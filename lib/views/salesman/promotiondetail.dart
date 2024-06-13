import 'package:auctus_call/utilities/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class PromotionDetail extends StatefulWidget {
  final String promotionID;

  const PromotionDetail({
    super.key,
    required this.promotionID,
  });

  @override
  State<PromotionDetail> createState() => _PromotionDetailState();
}

class _PromotionDetailState extends State<PromotionDetail> {
  String title = '';
  String description = '';
  String period = '';
  String imageUrl = '';
  bool isClaim = false;
  String promotionID = '';

  @override
  void initState() {
    super.initState();
    _fetchPromotionData();
  }

  void _fetchPromotionData() async {
    final DocumentSnapshot promotionSnapshot = await FirebaseFirestore.instance
        .collection('promotion')
        .doc(widget.promotionID)
        .get();
    setState(() {
      title = promotionSnapshot['title'];
      description = promotionSnapshot['description'];
      period = promotionSnapshot['periode'];
      imageUrl = promotionSnapshot['bannerURL'];
      isClaim = promotionSnapshot['isClaim'];
    });
    // final Map<String, dynamic> data =
    //     promotionSnapshot.data() as Map<String, dynamic>;
    // final String bannerURL =
    //     await FirebaseStorage.instance.ref(data['bannerURL']).getDownloadURL();

    // data['bannerURL'] = bannerURL;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Promotion Detail',
            style: TextStyle(color: Colors.white),
          ),
          foregroundColor: Colors.white,
          backgroundColor: mainColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Image.network(
              //   data['bannerURL'],
              //   fit: BoxFit.cover,
              // ),
            ],
          ),
        ));
  }
}
