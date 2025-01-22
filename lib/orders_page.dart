import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class OrdersPage extends StatefulWidget {
  final String username;

  OrdersPage({required this.username});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<Map<String, dynamic>> orders = [];
  bool _isLoading = true;
  late Timer _timer;

  // Map untuk menyimpan status checkbox setiap pesanan
  Map<int, bool> _selectedOrders = {};

  @override
  void initState() {
    super.initState();
    _fetchOrders(); // Ambil pesanan saat pertama kali dimuat
    _startPolling(); // Mulai polling untuk memperbarui data secara periodik
  }

  @override
  void dispose() {
    _timer.cancel(); // Hentikan polling saat widget dihapus
    super.dispose();
  }

  // Mengambil data pesanan dari server
  Future<void> _fetchOrders() async {
    try {
      final response = await http.post(
        Uri.parse('https://teknologi22.xyz/project_api/api_raynor/online_store/get_orders.php'),
        body: {'username': widget.username},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            orders = List<Map<String, dynamic>>.from(data['orders']);
            for (int i = 0; i < orders.length; i++) {
              _selectedOrders[i] = _selectedOrders[i] ?? false;
            }
            _isLoading = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Gagal memuat pesanan')),
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
    } catch (e) {
      print('Error fetching orders: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk memulai polling setiap 5 detik (pengaturan interval lebih pendek)
  void _startPolling() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      _fetchOrders(); // Ambil data pesanan terbaru
    });
  }

  // Fungsi untuk menghapus pesanan yang dipilih dari database
  Future<void> _deleteSelectedOrders() async {
    try {
      List<int> selectedIds = [];
      _selectedOrders.forEach((index, isSelected) {
        if (isSelected) {
          selectedIds.add(orders[index]['id']);
        }
      });

      if (selectedIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak ada pesanan yang dipilih')),
        );
        return;
      }

      print('Mengirim permintaan untuk menghapus pesanan: $selectedIds');

      final response = await http.post(
        Uri.parse('https://teknologi22.xyz/project_api/api_raynor/online_store/delete_orders.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ids': selectedIds}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Hapus pesanan yang terpilih dari list `orders`
          setState(() {
            orders.removeWhere((order) => selectedIds.contains(order['id']));
            _selectedOrders.clear(); // Reset pilihan checkbox
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pesanan terpilih telah dihapus')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Gagal menghapus pesanan')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error server (${response.statusCode})')),
        );
      }
    } catch (e) {
      print('Error deleting orders: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesanan Anda'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Stack(
        children: [
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : orders.isEmpty
              ? Center(
            child: Text(
              'Belum ada pesanan yang terdaftar',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
              : ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _selectedOrders[index] ?? false,
                            onChanged: (bool? value) {
                              setState(() {
                                _selectedOrders[index] = value ?? false;
                              });
                            },
                          ),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(order['image_url'] ?? 'https://via.placeholder.com/80'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order['name'] ?? 'Nama Produk Tidak Tersedia',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Jumlah: ${order['quantity'] ?? '0'}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Harga Satuan: Rp${order['unit_price'] ?? '0'}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Total Bayar: Rp${order['total_bayar'] ?? '0'}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Alamat: ${order['address'] ?? 'Tidak Diketahui'}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Metode Pembayaran: ${order['metode_pembayaran'] ?? 'Tidak Diketahui'}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Opsi Pengiriman: ${order['opsi_pengiriman'] ?? 'Tidak Diketahui'}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Tanggal Pesanan: ${order['created_at'] ?? 'Tidak Diketahui'}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (!_isLoading && orders.isNotEmpty)
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: _deleteSelectedOrders,
                backgroundColor: Colors.red,
                child: Icon(Icons.delete, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}