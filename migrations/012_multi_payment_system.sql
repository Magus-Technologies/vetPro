-- MIGRATION: 012_multi_payment_system.sql
-- Aplica a: vetPro y cualquier proyecto que necesite:
--   - Métodos de pago configurables desde BD
--   - Soporte para CE / Pasaporte en clientes
--   - Split payment (múltiples métodos por venta)
--   - VARCHAR en lugar de ENUM para método de pago
-- Requiere: MySQL 5.7+ / MariaDB 10.2+
-- Idempotente: SEGURO de correr varias veces (no falla si ya existe)

-- ═══════════════════════════════════════════════════
-- PASO 1: Tabla dedicada de métodos de pago
-- ═══════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS metodos_pago (
    id      INT PRIMARY KEY AUTO_INCREMENT,
    nombre  VARCHAR(50) NOT NULL,
    icono   VARCHAR(30) DEFAULT NULL,
    orden   INT DEFAULT 0,
    activo  TINYINT(1) DEFAULT 1
);

INSERT IGNORE INTO metodos_pago (nombre, icono, orden) VALUES
    ('Efectivo',        'EF', 1),
    ('Yape',            'YP', 2),
    ('Plin',            'PL', 3),
    ('Tarjeta debito',  'TD', 4),
    ('Tarjeta credito', 'TC', 5),
    ('Transferencia',   'TR', 6);

-- ═══════════════════════════════════════════════════
-- PASO 2: Extender clientes para extranjeros
-- (usa procedimiento para ser idempotente en MariaDB)
-- ═══════════════════════════════════════════════════
DROP PROCEDURE IF EXISTS add_column_if_not_exists;
DELIMITER //
CREATE PROCEDURE add_column_if_not_exists(
    IN tbl VARCHAR(64),
    IN col VARCHAR(64),
    IN def VARCHAR(256),
    IN after_col VARCHAR(64)
)
BEGIN
    DECLARE col_exists INT DEFAULT 0;
    SELECT COUNT(*) INTO col_exists
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = tbl
      AND COLUMN_NAME = col;

    IF col_exists = 0 THEN
        SET @sql = CONCAT('ALTER TABLE ', tbl, ' ADD COLUMN ', col, ' ', def);
        IF after_col IS NOT NULL AND after_col != '' THEN
            SET @sql = CONCAT(@sql, ' AFTER ', after_col);
        END IF;
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END//
DELIMITER ;

CALL add_column_if_not_exists('clientes', 'ce', 'VARCHAR(20) DEFAULT NULL', 'ruc');
CALL add_column_if_not_exists('clientes', 'pasaporte', 'VARCHAR(30) DEFAULT NULL', 'ce');

DROP PROCEDURE IF EXISTS add_index_if_not_exists;
DELIMITER //
CREATE PROCEDURE add_index_if_not_exists(
    IN tbl VARCHAR(64),
    IN idx_name VARCHAR(64),
    IN col VARCHAR(64)
)
BEGIN
    DECLARE idx_exists INT DEFAULT 0;
    SELECT COUNT(*) INTO idx_exists
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = tbl
      AND INDEX_NAME = idx_name;

    IF idx_exists = 0 THEN
        SET @sql = CONCAT('CREATE INDEX ', idx_name, ' ON ', tbl, '(', col, ')');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END//
DELIMITER ;

CALL add_index_if_not_exists('clientes', 'idx_clientes_ce', 'ce');
CALL add_index_if_not_exists('clientes', 'idx_clientes_pasaporte', 'pasaporte');

-- ═══════════════════════════════════════════════════
-- PASO 3: metodo_pago en ventas como VARCHAR
-- ═══════════════════════════════════════════════════
DROP PROCEDURE IF EXISTS alter_to_varchar;
DELIMITER //
CREATE PROCEDURE alter_to_varchar(IN tbl VARCHAR(64), IN col VARCHAR(64))
BEGIN
    DECLARE col_type VARCHAR(128) DEFAULT '';
    SELECT COLUMN_TYPE INTO col_type
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = tbl
      AND COLUMN_NAME = col;

    IF col_type != '' AND col_type NOT LIKE 'varchar%' THEN
        SET @sql = CONCAT('ALTER TABLE ', tbl, ' MODIFY COLUMN ', col, ' VARCHAR(50) DEFAULT ''efectivo''');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END//
DELIMITER ;

CALL alter_to_varchar('ventas', 'metodo_pago');
CALL alter_to_varchar('movimientos_caja', 'metodo_pago');

-- ═══════════════════════════════════════════════════
-- PASO 4: Tabla para múltiples métodos por venta
-- ═══════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS venta_pagos (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    venta_id    INT NOT NULL,
    metodo_pago  VARCHAR(50) NOT NULL,
    monto       DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_venta_pagos_venta ON venta_pagos(venta_id);

-- Limpieza
DROP PROCEDURE IF EXISTS add_column_if_not_exists;
DROP PROCEDURE IF EXISTS add_index_if_not_exists;
DROP PROCEDURE IF EXISTS alter_to_varchar;