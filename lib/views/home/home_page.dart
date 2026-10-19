import 'package:flutter/material.dart';

import '../../models/expense_data.dart';
import '../menus/member_page.dart';
import '../menus/calculator_page.dart';
import '../menus/expense_page.dart';
import '../menus/date_conversion_page.dart';
import '../menus/calendar_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeMate Dashboard'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Selamat Datang, ${UserSession.username}!',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Pilih menu di bawah untuk mengelola rumah tangga:',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          _buildMenuCard(
            context,
            'Daftar Anggota',
            Icons.group,
            const MemberPage(),
          ),
          _buildMenuCard(
            context,
            'Home Calculator',
            Icons.calculate,
            const CalculatorPage(),
          ),
          _buildMenuCard(
            context,
            'Pengeluaran Rumah',
            Icons.wallet,
            const ExpensePage(),
          ),
          _buildMenuCard(
            context,
            'Konversi Tanggal & Umur',
            Icons.date_range,
            const DateConversionPage(),
          ),
          _buildMenuCard(
            context,
            'Kalender (Weton, Hijriah, Saka)',
            Icons.calendar_month,
            const CalendarPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget targetPage,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF869277), size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color(0xFFB88E65),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetPage),
          );
        },
      ),
    );
  }
}
