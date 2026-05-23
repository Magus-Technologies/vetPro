-- 008_clientes_ce_pasaporte.sql
-- Agrega campos CE y Pasaporte a la tabla clientes para soportar extranjeros.

ALTER TABLE clientes ADD COLUMN ce VARCHAR(20) DEFAULT NULL AFTER ruc;
ALTER TABLE clientes ADD COLUMN pasaporte VARCHAR(30) DEFAULT NULL AFTER ce;

CREATE INDEX idx_clientes_ce ON clientes(ce);
CREATE INDEX idx_clientes_pasaporte ON clientes(pasaporte);