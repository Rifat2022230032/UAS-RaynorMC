import 'package:flutter/material.dart';
import 'cart_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OrderDetailsPage extends StatefulWidget {
  final List<CartItem> selectedItems;

  OrderDetailsPage({required this.selectedItems});

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final TextEditingController _addressController = TextEditingController();
  String? _selectedPaymentMethod;
  String? _selectedShippingOption;

  final List<String> _paymentMethods = ['Transfer Bank', 'Kartu Kredit', 'COD'];
  final List<String> _shippingOptions = ['Reguler', 'Ekspres', 'Same Day'];

  double getShippingCost() {
    switch (_selectedShippingOption) {
      case 'Reguler':
        return 10000;
      case 'Ekspres':
        return 20000;
      case 'Same Day':
        return 50000;
      default:
        return 0;
    }
  }

  void _submitOrder() async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Alamat belum diisi')));
      return;
    }

    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Metode pembayaran belum dipilih')));
      return;
    }

    if (_selectedShippingOption == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Opsi pengiriman belum dipilih')));
      return;
    }

    // Menghitung total bayar tanpa mengalikan dengan quantity
    double totalPrice = widget.selectedItems.fold(0, (sum, item) => sum + item.price);
    double shippingCost = getShippingCost();
    double totalAmount = totalPrice + shippingCost;

    // Mengambil username dari SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? 'Guest'; // Default 'Guest' jika tidak ditemukan

    // Mengirim data pesanan ke server
    try {
      final response = await http.post(
        Uri.parse('https://teknologi22.xyz/project_api/api_raynor/online_store/create_order.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,  // Menggunakan username yang diambil
          'name': widget.selectedItems.map((item) => item.name).join(', '),
          'unit_price': widget.selectedItems.map((item) => item.price).join(', '),
          'image_url': widget.selectedItems.map((item) => item.imageUrl).join(', '),
          'quantity': widget.selectedItems.map((item) => item.quantity).join(', '),
          'address': _addressController.text,
          'metode_pembayaran': _selectedPaymentMethod,
          'opsi_pengiriman': _selectedShippingOption,
          'total_bayar': totalAmount.toStringAsFixed(0),  // Mengirimkan total dalam bentuk string
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = jsonDecode(response.body);
      if (responseData['message'] == 'Pesanan berhasil disimpan') {
        // Hapus item yang dipesan dari keranjang
        await _deleteCartItemsAfterOrder(username);

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pesanan berhasil dibuat! Terima kasih.')));
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      } else {
        throw Exception('Gagal memproses pesanan');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal mengirim pesanan: $e')));
    }
  }

  // Fungsi untuk menghapus item dari keranjang setelah pesanan berhasil dibuat
  Future<void> _deleteCartItemsAfterOrder(String username) async {
    try {
      for (var item in widget.selectedItems) {
        final response = await http.post(
          Uri.parse('https://teknologi22.xyz/project_api/api_raynor/online_store/delete_cart_item.php'),
          body: {
            'username': username,
            'id': item.id.toString(),
          },
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['status'] != 'success') {
            throw Exception(responseData['message'] ?? 'Gagal menghapus item dari keranjang');
          }
        } else {
          throw Exception('Failed to delete item from cart');
        }
      }
    } catch (e) {
      print('Error deleting cart items: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus item dari keranjang: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.selectedItems.fold(0, (sum, item) => sum + item.price);
    double shippingCost = getShippingCost();
    double totalAmount = totalPrice + shippingCost;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pesanan'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Barang yang Dipesan:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.selectedItems.length,
                itemBuilder: (context, index) {
                  final item = widget.selectedItems[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Image.network(
                        item.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
                      ),
                      title: Text(item.name),
                      subtitle: Text(
                          'Jumlah: ${item.quantity} | Harga: Rp${item.price.toStringAsFixed(0)}'),
                    ),
                  );
                },
              ),
              Divider(),
              SizedBox(height: 10),
              Text(
                'Total Harga: Rp${totalPrice.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Opsi Pengiriman: ${_selectedShippingOption ?? "Belum dipilih"}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                'Biaya Pengiriman: Rp${shippingCost.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Alamat Pembeli',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              Text(
                'Metode Pembayaran:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                hint: Text('Pilih metode pembayaran'),
                items: _paymentMethods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Opsi Pengiriman: ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _selectedShippingOption,
                hint: Text('Pilih opsi pengiriman'),
                items: _shippingOptions.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedShippingOption = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Total yang harus dibayar: Rp${totalAmount.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: _submitOrder,
                  child: Text('Pesan Sekarang'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
