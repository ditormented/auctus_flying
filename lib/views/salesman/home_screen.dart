import 'package:auctus_call/utilities/colors.dart';
import 'package:auctus_call/views/salesman/form_call.dart';
import 'package:auctus_call/views/salesman/product_list.dart';
import 'package:auctus_call/views/salesman/promotion_list.dart';
import 'package:auctus_call/views/salesman/scraping_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  final String documentID;
  final String callID;

  const HomeScreen({
    super.key,
    required this.documentID,
    required this.callID,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  String _userEmail = '';
  int _storeCount = 0;
  int _callCount = 0;
  int _ecTotal = 0;
  int _rejectTotal = 0;

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
        });
        getStoreCount();
        getCallTotal();
        getECtotal();
        getRejectTotal();
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void getStoreCount() async {
    try {
      DateTime startOfDay = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      DateTime endOfDay = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 23, 59, 59);
      QuerySnapshot storeSnapshot = await FirebaseFirestore.instance
          .collection('stores')
          .where('email', isEqualTo: _userEmail)
          // .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          // .where('timestamp', isLessThanOrEqualTo: endOfDay)
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
      DateTime startOfDay = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      DateTime endOfDay = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 23, 59, 59);
      QuerySnapshot storeSnapshot = await FirebaseFirestore.instance
          .collection('calls')
          .where('email', isEqualTo: _userEmail)
          // .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          // .where('timestamp', isLessThanOrEqualTo: endOfDay)
          .get();

      setState(() {
        _callCount = storeSnapshot.docs.length;
      });
    } catch (e) {
      print('Error fetching call count: $e');
    }
  }

  void getECtotal() async {
    try {
      DateTime startOfDay = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      DateTime endOfDay = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 23, 59, 59);
      QuerySnapshot storeSnapshot = await FirebaseFirestore.instance
          .collection('calls')
          .where('email', isEqualTo: _userEmail)
          .where('callResult', isEqualTo: 'purchase')
          // .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          // .where('timestamp', isLessThanOrEqualTo: endOfDay)
          .get();

      setState(() {
        _ecTotal = storeSnapshot.docs.length;
      });
    } catch (e) {
      print('Error fetching EC count: $e');
    }
  }

  void getRejectTotal() async {
    try {
      DateTime startOfDay = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      DateTime endOfDay = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 23, 59, 59);
      QuerySnapshot storeSnapshot = await FirebaseFirestore.instance
          .collection('calls')
          .where('email', isEqualTo: _userEmail)
          .where('callResult', isEqualTo: 'reject')
          // .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          // .where('timestamp', isLessThanOrEqualTo: endOfDay)
          .get();

      setState(() {
        _rejectTotal = storeSnapshot.docs.length;
      });
    } catch (e) {
      print('Error fetching EC count: $e');
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
                            SizedBox(height: 8),
                            Text(
                              'Main Menu',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: mainColor,
                              ),
                            ),
                            SizedBox(height: 8),
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
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Store Scraping',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(
                                height: 8), // Menambahkan jarak antara tombol
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FormCall(
                                      documentID: widget.documentID,
                                      callID: widget.callID,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainColor,
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Text(
                                'Form Call',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PromotionListScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainColor,
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Text(
                                'Promotion Info',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Daily Update',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: mainColor,
                              ),
                            ),
                            SizedBox(height: 8),
                            GridView.count(
                              shrinkWrap: true,
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 38, 77, 141),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  icon: Icon(Icons.store, color: Colors.white),
                                  label: Text(
                                      'Store Scraped Total ($_storeCount)',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 194, 162, 47),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  icon: Icon(Icons.call, color: Colors.white),
                                  label: Text('Amount Of Call ($_callCount)',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 24, 120, 97),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  icon: Icon(Icons.check_circle,
                                      color: Colors.white),
                                  label: Text('Effective Call ($_ecTotal)',
                                      style: TextStyle(color: Colors.white)),
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
                                  icon: Icon(Icons.cancel, color: Colors.white),
                                  label: Text('Rejected Call ($_rejectTotal)',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
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

  ProfileHeader({
    required this.screenWidth,
    required this.screenHeight,
    required this.dynamicFontSize,
    required this.currentDate,
    required this.userName,
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
                child: Icon(Icons.person, size: 40, color: mainColor),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentDate,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Role',
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
