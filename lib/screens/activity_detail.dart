import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ActivityDetailPage extends StatefulWidget {
  final String date;
  final String duration;
  final String distance;
  final Map<String, dynamic> sessionData;
  final String docId;  // <-- ID del documento Firestore

  const ActivityDetailPage({
    super.key,
    required this.date,
    required this.duration,
    required this.distance,
    required this.sessionData,
    required this.docId, // <-- Recibimos el docId
  });

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _deleteSession() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar sesión'),
        content: const Text('¿Estás seguro que deseas eliminar esta sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('sessions').doc(widget.docId).delete();
        if (mounted) {
          Navigator.of(context).pop(true); // Regresa y notifica que eliminó
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar sesión: $e')),
        );
      }
    }
  }

  String formatDurationFromMinutes(String durationStr) {
    int totalMinutes = int.tryParse(durationStr) ?? 0;
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    int seconds = 0; // no hay segundos disponibles, ponemos 0

    if (hours > 0) {
      return '${hours.toString().padLeft(2,'0')}:${minutes.toString().padLeft(2,'0')}:${seconds.toString().padLeft(2,'0')}';
    } else {
      return '${minutes.toString().padLeft(2,'0')}:${seconds.toString().padLeft(2,'0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionData = widget.sessionData;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Detalle de Actividad',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Eliminar sesión',
            onPressed: _deleteSession,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildInfoCard(sessionData),
              const SizedBox(height: 24),
              const Text(
                'Ruta del recorrido',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              _buildMap(sessionData),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> data) {
    final calories = data['calories']?.toString() ?? '0';
    final pace = data['pace']?.toString() ?? 'N/A';
    final heartRate = data['heartRate']?.toString() ?? '0';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(3, 3))],
      ),
      child: Column(
        children: [
          _infoRow(Icons.calendar_today, 'Fecha', widget.date),
          const SizedBox(height: 10),
          _infoRow(Icons.timer, 'Duración', formatDurationFromMinutes(widget.duration)),
          const SizedBox(height: 10),
          _infoRow(Icons.directions_run, 'Distancia', '${widget.distance} km'),
          const Divider(height: 30, color: Colors.grey),
          _infoRow(Icons.local_fire_department, 'Calorías quemadas', '$calories kcal'),
          const SizedBox(height: 10),
          _infoRow(Icons.speed, 'Ritmo promedio', pace),
          const SizedBox(height: 10),
          _infoRow(Icons.favorite, 'Frecuencia cardíaca', '$heartRate bpm'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Colors.blue),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$label:',
            style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildMap(Map<String, dynamic> data) {
    final route = data['route'] as List<dynamic>?;

    if (route == null || route.isEmpty) {
      return const Center(
        child: Text(
          'No hay datos de ruta disponibles.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    }

    final points = route.map((coord) {
      final lat = coord['lat'] ?? 0.0;
      final lng = coord['lng'] ?? 0.0;
      return LatLng(lat, lng);
    }).toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(2, 4))],
        ),
        height: 300,
        child: FlutterMap(
          options: MapOptions(
            // center: points.first,
            // zoom: 15,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: "com.example.running_movil",
            ),
            PolylineLayer(
              polylines: [
                Polyline(points: points, strokeWidth: 4.5, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
