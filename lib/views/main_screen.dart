import 'dart:async';

import 'package:auctus_call/utilities/colors.dart';
import 'package:auctus_call/views/salesman/form_call.dart';
import 'package:auctus_call/views/salesman/home_screen.dart';
import 'package:auctus_call/views/salesman/product_list.dart';
import 'package:auctus_call/views/salesman/profile_screen.dart';
import 'package:auctus_call/views/salesman/store_profile/store_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class MainScreen extends StatefulWidget {
  final String ID;
  const MainScreen({super.key, required this.ID});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _pageIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  Timer? timer;
  bool isTimerActive = false;
  timerPermission() {
    setState(() {
      isTimerActive = true;
    });
    timer = Timer.periodic(const Duration(milliseconds: 2000), (timer) {
      checkLocationService();
      checkCameraService();
      if (isLocationServiceCalled == true && isCameraServiceCalled == true) {
        timer.cancel();
      }
    });
  }

  bool isLocationServiceCalled = false;
  bool isCameraServiceCalled = false;

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
        isLocationServiceCalled = true;
      });
    }
  }

  init() async {
    if (isTimerActive = true) {
      timerPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(documentID: widget.ID),
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
}
