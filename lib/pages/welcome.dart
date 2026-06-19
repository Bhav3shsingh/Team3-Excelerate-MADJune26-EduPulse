import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EduPulse"),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 68), 
          const Center(
            child: Text("WELCOME !"),
          ),
          const SizedBox(height: 48),
          const Center(
            child: Text("You are..."),
          ),
          const SizedBox(height: 68), 
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              style:ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF16516),
                foregroundColor: Colors.white
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/login', arguments: 0);
              },
              child: const Text("LEARNER"),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              style:ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0B66B1),
                foregroundColor: Colors.white
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/login', arguments: 1);
              },
              child: const Text("ADMIN"),
            ),
          ),
        ],
      ),
    );
  }
}