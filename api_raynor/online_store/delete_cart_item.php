<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include('db.php'); // Pastikan file ini ada dan berisi koneksi database

// Fungsi untuk menghapus item dari keranjang
function deleteCartItem($username, $id) {
    global $conn;

    try {
        // Menyiapkan query untuk menghapus item dalam keranjang berdasarkan username dan ID item
        $stmt = $conn->prepare("DELETE FROM cart WHERE username = ? AND id = ?");
        $stmt->bind_param("si", $username, $id);
        $stmt->execute();

        if ($stmt->affected_rows > 0) {
            return ['status' => 'success', 'message' => 'Item berhasil dihapus'];
        } else {
            return ['status' => 'error', 'message' => 'Item tidak ditemukan'];
        }
    } catch (Exception $e) {
        return ['status' => 'error', 'message' => 'Error: ' . $e->getMessage()];
    }
}

// Mendapatkan data dari permintaan
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Cek apakah data dikirim sebagai JSON (php://input) atau form-data ($_POST)
    $inputData = json_decode(file_get_contents("php://input"), true);

    if ($inputData) {
        // Jika data dikirim sebagai JSON
        $username = $inputData['username'] ?? null;
        $id = $inputData['id'] ?? null;
    } else {
        // Jika data dikirim sebagai form-data
        $username = $_POST['username'] ?? null;
        $id = $_POST['id'] ?? null;
    }

    // Validasi data
    if (empty($username) || empty($id)) {
        echo json_encode(['status' => 'error', 'message' => 'Username atau ID tidak valid']);
        exit;
    }

    // Menghapus item dari keranjang
    $result = deleteCartItem($username, $id);
    echo json_encode($result);
} else {
    // Jika metode request bukan POST
    echo json_encode(['status' => 'error', 'message' => 'Metode request tidak valid']);
}
?>