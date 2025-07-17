// lib/utils/helpers.dart

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/scan_result.dart';
import 'constants.dart';

class Helpers {
  // تنسيق الوقت والتاريخ
  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
  }

  // تنسيق التاريخ فقط
  static String formatDate(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  // تنسيق الوقت فقط
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  // تقصير الرابط للعرض
  static String shortenUrl(String url, {int maxLength = 50}) {
    if (url.length <= maxLength) return url;
    
    try {
      final uri = Uri.parse(url);
      final domain = uri.host;
      final path = uri.path;
      
      if (domain.length + 10 > maxLength) {
        return '${domain.substring(0, maxLength - 3)}...';
      }
      
      final availableLength = maxLength - domain.length - 3;
      if (path.length > availableLength) {
        return '$domain...${path.substring(path.length - availableLength)}';
      }
      
      return url;
    } catch (e) {
      return url.length > maxLength 
          ? '${url.substring(0, maxLength - 3)}...'
          : url;
    }
  }

  // تحويل حجم الملف إلى نص مقروء
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // الحصول على لون حسب مستوى التهديد
  static Color getThreatColor(ThreatLevel level) {
    switch (level) {
      case ThreatLevel.high:
        return const Color(Constants.errorColor);
      case ThreatLevel.medium:
        return const Color(Constants.warningColor);
      case ThreatLevel.safe:
        return const Color(Constants.successColor);
    }
  }

  // الحصول على أيقونة حسب مستوى التهديد
  static IconData getThreatIcon(ThreatLevel level) {
    switch (level) {
      case ThreatLevel.high:
        return Icons.dangerous;
      case ThreatLevel.medium:
        return Icons.warning;
      case ThreatLevel.safe:
        return Icons.verified_user;
    }
  }

  // الحصول على نص وصفي لمستوى التهديد
  static String getThreatDescription(ThreatLevel level) {
    switch (level) {
      case ThreatLevel.high:
        return 'خطر عالي - تجنب زيارة هذا الرابط';
      case ThreatLevel.medium:
        return 'خطر متوسط - توخ الحذر';
      case ThreatLevel.safe:
        return 'آمن للزيارة';
    }
  }

  // إنشاء معرف فريد للإشعار
  static int generateNotificationId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  // نسخ النص إلى الحافظة
  static void copyToClipboard(BuildContext context, String text) {
    // سيتم تنفيذه في widget منفصل
  }

  // فتح الرابط في المتصفح
  static Future<void> openUrl(String url) async {
    // سيتم تنفيذه لاحقاً مع url_launcher
    print('فتح الرابط: $url');
  }

  // التحقق من نوع المنصة
  static bool isDesktop() {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  static bool isMobile() {
    return Platform.isAndroid || Platform.isIOS;
  }

  static String getPlatformName() {
    if (Platform.isAndroid) return Constants.platformAndroid;
    if (Platform.isIOS) return Constants.platformIOS;
    if (Platform.isLinux) return Constants.platformLinux;
    if (Platform.isWindows) return Constants.platformWindows;
    if (Platform.isMacOS) return Constants.platformMacOS;
    return 'unknown';
  }

  // تشغيل أوامر النظام (Linux KDE)
  static Future<bool> executeSystemCommand(String command, List<String> arguments) async {
    try {
      if (Platform.isLinux) {
        final result = await Process.run(command, arguments);
        return result.exitCode == 0;
      }
      return false;
    } catch (e) {
      print('خطأ في تشغيل الأمر: $e');
      return false;
    }
  }

  // إرسال إشعار KDE
  static Future<void> showKDENotification({
    required String title,
    required String message,
    String icon = Constants.kdeNotificationIcon,
    int timeout = 5000,
  }) async {
    if (!Platform.isLinux) return;
    
    try {
      await executeSystemCommand('kdialog', [
        '--title', title,
        '--passivepopup', message,
        '--icon', icon,
      ]);
    } catch (e) {
      print('خطأ في إرسال إشعار KDE: $e');
    }
  }

  // إنشاء ملف سطح المكتب لـ Linux
  static Future<bool> createDesktopEntry(String appPath) async {
    if (!Platform.isLinux) return false;
    
    try {
      final homeDir = Platform.environment['HOME'];
      if (homeDir == null) return false;
      
      final desktopPath = '$homeDir/.local/share/applications/${Constants.kdeDesktopEntry}';
      final desktopContent = '''
[Desktop Entry]
Name=${Constants.appName}
Comment=${Constants.appDescription}
Exec=$appPath
Icon=security-medium
Terminal=false
Type=Application
Categories=Security;Network;
StartupNotify=true
''';
      
      final file = File(desktopPath);
      await file.writeAsString(desktopContent);
      
      // جعل الملف قابل للتنفيذ
      await executeSystemCommand('chmod', ['+x', desktopPath]);
      
      return true;
    } catch (e) {
      print('خطأ في إنشاء ملف سطح المكتب: $e');
      return false;
    }
  }

  // تصدير البيانات إلى ملف JSON
  static Future<String?> exportToJson(Map<String, dynamic> data) async {
    try {
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      return jsonString;
    } catch (e) {
      print('خطأ في تصدير JSON: $e');
      return null;
    }
  }

  // استيراد البيانات من JSON
  static Map<String, dynamic>? importFromJson(String jsonString) {
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('خطأ في استيراد JSON: $e');
      return null;
    }
  }

  // حساب معدل التهديدات
  static double calculateThreatRate(List<ScanResult> results) {
    if (results.isEmpty) return 0.0;
    
    final threatCount = results.where((result) => 
        result.threatLevel != ThreatLevel.safe).length;
    
    return (threatCount / results.length) * 100;
  }

  // تجميع النتائج حسب التاريخ
  static Map<String, List<ScanResult>> groupResultsByDate(List<ScanResult> results) {
    final grouped = <String, List<ScanResult>>{};
    
    for (final result in results) {
      final dateKey = formatDate(result.timestamp);
      grouped[dateKey] = grouped[dateKey] ?? [];
      grouped[dateKey]!.add(result);
    }
    
    return grouped;
  }

  // تجميع النتائج حسب النطاق
  static Map<String, List<ScanResult>> groupResultsByDomain(List<ScanResult> results) {
    final grouped = <String, List<ScanResult>>{};
    
    for (final result in results) {
      try {
        final domain = Uri.parse(result.url).host;
        grouped[domain] = grouped[domain] ?? [];
        grouped[domain]!.add(result);
      } catch (e) {
        grouped['غير صحيح'] = grouped['غير صحيح'] ?? [];
        grouped['غير صحيح']!.add(result);
      }
    }
    
    return grouped;
  }

  // البحث في النتائج
  static List<ScanResult> searchResults(List<ScanResult> results, String query) {
    if (query.isEmpty) return results;
    
    final lowerQuery = query.toLowerCase();
    return results.where((result) {
      return result.url.toLowerCase().contains(lowerQuery) ||
             result.status.toLowerCase().contains(lowerQuery) ||
             result.threatNames.any((name) => 
                 name.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  // تصفية النتائج حسب مستوى التهديد
  static List<ScanResult> filterByThreatLevel(List<ScanResult> results, ThreatLevel level) {
    return results.where((result) => result.threatLevel == level).toList();
  }

  // تصفية النتائج حسب التاريخ
  static List<ScanResult> filterByDateRange(
    List<ScanResult> results, 
    DateTime startDate, 
    DateTime endDate
  ) {
    return results.where((result) => 
        result.timestamp.isAfter(startDate) && 
        result.timestamp.isBefore(endDate)).toList();
  }

  // إنشاء تقرير مفصل
  static Map<String, dynamic> generateReport(List<ScanResult> results) {
    final totalScans = results.length;
    final safeCount = results.where((r) => r.threatLevel == ThreatLevel.safe).length;
    final suspiciousCount = results.where((r) => r.threatLevel == ThreatLevel.medium).length;
    final maliciousCount = results.where((r) => r.threatLevel == ThreatLevel.high).length;
    
    final domains = <String, int>{};
    for (final result in results) {
      try {
        final domain = Uri.parse(result.url).host;
        domains[domain] = (domains[domain] ?? 0) + 1;
      } catch (e) {
        // تجاهل الروابط غير الصحيحة
      }
    }
    
    final topDomains = domains.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(10);
    
    return {
      'report_date': DateTime.now().toIso8601String(),
      'total_scans': totalScans,
      'safe_count': safeCount,
      'suspicious_count': suspiciousCount,
      'malicious_count': maliciousCount,
      'threat_rate': calculateThreatRate(results),
      'top_domains': Map.fromEntries(topDomains),
      'date_range': {
        'start': results.isNotEmpty ? results.last.timestamp.toIso8601String() : null,
        'end': results.isNotEmpty ? results.first.timestamp.toIso8601String() : null,
      },
    };
  }

  // تشغيل اختبار الشبكة
  static Future<bool> testNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // حساب الوقت المنقضي
  static String getElapsedTime(DateTime startTime) {
    final elapsed = DateTime.now().difference(startTime);
    
    if (elapsed.inSeconds < 60) {
      return '${elapsed.inSeconds} ثانية';
    } else if (elapsed.inMinutes < 60) {
      return '${elapsed.inMinutes} دقيقة';
    } else {
      return '${elapsed.inHours} ساعة و ${elapsed.inMinutes.remainder(60)} دقيقة';
    }
  }

  // إنشاء اسم ملف فريد
  static String generateUniqueFileName(String prefix, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_$timestamp.$extension';
  }

  // تنظيف وتطبيع النص
  static String cleanText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // التحقق من صحة التكوين
  static bool validateConfiguration() {
    // التحقق من مفتاح API
    if (Constants.virusTotalApiKey.isEmpty || Constants.virusTotalApiKey.length != 64) {
      return false;
    }
    
    // التحقق من إعدادات أخرى
    return true;
  }
}