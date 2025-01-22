<?php
// Mengatur header agar respons JSON
header('Content-Type: application/json');

// Menyertakan file koneksi ke database
include 'db.php'; // Pastikan file koneksi database ada

// Mengambil data POST
$product_id = isset($_POST['product_id']) ? $_POST['product_id'] : null;

// Cek apakah product_id ada
if ($product_id) {
    // Query untuk menghapus produk berdasarkan ID
    $query = "DELETE FROM products WHERE id = ?";
    
    // Persiapkan query
    if ($stmt = $conn->prepare($query)) {
        // Binding parameter
        $stmt->bind_param("i", $product_id);

        // Eksekusi query
        if ($stmt->execute()) {
            // Jika berhasil, kirim respons sukses
            echo json_encode(['status' => 'success', 'message' => 'Produk berhasil dihapus']);
        } else {
            // Jika gagal, kirim respons gagal
            echo json_encode(['status' => 'error', 'message' => 'Gagal menghapus produk']);
        }

        // Menutup statement
        $stmt->close();
    } else {
        // Jika query tidak berhasil dipersiapkan
        echo json_encode(['status' => 'error', 'message' => 'Query tidak valid']);
    }

    // Menutup koneksi
    $conn->close();
} else {
    // Jika product_id tidak diberikan
    echo json_encode(['status' => 'error', 'message' => 'Product ID tidak ditemukan']);
}
?>
