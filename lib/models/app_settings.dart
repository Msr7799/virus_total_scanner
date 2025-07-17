// lib/models/app_settings.dart

enum NotificationLevel { all, threatsOnly, none }

class AppSettings {
  final bool autoStartMonitoring;
  final bool isMonitoringEnabled;
  final int scanDelaySeconds;
  final NotificationLevel notificationLevel;
  final bool enableSoundNotifications;
  final bool enableVibration;
  final int maxHistoryItems;
  final bool showOnlyThreats;
  final String theme;
  final String language;

  AppSettings({
    this.autoStartMonitoring = false,
    this.isMonitoringEnabled = false,
    this.scanDelaySeconds = 2,
    this.notificationLevel = NotificationLevel.threatsOnly,
    this.enableSoundNotifications = true,
    this.enableVibration = true,
    this.maxHistoryItems = 100,
    this.showOnlyThreats = false,
    this.theme = 'system',
    this.language = 'ar',
  });

  // تحويل إلى JSON للتخزين
  Map<String, dynamic> toJson() {
    return {
      'autoStartMonitoring': autoStartMonitoring,
      'isMonitoringEnabled': isMonitoringEnabled,
      'scanDelaySeconds': scanDelaySeconds,
      'notificationLevel': notificationLevel.index,
      'enableSoundNotifications': enableSoundNotifications,
      'enableVibration': enableVibration,
      'maxHistoryItems': maxHistoryItems,
      'showOnlyThreats': showOnlyThreats,
      'theme': theme,
      'language': language,
    };
  }

  // إنشاء من JSON
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      autoStartMonitoring: json['autoStartMonitoring'] ?? false,
      isMonitoringEnabled: json['isMonitoringEnabled'] ?? false,
      scanDelaySeconds: json['scanDelaySeconds'] ?? 2,
      notificationLevel: NotificationLevel.values[json['notificationLevel'] ?? 1],
      enableSoundNotifications: json['enableSoundNotifications'] ?? true,
      enableVibration: json['enableVibration'] ?? true,
      maxHistoryItems: json['maxHistoryItems'] ?? 100,
      showOnlyThreats: json['showOnlyThreats'] ?? false,
      theme: json['theme'] ?? 'system',
      language: json['language'] ?? 'ar',
    );
  }

  // نسخة محدثة من الإعدادات
  AppSettings copyWith({
    bool? autoStartMonitoring,
    bool? isMonitoringEnabled,
    int? scanDelaySeconds,
    NotificationLevel? notificationLevel,
    bool? enableSoundNotifications,
    bool? enableVibration,
    int? maxHistoryItems,
    bool? showOnlyThreats,
    String? theme,
    String? language,
  }) {
    return AppSettings(
      autoStartMonitoring: autoStartMonitoring ?? this.autoStartMonitoring,
      isMonitoringEnabled: isMonitoringEnabled ?? this.isMonitoringEnabled,
      scanDelaySeconds: scanDelaySeconds ?? this.scanDelaySeconds,
      notificationLevel: notificationLevel ?? this.notificationLevel,
      enableSoundNotifications: enableSoundNotifications ?? this.enableSoundNotifications,
      enableVibration: enableVibration ?? this.enableVibration,
      maxHistoryItems: maxHistoryItems ?? this.maxHistoryItems,
      showOnlyThreats: showOnlyThreats ?? this.showOnlyThreats,
      theme: theme ?? this.theme,
      language: language ?? this.language,
    );
  }

  @override
  String toString() {
    return 'AppSettings(autoStartMonitoring: $autoStartMonitoring, notificationLevel: $notificationLevel)';
  }
}