import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import untuk format harga
import 'package:http/http.dart' as http; // Import untuk request HTTP
import 'dart:convert';
import 'home_page.dart'; // Import model Product

class ProductPage extends StatelessWidget {
  final Product product;
  final String username; // Menambahkan parameter username

  ProductPage({required this.product, required this.username});

  // Fungsi untuk menambahkan barang ke tabel cart di database
  Future<void> _addToCart(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://teknologi22.xyz/project_api/api_raynor/online_store/add_to_cart.php'),
        body: {
          'username': username, // Mengirimkan username
          'name': product.name, // Nama produk
          'price': product.price.toString(), // Harga produk
          'image_url': product.imageUrl, // URL gambar produk
          'description': product.description, // Deskripsi produk
          'quantity': '1', // Default quantity 1
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} Gagal menambahkan ke keranjang'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('berhasil ditambahkan ke keranjang'),
            ),
          );
        }
      } else {
        throw Exception('Failed to add to cart');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade400, Colors.teal.shade700],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: AppBar(
            title: Text(product.name),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade400, Colors.teal.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with border-radius and shadow (taller image)
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.network(
                  product.imageUrl,
                  width: double.infinity,
                  height: 500, // Increase the height for a larger image
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16),

              // Product name with improved styling
              Text(
                product.name,
                style: TextStyle(
                  fontSize: 28, // Increase font size for product name
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.6),
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),

              // Price with more emphasis
              Text(
                NumberFormat.simpleCurrency(locale: 'id_ID').format(product.price),
                style: TextStyle(
                  fontSize: 24, // Increase font size for price
                  fontWeight: FontWeight.w600,
                  color: Colors.greenAccent,
                  shadows: [
                    Shadow(
                      blurRadius: 5.0,
                      color: Colors.black.withOpacity(0.3),
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8), // Add a small space between price and store name

              // Store name below the price
              Text(
                'Toko: ${product.storeName}', // Display store name
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16), // Space for description

              // Product description in a card with slight shadow
              Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
              SizedBox(height: 16), // Space before the button

              // Full width button with gradient, use Expanded to push it to the bottom
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _addToCart(context); // Menambahkan produk ke keranjang
                    },
                    icon: Icon(Icons.add_shopping_cart),
                    label: Text("Tambah ke Keranjang"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      minimumSize: Size(double.infinity, 50), // Tombol penuh lebar
                      backgroundColor: Colors.teal, // Button color
                      foregroundColor: Colors.white, // Text color (previously onPrimary)
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
