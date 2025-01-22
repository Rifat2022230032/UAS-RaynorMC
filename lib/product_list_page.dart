import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async'; // Untuk Timer
import 'add_product_page.dart';
import 'edit_product_page.dart';

class ProductListPage extends StatefulWidget {
  final String username;
  final String nama_toko;

  ProductListPage({required this.username, required this.nama_toko});

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Map<String, dynamic>> products = [];
  bool _isLoading = true;
  late Timer _timer; // Untuk timer polling

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // Ambil produk saat pertama kali dimuat
    _startPolling(); // Mulai polling untuk memperbarui data secara periodik
  }

  @override
  void dispose() {
    _timer.cancel(); // Hentikan polling saat widget dihapus
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    final response = await http.post(
      Uri.parse('https://teknologi22.xyz/project_api/api_raynor/online_store/products.php'),
      body: {
        'username': widget.username,
        'nama_toko': widget.nama_toko, // Kirim nama_toko
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['data'] != null) {
        List filteredProducts = (data['data'] as List).where((product) {
          return product['nama_toko'] == widget.nama_toko; // Pastikan nama_toko milik pengguna
        }).toList();

        setState(() {
          products = filteredProducts.map<Map<String, dynamic>>((product) {
            return {...(product as Map<String, dynamic>), 'isChecked': false};
          }).toList();
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat produk')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error server (${response.statusCode})')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk memulai polling setiap 5 detik
  void _startPolling() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _fetchProducts(); // Ambil data produk terbaru
    });
  }

  Future<void> _deleteProduct(String productId) async {
    final response = await http.post(
      Uri.parse('https://teknologi22.xyz/project_api/api_raynor/online_store/delete_product.php'),
      body: {'product_id': productId},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          products.removeWhere((product) => product['id'] == productId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produk berhasil dihapus')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Gagal menghapus produk')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error server (${response.statusCode})')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Produk Anda (${widget.nama_toko})'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : products.isEmpty
          ? Center(
        child: Text(
          'Belum ada produk yang terdaftar',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            title: Text(product['name']),
            subtitle: Text(
              'Harga: Rp${product['price']} - ${product['description'] ?? ''}',
            ),
            leading: product['image_url'] != null
                ? Image.network(
              product['image_url'],
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            )
                : Icon(Icons.image, size: 50), // Placeholder icon
            trailing: Row(
              mainAxisSize: MainAxisSize.min, // Membatasi ukuran trailing
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue), // Tombol Edit
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProductPage(
                          productId: product['id'],
                          initialData: product, // Kirim data produk
                        ),
                      ),
                    ).then((_) => _fetchProducts()); // Refresh data setelah kembali
                  },
                ),
                Checkbox(
                  value: product['isChecked'],
                  onChanged: (value) {
                    setState(() {
                      product['isChecked'] = value!;
                    });
                  },
                ),
              ],
            ),
            onTap: () {
              // Handle product detail
              print('Product ID: ${product['id']}');
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0), // Raise the buttons a little
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20), // Less space between buttons
              child: FloatingActionButton(
                onPressed: () {
                  // Hapus produk yang dipilih
                  final selectedProducts = products.where((p) => p['isChecked']).toList();
                  if (selectedProducts.isNotEmpty) {
                    for (var product in selectedProducts) {
                      _deleteProduct(product['id']);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Pilih produk untuk dihapus')),
                    );
                  }
                },
                child: Icon(Icons.delete),
                backgroundColor: Colors.red,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10), // Less space between buttons
              child: FloatingActionButton(
                onPressed: () {
                  // Navigate to AddProductPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddProductPage(
                        username: widget.username,
                        shopName: widget.nama_toko,
                      ),
                    ),
                  );
                },
                child: Icon(Icons.add),
                backgroundColor: Colors.teal.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
