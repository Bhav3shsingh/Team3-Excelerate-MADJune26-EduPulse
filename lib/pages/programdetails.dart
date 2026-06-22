import 'package:flutter/material.dart';

class ProgramDetails extends StatelessWidget {

   @override
   Widget build(BuildContext context) {
    final program = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
     return Scaffold(
       appBar: AppBar(
         title: const Text('Program Overview'),
       ),
       body:Padding(
             padding: const EdgeInsets.all(16.0),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                Image.network(program['imageUrl'], height: 200, width: double.infinity, fit: BoxFit.cover),
                 Text('Title: ${program['title']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                 const SizedBox(height: 8),
                 Text('Start Time: ${program['startTime']}'),
                 const SizedBox(height: 8),
                 Text('End Time: ${program['endTime']}'),
                 const SizedBox(height: 8),
                 Text('Description: ${program['description']}'),
                 const SizedBox(height: 8),
                 Text('Category: ${program['category']}')
               ],
             )
           )
         );
      }
}
 