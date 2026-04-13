import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback? toggleScreen;
  const RegisterScreen({super.key, required this.toggleScreen});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? email;
  String? password;
  String? confirmPassword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text(
            "Create and account",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text("Join the community of digital guardians today"),
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

          Column(
            children: [
              Text('Confirm Password'),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Confirm your password',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              email = emailController.text.trim();
              password = passwordController.text.trim();

              FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: email!,
                password: password!,
              );
            },
            child: Text('Sign Up'),
          ),

          const SizedBox(height: 20),
          Row(
            children: [
              Text("Already have an account?"),
              TextButton(
                onPressed: () {
                  // navigate to registration screen
                  widget.toggleScreen!();
                },
                child: Text('Login up'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
