// lib/utils/constants.dart

class Constants {
  // API Configuration
  static const String virusTotalApiKey = 'e1b8d9aa09db5b9207ea8d398329f62e1bf7515a5980aedb7240c0f6dbdcee81';
  static const String virusTotalBaseUrl = 'https://www.virustotal.com/api/v3';
  
  // App Information
  static const String appName = 'Advanced VirusTotal Scanner';
  static const String appVersion = '2.0.0';
  static const String appDescription = 'فحص الروابط والحماية من التهديدات';
  
  // API Limits
  static const int maxRequestsPerMinute = 4;
  static const int maxRequestsPerDay = 1000;
  static const int apiTimeoutSeconds = 30;
  
  // Storage Keys
  static const String settingsKey = 'app_settings';
  static const String scanHistoryKey = 'scan_history';
  static const String lastBackupKey = 'last_backup_date';
  
  // Default Settings
  static const int defaultScanDelay = 2;
  static const int defaultMaxHistoryItems = 100;
  static const int defaultNotificationTimeout = 10;
  
  // Clipboard Monitoring
  static const int clipboardCheckInterval = 1000; // milliseconds
  static const int duplicateContentTimeoutMinutes = 5;
  
  // File Paths
  static const String logFileName = 'scan_logs.txt';
  static const String backupFileName = 'backup_data.json';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 4.0;
  
  // Colors (Material Design 3)
  static const int primaryColor = 0xFF1976D2;
  static const int secondaryColor = 0xFF03DAC6;
  static const int errorColor = 0xFFB00020;
  static const int warningColor = 0xFFFF9800;
  static const int successColor = 0xFF4CAF50;
  
  // Threat Levels
  static const String threatHigh = 'high';
  static const String threatMedium = 'medium';
  static const String threatLow = 'low';
  static const String threatSafe = 'safe';
  
  // Notification Channels
  static const String notificationChannelId = 'virus_scanner_channel';
  static const String notificationChannelName = 'VirusTotal Scanner';
  static const String notificationChannelDescription = 'إشعارات فحص الفيروسات والتهديدات';
  
  // URLs and Links
  static const String virusTotalWebsite = 'https://www.virustotal.com';
  static const String apiDocumentationUrl = 'https://developers.virustotal.com/reference';
  static const String supportEmail = 'support@example.com';
  static const String privacyPolicyUrl = 'https://example.com/privacy';
  
  // Regular Expressions
  static const String urlRegexPattern = r'^https?:\/\/[^\s]+$';
  static const String domainRegexPattern = r'^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}$';
  static const String ipRegexPattern = r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$';
  
  // Error Messages
  static const String errorNetworkConnection = 'خطأ في الاتصال بالشبكة';
  static const String errorInvalidUrl = 'رابط غير صحيح';
  static const String errorApiLimit = 'تم تجاوز حد الطلبات المسموحة';
  static const String errorInvalidApiKey = 'مفتاح API غير صحيح';
  static const String errorUnknown = 'خطأ غير معروف';
  
  // Success Messages
  static const String successScanComplete = 'تم الفحص بنجاح';
  static const String successMonitoringStarted = 'تم بدء المراقبة';
  static const String successMonitoringStopped = 'تم إيقاف المراقبة';
  static const String successDataExported = 'تم تصدير البيانات';
  static const String successDataImported = 'تم استيراد البيانات';
  
  // File Extensions
  static const List<String> dangerousFileExtensions = [
    '.exe', '.bat', '.cmd', '.com', '.pif', '.scr', '.vbs', '.js',
    '.jar', '.app', '.deb', '.rpm', '.dmg', '.pkg'
  ];
  
  // Suspicious Keywords
  static const List<String> suspiciousKeywords = [
    'malware', 'virus', 'trojan', 'worm', 'rootkit', 'spyware',
    'adware', 'ransomware', 'backdoor', 'keylogger'
  ];
  
  // Platform Detection
  static const String platformAndroid = 'android';
  static const String platformIOS = 'ios';
  static const String platformLinux = 'linux';
  static const String platformWindows = 'windows';
  static const String platformMacOS = 'macos';
  static const String platformWeb = 'web';
  
  // KDE Integration (Linux)
  static const String kdeNotificationCommand = 'kdialog';
  static const String kdeNotificationIcon = 'security-medium';
  static const String kdeDesktopEntry = 'virus-total-scanner.desktop';
  
  // Browser Integration
  static const List<String> supportedBrowsers = [
    'firefox', 'chrome', 'chromium', 'brave', 'edge', 'safari'
  ];
  
  // Logging Levels
  static const String logLevelInfo = 'INFO';
  static const String logLevelWarning = 'WARNING';
  static const String logLevelError = 'ERROR';
  static const String logLevelDebug = 'DEBUG';
}