<?php
include('db.php'); // Koneksi ke database

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');


// Mendapatkan username dari parameter GET
$username = $_GET['username'];

// Query untuk mendapatkan data keranjang berdasarkan username
$query = "SELECT * FROM cart WHERE username = '$username'";

// Menjalankan query
$result = mysqli_query($conn, $query);

if (mysqli_num_rows($result) > 0) {
    $cartItems = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $cartItems[] = $row;
    }
    echo json_encode(['data' => $cartItems]);
} else {
    echo json_encode(['data' => []]);
}

// Menutup koneksi
mysqli_close($conn);
?>
