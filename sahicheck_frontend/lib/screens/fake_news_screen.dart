import 'package:flutter/material.dart';
import 'package:sahicheck_frontend/services/api_service.dart';

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

  Future<void> _detectFakeNews() async {
    if (_titleController.text.trim().isEmpty ||
        _textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both title and text')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      print('Sending fake news detection request...');
      print('Title: ${_titleController.text.trim()}');
      print('Text length: ${_textController.text.trim().length}');
      final result = await ApiService.detectFakeNews(
        _titleController.text.trim(),
        _textController.text.trim(),
        'user123', // You can get this from Firebase Auth
      );
      print('Received result: $result');
      if (!mounted) return;
      setState(() {
        _result = result;
      });
    } catch (e) {
      print('Error in fake news detection: $e');
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
        title: const Text('Fake News Detection'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter news article details to check if it\'s fake or real',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Article Title *',
                hintText: 'Enter the news headline',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Article Content *',
                hintText: 'Enter the news article text',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.article),
              ),
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _detectFakeNews,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Analyze Article',
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
    final isFake = result['result'] == 'Fake News';
    final confidence = (result['confidence'] as double) * 100;
    final fakeNewsProbability = result['fake_news_probability'] as double?;
    final trueNewsProbability = result['true_news_probability'] as double?;

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
                  isFake ? Icons.warning : Icons.check_circle,
                  color: isFake ? Colors.red : Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  isFake ? 'FAKE NEWS DETECTED' : 'REAL NEWS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isFake ? Colors.red : Colors.green,
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
              color: isFake ? Colors.red : Colors.green,
            ),
            const SizedBox(height: 16),
            if (fakeNewsProbability != null)
              Text(
                "Fake News Probability: ${(fakeNewsProbability * 100).toStringAsFixed(1)}%",
                style: TextStyle(fontSize: 14, color: Colors.red.shade700),
              ),
            if (trueNewsProbability != null)
              Text(
                "True News Probability: ${(trueNewsProbability * 100).toStringAsFixed(1)}%",
                style: TextStyle(fontSize: 14, color: Colors.green.shade700),
              ),
          ],
        ),
      ),
    );
  }
}
