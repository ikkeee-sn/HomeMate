import 'package:flutter/material.dart';

import '../../models/expense_data.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({Key? key}) : super(key: key);

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  // Tahun yang sedang dipilih
  int? _selectedYear;

  // Bulan yang sedang dipilih
  String? _selectedMonth;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  // ============================================================
  // LOAD DATA DARI FIRESTORE
  // ============================================================

  Future<void> _loadExpenses() async {
    try {
      await ExpenseManager.loadExpenses();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengambil data pengeluaran: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  // ============================================================
  // DIALOG TAMBAH / EDIT PENGELUARAN
  // ============================================================

  Future<void> _showExpenseDialog({
    ExpenseItem? item,
  }) async {
    final titleController = TextEditingController(
      text: item?.title ?? '',
    );

    final categoryController = TextEditingController(
      text: item?.category ?? '',
    );

    final amountController = TextEditingController(
      text: item != null
          ? item.amount.toStringAsFixed(0)
          : '',
    );

    DateTime selectedDate =
        item?.rawDate ?? DateTime.now();

    await showDialog(
      context: context,
      builder: (context) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                item == null
                    ? 'Tambah Pengeluaran'
                    : 'Edit Pengeluaran',
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ==================================================
                    // NAMA PENGELUARAN
                    // ==================================================

                    TextField(
                      controller: titleController,
                      enabled: !isSaving,
                      decoration: const InputDecoration(
                        labelText:
                            'Nama Barang/Pengeluaran',
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ==================================================
                    // KATEGORI
                    // ==================================================

                    TextField(
                      controller: categoryController,
                      enabled: !isSaving,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ==================================================
                    // NOMINAL
                    // ==================================================

                    TextField(
                      controller: amountController,
                      enabled: !isSaving,
                      keyboardType:
                          TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nominal (Rp)',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // TANGGAL
                    // ==================================================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Tanggal: '
                            '${selectedDate.day}/'
                            '${selectedDate.month}/'
                            '${selectedDate.year}',
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ),

                        TextButton.icon(
                          icon: const Icon(
                            Icons.calendar_today,
                            size: 18,
                          ),
                          label: const Text(
                            'Pilih Tanggal',
                          ),

                          onPressed: isSaving
                              ? null
                              : () async {
                                  final now =
                                      DateTime.now();

                                  // Tidak ada lagi
                                  // batas 5 bulan.
                                  final firstAllowed =
                                      DateTime(
                                    2000,
                                    1,
                                    1,
                                  );

                                  DateTime initialDate =
                                      selectedDate;

                                  if (initialDate
                                      .isBefore(
                                    firstAllowed,
                                  )) {
                                    initialDate =
                                        firstAllowed;
                                  }

                                  if (initialDate
                                      .isAfter(now)) {
                                    initialDate = now;
                                  }

                                  final picked =
                                      await showDatePicker(
                                    context: context,
                                    initialDate:
                                        initialDate,
                                    firstDate:
                                        firstAllowed,
                                    lastDate: now,
                                    helpText:
                                        'Pilih Tanggal Pengeluaran',
                                  );

                                  if (picked != null) {
                                    setDialogState(() {
                                      selectedDate =
                                          picked;
                                    });
                                  }
                                },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ========================================================
              // TOMBOL DIALOG
              // ========================================================

              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () =>
                          Navigator.pop(context),
                  child: const Text('Batal'),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF869277),
                  ),

                  onPressed: isSaving
                      ? null
                      : () async {
                          final title =
                              titleController.text
                                  .trim();

                          final category =
                              categoryController
                                  .text
                                  .trim();

                          final amount =
                              double.tryParse(
                                    amountController
                                        .text
                                        .replaceAll(
                                          '.',
                                          '',
                                        )
                                        .replaceAll(
                                          ',',
                                          '',
                                        ),
                                  ) ??
                                  0.0;

                          // ==============================
                          // VALIDASI
                          // ==============================

                          if (title.isEmpty ||
                              amount <= 0) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Nama pengeluaran dan nominal harus diisi dengan benar!',
                                ),
                                backgroundColor:
                                    Colors.orange,
                              ),
                            );

                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            // ==============================
                            // TAMBAH
                            // ==============================

                            if (item == null) {
                              await ExpenseManager
                                  .addExpense(
                                title,
                                category,
                                amount,
                                customDate:
                                    selectedDate,
                              );
                            }

                            // ==============================
                            // EDIT
                            // ==============================

                            else {
                              await ExpenseManager
                                  .updateExpense(
                                item,
                                title: title,
                                category: category,
                                amount: amount,
                                customDate:
                                    selectedDate,
                              );
                            }

                            if (!mounted) return;

                            setState(() {});

                            Navigator.pop(context);

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  item == null
                                      ? 'Pengeluaran berhasil ditambahkan!'
                                      : 'Pengeluaran berhasil diperbarui!',
                                ),
                                backgroundColor:
                                    const Color(
                                  0xFF869277,
                                ),
                              ),
                            );
                          } catch (e) {
                            setDialogState(() {
                              isSaving = false;
                            });

                            if (!mounted) return;

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Gagal menyimpan data: $e',
                                ),
                                backgroundColor:
                                    Colors.red,
                              ),
                            );
                          }
                        },

                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Simpan',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    categoryController.dispose();
    amountController.dispose();
  }

  // ============================================================
  // HAPUS PENGELUARAN
  // ============================================================

  Future<void> _deleteExpense(
    ExpenseItem item,
  ) async {
    try {
      await ExpenseManager.deleteExpense(item);

      if (!mounted) return;

      setState(() {
        // Kalau bulan sudah tidak memiliki transaksi,
        // kembali ke daftar bulan.
        if (_selectedMonth != null &&
            ExpenseManager.items
                .where(
                  (i) =>
                      i.monthYear.trim() ==
                      _selectedMonth?.trim(),
                )
                .isEmpty) {
          _selectedMonth = null;
        }

        // Kalau tahun sudah tidak memiliki transaksi,
        // kembali ke daftar tahun.
        if (_selectedYear != null &&
            ExpenseManager.items
                .where(
                  (i) =>
                      i.rawDate.year ==
                      _selectedYear,
                )
                .isEmpty) {
          _selectedYear = null;
          _selectedMonth = null;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pengeluaran berhasil dihapus!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menghapus data: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF869277),
          ),
        ),
      );
    }

    // ============================================================
    // KELOMPOKKAN SEMUA DATA BERDASARKAN TAHUN
    // ============================================================

    Map<int, List<ExpenseItem>> groupedByYear = {};

    for (final expense in ExpenseManager.items) {
      final year = expense.rawDate.year;

      if (!groupedByYear.containsKey(year)) {
        groupedByYear[year] = [];
      }

      groupedByYear[year]!.add(expense);
    }

    // Tahun terbaru di atas
    final yearsList = groupedByYear.keys.toList()
      ..sort(
        (a, b) => b.compareTo(a),
      );

    // ============================================================
    // JIKA SUDAH MEMILIH TAHUN
    // ============================================================

    Map<String, List<ExpenseItem>> groupedByMonth = {};

    if (_selectedYear != null) {
      final yearItems =
          groupedByYear[_selectedYear] ?? [];

      for (final expense in yearItems) {
        final month = expense.monthYear
            .replaceAllMapped(
              RegExp(r'([a-zA-Z]+)(\d{4})'),
              (m) => '${m[1]} ${m[2]}',
            )
            .trim();

        expense.monthYear = month;

        if (!groupedByMonth.containsKey(month)) {
          groupedByMonth[month] = [];
        }

        groupedByMonth[month]!.add(expense);
      }
    }

    // ============================================================
    // DAFTAR BULAN DI TAHUN YANG DIPILIH
    // ============================================================

    List<String> monthsList =
        groupedByMonth.keys.toList();

    monthsList.sort((a, b) {
      final aItems = groupedByMonth[a] ?? [];
      final bItems = groupedByMonth[b] ?? [];

      final aDate = aItems.isNotEmpty
          ? aItems.first.rawDate
          : DateTime(2000);

      final bDate = bItems.isNotEmpty
          ? bItems.first.rawDate
          : DateTime(2000);

      return bDate.compareTo(aDate);
    });

    // ============================================================
    // TAMPILAN UTAMA
    // ============================================================

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedMonth != null
              ? _selectedMonth!
              : _selectedYear != null
                  ? 'Pilih Bulan $_selectedYear'
                  : 'Pilih Tahun Riwayat',
        ),

        leading: (_selectedYear != null ||
                _selectedMonth != null)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                ),
                onPressed: () {
                  setState(() {
                    if (_selectedMonth != null) {
                      // Dari transaksi kembali
                      // ke daftar bulan
                      _selectedMonth = null;
                    } else {
                      // Dari bulan kembali
                      // ke daftar tahun
                      _selectedYear = null;
                    }
                  });
                },
              )
            : null,
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: _selectedYear == null
          ? _buildYearMenu(
              groupedByYear,
              yearsList,
            )
          : _selectedMonth == null
              ? _buildMonthMenu(
                  groupedByMonth,
                  monthsList,
                )
              : _buildExpenseList(
                  groupedByMonth[
                          _selectedMonth] ??
                      [],
                ),

      // ============================================================
      // FLOATING ACTION BUTTON
      // ============================================================

      floatingActionButton:
          FloatingActionButton(
        backgroundColor:
            const Color(0xFFB88E65),

        onPressed: () =>
            _showExpenseDialog(),

        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  // ============================================================
  // HALAMAN DAFTAR TAHUN
  // ============================================================

  Widget _buildYearMenu(
    Map<int, List<ExpenseItem>>
        groupedByYear,
    List<int> yearsList,
  ) {
    if (yearsList.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada riwayat pengeluaran.',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: yearsList.length,

      itemBuilder: (context, index) {
        final year = yearsList[index];

        final itemsInYear =
            groupedByYear[year] ?? [];

        // Hitung total satu tahun
        final yearTotal =
            itemsInYear.fold<double>(
          0,
          (sum, item) =>
              sum + item.amount,
        );

        // Cari jumlah bulan unik
        final uniqueMonths =
            itemsInYear
                .map(
                  (item) =>
                      item.monthYear.trim(),
                )
                .toSet();

        return Card(
          elevation: 3,

          margin:
              const EdgeInsets.only(
            bottom: 12,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),

          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),

            leading:
                const CircleAvatar(
              backgroundColor:
                  Color(0xFF869277),

              child: Icon(
                Icons.calendar_today,
                color: Colors.white,
              ),
            ),

            // ==============================
            // TAHUN
            // ==============================

            title: Text(
              year.toString(),

              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 20,
              ),
            ),

            // ==============================
            // INFORMASI TAHUN
            // ==============================

            subtitle: Text(
              '${uniqueMonths.length} Bulan | '
              '${itemsInYear.length} Transaksi\n'
              'Total: '
              '${ExpenseManager.formatRupiah(yearTotal)}',
            ),

            isThreeLine: true,

            trailing:
                const Icon(
              Icons.chevron_right,
              color: Color(0xFFB88E65),
            ),

            // ==============================
            // PILIH TAHUN
            // ==============================

            onTap: () {
              setState(() {
                _selectedYear = year;
                _selectedMonth = null;
              });
            },
          ),
        );
      },
    );
  }

  // ============================================================
  // HALAMAN DAFTAR BULAN
  // ============================================================

  Widget _buildMonthMenu(
    Map<String, List<ExpenseItem>>
        groupedByMonth,
    List<String> monthsList,
  ) {
    if (monthsList.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada riwayat pengeluaran pada tahun ini.',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: monthsList.length,

      itemBuilder: (context, index) {
        final month =
            monthsList[index];

        final itemsInMonth =
            groupedByMonth[month] ?? [];

        final monthTotal =
            itemsInMonth.fold<double>(
          0,
          (sum, item) =>
              sum + item.amount,
        );

        return Card(
          elevation: 3,

          margin:
              const EdgeInsets.only(
            bottom: 12,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),

          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),

            leading:
                const CircleAvatar(
              backgroundColor:
                  Color(0xFF869277),

              child: Icon(
                Icons.calendar_month,
                color: Colors.white,
              ),
            ),

            title: Text(
              month,

              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 17,
              ),
            ),

            subtitle: Text(
              '${itemsInMonth.length} Transaksi | '
              'Total: '
              '${ExpenseManager.formatRupiah(monthTotal)}',
            ),

            trailing:
                const Icon(
              Icons.chevron_right,
              color: Color(0xFFB88E65),
            ),

            onTap: () {
              setState(() {
                _selectedMonth = month;
              });
            },
          ),
        );
      },
    );
  }

  // ============================================================
  // HALAMAN DAFTAR TRANSAKSI
  // ============================================================

  Widget _buildExpenseList(
    List<ExpenseItem> monthItems,
  ) {
    if (monthItems.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada pengeluaran di bulan ini.',
        ),
      );
    }

    // Urutkan transaksi terbaru
    // ke transaksi terlama
    monthItems.sort(
      (a, b) =>
          b.rawDate.compareTo(a.rawDate),
    );

    final totalMonth =
        monthItems.fold<double>(
      0,
      (sum, item) =>
          sum + item.amount,
    );

    return Column(
      children: [
        // ========================================================
        // TOTAL BULAN
        // ========================================================

        Container(
          padding:
              const EdgeInsets.all(16),

          color: const Color(
            0xFF869277,
          ).withOpacity(0.15),

          width: double.infinity,

          child: Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [
              const Text(
                'Total Bulan Ini:',

                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              Text(
                ExpenseManager
                    .formatRupiah(
                  totalMonth,
                ),

                style: const TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(0xFFB88E65),
                ),
              ),
            ],
          ),
        ),

        // ========================================================
        // LIST TRANSAKSI
        // ========================================================

        Expanded(
          child:
              ListView.builder(
            padding:
                const EdgeInsets.all(12),

            itemCount:
                monthItems.length,

            itemBuilder:
                (context, index) {
              final exp =
                  monthItems[index];

              return Card(
                margin:
                    const EdgeInsets
                        .symmetric(
                  vertical: 6,
                ),

                child: ListTile(
                  // ==========================
                  // NAMA
                  // ==========================

                  title: Text(
                    exp.title,

                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  // ==========================
                  // DETAIL
                  // ==========================

                  subtitle: Text(
                    '${exp.category} • '
                    '${exp.date}\n'
                    'Nominal: '
                    '${ExpenseManager.formatRupiah(exp.amount)}',
                  ),

                  isThreeLine: true,

                  // ==========================
                  // EDIT + DELETE
                  // ==========================

                  trailing: Row(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [
                      IconButton(
                        icon:
                            const Icon(
                          Icons.edit,
                          color:
                              Color(0xFFB88E65),
                        ),

                        onPressed: () =>
                            _showExpenseDialog(
                          item: exp,
                        ),
                      ),

                      IconButton(
                        icon:
                            const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),

                        onPressed: () =>
                            _deleteExpense(
                          exp,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}