import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:running_movil/screens/activity_detail.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  // Convierte duración de string a minutos en double para sumar
  double parseDurationToMinutes(String duration) {
    // Si duración es solo número (ejemplo "35")
    if (RegExp(r'^\d+(\.\d+)?$').hasMatch(duration)) {
      return double.tryParse(duration) ?? 0;
    }

    // Si viene en formato HH:mm:ss o mm:ss
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

  Future<void> _addTestSession(User user) async {
    try {
      await FirebaseFirestore.instance.collection('sessions').add({
        'uid': user.uid,
        'date': DateTime.now(),
        'duration': '00:35:00', // En formato HH:mm:ss
        'distance': 4.5,
        'calories': 280,
        'pace': '7:45 min/km',
        'heartRate': 118,
        'route': [
          {'lat': 19.4326, 'lng': -99.1332},
          {'lat': 19.4330, 'lng': -99.1340},
          {'lat': 19.4335, 'lng': -99.1350},
        ],
      });
      debugPrint('Sesión agregada correctamente');
    } catch (e) {
      debugPrint('Error al agregar sesión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = authSnapshot.data;

        if (user == null) {
          return const Scaffold(body: Center(child: Text("No has iniciado sesión.")));
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Actividad',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                fontSize: 25,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.blueAccent),
                tooltip: 'Agregar sesión de prueba',
                onPressed: () => _addTestSession(user),
              ),
            ],
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('sessions')
                .where('uid', isEqualTo: user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No hay sesiones registradas aún."));
              }

              final sessions = snapshot.data!.docs;

              // Ordenar por fecha descendente
              sessions.sort((a, b) {
                final aDate = (a['date'] as Timestamp).toDate();
                final bDate = (b['date'] as Timestamp).toDate();
                return bDate.compareTo(aDate);
              });

              // Sumar duración y distancia
              double totalDuration = 0;
              double totalDistance = 0;

              for (var doc in sessions) {
                final data = doc.data() as Map<String, dynamic>;
                totalDuration += parseDurationToMinutes(data['duration'].toString());
                totalDistance += double.tryParse(data['distance'].toString()) ?? 0;
              }

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                children: [
                  const SizedBox(height: 10),
                  _buildSummaryCard(totalDuration, sessions.length, totalDistance),
                  const SizedBox(height: 25),
                  ...sessions.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final Timestamp ts = data['date'];
                    final dt = ts.toDate();
                    final formattedDate = '${dt.day}/${dt.month}/${dt.year}';

                    return _buildSessionCard(
                      context,
                      date: formattedDate,
                      duration: data['duration'].toString(),
                      distance: data['distance'].toString(),
                      fullData: data,
                      docId: doc.id,
                    );
                  }).toList(),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(double totalDuration, int sessionCount, double totalDistance) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryBox(totalDuration.toStringAsFixed(1), 'Duración (min)'),
          _buildDivider(),
          _buildSummaryBox(sessionCount.toString(), 'Sesiones'),
          _buildDivider(),
          _buildSummaryBox(totalDistance.toStringAsFixed(1), 'Km'),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(horizontal: 10),
    );
  }

  Widget _buildSummaryBox(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontStyle: FontStyle.italic,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(
    BuildContext context, {
    required String date,
    required String duration,
    required String distance,
    required Map<String, dynamic> fullData,
    required String docId,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ActivityDetailPage(
            date: date,
            duration: duration,
            distance: distance,
            sessionData: fullData,
            docId: docId,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 30, color: Colors.blue),
                const SizedBox(width: 6),
                Text(duration, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 20),
                const Icon(Icons.place_outlined, size: 30, color: Colors.blue),
                const SizedBox(width: 6),
                Text('$distance km', style: const TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}