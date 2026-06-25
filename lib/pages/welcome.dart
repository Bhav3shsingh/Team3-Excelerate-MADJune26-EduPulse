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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 260,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          "WELCOME !",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D111A),
                          ),
                        ),
                        SizedBox(height: 58),
                        Text(
                          "You are...",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0D111A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                style:ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF16516),
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
                  backgroundColor: const Color(0xFF0B66B1),
                  foregroundColor: Colors.white
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/login', arguments: 1);
                },
                child: const Text("ADMIN"),
              ),
            ),
            Center(
              child: Image.asset(
                'assets/logo.png',
                width: 220,
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('Image asset not found', style: TextStyle(color: Colors.red)),
                ),
              ),
            ),
            const Center(
              child: Text(
                "An Excelerate App",
                style: TextStyle(fontSize: 14, color: Color(0xFFE9246B)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}