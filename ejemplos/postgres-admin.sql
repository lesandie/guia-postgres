-------------------
-- Check max conn
-------------------
SELECT  * FROM
(SELECT COUNT(*) used FROM pg_stat_activity) q1,
(SELECT setting::int res_for_super FROM pg_settings WHERE name=$$superuser_reserved_connections$$) q2,
(SELECT setting::int max_conn FROM pg_settings WHERE name=$$max_connections$$) q3;
-------------------------
-- Check archiving status
-------------------------
SELECT * FROM pg_catalog.pg_stat_archiver;
-----------------------
-- Kill connections
----------------------
SELECT pg_terminate_backend(pid) FROM pg_stat_activity 
WHERE pid <> pg_backend_pid() AND datname = current_database();
----------------------
-- Cache hit ratio
----------------------
-- For many application, not all the data is accessed all the time. 
-- Instead, certain datasets are accessed one and then for some period of time, then the data 
-- you're accessing changes. Postgres is, in fact, quite good at keeping frequently accessed data in memory.
-- Your cache hit ratio tells you how often your data is served from in memory vs. having to go to disk. 
-- Serving from memory vs. going to disk will be orders of magnitude faster, thus the more you can 
-- keep in memory, the better. Of course, you could provision an instance with as much memory as you 
-- have data, but you don't necessarily have to. Instead, watching your cache hit ratio and ensuring
-- it is at 99 percent is a good metric for proper performance.
-- You can monitor your cache hit ratio with:
SELECT 
  sum(heap_blks_read) as heap_read,
  sum(heap_blks_hit)  as heap_hit,
  sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)) as ratio
FROM 
  pg_statio_user_tables;
-----------------------
-- BLOAT
------------------------
-- Under the covers, Postgres is essentially a giant append only log. When you write data, it appends 
-- to the log, and when you update data, it marks the old record as invalid and writes a new one. 
-- When you delete data, it just marks it invalid. Later, Postgres comes through and vacuums those 
-- dead records (also known as tuples).
-- All those unvacuumed dead tuples are what is known as bloat. Bloat can slow down other writes and 
-- create other issues. Paying attention to your bloat and when it is getting out of hand can be key 
-- for tuning vacuum on your database.
WITH constants AS (
  SELECT current_setting('block_size')::numeric AS bs, 23 AS hdr, 4 AS ma
), bloat_info AS (
  SELECT
    ma,bs,schemaname,tablename,
    (datawidth+(hdr+ma-(case when hdr%ma=0 THEN ma ELSE hdr%ma END)))::numeric AS datahdr,
    (maxfracsum*(nullhdr+ma-(case when nullhdr%ma=0 THEN ma ELSE nullhdr%ma END))) AS nullhdr2
  FROM (
    SELECT
      schemaname, tablename, hdr, ma, bs,
      SUM((1-null_frac)*avg_width) AS datawidth,
      MAX(null_frac) AS maxfracsum,
      hdr+(
        SELECT 1+count(*)/8
        FROM pg_stats s2
        WHERE null_frac<>0 AND s2.schemaname = s.schemaname AND s2.tablename = s.tablename
      ) AS nullhdr
    FROM pg_stats s, constants
    GROUP BY 1,2,3,4,5
  ) AS foo
), table_bloat AS (
  SELECT
    schemaname, tablename, cc.relpages, bs,
    CEIL((cc.reltuples*((datahdr+ma-
      (CASE WHEN datahdr%ma=0 THEN ma ELSE datahdr%ma END))+nullhdr2+4))/(bs-20::float)) AS otta
  FROM bloat_info
  JOIN pg_class cc ON cc.relname = bloat_info.tablename
  JOIN pg_namespace nn ON cc.relnamespace = nn.oid AND nn.nspname = bloat_info.schemaname AND nn.nspname <> 'information_schema'
), index_bloat AS (
  SELECT
    schemaname, tablename, bs,
    COALESCE(c2.relname,'?') AS iname, COALESCE(c2.reltuples,0) AS ituples, COALESCE(c2.relpages,0) AS ipages,
    COALESCE(CEIL((c2.reltuples*(datahdr-12))/(bs-20::float)),0) AS iotta -- very rough approximation, assumes all cols
  FROM bloat_info
  JOIN pg_class cc ON cc.relname = bloat_info.tablename
  JOIN pg_namespace nn ON cc.relnamespace = nn.oid AND nn.nspname = bloat_info.schemaname AND nn.nspname <> 'information_schema'
  JOIN pg_index i ON indrelid = cc.oid
  JOIN pg_class c2 ON c2.oid = i.indexrelid
)
SELECT
  type, schemaname, object_name, bloat, pg_size_pretty(raw_waste) as waste
