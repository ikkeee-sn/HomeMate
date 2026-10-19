import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'views/auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const HomeMateApp());
}

class HomeMateApp extends StatelessWidget {
  const HomeMateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeMate - Pengeluaran Rumah Tangga',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF1E9E3),
        primaryColor: const Color(0xFF869277),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF869277),
          secondary: const Color(0xFFB88E65),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF869277),
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF869277),
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const LoginPage(),
    );
  }
}