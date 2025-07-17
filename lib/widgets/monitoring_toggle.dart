// lib/widgets/monitoring_toggle.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MonitoringToggle extends StatefulWidget {
  final bool isMonitoring;
  final VoidCallback onToggle;

  const MonitoringToggle({
    Key? key,
    required this.isMonitoring,
    required this.onToggle,
  }) : super(key: key);

  @override
  _MonitoringToggleState createState() => _MonitoringToggleState();
}

class _MonitoringToggleState extends State<MonitoringToggle>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _iconController;
  late Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _iconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _iconRotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    ));

    if (widget.isMonitoring) {
      _startPulseAnimation();
    }
  }

  @override
  void didUpdateWidget(MonitoringToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMonitoring != oldWidget.isMonitoring) {
      if (widget.isMonitoring) {
        _startPulseAnimation();
        _iconController.forward();
      } else {
        _stopPulseAnimation();
        _iconController.reverse();
      }
    }
  }

  void _startPulseAnimation() {
    if (mounted) {
      _pulseController.repeat(reverse: true);
    }
  }

  void _stopPulseAnimation() {
    if (mounted) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: widget.isMonitoring ? 6 : 4,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: widget.isMonitoring
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.successColor.withOpacity(0.1),
                    AppTheme.successColor.withOpacity(0.05),
                  ],
                )
              : null,
          border: widget.isMonitoring
              ? Border.all(
                  color: AppTheme.successColor.withOpacity(0.3),
                  width: 2,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(),
              AppTheme.smallVerticalSpace,
              _buildDescription(),
              AppTheme.mediumVerticalSpace,
              _buildToggleSection(),
              if (widget.isMonitoring) ...[
                AppTheme.smallVerticalSpace,
                _buildStatusIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            // إصلاح المشكلة: التأكد من أن القيمة صالحة
            final scale = widget.isMonitoring ? 
                (_pulseAnimation.value.isFinite ? _pulseAnimation.value : 1.0) : 1.0;
            
            return Transform.scale(
              scale: scale,
              child: AnimatedBuilder(
                animation: _iconRotation,
                builder: (context, child) {
                  // إصلاح المشكلة: التأكد من أن الزاوية صالحة
                  final angle = _iconRotation.value.isFinite ? 
                      _iconRotation.value * 0.1 : 0.0;
                  
                  return Transform.rotate(
                    angle: angle,
                    child: Icon(
                      widget.isMonitoring ? Icons.visibility : Icons.visibility_off,
                      color: widget.isMonitoring
                          ? AppTheme.successColor
                          : Colors.grey[600],
                      size: 28,
                    ),
                  );
                },
              ),
            );
          },
        ),
        AppTheme.mediumHorizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مراقبة الحافظة التلقائية',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.isMonitoring
                      ? AppTheme.successColor
                      : null,
                ),
              ),
              Text(
                widget.isMonitoring ? 'نشط' : 'متوقف',
                style: TextStyle(
                  color: widget.isMonitoring
                      ? AppTheme.successColor
                      : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.isMonitoring
          ? 'التطبيق يراقب الحافظة ويفحص أي رابط يتم نسخه تلقائياً. ستحصل على إشعار فوري إذا تم اكتشاف تهديد.'
          : 'قم بتفعيل المراقبة التلقائية للحافظة للحصول على حماية مستمرة من الروابط المشبوهة.',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Colors.grey[600],
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildToggleSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isMonitoring
            ? AppTheme.successColor.withOpacity(0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            widget.isMonitoring ? Icons.security : Icons.security_outlined,
            color: widget.isMonitoring
                ? AppTheme.successColor
                : Colors.grey[600],
          ),
          AppTheme.mediumHorizontalSpace,
          Expanded(
            child: Text(
              widget.isMonitoring
                  ? 'الحماية التلقائية مفعلة'
                  : 'تفعيل الحماية التلقائية',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: widget.isMonitoring
                    ? AppTheme.successColor
                    : Colors.grey[700],
              ),
            ),
          ),
          Switch(
            value: widget.isMonitoring,
            onChanged: (_) => widget.onToggle(),
            activeColor: AppTheme.successColor,
            activeTrackColor: AppTheme.successColor.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.successColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              // إصلاح المشكلة: التأكد من أن القيمة صالحة
              final opacity = _pulseAnimation.value.isFinite ? 
                  (_pulseAnimation.value * 0.5 + 0.5).clamp(0.0, 1.0) : 1.0;
              
              return Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(opacity),
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
          AppTheme.smallHorizontalSpace,
          const Text(
            'يراقب الحافظة الآن',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}