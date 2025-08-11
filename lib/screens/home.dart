import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import 'package:running_movil/screens/exercise.dart';

// Función para convertir duración String a minutos en double
double parseDurationToMinutes(String duration) {
  // Si es número directo (ej: "35" o "35.5")
  if (RegExp(r'^\d+(\.\d+)?$').hasMatch(duration)) {
    return double.tryParse(duration) ?? 0;
  }

  // Si tiene formato HH:mm:ss o mm:ss
  final parts = duration.split(':').map((e) => int.tryParse(e) ?? 0).toList();

  if (parts.length == 3) {
    // HH:mm:ss
    return parts[0] * 60 + parts[1] + parts[2] / 60;
  } else if (parts.length == 2) {
    // mm:ss
    return parts[0] + parts[1] / 60;
  }

  return 0;
}

// Función para convertir distancia String (puede tener coma) a double
double parseDistance(String distance) {
  final normalized = distance.replaceAll(',', '.');
  return double.tryParse(normalized) ?? 0;
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset('assets/images/running_logo.png', height: 40),
            const SizedBox(width: 10),
            const Text(
              'Running',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 800),
            child: Container(
              padding: const EdgeInsets.all(52),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade500, Colors.lightBlue.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Hola, Atleta!',
                          style: TextStyle(
                            fontSize: 25,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Sigue corriendo, ¡vas increíble! 💪🏽',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 17,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset('assets/images/running_logo.png', height: 85),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          if (user != null)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('sessions')
                  .where('uid', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                double totalMinutes = 0;
                double totalKm = 0;
                Set<String> uniqueDays = {};

                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  totalMinutes += parseDurationToMinutes(data['duration'].toString());
                  totalKm += parseDistance(data['distance'].toString());

                  if (data['date'] is Timestamp) {
                    final dt = (data['date'] as Timestamp).toDate();
                    uniqueDays.add('${dt.year}-${dt.month}-${dt.day}');
                  }
                }

                return ZoomIn(
                  duration: const Duration(milliseconds: 700),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black12)],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _progressCircle('Días', uniqueDays.length, 7),
                        _progressCircle('Min', totalMinutes.toInt(), 1000),
                        _progressCircle('Km', totalKm.toInt(), 10000),
                      ],
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 25),

          SlideInLeft(
            duration: const Duration(milliseconds: 600),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExercisePage()),
                );
              },
              child: Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🏃‍♂️ Running Records!',
                              style: TextStyle(
                                fontSize: 25,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/ruta.png',
                          height: 105,
                          width: 105,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),

          FadeInUp(
            duration: const Duration(milliseconds: 700),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '“No se trata de ser el mejor, sino de ser mejor que ayer.” 🌟',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _progressCircle(String label, int current, int total) {
    final percent = (current / total).clamp(0.0, 1.0);
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 70,
              width: 70,
              child: CircularProgressIndicator(
                value: percent,
                strokeWidth: 7,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            Text(
              '$current',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
