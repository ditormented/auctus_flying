import 'dart:async';
import 'dart:developer';

import 'package:auctus_call/views/salesman/store_profile/1.store_visit_history/purchase_document_object.dart';
import 'package:auctus_call/views/salesman/store_profile/store_object.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StoreVisitHistory extends StatefulWidget {
  final StoreObject storeObject;
  final String userID;
  StoreVisitHistory(
      {super.key, required this.storeObject, required this.userID});

  @override
  _StoreVisitHistoryState createState() => _StoreVisitHistoryState();
}

List<PurchaseDocumentObject> listPurchase = [];

class _StoreVisitHistoryState extends State<StoreVisitHistory> {
  Future collectAllCall() async {
  log('widget.storeObject.storeId ${widget.storeObject.storeId}');
  List<String> listCallID = [];
  List<PurchaseDocumentObject> listPurchase = [];

  try {
    QuerySnapshot callsSnapshot = await FirebaseFirestore.instance
        .collection('calls')
        .where('storeID', isEqualTo: widget.storeObject.storeId)
        .where('callResult', isEqualTo: "purchase")
        .get();

    log('callsSnapshot.docs.length: ${callsSnapshot.docs.length}'); // Log jumlah dokumen yang ditemukan

    for (var doc in callsSnapshot.docs) {
      listCallID.add(doc.id);
      try {
        QuerySnapshot purchaseSnapshot = await FirebaseFirestore.instance
            .collection('purchases')
            .where('callID', isEqualTo: doc.id)
            .get();
        
        if (purchaseSnapshot.docs.isNotEmpty) {
          var purchaseDoc = purchaseSnapshot.docs[0];
          log("purchaseSnapshot.id => ${purchaseDoc.id}");

          try {
            List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(purchaseDoc["items"]);
            listPurchase.add(
              PurchaseDocumentObject(
                callID: purchaseDoc["callID"] ?? '',
                items: items,
                timestamp: (purchaseDoc["timestamp"] as Timestamp).toDate(),
                total: purchaseDoc["total"] ?? 0.0,
                userID: purchaseDoc["userID"] ?? '',
              ),
            );
          } catch (e) {
            log("listPurchase.add error => $e");
          }
        } else {
          log("No purchase document found for callID: ${doc.id}");
        }
      } catch (e) {
        log("Error getting purchase document with ID ${doc.id} => $e");
      }
    }
  } catch (e) {
    log("Error getting calls documents => $e");
  }

  log('listCallID -> ${listCallID.length}');
  log('listPurchase -> $listPurchase');
}

  int totalPurchases = 0;
  Future calculateTotalPurchases() async {
    int total = 0;
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('purchases')
          // .where('call', isEqualTo: widget.userID)
          .where('storeID', isEqualTo: widget.storeObject.storeId)
          .get();

      for (var doc in querySnapshot.docs) {
        final data = doc.data()
            as Map<String, dynamic>?; // Cast to Map<String, dynamic>?
        if (data != null && data.containsKey('total')) {
          total += (data['total'] as num).toInt();
        }
      }
    } catch (e) {
      log('Error calculating total purchases: $e');
    }

    setState(() {
      totalPurchases = total;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // calculateTotalPurchases();
    collectAllCall();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Visit History'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.store, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.storeObject.storeName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'ID - Address',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                '$totalPurchases',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusButton('VH'),
                _buildStatusButton('OH'),
                _buildStatusButton('SH'),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'GPS Coordinate',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Text(
                'online store',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.blue),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
