-- función factorial
CREATE OR REPLACE FUNCTION factorial(INTEGER) RETURNS INTEGER AS $$
BEGIN
  IF $1 IS NULL OR $1 < 0 THEN RAISE NOTICE 'Invalid Number';
    RETURN NULL;
  ELSIF $1 = 1 THEN 
    RETURN 1;
  ELSE 
    RETURN factorial($1 - 1) * $1;
END IF;
END;  
$$ LANGUAGE 'plpgsql';
-- Utilizando un alias para $1
-- Es una función recursiva
CREATE OR REPLACE FUNCTION factorial(INTEGER) RETURNS INTEGER AS $$
  DECLARE
    fact ALIAS FOR $1;
    result INTEGER;
  BEGIN
  IF fact IS NULL OR fact < 0 THEN RAISE NOTICE 'Invalid Number';
    RETURN NULL;
  ELSIF fact = 1 THEN
    RETURN 1;
  ELSE
    result = factorial(fact - 1) * fact;
    RETURN result;
  END IF;
  END;
$$ LANGUAGE 'plpgsql';
-- Condicionales
CREATE OR REPLACE FUNCTION escala_texto (valor int) RETURNS TEXT AS $$
DECLARE
  valor ALIAS FOR $1;
  resultado TEXT;
BEGIN
  IF valor = 5 THEN resultado = 'Excelente';
    ELSIF valor = 4 THEN resultado = 'Muy bueno';
    ELSIF valor = 3 THEN resultado = 'Bueno';
    ELSIF valor = 2 THEN resultado ='Decente';
    ELSIF valor = 1 THEN resultado ='Malo';
    ELSE resultado ='No existe';
  END IF;
  RETURN resultado;
END;
$$ LANGUAGE plpgsql;
-- probar la anterior funcion
SELECT n, escala_texto(n) FROM generate_series(1,6) AS salida(n);
-- La función anterior con IF ELSIF
CREATE OR REPLACE FUNCTION escala_texto (valor INT) RETURNS TEXT AS $$
DECLARE
valor ALIAS FOR $1;
resultado TEXT;
BEGIN
  CASE 
    WHEN valor=5 THEN resultado = 'Excelente';
    WHEN valor=4 THEN resultado = 'Muy bueno';
    WHEN valor=3 THEN resultado = 'Bueno';
    WHEN valor=2 THEN resultado ='Decente';
    WHEN valor=1 THEN resultado ='Malo';
    WHEN valor IS NULL THEN RAISE EXCEPTION 'Valor no debe ser NULL';
    ELSE resultado ='No existe ese valor';
  END CASE;
  RETURN resultado;
END;
$$ LANGUAGE plpgsql;
-- WHILE
DO $$
DECLARE
	contador INT := 1;
BEGIN
	WHILE (contador < 1000) LOOP
		RAISE NOTICE ‘ Estoy contando hasta 1000 y voy por el % ‘, contador;
		contador := contador + 1;
	END LOOP  
END;
$$ LANGUAGE plpgsql;
-- FOR LOOP
DO $$
DECLARE
 	database RECORD;
BEGIN
 	FOR database IN SELECT * FROM pg_database LOOP
 		RAISE notice '%', database.datname;
 	END LOOP;
END; 
-- captura de excepciones
CREATE OR REPLACE FUNCTION check_not_null (value anyelement) RETURNS VOID AS
$$
BEGIN
 	IF (value IS NULL) THEN RAISE EXCEPTION USING ERRCODE = 'check_violation'; 
 	END IF;
END;
$$ LANGUAGE plpgsql;
-- reescritura factorial
DROP FUNCTION IF EXISTS factorial(INTEGER);
CREATE OR REPLACE FUNCTION factorial(INTEGER) RETURNS BIGINT AS $$
DECLARE
 	fact ALIAS FOR $1;
BEGIN
 	PERFORM check_not_null(fact);
 	IF fact > 1 THEN RETURN factorial(fact - 1) * fact;
 	ELSIF fact IN (0,1) THEN RETURN 1;
 	ELSE RETURN NULL;
 	END IF;
 	EXCEPTION 
 		WHEN check_violation THEN RETURN NULL;
 		WHEN OTHERS THEN RAISE NOTICE '% %', SQLERRM, SQLSTATE;
END;
$$ LANGUAGE 'plpgsql';
-- SQL dinámico
CREATE OR REPLACE FUNCTION analizar_tablas (esquema TEXT) RETURNS BOOLEAN AS $$
DECLARE
 	nombre_tabla text;
  esquema ALIAS FOR $1;
BEGIN
 	FOR nombre_tabla IN SELECT tablename FROM pg_tables WHERE schemaname = esquema LOOP
 		RAISE NOTICE 'Analizando %', nombre_tabla;
 		EXECUTE 'ANALYZE ' || table_name;
 	END LOOP;
RETURN TRUE;
EXCEPTION WHEN OTHERS THEN 
  RAISE NOTICE '% %', SQLERRM, SQLSTATE;
	RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

