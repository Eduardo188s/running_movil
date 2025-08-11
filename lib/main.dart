import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:running_movil/auth/login_page.dart';
import 'package:running_movil/auth/register_page.dart';
import 'package:running_movil/auth_gate.dart';
import 'package:running_movil/firebase_options.dart';
import 'package:running_movil/screens/main_screen.dart';
import 'package:running_movil/services/notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar notificaciones
  await NotificationServiceAwesome.initialize();
  
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Iniciar app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      routes: {
        '/auth/login_page': (context) => const LoginPage(),
        '/auth/register_page': (context) => const RegisterPage(),
        '/home': (context) => const MainScreen(),
      },
    );
  }
}
