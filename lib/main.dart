// lib/main.dart

// --- FLUTTER & DART ---
import 'package:flutter/material.dart';

// --- PACKAGES ---
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Tetap butuh ini untuk init Hive
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

// --- MODELS & PROVIDERS ---
import 'package:bookapp/models/saved_book_model.dart';
import 'package:bookapp/providers/book_provider.dart';
import 'package:bookapp/providers/user_provider.dart';

// --- SCREENS ---
import 'package:bookapp/screens/splash_screen.dart';
import 'package:bookapp/screens/welcome_screen.dart';
import 'package:bookapp/screens/login_screen.dart';
import 'package:bookapp/screens/register_screen.dart';
import 'package:bookapp/screens/main_navigation_screen.dart';

Future<void> main() async {
  // --- BAGIAN INISIALISASI ---
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Hive.initFlutter();
  Hive.registerAdapter(SavedBookAdapter());
  await Hive.openBox('userBox');
  await Hive.openBox('sessionBox');
  await Hive.openBox<SavedBook>('savedBooksBox');

  // --- Jalankan Aplikasi (Tetap pakai MultiProvider) ---
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BookProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- LANGSUNG MaterialApp (TANPA HiveInspector) ---
    return MaterialApp(
      title: 'BookApp',
      debugShowCheckedModeBanner: false,

      // Tema Global
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        brightness: Brightness.light,
        textTheme: GoogleFonts.manropeTextTheme(
          Theme.of(context).textTheme,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.grey[700]),
        ),
      ),

      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainNavigationScreen(),
      },
    );
    // ---------------------------------------------------
  }
}