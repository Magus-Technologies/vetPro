-- MIGRATION: 013_notas_credito.sql
-- Notas de Crédito y Débito electrónicas (SUNAT — catálogo 09).
--
-- Contexto: la tabla `notas_credito` ya existía en el dump con la columna
-- `pago_id`, pero ningún código la usaba y la nota siempre afecta a un
-- comprobante (`ventas`), no a un pago. Esta migración normaliza la columna
-- a `venta_id` cuando encuentra el esquema viejo, y crea la tabla desde cero
-- cuando no existe.
--
-- La sede no se guarda aquí: se deriva de `ventas.sede_id` del comprobante
-- afectado, que es la única fuente de verdad.
--
-- Idempotente: SEGURO de correr varias veces.

CREATE TABLE IF NOT EXISTS notas_credito (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  venta_id      INT NOT NULL,
  tipo_nota     ENUM('credito','debito') NOT NULL DEFAULT 'credito',
  serie         VARCHAR(10) NOT NULL,
  numero        INT UNSIGNED NOT NULL DEFAULT 1,
  cod_motivo    VARCHAR(5) NOT NULL,
  des_motivo    VARCHAR(250) NOT NULL,
  total         DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  aplica_igv    TINYINT(1) NOT NULL DEFAULT 1,
  sunat_xml     MEDIUMTEXT NULL,
  sunat_hash    VARCHAR(100) NULL,
  sunat_qr      TEXT NULL,
  sunat_cdr     TEXT NULL,
  sunat_estado  ENUM('pendiente','aceptado','rechazado') NOT NULL DEFAULT 'pendiente',
  sunat_mensaje VARCHAR(1000) NULL,
  sunat_fecha   DATETIME NULL,
  estado        ENUM('activa','anulada') NOT NULL DEFAULT 'activa',
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_venta_id (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Esquema viejo: pago_id -> venta_id (solo si la columna vieja sigue ahí).
SET @tiene_pago_id := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'notas_credito'
      AND COLUMN_NAME  = 'pago_id'
);
SET @sql := IF(@tiene_pago_id > 0,
    'ALTER TABLE notas_credito CHANGE pago_id venta_id INT NOT NULL',
    'DO 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- El índice viejo apuntaba a pago_id.
SET @tiene_idx_pago := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'notas_credito'
      AND INDEX_NAME   = 'idx_pago_id'
);
SET @sql := IF(@tiene_idx_pago > 0,
    'ALTER TABLE notas_credito DROP INDEX idx_pago_id',
    'DO 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @tiene_idx_venta := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'notas_credito'
      AND INDEX_NAME   = 'idx_venta_id'
);
SET @sql := IF(@tiene_idx_venta = 0,
    'CREATE INDEX idx_venta_id ON notas_credito(venta_id)',
    'DO 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- La serie viaja con prefijo de sede (NC001, ND002...): 4 chars no alcanzan.
SET @serie_len := (
    SELECT COALESCE(CHARACTER_MAXIMUM_LENGTH, 0) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'notas_credito'
      AND COLUMN_NAME  = 'serie'
);
SET @sql := IF(@serie_len < 10,
    'ALTER TABLE notas_credito MODIFY COLUMN serie VARCHAR(10) NOT NULL',
    'DO 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Series por defecto de la sede principal, si no están configuradas.
INSERT IGNORE INTO configuracion_sede (sede_id, clave, valor) VALUES
    (1, 'serie_nota_credito', 'NC001'),
    (1, 'serie_nota_debito',  'ND001');
