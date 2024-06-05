import 'package:auctus_call/utilities/categ_list.dart';
import 'package:auctus_call/utilities/colors.dart';
import 'package:auctus_call/views/salesman/form_call.dart';
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
  void getUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.documentID)
          .get();

      if (userDoc.exists) {
        setState(() {
          _userName = userDoc['name'];
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
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
    double dynamicFontSize = screenWidth * 0.08;
    String currentDate = DateFormat.yMMMMd().format(DateTime.now());

    final List<Map<String, dynamic>> listTileData = [
      {
        'title': 'Form Scraping',
        'subtitle': 'Click to input scraping data',
        'icon': Icons.search,
        'page': (String documentID) => ScrapingForm(
            documentID: documentID), // Closure that creates the page
      },
      {
        'title': 'Form Call',
        'subtitle': 'Click to input call data',
        'icon': Icons.sailing_outlined,
        'page': (String documentID, String callID) => FormCall(
              documentID: documentID,
              callID: callID,
            ), // Closure that creates the page
      },
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            collapsedHeight: screenHeight * 0.1,
            backgroundColor: terColor,
            expandedHeight: screenHeight * 0.18,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: mainColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: screenWidth * 0.1,
                              height: screenHeight * 0.1,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                  image: AssetImage('images/auctus_logo.png'),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Welcome $_userName !!",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: dynamicFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    currentDate,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: dynamicFontSize * 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = listTileData[index];
                return SizedBox(
                  height: 200,
                  width: screenWidth * 0.8,
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    child: InkWell(
                      onTap: () {
                        if (item['title'] == 'Form Scraping') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  item['page'](widget.documentID),
                            ),
                          );
                        } else if (item['title'] == 'Form Call') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => item['page'](
                                  widget.documentID, widget.callID),
                            ),
                          );
                        }
                      },
                      child: ListTile(
                        leading: Icon(item['icon'], color: mainColor),
                        title: Text(item['title']),
                        subtitle: Text(item['subtitle']),
                        trailing: const Icon(Icons.arrow_forward),
                        tileColor:
                            index % 2 == 0 ? Colors.grey[200] : Colors.white,
                      ),
                    ),
                  ),
                );
              },
              childCount: listTileData.length,
            ),
          ),
        ],
      ),
    );
  }
}
