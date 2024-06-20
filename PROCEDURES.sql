-- STORED PROCEDURE PARA CARGAR LA TABLA POSEE CON VALORES DEFAULT
DELIMITER $$
CREATE PROCEDURE CargarPosee()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE var_nro_grupo INT;
    DECLARE var_nro_socio INT;
    DECLARE var_fecha_nac DATE;
    DECLARE var_categoria INT;
    DECLARE var_periodo DATE DEFAULT CURDATE();
    DECLARE socio_cursor CURSOR FOR 
    SELECT NRO_GRUPO, NRO_SOCIO, FECHA_NAC_SOCIO FROM SOCIO;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN socio_cursor;
    
    socio_loop: LOOP
        FETCH socio_cursor INTO var_nro_grupo, var_nro_socio, var_fecha_nac;
        IF done THEN
            LEAVE socio_loop;
        END IF;
        
        -- Determinar la categoría en función de la edad
        SET var_categoria = 
            CASE 
                WHEN TIMESTAMPDIFF(YEAR, var_fecha_nac, CURDATE()) < 18 THEN 0317
                WHEN TIMESTAMPDIFF(YEAR, var_fecha_nac, CURDATE()) < 41 THEN 1840
                ELSE 4165
            END;
        
        -- Insertar en la tabla POSEE
        INSERT INTO POSEE (NRO_GRUPO, NRO_SOCIO, COD_CATEGORIA, PERIODO_CATEGORIA)
        VALUES (var_nro_grupo, var_nro_socio, var_categoria, var_periodo);
    END LOOP;
    
    CLOSE socio_cursor;
END $$

DELIMITER ;

CALL CargarPosee();

-- Store procedure para crear turnos
DELIMITER $$
CREATE PROCEDURE create_turnos(
    IN start_date DATE,
    IN end_date DATE,
    IN turnos_por_dia INT, -- TURNOS POR DIA PARA CADA UNA DE LAS AREAS, SON 6
    IN intervalo INT,
    IN hora_inicio TIME
)
BEGIN
    DECLARE curr_date DATE;
    DECLARE turno_id INT;
    DECLARE hora TIME;
    DECLARE i INT DEFAULT 0;
	DECLARE J INT DEFAULT 0;
    DECLARE CANT_AREAS INT DEFAULT 0;
    
    SET curr_date = start_date;
    
	SELECT COUNT(*) INTO CANT_AREAS
	FROM AREA;
    
    WHILE curr_date <= end_date DO
        SET i = 0;
        WHILE i < turnos_por_dia DO
            SET hora = ADDTIME(hora_inicio, SEC_TO_TIME(i * intervalo * 60)); -- intervalo en minutos
            SET j = 0;
            WHILE j < CANT_AREAS DO
				
                SELECT IFNULL(MAX(COD_TURNO), 99) + 1 INTO turno_id
				FROM TURNO;
				
                INSERT INTO TURNO (COD_TURNO, FECHA_TURNO, HORARIO) VALUES (turno_id, curr_date, hora);
                SET j = j + 1;
			END WHILE;	
            SET i = i + 1;
        END WHILE;
        SET curr_date = DATE_ADD(curr_date, INTERVAL 1 DAY);
    END WHILE;
END$$
DELIMITER ;

-- Ejemplo de cómo llamar al procedimiento
DELETE FROM TURNO;
CALL create_turnos('2024-06-20', '2024-07-19', 7, 120, '08:00:00');


