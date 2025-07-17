// lib/widgets/scan_result_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/scan_result.dart';
import '../theme/app_theme.dart';
import '../utils/helpers.dart';

class ScanResultCard extends StatelessWidget {
  final ScanResult result;
  final bool showDetails;
  final bool isCompact;
  final VoidCallback? onTap;

  const ScanResultCard({
    Key? key,
    required this.result,
    this.showDetails = false,
    this.isCompact = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactCard(context);
    }
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap ?? () => _showDetailDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: result.statusColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                AppTheme.mediumVerticalSpace,
                _buildResultSummary(context),
                if (showDetails) ...[
                  AppTheme.mediumVerticalSpace,
                  _buildDetailedStats(context),
                  AppTheme.mediumVerticalSpace,
                  _buildActionButtons(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: result.statusColor.withOpacity(0.1),
          child: Icon(
            result.threatLevel == ThreatLevel.high
                ? Icons.dangerous
                : result.threatLevel == ThreatLevel.medium
                    ? Icons.warning
                    : Icons.verified_user,
            color: result.statusColor,
            size: 20,
          ),
        ),
        title: Text(
          Helpers.shortenUrl(result.url, maxLength: 40),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${Helpers.formatDateTime(result.timestamp)} • ${result.statusText}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: _buildThreatBadge(),
        onTap: onTap ?? () => _showDetailDialog(context),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: result.statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            result.threatLevel == ThreatLevel.high
                ? Icons.dangerous
                : result.threatLevel == ThreatLevel.medium
                    ? Icons.warning
                    : Icons.verified_user,
            color: result.statusColor,
            size: 24,
          ),
        ),
        AppTheme.mediumHorizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Helpers.shortenUrl(result.url, maxLength: 50),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              AppTheme.smallVerticalSpace,
              Text(
                Helpers.formatDateTime(result.timestamp),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        _buildThreatBadge(),
      ],
    );
  }

  Widget _buildThreatBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: result.statusColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        result.threatLevel == ThreatLevel.high
            ? 'خطر'
            : result.threatLevel == ThreatLevel.medium
                ? 'مشبوه'
                : 'آمن',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildResultSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: result.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: result.statusColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security,
            color: result.statusColor,
            size: 20,
          ),
          AppTheme.smallHorizontalSpace,
          Expanded(
            child: Text(
              result.statusText,
              style: TextStyle(
                color: result.statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStats(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildStatRow('محركات ضارة', result.malicious, AppTheme.errorColor),
          _buildStatRow('محركات مشبوهة', result.suspicious, AppTheme.warningColor),
          _buildStatRow('محركات آمنة', result.clean, AppTheme.successColor),
          _buildStatRow('غير محددة', result.undetected, Colors.grey),
          if (result.timeout > 0)
            _buildStatRow('انتهت المهلة', result.timeout, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _copyToClipboard(context, result.url),
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('نسخ الرابط'),
          ),
        ),
        AppTheme.smallHorizontalSpace,
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _openUrl(result.url),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('فتح الرابط'),
          ),
        ),
        AppTheme.smallHorizontalSpace,
        OutlinedButton(
          onPressed: () => _showDetailDialog(context),
          child: const Icon(Icons.info_outline, size: 16),
        ),
      ],
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الرابط'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('خطأ في فتح الرابط: $e');
    }
  }

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              result.threatLevel == ThreatLevel.high
                  ? Icons.dangerous
                  : result.threatLevel == ThreatLevel.medium
                      ? Icons.warning
                      : Icons.verified_user,
              color: result.statusColor,
            ),
            AppTheme.smallHorizontalSpace,
            const Text('تفاصيل الفحص'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailSection('معلومات عامة', [
                  _buildDetailRow('الرابط', result.url),
                  _buildDetailRow('وقت الفحص', Helpers.formatDateTime(result.timestamp)),
                  _buildDetailRow('الحالة', result.statusText),
                ]),
                AppTheme.mediumVerticalSpace,
                _buildDetailSection('نتائج الفحص', [
                  _buildDetailRow('محركات ضارة', '${result.malicious}'),
                  _buildDetailRow('محركات مشبوهة', '${result.suspicious}'),
                  _buildDetailRow('محركات آمنة', '${result.clean}'),
                  _buildDetailRow('غير محددة', '${result.undetected}'),
                  if (result.timeout > 0)
                    _buildDetailRow('انتهت المهلة', '${result.timeout}'),
                ]),
                if (result.threatNames.isNotEmpty) ...[
                  AppTheme.mediumVerticalSpace,
                  _buildDetailSection('التهديدات المكتشفة', 
                    result.threatNames.map((name) => 
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '• $name',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.errorColor,
                          ),
                        ),
                      )
                    ).toList(),
                  ),
                ],
                if (result.permalink != null) ...[
                  AppTheme.mediumVerticalSpace,
                  _buildDetailSection('روابط إضافية', [
                    InkWell(
                      onTap: () => _openUrl(result.permalink!),
                      child: Text(
                        'عرض التقرير الكامل في VirusTotal',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ]),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _copyToClipboard(context, result.url);
            },
            child: const Text('نسخ الرابط'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppTheme.smallVerticalSpace,
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}