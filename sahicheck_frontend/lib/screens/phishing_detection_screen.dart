import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sahicheck_frontend/l10n/app_localizations.dart';
import 'package:sahicheck_frontend/services/api_service.dart';
import 'package:sahicheck_frontend/utils/responsive.dart';

class PhishingDetectionScreen extends StatefulWidget {
  const PhishingDetectionScreen({super.key});

  @override
  State<PhishingDetectionScreen> createState() =>
      _PhishingDetectionScreenState();
}

class _PhishingDetectionScreenState extends State<PhishingDetectionScreen> {
  final _urlController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _detectPhishing() async {
    if (_urlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL required')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
      final result = await ApiService.detectPhishing(
        _urlController.text.trim(),
        userId,
      );
      if (!mounted) return;
      setState(() => _result = result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final padding = Responsive.pagePadding(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.phishing),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
          child: SingleChildScrollView(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.enterUrl,
                  style: TextStyle(
                    fontSize: Responsive.bodySize(context) + 2,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL',
                    hintText: 'https://example.com',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _detectPhishing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(l10n.checkUrl),
                  ),
                ),
                if (_result != null) ...[
                  const SizedBox(height: 20),
                  _buildResultCard(l10n),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(AppLocalizations l10n) {
    final result = _result!;
    final isPhishing = result['result'] == 'phishing';
    final confidence = ((result['confidence'] as num?) ?? 0) * 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPhishing ? 'PHISHING' : 'SAFE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isPhishing ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text('${l10n.confidence}: ${confidence.toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (result['confidence'] as num?)?.toDouble() ?? 0,
              color: isPhishing ? Colors.red : Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
