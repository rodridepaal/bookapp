// lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Inisialisasi timezone data
    tz.initializeTimeZones();

    // Inisialisasi setting Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    // Inisialisasi plugin
    await _notificationsPlugin.initialize(settings);
    print("DEBUG (Notif): NotificationService Initialized.");

    // Minta izin notifikasi di Android 13+
    _requestAndroidPermission();
  }

  static void _requestAndroidPermission() async {
    final plugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (plugin != null) {
      final bool? granted = await plugin.requestExactAlarmsPermission();
      print("DEBUG (Notif): Android Notification Permission Granted: $granted");
    }
  }

  // --- Fungsi Penjadwalan ---
  static Future<void> scheduleDailyReadingNotification() async {
    // 1. Tentukan detail notifikasi
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'daily_reading_channel_id', // ID Channel
      'Daily Reading Reminder', // Nama Channel
      channelDescription: 'Pengingat harian untuk membaca buku jam 8 malam',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    // 2. Tentukan waktu (Jam 8 malam / 20:00)
    final tz.TZDateTime scheduledTime = _nextInstanceOf8PM();
    print("DEBUG (Notif): Notifikasi dijadwalkan untuk: $scheduledTime");

    // 3. Jadwalkan!
    await _notificationsPlugin.zonedSchedule(
      0, // ID notifikasi (unik)
      'Waktunya Membaca Buku!', // Judul
      'Jangan lupa pengingat harianmu buat baca buku 📚', // Isi
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Ulangi setiap hari
    );
    print('DEBUG (Notif): Notifikasi harian jam 8 malam berhasil dijadwalkan.');
  }

  // Fungsi untuk menampilkan notifikasi tes segera (dipanggil dari UI)
  static Future<void> showTestNotificationNow() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_channel_id',
      'Test Notifications',
      channelDescription: 'Channel for test notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      999, // id unik untuk notifikasi tes
      'Notifikasi Tes',
      'Ini adalah notifikasi tes yang dikirim sekarang.',
      notificationDetails,
    );
    print('DEBUG (Notif): Test notification shown.');
  }

  // Helper buat ngitung jam 8 malam (20:00) berikutnya
  static tz.TZDateTime _nextInstanceOf8PM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      16, // Jam 20 (8 malam)
      11, // Menit 00
    );

    // Jika jam 8 malam hari ini udah lewat, jadwalkan untuk besok
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Fungsi untuk membatalkan notifikasi (opsional)
  static Future<void> cancelDailyNotification() async {
    await _notificationsPlugin.cancel(0);
    print('DEBUG (Notif): Notifikasi dibatalkan.');
  }

  // Fungsi untuk membatalkan semua notifikasi (opsional)
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    print('DEBUG (Notif): Semua notifikasi dibatalkan.');
  }
}