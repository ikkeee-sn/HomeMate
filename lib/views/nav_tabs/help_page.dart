import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/login_page.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal logout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text(
          'Apakah kamu yakin ingin keluar dari aplikasi HomeMate?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB88E65),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);

              await _logout(context);
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pusat Bantuan & Panduan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Panduan Fitur HomeMate',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF869277),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Pelajari cara menggunakan setiap menu utama di aplikasi HomeMate:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // 1. Daftar Anggota
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                leading: const Icon(
                  Icons.group,
                  color: Color(0xFF869277),
                ),
                title: const Text(
                  'Daftar Anggota',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'Menampilkan daftar anggota atau penghuni rumah tangga beserta informasi detailnya untuk mempermudah koordinasi antar anggota keluarga.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Home Calculator
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                leading: const Icon(
                  Icons.calculate,
                  color: Color(0xFF869277),
                ),
                title: const Text(
                  'Home Calculator',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'Hitung perkiraan total belanja harian secara otomatis berdasarkan harga satuan dan kuantitas barang, lalu simpan langsung ke dalam catatan pengeluaran.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Pengeluaran Rumah
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                leading: const Icon(
                  Icons.wallet,
                  color: Color(0xFF869277),
                ),
                title: const Text(
                  'Pengeluaran Rumah (CRUD)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'Kelola riwayat belanja rumah tangga dengan fitur memilih bulan transaksi terlebih dahulu. Anda dapat menambah, melihat, mengedit, atau menghapus data pengeluaran.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 4. Konversi Tanggal & Umur
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                leading: const Icon(
                  Icons.date_range,
                  color: Color(0xFF869277),
                ),
                title: const Text(
                  'Konversi Tanggal & Umur',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'Hitung usia secara mendetail berdasarkan tanggal lahir hingga ke satuan tahun, bulan, hari, jam, menit, dan detik secara real-time.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 5. Kalender (Weton, Hijriah, Saka)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                leading: const Icon(
                  Icons.calendar_month,
                  color: Color(0xFF869277),
                ),
                title: const Text(
                  'Kalender (Weton, Hijriah, Saka)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'Konversikan tanggal Masehi ke sistem penanggalan tradisional dan keagamaan seperti Weton (Jawa), Kalender Hijriah (Islam), dan Kalender Saka Bali.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 6. Stopwatch
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                leading: const Icon(
                  Icons.timer,
                  color: Color(0xFF869277),
                ),
                title: const Text(
                  'Stopwatch',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'Gunakan penghitung waktu untuk mengukur durasi pengerjaan tugas atau pekerjaan rumah tangga.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Tombol Logout
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB88E65),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  _showLogoutDialog(context);
                },
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
                label: const Text(
                  'LOGOUT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}