-- 007_metodos_pago.sql
-- Tabla dedicada para métodos de pago (reemplaza el uso de `configuracion`).
-- migrate: inserta los 6 métodos default si la tabla está vacía.

CREATE TABLE IF NOT EXISTS metodos_pago (
    id      INT PRIMARY KEY AUTO_INCREMENT,
    nombre  VARCHAR(50) NOT NULL,
    icono   VARCHAR(30) DEFAULT NULL,
    orden   INT DEFAULT 0,
    activo  TINYINT(1) DEFAULT 1
);

INSERT INTO metodos_pago (nombre, icono, orden) VALUES
    ('Efectivo',        '💵', 1),
    ('Yape',            '📱', 2),
    ('Plin',            '📱', 3),
    ('Tarjeta débito',  '💳', 4),
    ('Tarjeta crédito', '💳', 5),
    ('Transferencia',   '🏦', 6)
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);

-- Limpiar el approach anterior (configuracion con metodo_pago_N)
DELETE FROM configuracion WHERE clave LIKE 'metodo_pago_%';
