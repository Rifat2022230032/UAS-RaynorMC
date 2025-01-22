<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
header("Access-Control-Allow-Methods: POST, OPTIONS"); // Izinkan metode POST dan OPTIONS
header("Access-Control-Allow-Headers: Content-Type"); // Izinkan header Content-Type

// Tangani preflight request untuk CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Include file koneksi database
include('db.php'); // Pastikan file ini ada dan berisi koneksi database

// Ambil data dari body permintaan
$data = json_decode(file_get_contents("php://input"), true);

// Validasi data yang diterima
if (empty($data) || !isset($data['ids'])) {
    echo json_encode(['status' => 'error', 'message' => 'Data tidak valid']);
    exit;
}

$ids = $data['ids'];

if (!empty($ids)) {
    try {
        // Buat placeholder untuk query SQL
        $placeholders = implode(',', array_fill(0, count($ids), '?'));
        $types = str_repeat('i', count($ids)); // 'i' untuk tipe data integer

        // Persiapkan query SQL
        $query = "DELETE FROM orders WHERE id IN ($placeholders)";
        $stmt = $conn->prepare($query);

        if ($stmt === false) {
            throw new Exception("Prepare failed: " . $conn->error);
        }

        // Bind parameter ke query
        $stmt->bind_param($types, ...$ids);

        // Eksekusi query
        $stmt->execute();

        if ($stmt->affected_rows > 0) {
            echo json_encode(['status' => 'success', 'message' => 'Pesanan berhasil dihapus']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Tidak ada pesanan yang dihapus']);
        }

        // Tutup statement
        $stmt->close();
    } catch (Exception $e) {
        echo json_encode(['status' => 'error', 'message' => 'Error saat menghapus pesanan: ' . $e->getMessage()]);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Tidak ada pesanan yang dipilih']);
}

// Tutup koneksi database
$conn->close();
?>