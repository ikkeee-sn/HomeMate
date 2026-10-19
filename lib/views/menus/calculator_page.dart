import 'package:flutter/material.dart';

import '../../models/expense_data.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({Key? key}) : super(key: key);

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  double _total = 0.0;

  bool _isSaving = false;

  // =========================
  // HITUNG TOTAL
  // =========================
  void _calculate() {
    double price =
        double.tryParse(
          _priceController.text.replaceAll('.', '').replaceAll(',', ''),
        ) ??
        0.0;

    double qty =
        double.tryParse(
          _qtyController.text.replaceAll('.', '').replaceAll(',', ''),
        ) ??
        0.0;

    setState(() {
      _total = price * qty;
    });
  }

  // =========================
  // PILIH TANGGAL
  // =========================
  Future<void> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();

    // Batas maksimal 5 bulan data
    DateTime minDate = DateTime(
      now.year,
      now.month - 4,
      1,
    );

    DateTime initialDate = _selectedDate;

    // Pastikan tanggal yang ditampilkan berada
    // dalam rentang yang diperbolehkan
    if (initialDate.isBefore(minDate)) {
      initialDate = minDate;
    }

    if (initialDate.isAfter(now)) {
      initialDate = now;
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
      lastDate: now,
      helpText: 'Pilih Tanggal Pengeluaran',
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // =========================
  // SIMPAN KE FIRESTORE
  // =========================
  Future<void> _saveToExpense() async {
    // Validasi nama barang
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan isi nama barang terlebih dahulu!',
          ),
        ),
      );
      return;
    }

    // Validasi total
    if (_total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan hitung total terlebih dahulu!',
          ),
        ),
      );
      return;
    }

    // Cegah tombol ditekan berkali-kali
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Simpan ke Firestore
      await ExpenseManager.addExpense(
        _nameController.text.trim(),
        'Belanja / Kalkulator',
        _total,
        customDate: _selectedDate,
      );

      if (!mounted) return;

      // Bersihkan form setelah berhasil
      _nameController.clear();
      _priceController.clear();
      _qtyController.clear();

      setState(() {
        _total = 0.0;
        _isSaving = false;
      });

      // Tampilkan notifikasi berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Berhasil ditambahkan ke Pengeluaran Rumah!',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // PENTING:
      // Tidak menggunakan Navigator.pop(context)
      //
      // Jadi halaman Calculator TETAP terbuka.
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan pengeluaran: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================
  // NAMA BULAN INDONESIA
  // =========================
  String _getMonthName(int month) {
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return months[month];
  }

  // =========================
  // DISPOSE CONTROLLER
  // =========================
  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _qtyController.dispose();

    super.dispose();
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Calculator Belanja'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          children: [
            // =========================
            // NAMA BARANG
            // =========================
            TextField(
              controller: _nameController,

              decoration: const InputDecoration(
                labelText: 'Nama Barang',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // =========================
            // HARGA SATUAN
            // =========================
            TextField(
              controller: _priceController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                labelText: 'Harga Satuan (Rp)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // =========================
            // KUANTITAS
            // =========================
            TextField(
              controller: _qtyController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                labelText: 'Jumlah Beli / Kuantitas',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // =========================
            // TANGGAL
            // =========================
            InkWell(
              onTap: () => _selectDate(context),

              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Tanggal Pengeluaran',
                  border: OutlineInputBorder(),

                  suffixIcon: Icon(
                    Icons.calendar_today,
                    color: Color(0xFF869277),
                  ),
                ),

                child: Text(
                  '${_selectedDate.day} '
                  '${_getMonthName(_selectedDate.month)} '
                  '${_selectedDate.year}',

                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // TOMBOL HITUNG
            // =========================
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF869277),

                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),

              onPressed: _calculate,

              child: const Text(
                'Hitung Total',

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // TOTAL BIAYA
            // =========================
            Text(
              'Total Biaya: ${ExpenseManager.formatRupiah(_total)}',

              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB88E65),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // TOMBOL SIMPAN
            // =========================
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB88E65),

                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 12,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),

              onPressed: _isSaving ? null : _saveToExpense,

              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,

                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.save,
                      color: Colors.white,
                    ),

              label: Text(
                _isSaving
                    ? 'Menyimpan...'
                    : 'Simpan ke Pengeluaran Rumah',

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}