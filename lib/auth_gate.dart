// auth_gate.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recorrido_salud/screens/main_screen.dart';
import 'package:recorrido_salud/auth/login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Esperando conexión con Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Usuario autenticado
        if (snapshot.hasData) {
          return const MainScreen();
        }
        // Usuario no autenticado
        return const LoginPage();
      },
    );
  }
}
