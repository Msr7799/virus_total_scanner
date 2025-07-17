// lib/models/scan_result.dart

import 'package:flutter/material.dart';

enum ThreatLevel { safe, medium, high }

class ScanResult {
  final String url;
  final DateTime timestamp;
  final int malicious;
  final int suspicious;
  final int clean;
  final int undetected;
  final int timeout;
  final Map<String, dynamic> fullData;
  final String status;
  final String? permalink;
  final List<String> threatNames;

  ScanResult({
    required this.url,
    required this.timestamp,
    required this.malicious,
    required this.suspicious,
    required this.clean,
    required this.undetected,
    this.timeout = 0,
    required this.fullData,
    required this.status,
    this.permalink,
    this.threatNames = const [],
  });

  // تحديد مستوى الخطر
  ThreatLevel get threatLevel {
    if (malicious > 0) return ThreatLevel.high;
    if (suspicious > 0) return ThreatLevel.medium;
    return ThreatLevel.safe;
  }

  // تحديد لون النتيجة
  Color get statusColor {
    switch (threatLevel) {
      case ThreatLevel.high:
        return Colors.red;
      case ThreatLevel.medium:
        return Colors.orange;
      case ThreatLevel.safe:
        return Colors.green;
    }
  }

  // نص حالة النتيجة
  String get statusText {
    switch (threatLevel) {
      case ThreatLevel.high:
        return 'ضار - خطر عالي';
      case ThreatLevel.medium:
        return 'مشبوه - خطر متوسط';
      case ThreatLevel.safe:
        return 'آمن';
    }
  }

  // تحويل إلى JSON للتخزين
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'timestamp': timestamp.toIso8601String(),
      'malicious': malicious,
      'suspicious': suspicious,
      'clean': clean,
      'undetected': undetected,
      'timeout': timeout,
      'status': status,
      'permalink': permalink,
      'threatNames': threatNames,
      'fullData': fullData,
    };
  }

  // إنشاء من JSON
  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      url: json['url'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      malicious: json['malicious'] ?? 0,
      suspicious: json['suspicious'] ?? 0,
      clean: json['clean'] ?? 0,
      undetected: json['undetected'] ?? 0,
      timeout: json['timeout'] ?? 0,
      status: json['status'] ?? '',
      permalink: json['permalink'],
      threatNames: List<String>.from(json['threatNames'] ?? []),
      fullData: json['fullData'] ?? {},
    );
  }

  // نسخة محدثة من النتيجة
  ScanResult copyWith({
    String? url,
    DateTime? timestamp,
    int? malicious,
    int? suspicious,
    int? clean,
    int? undetected,
    int? timeout,
    Map<String, dynamic>? fullData,
    String? status,
    String? permalink,
    List<String>? threatNames,
  }) {
    return ScanResult(
      url: url ?? this.url,
      timestamp: timestamp ?? this.timestamp,
      malicious: malicious ?? this.malicious,
      suspicious: suspicious ?? this.suspicious,
      clean: clean ?? this.clean,
      undetected: undetected ?? this.undetected,
      timeout: timeout ?? this.timeout,
      fullData: fullData ?? this.fullData,
      status: status ?? this.status,
      permalink: permalink ?? this.permalink,
      threatNames: threatNames ?? this.threatNames,
    );
  }
}