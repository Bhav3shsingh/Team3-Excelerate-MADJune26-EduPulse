import 'package:cloud_firestore/cloud_firestore.dart';
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
       body: SingleChildScrollView(
              child: 
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.notifications),
                        title: Text(notifications[index])
                      );
                    },
                  )
          ),
           );
         }
         
          void _loadNot() async{
            final notificationsSnapshot = await FirebaseFirestore.instance.collection("notifications").get();
            if (mounted) {
              final allNotifications = notificationsSnapshot.docs.map((doc) => doc.data()['message'] as String? ??'').toList();
              setState(() {
              notifications = allNotifications;
            });
            }
          }
}