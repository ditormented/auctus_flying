// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:auctus_call/utilities/colors.dart';
import 'package:auctus_call/views/salesman/store_profile/1.store_visit_history/call_document_object.dart';
import 'package:auctus_call/views/salesman/store_profile/2.store_order_history/purchase_document_object.dart';
import 'package:auctus_call/views/salesman/store_profile/1.store_visit_history/store_visit_history.dart';
import 'package:auctus_call/views/salesman/store_profile/2.store_order_history/store_order_history.dart';
import 'package:auctus_call/views/salesman/store_profile/store_object.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class StoreProfile extends StatefulWidget {
  final StoreObject storeObject;
  final String userID;
  const StoreProfile(
      {super.key, required this.storeObject, required this.userID});

  @override
  // ignore: library_private_types_in_public_api
  _StoreProfileState createState() => _StoreProfileState();
}

class _StoreProfileState extends State<StoreProfile> {
  final ImagePicker _picker = ImagePicker();
  XFile? imagePhotoTokoX;
  late StoreObject storeObject;

  Future getPhotoToko() async {
    late Position position;
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    try {
      XFile? file = await _picker.pickImage(
          source: ImageSource.camera,
          maxHeight: 1000,
          maxWidth: 1000,
          imageQuality: 75,
          preferredCameraDevice: CameraDevice.rear);

      if (file != null) {
        imagePhotoTokoX = file;
        storeObject.latitude = position.latitude;
        storeObject.longitude = position.longitude;

        // Get reverse geotagging
        try {
          List<Placemark>? placemarks = await placemarkFromCoordinates(
              position.latitude, position.longitude);
          if (placemarks == null || placemarks.isEmpty) {
            log("Placemarks list is null or empty.");
          } else {
            log("Placemarks: $placemarks");

            Placemark placemark = placemarks.first;

            String street = placemark.street ?? "";
            log("street: $street");
            String subLocality = placemark.subLocality ?? "";
            log("subLocality: $subLocality");
            String locality = placemark.locality ?? "";
            log("locality: $locality");
            String administrativeArea = placemark.administrativeArea ?? "";
            log("administrativeArea: $administrativeArea");
            String country = placemark.country ?? "";
            log("country: $country");

            storeObject.reverseGeotagging =
                "$street, $subLocality, $locality, $administrativeArea, $country";
            log("Reverse geolocation: ${storeObject.reverseGeotagging}");
          }
        } catch (e) {
          log("Error fetching reverse geotagging: $e");
        }

        // Upload the image to a cloud storage service and get the URL
        String storeImageUrl = await uploadImage(file);
        log("Uploaded image URL: $storeImageUrl");

        // Update Firestore
        await updateStoreData(storeImageUrl, position.latitude,
            position.longitude, storeObject.reverseGeotagging);
        log("Store data updated in Firestore.");
      }
    } catch (e) {
      imagePhotoTokoX = null;
      log("Error in getPhotoToko: $e");
    }
  }

  Future<String> uploadImage(XFile file) async {
    final storageRef = FirebaseStorage.instance.ref().child(
        'store_images/${widget.storeObject.storeId}${DateTime.now()}.jpg');
    await storageRef.putFile(File(file.path));
    return await storageRef.getDownloadURL();
  }

  Future updateStoreData(String storeImageUrl, double latitude,
      double longitude, String reverseGeolocation) async {
    DocumentReference storeRef = FirebaseFirestore.instance
        .collection('stores')
        .doc(storeObject.storeId);

    await storeRef.update({
      'storeImageUrl': storeImageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'reverseGeotagging': reverseGeolocation,
    });
  }

  List<PurchaseDocumentObject> listPurchase = [];
  List<CallDocumentObject> listCall = [];

