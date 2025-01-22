<?php
// login.php
include 'db.php';  // Koneksi ke database

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Ambil data yang dikirim melalui POST
$username = $_POST['username'];
$password = $_POST['password'];  // Password yang dikirim dari aplikasi

// Periksa apakah username ada dalam database
$query = "SELECT * FROM users WHERE username = '$username'";
$result = mysqli_query($conn, $query);

if (mysqli_num_rows($result) > 0) {
    $user = mysqli_fetch_assoc($result);
    // Cek apakah password sesuai dengan password yang di-hash
    if (password_verify($password, $user['password'])) {
        // Password valid
        echo json_encode([
            'status' => 'success',
            'username' => $user['username'],  // Kirim username ke aplikasi
        ]);
    } else {
        // Password tidak cocok
        echo json_encode([
            'status' => 'error',
            'message' => 'Password salah'
        ]);
    }
} else {
    // Username tidak ditemukan
    echo json_encode([
        'status' => 'error',
        'message' => 'Username tidak ditemukan'
    ]);
}
?>
