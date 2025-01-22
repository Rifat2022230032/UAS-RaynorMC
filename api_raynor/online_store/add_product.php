<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

include('db.php'); // Koneksi ke database

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get input data from POST request
$nama_toko = $_POST['nama_toko'];
$name = $_POST['name'];
$price = $_POST['price'];
$description = $_POST['description'];
$image_url = $_POST['image_url'];

// Prepare SQL query to insert product
$sql = "INSERT INTO products (name, price, nama_toko, image_url, description) VALUES ('$name', '$price', '$nama_toko', '$image_url', '$description')";

if ($conn->query($sql) === TRUE) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Error: ' . $conn->error]);
}

$conn->close();
?>
