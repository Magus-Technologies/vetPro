-- 005_cliente_varios.sql
-- Crea (si no existe) un cliente "CLIENTES VARIOS" que se usa cuando se emite
-- boleta/nota sin un cliente identificado. Permite venta directa al mostrador.
--
-- Convención SUNAT: para boleta sin cliente identificado se usa
-- tipo_doc=0, num_doc=00000000, rzn_social='CLIENTES VARIOS'.
--
-- El cliente se identifica por su `nombre`. El INSERT condicional evita duplicados.

INSERT INTO `clientes` (nombre, dni, ruc, direccion, telefono, email, activo)
SELECT 'CLIENTES VARIOS', NULL, NULL, '-', '-', NULL, 1
FROM dual
WHERE NOT EXISTS (
    SELECT 1 FROM `clientes` WHERE nombre = 'CLIENTES VARIOS'
);
