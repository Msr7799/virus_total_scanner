// lib/screens/scan_history_screen.dart

import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/scan_result.dart';
import '../models/app_settings.dart';
import '../widgets/scan_result_card.dart';
import '../widgets/history_item_widget.dart';
import '../theme/app_theme.dart';
import '../utils/helpers.dart';

class ScanHistoryScreen extends StatefulWidget {
  @override
  _ScanHistoryScreenState createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  final StorageService _storageService = StorageService();
  final TextEditingController _searchController = TextEditingController();
  
  List<ScanResult> _allResults = [];
  List<ScanResult> _filteredResults = [];
  bool _showOnlyThreats = false;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadHistory();
    _searchController.addListener(_filterResults);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final settings = _storageService.getSettings();
      _allResults = _storageService.getScanHistory();
      _showOnlyThreats = settings.showOnlyThreats;
      _filterResults();
    } catch (e) {
      print('خطأ في تحميل السجل: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterResults() {
    setState(() {
      _filteredResults = _allResults.where((result) {
        final matchesSearch = _searchController.text.isEmpty ||
            result.url.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            result.status.toLowerCase().contains(_searchController.text.toLowerCase());
        
        final matchesThreatFilter = !_showOnlyThreats || 
            result.threatLevel != ThreatLevel.safe;
        
        return matchesSearch && matchesThreatFilter;
      }).toList();
    });
  }

  void _toggleThreatFilter() {
    setState(() {
      _showOnlyThreats = !_showOnlyThreats;
    });
    _filterResults();
  }

  Future<void> _clearHistory() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح السجل'),
        content: const Text('هل تريد مسح جميع نتائج الفحص؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _storageService.clearScanHistory();
              Navigator.pop(context);
              await _loadHistory();
            },
            style: AppTheme.dangerButtonStyle,
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportHistory() async {
    try {
      final data = await _storageService.exportScanHistory();
      // هنا يمكن إضافة منطق حفظ الملف
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تصدير البيانات بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في التصدير: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الفحص'),
        actions: [
          IconButton(
            icon: Icon(_showOnlyThreats ? Icons.filter_alt : Icons.filter_alt_off),
            onPressed: _toggleThreatFilter,
            tooltip: _showOnlyThreats ? 'عرض الكل' : 'التهديدات فقط',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _exportHistory();
                  break;
                case 'clear':
                  _clearHistory();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('تصدير البيانات'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('مسح السجل'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatistics(),
          Expanded(
            child: _buildHistoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'البحث في السجل...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    if (_allResults.isEmpty) return Container();

    final stats = _storageService.getScanStatistics();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('الكل', stats['total']!, Colors.blue),
          _buildStatItem('آمن', stats['safe']!, AppTheme.successColor),
          _buildStatItem('مشبوه', stats['suspicious']!, AppTheme.warningColor),
          _buildStatItem('ضار', stats['malicious']!, AppTheme.errorColor),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredResults.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        itemCount: _filteredResults.length,
        itemBuilder: (context, index) {
          final result = _filteredResults[index];
          return HistoryItemWidget(
            result: result,
            onTap: () => _showResultDetails(result),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchController.text.isNotEmpty ? Icons.search_off : Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          AppTheme.mediumVerticalSpace,
          Text(
            _searchController.text.isNotEmpty 
                ? 'لا توجد نتائج مطابقة للبحث'
                : 'لا توجد نتائج فحص بعد',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          AppTheme.smallVerticalSpace,
          Text(
            _searchController.text.isNotEmpty
                ? 'جرب البحث بكلمات مختلفة'
                : 'ابدأ بفحص رابط لرؤية النتائج هنا',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showResultDetails(ScanResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Helpers.getThreatIcon(result.threatLevel),
              color: Helpers.getThreatColor(result.threatLevel),
            ),
            AppTheme.smallHorizontalSpace,
            const Text('تفاصيل الفحص'),
          ],
        ),
        content: ScanResultCard(
          result: result,
          showDetails: true,
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
}