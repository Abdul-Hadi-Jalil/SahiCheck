import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? toggleScreen;
  const LoginScreen({super.key, required this.toggleScreen});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text(
            "SahiCheck",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text("The Guardian of Digital Authenticity"),
          const SizedBox(height: 20),
          Column(
            children: [
              Text('Email Address'),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'Enter your email'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Column(
            children: [
              Text('Password'),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Enter your password',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              FirebaseAuth.instance.signInWithEmailAndPassword(
                email: emailController.toString().trim(),
                password: passwordController.toString().trim(),
              );
            },
            child: Text('Login'),
          ),

          const SizedBox(height: 20),
          Row(
            children: [
              Text("Don't have an account?"),
              TextButton(
                onPressed: () {
                  // navigate to registration screen
                  widget.toggleScreen!();
                },
                child: Text('Sign up'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
