-- 006_metodos_pago.sql
-- Agrega métodos de pago configurables en la tabla `configuracion`.
-- El form de facturación los lee desde la BD y permite agregar nuevos.
-- Formato: clave=metodo_pago_N, valor=NOMBRE (ej: metodo_pago_1=Efectivo)
-- Si no existe ningún método, usa los hardcodeados como fallback.

INSERT INTO `configuracion` (clave, valor) VALUES
('metodo_pago_1', 'Efectivo'),
('metodo_pago_2', 'Yape'),
('metodo_pago_3', 'Plin'),
('metodo_pago_4', 'Tarjeta débito'),
('metodo_pago_5', 'Tarjeta crédito'),
('metodo_pago_6', 'Transferencia')
ON DUPLICATE KEY UPDATE valor=VALUES(valor);