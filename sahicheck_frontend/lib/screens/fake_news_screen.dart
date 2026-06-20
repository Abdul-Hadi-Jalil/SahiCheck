import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sahicheck_frontend/l10n/app_localizations.dart';
import 'package:sahicheck_frontend/services/api_service.dart';
import 'package:sahicheck_frontend/utils/responsive.dart';

class FakeNewsScreen extends StatefulWidget {
  const FakeNewsScreen({super.key});

  @override
  State<FakeNewsScreen> createState() => _FakeNewsScreenState();
}

class _FakeNewsScreenState extends State<FakeNewsScreen> {
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _detectFakeNews() async {
    final l10n = AppLocalizations.of(context);
    if (_titleController.text.trim().isEmpty ||
        _textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.articleTitle} & ${l10n.articleContent}')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
      final result = await ApiService.detectFakeNews(
        _titleController.text.trim(),
        _textController.text.trim(),
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
        title: Text(l10n.fakeNews),
        backgroundColor: Colors.blue.shade700,
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
                  l10n.fakeNewsDesc,
                  style: TextStyle(
                    fontSize: Responsive.bodySize(context) + 2,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: l10n.articleTitle,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.title),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    labelText: l10n.articleContent,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.article),
                  ),
                  minLines: 5,
                  maxLines: 10,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _detectFakeNews,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(l10n.analyzeArticle),
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
    final isFake = result['result'] == 'Fake News';
    final confidence = ((result['confidence'] as num?) ?? 0) * 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isFake ? l10n.fakeDetected : l10n.realNews,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isFake ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text('${l10n.confidence}: ${confidence.toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (result['confidence'] as num?)?.toDouble() ?? 0,
              color: isFake ? Colors.red : Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
