import 'package:flutter/material.dart';
import 'package:sahicheck_frontend/services/api_service.dart';

class IntegrationTestScreen extends StatefulWidget {
  const IntegrationTestScreen({super.key});

  @override
  State<IntegrationTestScreen> createState() => _IntegrationTestScreenState();
}

class _IntegrationTestScreenState extends State<IntegrationTestScreen> {
  bool _isTesting = false;
  String _testResult = '';
  List<String> _testLogs = [];

  void _addLog(String message) {
    setState(() {
      _testLogs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
  }

  Future<void> _runIntegrationTests() async {
    setState(() {
      _isTesting = true;
      _testResult = '';
      _testLogs = [];
    });

    _addLog('Starting integration tests...');

    try {
      // Test 1: Connection Test
      _addLog('Testing backend connection...');
      final isConnected = await ApiService.testConnection();
      if (isConnected) {
        _addLog('Backend connection: SUCCESS');
      } else {
        _addLog('Backend connection: FAILED');
        throw Exception('Backend not reachable');
      }

      // Test 2: Phishing Detection
      _addLog('Testing phishing detection...');
      try {
        final phishingResult = await ApiService.detectPhishing(
          'https://www.paypal.com/login',
          'test123',
        );
        _addLog('Phishing detection: SUCCESS');
        _addLog(
          'Result: ${phishingResult['result']} (${(phishingResult['confidence'] * 100).toStringAsFixed(1)}%)',
        );
      } catch (e) {
        _addLog('Phishing detection: FAILED - $e');
      }

      // Test 3: Fraud Detection
      _addLog('Testing fraud detection...');
      try {
        final fraudResult = await ApiService.detectFraud(
          1000.0,
          -1.2,
          0.5,
          1.0,
          -0.5,
          0.8,
          -0.3,
          0.2,
          -0.1,
          0.6,
          -0.4,
          0.3,
          -0.2,
          0.1,
          -0.8,
          0.7,
          -0.6,
          0.4,
          -0.9,
          0.5,
          -0.3,
          0.2,
          -0.7,
          0.6,
          -0.4,
          0.8,
          -0.1,
          0.3,
          0.0,
          100.0,
          'test123',
        );
        _addLog('Fraud detection: SUCCESS');
        _addLog(
          'Result: ${fraudResult['result']} (${(fraudResult['confidence'] * 100).toStringAsFixed(1)}%)',
        );
      } catch (e) {
        _addLog('Fraud detection: FAILED - $e');
      }

      // Test 4: Fake News Detection
      _addLog('Testing fake news detection...');
      try {
        final fakeNewsResult = await ApiService.detectFakeNews(
          'Breaking: Scientists Discover Cure for Cancer',
          'Scientists have announced a groundbreaking discovery that could cure all forms of cancer. This revolutionary treatment has shown remarkable results in clinical trials.',
          'test123',
        );
        _addLog('Fake news detection: SUCCESS');
        _addLog(
          'Result: ${fakeNewsResult['result']} (${(fakeNewsResult['confidence'] * 100).toStringAsFixed(1)}%)',
        );
      } catch (e) {
        _addLog('Fake news detection: FAILED - $e');
      }

      _addLog('Integration tests completed!');
      setState(() {
        _testResult = 'SUCCESS';
      });
    } catch (e) {
      _addLog('Integration tests FAILED: $e');
      setState(() {
        _testResult = 'FAILED';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Integration Test'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Backend Integration Test',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Test all API endpoints to verify frontend-backend connection',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isTesting ? null : _runIntegrationTests,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isTesting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(width: 10),
                        Text('Testing...', style: TextStyle(fontSize: 16)),
                      ],
                    )
                  : const Text(
                      'Run Integration Tests',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 20),
            if (_testResult.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _testResult == 'SUCCESS'
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _testResult == 'SUCCESS' ? Colors.green : Colors.red,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _testResult == 'SUCCESS'
                          ? Icons.check_circle
                          : Icons.error,
                      color: _testResult == 'SUCCESS'
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _testResult == 'SUCCESS'
                          ? 'All Tests Passed!'
                          : 'Tests Failed!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _testResult == 'SUCCESS'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'Test Logs:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testLogs.isEmpty
                        ? 'No logs yet. Run tests to see results.'
                        : _testLogs.join('\n'),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
