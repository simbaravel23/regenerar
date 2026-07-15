import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  // Agendar alerta recorrente de água (De 2 em 2 horas)
  static Future<void> scheduleWaterAlert(bool active) async {
    const int waterNotificationId = 999;
    if (!active) {
      await _notificationsPlugin.cancel(waterNotificationId);
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'water_channel',
      'Lembrete de Água',
      channelDescription: 'Canal para lembrar de beber água periodicamente',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    // Agenda uma repetição periódica a cada 2 horas
    await _notificationsPlugin.periodicallyShow(
      waterNotificationId,
      'Hora de hidratar! 💧',
      'Beba um copo d\'água para manter sua meta de hoje.',
      RepeatInterval.everyTwoHours,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Agendar alerta diário em um horário específico (ex: 09:00 para treino e 20:00 para meditação)
  static Future<void> scheduleDailyAlert({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required bool active,
  }) async {
    if (!active) {
      await _notificationsPlugin.cancel(id);
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_channel',
      'Lembretes Diários',
      channelDescription: 'Canal de lembretes diários de saúde',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    // Calcula o próximo horário em que o alarme deve tocar
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repetir todos os dias nesse horário
    );
  }
}