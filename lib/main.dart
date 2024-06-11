import 'package:auctus_call/views/salesman/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAy63SV3WfBu31XcRWD1IpeDI8wo1BqCNw',
      appId: '1:104318353121:android:2949536fc4c931a2b141a0',
      messagingSenderId: '104318353121',
      projectId: 'auctussfa',
      storageBucket: 'auctussfa.appspot.com',
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
