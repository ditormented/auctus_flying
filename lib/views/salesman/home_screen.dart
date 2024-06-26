import 'dart:developer';
import 'package:auctus_call/views/salesman/inputpjp.dart';
import 'package:auctus_call/views/salesman/session.dart';
import 'package:auctus_call/utilities/colors.dart';
import 'package:auctus_call/views/salesman/form_call.dart';
import 'package:auctus_call/views/salesman/promotion_list.dart';
import 'package:auctus_call/views/salesman/scraping_form.dart';
import 'package:auctus_call/views/salesman/sign_up.dart';
import 'package:auctus_call/views/salesman/store_profile/store_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final String documentID;

  const HomeScreen({
    super.key,
    required this.documentID,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  String _userEmail = '';
  String _userRole = '';
  String? _imageUrl;
  int _storeCount = 0;
  int _callCount = 0;
  int _ecTotal = 0;
  int _rejectTotal = 0;
  DateTime _selectedDate = DateTime.now();
  final SessionManager _sessionManager = SessionManager();

  void getUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.documentID)
          .get();

      if (userDoc.exists) {
        setState(() {
          _userName = userDoc['name'];
          _userEmail = userDoc['email'];
          _userRole = userDoc['role'];
          _imageUrl = userDoc['imageProfile'];
        });
        fetchCounts();
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void fetchCounts() {
    getStoreCount();
    getCallTotal();
    getECtotal();
    getRejectTotal();
  }

  void getStoreCount() async {
    try {
      QuerySnapshot storeSnapshot = await FirebaseFirestore.instance
          .collection('stores')
          .where('email', isEqualTo: _userEmail)
          .get();

      setState(() {
        _storeCount = storeSnapshot.docs.length;
      });
    } catch (e) {
      print('Error fetching store count: $e');
    }
  }

  void getCallTotal() async {
    try {
      DateTime startOfDay = DateTime(_selectedDate.year, _selectedDate.month,
          _selectedDate.day, 00, 00, 00);
      DateTime endOfDay = DateTime(_selectedDate.year, _selectedDate.month,
          _selectedDate.day, 23, 59, 59);

      QuerySnapshot callSnapshot = await FirebaseFirestore.instance
          .collection('calls')
          .where('email', isEqualTo: _userEmail)
          // .where('timestamp',
          //     isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          // .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      setState(() {
        _callCount = callSnapshot.docs.length;
      });
    } catch (e) {
      print('Error fetching call count: $e');
    }
  }

  void getECtotal() async {
    try {
      DateTime startOfDay =
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      DateTime endOfDay = DateTime(_selectedDate.year, _selectedDate.month,
          _selectedDate.day, 23, 59, 59);

      QuerySnapshot ecSnapshot = await FirebaseFirestore.instance
          .collection('calls')
          .where('email', isEqualTo: _userEmail)
          .where('callResult', isEqualTo: 'purchase')
          // .where('timestamp',
          //     isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          // .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      setState(() {
        _ecTotal = ecSnapshot.docs.length;
      });
    } catch (e) {
      print('Error fetching EC count: $e');
    }
  }

  void getRejectTotal() async {
    try {
      DateTime startOfDay =
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      DateTime endOfDay = DateTime(_selectedDate.year, _selectedDate.month,
          _selectedDate.day, 23, 59, 59);

      QuerySnapshot rejectSnapshot = await FirebaseFirestore.instance
          .collection('calls')
          .where('email', isEqualTo: _userEmail)
          .where('callResult', isEqualTo: 'reject')
          // .where('timestamp',
          //     isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          // .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      setState(() {
        _rejectTotal = rejectSnapshot.docs.length;
      });
    } catch (e) {
      print('Error fetching reject count: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      fetchCounts();
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double dynamicFontSize = screenWidth * 0.05;
    String currentDate = DateFormat.yMMMMd().format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: ProfileHeader(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              dynamicFontSize: dynamicFontSize,
              currentDate: currentDate,
              userName: _userName,
              userRole: _userRole,
              imageUrl: _imageUrl,
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            const Text(
                              'Main Menu',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: mainColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ScrapingForm(
                                      documentID: widget.documentID,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainColor,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Store Scraping',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(
                                height: 8), // Menambahkan jarak antara tombol
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FormCall(
                                      documentID: widget.documentID,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainColor,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Form Call',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PromotionList(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainColor,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Promotion Info',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUpScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainColor,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Sign Up User',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InputPJP(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainColor,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Create PJP Salesman',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Daily Update',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: mainColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Selected Date: ${DateFormat.yMMMMd().format(_selectedDate)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: mainColor,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _selectDate(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Icon(Icons.calendar_today,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            GridView.count(
                              shrinkWrap: true,
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    StoreList(userID: widget.documentID);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 38, 77, 141),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  icon: const Icon(Icons.store,
                                      color: Colors.white),
                                  label: Text(
                                      'Store Scraped Total ($_storeCount)',
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    //   Navigator.push(
                                    // context,
                                    // MaterialPageRoute(
                                    //   builder: (context) => StoreList(
                                    //     userID: widget.,
                                    //   ),
                                    // ),
                                    // );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 194, 162, 47),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  icon: const Icon(Icons.call,
                                      color: Colors.white),
                                  label: Text('Amount Of Call ($_callCount)',
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 24, 120, 97),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  icon: const Icon(Icons.check_circle,
                                      color: Colors.white),
                                  label: Text('Effective Call ($_ecTotal)',
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 152, 69, 69),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  icon: const Icon(Icons.cancel,
                                      color: Colors.white),
                                  label: Text('Rejected Call ($_rejectTotal)',
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileHeader extends SliverPersistentHeaderDelegate {
  final double screenWidth;
  final double screenHeight;
  final double dynamicFontSize;
  final String currentDate;
  final String userName;
  final String userRole;
  final String? imageUrl;

  ProfileHeader({
    required this.screenWidth,
    required this.screenHeight,
    required this.dynamicFontSize,
    required this.currentDate,
    required this.userName,
    required this.userRole,
    this.imageUrl,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: mainColor,
      padding: EdgeInsets.only(
        top: 16.0 +
            MediaQuery.of(context)
                .padding
                .top, // Add top padding to accommodate the status bar
        left: 16.0,
        right: 16.0,
        bottom: 16.0,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align children to the start
        mainAxisAlignment:
            MainAxisAlignment.center, // Center the children vertically
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                backgroundImage: imageUrl != null
                    ? NetworkImage(imageUrl!)
                    : const AssetImage('images/auctus_logo.png')
                        as ImageProvider,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentDate,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    userRole,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => screenHeight * 0.18;

  @override
  double get minExtent => screenHeight * 0.18;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
