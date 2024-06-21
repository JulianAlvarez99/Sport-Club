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


DELIMITER //

CREATE TRIGGER generar_cuota_social
AFTER INSERT ON POSEE
FOR EACH ROW
BEGIN
    DECLARE v_cod_cuota_social INT;
    DECLARE v_monto_base DECIMAL(10, 2);
    DECLARE v_modificacion DECIMAL(5, 2);
    DECLARE v_fecha_vigencia DATE;
    DECLARE v_cod_cuota_mensual INT;

    -- Inicializar el valor del código de cuota social
    SET v_cod_cuota_social = 100000;

    -- Obtener el código de la cuota mensual asociada al grupo familiar
    SELECT COD_CUOTA_MENSUAL
    INTO v_cod_cuota_mensual
    FROM CUOTA_MENSUAL
    WHERE NRO_GRUPO = NEW.NRO_GRUPO
    ORDER BY FECHA_VENC DESC
    LIMIT 1;

    IF v_cod_cuota_mensual IS NOT NULL THEN
        -- Determinar el monto base y la modificación según la categoría del socio
        CASE NEW.COD_CATEGORIA
            WHEN 1 THEN -- Infantil
                SELECT MODIFICACION_INFANTIL INTO v_modificacion FROM INFANTIL WHERE COD_CATEGORIA = NEW.COD_CATEGORIA;
            WHEN 2 THEN -- Mayor
                SELECT MODIFICACION_MAYOR INTO v_modificacion FROM MAYOR WHERE COD_CATEGORIA = NEW.COD_CATEGORIA;
            WHEN 3 THEN -- Vitalicio
                SELECT MODIFICACION_VITALICIO INTO v_modificacion FROM VITALICIO WHERE COD_CATEGORIA = NEW.COD_CATEGORIA;
            ELSE
                SET v_modificacion = 0;
        END CASE;

        -- Calcular la fecha de vigencia (un mes desde la fecha actual)
        SET v_fecha_vigencia = DATE_ADD(CURDATE(), INTERVAL 1 MONTH);

        -- Insertar la nueva cuota social
        INSERT INTO CUOTA_SOCIAL (COD_CUOTA_SOCIAL, MONTO_BASE, VIGENCIA_CUOTA_SOCIAL, PORCENTAJE_MODIFICACION, NRO_GRUPO, NRO_SOCIO, COD_CUOTA_MENSUAL)
        VALUES (v_cod_cuota_social, v_modificacion, v_fecha_vigencia, 0, NEW.NRO_GRUPO, NEW.NRO_SOCIO, v_cod_cuota_mensual);
    END IF;
END //

DELIMITER ;
