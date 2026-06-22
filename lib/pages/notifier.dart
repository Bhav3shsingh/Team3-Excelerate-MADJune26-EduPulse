import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Notifier extends StatefulWidget {
  const Notifier({super.key});

  @override
  State<Notifier> createState() => _NotifierState();
}

class _NotifierState extends State<Notifier> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Push Notifications"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          TextField(
            controller: _textController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: "Enter your message",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {
              final message = _textController.text.trim();
              if (message.isNotEmpty) {
                FirebaseFirestore.instance.collection('notifications').add({
                  'message': message
                });
                _textController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text("Send Notification"),
          ),
        ],
      )),
    );
  }
}