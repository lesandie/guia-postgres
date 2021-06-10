-- En esta práctica vamos a crear la base de datos curso-postgresql, 
-- en la cual instalaremos las extensiones de postgis y pg_stat_statements
-- Además crearemos un usuarios con permisos
-- Instalar postgis

CREATE DATABASE curso_postgresql ENCODING UTF8 LC_COLLATE 'en_US.UTF-8' TEMPLATE template0;
-- CREATE DATABASE curso-postgresql WITH OWNER alumno ENCODING UTF8 LC_COLLATE 'en_US.UTF-8';
CREATE ROLE alumno WITH LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;
ALTER ROLE alumno WITH PASSWORD ‘alumno’;
GRANT ALL PRIVILEGES ON DATABASE curso_postgresql TO alumno;
--
CREATE EXTENSION postgis;
-- Esta última extensión requiere que antes configuremos el postgresql.conf y añadamos esta linea
-- shared_preload_libraries = 'pg_stat_statements'
CREATE EXTENSION pg_stat_statements;
-- 