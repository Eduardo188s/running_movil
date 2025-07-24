import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:recorrido_salud/services/notification.dart';

class NotificationsListPage extends StatefulWidget {
  const NotificationsListPage({super.key});

  @override
  State<NotificationsListPage> createState() => _NotificationsListPageState();
}

class _NotificationsListPageState extends State<NotificationsListPage> {
  final NotificationService _notificationService = NotificationService();
  List<Map<String, dynamic>> _scheduledNotifications = [];

  @override
  void initState() {
    super.initState();
    _loadScheduledNotifications();
  }

  Future<void> _loadScheduledNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString('scheduled_notifications');

    if (storedData != null) {
      setState(() {
        _scheduledNotifications = List<Map<String, dynamic>>.from(json.decode(storedData));
      });
    }
  }

  Future<void> _saveScheduledNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('scheduled_notifications', json.encode(_scheduledNotifications));
  }

  Future<void> _pickTimeAndSchedule() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      final scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      final int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await _notificationService.scheduleNotification(
        id: id,
        title: '¡Hora de correr! Ya estas bien panzón',
        body: 'Recuerda que programaste tu sesión a las ${pickedTime.format(context)} 🏃‍♂️',
        scheduledDate: scheduledDateTime,
      );

      _scheduledNotifications.add({
        'id': id,
        'hour': pickedTime.hour,
        'minute': pickedTime.minute,
      });

      await _saveScheduledNotifications();
      _loadScheduledNotifications();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notificación programada para las ${pickedTime.format(context)}',)),
      );
    }
  }

  Future<void> _cancelNotification(int id) async {
    await _notificationService.cancelNotification(id);
    _scheduledNotifications.removeWhere((item) => item['id'] == id);
    await _saveScheduledNotifications();
    _loadScheduledNotifications();
  }

  Future<void> _cancelAllNotifications() async {
    await _notificationService.cancelAll();
    _scheduledNotifications.clear();
    await _saveScheduledNotifications();
    _loadScheduledNotifications();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Todas las notificaciones canceladas')),
    );
  }

  String _formatTime(int hour, int minute) {
    final time = TimeOfDay(hour: hour, minute: minute);
    return time.format(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Agregar nueva notificación',
            onPressed: _pickTimeAndSchedule,
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Cancelar todas las notificaciones',
            onPressed: _cancelAllNotifications,
          )
        ],
      ),
      body: _scheduledNotifications.isEmpty
          ? const Center(
              child: Text(
                'No hay notificaciones programadas.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            )
          : ListView.builder(
              itemCount: _scheduledNotifications.length,
              itemBuilder: (context, index) {
                final notification = _scheduledNotifications[index];
                final time = _formatTime(notification['hour'], notification['minute']);

                return ListTile(
                  leading: const Icon(Icons.alarm, color: Colors.blue),
                  title: Text('Sesión programada a las $time'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _cancelNotification(notification['id']),
                  ),
                );
              },
            ),
    );
  }
}
