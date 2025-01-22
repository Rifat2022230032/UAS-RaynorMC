<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");


include('db.php'); // Koneksi ke database

// Periksa koneksi
if ($conn->connect_error) {
    echo json_encode(['status' => 'error', 'message' => 'Database connection failed: ' . $conn->connect_error]);
    exit();
}

// Periksa apakah request menggunakan metode POST
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $username = isset($_POST['username']) ? $_POST['username'] : null;
    $nama_toko = isset($_POST['nama_toko']) ? $_POST['nama_toko'] : null;

    // Validasi input
    if (empty($username) || empty($nama_toko)) {
        echo json_encode(['status' => 'error', 'message' => 'Username dan Nama Toko wajib diisi.']);
        exit();
    }

    // Periksa apakah username ada di tabel users
    $check_user_query = "SELECT * FROM users WHERE username = ?";
    $stmt = $conn->prepare($check_user_query);
    $stmt->bind_param('s', $username);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows == 0) {
        echo json_encode(['status' => 'error', 'message' => 'Username tidak ditemukan.']);
        exit();
    }

    // Update nama_toko di tabel users
    $update_query = "UPDATE users SET nama_toko = ? WHERE username = ?";
    $stmt = $conn->prepare($update_query);
    $stmt->bind_param('ss', $nama_toko, $username);

    if ($stmt->execute()) {
        echo json_encode(['status' => 'success', 'message' => 'Toko berhasil dibuat.']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Gagal membuat toko.']);
    }

    $stmt->close();
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method.']);
}

$conn->close();
?>
