-- 004_venta_items_tipo.sql
-- Amplía la columna `venta_items.tipo` para aceptar los nuevos tipos del sistema.
-- Antes: ENUM('producto','servicio')
-- Después: ENUM('producto','servicio','petshop','grooming','farmacia')
--
-- Causa: el form de Facturación envía `tipo='petshop'` (y otros) pero el ENUM
-- original solo aceptaba 2 valores → MariaDB devolvía "Data truncated" y
-- al insertar el segundo item la venta quedaba con total inconsistente
-- (venta guardada pero items huérfanos).
--
-- MODIFY COLUMN es idempotente: si ya tiene esos valores, no hace nada efectivo.

ALTER TABLE `venta_items`
  MODIFY COLUMN `tipo` ENUM('producto','servicio','petshop','grooming','farmacia') NOT NULL;
