// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../widgets/url_input_widget.dart';
import '../widgets/monitoring_toggle.dart';
import '../widgets/scan_result_card.dart';
import '../services/clipboard_service.dart';
import '../services/virus_total_service.dart';
import '../services/storage_service.dart';
import '../models/scan_result.dart';
import '../models/app_settings.dart';
import '../theme/app_theme.dart';
import '../utils/helpers.dart';
import 'scan_history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ClipboardService _clipboardService = ClipboardService();
  final VirusTotalService _virusTotalService = VirusTotalService();
  final StorageService _storageService = StorageService();
  
  ScanResult? _currentScanResult;
  bool _isScanning = false;
  AppSettings _settings = AppSettings();
  List<ScanResult> _recentResults = [];
  
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
    _setupClipboardListener();
  }

  void _initializeControllers() {
    _scanAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  Future<void> _loadInitialData() async {
    try {
      _settings = _storageService.getSettings();
      _recentResults = _storageService.getScanHistory().take(5).toList();
      
      // بدء المراقبة تلقائياً إذا كانت مفعلة
      if (_settings.autoStartMonitoring) {
        await _clipboardService.startMonitoring();
      }
      
      setState(() {});
    } catch (e) {
      print('خطأ في تحميل البيانات الأولية: $e');
    }
  }

  void _setupClipboardListener() {
    _clipboardService.addScanCompleteCallback((result) {
      if (mounted) {
        setState(() {
          _recentResults.insert(0, result);
          if (_recentResults.length > 5) {
            _recentResults = _recentResults.sublist(0, 5);
          }
        });
        
        // تشغيل الرسوم المتحركة للنتيجة الجديدة
        _scanAnimationController.forward().then((_) {
          _scanAnimationController.reset();
        });
      }
    });
  }

  Future<void> _scanUrl(String url) async {
    if (url.isEmpty) {
      _showSnackBar('يرجى إدخال رابط للفحص', isError: true);
      return;
    }

    setState(() {
      _isScanning = true;
      _currentScanResult = null;
    });

    try {
      final result = await _virusTotalService.scanUrl(url);
      
      if (result != null) {
        await _storageService.addScanResult(result);
        
        setState(() {
          _currentScanResult = result;
          _recentResults.insert(0, result);
          if (_recentResults.length > 5) {
            _recentResults = _recentResults.sublist(0, 5);
          }
        });
        
        _scanAnimationController.forward().then((_) {
          _scanAnimationController.reset();
        });
        
        _showSnackBar('تم الفحص بنجاح');
      } else {
        _showSnackBar('فشل في فحص الرابط', isError: true);
      }
    } catch (e) {
      _showSnackBar('خطأ في الفحص: $e', isError: true);
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _toggleMonitoring() async {
    try {
      await _clipboardService.toggleMonitoring();
      _settings = _storageService.getSettings();
      setState(() {});
      
      final message = _clipboardService.isMonitoring 
          ? 'تم تفعيل مراقبة الحافظة' 
          : 'تم إيقاف مراقبة الحافظة';
      _showSnackBar(message);
    } catch (e) {
      _showSnackBar('خطأ في تغيير حالة المراقبة: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'إغلاق',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    _clipboardService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              AppTheme.mediumVerticalSpace,
              _buildUrlInputSection(),
              AppTheme.mediumVerticalSpace,
              _buildMonitoringSection(),
              AppTheme.mediumVerticalSpace,
              _buildCurrentResultSection(),
              AppTheme.mediumVerticalSpace,
              _buildRecentResultsSection(),
              AppTheme.mediumVerticalSpace,
              _buildQuickActionsSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Icon(Icons.security, size: 28),
          AppTheme.smallHorizontalSpace,
          const Text('VirusTotal Scanner'),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ScanHistoryScreen()),
            );
          },
          tooltip: 'سجل الفحص',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            ).then((_) => _loadInitialData());
          },
          tooltip: 'الإعدادات',
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.security,
            size: 60,
            color: Colors.white,
          ),
          AppTheme.smallVerticalSpace,
          Text(
            'فحص الروابط والحماية من التهديدات',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          AppTheme.smallVerticalSpace,
          Text(
            'مراقبة تلقائية • إشعارات فورية • تقارير مفصلة',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUrlInputSection() {
    return UrlInputWidget(
      onScan: _scanUrl,
      isScanning: _isScanning,
    );
  }

  Widget _buildMonitoringSection() {
    return MonitoringToggle(
      isMonitoring: _clipboardService.isMonitoring,
      onToggle: _toggleMonitoring,
    );
  }

  Widget _buildCurrentResultSection() {
    if (_currentScanResult == null && !_isScanning) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نتيجة الفحص الحالي',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        AppTheme.smallVerticalSpace,
        AnimatedBuilder(
          animation: _scanAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * _scanAnimation.value),
              child: Opacity(
                opacity: 0.5 + (0.5 * _scanAnimation.value),
                child: child,
              ),
            );
          },
          child: _isScanning
              ? _buildScanningIndicator()
              : ScanResultCard(
                  result: _currentScanResult!,
                  showDetails: true,
                ),
        ),
      ],
    );
  }

  Widget _buildScanningIndicator() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            AppTheme.mediumVerticalSpace,
            Text(
              'جاري فحص الرابط...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            AppTheme.smallVerticalSpace,
            Text(
              'يرجى الانتظار، قد يستغرق الفحص بضع ثوان',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentResultsSection() {
    if (_recentResults.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'النتائج الأخيرة',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScanHistoryScreen()),
                );
              },
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        AppTheme.smallVerticalSpace,
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentResults.length,
          itemBuilder: (context, index) {
            return ScanResultCard(
              result: _recentResults[index],
              showDetails: false,
              isCompact: true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إجراءات سريعة',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        AppTheme.smallVerticalSpace,
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildQuickActionCard(
              icon: Icons.content_paste,
              title: 'فحص الحافظة',
              subtitle: 'فحص الرابط المنسوخ',
              onTap: _scanClipboard,
            ),
            _buildQuickActionCard(
              icon: Icons.history,
              title: 'السجل',
              subtitle: 'عرض سجل الفحص',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScanHistoryScreen()),
                );
              },
            ),
            _buildQuickActionCard(
              icon: Icons.analytics,
              title: 'الإحصائيات',
              subtitle: 'عرض إحصائيات التهديدات',
              onTap: _showStatistics,
            ),
            _buildQuickActionCard(
              icon: Icons.settings,
              title: 'الإعدادات',
              subtitle: 'تخصيص التطبيق',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                ).then((_) => _loadInitialData());
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: AppTheme.primaryColor),
              AppTheme.smallVerticalSpace,
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _clipboardService.isMonitoring ? _toggleMonitoring : _toggleMonitoring,
      icon: Icon(_clipboardService.isMonitoring ? Icons.pause : Icons.play_arrow),
      label: Text(_clipboardService.isMonitoring ? 'إيقاف المراقبة' : 'بدء المراقبة'),
      backgroundColor: _clipboardService.isMonitoring 
          ? AppTheme.warningColor 
          : AppTheme.successColor,
    );
  }

  Future<void> _scanClipboard() async {
    try {
      final result = await _clipboardService.scanCurrentClipboard();
      if (result != null) {
        await _storageService.addScanResult(result);
        setState(() {
          _currentScanResult = result;
          _recentResults.insert(0, result);
          if (_recentResults.length > 5) {
            _recentResults = _recentResults.sublist(0, 5);
          }
        });
        _showSnackBar('تم فحص محتوى الحافظة');
      } else {
        _showSnackBar('لا يوجد رابط صالح في الحافظة', isError: true);
      }
    } catch (e) {
      _showSnackBar('خطأ في فحص الحافظة: $e', isError: true);
    }
  }

  void _showStatistics() {
    final stats = _storageService.getScanStatistics();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إحصائيات الفحص'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('إجمالي الفحوصات', '${stats['total']}'),
            _buildStatRow('روابط آمنة', '${stats['safe']}', AppTheme.successColor),
            _buildStatRow('روابط مشبوهة', '${stats['suspicious']}', AppTheme.warningColor),
            _buildStatRow('روابط ضارة', '${stats['malicious']}', AppTheme.errorColor),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}