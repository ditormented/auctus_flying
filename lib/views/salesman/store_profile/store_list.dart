import 'dart:developer';
import 'package:auctus_call/utilities/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StoreList extends StatefulWidget {
  String userID;
  StoreList({super.key, required this.userID});

  @override
  State<StoreList> createState() => _StoreListState();
}

class _StoreListState extends State<StoreList> {
  CollectionReference stores = FirebaseFirestore.instance.collection('stores');
  TextEditingController searchStoreController = TextEditingController();
  List<StoreObject> listStore = [];
  List<StoreObject> filteredStore = [];
  String _userEmail = "";

  @override
  void initState() {
    super.initState();
    getUserData();
    fetchStores();
    searchStoreController.addListener(_filterStores);
  }

  @override
  void dispose() {
    searchStoreController.dispose();
    super.dispose();
  }

  void getUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userID)
          .get();

      if (userDoc.exists) {
        setState(() {
          _userEmail = userDoc['email'];
        });
        fetchStores(); // Call fetchStores only after _userEmail is set
      }
    } catch (e) {
      log('Error fetching user data: $e');
    }
  }

  void fetchStores() async {
    try {
      QuerySnapshot storeDocs = await stores.where("email", isEqualTo: _userEmail).get();
      setState(() {
        listStore = storeDocs.docs
            .map((doc) => StoreObject(
                storeId: doc.id,
                storeName: doc["storeName"],
                email: doc["email"]))
            .toList();
        filteredStore = listStore;
      });
    } catch (e) {
      log('Error fetching stores: $e');
    }
  }

  void _filterStores() {
    String query = searchStoreController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredStore = listStore;
      } else {
        filteredStore = listStore.where((store) {
          return store.storeName.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: Colors.white),
        //   onPressed: () {
        //     Navigator.of(context).pop();
        //   },
        // ),
        elevation: 5,
        toolbarHeight: 70,
        backgroundColor: mainColor,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            controller: searchStoreController,
            decoration: InputDecoration(
              hintText: 'Search...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.white,
              filled: true,
              prefixIcon: Icon(Icons.search, color: mainColor),
              contentPadding: EdgeInsets.symmetric(vertical: 10.0),
            ),
            style: TextStyle(color: mainColor),
          ),
        ),
      ),
      body: filteredStore.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: filteredStore.length,
              itemBuilder: (context, index) {
                final store = filteredStore[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: const EdgeInsets.all(8.0),
                  elevation: 5,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    title: Text(
                      store.storeName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      store.email,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    leading: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: mainColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Icon(Icons.store, color: mainColor, size: 30),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, color: mainColor),
                    onTap: () {
                      // Add navigation or other actions here
                    },
                  ),
                );
              },
            ),
    );
  }
}

class StoreObject {
  String storeName;
  String storeId;
  String email;
  StoreObject({required this.storeName, required this.storeId, required this.email});
}
