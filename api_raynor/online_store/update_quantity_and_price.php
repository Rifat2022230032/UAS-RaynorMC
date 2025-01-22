<?php
include('db.php'); // Koneksi ke database

// Mendapatkan data dari permintaan POST
$username = $_POST['username'] ?? null;
$id = $_POST['id'] ?? null;
$quantity = $_POST['quantity'] ?? null;

// Validasi input
if (empty($username) || empty($id) || empty($quantity)) {
    echo json_encode(['status' => 'error', 'message' => 'Username, ID, atau quantity tidak valid']);
    exit;
}

if (!is_numeric($quantity) || $quantity <= 0) {
    echo json_encode(['status' => 'error', 'message' => 'Quantity harus berupa angka positif']);
    exit;
}

// Query untuk mendapatkan harga satuan
$query = $conn->prepare("SELECT unit_price FROM cart WHERE username = ? AND id = ?");
$query->bind_param("si", $username, $id);
$query->execute();
$result = $query->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $unit_price = $row['unit_price'];

    // Menghitung harga total baru
    $total_price = $unit_price * $quantity;

    // Query untuk memperbarui quantity dan harga total
    $update_query = $conn->prepare("UPDATE cart SET quantity = ?, price = ? WHERE username = ? AND id = ?");
    $update_query->bind_param("ddsi", $quantity, $total_price, $username, $id);

    if ($update_query->execute()) {
        echo json_encode([
            'status' => 'success',
            'message' => 'Quantity dan harga berhasil diperbarui',
            'new_price' => $total_price
        ]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Gagal memperbarui quantity dan harga']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Data barang tidak ditemukan']);
}

// Menutup koneksi
$conn->close();
?>