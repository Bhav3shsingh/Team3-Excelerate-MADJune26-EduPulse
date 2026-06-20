import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/authgate.dart';
import 'package:flutter_application_2/firebase_options.dart';
import 'package:flutter_application_2/pages/mainscreen.dart';
import 'package:flutter_application_2/pages/master_admin_approval.dart';
import 'package:flutter_application_2/pages/programcreation.dart';
import 'package:flutter_application_2/pages/register.dart';
import 'pages/welcome.dart';
import 'pages/login.dart';

void main() async {
 WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp(options:DefaultFirebaseOptions.currentPlatform,);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduPulse',
      initialRoute: '/',
      routes:{
        '/':(context) => AuthGate(),
        '/welcome':(context) => WelcomePage(),
        '/login':(context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/mainscreen': (context) => MainScreen(),
        '/pending-admins': (context) => const MasterAdminApprovalPage(),
        '/program-create': (context) => const ProgramCreateScreen(),
      },
    );
  }
}