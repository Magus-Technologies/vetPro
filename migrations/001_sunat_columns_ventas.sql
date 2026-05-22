-- =============================================================
-- 001 — Columnas SUNAT en `ventas`
-- Idempotente: usa IF NOT EXISTS.
-- =============================================================
ALTER TABLE `ventas`
    ADD COLUMN IF NOT EXISTS `sunat_estado`  ENUM('pendiente','aceptado','rechazado') NULL DEFAULT NULL,
    ADD COLUMN IF NOT EXISTS `sunat_hash`    VARCHAR(255) NULL DEFAULT NULL,
    ADD COLUMN IF NOT EXISTS `sunat_qr`      TEXT NULL,
    ADD COLUMN IF NOT EXISTS `sunat_xml`     LONGTEXT NULL,
    ADD COLUMN IF NOT EXISTS `sunat_cdr`     LONGTEXT NULL,
    ADD COLUMN IF NOT EXISTS `sunat_mensaje` VARCHAR(1000) NULL,
    ADD COLUMN IF NOT EXISTS `sunat_fecha`   DATETIME NULL;
