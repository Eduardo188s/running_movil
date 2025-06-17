import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:recorrido_salud/firebase_options.dart';
import 'package:recorrido_salud/screens/home.dart';
import 'package:recorrido_salud/auth/register_page.dart'; 
import 'package:recorrido_salud/auth/login_page.dart';  

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      initialRoute: '/auth/login_page', // o la pantalla que desees inicial
      routes: {
        '/auth/login_page': (context) => const LoginPage(),
        '/auth/register_page': (context) => const RegisterPage(), // 👈 Aquí la ruta
        '/home': (context) => const HomePage(),
      },
    );
  }
}
