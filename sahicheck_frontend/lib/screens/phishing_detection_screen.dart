import 'package:flutter/material.dart';
import 'package:sahicheck_frontend/services/api_service.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a URL')));
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final result = await ApiService.detectPhishing(
        _urlController.text.trim(),
        'user123', // You can get this from Firebase Auth
      );
      if (!mounted) return;
      setState(() {
        _result = result;
      });
    } catch (e) {
      if (!mounted) return;
      final message = e.toString();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phishing Detection'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter a URL to check if it\'s safe or a phishing attempt',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _detectPhishing,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Check URL', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
            if (_result != null) _buildResultCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final result = _result!;
    final isPhishing = result['result'] == 'phishing';
    final confidence = (result['confidence'] as double) * 100;
    final phishingProbability = result['phishing_probability'] as double?;
    final legitimateProbability = result['legitimate_probability'] as double?;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPhishing ? Icons.warning : Icons.check_circle,
                  color: isPhishing ? Colors.red : Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  isPhishing ? 'PHISHING DETECTED' : 'SAFE URL',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isPhishing ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Confidence: ${confidence.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: result['confidence'],
              backgroundColor: Colors.grey.shade300,
              color: isPhishing ? Colors.red : Colors.green,
            ),
            const SizedBox(height: 16),
            if (phishingProbability != null)
              Text(
                "Phishing Probability: ${(phishingProbability * 100).toStringAsFixed(1)}%",
                style: TextStyle(fontSize: 14, color: Colors.red.shade700),
              ),
            if (legitimateProbability != null)
              Text(
                "Legitimate Probability: ${(legitimateProbability * 100).toStringAsFixed(1)}%",
                style: TextStyle(fontSize: 14, color: Colors.green.shade700),
              ),
          ],
        ),
      ),
    );
  }
}
