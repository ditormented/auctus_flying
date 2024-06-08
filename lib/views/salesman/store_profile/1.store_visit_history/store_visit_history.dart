import 'package:auctus_call/views/salesman/store_profile/2.store_order_history/purchase_document_object.dart';
import 'package:auctus_call/views/salesman/store_profile/store_object.dart';
import 'package:flutter/material.dart';

class StoreVisitHistory extends StatefulWidget {
  final StoreObject storeObject;
  final String userID;
  const StoreVisitHistory(
      {super.key, required this.storeObject, required this.userID});

  @override
  _StoreVisitHistoryState createState() => _StoreVisitHistoryState();
}

List<PurchaseDocumentObject> listPurchase = [];

class _StoreVisitHistoryState extends State<StoreVisitHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Visit History'),
        backgroundColor: Colors.blue,
      ),
      body: Container(),
    );
  }
}
