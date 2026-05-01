import 'package:flutter/material.dart';
import 'package:sahicheck_frontend/services/api_service.dart';

class FraudDetectionScreen extends StatefulWidget {
  const FraudDetectionScreen({super.key});

  @override
  State<FraudDetectionScreen> createState() => _FraudDetectionScreenState();
}

class _FraudDetectionScreenState extends State<FraudDetectionScreen> {
  final _timeController = TextEditingController();
  final _amountController = TextEditingController();
  final _v1Controller = TextEditingController();
  final _v2Controller = TextEditingController();
  final _v3Controller = TextEditingController();
  final _v4Controller = TextEditingController();
  final _v5Controller = TextEditingController();
  final _v6Controller = TextEditingController();
  final _v7Controller = TextEditingController();
  final _v8Controller = TextEditingController();
  final _v9Controller = TextEditingController();
  final _v10Controller = TextEditingController();
  final _v11Controller = TextEditingController();
  final _v12Controller = TextEditingController();
  final _v13Controller = TextEditingController();
  final _v14Controller = TextEditingController();
  final _v15Controller = TextEditingController();
  final _v16Controller = TextEditingController();
  final _v17Controller = TextEditingController();
  final _v18Controller = TextEditingController();
  final _v19Controller = TextEditingController();
  final _v20Controller = TextEditingController();
  final _v21Controller = TextEditingController();
  final _v22Controller = TextEditingController();
  final _v23Controller = TextEditingController();
  final _v24Controller = TextEditingController();
  final _v25Controller = TextEditingController();
  final _v26Controller = TextEditingController();
  final _v27Controller = TextEditingController();
  final _v28Controller = TextEditingController();

  bool _isLoading = false;
  Map<String, dynamic>? _result;

  void _fillLegitimateTransaction() {
    setState(() {
      _timeController.text = '1000.0';
      _amountController.text = '25.50';
      _v1Controller.text = '1.2';
      _v2Controller.text = '0.5';
      _v3Controller.text = '-0.3';
      _v4Controller.text = '0.8';
      _v5Controller.text = '-0.2';
      _v6Controller.text = '0.1';
      _v7Controller.text = '-0.5';
      _v8Controller.text = '0.3';
      _v9Controller.text = '-0.1';
      _v10Controller.text = '0.6';
      _v11Controller.text = '-0.4';
      _v12Controller.text = '0.2';
      _v13Controller.text = '-0.7';
      _v14Controller.text = '0.4';
      _v15Controller.text = '-0.9';
      _v16Controller.text = '0.5';
      _v17Controller.text = '-0.3';
      _v18Controller.text = '0.8';
      _v19Controller.text = '-0.1';
      _v20Controller.text = '0.6';
      _v21Controller.text = '-0.4';
      _v22Controller.text = '0.2';
      _v23Controller.text = '-0.8';
      _v24Controller.text = '0.7';
      _v25Controller.text = '-0.5';
      _v26Controller.text = '0.3';
      _v27Controller.text = '-0.2';
      _v28Controller.text = '0.1';
    });
  }

  void _fillFraudulentTransaction() {
    setState(() {
      _timeController.text = '2000.0';
      _amountController.text = '1500.00';
      _v1Controller.text = '-2.5';
      _v2Controller.text = '1.8';
      _v3Controller.text = '-3.2';
      _v4Controller.text = '2.1';
      _v5Controller.text = '-1.5';
      _v6Controller.text = '0.9';
      _v7Controller.text = '-2.8';
      _v8Controller.text = '1.6';
      _v9Controller.text = '-0.7';
      _v10Controller.text = '2.3';
      _v11Controller.text = '-1.9';
      _v12Controller.text = '0.5';
      _v13Controller.text = '-2.1';
      _v14Controller.text = '1.4';
      _v15Controller.text = '-3.5';
      _v16Controller.text = '2.8';
      _v17Controller.text = '-1.2';
      _v18Controller.text = '0.3';
      _v19Controller.text = '-2.9';
      _v20Controller.text = '1.7';
      _v21Controller.text = '-0.4';
      _v22Controller.text = '2.6';
      _v23Controller.text = '-1.8';
      _v24Controller.text = '0.9';
      _v25Controller.text = '-2.3';
      _v26Controller.text = '1.5';
      _v27Controller.text = '-0.6';
      _v28Controller.text = '2.0';
    });
  }

  void _clearAll() {
    setState(() {
      _timeController.clear();
      _amountController.clear();
      _v1Controller.clear();
      _v2Controller.clear();
      _v3Controller.clear();
      _v4Controller.clear();
      _v5Controller.clear();
      _v6Controller.clear();
      _v7Controller.clear();
      _v8Controller.clear();
      _v9Controller.clear();
      _v10Controller.clear();
      _v11Controller.clear();
      _v12Controller.clear();
      _v13Controller.clear();
      _v14Controller.clear();
      _v15Controller.clear();
      _v16Controller.clear();
      _v17Controller.clear();
      _v18Controller.clear();
      _v19Controller.clear();
      _v20Controller.clear();
      _v21Controller.clear();
      _v22Controller.clear();
      _v23Controller.clear();
      _v24Controller.clear();
      _v25Controller.clear();
      _v26Controller.clear();
      _v27Controller.clear();
      _v28Controller.clear();
    });
  }

