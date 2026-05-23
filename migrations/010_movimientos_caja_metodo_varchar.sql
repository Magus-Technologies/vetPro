-- 010_movimientos_caja_metodo_varchar.sql
-- Cambia metodo_pago en movimientos_caja de ENUM a VARCHAR(50).

ALTER TABLE movimientos_caja MODIFY COLUMN metodo_pago VARCHAR(50) DEFAULT 'efectivo';