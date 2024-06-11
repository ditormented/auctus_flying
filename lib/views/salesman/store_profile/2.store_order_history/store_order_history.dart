import 'dart:developer';
import 'package:auctus_call/utilities/colors.dart';
import 'package:auctus_call/views/salesman/store_profile/2.store_order_history/purchase_document_object.dart';
import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoreOrderHistory extends StatefulWidget {
  final String userID;
  final List<PurchaseDocumentObject> listPurchase;
  const StoreOrderHistory(
      {super.key, required this.userID, required this.listPurchase});

  @override
  _StoreOrderHistoryState createState() => _StoreOrderHistoryState();
}

class _StoreOrderHistoryState extends State<StoreOrderHistory> {
  List<PurchaseDocumentObject> listPurchase = [];

  Future<void> collectAllPurchases() async {
    try {
      // QuerySnapshot purchaseSnapshot = await FirebaseFirestore.instance
      //     .collection('purchases')
      //     .where('userID', isEqualTo: widget.userID)
      //     .get();

      // List<PurchaseDocumentObject> listPurchaseTemp = [];
      // for (var doc in purchaseSnapshot.docs) {
      //   final data = doc.data() as Map<String, dynamic>;
      //   Timestamp timestamp = data['timestamp'];
      //   DateTime purchaseDate = timestamp.toDate();

      //   listPurchaseTemp.add(
      //     PurchaseDocumentObject(
      //       callID: data['callID'] ?? '',
      //       items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      //       timestamp: purchaseDate,
      //       total: data['total'] ?? 0.0,
      //       userID: data['userID'] ?? '',
      //       caption: '',
      //     ),
      //   );
      // }
      log('jumlah list Purchase${widget.listPurchase.length}');
      setState(() {
        listPurchase = widget.listPurchase;
      });
    } catch (e) {
      print('Error fetching purchase history: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    collectAllPurchases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order History',
          style: TextStyle(color: Colors.white),
        ),
        foregroundColor: Colors.white,
        backgroundColor: mainColor,
      ),
      body: ListView.builder(
        itemCount: listPurchase.length,
        itemBuilder: (context, index) {
          return timelineTile(
            context,
            time: listPurchase[index].timestamp,
            total: listPurchase[index].total,
            items: listPurchase[index].items,
            isFirst: index == 0,
            isLast: index == listPurchase.length - 1,
          );
        },
      ),
    );
  }

  TimelineTile timelineTile(BuildContext context,
      {required DateTime time,
      required double total,
      required List<Map<String, dynamic>> items,
      bool isFirst = false,
      bool isLast = false}) {
    final DateFormat timeFormat = DateFormat('HH:mm');
    final DateFormat dateFormat = DateFormat('EEE, dd MMM yyyy');
    String formattedTime = timeFormat.format(time);
    String formattedDate = dateFormat.format(time);

    return TimelineTile(
      alignment: TimelineAlign.start,
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: IndicatorStyle(
        width: 20,
        color: isFirst || isLast ? Colors.purple : Colors.teal,
        padding: EdgeInsets.all(6),
      ),
      endChild: Container(
        constraints: BoxConstraints(minHeight: 80),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedTime,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              formattedDate,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Total: \Rp.${total.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Items:',
              style: TextStyle(color: Colors.grey),
            ),
            for (var item in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  '- ${item['Name']}',
                  style: TextStyle(color: Colors.black),
                ),
              ),
          ],
        ),
      ),
      beforeLineStyle: LineStyle(
        color: Colors.grey,
        thickness: 2,
      ),
    );
  }
}
