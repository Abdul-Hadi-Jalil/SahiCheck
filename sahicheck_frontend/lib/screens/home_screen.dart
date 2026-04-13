import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SahiCheck')),
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
                  },
                  child: const Text("Start Analysis"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
