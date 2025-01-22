<?php
// register.php
include 'db.php';  // Koneksi ke database

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Ambil data yang dikirim melalui POST
$username = $_POST['username'];
$password = $_POST['password'];
$email = $_POST['email'];
$phone = $_POST['phone'];

// Periksa apakah username sudah ada
$query = "SELECT * FROM users WHERE username = '$username'";
$result = mysqli_query($conn, $query);

if (mysqli_num_rows($result) > 0) {
    // Username sudah ada
    echo json_encode([
        'status' => 'error',
        'message' => 'Username sudah terdaftar'
    ]);
} else {
    // Insert data ke database
    $passwordHash = password_hash($password, PASSWORD_DEFAULT);
    $insertQuery = "INSERT INTO users (username, password, email, phone) 
                    VALUES ('$username', '$passwordHash', '$email', '$phone')";
    $insertResult = mysqli_query($conn, $insertQuery);

    if ($insertResult) {
        echo json_encode([
            'status' => 'success',
            'message' => 'Akun berhasil dibuat'
        ]);
    } else {
        echo json_encode([
            'status' => 'error',
            'message' => 'Gagal membuat akun'
        ]);
    }
}
?>
