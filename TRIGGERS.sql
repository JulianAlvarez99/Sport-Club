DELIMITER //
#Un pago de arancel para un socio debe ser para una actividad en la cual está inscrito.
CREATE TRIGGER verificar_inscripcion_pago_arancel
BEFORE INSERT ON PAGO_ARANCEL
FOR EACH ROW
BEGIN
    DECLARE v_count INT;

    -- Verificar si el socio está inscrito en la actividad
    SELECT COUNT(*)
    INTO v_count
    FROM SE_INSCRIBE SI
    JOIN CRONOGRAMA C ON SI.COD_CRONOGRAMA = C.COD_CRONOGRAMA
    WHERE SI.NRO_SOCIO = NEW.NRO_SOCIO
    AND C.COD_ACTIVIDAD = NEW.COD_ACTIVIDAD;

    -- Si no está inscrito, lanza un error
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El socio no está inscrito en la actividad.';
    END IF;
END;
//
DELIMITER ;

-- TRIGGER PARA CARGAR LA TABLA POSEE CON LOS ULTIMOS SOCIOS AGREGADOS
DELIMITER $$
CREATE TRIGGER after_insert_socio
AFTER INSERT ON SOCIO
FOR EACH ROW
BEGIN
    DECLARE var_categoria INT;
    DECLARE var_periodo DATE DEFAULT CURDATE();
    
    SET var_categoria = 
            CASE 
                WHEN TIMESTAMPDIFF(YEAR, NEW.FECHA_NAC_SOCIO, CURDATE()) < 18 THEN 0317
                WHEN TIMESTAMPDIFF(YEAR, NEW.FECHA_NAC_SOCIO, CURDATE()) < 41 THEN 1840
                ELSE 4165
            END;
    
    -- Insertar en la tabla POSEE
    INSERT INTO POSEE (NRO_GRUPO, NRO_SOCIO, COD_CATEGORIA, PERIODO_CATEGORIA)
    VALUES (NEW.NRO_GRUPO, NEW.NRO_SOCIO, var_categoria, var_periodo);
END $$
DELIMITER ;

-- Crear trigger para validar antes de insertar en A_CARGO_DE
DELIMITER //
CREATE TRIGGER trg_before_insert_acargode
BEFORE INSERT ON A_CARGO_DE
FOR EACH ROW
BEGIN
    -- Verificar si el profesional está capacitado para la actividad
    IF NOT EXISTS (
        SELECT 1
        FROM ESTA_CAPACITADO_PARA
        WHERE LEGAJO = NEW.LEGAJO
          AND COD_ACTIVIDAD = NEW.COD_ACTIVIDAD
    ) THEN
        -- Si no está capacitado, lanzar un error
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El profesional no está capacitado para esta actividad';
    END IF;
END //

-- Restaurar el delimitador a ;
DELIMITER ;