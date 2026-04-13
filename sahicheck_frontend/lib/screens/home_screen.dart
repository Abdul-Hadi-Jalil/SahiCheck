import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sahicheck_frontend/screens/fake_news_screen.dart';
import 'package:sahicheck_frontend/screens/fraud_detection_screen.dart';
import 'package:sahicheck_frontend/screens/phishing_detection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SahiCheck'),
        actions: [
          OutlinedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            child: Text("Sign out"),
          ),
          SizedBox(width: 20),
        ],
      ),
      body: Column(
        children: [
          const Text(
            "Welcome back to SahiCheck",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Your digital guardian is active. Choose a module to begin verifying information today",
          ),

          const SizedBox(height: 20),

          // Fake News Detection Module
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text("Fake News Detection"),
                const Text(
                  "Analyze news headlines and articles using our advanced NLP models to determine credibility scores.",
                ),
                TextButton(
                  onPressed: () {
                    // Handle button press
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FakeNewsScreen(),
                      ),
                    );
                  },
                  child: const Text("Start Analysis"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Phishing Detection Module
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text("Phishing Detection"),
                const Text(
                  "Scan URLs and email content to identify malicious links and deceptive communication patterns.",
                ),
                TextButton(
                  onPressed: () {
                    // Handle button press
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PhishingDetectionScreen(),
                      ),
                    );
                  },
                  child: const Text("Scan Link"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Fraud Detection Module
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text("Fraud Detection"),
                const Text(
                  "Verify bank SMS alerts and financial transactions to protect against sophisticated UPI and banking frauds.",
                ),
                TextButton(
                  onPressed: () {
                    // Handle button press
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FraudDetectionScreen(),
                      ),
                    );
                  },
                  child: const Text("Check Message"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
