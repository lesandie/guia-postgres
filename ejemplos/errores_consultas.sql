-- postgres=# \timing 
-- Timing is on.
SELECT * FROM ejemplo_explain;
--Time: 85,089 ms
SELECT DISTINCT * FROM ejemplo_explain;
--Time: 191,335 ms
--
SELECT * FROM ejemplo_explain UNION SELECT * FROM ejemplo_explain;
--Time: 267,258 ms
SELECT DISTINCT * FROM ejemplo_explain UNION SELECT DISTINCT * FROM ejemplo_explain;
--Time: 346,014 ms
--
CREATE OR REPLACE VIEW vw_explain AS SELECT * FROM ejemplo_explain ORDER BY 1 ASC
--Time: 42,370 ms
SELECT * FROM vw_explain;
--Time: 132,292 ms

