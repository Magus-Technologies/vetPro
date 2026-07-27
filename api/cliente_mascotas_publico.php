<?php
/**
 * VetPro — API PÚBLICA: cliente + mascotas por DNI (para reservar.php)
 * Endpoint: /api/cliente_mascotas_publico.php?dni=12345678
 *
 * Si el DNI corresponde a un cliente registrado, devuelve sus mascotas
 * para que el dueño seleccione a cuál(es) traer (evita duplicados).
 */
require_once __DIR__ . '/../includes/config.php';
header('Content-Type: application/json; charset=utf-8');
header('X-Content-Type-Options: nosniff');

$dni = preg_replace('/\D/', '', $_GET['dni'] ?? '');
if (strlen($dni) !== 8) { echo json_encode(['ok' => false, 'error' => 'DNI inválido']); exit; }

$db = getDB();

// Límite anti-abuso por IP (comparte tabla con la consulta de DNI)
try {
    $db->exec("CREATE TABLE IF NOT EXISTS dni_publico_hits (ip VARCHAR(45), ts INT, KEY idx_ip_ts (ip,ts)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
    $ip = substr($_SERVER['REMOTE_ADDR'] ?? '0.0.0.0', 0, 45); $ahora = time();
    if (mt_rand(1,20) === 1) { $db->exec("DELETE FROM dni_publico_hits WHERE ts < " . ($ahora - 7200)); }
    $st = $db->prepare("SELECT COUNT(*) FROM dni_publico_hits WHERE ip=? AND ts > ?");
    $st->execute([$ip, $ahora - 3600]);
    if ((int)$st->fetchColumn() >= 40) { http_response_code(429); echo json_encode(['ok'=>false,'error'=>'Demasiadas consultas']); exit; }
    $db->prepare("INSERT INTO dni_publico_hits (ip,ts) VALUES (?,?)")->execute([$ip, $ahora]);
} catch (Exception $e) {}

try {
    $c = $db->prepare("SELECT id,nombre FROM clientes WHERE dni=? AND activo=1 LIMIT 1");
    $c->execute([$dni]); $cli = $c->fetch(PDO::FETCH_ASSOC);
    if (!$cli) { echo json_encode(['ok' => true, 'registrado' => false]); exit; }

    $m = $db->prepare("SELECT id,nombre,especie FROM mascotas WHERE cliente_id=? AND (estado IS NULL OR estado='activo') ORDER BY nombre");
    $m->execute([(int)$cli['id']]);
    $mascotas = [];
    foreach ($m->fetchAll(PDO::FETCH_ASSOC) as $r) {
        $mascotas[] = ['id' => (int)$r['id'], 'nombre' => $r['nombre'], 'especie' => $r['especie'] ?: 'otro'];
    }
    echo json_encode(['ok' => true, 'registrado' => true, 'cliente' => ['nombre' => $cli['nombre']], 'mascotas' => $mascotas]);
} catch (Exception $e) {
    echo json_encode(['ok' => false, 'error' => 'No se pudo consultar']);
}
