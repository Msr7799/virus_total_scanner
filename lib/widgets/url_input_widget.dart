// lib/widgets/url_input_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/validators.dart';
import '../theme/app_theme.dart';

class UrlInputWidget extends StatefulWidget {
  final Function(String) onScan;
  final bool isScanning;

  const UrlInputWidget({
    Key? key,
    required this.onScan,
    this.isScanning = false,
  }) : super(key: key);

  @override
  _UrlInputWidgetState createState() => _UrlInputWidgetState();
}

class _UrlInputWidgetState extends State<UrlInputWidget> {
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _errorText;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _urlController.addListener(_onUrlChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _urlController.removeListener(_onUrlChanged);
    _urlController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onUrlChanged() {
    setState(() {
      final url = _urlController.text.trim();
      
      if (url.isEmpty) {
        _errorText = null;
        _isValid = false;
      } else if (!Validators.isValidUrl(url)) {
        _errorText = 'يرجى إدخال رابط صحيح';
        _isValid = false;
      } else {
        _errorText = null;
        _isValid = true;
      }
    });
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _validateUrl();
    }
  }

  void _validateUrl() {
    final url = _urlController.text.trim();
    if (url.isNotEmpty && !Validators.isValidUrl(url)) {
      setState(() {
        _errorText = 'رابط غير صحيح';
      });
    }
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        _urlController.text = clipboardData!.text!.trim();
        _onUrlChanged();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في لصق النص: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _clearUrl() {
    _urlController.clear();
    _focusNode.requestFocus();
  }

  void _scanUrl() {
    if (_isValid && !widget.isScanning) {
      widget.onScan(_urlController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'فحص رابط',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            AppTheme.smallVerticalSpace,
            Text(
              'أدخل الرابط الذي تريد فحصه للتأكد من أمانه',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            AppTheme.mediumVerticalSpace,
            _buildUrlInputField(),
            AppTheme.mediumVerticalSpace,
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlInputField() {
    return TextField(
      controller: _urlController,
      focusNode: _focusNode,
      enabled: !widget.isScanning,
      decoration: InputDecoration(
        labelText: 'رابط الموقع',
        hintText: 'https://example.com',
        errorText: _errorText,
        prefixIcon: Icon(
          Icons.link,
          color: _isValid ? AppTheme.successColor : null,
        ),
        suffixIcon: _buildSuffixIcons(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _isValid ? AppTheme.successColor : Colors.grey[300]!,
            width: _isValid ? 2 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _isValid ? AppTheme.successColor : AppTheme.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.errorColor,
            width: 2,
          ),
        ),
      ),
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.go,
      onSubmitted: (_) => _scanUrl(),
      maxLines: null,
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildSuffixIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_urlController.text.isNotEmpty && !widget.isScanning)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearUrl,
            tooltip: 'مسح',
          ),
        IconButton(
          icon: const Icon(Icons.content_paste),
          onPressed: widget.isScanning ? null : _pasteFromClipboard,
          tooltip: 'لصق من الحافظة',
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: (_isValid && !widget.isScanning) ? _scanUrl : null,
            child: widget.isScanning 
                ? _buildScanningContent()
                : _buildScanButton(),
          ),
        ),
        AppTheme.smallHorizontalSpace,
        OutlinedButton(
          onPressed: widget.isScanning ? null : _showUrlInfo,
          child: const Icon(Icons.info_outline),
        ),
      ],
    );
  }

  Widget _buildScanningContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        AppTheme.smallHorizontalSpace,
        const Text('جاري الفحص...'),
      ],
    );
  }

  Widget _buildScanButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.security),
        AppTheme.smallHorizontalSpace,
        const Text('فحص الرابط'),
      ],
    );
  }

  void _showUrlInfo() {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    final urlInfo = Validators.parseUrlInfo(url);
    if (urlInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكن تحليل الرابط'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('معلومات الرابط'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('النطاق', urlInfo.host),
              _buildInfoRow('البروتوكول', urlInfo.scheme.toUpperCase()),
              _buildInfoRow('المنفذ', urlInfo.port.toString()),
              _buildInfoRow('آمن', urlInfo.isSecure ? 'نعم' : 'لا'),
              _buildInfoRow('محلي', urlInfo.isLocal ? 'نعم' : 'لا'),
              _buildInfoRow('رابط مختصر', urlInfo.isShort ? 'نعم' : 'لا'),
              _buildInfoRow('مستوى الخطر', _getRiskLevelText(urlInfo.riskLevel)),
              if (urlInfo.path.isNotEmpty)
                _buildInfoRow('المسار', urlInfo.path),
              if (urlInfo.query.isNotEmpty)
                _buildInfoRow('المعاملات', urlInfo.query),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          if (_isValid)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _scanUrl();
              },
              child: const Text('فحص'),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _getRiskLevelText(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'منخفض';
      case RiskLevel.medium:
        return 'متوسط';
      case RiskLevel.high:
        return 'عالي';
    }
  }
}