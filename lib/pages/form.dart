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
        title: Text("Feedback"),
      ),
      body:
        Column(
          children:[
            TextField(
              controller: _textController,
              maxLength: null,
              decoration:const InputDecoration(
                label:Text('Write Here'),
                border:OutlineInputBorder()
              )
            ),
            OutlinedButton(onPressed: () async {
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
                  'reviews': rew.isEmpty ? res : '$email : $rew\n$res',
                });

                if (mounted) Navigator.of(context).pop();
              }
            }, child: Text('SUBMIT'))
          ]
        )
    );
  }
}