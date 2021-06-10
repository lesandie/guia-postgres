-- En esta práctica vamos a crear funciones y triggers
--Crear xx función y xx trigger asociado a la tabla coches, que controlen que:
--•	Cuando se inserte un dato (INSERT), se compruebe que la nueva matrícula no existe y si existe marcar la nueva matrícula como errónea añadiendo la cadena de caracteres ERROR_ antes de la matrícula (ejemplo ERROR_4898HYB).
--•	Cuando se vaya a actualizar (UPDATE) una matrícula tenemos que verificar que la matrícula existente en la BD tenga la cadena de caracteres ERROR_.
--•	Verificar la necesidad de crear un índice en el campo matrícula
CREATE OR REPLACE FUNCTION actualizar_vl_apoyo_conductor_tramo() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
            NEW.num_tipoapoyo := concat(lpad(NEW.id_tipoapoyo::text,2,'0'), ' ', NEW.tipoapoyo);
            RETURN NEW;
    ELSEIF (TG_OP = 'UPDATE') THEN
            DELETE FROM vl_apoyo_3857 WHERE matricula = OLD.matricula;
            RETURN OLD;
    END IF;
    RETURN NULL;
END
$$ LANGUAGE plpgsql;
---------------------------------------------------------------------------
-- las estructuras NEW y OLD solo en triggers ROW-LEVEL
DROP TRIGGER vl_conductor_trigger ON vl_conductor_3857;
CREATE TRIGGER vl_conductor_trigger AFTER INSERT OR UPDATE OR DELETE 
ON vl_conductor_3857 FOR EACH ROW 
WHEN (pg_trigger_depth() = 0)
EXECUTE PROCEDURE actualizar_vl_apoyo_conductor_tramo();