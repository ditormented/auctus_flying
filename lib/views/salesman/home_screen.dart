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
  int _storeCount = 0;
  int _callCount = 0;
  int _ecTotal = 0;
  int _rejectTotal = 0;
  DateTime _selectedDate = DateTime.now();

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
      DateTime startOfDay =
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      DateTime endOfDay = DateTime(_selectedDate.year, _selectedDate.month,
          _selectedDate.day, 23, 59, 59);

      QuerySnapshot storeSnapshot = await FirebaseFirestore.instance
          .collection('stores')
          .where('email', isEqualTo: _userEmail)
          // .where('timestamp',
          //     isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          // .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
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
      DateTime startOfDay =
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      DateTime endOfDay = DateTime(_selectedDate.year, _selectedDate.month,
          _selectedDate.day, 23, 59, 59);

      QuerySnapshot callSnapshot = await FirebaseFirestore.instance
          .collection('calls')
          .where('email', isEqualTo: _userEmail)
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
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
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
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
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
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
    getCallTotal();
    getStoreCount();
    getRejectTotal();
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
                                  borderRadius: BorderRadius.circular(20),
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
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainColor,
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
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
                                  borderRadius: BorderRadius.circular(20),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Selected Date: ${DateFormat.yMMMMd().format(_selectedDate)}',
                                  style: TextStyle(
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
                                  child: Icon(Icons.calendar_today,
                                      color: Colors.white),
                                ),
                              ],
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
