// lib/services/notification_service.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/scan_result.dart';
import '../models/app_settings.dart';
import 'storage_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _requestPermissions();
      await _initializeNotifications();
      _isInitialized = true;
      print('تم تهيئة خدمة الإشعارات بنجاح');
    } catch (e) {
      print('خطأ في تهيئة خدمة الإشعارات: $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }
  }

  Future<void> _initializeNotifications() async {
    if (Platform.isAndroid) {
      await _initializeAndroidNotifications();
    } else if (Platform.isLinux) {
      await _initializeLinuxNotifications();
    } else if (Platform.isWindows) {
      await _initializeWindowsNotifications();
    }
  }

  Future<void> _initializeAndroidNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // إنشاء قناة الإشعارات
    await _createNotificationChannel();
  }

  Future<void> _initializeLinuxNotifications() async {
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(
      defaultActionName: 'Open notification',
      defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(linux: initializationSettingsLinux);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _initializeWindowsNotifications() async {
    // إعداد إشعارات Windows إذا كانت متاحة
    try {
      // يمكن إضافة إعدادات خاصة بـ Windows هنا
      print('تهيئة إشعارات Windows');
    } catch (e) {
      print('خطأ في تهيئة إشعارات Windows: $e');
    }
  }

  Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'virus_scanner_channel',
        'VirusTotal Scanner',
        description: 'إشعارات فحص الفيروسات والروابط المشبوهة',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  // إرسال إشعار للتهديدات
  Future<void> showThreatNotification(ScanResult result) async {
    final settings = await StorageService().getSettings();
    
    // التحقق من إعدادات الإشعارات
    if (settings.notificationLevel == NotificationLevel.none) return;
    
    if (settings.notificationLevel == NotificationLevel.threatsOnly &&
        result.threatLevel == ThreatLevel.safe) return;

    String title = _getThreatTitle(result);
    String body = _getThreatBody(result);

    await _showNotification(
      title: title,
      body: body,
      payload: result.url,
      importance: _getImportanceLevel(result),
    );

    // اهتزاز إضافي للتهديدات الخطيرة
    if (result.threatLevel == ThreatLevel.high && settings.enableVibration) {
      await _vibrate();
    }
  }

  // إرسال إشعار عام
  Future<void> showGeneralNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _showNotification(
      title: title,
      body: body,
      payload: payload,
      importance: Importance.defaultImportance,
    );
  }

  Future<void> _showNotification({
    required String title,
    required String body,
    String? payload,
    required Importance importance,
  }) async {
    if (!_isInitialized) {
      print('خدمة الإشعارات غير مُهيأة');
      return;
    }

    try {
      if (Platform.isAndroid) {
        await _showAndroidNotification(title, body, payload, importance);
      } else if (Platform.isLinux) {
        await _showLinuxNotification(title, body, payload, importance);
      } else {
        await _showFallbackNotification(title, body);
      }
    } catch (e) {
      print('خطأ في إرسال الإشعار: $e');
    }
  }

  Future<void> _showAndroidNotification(
    String title,
    String body,
    String? payload,
    Importance importance,
  ) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'virus_scanner_channel',
      'VirusTotal Scanner',
      channelDescription: 'إشعارات فحص الفيروسات',
      importance: importance,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      ticker: title,
    );

    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> _showLinuxNotification(
    String title,
    String body,
    String? payload,
    Importance importance,
  ) async {
    LinuxNotificationUrgency urgency;
    switch (importance) {
      case Importance.high:
      case Importance.max:
        urgency = LinuxNotificationUrgency.critical;
        break;
      case Importance.defaultImportance:
        urgency = LinuxNotificationUrgency.normal;
        break;
      default:
        urgency = LinuxNotificationUrgency.low;
    }

    final LinuxNotificationDetails linuxDetails = LinuxNotificationDetails(
      urgency: urgency,
      category: LinuxNotificationCategory.security,
      timeout: LinuxNotificationTimeout.fromSeconds(10),
    );

    final NotificationDetails notificationDetails =
        NotificationDetails(linux: linuxDetails);

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> _showFallbackNotification(String title, String body) async {
    // إشعار احتياطي للمنصات غير المدعومة
    print('إشعار: $title - $body');
  }

  // اهتزاز الجهاز
  Future<void> _vibrate() async {
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      print('خطأ في الاهتزاز: $e');
    }
  }

  String _getThreatTitle(ScanResult result) {
    switch (result.threatLevel) {
      case ThreatLevel.high:
        return '🚨 تهديد خطير اكتُشف!';
      case ThreatLevel.medium:
        return '⚠️ رابط مشبوه!';
      case ThreatLevel.safe:
        return '✅ رابط آمن';
    }
  }

  String _getThreatBody(ScanResult result) {
    String domain = Uri.tryParse(result.url)?.host ?? result.url;
    
    switch (result.threatLevel) {
      case ThreatLevel.high:
        return 'الرابط: $domain\n'
            'محركات ضارة: ${result.malicious}\n'
            'تجنب زيارة هذا الرابط!';
      case ThreatLevel.medium:
        return 'الرابط: $domain\n'
            'محركات مشبوهة: ${result.suspicious}\n'
            'توخ الحذر عند زيارة هذا الرابط';
      case ThreatLevel.safe:
        return 'الرابط: $domain\n'
            'آمن للزيارة';
    }
  }

  Importance _getImportanceLevel(ScanResult result) {
    switch (result.threatLevel) {
      case ThreatLevel.high:
        return Importance.max;
      case ThreatLevel.medium:
        return Importance.high;
      case ThreatLevel.safe:
        return Importance.defaultImportance;
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('تم النقر على الإشعار: ${response.payload}');
    // يمكن إضافة منطق للتعامل مع النقر على الإشعار
  }

  // إيقاف إشعار محدد
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}ف جميع الإشعارات
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // إيقا