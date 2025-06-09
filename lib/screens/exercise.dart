import 'package:flutter/material.dart';
import 'package:recorrido_salud/screens/activity_detail.dart';

class ExercisePage extends StatelessWidget {
  const ExercisePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
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
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          const SizedBox(height: 10),
          _buildSummaryCard(),
          const SizedBox(height: 25),
          _buildSessionCard(
            context,
            date: '24 ABRIL 2025',
            duration: '35 min',
            distance: '1.8',
          ),
          _buildSessionCard(
            context,
            date: '16 ABRIL 2025',
            duration: '1.10 h',
            distance: '2.6',
          ),
          _buildSessionCard(
            context,
            date: '15 ABRIL 2025',
            duration: '1.15 h',
            distance: '2.3',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
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
          _buildSummaryBox('50.9', 'Duración'),
          _buildDivider(),
          _buildSummaryBox('40', 'Sesiones'),
          _buildDivider(),
          _buildSummaryBox('90.8', 'Km'),
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
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
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
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActivityDetailPage(
            date: date,
            duration: duration,
            distance: distance,
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
                Icon(Icons.access_time_rounded, size: 30, color: Colors.blue),
                const SizedBox(width: 6),
                Text(duration, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 20),
                Icon(Icons.place_outlined, size: 30, color: Colors.blue),
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
