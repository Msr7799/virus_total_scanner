import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced VirusTotal Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: VirusTotalScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ScanResult {
  final String url;
  final DateTime timestamp;
  final int malicious;
  final int suspicious;
  final int clean;
  final int undetected;
  final Map<String, dynamic> fullData;
  final String status;

  ScanResult({
    required this.url,
    required this.timestamp,
    required this.malicious,
    required this.suspicious,
    required this.clean,
    required this.undetected,
    required this.fullData,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'timestamp': timestamp.toIso8601String(),
      'malicious': malicious,
      'suspicious': suspicious,
      'clean': clean,
      'undetected': undetected,
      'status': status,
      'fullData': fullData,
    };
  }

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      url: json['url'],
      timestamp: DateTime.parse(json['timestamp']),
      malicious: json['malicious'],
      suspicious: json['suspicious'],
      clean: json['clean'],
      undetected: json['undetected'],
      status: json['status'],
      fullData: json['fullData'],
    );
  }
}

class VirusTotalScreen extends StatefulWidget {
  @override
  _VirusTotalScreenState createState() => _VirusTotalScreenState();
}

class _VirusTotalScreenState extends State<VirusTotalScreen> with ClipboardListener {
  static const String API_KEY = 'e1b8d9aa09db5b9207ea8d398329f62e1bf7515a5980aedb7240c0f6dbdcee81';
  static const String BASE_URL = 'https://www.virustotal.com/api/v3';
  
  final TextEditingController _urlController = TextEditingController();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  bool _isScanning = false;
  bool _isMonitoring = false;
  bool _showOnlyThreats = false;
  Map<String, dynamic>? _scanResults;
  List<ScanResult> _scanHistory = [];
  String? _lastClipboardContent;
  Timer? _clipboardTimer;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _initializePreferences();
    await _initializeNotifications();
    await _requestPermissions();
    await _loadScanHistory();
    clipboardWatcher.addListener(this);
    _startPeriodicClipboardCheck();
  }

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _isMonitoring = _prefs?.getBool('is_monitoring') ?? false;
    _showOnlyThreats = _prefs?.getBool('show_only_threats') ?? false;
  }

  Future<void> _loadScanHistory() async {
    final historyJson = _prefs?.getStringList('scan_history') ?? [];
    _scanHistory = historyJson.map((json) => ScanResult.fromJson(jsonDecode(json))).toList();
    setState(() {});
  }

  Future<void> _saveScanHistory() async {
    final historyJson = _scanHistory.map((result) => jsonEncode(result.toJson())).toList();
    await _prefs?.setStringList('scan_history', historyJson);
  }

  void _startPeriodicClipboardCheck() {
    _clipboardTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (_isMonitoring) {
        try {
          ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
          if (data != null && data.text != null) {
            String clipboardText = data.text!.trim();
            
            if (clipboardText != _lastClipboardContent && _isValidUrl(clipboardText)) {
              _lastClipboardContent = clipboardText;
              await _scanUrlInBackground(clipboardText);
            }
          }
        } catch (e) {
          print('خطأ في قراءة الحافظة: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    clipboardWatcher.removeListener(this);
    _clipboardTimer?.cancel();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    if (Platform.isLinux) {
      // إعداد خاص بـ Linux KDE
      await _setupLinuxNotifications();
    } else if (Platform.isAndroid) {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    }
  }

  Future<void> _setupLinuxNotifications() async {
    // إعداد مخصص للإشعارات في Linux KDE
    try {
      const LinuxInitializationSettings initializationSettingsLinux =
          LinuxInitializationSettings(
        defaultActionName: 'Open notification',
        defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
      );
      
      const InitializationSettings initializationSettings =
          InitializationSettings(linux: initializationSettingsLinux);
      
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    } catch (e) {
      print('خطأ في إعداد الإشعارات لـ Linux: $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }
  }

  @override
  void onClipboardChanged() async {
    // هذه الدالة مخصصة للمراقبة المباشرة
    if (!_isMonitoring) return;
    
    try {
      ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data != null && data.text != null) {
        String clipboardText = data.text!.trim();
        
        if (clipboardText != _lastClipboardContent && _isValidUrl(clipboardText)) {
          _lastClipboardContent = clipboardText;
          await _scanUrlInBackground(clipboardText);
        }
      }
    } catch (e) {
      print('خطأ في قراءة الحافظة: $e');
    }
  }

  bool _isValidUrl(String text) {
    try {
      Uri uri = Uri.parse(text);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  Future<void> _scanUrlInBackground(String url) async {
    try {
      print('بدء فحص الرابط: $url');
      
      final results = await _scanUrl(url);
      
      if (results != null) {
        int maliciousCount = results['malicious'] ?? 0;
        int suspiciousCount = results['suspicious'] ?? 0;
        
        // إنشاء نتيجة الفحص
        final scanResult = ScanResult(
          url: url,
          timestamp: DateTime.now(),
          malicious: maliciousCount,
          suspicious: suspiciousCount,
          clean: results['clean'] ?? 0,
          undetected: results['undetected'] ?? 0,
          fullData: results['full_data'] ?? {},
          status: maliciousCount > 0 ? 'ضار' : 
                  suspiciousCount > 0 ? 'مشبوه' : 'آمن',
        );
        
        // حفظ النتيجة في السجل
        _scanHistory.insert(0, scanResult);
        if (_scanHistory.length > 100) {
          _scanHistory = _scanHistory.sublist(0, 100);
        }
        await _saveScanHistory();
        
        // تحديث الواجهة
        setState(() {});
        
        // إرسال إشعار فقط إذا كان الرابط مشبوه أو ضار
        if (maliciousCount > 0 || suspiciousCount > 0) {
          await _showThreatNotification(scanResult);
        }
        
        print('تم فحص الرابط: $url - النتيجة: ${scanResult.status}');
      }
    } catch (e) {
      print('خطأ في فحص الرابط في الخلفية: $e');
    }
  }

  Future<void> _showThreatNotification(ScanResult result) async {
    String title = result.malicious > 0 ? 
        '⚠️ تهديد خطير!' : 
        '⚠️ رابط مشبوه!';
    
    String body = 'الرابط: ${result.url}\n' +
        'محركات ضارة: ${result.malicious}\n' +
        'محركات مشبوهة: ${result.suspicious}';
    
    if (Platform.isLinux) {
      await _showLinuxNotification(title, body);
    } else if (Platform.isAndroid) {
      await _showAndroidNotification(title, body);
    }
  }

  Future<void> _showLinuxNotification(String title, String body) async {
    try {
      const LinuxNotificationDetails linuxPlatformChannelSpecifics =
          LinuxNotificationDetails(
        urgency: LinuxNotificationUrgency.critical,
        category: LinuxNotificationCategory.security,
        timeout: LinuxNotificationTimeout.fromSeconds(10),
      );
      
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(linux: linuxPlatformChannelSpecifics);
      
      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
      );
    } catch (e)

    // تهيئة الخدمات الأساسية
  await StorageService().initialize();
  await NotificationService().initialize();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced VirusTotal Scanner',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}