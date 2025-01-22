import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'order_details_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CartPage(username: 'test_user'), // Ganti dengan username dinamis Anda
    );
  }
}

class CartPage extends StatefulWidget {
  final String username;

  CartPage({required this.username});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> cartItems = [];
  bool isLoading = false;
  Timer? _timer;

  Future<void> _fetchCartItems() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://teknologi22.xyz/project_api/api_raynor/online_store/get_cart.php?username=${widget.username}'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);

        if (decodedData.containsKey('data')) {
          final List<dynamic> data = decodedData['data'];
          setState(() {
            cartItems =
                data.map((cartJson) => CartItem.fromJson(cartJson)).toList();
          });
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        throw Exception('Failed to load cart items');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal memuat keranjang')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _increaseQuantity(int itemId) async {
    try {
      final item = cartItems.firstWhere((item) => item.id == itemId);
      final newQuantity = item.quantity + 1;

      final response = await http.post(
        Uri.parse(
            'https://teknologi22.xyz/project_api/api_raynor/online_store/update_quantity_and_price.php'),
        body: {
          'username': widget.username,
          'id': itemId.toString(),
          'quantity': newQuantity.toString(),
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 'success') {
          setState(() {
            item.quantity = newQuantity;
            item.price = responseData['new_price'];
          });
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal menambah jumlah barang')));
        } else {
          throw Exception(responseData['message'] ?? 'Gagal memperbarui jumlah');
        }
      } else {
        throw Exception('Failed to update quantity');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Jumlah barang berhasil ditambah')));
    }
  }

  Future<void> _decreaseQuantity(int itemId) async {
    try {
      final item = cartItems.firstWhere((item) => item.id == itemId);
      if (item.quantity > 1) {
        final newQuantity = item.quantity - 1;

        final response = await http.post(
          Uri.parse(
              'https://teknologi22.xyz/project_api/api_raynor/online_store/update_quantity_and_price.php'),
          body: {
            'username': widget.username,
            'id': itemId.toString(),
            'quantity': newQuantity.toString(),
          },
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);

          if (responseData['status'] == 'success') {
            setState(() {
              item.quantity = newQuantity;
              item.price = responseData['new_price'];
            });
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal mengurangi jumlah barang')));
          } else {
            throw Exception(responseData['message'] ?? 'Gagal memperbarui jumlah');
          }
        } else {
          throw Exception('Failed to update quantity');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Jumlah barang tidak bisa kurang dari 1')));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Jumlah barang berhasil dikurangi')));
    }
  }

  Future<void> _deleteSelectedItems() async {
    try {
      // Mendapatkan item yang dipilih
      final selectedItems = cartItems.where((item) => item.isSelected).toList();

      if (selectedItems.isNotEmpty) {
        for (var item in selectedItems) {
          final response = await http.post(
            Uri.parse(
                'https://teknologi22.xyz/project_api/api_raynor/online_store/delete_cart_item.php'),
            body: {
              'username': widget.username,
              'id': item.id.toString(),
            },
          );

          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body);

            if (responseData['status'] == 'success') {
              setState(() {
                // Menghapus item dari list jika penghapusan berhasil
                cartItems.removeWhere((cartItem) => cartItem.id == item.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Item berhasil dihapus')));
            } else {
              throw Exception(responseData['message'] ?? 'Gagal menghapus item');
            }
          } else {
            throw Exception('Failed to delete item');
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tidak ada item yang dipilih')));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus item')));
    }
  }

  Future<void> _placeOrderForSelectedItems() async {
    final selectedItems = cartItems.where((item) => item.isSelected).toList();
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak ada barang yang dipilih untuk dipesan')),
      );
      return;
    }

    try {
      // Navigasi ke halaman OrderDetailsPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderDetailsPage(selectedItems: selectedItems),
        ),
      );
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal membuat pesanan')));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
    // Mulai timer untuk polling setiap 5 detik
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _fetchCartItems();
    });
  }

  @override
  void dispose() {
    // Hentikan timer saat widget di-dispose
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang Belanja'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteSelectedItems,
          ),
        ],
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
          ? Container(
        color: Colors.teal.shade200, // Sama seperti background saat ada produk
        child: Center(
          child: Text(
            'Keranjang kosong',
            style: TextStyle(fontSize: 18, color: Colors.teal.shade900),
          ),
        ),
      )
          : Container(
        color: Colors.teal.shade200, // Background saat ada produk
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Image.network(
                      cartItems[index].imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(cartItems[index].name),
                    subtitle: Text(
                        'Jumlah: ${cartItems[index].quantity} | Harga: Rp ${cartItems[index].price.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            _decreaseQuantity(cartItems[index].id);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            _increaseQuantity(cartItems[index].id);
                          },
                        ),
                        Checkbox(
                          value: cartItems[index].isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              cartItems[index].isSelected = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        cartItems[index].isSelected = !cartItems[index].isSelected;
                      });
                    },
                  );
                },
              ),
            ),
            // Tambahkan Padding untuk menaikkan posisi tombol "Order now"
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0), // Sesuaikan nilai bottom sesuai kebutuhan
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.teal),
                ),
                onPressed: _placeOrderForSelectedItems,
                child: Text(
                  'Order now',
                  style: TextStyle(color: Colors.teal),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItem {
  final int id;
  final String name;
  double price;
  int quantity;
  final String imageUrl;
  bool isSelected;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    this.isSelected = false,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? 'Unknown',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      imageUrl: json['image_url'] ?? '',
    );
  }

  double totalPrice() {
    return price * quantity;
  }
}