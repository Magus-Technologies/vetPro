-- 011_venta_pagos.sql
-- Permite múltiples métodos de pago en una misma venta.
-- Ejemplo: S/. 50 YAPE + S/. 50 Efectivo = S/. 100 total.

CREATE TABLE IF NOT EXISTS venta_pagos (
    id         INT PRIMARY KEY AUTO_INCREMENT,
    venta_id   INT NOT NULL,
    metodo_pago VARCHAR(50) NOT NULL,
    monto      DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE CASCADE
);

CREATE INDEX idx_venta_pagos_venta ON venta_pagos(venta_id);