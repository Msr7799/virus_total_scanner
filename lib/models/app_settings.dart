// lib/models/app_settings.dart

class AppSettings {
  final bool isMonitoringEnabled;
  final bool showOnlyThreats;
  final bool enableSoundNotifications;
  final bool enableVibration;
  final int scanDelaySeconds;
  final int maxHistoryItems;
  final bool autoStartMonitoring;
  final NotificationLevel notificationLevel;

  AppSettings({
    this.isMonitoringEnabled = false,
    this.showOnlyThreats = false,
    this.enableSoundNotifications = true,
    this.enableVibration = true,
    this.scanDelaySeconds = 2,
    this.maxHistoryItems = 100,
    this.autoStartMonitoring = false,
    this.notificationLevel = NotificationLevel.threatsOnly,
  });

  Map<String, dynamic> toJson() {
    return {
      'isMonitoringEnabled': isMonitoringEnabled,
      'showOnlyThreats': showOnlyThreats,
      'enableSoundNotifications': enableSoundNotifications,
      'enableVibration': enableVibration,
      'scanDelaySeconds': scanDelaySeconds,
      'maxHistoryItems': maxHistoryItems,
      'autoStartMonitoring': autoStartMonitoring,
      'notificationLevel': notificationLevel.index,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isMonitoringEnabled: json['isMonitoringEnabled'] ?? false,
      showOnlyThreats: json['showOnlyThreats'] ?? false,
      enableSoundNotifications: json['enableSoundNotifications'] ?? true,
      enableVibration: json['enableVibration'] ?? true,
      scanDelaySeconds: json['scanDelaySeconds'] ?? 2,
      maxHistoryItems: json['maxHistoryItems'] ?? 100,
      autoStartMonitoring: json['autoStartMonitoring'] ?? false,
      notificationLevel: NotificationLevel.values[json['notificationLevel'] ?? 0],
    );
  }

  AppSettings copyWith({
    bool? isMonitoringEnabled,
    bool? showOnlyThreats,
    bool? enableSoundNotifications,
    bool? enableVibration,
    int? scanDelaySeconds,
    int? maxHistoryItems,
    bool? autoStartMonitoring,
    NotificationLevel? notificationLevel,
  }) {
    return AppSettings(
      isMonitoringEnabled: isMonitoringEnabled ?? this.isMonitoringEnabled,
      showOnlyThreats: showOnlyThreats ?? this.showOnlyThreats,
      enableSoundNotifications: enableSoundNotifications ?? this.enableSoundNotifications,
      enableVibration: enableVibration ?? this.enableVibration,
      scanDelaySeconds: scanDelaySeconds ?? this.scanDelaySeconds,
      maxHistoryItems: maxHistoryItems ?? this.maxHistoryItems,
      autoStartMonitoring: autoStartMonitoring ?? this.autoStartMonitoring,
      notificationLevel: notificationLevel ?? this.notificationLevel,
    );
  }
}

enum NotificationLevel {
  all,        // جميع النتائج
  threatsOnly, // التهديدات فقط
  none,       // بدون إشعارات
}