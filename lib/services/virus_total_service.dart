// lib/services/virus_total_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/scan_result.dart';
import '../utils/constants.dart';

class VirusTotalService {
  static final VirusTotalService _instance = VirusTotalService._internal();
  factory VirusTotalService() => _instance;
  VirusTotalService._internal();

  // فحص رابط باستخدام VirusTotal API
  Future<ScanResult?> scanUrl(String url) async {
    try {
      print('بدء فحص الرابط: $url');

      // إرسال الرابط للفحص
      final submitResponse = await _submitUrl(url);
      if (submitResponse == null) return null;

      // انتظار قصير لمعالجة الفحص
      await Future.delayed(Duration(seconds: 3));

      // الحصول على النتائج
      final analysisId = submitResponse['data']['id'];
      final results = await _getAnalysisResults(analysisId);
      
      if (results != null) {
        return _parseResults(url, results);
      }

      return null;
    } catch (e) {
      print('خطأ في فحص الرابط: $e');
      return null;
    }
  }

  // إرسال الرابط للفحص
  Future<Map<String, dynamic>?> _submitUrl(String url) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.virusTotalBaseUrl}/urls'),
        headers: {
          'X-Apikey': Constants.virusTotalApiKey,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'url=$url',
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('خطأ في إرسال الرابط: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('خطأ في الشبكة أثناء إرسال الرابط: $e');
      return null;
    }
  }

  // الحصول على نتائج التحليل
  Future<Map<String, dynamic>?> _getAnalysisResults(String analysisId) async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.virusTotalBaseUrl}/analyses/$analysisId'),
        headers: {'X-Apikey': Constants.virusTotalApiKey},
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('خطأ في الحصول على النتائج: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('خطأ في الشبكة أثناء الحصول على النتائج: $e');
      return null;
    }
  }

  // تحليل النتائج وإنشاء ScanResult
  ScanResult _parseResults(String url, Map<String, dynamic> data) {
    final attributes = data['data']['attributes'];
    final stats = attributes['stats'];
    final results = attributes['results'] ?? {};

    // استخراج أسماء التهديدات
    List<String> threatNames = [];
    results.forEach((engine, result) {
      if (result['category'] == 'malicious' && result['result'] != null) {
        threatNames.add('${result['result']} (${engine})');
      }
    });

    // إنشاء رابط التقرير الدائم
    String? permalink;
    if (data['data']['links'] != null && data['data']['links']['self'] != null) {
      String analysisUrl = data['data']['links']['self'];
      String analysisId = analysisUrl.split('/').last;
      permalink = 'https://www.virustotal.com/gui/url-analysis/$analysisId';
    }

    return ScanResult(
      url: url,
      timestamp: DateTime.now(),
      malicious: stats['malicious'] ?? 0,
      suspicious: stats['suspicious'] ?? 0,
      clean: stats['harmless'] ?? 0,
      undetected: stats['undetected'] ?? 0,
      timeout: stats['timeout'] ?? 0,
      fullData: data,
      status: _getStatusText(stats),
      permalink: permalink,
      threatNames: threatNames,
    );
  }

  // تحديد نص الحالة
  String _getStatusText(Map<String, dynamic> stats) {
    int malicious = stats['malicious'] ?? 0;
    int suspicious = stats['suspicious'] ?? 0;

    if (malicious > 0) {
      return 'ضار - تم اكتشاف $malicious محرك ضار';
    } else if (suspicious > 0) {
      return 'مشبوه - تم اكتشاف $suspicious محرك مشبوه';
    } else {
      return 'آمن - لم يتم اكتشاف أي تهديدات';
    }
  }

  // فحص معلومات الدومين
  Future<Map<String, dynamic>?> getDomainInfo(String domain) async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.virusTotalBaseUrl}/domains/$domain'),
        headers: {'X-Apikey': Constants.virusTotalApiKey},
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('خطأ في الحصول على معلومات الدومين: $e');
      return null;
    }
  }

  // فحص سمعة IP
  Future<Map<String, dynamic>?> getIpInfo(String ip) async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.virusTotalBaseUrl}/ip_addresses/$ip'),
        headers: {'X-Apikey': Constants.virusTotalApiKey},
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('خطأ في الحصول على معلومات IP: $e');
      return null;
    }
  }

  // التحقق من صحة مفتاح API
  Future<bool> validateApiKey() async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.virusTotalBaseUrl}/users/${Constants.virusTotalApiKey}'),
        headers: {'X-Apikey': Constants.virusTotalApiKey},
      ).timeout(Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('خطأ في التحقق من مفتاح API: $e');
      return false;
    }
  }
}