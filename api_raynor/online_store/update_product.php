<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

include 'db.php';  // Koneksi ke database

// Periksa koneksi
if ($conn->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Koneksi database gagal: ' . $conn->connect_error]));
}

// Periksa apakah data yang diperlukan tersedia
if (!isset($_POST['product_id']) || !isset($_POST['name']) || !isset($_POST['price']) || !isset($_POST['description']) || !isset($_POST['image_url'])) {
    echo json_encode(['status' => 'error', 'message' => 'Data tidak lengkap']);
    exit;
}

// Ambil data dari request
$product_id = $conn->real_escape_string($_POST['product_id']);
$name = $conn->real_escape_string($_POST['name']);
$price = $conn->real_escape_string($_POST['price']);
$description = $conn->real_escape_string($_POST['description']);
$image_url = $conn->real_escape_string($_POST['image_url']);

// Query untuk memperbarui data produk
$sql = "UPDATE products SET 
            name = '$name',
            price = '$price',
            description = '$description',
            image_url = '$image_url'
        WHERE id = '$product_id'";

// Eksekusi query
if ($conn->query($sql) === TRUE) {
    echo json_encode(['status' => 'success', 'message' => 'Produk berhasil diperbarui']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Gagal memperbarui produk: ' . $conn->error]);
}

// Tutup koneksi
$conn->close();
?>
