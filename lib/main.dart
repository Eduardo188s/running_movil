import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:recorrido_salud/auth_gate.dart';
import 'package:recorrido_salud/firebase_options.dart';
import 'package:recorrido_salud/auth/register_page.dart'; 
import 'package:recorrido_salud/auth/login_page.dart';
import 'package:recorrido_salud/screens/main_screen.dart';
import 'package:recorrido_salud/services/notification.dart';  

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize(); 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(), // o la pantalla que desees inicial
      routes: {
        '/auth/login_page': (context) => const LoginPage(),
        '/auth/register_page': (context) => const RegisterPage(), // 👈 Aquí la ruta
        '/home': (context) => const MainScreen(),
      },
    );
  }
}
