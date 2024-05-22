USE ClubDeportivo;

INSERT INTO SOCIO (NRO_SOCIO, NOMBRE_SOCIO, FECHA_NAC_SOCIO, MAIL) VALUES
(1, 'Juan Perez', '1985-03-20', 'juan.perez@example.com'),
(2, 'Maria Garcia', '1990-07-15', 'maria.garcia@example.com'),
(3, 'Carlos Lopez', '1975-11-30', 'carlos.lopez@example.com');

INSERT INTO CUOTA_MENSUAL (COD_CUOTA_MENSUAL, NOMBRE_TITULAR, IMPORTE_A_PAGAR, FECHA_VENC) VALUES
(1, 'Juan Perez', 50.00, '2024-06-01'),
(2, 'Maria Garcia', 50.00, '2024-06-01'),
(3, 'Carlos Lopez', 50.00, '2024-06-01');

INSERT INTO GRUPO_FAMILIAR (NRO_GRUPO, NRO_SOCIO_TITULAR, COD_CUOTA_MENSUAL, DOMICILIO) VALUES
(1, 1, 1, 'Calle Falsa 123'),
(2, 2, 2, 'Avenida Siempre Viva 456'),
(3, 3, 3, 'Boulevard de los Sueños 789');

INSERT INTO CONTACTO (PREFIJO, NRO_TELEFONO, DESCRIPCION, NRO_GRUPO) VALUES
(54, 1112345678, 'Casa', 1),
(54, 1123456789, 'Trabajo', 2),
(54, 1134567890, 'Móvil', 3);

INSERT INTO PAGO_MENSUAL (COD_CUOTA_MENSUAL, COD_PAGO_MENSUAL, IMPORTE_PAGO_MENSUAL, FECHA_PAGO_MENSUAL) VALUES
(1, 1, 50.00, '2024-05-15'),
(2, 2, 50.00, '2024-05-15'),
(3, 3, 50.00, '2024-05-15');

INSERT INTO CUOTA_SOCIAL (COD_CUOTA_SOCIAL, MONTO_BASE, VIGENCIA_CUOTA_SOCIAL, PORCENTAJE_MODIFICACION, NRO_SOCIO, COD_CUOTA_MENSUAL) VALUES
(1, 100.00, '2024-01-01', 10.00, 1, 1),
(2, 100.00, '2024-01-01', 10.00, 2, 2),
(3, 100.00, '2024-01-01', 10.00, 3, 3);

INSERT INTO CATEGORIA (COD_CATEGORIA, PERIODO_CATEGORIA, TIPO_CATEGORIA) VALUES
(1, '2024-01-01', 'INFANTIL'),
(2, '2024-01-01', 'MAYOR'),
(3, '2024-01-01', 'VITALICIO');

INSERT INTO INFANTIL (COD_CATEGORIA, MODIFICACION_INFANTIL) VALUES
(1, 5.00);

INSERT INTO MAYOR (COD_CATEGORIA, MODIFICACION_MAYOR) VALUES
(2, 10.00);

INSERT INTO VITALICIO (COD_CATEGORIA, MODIFICACION_VITALICIO) VALUES
(3, 15.00);

INSERT INTO POSEE (NRO_SOCIO, COD_CATEGORIA) VALUES
(1, 1),
(2, 2),
(3, 3);

INSERT INTO ACTIVIDAD (COD_ACTIVIDAD, NOMBRE_ACT, COSTO) VALUES
(1, 'Natación', 200.00),
(2, 'Fútbol', 150.00),
(3, 'Tenis', 180.00);

INSERT INTO PERTENECE (COD_ACTIVIDAD, COD_CATEGORIA) VALUES
(1, 1),
(2, 2),
(3, 3);

INSERT INTO PROFESIONAL (LEGAJO, NOMBRE_PROF, FECHA_NAC_PROF, TIPO_DOC, NRO_DOC) VALUES
(1, 'Pedro Martinez', '1970-02-25', 'DNI', 12345678),
(2, 'Ana Suarez', '1980-05-10', 'DNI', 87654321),
(3, 'Lucia Gomez', '1990-08-15', 'DNI', 11223344);

INSERT INTO ESTA_CAPACITADO_PARA (COD_ACTIVIDAD, LEGAJO) VALUES
(1, 1),
(2, 2),
(3, 3);

INSERT INTO A_CARGO_DE (COD_ACTIVIDAD, LEGAJO) VALUES
(1, 1),
(2, 2),
(3, 3);

INSERT INTO GRATUITA (COD_ACTIVIDAD) VALUES
(1);

INSERT INTO ARANCELADA (COD_ACTIVIDAD, ARANCEL) VALUES
(2, 150.00),
(3, 180.00);

INSERT INTO PAGO_ARANCEL (COD_ACTIVIDAD, COD_PAGO_ARANCEL, NRO_SOCIO, IMPORTE_PAGO_ARANCEL, TIPO_PAGO_ARANCEL, FECHA_PAGO_ARANCEL) VALUES
(2, 1, 1, 150.00, 'Mensual', '2024-05-20'),
(3, 2, 2, 180.00, 'Bimestral', '2024-05-21');

INSERT INTO AREA (COD_AREA, UBICACION, CAPACIDAD, MANTENIMIENTO, ACTIVIDADES) VALUES
(1, 'Piscina', 50, 'Diario', 'Natación'),
(2, 'Campo de Fútbol', 100, 'Semanal', 'Fútbol'),
(3, 'Cancha de Tenis', 30, 'Mensual', 'Tenis');

INSERT INTO TURNO (COD_TURNO, DIAS, HORARIO) VALUES
(1, 'Lunes, Miércoles, Viernes', '10:00 - 12:00'),
(2, 'Martes, Jueves', '14:00 - 16:00'),
(3, 'Sábado', '09:00 - 11:00');

INSERT INTO CRONOGRAMA (COD_CRONOGRAMA, PERIODO, LEGAJO, COD_ACTIVIDAD, COD_AREA, COD_TURNO) VALUES
(1, '2024-05-01 a 2024-05-31', 1, 1, 1, 1),
(2, '2024-05-01 a 2024-05-31', 2, 2, 2, 2),
(3, '2024-05-01 a 2024-05-31', 3, 3, 3, 3);

INSERT INTO SE_INSCRIBE (NRO_SOCIO, COD_CRONOGRAMA, FECHA_INSCRIPCION) VALUES
(1, 1, '2024-04-25'),
(2, 2, '2024-04-26'),
(3, 3, '2024-04-27');
