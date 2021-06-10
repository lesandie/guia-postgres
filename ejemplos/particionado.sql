CREATE TABLE t_data (id serial, fecha date, carga text);
CREATE TABLE t_data_2017 () INHERITS (t_data);
CREATE TABLE t_data_2018 (tipo_carga text) INHERITS (t_data);
-- Describe tablas
SELECT column_name, data_type, character_maximum_length
FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 't_data_2017';
-- Carga de datos
INSERT INTO t_data_2017 (fecha, carga) VALUES ('2017-05-04', 'alimentaria 1235');
INSERT INTO t_data_2017 (fecha, carga) VALUES ('2017-06-04', 'herramientas 73774');
INSERT INTO t_data_2018 (fecha, carga, tipo_carga) VALUES ('2017-07-04', 'herramientas 54993', 'contenedor3');
INSERT INTO t_data_2018 (fecha, carga, tipo_carga) VALUES ('2017-08-04', 'alimentaria 34421', 'caja332');
-- acceso a toda la estructura
EXPLAIN SELECT * FROM t_data WHERE fecha = '2017-01-04';
-- constraints check
ALTER TABLE t_data_2017 
ADD CHECK (fecha >= '2017-01-01' AND fecha < '2018-01-01');
ALTER TABLE t_data_2017 
ADD CHECK (fecha >= '2018-01-01' AND fecha < '2019-01-01');
-- ver que selecciona la particion correcta
EXPLAIN SELECT * FROM t_data WHERE fecha = '2017-01-04';