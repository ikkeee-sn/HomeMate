import 'package:flutter/material.dart';

class MemberPage extends StatelessWidget {
  const MemberPage({Key? key}) : super(key: key);

  final List<Map<String, String>> members = const [
    {'name': 'Najla Huwaida', 'nim': '124240003'},
    {'name': 'Ikke Surya Ningsih', 'nim': '124240007'},
    {'name': 'Syarifah Khaerunnisa', 'nim': '124240017'},
    {'name': 'Diandra Mayliza Nurazizah', 'nim': '124240022'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Anggota'),
        backgroundColor: const Color(0xFF869277), // Sage Green
      ),
      body: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF869277), // Sage Green
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                members[index]['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('NIM: ${members[index]['nim']}'),
            ),
          );
        },
      ),
    );
  }
}
