import 'package:auctus_call/utilities/colors.dart';
import 'package:auctus_call/views/salesman/catalog.dart';
import 'package:auctus_call/views/salesman/form_call.dart';
import 'package:auctus_call/views/salesman/form_noo.dart';
import 'package:auctus_call/views/salesman/home_screen.dart';
import 'package:auctus_call/views/salesman/main_catalog_screen.dart';
import 'package:auctus_call/views/salesman/profile_screen.dart';
import 'package:auctus_call/views/salesman/rejected_screen.dart';
import 'package:auctus_call/views/salesman/scraping_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final String ID;
  const MainScreen({super.key, required this.ID});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomeScreen(
        documentID: widget.ID,
        callID: widget.ID,
      ),
      RejectedScreen(storeID: widget.ID, callID: widget.ID),
      ProfileScreen(documentID: widget.ID),
      ScrapingForm(documentID: ''), // Add the ScrapingForm screen here
      FormCall(
        documentID: widget.ID,
        callID: widget.ID,
      ), // Add the FormCall screen here
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
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.circle_bottomthird_split),
              label: 'Activities'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.cart), label: 'Cart'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person), label: 'Profile')
        ],
      ),
      body: _pages[_pageIndex],
    );
  }
}
