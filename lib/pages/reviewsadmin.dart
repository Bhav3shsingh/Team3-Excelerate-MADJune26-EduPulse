import 'package:flutter/material.dart';

class AdminReview extends StatelessWidget {
  const AdminReview({super.key});


  @override
  Widget build(BuildContext context) {
    final program = ModalRoute.of(context)?.settings.arguments as Map<String,dynamic>? ?? {};
    final reviewsString = program['reviews']?.toString() ?? '';
    final reviews = reviewsString.split('\n').where((r) => r.trim().isNotEmpty).toList();
    return Scaffold(
      appBar: AppBar(title:Text("Reviews"),centerTitle: true,),
      body: Center(
        child:ListView.builder(itemCount:reviews.length, 
        itemBuilder:(context,index){
          return Card(
            child: ListTile(
              title: Text(reviews[index].split(':')[0].trim()),
              subtitle: Text(reviews[index].substring(reviews[index].indexOf(':')+1).trim()),
            )
          );
        } 
        )
      )
    );    
  }
  
}