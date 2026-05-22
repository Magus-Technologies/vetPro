-- 003_aplica_igv.sql
-- Agrega flag aplica_igv (1=gravado, 0=exonerado/inafecto) a `ventas`.
-- Cuando aplica_igv=0, el comprobante se emite sin desglose de IGV (todo va como inafecto).

ALTER TABLE `ventas`
  ADD COLUMN `aplica_igv` TINYINT(1) NOT NULL DEFAULT 1 AFTER `igv`;
