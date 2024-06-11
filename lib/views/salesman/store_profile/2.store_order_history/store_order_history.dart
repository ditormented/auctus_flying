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
        padding: const EdgeInsets.all(6),
      ),
      endChild: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: mainColor,
          textColor: Colors.white,
          dense: true,
          title: Text(
            "$formattedDate, $formattedTime",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            "Total: Rp.${total.round()}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          children: [
            Container(
              padding:
                  const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
              color: Colors.white.withOpacity(0.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      for (var item in items)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 8, right: 8),
                                child: Icon(Icons.circle,
                                    size: 8, color: Colors.white),
                              ),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.475,
                                child: Text(
                                  '${item['Name']}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Rp.${item['ppnPrice']}",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                        Text(
                                          "Qty: ${item['quantity']}",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      // Container(
      //   constraints: const BoxConstraints(minHeight: 80),
      //   padding: const EdgeInsets.all(16),
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       Text(
      //         formattedTime,
      //         style: const TextStyle(fontWeight: FontWeight.bold),
      //       ),
      //       const SizedBox(height: 8),
      //       Text(
      //         formattedDate,
      //         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      //       ),
      //       Text(
      //         'Total: Rp.${total.toStringAsFixed(2)}',
      //         style: const TextStyle(color: Colors.grey),
      //       ),
      //       const SizedBox(height: 8),
      //       const Text(
      //         'Items:',
      //         style: TextStyle(color: Colors.grey),
      //       ),
      //       for (var item in items)
      //         Padding(
      //           padding: const EdgeInsets.symmetric(vertical: 4.0),
      //           child: Text(
      //             '- ${item['Name']}',
      //             style: const TextStyle(color: Colors.black),
      //           ),
      //         ),
      //     ],
      //   ),
      // ),
      beforeLineStyle: const LineStyle(
        color: Colors.grey,
        thickness: 2,
      ),
    );
  }
}
