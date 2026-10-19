import 'package:flutter/material.dart';
import 'package:hijri_date_time/hijri_date_time.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDate;
  String _conversionType = 'Weton';

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  // 1. Algoritma Weton Asli
  String _getWeton(DateTime date) {
    const pasaranList = ['Kliwon', 'Legi', 'Pahing', 'Pon', 'Wage'];
    const hariList = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];

    DateTime refDate = DateTime(2023, 1, 1);
    int difference = date.difference(refDate).inDays;

    int hariIndex = date.weekday % 7;
    int pasaranIndex = (2 + difference) % 5;
    if (pasaranIndex < 0) pasaranIndex += 5;

    return '${hariList[hariIndex]} ${pasaranList[pasaranIndex]}';
  }

  // 2. Konversi Hijriah Dinamis
  String _getHijriah(DateTime date) {
    try {
      // Menggunakan static method fromGregorian
      HijriDateTime hijriDate = HijriDateTime.fromGregorian(date);

      const hijriMonths = [
        'Muharram',
        'Safar',
        'Rabiul Awal',
        'Rabiul Akhir',
        'Jumadil Awal',
        'Jumadil Akhir',
        'Rajab',
        'Syaban',
        'Ramadhan',
        'Syawal',
        'Dzulqadah',
        'Dzulhijjah',
      ];

      int monthIndex = (hijriDate.month - 1).clamp(0, 11);
      String monthName = hijriMonths[monthIndex];

      return '${hijriDate.day} $monthName ${hijriDate.year} H';
    } catch (e) {
      return 'Gagal memproses konversi Hijriah';
    }
  }

  // 3. Kalender Saka Bali Dinamis
  String _getSakaBali(DateTime date) {
    int sakaYear = date.year - 78;
    if (date.month < 3 || (date.month == 3 && date.day < 22)) {
      sakaYear -= 1;
    }

    const sasihList = [
      'Sasih Kasa',
      'Sasih Karo',
      'Sasih Katiga',
      'Sasih Kapat',
      'Sasih Kalima',
      'Sasih Kanem',
      'Sasih Kapitu',
      'Sasih Kawulu',
      'Sasih Kasanga',
      'Sasih Kadasa',
      'Sasih Jiyestha',
      'Sasih Sada',
    ];

    int sasihIndex = (date.month + 5) % 12;

    return 'Tahun Saka $sakaYear (${sasihList[sasihIndex]})';
  }

  String _getResult() {
    if (_conversionType == 'Weton') {
      return 'Weton: ${_getWeton(_selectedDate)}';
    } else if (_conversionType == 'Hijriah') {
      return 'Kalender Hijriah: ${_getHijriah(_selectedDate)}';
    } else {
      return 'Kalender Saka Bali: ${_getSakaBali(_selectedDate)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kalender & Konversi Tanggal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5),
                ],
              ),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                //Tahun Mulai dan Akhir Kalender
                firstDate: DateTime(1950),
                lastDate: DateTime(2050),
                onDateChanged: (DateTime? date) {
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pilih Jenis Konversi:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                DropdownButton<String>(
                  value: _conversionType,
                  items: ['Weton', 'Hijriah', 'Saka Bali'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _conversionType = newValue;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF869277).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF869277)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal Dipilih: ${_selectedDate.day}-${_selectedDate.month}-${_selectedDate.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getResult(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF869277),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