  Future collectAllCall() async {
    log('storeObject.storeId ${storeObject.storeId}');

    try {
      QuerySnapshot callsSnapshot = await FirebaseFirestore.instance
          .collection('calls')
          .where('storeID', isEqualTo: storeObject.storeId)
          // .where('callResult', isEqualTo: "purchase")
          .get();

      log('callsSnapshot.docs.length: ${callsSnapshot.docs.length}'); // Log jumlah dokumen yang ditemukan

      List<CallDocumentObject> listCall1 = [];
      for (var doc in callsSnapshot.docs) {
        final data = doc.data()
            as Map<String, dynamic>?; // Cast to Map<String, dynamic>?
        Timestamp? docTimestamp = data?.containsKey('timestamp') == true
            ? doc['timestamp'] as Timestamp?
            : null;
        DateTime? visitDate = docTimestamp?.toDate();
        listCall1.add(
          CallDocumentObject(
            address: doc["address"] ?? '',
            callResult: doc["callResult"] ?? '',
            email: doc["email"] ?? '',
            imageUrl: doc["imageURL"] ?? '',
            kabupaten: doc["kabupaten"] ?? '',
            name: doc["name"] ?? '',
            picContact: doc["picContact"] ?? '',
            picName: doc["picName"] ?? '',
            planType: doc["planType"] ?? '',
            province: doc["province"] ?? '',
            status: doc["status"] ?? '',
            storeID: doc["storeID"] ?? '',
            storeName: doc["storeName"] ?? '',
            dateTime: visitDate ?? DateTime.now(),
          ),
        );
        log("callsSnapshot.timeStamp = ${doc["timestamp"]}");
        try {
          QuerySnapshot purchaseSnapshot = await FirebaseFirestore.instance
              .collection('purchases')
              .where('callID', isEqualTo: doc.id)
              .where('userID', isEqualTo: widget.userID)
              .get();

          if (purchaseSnapshot.docs.isNotEmpty) {
            var purchaseDoc = purchaseSnapshot.docs[0];
            log("purchaseSnapshot.id => ${purchaseDoc['timestamp']}");

            try {
              List<Map<String, dynamic>> items =
                  List<Map<String, dynamic>>.from(purchaseDoc["items"]);
              setState(() {
                listPurchase.add(
                  PurchaseDocumentObject(
                    callID: purchaseDoc["callID"] ?? '',
                    items: items,
                    // timestamp: purchaseDoc["timestamp"].isNotEmpty
                    //     ? (purchaseDoc["timestamp"] as Timestamp).toDate()
                    //     : DateTime.now(),
                    timestamp: (purchaseDoc["timestamp"] as Timestamp).toDate(),
                    total: purchaseDoc["total"] ?? 0.0,
                    userID: purchaseDoc["userID"] ?? '',
                    caption: purchaseDoc["caption"],
                  ),
                );
              });
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
      setState(() {
        listCall = listCall1;
      });
    } catch (e) {
      log("Error getting calls documents => $e");
    }

    log('listCallID -> ${listCall.length}');
    log('listPurchase -> $listPurchase');
    calculateTotalPurchases(listPurchase);
  }

  int totalPurchases = 0;
  Future calculateTotalPurchases(
      List<PurchaseDocumentObject> listPurchase) async {
    int totalPembelian = 0;
    for (var element in listPurchase) {
      log("for listPurchase => ${element.callID}");
      totalPembelian += element.total
          .round(); // Menambahkan total dari setiap elemen ke totalPembelian
    }

    setState(() {
      totalPurchases =
          totalPembelian; // Mengupdate totalPurchases dengan nilai totalPembelian
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    storeObject = widget.storeObject;
    collectAllCall();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title:
            const Text('Store Detail', style: TextStyle(color: Colors.white)),
        backgroundColor: mainColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue,
                          child:
                              Icon(Icons.store, size: 30, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              storeObject.storeName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: const Text(
                                'online store',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tanggal Bergabung : ${DateFormat('d MMM yyyy').format(storeObject.visitDate)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No.Telp : ${storeObject.contactToko}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: mainColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Text(
                            "Riwayat Transaksi",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Total Transaksi',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Rp. $totalPurchases',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Menu History",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _historyButton(
                              selectHistory: EnumSelectHistory.visitHistory),
                          _historyButton(
                              selectHistory: EnumSelectHistory.orderHistory,
                              list: listPurchase),
                          _historyButton(
                              selectHistory: EnumSelectHistory.storeLeague),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: mainColor,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Text(
                            "Validasi Lokasi",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      storeObject.storeImageUrl.isNotEmpty
                          ? Image.network(
                              storeObject.storeImageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.error,
                                size: 100,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.image,
                              size: 100,
                              color: Colors.white,
                            ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          getPhotoToko();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        icon: const Icon(
                          Icons.gps_fixed_rounded,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Update data GPS',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      storeObject.latitude != null &&
                              storeObject.longitude != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _latLongContainer('Latitude',
                                    storeObject.latitude.toString()),
                                _latLongContainer('Longitude',
                                    storeObject.longitude.toString()),
                              ],
                            )
                          : Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: const Text(
                                "Latitude / longitude tidak ditemukan!",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Reverse Geotagging (Alamat GPS)',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              storeObject.reverseGeotagging,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            const Text(
                              'Alamat input by Salesman',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              storeObject.address,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _historyButton(
      {required EnumSelectHistory selectHistory,
      List<PurchaseDocumentObject>? list}) {
    print("_historyButton listPurchase ${listPurchase.length}");
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => selectHistory ==
                      EnumSelectHistory.visitHistory
                  ? StoreVisitHistory(listCall: listCall, userID: widget.userID)
                  : selectHistory == EnumSelectHistory.orderHistory
                      // ? const StoreOrderHistory(
                      //     listCall: listCall, userID: widget.userID)
                      // : const StoreOrderHistory(
                      //     listCall: listCall, userID: widget.userID),
                      ? StoreOrderHistory(
                          userID: widget.userID,
                          listPurchase: list ?? [],
                        )
                      : StoreOrderHistory(
                          userID: widget.userID,
                          listPurchase: list ?? [],
                        ),
            ),
          );
          if (selectHistory == EnumSelectHistory.visitHistory) {
          } else if (selectHistory == EnumSelectHistory.orderHistory) {}
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.blue),
          ),
          child: Text(
            selectHistory.name == EnumSelectHistory.visitHistory.name
                ? 'Visit History'
                : selectHistory.name == EnumSelectHistory.orderHistory.name
                    ? 'Order History'
                    : 'Store League',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _latLongContainer(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.blue),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum EnumSelectHistory {
  visitHistory,
  orderHistory,
  storeLeague,
}
