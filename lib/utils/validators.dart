// lib/utils/validators.dart

import 'constants.dart';

class Validators {
  // التحقق من صحة الرابط
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;
    
    try {
      final uri = Uri.parse(url.trim());
      return uri.hasScheme && 
             (uri.scheme == 'http' || uri.scheme == 'https') &&
             uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  // التحقق من صحة الرابط باستخدام RegEx
  static bool isValidUrlRegex(String url) {
    final regex = RegExp(Constants.urlRegexPattern);
    return regex.hasMatch(url.trim());
  }

  // التحقق من صحة النطاق (Domain)
  static bool isValidDomain(String domain) {
    if (domain.isEmpty) return false;
    
    final regex = RegExp(Constants.domainRegexPattern);
    return regex.hasMatch(domain.trim().toLowerCase());
  }

  // التحقق من صحة عنوان IP
  static bool isValidIP(String ip) {
    if (ip.isEmpty) return false;
    
    final regex = RegExp(Constants.ipRegexPattern);
    if (!regex.hasMatch(ip.trim())) return false;
    
    // التحقق من أن كل جزء في النطاق الصحيح (0-255)
    final parts = ip.split('.');
    for (final part in parts) {
      final value = int.tryParse(part);
      if (value == null || value < 0 || value > 255) return false;
    }
    
    return true;
  }

  // استخراج النطاق من الرابط
  static String? extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return null;
    }
  }

  // التحقق من وجود كلمات مشبوهة في الرابط
  static bool containsSuspiciousKeywords(String url) {
    final lowerUrl = url.toLowerCase();
    return Constants.suspiciousKeywords.any((keyword) => 
        lowerUrl.contains(keyword));
  }

  // التحقق من امتداد ملف خطير في الرابط
  static bool hasDangerousFileExtension(String url) {
    final lowerUrl = url.toLowerCase();
    return Constants.dangerousFileExtensions.any((extension) => 
        lowerUrl.endsWith(extension));
  }

  // التحقق من صحة مفتاح API
  static bool isValidApiKey(String apiKey) {
    // مفتاح VirusTotal يجب أن يكون 64 حرف hexadecimal
    if (apiKey.length != 64) return false;
    
    final regex = RegExp(r'^[a-fA-F0-9]{64}$');
    return regex.hasMatch(apiKey);
  }

  // تنظيف الرابط من المعاملات غير الضرورية
  static String cleanUrl(String url) {
    try {
      final uri = Uri.parse(url);
      // إزالة معاملات التتبع الشائعة
      final cleanQuery = <String, String>{};
      
      uri.queryParameters.forEach((key, value) {
        // الاحتفاظ بالمعاملات المهمة فقط
        if (!_isTrackingParameter(key)) {
          cleanQuery[key] = value;
        }
      });
      
      return uri.replace(queryParameters: cleanQuery.isEmpty ? null : cleanQuery).toString();
    } catch (e) {
      return url; // إرجاع الرابط الأصلي في حالة الخطأ
    }
  }

  // التحقق من كون المعامل معامل تتبع
  static bool _isTrackingParameter(String param) {
    const trackingParams = [
      'utm_source', 'utm_medium', 'utm_campaign', 'utm_term', 'utm_content',
      'fbclid', 'gclid', 'msclkid', 'ref', 'source', 'campaign_id',
      '_ga', '_gid', 'mc_cid', 'mc_eid', 'affiliate_id'
    ];
    
    return trackingParams.contains(param.toLowerCase());
  }

  // التحقق من كون الرابط رابط قصير
  static bool isShortUrl(String url) {
    const shortDomains = [
      'bit.ly', 'tinyurl.com', 'short.link', 'ow.ly', 'buff.ly',
      't.co', 'goo.gl', 'is.gd', 'v.gd', 'tiny.cc', 'lnkd.in'
    ];
    
    try {
      final domain = Uri.parse(url).host.toLowerCase();
      return shortDomains.contains(domain);
    } catch (e) {
      return false;
    }
  }

  // التحقق من كون الرابط محلي (localhost أو IP محلي)
  static bool isLocalUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();
      
      if (host == 'localhost' || host == '127.0.0.1') return true;
      
      // التحقق من شبكات IP المحلية
      if (isValidIP(host)) {
        final parts = host.split('.').map(int.parse).toList();
        // 192.168.x.x
        if (parts[0] == 192 && parts[1] == 168) return true;
        // 10.x.x.x
        if (parts[0] == 10) return true;
        // 172.16.x.x - 172.31.x.x
        if (parts[0] == 172 && parts[1] >= 16 && parts[1] <= 31) return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  // التحقق من صحة البريد الإلكتروني
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email.trim());
  }

  // التحقق من قوة كلمة المرور (إن وجدت في المستقبل)
  static bool isStrongPassword(String password) {
    if (password.length < 8) return false;
    
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    return hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters;
  }

  // تقييم مستوى خطر الرابط بناءً على خصائصه
  static RiskLevel assessUrlRisk(String url) {
    int riskScore = 0;
    
    // عوامل زيادة الخطر
    if (containsSuspiciousKeywords(url)) riskScore += 3;
    if (hasDangerousFileExtension(url)) riskScore += 2;
    if (isShortUrl(url)) riskScore += 1;
    if (!isValidUrl(url)) riskScore += 5;
    
    // التحقق من المنفذ غير القياسي
    try {
      final uri = Uri.parse(url);
      if (uri.hasPort && uri.port != 80 && uri.port != 443) {
        riskScore += 1;
      }
    } catch (e) {
      riskScore += 2;
    }
    
    // تقييم المستوى
    if (riskScore >= 5) return RiskLevel.high;
    if (riskScore >= 2) return RiskLevel.medium;
    return RiskLevel.low;
  }

  // استخراج معلومات الرابط
  static UrlInfo? parseUrlInfo(String url) {
    try {
      final uri = Uri.parse(url);
      return UrlInfo(
        originalUrl: url,
        scheme: uri.scheme,
        host: uri.host,
        port: uri.hasPort ? uri.port : (uri.scheme == 'https' ? 443 : 80),
        path: uri.path,
        query: uri.query,
        fragment: uri.fragment,
        isSecure: uri.scheme == 'https',
        isLocal: isLocalUrl(url),
        isShort: isShortUrl(url),
        riskLevel: assessUrlRisk(url),
      );
    } catch (e) {
      return null;
    }
  }

  // التحقق من صحة رقم المنفذ
  static bool isValidPort(int port) {
    return port >= 1 && port <= 65535;
  }

  // تطبيع الرابط
  static String normalizeUrl(String url) {
    try {
      final uri = Uri.parse(url.trim());
      
      // إضافة البروتوكول إذا كان مفقوداً
      if (!uri.hasScheme) {
        return 'https://$url';
      }
      
      // تحويل إلى أحرف صغيرة للمضيف
      return uri.replace(host: uri.host.toLowerCase()).toString();
    } catch (e) {
      return url;
    }
  }
}

// تعداد مستوى الخطر
enum RiskLevel { low, medium, high }

// فئة معلومات الرابط
class UrlInfo {
  final String originalUrl;
  final String scheme;
  final String host;
  final int port;
  final String path;
  final String query;
  final String fragment;
  final bool isSecure;
  final bool isLocal;
  final bool isShort;
  final RiskLevel riskLevel;

  UrlInfo({
    required this.originalUrl,
    required this.scheme,
    required this.host,
    required this.port,
    required this.path,
    required this.query,
    required this.fragment,
    required this.isSecure,
    required this.isLocal,
    required this.isShort,
    required this.riskLevel,
  });

  @override
  String toString() {
    return 'UrlInfo(host: $host, scheme: $scheme, isSecure: $isSecure, riskLevel: $riskLevel)';
  }
}