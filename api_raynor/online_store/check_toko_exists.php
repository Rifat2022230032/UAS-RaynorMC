<?php
// check_toko_exists.php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");


include 'db.php'; // Include your database connection

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Ambil nama toko dari request
    $nama_toko = trim(strtolower($_POST['nama_toko'])); // Normalisasi nama toko (mengabaikan huruf besar/kecil dan spasi)

    // Query untuk mengecek apakah nama toko sudah ada
    $query = "SELECT * FROM users WHERE LOWER(nama_toko) = ?";  // Menggunakan LOWER untuk perbandingan yang case-insensitive
    $stmt = $conn->prepare($query);
    $stmt->bind_param("s", $nama_toko);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        // Jika nama toko sudah ada
        echo json_encode(['status' => 'exists']);
    } else {
        // Jika nama toko belum ada
        echo json_encode(['status' => 'available']);
    }

    $stmt->close();
    $conn->close();
}
?>
