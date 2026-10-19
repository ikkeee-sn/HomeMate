import 'dart:async';

import 'package:flutter/material.dart';

class DateConversionPage extends StatefulWidget {
  const DateConversionPage({Key? key}) : super(key: key);

  @override
  State<DateConversionPage> createState() => _DateConversionPageState();
}

class _DateConversionPageState extends State<DateConversionPage> {
  DateTime _selectedDate = DateTime(2004, 5, 15);
  int years = 0, months = 0, days = 0, hours = 0, minutes = 0, seconds = 0;
  bool _isCalculated = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startLiveAgeCalculation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startLiveAgeCalculation() {
    _timer?.cancel();
    _calculateAge();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateAge();
    });
  }

  void _calculateAge() {
    DateTime now = DateTime.now();

    int y = now.year - _selectedDate.year;
    int m = now.month - _selectedDate.month;
    int d = now.day - _selectedDate.day;

    if (d < 0) {
      m--;
      final prevMonth = DateTime(now.year, now.month - 1, _selectedDate.day);
      d += now.difference(prevMonth).inDays;
    }
    if (m < 0) {
      y--;
      m += 12;
    }

    Duration diff = now.difference(_selectedDate);

    setState(() {
      years = y;
      months = m;
      days = d;
      hours = diff.inHours % 24;
      minutes = diff.inMinutes % 60;
      seconds = diff.inSeconds % 60;
      _isCalculated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konversi Tanggal Lahir & Umur')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const Text(
                      'Pilih Tanggal Lahir Anda',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CalendarDatePicker(
                      initialDate: _selectedDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      onDateChanged: (DateTime newDate) {
                        setState(() {
                          _selectedDate = newDate;
                        });
                        _startLiveAgeCalculation();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_isCalculated) ...[
              const Text(
                'Rincian Usia Anda Secara Real-Time',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB88E65),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildAgeBox('Tahun', '$years', Icons.timer),
                  _buildAgeBox('Bulan', '$months', Icons.calendar_view_month),
                  _buildAgeBox('Hari', '$days', Icons.wb_sunny),
                ],
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Sisa Jam'),
                        trailing: Text(
                          '$hours Jam',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Sisa Menit'),
                        trailing: Text(
                          '$minutes Menit',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Sisa Detik'),
                        trailing: Text(
                          '$seconds Detik',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB88E65),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAgeBox(String label, String value, IconData icon) {
    return Expanded(
      child: Card(
        color: const Color(0xFF869277),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
