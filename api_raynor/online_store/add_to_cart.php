<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

include('db.php'); // Koneksi ke database

// Mendapatkan data dari permintaan POST
$username = $_POST['username'];
$name = $_POST['name'];
$price = $_POST['price'];
$image_url = $_POST['image_url'];
$description = $_POST['description'];
$quantity = $_POST['quantity'];

// Menyiapkan query untuk menambahkan produk ke keranjang, termasuk unit_price
$query = "INSERT INTO cart (username, name, price, image_url, description, quantity, unit_price) 
          VALUES ('$username', '$name', '$price', '$image_url', '$description', '$quantity', '$price')";

// Menjalankan query
if (mysqli_query($conn, $query)) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to add product to cart']);
}

// Menutup koneksi
mysqli_close($conn);
?>
