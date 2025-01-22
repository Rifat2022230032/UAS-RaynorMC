<?php
include('db.php'); // Koneksi ke database

// Cek koneksi
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Mendapatkan parameter dari request
$input = json_decode(file_get_contents("php://input"), true);
$user = isset($input['username']) ? $input['username'] : '';
$shopName = isset($input['nama_toko']) ? $input['nama_toko'] : ''; // Ganti dari shop_name menjadi nama_toko

// Cek apakah parameter tersedia
if (empty($user) || empty($shopName)) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Username dan nama toko harus diisi.'
    ]);
    exit();
}

// Query untuk mendapatkan produk berdasarkan username dan nama_toko
$sql = "SELECT * FROM products WHERE username = ? AND nama_toko = ?"; // Ganti dari shop_name menjadi nama_toko
$stmt = $conn->prepare($sql);
$stmt->bind_param("ss", $user, $shopName);
$stmt->execute();
$result = $stmt->get_result();

// Cek apakah produk ditemukan
if ($result->num_rows > 0) {
    $products = [];
    while ($row = $result->fetch_assoc()) {
        $products[] = [
            'id' => $row['id'],
            'name' => $row['name'],
            'price' => $row['price'],
            'description' => $row['description'],
            'image_url' => $row['image_url'],
        ];
    }
    echo json_encode([
        'status' => 'success',
        'products' => $products
    ]);
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'Tidak ada produk ditemukan.'
    ]);
}

// Menutup koneksi
$conn->close();
?>
