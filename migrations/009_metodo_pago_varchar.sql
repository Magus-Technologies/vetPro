-- 009_metodo_pago_varchar.sql
-- Cambia metodo_pago de ENUM a VARCHAR(50) para aceptar métodos dinámicos.

ALTER TABLE ventas MODIFY COLUMN metodo_pago VARCHAR(50) DEFAULT 'efectivo';