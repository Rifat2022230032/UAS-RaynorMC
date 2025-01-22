import 'dart:convert';
import 'dart:async'; // Import Timer
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'cart_page.dart';
import 'profile_page.dart';
import 'product_page.dart';

class HomePage extends StatefulWidget {
  final String username;

  HomePage({required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  TextEditingController _searchController = TextEditingController();
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  late Timer _timer;

  // Function to fetch products from the API
  Future<void> _fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(
          'https://teknologi22.xyz/project_api/api_raynor/online_store/products.php'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);

        if (decodedData.containsKey('data')) {
          final List<dynamic> data = decodedData['data'];
          setState(() {
            _allProducts = data.map((productJson) {
              try {
                return Product.fromJson(productJson);
              } catch (e) {
                print('Error parsing product: $e');
                return Product(
                  id: 0,
                  name: 'Unknown',
                  price: 0.0,
                  imageUrl: '',
                  description: 'No description available',
                  storeName: 'Unknown Store',
                );
              }
            }).toList();
            _filteredProducts = _allProducts;
          });
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        throw Exception('Failed to load products, StatusCode: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load products: $e');
    }
  }

  // Function to add product to the cart
  Future<void> _addToCart(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('https://teknologi22.xyz/project_api/api_raynor/online_store/add_to_cart.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': widget.username,
          'name': product.name,
          'price': product.price.toString(),
          'image_url': product.imageUrl,
          'description': product.description,
          'quantity': '1',
        },
      );

      if (response.statusCode == 200) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produk berhasil ditambahkan ke keranjang'),
            backgroundColor: Colors.black,
          ),
        );
      } else {
        // Show failure message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan produk ke keranjang'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle error and show failure message
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat menambahkan produk ke keranjang'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to handle tab changes
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Function to filter products based on search query
  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts
            .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _fetchProducts(); // Call _fetchProducts every 10 seconds to refresh the product list
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = <Widget>[
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade200, Colors.teal.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari produk...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onChanged: _filterProducts,
              ),
            ),
            Expanded(
              child: _filteredProducts.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 products per row
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.75, // Adjust the aspect ratio as needed
                ),
                padding: EdgeInsets.all(8.0),
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];
                  return Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductPage(
                              product: product,
                              username: widget.username,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                product.imageUrl,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              product.storeName,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              NumberFormat.simpleCurrency(locale: 'id_ID').format(product.price),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      ProfilePage(username: widget.username),
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade200, Colors.teal.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CartPage(username: widget.username),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Selamat datang, ${widget.username}'), // Tambahkan username di sini
        backgroundColor: Colors.green,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.green,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Keranjang',
          ),
        ],
      ),
    );
  }
}

class Product {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;
  final String storeName;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.storeName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? 'Unknown',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? 'No description available',
      storeName: json['nama_toko'] ?? 'Unknown Store',
    );
  }
}