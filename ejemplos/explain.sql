CREATE TABLE ejemplo_explain (id INT PRIMARY KEY, nombre TEXT NOT NULL);
INSERT INTO ejemplo_explain SELECT n, md5 (random()::text) FROM generate_series (1,100000) AS foo(n);
ANALYZE ejemplo_explain;
EXPLAIN SELECT * FROM ejemplo_explain;
ALTER TABLE ejemplo_explain ALTER COLUMN id SET STATISTICS 1;
EXPLAIN ANALYZE SELECT * FROM ejemplo_explain WHERE id >= 10 and id < 20;
EXPLAIN (ANALYZE, BUFFERS, FORMAT YAML) SELECT * FROM ejemplo_explain;
-- Casting para equivocar al planificador
EXPLAIN SELECT * FROM ejemplo_explain WHERE upper(id::text)::int < 20;
-- Sin desactivar ninguna opción del planificador
EXPLAIN ANALYZE WITH tmp AS (SELECT * FROM ejemplo_explain WHERE id <10000)
    SELECT * FROM tmp a inner join tmp b on a.id = b.id;
-- Desactivando hash y merge
SET enable_mergejoin TO off ;
SET enable_hashjoin TO off ;
EXPLAIN ANALYZE WITH tmp AS (SELECT * FROM guru WHERE id <10000)
    SELECT * FROM tmp a inner join tmp b on a.id = b.id;
-- de CTE a SQL
EXPLAIN ANALYZE SELECT * FROM guru as a inner join guru b on a.id = b.id WHERE a.id < 10000;
