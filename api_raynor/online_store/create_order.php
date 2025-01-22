<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include('db.php'); // Koneksi ke database

$data = json_decode(file_get_contents("php://input"));

if ($data === null) {
    echo json_encode(["message" => "Invalid JSON data"]);
    exit();
}

// Ambil data dari input JSON
$username = $data->username;
$name = $data->name;
$unit_price = $data->unit_price;
$image_url = $data->image_url;
$quantity = $data->quantity;
$address = $data->address;
$metode_pembayaran = $data->metode_pembayaran;
$opsi_pengiriman = $data->opsi_pengiriman;
$total_bayar = $data->total_bayar;

// Pastikan quantity tidak 0 untuk menghindari pembagian dengan nol
if ($quantity > 0) {
    $unit_price_per_item = $unit_price / $quantity;  // Menghitung harga per unit
} else {
    echo json_encode(["message" => "Quantity harus lebih besar dari 0"]);
    exit();
}

// Query untuk memasukkan data pesanan ke dalam database
$stmt = $conn->prepare("INSERT INTO orders (username, name, unit_price, image_url, quantity, address, metode_pembayaran, opsi_pengiriman, total_bayar) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
$stmt->bind_param("sssssssss", $username, $name, $unit_price_per_item, $image_url, $quantity, $address, $metode_pembayaran, $opsi_pengiriman, $total_bayar);

if ($stmt->execute()) {
    echo json_encode(["message" => "Pesanan berhasil disimpan"]);
} else {
    echo json_encode(["message" => "Error: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