DELIMITER //
CREATE PROCEDURE CrearCronograma(
    IN p_PERIODO DATE,
    IN p_NOMBRE_ACT VARCHAR(30),
    IN p_HORARIO TIME
)
BEGIN
    DECLARE v_COD_CRONOGRAMA INT;
    DECLARE v_COD_ACTIVIDAD INT;
    DECLARE v_LEGAJO INT;
    DECLARE v_COD_AREA INT;
    DECLARE v_COD_TURNO INT;
    DECLARE v_error_message VARCHAR(255);
    
    -- Obtener el código de la actividad
    SELECT COD_ACTIVIDAD INTO v_COD_ACTIVIDAD
    FROM ACTIVIDAD
    WHERE NOMBRE_ACT = p_NOMBRE_ACT
    LIMIT 1;

    -- Verificar si la actividad existe
    IF v_COD_ACTIVIDAD IS NULL THEN
        SET v_error_message = 'La actividad no existe.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_message;
    END IF;

    -- Obtener el profesional a cargo de la actividad
    SELECT LEGAJO INTO v_LEGAJO
    FROM A_CARGO_DE
    WHERE COD_ACTIVIDAD = v_COD_ACTIVIDAD
    LIMIT 1;

    -- Verificar si existe un profesional a cargo
    IF v_LEGAJO IS NULL THEN
        SET v_error_message = 'No hay un profesional a cargo de esta actividad.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_message;
    END IF;

	-- Obtener un área disponible para la actividad 
    SELECT COD_AREA INTO v_COD_AREA
    FROM AREA
    WHERE ACTIVIDADES LIKE CONCAT('%', p_NOMBRE_ACT, '%')
    AND COD_AREA NOT IN (SELECT COD_AREA 
						 FROM CRONOGRAMA 
						 WHERE COD_TURNO IN (SELECT COD_TURNO 
											FROM TURNO
											WHERE COD_TURNO IN (SELECT COD_TURNO FROM CRONOGRAMA)
											AND HORARIO = p_HORARIO
											AND FECHA_TURNO = p_PERIODO));
    -- Verificar si existe un área
    IF v_COD_AREA IS NULL THEN
        SET v_error_message = 'No hay un área disponible.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_message;
    END IF;

    -- Obtener el turno correspondiente al horario proporcionado
    -- Chequea que haya turnos disponibles en ese horario
    SELECT COD_TURNO INTO v_COD_TURNO
	FROM TURNO
	WHERE COD_TURNO NOT IN (SELECT COD_TURNO FROM CRONOGRAMA)
	AND HORARIO = p_HORARIO
    AND FECHA_TURNO = p_PERIODO
    LIMIT 1;
    
    -- Verificar si existe el turno
    IF v_COD_TURNO IS NULL THEN
        SET v_error_message = 'No hay un turno disponible con ese horario.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_message;
    END IF;
    
    -- Verificar si el área y el turno están disponibles para el período especificado
    IF EXISTS (
        SELECT 1
        FROM CRONOGRAMA
        WHERE PERIODO = p_PERIODO
          AND COD_AREA = v_COD_AREA
          AND COD_TURNO = v_COD_TURNO
    ) THEN
        SET v_error_message = 'El área y el turno ya están ocupados para este turno en este periodo.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_message;
    END IF;

    -- Obtener el próximo COD_CRONOGRAMA disponible, empezando desde 10000
    SELECT IFNULL(MAX(COD_CRONOGRAMA), 9999) + 1 INTO v_COD_CRONOGRAMA
    FROM CRONOGRAMA;

    -- Insertar en la tabla CRONOGRAMA
    INSERT INTO CRONOGRAMA (COD_CRONOGRAMA, PERIODO, LEGAJO, COD_ACTIVIDAD, COD_AREA, COD_TURNO)
    VALUES (v_COD_CRONOGRAMA, p_PERIODO, v_LEGAJO, v_COD_ACTIVIDAD, v_COD_AREA, v_COD_TURNO);
END //
DELIMITER ;


