-- 003_aplica_igv.sql
-- Agrega flag aplica_igv (1=gravado, 0=exonerado/inafecto) a `ventas`.
-- Cuando aplica_igv=0, el comprobante se emite sin desglose de IGV.
-- Idempotente: usa IF NOT EXISTS.

ALTER TABLE `ventas`
  ADD COLUMN IF NOT EXISTS `aplica_igv` TINYINT(1) NOT NULL DEFAULT 1;
