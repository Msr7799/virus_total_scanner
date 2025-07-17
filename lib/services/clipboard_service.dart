// lib/services/clipboard_service.dart

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:clipboard_watcher/clipboard_watcher.dart';
import '../utils/validators.dart';
import '../models/scan_result.dart';
import '../models/app_settings.dart'; // إضافة الاستيراد المفقود
import 'virus_total_service.dart';
import 'notification_service.dart';
import 'storage_service.dart';

class ClipboardService with ClipboardListener {
  static final ClipboardService _instance = ClipboardService._internal();
  factory ClipboardService() => _instance;
  ClipboardService._internal();

  Timer? _clipboardTimer;
  String? _lastClipboardContent;
  bool _isMonitoring = false;
  final List<Function(ScanResult)> _onScanCompleteCallbacks = [];

  // بدء مراقبة الحافظة
  Future<void> startMonitoring() async {
    if (_isMonitoring) return;

    try {
      _isMonitoring = true;
      
      // استخدام مراقب الحافظة المباشر
      clipboardWatcher.addListener(this);
      clipboardWatcher.start();
      
      // بدء مراقبة دورية كنسخة احتياطية
      _startPeriodicCheck();
      
      print('تم بدء مراقبة الحافظة');
      
      // حفظ حالة المراقبة
      final settings = StorageService().getSettings();
      await StorageService().saveSettings(
        settings.copyWith(isMonitoringEnabled: true)
      );
      
    } catch (e) {
      print('خطأ في بدء مراقبة الحافظة: $e');
    }
  }

  // إيقاف مراقبة الحافظة
  Future<void> stopMonitoring() async {
    if (!_isMonitoring) return;

    try {
      _isMonitoring = false;
      
      clipboardWatcher.removeListener(this);
      clipboardWatcher.stop();
      
      _clipboardTimer?.cancel();
      _clipboardTimer = null;
      
      print('تم إيقاف مراقبة الحافظة');
      
      // حفظ حالة المراقبة
      final settings = StorageService().getSettings();
      await StorageService().saveSettings(
        settings.copyWith(isMonitoringEnabled: false)
      );
      
    } catch (e) {
      print('خطأ في إيقاف مراقبة الحافظة: $e');
    }
  }

  // التبديل بين تشغيل وإيقاف المراقبة
  Future<void> toggleMonitoring() async {
    if (_isMonitoring) {
      await stopMonitoring();
    } else {
      await startMonitoring();
    }
  }

  // مراقبة دورية للحافظة (نسخة احتياطية)
  void _startPeriodicCheck() {
    _clipboardTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (!_isMonitoring) {
        timer.cancel();
        return;
      }
      
      await _checkClipboard();
    });
  }

  // فحص محتوى الحافظة
  Future<void> _checkClipboard() async {
    try {
      ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text != null) {
        String clipboardText = data!.text!.trim();
        await _processClipboardContent(clipboardText);
      }
    } catch (e) {
      print('خطأ في قراءة الحافظة: $e');
    }
  }

  // معالجة محتوى الحافظة الجديد
  Future<void> _processClipboardContent(String content) async {
    // تجنب المعالجة المتكررة لنفس المحتوى
    if (content == _lastClipboardContent || content.isEmpty) return;
    
    _lastClipboardContent = content;
    
    // فحص إذا كان المحتوى رابط صالح
    if (Validators.isValidUrl(content)) {
      print('تم اكتشاف رابط جديد: $content');
      await _scanUrlInBackground(content);
    }
  }

  // فحص الرابط في الخلفية
  Future<void> _scanUrlInBackground(String url) async {
    try {
      final settings = StorageService().getSettings();
      
      // تطبيق تأخير لتجنب الطلبات المتكررة
      await Future.delayed(Duration(seconds: settings.scanDelaySeconds));
      
      print('بدء فحص الرابط في الخلفية: $url');
      
      final result = await VirusTotalService().scanUrl(url);
      
      if (result != null) {
        // حفظ النتيجة في السجل
        await StorageService().addScanResult(result);
        
        // إرسال إشعار حسب الإعدادات
        await _handleScanResult(result);
        
        // إشعار المستمعين
        _notifyCallbacks(result);
        
        print('تم فحص الرابط: $url - النتيجة: ${result.status}');
      }
    } catch (e) {
      print('خطأ في فحص الرابط في الخلفية: $e');
    }
  }

  // التعامل مع نتيجة الفحص
  Future<void> _handleScanResult(ScanResult result) async {
    final settings = StorageService().getSettings();
    
    // إرسال إشعار حسب مستوى التهديد والإعدادات
    switch (settings.notificationLevel) {
      case NotificationLevel.all:
        await NotificationService().showThreatNotification(result);
        break;
      case NotificationLevel.threatsOnly:
        if (result.threatLevel != ThreatLevel.safe) {
          await NotificationService().showThreatNotification(result);
        }
        break;
      case NotificationLevel.none:
        // لا إشعارات
        break;
    }
  }

  // إضافة مستمع لنتائج الفحص
  void addScanCompleteCallback(Function(ScanResult) callback) {
    _onScanCompleteCallbacks.add(callback);
  }

  // إزالة مستمع
  void removeScanCompleteCallback(Function(ScanResult) callback) {
    _onScanCompleteCallbacks.remove(callback);
  }

  // إشعار جميع المستمعين
  void _notifyCallbacks(ScanResult result) {
    for (final callback in _onScanCompleteCallbacks) {
      try {
        callback(result);
      } catch (e) {
        print('خطأ في استدعاء callback: $e');
      }
    }
  }

  // تنفيذ ClipboardListener
  @override
  void onClipboardChanged() async {
    if (!_isMonitoring) return;
    await _checkClipboard();
  }

  // الحصول على حالة المراقبة
  bool get isMonitoring => _isMonitoring;

  // الحصول على آخر محتوى تم نسخه
  String? get lastClipboardContent => _lastClipboardContent;

  // فحص يدوي للحافظة الحالية
  Future<ScanResult?> scanCurrentClipboard() async {
    try {
      ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text != null) {
        String content = data!.text!.trim();
        if (Validators.isValidUrl(content)) {
          return await VirusTotalService().scanUrl(content);
        }
      }
      return null;
    } catch (e) {
      print('خطأ في فحص الحافظة الحالية: $e');
      return null;
    }
  }

  // تنظيف الموارد
  void dispose() {
    stopMonitoring();
    _onScanCompleteCallbacks.clear();
  }
}