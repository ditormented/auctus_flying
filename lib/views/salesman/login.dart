import 'package:auctus_call/utilities/colors.dart';
import 'package:auctus_call/views/main_screen.dart';
import 'package:auctus_call/views/salesman/session.dart';
import 'package:auctus_call/views/salesman/sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SessionManager _sessionManager = SessionManager();
  bool passwordVisible = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    bool loggedIn = await _sessionManager.isLoggedIn();
    if (loggedIn) {
      String? userId = await _sessionManager.getUserId();
      if (userId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(ID: userId),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    const Row(
                      children: [
                        Text(
                          'Sign In',
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: mainColor),
                        ),
                        SizedBox(width: 15),
                        Icon(Icons.airplane_ticket_outlined),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const SizedBox(height: 16),
                    SizedBox(
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign Up dulu deh',
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ),
                    const SizedBox(height: 32),
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                setState(() {
                                  isLoading = true;
                                });
                                String email = _emailController.text;
                                String password = _passwordController.text;

                                try {
                                  UserCredential userCredential =
                                      await FirebaseAuth.instance
                                          .signInWithEmailAndPassword(
                                    email: email,
                                    password: password,
                                  );
                                  String userId =
                                      userCredential.user?.uid ?? '';
                                  await _sessionManager.saveUserSession(userId);
                                  MyMessage.showSnackBar(
                                      _scaffoldMessengerKey, 'Signing In...');
                                  setState(() {
                                    _emailController.clear();
                                    _passwordController.clear();
                                    _formKey.currentState?.reset();
                                  });

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MainScreen(ID: userId),
                                    ),
                                  );
                                } on FirebaseAuthException catch (e) {
                                  MyMessage.showSnackBar(_scaffoldMessengerKey,
                                      'Failed with error: ${e.message}');
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
                                    _scaffoldMessengerKey, "Validation Failed");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 32),
                                    Text(
                                      'Sign In',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 16),
                                    ),
                                  ],
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
