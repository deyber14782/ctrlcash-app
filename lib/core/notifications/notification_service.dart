import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const int _dailyReminderId = 1001;

  static const _keyReminderEnabled = 'reminder_enabled';
  static const _keyReminderHour = 'reminder_hour';
  static const _keyReminderMinute = 'reminder_minute';

  Future<void> init() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Bogota'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(initSettings);
  }

  Future<bool> requestPermission() async {
    final androidImpl =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl == null) return false;
    final granted = await androidImpl.requestNotificationsPermission();
    return granted ?? false;
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await _plugin.zonedSchedule(
      _dailyReminderId,
      'CtrlCash',
      '¿Ya registraste tus gastos de hoy?',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Recordatorio diario',
          channelDescription: 'Recordatorio para registrar tus gastos',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(_dailyReminderId);
  }

  // ---- Preferencia del recordatorio ----

  Future<bool> isReminderEnabled() async {
    return (await _storage.read(key: _keyReminderEnabled)) == 'true';
  }

  Future<({int hour, int minute})> getReminderTime() async {
    final h = await _storage.read(key: _keyReminderHour);
    final m = await _storage.read(key: _keyReminderMinute);
    return (
      hour: int.tryParse(h ?? '20') ?? 20,
      minute: int.tryParse(m ?? '0') ?? 0,
    );
  }

  Future<void> enableReminder({required int hour, required int minute}) async {
    await _storage.write(key: _keyReminderEnabled, value: 'true');
    await _storage.write(key: _keyReminderHour, value: hour.toString());
    await _storage.write(key: _keyReminderMinute, value: minute.toString());
    await scheduleDailyReminder(hour: hour, minute: minute);
  }

  Future<void> disableReminder() async {
    await _storage.write(key: _keyReminderEnabled, value: 'false');
    await cancelDailyReminder();
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> showTestNow() async {
    await _plugin.show(
      9999,
      'CtrlCash',
      'Las notificaciones funcionan',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test',
          'Prueba',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}