import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ActivityDetailPage extends StatefulWidget {
  final String date;
  final String duration;
  final String distance;

  const ActivityDetailPage({
    super.key,
    required this.date,
    required this.duration,
    required this.distance,
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

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildInfoCard(),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(2, 4)),
                    ],
                  ),
                  height: 300,
                  child: FlutterMap(
                    options: MapOptions(
                      center: LatLng(19.43, -99.13),
                      zoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [
                              LatLng(19.431, -99.132),
                              LatLng(19.432, -99.131),
                              LatLng(19.433, -99.130),
                              LatLng(19.434, -99.129),
                            ],
                            strokeWidth: 4.5,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(3, 3),
          )
        ],
      ),
      child: Column(
        children: [
          _infoRow(Icons.calendar_today, 'Fecha', widget.date),
          const SizedBox(height: 10),
          _infoRow(Icons.timer, 'Duración', widget.duration),
          const SizedBox(height: 10),
          _infoRow(Icons.directions_run, 'Distancia', '${widget.distance} km'),
          const Divider(height: 30, color: Colors.grey),
          _infoRow(Icons.local_fire_department, 'Calorías quemadas', '310 kcal'),
          const SizedBox(height: 10),
          _infoRow(Icons.speed, 'Ritmo promedio', '6.5 min/km'),
          const SizedBox(height: 10),
          _infoRow(Icons.favorite, 'Frecuencia cardíaca', '135 bpm'),
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
            style: const TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic, 
              fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            ),
        ),
      ],
    );
  }
}

