import 'package:flutter/material.dart';

class PhishingDetectionScreen extends StatefulWidget {
  const PhishingDetectionScreen({super.key});

  @override
  State<PhishingDetectionScreen> createState() =>
      _PhishingDetectionScreenState();
}

class _PhishingDetectionScreenState extends State<PhishingDetectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Phishing Detection")));
  }
}
