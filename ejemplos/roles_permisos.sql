-- admin
CREATE ROLE administrador NOSUPERUSER INHERIT CREATEDB CREATEROLE NOREPLICATION VALID UNTIL 'infinity';
ALTER DATABASE pruebas OWNER TO administrador;
ALTER SCHEMA PUBLIC OWNER TO administrador;
GRANT ALL PRIVILEGES ON SCHEMA public TO administrador;
GRANT ALL PRIVILEGES ON DATABASE pruebas TO admintrador;
-- usuario1, ejecutar conectado a la base de datos en la que queramos asignar los permisos
CREATE ROLE usuario1 WITH LOGIN;
ALTER ROLE usuario1 WITH PASSWORD 'usuario1.u&';
GRANT administrador to usuario1;
GRANT CONNECT ON DATABASE pruebas TO usuario1;
GRANT USAGE ON SCHEMA public TO usuario1;
GRANT SELECT,INSERT,UPDATE ON ALL TABLES IN SCHEMA public TO usuario1;

