import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'product_list_page.dart';
import 'orders_page.dart';

class ProfilePage extends StatefulWidget {
  final String username;

  ProfilePage({required this.username});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String email = '';
  String phone = '';
  String? namaToko;
  bool _isLoading = true;
  int productCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _getUserProfile();
    // Mulai timer untuk polling setiap 5 detik
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _getUserProfile();
    });
  }

  @override
  void dispose() {
    // Hentikan timer saat widget di-dispose
    _timer?.cancel();
    super.dispose();
  }

  // Fetch user profile from API
  Future<void> _getUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username') ?? widget.username;

    final response = await http.post(
      Uri.parse(
          'https://teknologi22.xyz/project_api/api_raynor/online_store/get_profile.php'),
      body: {'username': username},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          email = data['email'];
          phone = data['phone'];
          namaToko = data['nama_toko'];
          productCount = data['product_count'] ?? 0;
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Error fetching profile')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error server (${response.statusCode})')),
      );
    }
  }

  // Logout function
  // Logout function with confirmation
  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Logout'),
          content: Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Tidak'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('username');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Ya'),
            ),
          ],
        );
      },
    );
  }


  // Function to create store
  Future<void> _createToko() async {
    TextEditingController tokoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Buat Toko'),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
            ),
          ],
        ),
        content: TextField(
          controller: tokoController,
          decoration: InputDecoration(hintText: 'Masukkan Nama Toko'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              String namaTokoInput = tokoController.text.trim();
              if (namaTokoInput.isNotEmpty) {
                // Cek jika nama toko sudah ada
                final responseCheck = await http.post(
                  Uri.parse('https://teknologi22.xyz/project_api/api_raynor/online_store/check_toko_exists.php'),
                  body: {'nama_toko': namaTokoInput},
                );

                if (responseCheck.statusCode == 200) {
                  final data = jsonDecode(responseCheck.body);
                  if (data['status'] == 'exists') {
                    // Jika nama toko sudah ada
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Nama toko sudah digunakan. Pilih nama lain.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    Navigator.pop(context); // Close dialog
                    return;
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error server (${responseCheck.statusCode})')),
                  );
                  Navigator.pop(context); // Close dialog
                  return;
                }

                // Jika nama toko unik, buat toko baru
                final response = await http.post(
                  Uri.parse('https://teknologi22.xyz/project_api/api_raynor/online_store/create_toko.php'),
                  body: {
                    'username': widget.username,
                    'nama_toko': namaTokoInput,
                  },
                );

                if (response.statusCode == 200) {
                  final data = jsonDecode(response.body);

                  if (data['status'] == 'success') {
                    setState(() {
                      namaToko = namaTokoInput;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Toko berhasil dibuat')),
                    );

                    // Navigate to ProductListPage after store creation
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductListPage(
                          username: widget.username,
                          nama_toko: namaTokoInput,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(data['message'] ?? 'Gagal membuat toko')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error server (${response.statusCode})')),
                  );
                }
                Navigator.pop(context); // Close dialog
              } else {
                // Jika nama toko kosong
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Nama toko tidak boleh kosong')),
                );
              }
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade200, Colors.teal.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.teal.shade700,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Username: ${widget.username}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Tambahkan Padding ke kiri untuk menggeser informasi profil ke kanan
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Email: $email',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Phone: $phone',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                        SizedBox(height: 10),
                        if (namaToko != null && namaToko!.isNotEmpty)
                          Text(
                            'Toko: $namaToko',
                            style: TextStyle(fontSize: 16, color: Colors.white70),
                          )
                        else
                          Text(
                            'Toko: Belum ada toko',
                            style: TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildButton(
                        icon: Icons.store,
                        label: 'Produk Anda',
                        color: Colors.teal.shade600,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductListPage(
                                username: widget.username,
                                nama_toko: namaToko ?? 'Toko Anda',
                              ),
                            ),
                          );
                        },
                      ),
                      _buildButton(
                        icon: Icons.shopping_cart,
                        label: 'Lihat pesanan',
                        color: Colors.teal.shade600,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrdersPage(username: widget.username),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: _buildButton(
                      icon: Icons.store,
                      label: 'Buat Toko',
                      color: Colors.teal.shade800,
                      onPressed: _createToko,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(Icons.logout, color: Colors.white),
                onPressed: _logout,
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
      ),
    );
  }
}