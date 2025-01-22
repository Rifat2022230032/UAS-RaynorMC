<?php
include 'db.php';

// Tambahkan header CORS untuk mengizinkan akses dari semua asal
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

$query = "SELECT * FROM products";
$result = mysqli_query($conn, $query);
$products = [];

while ($row = mysqli_fetch_assoc($result)) {
    $products[] = $row;
}

echo json_encode(['data' => $products]);
?>
