
-- Insertamos cuotas mensuales, algunas no pagadas
INSERT INTO CUOTA_MENSUAL (COD_CUOTA_MENSUAL, NRO_GRUPO, IMPORTE_A_PAGAR, FECHA_VENC) VALUES (1000000, 1 , 50.00, '2024-06-01');

-- Insertamos cuotas sociales (la cuota social de Laura no está pagada)
INSERT INTO CUOTA_SOCIAL (COD_CUOTA_SOCIAL, MONTO_BASE, VIGENCIA_CUOTA_SOCIAL, PORCENTAJE_MODIFICACION, NRO_SOCIO, COD_CUOTA_MENSUAL) VALUES (100000, 100.00, '2024-01-01', 10.00, 1, 1, 1000000);
UPDATE CUOTA_SOCIAL SET NRO_GRUPO = 1, NRO_SOCIO = 1 WHERE COD_CUOTA_SOCIAL = 100000;