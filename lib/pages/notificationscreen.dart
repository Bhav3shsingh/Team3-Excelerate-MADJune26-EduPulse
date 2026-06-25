import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationscreenState();

}

class _NotificationscreenState extends State<NotificationScreen>{
   
  List<String> notifications = [];

   @override
   void initState(){
    super.initState();
    _loadNot();
   }

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(title: const Text("Notifications"), centerTitle: true),
       body: notifications.isEmpty
           ? const Center(child: Text('No notifications'))
           : ListView.builder(
               padding: const EdgeInsets.all(12),
               itemCount: notifications.length,
               itemBuilder: (context, index) {
                 return Card(
                   margin: const EdgeInsets.symmetric(vertical: 8),
                   child: ListTile(
                     leading: const Icon(Icons.notifications),
                     title: Text(notifications[index]),
                   ),
                 );
               },
             ),
           );
         }
         
          void _loadNot() async{
            final uid = FirebaseAuth.instance.currentUser?.uid;
            String role = '';
            if (uid != null) {
              final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
              role = userDoc.data()?['role'] as String? ?? '';
            }

            final notificationsSnapshot = await FirebaseFirestore.instance.collection("notifications").get();
            final allNotifications = <String>[];
            for (final doc in notificationsSnapshot.docs) {
              final data = doc.data();
              final msg = data['message'] as String? ?? '';
              final targetUid = data['uid'] as String?;
              final roles = (data['roles'] as List<dynamic>?)?.cast<String>();

              if (targetUid != null) {
                if (uid != null && targetUid == uid) {
                  allNotifications.add(msg);
                }
                continue;
              }
              if (roles != null && roles.isNotEmpty) {
                if (role.isNotEmpty && roles.contains(role)) {
                  allNotifications.add(msg);
                }
                continue;
              }
              // public notification
              allNotifications.add(msg);
            }

            if (mounted) {
              setState(() {
                notifications = allNotifications;
              });
            }
          }
}