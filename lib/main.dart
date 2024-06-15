import 'package:auctus_call/views/salesman/login.dart';
import 'package:auctus_call/views/salesman/session.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      // CONFIG PROD
      apiKey: 'AIzaSyAy63SV3WfBu31XcRWD1IpeDI8wo1BqCNw',
      appId: '1:104318353121:android:2949536fc4c931a2b141a0',
      messagingSenderId: '104318353121',
      projectId: 'auctussfa',
      storageBucket: 'auctussfa.appspot.com',

      // //CONFIG TES
      // apiKey: 'AIzaSyBS9MRPmvDOvbdNbWBL3qSqtlOs8jdrGew',
      // appId: '1:738273846116:android:676b82a3cbdee3d5459071',
      // messagingSenderId: '738273846116',
      // projectId: 'cekcek-41bd2',
      // storageBucket: 'cekcek.appspot.com',
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final SessionManager sessionManager = SessionManager();
  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const LoginScreen(), // later switch to login screen
    );
  }
}
