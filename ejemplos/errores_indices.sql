CREATE TABLE ejemplo_indice (id int, descripcion text, explain_id int references ejemplo_explain(id));
--
INSERT INTO ejemplo_indice (id, descripcion, explain_id) 
    SELECT n, md5(n::text), random()*99999+1 FROM generate_series(1,200000) AS foo(n);
--
EXPLAIN ANALYZE SELECT * FROM ejemplo_explain INNER JOIN ejemplo_indice 
                ON ejemplo_explain.id = ejemplo_indice.explain_id 
                WHERE explain_id = 1000;
--
CREATE INDEX ON ejemplo_indice (explain_id);
--
CREATE OR REPLACE FUNCTION generate_random_text (int) RETURNS TEXT AS
$$
SELECT string_agg(substr('0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', trunc(random() * 62)::integer + 1, 1), '') FROM generate_series(1, $1)
$$
LANGUAGE SQL;
--
CREATE TABLE login AS SELECT n, generate_random_text(8) AS login_name FROM generate_series(1, 1000) AS foo(n);
CREATE INDEX ON login(login_name);
VACUUM ANALYZE login;
-- Vemos si el analizador utiliza el indice
EXPLAIN SELECT * FROM login WHERE login_name = 'jxaG6gjJ';
-- variante con lower que utiliza el indice
EXPLAIN SELECT * FROM login WHERE login_name = lower('jxaG6gjJ');
-- variante que no lo utiliza
EXPLAIN SELECT * FROM login WHERE lower(login_name) = 'jxaG6gjJ';
-- indice para texto búsqueda por patrones LIKE %
CREATE INDEX on login (login_name text_pattern_ops);
EXPLAIN ANALYZE SELECT * FROM login WHERE login_name like 'a%';