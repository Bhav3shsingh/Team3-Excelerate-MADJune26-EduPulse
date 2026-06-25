import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FormScreen extends StatefulWidget{

  const FormScreen({super.key});
  
  @override
  State<StatefulWidget> createState() => _FormScreenState();

}

class _FormScreenState extends State<FormScreen>{

  final _textController = TextEditingController();
  
  @override
  void dispose()
  {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)?.settings.arguments as String? ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Share your feedback',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Write your feedback',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () async {
                final String res = _textController.text.trim();

                if (id.isEmpty) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Program id is missing.')),
                    );
                  }
                  return;
                }

                final docRef = FirebaseFirestore.instance.collection('programs').doc(id);
                final snapshot = await docRef.get();
                final email = FirebaseAuth.instance.currentUser?.email.toString();

                if (!snapshot.exists) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Program not found.')),
                    );
                  }
                  return;
                }

                final String rew = snapshot.data()?['reviews']?.toString() ?? '';

                if (res.isNotEmpty) {
                  await docRef.update({
                    'reviews': rew.isEmpty ? 'Anonymous : $res\n$rew' : '$email : $res\n$rew',
                  });

                  if (mounted) Navigator.of(context).pop();
                }
              },
              child: const Text('SUBMIT'),
            ),
          ],
        ),
      ),
    );
  }
}