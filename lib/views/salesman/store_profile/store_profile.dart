// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:auctus_call/utilities/colors.dart';
import 'package:auctus_call/views/salesman/store_profile/1.store_visit_history/call_document_object.dart';
import 'package:auctus_call/views/salesman/store_profile/1.store_visit_history/store_visit_history.dart';
import 'package:auctus_call/views/salesman/store_profile/2.store_order_history/purchase_document_object.dart';
import 'package:auctus_call/views/salesman/store_profile/2.store_order_history/store_order_history.dart';
import 'package:auctus_call/views/salesman/store_profile/store_league.dart';
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

  TextEditingController addressByGeoReverseController = TextEditingController();
  TextEditingController addressBySalesmanController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController joiningDateController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

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
        setState(() {
          imagePhotoTokoX = file;
          latitudeController.text = position.latitude.toString();
          longitudeController.text = position.longitude.toString();
        });

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

            setState(() {
              addressByGeoReverseController.text =
                  "$street, $subLocality, $locality, $administrativeArea, $country";
            });
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
        'store_images/${widget.storeObject.storeId}-${DateTime.now()}.jpg');
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

  Future<void> getStoreDetail() async {
    CollectionReference stores =
        FirebaseFirestore.instance.collection('stores');
    var storeDoc = await stores.doc(widget.storeObject.storeId).get();

    if (storeDoc.exists) {
      var data = storeDoc.data() as Map<String, dynamic>;

      setState(() {
        storeObject = StoreObject(
          storeId: widget.storeObject.storeId,
          address: data['address'] ?? '',
          contactToko: data['contactToko'] ?? '',
          email: data['email'] ?? '',
          name: data['name'] ?? '',
          picName: data['picName'] ?? '',
          selectedCategory: data['selectedCategory'] ?? '',
          selectedKabupaten: data['selectedKabupaten'] ?? '',
          selectedPlan: data['selectedPlan'] ?? '',
          selectedProvince: data['selectedProvince'] ?? '',
          status: data['status'] ?? '',
          storeName: data['storeName'] ?? '',
          visitDate: DateTime.now(), // Jika visitDate tidak ada di data
          latitude: data['latitude'] ?? 0.0,
          longitude: data['longitude'] ?? 0.0,
          storeImageUrl: data['storeImageUrl'] ?? '',
          reverseGeotagging: data['reverseGeotagging'] ?? '',
        );
      });
      setState(() {
        addressByGeoReverseController.text = storeObject.reverseGeotagging;
        addressBySalesmanController.text = storeObject.address;
        latitudeController.text = storeObject.latitude.toString();
        longitudeController.text = storeObject.longitude.toString();
        joiningDateController.text =
            DateFormat('d MMM yyyy').format(storeObject.visitDate);
        phoneNumberController.text = storeObject.contactToko;
      });
      collectAllCall();
    }
  }

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
            documentID: doc.id,
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
              setState(() {
                listPurchase.sort((a, b) => a.timestamp.compareTo(b.timestamp));
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
      listCall1.sort((a, b) => a.dateTime.compareTo(b.dateTime));
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
    getStoreDetail();
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
                child: Row(
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
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Transaksi',
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Rp. $totalPurchases',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
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
                          const SizedBox(width: 8),
                          _historyButton(
                              selectHistory: EnumSelectHistory.orderHistory,
                              list: listPurchase),
                          const SizedBox(width: 8),
                          _historyButton(
                              selectHistory: EnumSelectHistory.storeLeague),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _textField(EnumForm.joinDate),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _textField(EnumForm.phoneNumber),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Text(
                          "Validasi Lokasi",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    imagePhotoTokoX == null
                        ? storeObject.storeImageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
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
                                ),
                              )
                            : const Icon(
                                Icons.image,
                                size: 100,
                                color: Colors.grey,
                              )
                        : Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12)),
                            child: Image.file(
                              File(imagePhotoTokoX!.path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200,
                            ),
                          ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        getPhotoToko();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      icon: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Update data geolocation',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _textField(EnumForm.latitude),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _textField(EnumForm.longitude),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: addressByGeoReverseController,
                      minLines: 1,
                      maxLines: null,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Reverse Geotagging (GPS Address)',
                        labelStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight:
                                FontWeight.bold), // Change the label style
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2, color: Colors.grey.shade300),
                        ),
                      ),
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black), // Change the input text style
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextField(
                      controller: addressBySalesmanController,
                      minLines: 1,
                      maxLines: null,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Address by salesman',
                        labelStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight:
                                FontWeight.bold), // Change the label style
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2, color: Colors.grey.shade300),
                        ),
                      ),
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black), // Change the input text style
                    ),
                  ],
                ),
              ),
              // validasi lokasi => finish
            ],
          ),
        ),
      ),
    );
  }

  Widget _historyButton({
    required EnumSelectHistory selectHistory,
    List<PurchaseDocumentObject>? list,
  }) {
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
                      ? StoreOrderHistory(
                          userID: widget.userID,
                          listPurchase: list ?? [],
                        )
                      : StoreLeague(),
            ),
          );
          if (selectHistory == EnumSelectHistory.visitHistory) {
          } else if (selectHistory == EnumSelectHistory.orderHistory) {}
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 3, color: Colors.blue.shade900),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            selectHistory.name == EnumSelectHistory.visitHistory.name
                ? 'Visit\nHistory'
                : selectHistory.name == EnumSelectHistory.orderHistory.name
                    ? 'Order\nHistory'
                    : 'Store\nLeague',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField(EnumForm enumForm) {
    return TextField(
      controller: enumForm == EnumForm.latitude
          ? latitudeController
          : enumForm == EnumForm.longitude
              ? longitudeController
              : enumForm == EnumForm.joinDate
                  ? joiningDateController
                  : phoneNumberController,
      minLines: 1,
      maxLines: null,
      readOnly: true,
      decoration: InputDecoration(
        labelText: enumForm == EnumForm.latitude
            ? 'Latitude'
            : enumForm == EnumForm.longitude
                ? 'Longitude'
                : enumForm == EnumForm.joinDate
                    ? 'Join date'
                    : 'Phone number',
        labelStyle: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.bold), // Change the label style
        border: const OutlineInputBorder(
          borderSide: BorderSide(width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 2, color: Colors.grey.shade300),
        ),
      ),
      style: const TextStyle(
          fontSize: 14, color: Colors.black), // Change the input text style
    );
  }
}

enum EnumForm {
  latitude,
  longitude,
  joinDate,
  phoneNumber,
}

enum EnumSelectHistory {
  visitHistory,
  orderHistory,
  storeLeague,
}
