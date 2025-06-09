import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:recorrido_salud/screens/edit_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            fontSize: 25,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // 🟢 Animación de entrada al avatar
            ZoomIn(
              duration: const Duration(milliseconds: 800),
              child: CircleAvatar(
                radius: 65,
                backgroundImage: const AssetImage('assets/images/running_logo.png'),
              ),
            ),

            const SizedBox(height: 20),

            FadeInDown(
              delay: const Duration(milliseconds: 300),
              child: const Text(
                'Eduardo Sánchez',
                style: TextStyle(
                  fontSize: 24,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 5),

            FadeInDown(
              delay: const Duration(milliseconds: 450),
              child: const Text(
                'eduardodelarosa188@email.com',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 🟡 Estadísticas
            SlideInUp(
              delay: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Recorridos', '42'),
                      _buildStatItem('Kilómetros', '238.7'),
                      _buildStatItem('Calorías', '13,500'),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 🔵 Menú de opciones
            FadeInUp(
              delay: const Duration(milliseconds: 700),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildOption(Icons.settings, 'Configuración', () {}),
                    _buildOption(Icons.help_outline, 'Ayuda y soporte', () {}),
                    _buildOption(Icons.logout, 'Cerrar sesión', () {}, color: Colors.red),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildOption(IconData icon, String text, VoidCallback onTap, {Color? color}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color ?? Colors.black),
          title: Text(
            text,
            style: TextStyle(
              color: color ?? Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}