  Future<void> _detectFraud() async {
    if (_timeController.text.trim().isEmpty ||
        _amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter time and amount')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final result = await ApiService.detectFraud(
        double.parse(_timeController.text.trim()),
        double.tryParse(_v1Controller.text.trim()) ?? 0.0,
        double.tryParse(_v2Controller.text.trim()) ?? 0.0,
        double.tryParse(_v3Controller.text.trim()) ?? 0.0,
        double.tryParse(_v4Controller.text.trim()) ?? 0.0,
        double.tryParse(_v5Controller.text.trim()) ?? 0.0,
        double.tryParse(_v6Controller.text.trim()) ?? 0.0,
        double.tryParse(_v7Controller.text.trim()) ?? 0.0,
        double.tryParse(_v8Controller.text.trim()) ?? 0.0,
        double.tryParse(_v9Controller.text.trim()) ?? 0.0,
        double.tryParse(_v10Controller.text.trim()) ?? 0.0,
        double.tryParse(_v11Controller.text.trim()) ?? 0.0,
        double.tryParse(_v12Controller.text.trim()) ?? 0.0,
        double.tryParse(_v13Controller.text.trim()) ?? 0.0,
        double.tryParse(_v14Controller.text.trim()) ?? 0.0,
        double.tryParse(_v15Controller.text.trim()) ?? 0.0,
        double.tryParse(_v16Controller.text.trim()) ?? 0.0,
        double.tryParse(_v17Controller.text.trim()) ?? 0.0,
        double.tryParse(_v18Controller.text.trim()) ?? 0.0,
        double.tryParse(_v19Controller.text.trim()) ?? 0.0,
        double.tryParse(_v20Controller.text.trim()) ?? 0.0,
        double.tryParse(_v21Controller.text.trim()) ?? 0.0,
        double.tryParse(_v22Controller.text.trim()) ?? 0.0,
        double.tryParse(_v23Controller.text.trim()) ?? 0.0,
        double.tryParse(_v24Controller.text.trim()) ?? 0.0,
        double.tryParse(_v25Controller.text.trim()) ?? 0.0,
        double.tryParse(_v26Controller.text.trim()) ?? 0.0,
        double.tryParse(_v27Controller.text.trim()) ?? 0.0,
        double.tryParse(_v28Controller.text.trim()) ?? 0.0,
        double.parse(_amountController.text.trim()),
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
        title: const Text('Fraud Detection'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Enter transaction details to check for fraud',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Test Options:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _fillLegitimateTransaction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Legitimate\nTransaction',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _fillFraudulentTransaction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Fraudulent\nTransaction',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _clearAll,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade600,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Clear All',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'V1-V28 are anonymized transaction features. Use presets or leave as 0.0',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Required fields
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'Time *',
                      hintText: 'Transaction time',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount *',
                      hintText: 'Transaction amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'V1-V28 Features (Optional - leave blank for 0)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            // V1-V14 fields
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 14,
              itemBuilder: (context, index) {
                final controllers = [
                  _v1Controller,
                  _v2Controller,
                  _v3Controller,
                  _v4Controller,
                  _v5Controller,
                  _v6Controller,
                  _v7Controller,
                  _v8Controller,
                  _v9Controller,
                  _v10Controller,
                  _v11Controller,
                  _v12Controller,
                  _v13Controller,
                  _v14Controller,
                ];
                return TextField(
                  controller: controllers[index],
                  decoration: InputDecoration(
                    labelText: 'V${index + 1}',
                    hintText: '0.0',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                );
              },
            ),
            const SizedBox(height: 10),
            // V15-V28 fields
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 14,
              itemBuilder: (context, index) {
                final controllers = [
                  _v15Controller,
                  _v16Controller,
                  _v17Controller,
                  _v18Controller,
                  _v19Controller,
                  _v20Controller,
                  _v21Controller,
                  _v22Controller,
                  _v23Controller,
                  _v24Controller,
                  _v25Controller,
                  _v26Controller,
                  _v27Controller,
                  _v28Controller,
                ];
                return TextField(
                  controller: controllers[index],
                  decoration: InputDecoration(
                    labelText: 'V${index + 15}',
                    hintText: '0.0',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _detectFraud,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Check Transaction',
                      style: TextStyle(fontSize: 16),
                    ),
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
    final isFraud = result['result'] == 'Fraud';
    final confidence = (result['confidence'] as double) * 100;
    final fraudProbability = result['fraud_probability'] as double?;
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
                  isFraud ? Icons.warning : Icons.check_circle,
                  color: isFraud ? Colors.red : Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  isFraud ? 'FRAUD DETECTED' : 'LEGITIMATE TRANSACTION',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isFraud ? Colors.red : Colors.green,
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
              color: isFraud ? Colors.red : Colors.green,
            ),
            const SizedBox(height: 16),
            if (fraudProbability != null)
              Text(
                "Fraud Probability: ${(fraudProbability * 100).toStringAsFixed(1)}%",
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
