// lib/services/storage_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_result.dart';
import '../models/app_settings.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;
  List<ScanResult> _scanHistory = [];
  AppSettings _settings = AppSettings();

  // تهيئة خدمة التخزين
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
    await _loadScanHistory();
    print('تم تهيئة خدمة التخزين');
  }

  // حفظ وتحميل الإعدادات
  Future<void> _loadSettings() async {
    try {
      final settingsJson = _prefs?.getString('app_settings');
      if (settingsJson != null) {
        _settings = AppSettings.fromJson(jsonDecode(settingsJson));
      }
    } catch (e) {
      print('خطأ في تحميل الإعدادات: $e');
      _settings = AppSettings(); // إعدادات افتراضية
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    try {
      _settings = settings;
      await _prefs?.setString('app_settings', jsonEncode(settings.toJson()));
      print('تم حفظ الإعدادات');
    } catch (e) {
      print('خطأ في حفظ الإعدادات: $e');
    }
  }

  AppSettings getSettings() => _settings;

  // إدارة سجل الفحص
  Future<void> _loadScanHistory() async {
    try {
      final historyJson = _prefs?.getStringList('scan_history') ?? [];
      _scanHistory = historyJson
          .map((json) => ScanResult.fromJson(jsonDecode(json)))
          .toList();
      
      // ترتيب حسب الوقت (الأحدث أولاً)
      _scanHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      print('تم تحميل ${_scanHistory.length} نتيجة فحص من السجل');
    } catch (e) {
      print('خطأ في تحميل سجل الفحص: $e');
      _scanHistory = [];
    }
  }

  Future<void> _saveScanHistory() async {
    try {
      // الاحتفاظ بعدد محدود من النتائج
      final maxItems = _settings.maxHistoryItems;
      if (_scanHistory.length > maxItems) {
        _scanHistory = _scanHistory.sublist(0, maxItems);
      }

      final historyJson = _scanHistory
          .map((result) => jsonEncode(result.toJson()))
          .toList();
      
      await _prefs?.setStringList('scan_history', historyJson);
    } catch (e) {
      print('خطأ في حفظ سجل الفحص: $e');
    }
  }

  // إضافة نتيجة فحص جديدة
  Future<void> addScanResult(ScanResult result) async {
    // تجنب التكرار
    _scanHistory.removeWhere((existing) => 
        existing.url == result.url && 
        existing.timestamp.difference(result.timestamp).abs().inMinutes < 5);
    
    _scanHistory.insert(0, result);
    await _saveScanHistory();
    print('تمت إضافة نتيجة فحص جديدة: ${result.url}');
  }

  // الحصول على سجل الفحص
  List<ScanResult> getScanHistory({bool threatsOnly = false}) {
    if (threatsOnly) {
      return _scanHistory.where((result) => 
          result.threatLevel != ThreatLevel.safe).toList();
    }
    return List.from(_scanHistory);
  }

  // البحث في سجل الفحص
  List<ScanResult> searchScanHistory(String query) {
    if (query.isEmpty) return getScanHistory();
    
    final lowerQuery = query.toLowerCase();
    return _scanHistory.where((result) =>
        result.url.toLowerCase().contains(lowerQuery) ||
        result.status.toLowerCase().contains(lowerQuery) ||
        result.threatNames.any((name) => 
            name.toLowerCase().contains(lowerQuery))
    ).toList();
  }

  // الحصول على إحصائيات الفحص
  Map<String, int> getScanStatistics() {
    final stats = {
      'total': _scanHistory.length,
      'safe': 0,
      'suspicious': 0,
      'malicious': 0,
    };

    for (final result in _scanHistory) {
      switch (result.threatLevel) {
        case ThreatLevel.safe:
          stats['safe'] = stats['safe']! + 1;
          break;
        case ThreatLevel.medium:
          stats['suspicious'] = stats['suspicious']! + 1;
          break;
        case ThreatLevel.high:
          stats['malicious'] = stats['malicious']! + 1;
          break;
      }
    }

    return stats;
  }

  // حذف نتيجة فحص محددة
  Future<void> deleteScanResult(ScanResult result) async {
    _scanHistory.removeWhere((item) => 
        item.url == result.url && 
        item.timestamp == result.timestamp);
    await _saveScanHistory();
  }

  // مسح كامل لسجل الفحص
  Future<void> clearScanHistory() async {
    _scanHistory.clear();
    await _prefs?.remove('scan_history');
    print('تم مسح سجل الفحص');
  }

  // مسح النتائج الآمنة فقط
  Future<void> clearSafeResults() async {
    _scanHistory.removeWhere((result) => 
        result.threatLevel == ThreatLevel.safe);
    await _saveScanHistory();
    print('تم مسح النتائج الآمنة');
  }

  // مسح النتائج القديمة
  Future<void> clearOldResults(Duration maxAge) async {
    final cutoffDate = DateTime.now().subtract(maxAge);
    _scanHistory.removeWhere((result) => 
        result.timestamp.isBefore(cutoffDate));
    await _saveScanHistory();
    print('تم مسح النتائج القديمة');
  }

  // تصدير البيانات
  Future<String> exportScanHistory() async {
    try {
      final exportData = {
        'export_date': DateTime.now().toIso8601String(),
        'app_version': '1.0.0',
        'settings': _settings.toJson(),
        'scan_history': _scanHistory.map((r) => r.toJson()).toList(),
        'statistics': getScanStatistics(),
      };
      
      return jsonEncode(exportData);
    } catch (e) {
      print('خطأ في تصدير البيانات: $e');
      return '';
    }
  }

  // استيراد البيانات
  Future<bool> importScanHistory(String jsonData) async {
    try {
      final data = jsonDecode(jsonData);
      
      if (data['scan_history'] != null) {
        final importedResults = (data['scan_history'] as List)
            .map((json) => ScanResult.fromJson(json))
            .toList();
        
        _scanHistory.addAll(importedResults);
        
        // إزالة التكرار
        final uniqueResults = <String, ScanResult>{};
        for (final result in _scanHistory) {
          final key = '${result.url}_${result.timestamp.millisecondsSinceEpoch}';
          uniqueResults[key] = result;
        }
        
        _scanHistory = uniqueResults.values.toList();
        _scanHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        await _saveScanHistory();
        
        print('تم استيراد ${importedResults.length} نتيجة فحص');
        return true;
      }
      
      return false;
    } catch (e) {
      print('خطأ في استيراد البيانات: $e');
      return false;
    }
  }

  // الحصول على حجم البيانات المحفوظة
  Future<int> getStorageSize() async {
    try {
      final keys = _prefs?.getKeys() ?? {};
      int totalSize = 0;
      
      for (final key in keys) {
        final value = _prefs?.get(key);
        if (value is String) {
          totalSize += value.length * 2; // تقدير تقريبي
        }
      }
      
      return totalSize;
    } catch (e) {
      print('خطأ في حساب حجم التخزين: $e');
      return 0;
    }
  }

  // تحسين الأداء وتنظيف البيانات
  Future<void> optimizeStorage() async {
    // إزالة النتائج المتكررة
    final uniqueResults = <String, ScanResult>{};
    for (final result in _scanHistory) {
      final key = result.url;
      if (!uniqueResults.containsKey(key) || 
          uniqueResults[key]!.timestamp.isBefore(result.timestamp)) {
        uniqueResults[key] = result;
      }
    }
    
    _scanHistory = uniqueResults.values.toList();
    _scanHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    // تطبيق الحد الأقصى للعناصر
    if (_scanHistory.length > _settings.maxHistoryItems) {
      _scanHistory = _scanHistory.sublist(0, _settings.maxHistoryItems);
    }
    
    await _saveScanHistory();
    print('تم تحسين وتنظيف البيانات المحفوظة');
  }
}