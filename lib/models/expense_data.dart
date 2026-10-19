import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserSession {
  static String username = "Pengguna";
}

class ExpenseItem {
  String? id;
  String title;
  String category;
  double amount;
  String monthYear;
  String date;
  DateTime rawDate;

  ExpenseItem({
    this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.monthYear,
    required this.date,
    required this.rawDate,
  });

  factory ExpenseItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    DateTime rawDate;

    if (data['rawDate'] is Timestamp) {
      rawDate = (data['rawDate'] as Timestamp).toDate();
    } else {
      rawDate = DateTime.now();
    }

    return ExpenseItem(
      id: doc.id,
      title: data['title'] ?? 'Tanpa Nama',
      category: data['category'] ?? 'Umum',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      monthYear: data['monthYear'] ?? '',
      date: data['date'] ?? '',
      rawDate: rawDate,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'category': category,
      'amount': amount,
      'monthYear': monthYear,
      'date': date,
      'rawDate': Timestamp.fromDate(rawDate),
    };
  }
}

class ExpenseManager {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static List<ExpenseItem> items = [];

  static CollectionReference<Map<String, dynamic>>
      get _expenseCollection {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User belum login');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('expenses');
  }

  // =========================
  // FORMAT RUPIAH
  // =========================

  static String formatRupiah(double amount) {
    String s = amount.toStringAsFixed(0);

    RegExp reg = RegExp(
      r'(\d{1,3})(?=(\d{3})+(?!\d))',
    );

    return 'Rp ${s.replaceAllMapped(
      reg,
      (Match m) => '${m[1]}.',
    )}';
  }

  // =========================
  // LOAD SEMUA PENGELUARAN
  // =========================

  static Future<void> loadExpenses() async {
    final snapshot = await _expenseCollection
        .orderBy(
          'rawDate',
          descending: true,
        )
        .get();

    // Semua data dari Firestore dimuat.
    // Tidak ada lagi batas 5 bulan.
    items = snapshot.docs
        .map(
          (doc) => ExpenseItem.fromFirestore(doc),
        )
        .toList();
  }

  // =========================
  // TAMBAH PENGELUARAN
  // =========================

  static Future<void> addExpense(
    String? title,
    String? category,
    double? amount, {
    DateTime? customDate,
  }) async {
    DateTime targetDate =
        customDate ?? DateTime.now();

    String mY =
        '${_getMonthName(targetDate.month)} '
        '${targetDate.year}';

    String d =
        '${targetDate.day} '
        '${_getMonthName(targetDate.month).substring(0, 3)} '
        '${targetDate.year}';

    final expense = ExpenseItem(
      title: (title == null || title.isEmpty)
          ? 'Tanpa Nama'
          : title,
      category:
          (category == null || category.isEmpty)
              ? 'Umum'
              : category,
      amount: amount ?? 0.0,
      monthYear: mY,
      date: d,
      rawDate: targetDate,
    );

    // Simpan ke Firestore
    final doc = await _expenseCollection.add(
      expense.toFirestore(),
    );

    // Simpan ID dokumen
    expense.id = doc.id;

    // Tambahkan ke daftar lokal
    items.add(expense);

    // Urutkan dari tanggal terbaru
    items.sort(
      (a, b) => b.rawDate.compareTo(a.rawDate),
    );

    // Tidak ada lagi penghapusan data lama.
  }

  // =========================
  // UPDATE PENGELUARAN
  // =========================

  static Future<void> updateExpense(
    ExpenseItem item, {
    required String title,
    required String category,
    required double amount,
    required DateTime customDate,
  }) async {
    item.title =
        title.isEmpty ? 'Tanpa Nama' : title;

    item.category =
        category.isEmpty ? 'Umum' : category;

    item.amount = amount;

    item.rawDate = customDate;

    item.monthYear =
        '${_getMonthName(customDate.month)} '
        '${customDate.year}';

    item.date =
        '${customDate.day} '
        '${_getMonthName(customDate.month).substring(0, 3)} '
        '${customDate.year}';

    // Update dokumen di Firestore
    if (item.id != null) {
      await _expenseCollection
          .doc(item.id)
          .update(
            item.toFirestore(),
          );
    }

    // Urutkan kembali setelah tanggal diubah
    items.sort(
      (a, b) => b.rawDate.compareTo(a.rawDate),
    );

    // Tidak ada lagi penghapusan data lama.
  }

  // =========================
  // HAPUS PENGELUARAN
  // =========================

  static Future<void> deleteExpense(
    ExpenseItem item,
  ) async {
    if (item.id != null) {
      await _expenseCollection
          .doc(item.id)
          .delete();
    }

    items.remove(item);
  }

  // =========================
  // NAMA BULAN
  // =========================

  static String _getMonthName(int month) {
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
}