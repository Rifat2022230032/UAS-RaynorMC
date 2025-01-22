import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddProductPage extends StatefulWidget {
  final String username; // Pass the username from ProfilePage
  final String shopName; // Pass the shop name from ProfilePage

  AddProductPage({required this.username, required this.shopName});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController imageUrlController = TextEditingController();

  bool _isLoading = false;

  Future<void> _addProduct() async {
    String shopName = widget.shopName; // Use the passed shop name directly
    String name = nameController.text.trim();
    String price = priceController.text.trim();
    String description = descriptionController.text.trim();
    String imageUrl = imageUrlController.text.trim();

    // Validasi input
    if (shopName.isEmpty || name.isEmpty || price.isEmpty || description.isEmpty || imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Kirim request ke API
      final response = await http.post(
        Uri.parse(
            'https://teknologi22.xyz/project_api/api_raynor/online_store/add_product.php'),
        body: {
          'username': widget.username,
          'nama_toko': shopName,
          'name': name,
          'price': price,
          'description': description,
          'image_url': imageUrl,
        },
      ).timeout(Duration(seconds: 10)); // Tambahkan timeout

      // Cetak respons API untuk debugging
      print('API Response: ${response.body}');

      // Proses respons API
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Tampilkan SnackBar sukses
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Product added successfully')));

          // Tunggu 2 detik sebelum kembali ke halaman sebelumnya
          await Future.delayed(Duration(seconds: 2));

          // Kembali ke halaman sebelumnya
          Navigator.pop(context);
        } else {
          // Tampilkan pesan error dari API
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'] ?? 'Failed to add product')));
        }
      } else {
        // Tampilkan pesan error jika status code bukan 200
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Server error (${response.statusCode})')));
      }
    } catch (e) {
      // Tangani error jika terjadi exception
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')));
    } finally {
      // Set loading ke false setelah proses selesai
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
        backgroundColor: Colors.teal.shade700,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
      ),
      backgroundColor: Colors.teal.shade200, // Set background color to teal.shade200
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input field untuk nama produk
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
              SizedBox(height: 16),
              // Input field untuk harga produk
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 16),
              // Input field untuk deskripsi produk
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 4,
              ),
              SizedBox(height: 16),
              // Input field untuk URL gambar produk
              TextField(
                controller: imageUrlController,
                decoration: InputDecoration(labelText: 'Image URL'),
              ),
              SizedBox(height: 20),
              // Tombol untuk menambahkan produk
              _isLoading
                  ? Center(child: CircularProgressIndicator()) // Loading indicator
                  : ElevatedButton(
                onPressed: _addProduct,
                child: Text('Add Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}