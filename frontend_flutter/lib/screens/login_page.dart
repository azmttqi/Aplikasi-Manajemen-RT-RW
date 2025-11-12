import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../dashboard/dashboard_rw.dart';
import '../dashboard/dashboard_rt.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> handleLogin() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final result = await ApiService.login(email, password);

    if (result['success']) {
      final role = result['role'];
      if (role.toLowerCase() == 'rw') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardRW()),
        );
      } else if (role.toLowerCase() == 'rt') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardRT()),
        );
      } else {
        setState(() {
          errorMessage = "Peran tidak dikenali.";
        });
      }
    } else {
      setState(() {
        errorMessage = result['message'];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login RT/RW")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: isLoading ? null : handleLogin,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