FROM
(SELECT
  'table' as type,
  schemaname,
  tablename as object_name,
  ROUND(CASE WHEN otta=0 THEN 0.0 ELSE table_bloat.relpages/otta::numeric END,1) AS bloat,
  CASE WHEN relpages < otta THEN '0' ELSE (bs*(table_bloat.relpages-otta)::bigint)::bigint END AS raw_waste
FROM
  table_bloat
    UNION
SELECT
  'index' as type,
  schemaname,
  tablename || '::' || iname as object_name,
  ROUND(CASE WHEN iotta=0 OR ipages=0 THEN 0.0 ELSE ipages/iotta::numeric END,1) AS bloat,
  CASE WHEN ipages < iotta THEN '0' ELSE (bs*(ipages-iotta))::bigint END AS raw_waste
FROM
  index_bloat) bloat_summary
ORDER BY raw_waste DESC, bloat DESC
------------------------------------
-- Removing unused indexes
------------------------------------
-- We always want our database to be performant, so in order to do that, we keep things in memory/cache 
-- (see earlier) and we index things so we don't have to scan everything on disk. But there is a trade-off
-- when it comes to indexing your database. Each index the system has to maintain will slow down your
-- write throughput on the database. This is fine when you do need to speed up queries, as long as 
-- they're being utilized. If you added an index years ago, but something within your application 
-- changed and you no longer need it, it's best to remove it.
-- Postgres makes it simple to query for unused indexes so you can easily give yourself back some 
-- performance by removing them:
SELECT
  schemaname || '.' || relname AS table,
  indexrelname AS index,
  pg_size_pretty(pg_relation_size(i.indexrelid)) AS index_size,
  idx_scan as index_scans
FROM pg_stat_user_indexes ui
JOIN pg_index i ON ui.indexrelid = i.indexrelid
WHERE NOT indisunique AND idx_scan < 50 AND pg_relation_size(relid) > 5 * 8192
ORDER BY pg_relation_size(i.indexrelid) / nullif(idx_scan, 0) DESC NULLS FIRST,
pg_relation_size(i.indexrelid) DESC;
---------------------------------------
-- Check in on Your Query Performance
---------------------------------------
-- In an earlier post, we talked about how useful pg_stat_statements was for monitoring your 
-- database query performance. It records a lot of valuable stats about which queries are run, 
-- how fast they return, how many times their run, etc. Checking in on this set of queries regularly
-- can tell you where it's best to add indexes or optimize your application so your query calls may 
-- not be so excessive.
-- Thanks to a HN commenter on our earlier post, we have a great query that is easy to tweak to 
-- show different views based on all that data:
SELECT query, 
       calls, 
       total_time, 
       total_time / calls as time_per, 
       stddev_time, 
       rows, 
       rows / calls as rows_per,
       100.0 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0) AS hit_percent
FROM pg_stat_statements
WHERE query not similar to '%pg_%'
and calls > 500
--ORDER BY calls
--ORDER BY total_time
order by time_per
--ORDER BY rows_per
DESC LIMIT 20;
----------------------------------------