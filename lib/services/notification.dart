// notification_service_awesome.dart
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationServiceAwesome {
  /// Inicializa la librería y los canales de notificación
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // Icono por defecto de la app, usa null para el icono de app
      [
        NotificationChannel(
          channelKey: 'run_channel',
          channelName: 'Running Notifications',
          channelDescription: 'Canal para notificaciones de running',
          importance: NotificationImportance.High,
          defaultColor: const Color(0xFF2196F3),
          ledColor: const Color(0xFF2196F3),
          channelShowBadge: true,
          playSound: true,
        )
      ],
    );
  }

  /// Mostrar notificación inmediata
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'run_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  /// Programar notificación para fecha futura
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'run_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar.fromDate(
        date: scheduledDate,
        preciseAlarm: true,
      ),
    );
  }

  /// Cancelar todas las notificaciones
  static Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  /// Cancelar notificación por id
  static Future<void> cancelNotificationById(int id) async {
    await AwesomeNotifications().cancel(id);
  }
}
