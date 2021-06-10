CREATE OR REPLACE FUNCTION function_ejemplo () RETURNS INT AS $$
    SELECT nombre FROM ejemplo_explain WHERE id <= 90000;
$$ LANGUAGE SQL;
-- no utiliza el cacheo
CREATE OR REPLACE FUNCTION function_ejemplo () RETURNS INT AS $$
    SELECT nombre FROM ejemplo_explain WHERE id = 90000;
$$ LANGUAGE SQL;
-- utiliza cacheando


