<?php
// db.php - Database connection
include 'db.php';  

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Retrieve the username (sent from the client side)
$username = $_POST['username'];

// Query to fetch user data from the database
$query = "SELECT username, email, phone, nama_toko FROM users WHERE username = '$username'";
$result = mysqli_query($conn, $query);

if (mysqli_num_rows($result) > 0) {
    $user = mysqli_fetch_assoc($result);

    // Return profile data as JSON
    echo json_encode([
        'status' => 'success',
        'username' => $user['username'],
        'email' => $user['email'],
        'phone' => $user['phone'],
        'nama_toko' => $user['nama_toko'], // Add the store name here
    ]);
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'User not found'
    ]);
}
?>
