import 'package:auctus_call/utilities/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  late String name;
  final TextEditingController _emailController = TextEditingController();
  late String email;
  final TextEditingController _passwordController = TextEditingController();
  late String password;
  bool passwordVisible = false;
  bool isLoading = false;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        body: Center(
          child: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Image.asset(
                        //   'images/auctus_logo.png',
                        //   width: 100,
                        //   height: 100,
                        // ),
                        const Text(
                          'Sign Up',
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: mainColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: screenWidth * 0.85,
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                          focusedBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: mainColor, width: 2)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: screenWidth * 0.85,
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                          focusedBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: mainColor, width: 2)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: screenWidth * 0.85,
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                passwordVisible = !passwordVisible;
                              });
                            },
                            icon: Icon(passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            iconSize: 15,
                          ),
                          labelText: 'Password',
                          labelStyle:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                          focusedBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: mainColor, width: 2)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        obscureText: !passwordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          } else if (value.length < 7) {
                            return 'Password must be at least 7 characters long';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                            context, '/welcome_screen');
                        print('Text clicked');
                      },
                      child: const Text(
                        'Login Aja Deh',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate() ?? false) {
                                setState(() {
                                  isLoading = true;
                                });
                                email = _emailController.text;
                                password = _passwordController.text;
                                name = _nameController.text;

                                try {
                                  await FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                    email: email,
                                    password: password,
                                  );
                                  _formKey.currentState!.reset();

                                  MyMessage.showSnackBar(
                                      _scaffoldMessengerKey, 'Signing Up...');
                                  print('Signing Up');

                                  await users
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .set({
                                    'name': name,
                                    'email': email,
                                    'password': password,
                                    'phone': '',
                                    'address': '',
                                    'user_id':
                                        FirebaseAuth.instance.currentUser!.uid,
                                  });

                                  setState(() {
                                    _nameController.clear();
                                    _emailController.clear();
                                    _passwordController.clear();
                                  });

                                  Navigator.pushReplacementNamed(
                                      context, '/home_screen');
                                } catch (e) {
                                  MyMessage.showSnackBar(
                                      _scaffoldMessengerKey, e.toString());
                                } finally {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              } else {
                                MyMessage.showSnackBar(
                                    _scaffoldMessengerKey, "Failed");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sign Up',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyMessage {
  static void showSnackBar(var scaffoldMessengerKey, String message) {
    scaffoldMessengerKey.currentState!.hideCurrentSnackBar();
    scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: secColor,
      ),
    );
  }
}
