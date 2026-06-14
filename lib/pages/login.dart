import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // clean up old alerts and push a new floating error snackbar
  void _showErrorSnackbar(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // Returns true if login is successful, false if it throws an error
  Future<bool> loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackbar("Email and password fields cannot be empty.");
      return false;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true; // Execution succeeded gracefully
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        _showErrorSnackbar("Invalid email or password combination.");
      } else if (e.code == 'invalid-email') {
        _showErrorSnackbar("The email address formatting is invalid.");
      } else if (e.code == 'user-disabled') {
        _showErrorSnackbar("This account has been administratively disabled.");
      } else {
        _showErrorSnackbar(e.message ?? "An authentication error occurred.");
      }
      return false;
    } catch (e) {
      _showErrorSnackbar("Connection failed. Check your network status.");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Catch the userType argument passed from WelcomePage (defaults to 0 if null)
    final userType = ModalRoute.of(context)?.settings.arguments as int? ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("EduPulse"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Email Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 28),

              // Login Button with custom EduPulse Blue profile parameters
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B66B1), // EduPulse Blue
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0), // Kept consistent rounded shape
                    ),
                  ),
                  onPressed: () async {
                    // Triggers the login sequence
                    bool isSuccess = await loginUser();
                    
                    // ONLY navigate back to the root if the login action was completely successful
                    if (isSuccess && context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  child: const Text("LOGIN"),
                ),
              ),

              // Conditional Register Link (Only shows if userType == 0)
              if (userType == 0) ...[
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text(
                    "No Account? Create one",
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}