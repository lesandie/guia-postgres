SELECT * FROM ejemplo_explain WHERE id = 4;
--
WITH ejemplo_cte as (SELECT * FROM ejemplo_explain) SELECT * FROM ejemplo_cte WHERE id = 4;
--