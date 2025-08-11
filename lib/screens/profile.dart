import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import 'package:running_movil/auth/login_page.dart';
import 'package:running_movil/screens/edit_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<String?> _getUserProfileImageUrl(String uid) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('profile_images/$uid.jpg');
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      // Puede ser que no exista imagen, o problema de permisos
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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

            // Foto de perfil con FutureBuilder
            FutureBuilder<String?>(
              future: user != null ? _getUserProfileImageUrl(user.uid) : Future.value(null),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.grey,
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                } else {
                  final imageUrl = snapshot.data;
                  return ZoomIn(
                    duration: const Duration(milliseconds: 800),
                    child: CircleAvatar(
                      radius: 65,
                      backgroundImage: imageUrl != null
                          ? NetworkImage(imageUrl)
                          : const AssetImage('assets/images/running_logo.png') as ImageProvider,
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 20),

            FadeInDown(
              delay: const Duration(milliseconds: 300),
              child: Text(
                user?.displayName ?? 'Nombre no disponible',
                style: const TextStyle(
                  fontSize: 24,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 5),

            FadeInDown(
              delay: const Duration(milliseconds: 450),
              child: Text(
                user?.email ?? 'Correo no disponible',
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 30),

            if (user != null)
              SlideInUp(
                delay: const Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _buildStats(user.uid),
                ),
              ),

            const SizedBox(height: 30),

            FadeInUp(
              delay: const Duration(milliseconds: 700),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildOption(Icons.settings, 'Configuración', () {
                      // Aquí puedes agregar la funcionalidad de configuración
                    }),
                    _buildOption(Icons.help_outline, 'Ayuda y soporte', () {
                      // Aquí puedes agregar la funcionalidad de ayuda
                    }),
                    _buildOption(Icons.logout, 'Cerrar sesión', () async {
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    }, color: Colors.red),
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

  Widget _buildStats(String uid) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('sessions')
          .where('uid', isEqualTo: uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar estadísticas'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hay datos disponibles'));
        }

        final docs = snapshot.data!.docs;
        final recorridos = docs.length;
        double kilometros = 0;
        double calorias = 0;

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          kilometros += double.tryParse(data['distance'].toString()) ?? 0;
          calorias += double.tryParse(data['calories'].toString()) ?? 0;
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Recorridos', recorridos.toString()),
              _buildStatItem('Kilómetros', kilometros.toStringAsFixed(1)),
              _buildStatItem('Calorías', calorias.toStringAsFixed(0)),
            ],
          ),
        );
      },
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
