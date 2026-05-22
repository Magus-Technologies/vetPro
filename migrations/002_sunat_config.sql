-- =============================================================
-- 002 — Configuración SUNAT en tabla configuracion
-- Credenciales SOL, modo, API URL, flag de certificado .pem
-- Idempotente: usa IF NOT EXISTS por si se aplicó manualmente antes.
-- =============================================================
ALTER TABLE `configuracion`
    ADD COLUMN IF NOT EXISTS `sunat_usuario_sol`  VARCHAR(45)  NULL DEFAULT NULL,
    ADD COLUMN IF NOT EXISTS `sunat_clave_sol`    VARCHAR(45)  NULL DEFAULT NULL,
    ADD COLUMN IF NOT EXISTS `sunat_modo`         VARCHAR(20)  NULL DEFAULT 'beta',
    ADD COLUMN IF NOT EXISTS `sunat_api_url`      VARCHAR(255) NULL DEFAULT NULL,
    ADD COLUMN IF NOT EXISTS `certificado_subido` TINYINT(1)   NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS `certificado_fecha`  DATETIME     NULL DEFAULT NULL;
