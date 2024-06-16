import 'dart:async';
import 'package:auctus_call/utilities/colors.dart';
import 'package:auctus_call/views/salesman/home_screen.dart';
import 'package:auctus_call/views/salesman/home_screen_user.dart';
import 'package:auctus_call/views/salesman/product_list.dart';
import 'package:auctus_call/views/salesman/profile_screen.dart';
import 'package:auctus_call/views/salesman/store_profile/store_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:auctus_call/views/salesman/session.dart';

class MainScreen extends StatefulWidget {
  final String ID;
  const MainScreen({super.key, required this.ID});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _pageIndex = 0;
  Timer? timer;
  bool isTimerActive = false;
  bool isLocationServiceCalled = false;
  bool isCameraServiceCalled = false;
  String _userRole = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await _getUserRole(); // Mendapatkan peran pengguna
    if (!isTimerActive) {
      timerPermission();
    }
  }

  Future<void> _getUserRole() async {
    final SessionManager sessionManager = SessionManager();
    String? role = await sessionManager.getRole();
    setState(() {
      _userRole = role ?? '';
      _isLoading = false;
    });
  }

  void timerPermission() {
    setState(() {
      isTimerActive = true;
    });
    timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      checkLocationService();
      checkCameraService();
      if (isLocationServiceCalled && isCameraServiceCalled) {
        timer.cancel();
      }
    });
  }

  void checkLocationService() async {
    PermissionStatus locationStatus = await Permission.location.status;

    if (locationStatus == PermissionStatus.granted) {
      setState(() {
        isLocationServiceCalled = true;
      });
    } else {
      await Permission.location.request();
      setState(() {
        isLocationServiceCalled = true;
      });
    }
  }

  void checkCameraService() async {
    PermissionStatus cameraStatus = await Permission.camera.status;
    if (cameraStatus == PermissionStatus.granted) {
      setState(() {
        isCameraServiceCalled = true;
      });
    } else {
      await Permission.camera.request();
      setState(() {
        isCameraServiceCalled = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final List<Widget> pages =
        _userRole == 'Administrator' || _userRole == 'Head Of C2C'
            ? [
                HomeScreen(documentID: widget.ID),
                ProductList(userID: widget.ID),
                StoreList(userID: widget.ID),
                ProfileScreen(documentID: widget.ID),
              ]
            : [
                HomeScreenUser(documentID: widget.ID),
                ProductList(userID: widget.ID),
                StoreList(userID: widget.ID),
                ProfileScreen(documentID: widget.ID),
              ];

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _pageIndex,
        onTap: (value) {
          setState(() {
            _pageIndex = value;
          });
        },
        unselectedItemColor: Colors.grey,
        selectedItemColor: mainColor,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Product'),
          BottomNavigationBarItem(
              icon: Icon(Icons.store), label: 'Store Profile'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person), label: 'Profile')
        ],
      ),
      body: pages[_pageIndex],
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
