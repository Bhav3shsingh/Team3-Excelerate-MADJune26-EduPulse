import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List data = [];

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  Future<void> loadJson() async {
    String jsonString =
        await rootBundle.loadString('assets/data.json');

    setState(() {
      data = json.decode(jsonString);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("EduPulse")),
      body: data.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Program list
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];

                      return Card(
                        child: ListTile(
                          title: Text(item["name"] ?? "No Name"),
                          subtitle: Text(item["category"] ?? "No Category"),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 20),

                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      "Notifications",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.notifications),
                        title: Text(notifications[index]),
                      );
                    },
                  ),
                ],
              ),
            ),
      );
  }

  List<String> notifications = [
    "Program starts in 30 minutes",
    "Certificate available for AI Workshop",
    "New Data Science event added",
    "Meeting link updated",
  ];
}