// lib/widgets/history_item_widget.dart

import 'package:flutter/material.dart';
import '../models/scan_result.dart';
import '../theme/app_theme.dart';
import '../utils/helpers.dart';

class HistoryItemWidget extends StatelessWidget {
  final ScanResult result;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const HistoryItemWidget({
    Key? key,
    required this.result,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThreatIcon(),
              AppTheme.mediumHorizontalSpace,
              Expanded(
                child: _buildContent(context),
              ),
              _buildTimeStamp(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThreatIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: result.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Helpers.getThreatIcon(result.threatLevel),
        color: result.statusColor,
        size: 20,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Helpers.shortenUrl(result.url, maxLength: 60),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        AppTheme.smallVerticalSpace,
        _buildStatusChip(),
        AppTheme.smallVerticalSpace,
        _buildStats(),
      ],
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: result.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result.statusColor.withOpacity(0.3),
        ),
      ),
      child: Text(
        result.statusText,
        style: TextStyle(
          color: result.statusColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        if (result.malicious > 0) ...[
          _buildStatBadge('${result.malicious}', AppTheme.errorColor, 'ضار'),
          AppTheme.smallHorizontalSpace,
        ],
        if (result.suspicious > 0) ...[
          _buildStatBadge('${result.suspicious}', AppTheme.warningColor, 'مشبوه'),
          AppTheme.smallHorizontalSpace,
        ],
        if (result.clean > 0) ...[
          _buildStatBadge('${result.clean}', AppTheme.successColor, 'آمن'),
          AppTheme.smallHorizontalSpace,
        ],
      ],
    );
  }

  Widget _buildStatBadge(String count, Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count $label',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimeStamp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          Helpers.formatTime(result.timestamp),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          Helpers.formatDate(result.timestamp),
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}