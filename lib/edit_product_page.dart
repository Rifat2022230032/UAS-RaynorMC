import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditProductPage extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> initialData;

  EditProductPage({required this.productId, required this.initialData});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;
  late TextEditingController imageUrlController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialData['name']);
    priceController = TextEditingController(text: widget.initialData['price']);
    descriptionController = TextEditingController(text: widget.initialData['description']);
    imageUrlController = TextEditingController(text: widget.initialData['image_url']);
  }

  Future<void> _updateProduct() async {
    String name = nameController.text.trim();
    String price = priceController.text.trim();
    String description = descriptionController.text.trim();
    String imageUrl = imageUrlController.text.trim();

    if (name.isEmpty || price.isEmpty || description.isEmpty || imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mohon isi semua bidang')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('https://teknologi22.xyz/project_api/api_raynor/online_store/update_product.php'),
      body: {
        'product_id': widget.productId,
        'name': name,
        'price': price,
        'description': description,
        'image_url': imageUrl,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produk berhasil diperbarui')),
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Gagal memperbarui produk')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error server (${response.statusCode})')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Produk'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nama Produk'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Deskripsi'),
                maxLines: 4,
              ),
              SizedBox(height: 16),
              TextField(
                controller: imageUrlController,
                decoration: InputDecoration(labelText: 'URL Gambar'),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _updateProduct,
                child: Text('Perbarui Produk'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
