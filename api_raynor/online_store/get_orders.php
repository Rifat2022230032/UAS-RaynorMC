<?php
// Konfigurasi database
include('db.php'); // Koneksi ke database

// Set header untuk CORS
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

// Cek koneksi
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Cek apakah username tersedia di POST request
if (!isset($_POST['username']) || empty($_POST['username'])) {
    echo json_encode(array("status" => "failure", "message" => "username tidak ditemukan"));
    exit;
}

// Ambil username dari request POST
$username = $_POST['username'];

// Query untuk mengambil pesanan berdasarkan username
$sql = "SELECT id, username, name, unit_price, image_url, quantity, address, metode_pembayaran, opsi_pengiriman, total_bayar, created_at FROM orders WHERE username = ?";

// Persiapkan statement
$stmt = $conn->prepare($sql);

// Cek apakah query berhasil dipersiapkan
if ($stmt === false) {
    error_log("Failed to prepare statement: " . $conn->error);
    echo json_encode(array("status" => "failure", "message" => "Gagal mempersiapkan query"));
    exit;
}

// Bind parameter
$stmt->bind_param("s", $username);

// Menjalankan query
$stmt->execute();

// Mendapatkan hasil query
$result = $stmt->get_result();

// Menyusun data dalam array
$orders = [];
while ($row = $result->fetch_assoc()) {
    $orders[] = $row;
}

// Mengirimkan response dalam format JSON
if (!empty($orders)) {
    echo json_encode(array("status" => "success", "orders" => $orders));
} else {
    echo json_encode(array("status" => "failure", "message" => "Tidak ada pesanan ditemukan"));
}

// Menutup koneksi
$stmt->close();
$conn->close();
?>
