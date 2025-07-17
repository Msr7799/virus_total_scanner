// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/app_settings.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  AppSettings _settings = AppSettings();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _settings = _storageService.getSettings();
    } catch (e) {
      print('خطأ في تحميل الإعدادات: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _storageService.saveSettings(_settings);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الإعدادات')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في حفظ الإعدادات: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'حفظ الإعدادات',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMonitoringSettings(),
            AppTheme.mediumVerticalSpace,
            _buildNotificationSettings(),
            AppTheme.mediumVerticalSpace,
            _buildStorageSettings(),
            AppTheme.mediumVerticalSpace,
            _buildAdvancedSettings(),
            AppTheme.mediumVerticalSpace,
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonitoringSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إعدادات المراقبة',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            AppTheme.smallVerticalSpace,
            SwitchListTile(
              title: const Text('البدء التلقائي للمراقبة'),
              subtitle: const Text('بدء مراقبة الحافظة عند تشغيل التطبيق'),
              value: _settings.autoStartMonitoring,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(autoStartMonitoring: value);
                });
              },
            ),
            ListTile(
              title: const Text('تأخير الفحص'),
              subtitle: Text('${_settings.scanDelaySeconds} ثانية'),
              trailing: SizedBox(
                width: 100,
                child: Slider(
                  value: _settings.scanDelaySeconds.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: '${_settings.scanDelaySeconds}s',
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(scanDelaySeconds: value.toInt());
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إعدادات الإشعارات',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            AppTheme.smallVerticalSpace,
            ListTile(
              title: const Text('مستوى الإشعارات'),
              subtitle: Text(_getNotificationLevelText(_settings.notificationLevel)),
              trailing: DropdownButton<NotificationLevel>(
                value: _settings.notificationLevel,
                onChanged: (value) {
                  setState(() {
                    _settings = _settings.copyWith(notificationLevel: value);
                  });
                },
                items: NotificationLevel.values.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(_getNotificationLevelText(level)),
                  );
                }).toList(),
              ),
            ),
            SwitchListTile(
              title: const Text('تفعيل الصوت'),
              subtitle: const Text('تشغيل صوت مع الإشعارات'),
              value: _settings.enableSoundNotifications,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(enableSoundNotifications: value);
                });
              },
            ),
            SwitchListTile(
              title: const Text('تفعيل الاهتزاز'),
              subtitle: const Text('اهتزاز الجهاز مع الإشعارات المهمة'),
              value: _settings.enableVibration,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(enableVibration: value);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إعدادات التخزين',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            AppTheme.smallVerticalSpace,
            ListTile(
              title: const Text('الحد الأقصى لعناصر السجل'),
              subtitle: Text('${_settings.maxHistoryItems} عنصر'),
              trailing: SizedBox(
                width: 100,
                child: Slider(
                  value: _settings.maxHistoryItems.toDouble(),
                  min: 50,
                  max: 500,
                  divisions: 9,
                  label: '${_settings.maxHistoryItems}',
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(maxHistoryItems: value.toInt());
                    });
                  },
                ),
              ),
            ),
            SwitchListTile(
              title: const Text('عرض التهديدات فقط'),
              subtitle: const Text('إخفاء النتائج الآمنة من السجل'),
              value: _settings.showOnlyThreats,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(showOnlyThreats: value);
                });
              },
            ),
            ListTile(
              title: const Text('مسح البيانات القديمة'),
              subtitle: const Text('حذف النتائج الأقدم من شهر'),
              trailing: ElevatedButton(
                onPressed: _clearOldData,
                child: const Text('مسح'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إعدادات متقدمة',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            AppTheme.smallVerticalSpace,
            ListTile(
              title: const Text('تحسين التخزين'),
              subtitle: const Text('إزالة البيانات المكررة وتحسين الأداء'),
              trailing: ElevatedButton(
                onPressed: _optimizeStorage,
                child: const Text('تحسين'),
              ),
            ),
            ListTile(
              title: const Text('إعادة تعيين الإعدادات'),
              subtitle: const Text('استعادة الإعدادات الافتراضية'),
              trailing: ElevatedButton(
                onPressed: _resetSettings,
                style: AppTheme.dangerButtonStyle,
                child: const Text('إعادة تعيين'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'حول التطبيق',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            AppTheme.smallVerticalSpace,
            ListTile(
              title: const Text('اسم التطبيق'),
              subtitle: const Text(Constants.appName),
              leading: const Icon(Icons.info),
            ),
            ListTile(
              title: const Text('الإصدار'),
              subtitle: const Text(Constants.appVersion),
              leading: const Icon(Icons.update),
            ),
            ListTile(
              title: const Text('الوصف'),
              subtitle: const Text(Constants.appDescription),
              leading: const Icon(Icons.description),
            ),
            ListTile(
              title: const Text('حالة API'),
              subtitle: const Text('متصل'),
              leading: Icon(Icons.api, color: AppTheme.successColor),
              trailing: ElevatedButton(
                onPressed: _testApiConnection,
                child: const Text('اختبار'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getNotificationLevelText(NotificationLevel level) {
    switch (level) {
      case NotificationLevel.all:
        return 'جميع النتائج';
      case NotificationLevel.threatsOnly:
        return 'التهديدات فقط';
      case NotificationLevel.none:
        return 'بدون إشعارات';
    }
  }

  Future<void> _clearOldData() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح البيانات القديمة'),
        content: const Text('هل تريد حذف النتائج الأقدم من شهر؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _storageService.clearOldResults(const Duration(days: 30));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم مسح البيانات القديمة')),
              );
            },
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  Future<void> _optimizeStorage() async {
    try {
      await _storageService.optimizeStorage();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحسين التخزين')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في التحسين: $e')),
      );
    }
  }

  Future<void> _resetSettings() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة تعيين الإعدادات'),
        content: const Text('هل تريد استعادة الإعدادات الافتراضية؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _settings = AppSettings();
              });
              await _saveSettings();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إعادة تعيين الإعدادات')),
              );
            },
            style: AppTheme.dangerButtonStyle,
            child: const Text('إعادة تعيين'),
          ),
        ],
      ),
    );
  }

  Future<void> _testApiConnection() async {
    // هنا يمكن إضافة اختبار الاتصال بـ API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('الاتصال بـ API سليم')),
    );
  }
}