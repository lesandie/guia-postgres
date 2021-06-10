SELECT consumo.fechafin AS fecha, maquinas.nombre AS nombre_maquina, institucion.nombre AS nombre instit, consumo.idusuario, aplicacion.nombre AS nombre_aplic, ejecutable.nombre AS nombre_ejec, 
consumo.estado AS estado, COUNT(consumo.idconsumo) AS idconsumo, SUM(consumo.systcpu) AS systcpu, SUM(consumo.usercpu) AS usercpu, SUM(consumo.elapcpu) AS elapcpu, 
MAX(consumo.memory) AS memory, SUM(consumo.io) AS io, SUM(consumo.rw) AS rw 
FROM ((ejecutable INNER JOIN 
	   	(aplicacion INNER JOIN 
			(aplicejec INNER JOIN maquinas ON aplicejec.idmaquina = maquinas.idmaquina) 
				ON aplicacion.idaplic = aplicejec.idaplic) 
	   				ON ejecutable.idejec = aplicejec.idejec) 
	  					INNER JOIN consumo ON aplicejec.idaplicejec = consumo.idaplicejec) 
							INNER JOIN institucion ON consumo.idinstitucion = institucion.id_instit 
GROUP BY consumo.fechafin, maquinas.nombre, institucion.nombre, consumo.idusuario, aplicacion.nombre, ejecutable.nombre, consumo.estado;
--
SELECT consumo.fechafin, maquinas.nombre, institucion.nombre, consumo.idusuario, aplicacion.nombre, ejecutable.nombre, 
consumo.estado, COUNT(consumo.idconsumo), SUM(consumo.systcpu), SUM(consumo.usercpu), SUM(consumo.elapcpu), 
MAX(consumo.memory), SUM(consumo.io), SUM(consumo.rw) 
FROM consumo, maquinas, institucion, aplicacion, aplicejec, ejecutable
-- INNER JOIN institucion ON consumo.idinstitucion = institucion.id_instit 
WHERE
institucion.id_instit = consumo.idinstitucion AND
consumo.idaplicejec = aplicejec.idaplicejec AND
aplicejec.idmaquina = maquinas.idmaquina AND
aplicejec.idaplic = aplicacion.idaplic AND
aplicejec.idejec = ejecutable.idejec
GROUP BY consumo.fechafin, maquinas.nombre, institucion.nombre, consumo.idusuario, aplicacion.nombre, ejecutable.nombre, consumo.estado;

SELECT count(*) FROM consumo;

