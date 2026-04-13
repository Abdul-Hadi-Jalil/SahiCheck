import 'package:flutter/material.dart';

class FakeNewsScreen extends StatefulWidget {
  const FakeNewsScreen({super.key});

  @override
  State<FakeNewsScreen> createState() => _FakeNewsScreenState();
}

class _FakeNewsScreenState extends State<FakeNewsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Fake News Detection")));
  }
}