-- Procedimiento para inscribir socio en actividad
DELIMITER //
CREATE PROCEDURE InscribirSocioEnActividad(
    IN p_NRO_GRUPO INT,
    IN p_NRO_SOCIO INT,
    IN p_NOMBRE_ACT VARCHAR(50),
    IN p_PERIODO DATE,
    IN p_HORARIO TIME
)
BEGIN
    DECLARE v_COD_ACTIVIDAD INT;
    DECLARE v_COD_CRONOGRAMA INT;
    DECLARE v_FECHA_INSCRIPCION DATE;
    DECLARE v_COD_TURNO INT;
    DECLARE v_CUPO INT DEFAULT 0;
    DECLARE v_CUPO_MAX INT DEFAULT 0;
    DECLARE v_error_message VARCHAR(255);

    -- Verificar que el socio existe en el grupo familiar
    IF NOT EXISTS (SELECT 1 FROM SOCIO WHERE NRO_GRUPO = p_NRO_GRUPO AND NRO_SOCIO = p_NRO_SOCIO) THEN
        SET v_error_message = 'El socio no existe en el grupo familiar proporcionado.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_message;
    END IF;

    -- Obtener el código de la actividad a partir del nombre de la actividad
    SELECT COD_ACTIVIDAD INTO v_COD_ACTIVIDAD
    FROM ACTIVIDAD
    WHERE NOMBRE_ACT = p_NOMBRE_ACT
    LIMIT 1;

    -- Verificar si la actividad existe
    IF v_COD_ACTIVIDAD IS NULL THEN
        SET v_error_message = 'La actividad no existe.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_message;
    END IF;
	
    SELECT COUNT(*) INTO v_CUPO
	FROM SE_INSCRIBE AS SE
	INNER JOIN CRONOGRAMA AS CR ON SE.COD_CRONOGRAMA =CR.COD_CRONOGRAMA
	INNER JOIN ACTIVIDAD AS ACT ON CR.COD_ACTIVIDAD = ACT.COD_ACTIVIDAD
	INNER JOIN TURNO AS T ON CR.COD_TURNO = T.COD_TURNO;
    
    SELECT CAPACIDAD INTO v_CUPO_MAX
    FROM AREA
    WHERE COD_AREA = (SELECT COD_AREA
					  FROM CRONOGRAMA
                      WHERE COD_ACTIVIDAD = v_COD_ACTIVIDAD
                      LIMIT 1);
                      
	IF v_CUPO >= v_CUPO_MAX THEN
		SET v_error_message = 'La actividad alcanzó su cupo maximo para este turno';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_message;
    END IF;
    
	SELECT COD_TURNO INTO v_COD_TURNO
    FROM TURNO
    WHERE FECHA_TURNO = p_PERIODO 
		AND HORARIO = p_HORARIO
	LIMIT 1;
    
    -- Obtener el código del cronograma más reciente para la actividad
    SELECT COD_CRONOGRAMA INTO v_COD_CRONOGRAMA
    FROM CRONOGRAMA
    WHERE COD_ACTIVIDAD = v_COD_ACTIVIDAD
	  AND PERIODO = p_PERIODO
      AND COD_TURNO = v_COD_TURNO
    ORDER BY PERIODO 
    LIMIT 1;

    -- Verificar si el cronograma existe
    IF v_COD_CRONOGRAMA IS NULL THEN
        SET v_error_message = 'No hay un cronograma disponible para esta actividad.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_message;
    END IF;

    -- Verificar si el socio ya está inscrito en el cronograma
    IF EXISTS (SELECT 1 FROM SE_INSCRIBE WHERE NRO_GRUPO = p_NRO_GRUPO AND NRO_SOCIO = p_NRO_SOCIO AND COD_CRONOGRAMA = v_COD_CRONOGRAMA) THEN
        SET v_error_message = 'El socio ya está inscrito en esta actividad en el cronograma actual.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_message;
    END IF;

    -- Establecer la fecha de inscripción como la fecha actual
    SET v_FECHA_INSCRIPCION = CURDATE();

    -- Insertar en la tabla SE_INSCRIBE
    INSERT INTO SE_INSCRIBE (NRO_GRUPO, NRO_SOCIO, COD_CRONOGRAMA, FECHA_INSCRIPCION)
    VALUES (p_NRO_GRUPO, p_NRO_SOCIO, v_COD_CRONOGRAMA, v_FECHA_INSCRIPCION);
END //

DELIMITER ;

DELETE FROM SE_INSCRIBE;

SELECT *
FROM CRONOGRAMA
ORDER BY PERIODO;

SELECT *
FROM TURNO
WHERE COD_TURNO = 388;

CREATE VIEW SOCIOS_INSCRIPTOS AS
SELECT NRO_GRUPO, NRO_SOCIO, NOMBRE_ACT, FECHA_TURNO, HORARIO
FROM SE_INSCRIBE AS SE
INNER JOIN CRONOGRAMA AS CR ON SE.COD_CRONOGRAMA =CR.COD_CRONOGRAMA
INNER JOIN ACTIVIDAD AS ACT ON CR.COD_ACTIVIDAD = ACT.COD_ACTIVIDAD
INNER JOIN TURNO AS T ON CR.COD_TURNO = T.COD_TURNO;

SELECT COUNT(*)
FROM SOCIOS_INSCRIPTOS;



