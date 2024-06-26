import 'dart:developer';
import 'dart:io';

import 'package:auctus_call/utilities/categ_list.dart';
import 'package:auctus_call/utilities/colors.dart';
import 'package:auctus_call/views/salesman/main_catalog_screen.dart';
import 'package:auctus_call/views/salesman/rejected_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

enum PlanType { online, offline }

enum CallResult { purchase, reject }

class FormCall extends StatefulWidget {
  final String documentID;

  const FormCall({
    super.key,
    required this.documentID,
  });

  @override
  State<FormCall> createState() => _FormCallState();
}

class _FormCallState extends State<FormCall> {
  final ImagePicker _picker = ImagePicker();
  String imagePath = '';

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController picNameController = TextEditingController();
  TextEditingController picContactController = TextEditingController();
  TextEditingController searchStoreController = TextEditingController();

  PlanType? selectedPlan;
  CallResult? selectedCall;
  Province? selectedProvince;
  Kabupaten? selectedKabupaten;
  int selectedGridIndex = -1;
  CollectionReference stores = FirebaseFirestore.instance.collection('stores');
  CollectionReference calls = FirebaseFirestore.instance.collection('calls');
  bool _isChecked = false;

  List<String> storeNames = [];
  List<StoreObject> listStore = [];
  StoreObject? selectedStore;
  StoreObject? tempSelectedStore;
  String selectedStoreID = "";

  bool loadingButtonGetPhotoToko = false;
  void dialogGetLatLong(
      BuildContext context, String storeName, bool isOfflineStore,
      {double lat = 0.0, double long = 0.0}) async {
    if (lat == 0.0 || long == 0.0 && isOfflineStore) {
      showDialog(
        context: (context),
        builder: (context) {
          return StatefulBuilder(builder: (context, setStateBuilder) {
            return AlertDialog(
              title: RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade500),
                  children: [
                    const TextSpan(text: 'Data geolocation untuk toko'),
                    TextSpan(
                      text: ' $storeName',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const TextSpan(text: ' tidak lengkap!')
                  ],
                ),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "Silahkan lengkapi data Geolocation dengan mengambil foto tampak banner dari depan toko.",
                  style: TextStyle(
                      color: Colors.grey.shade400, fontWeight: FontWeight.bold),
                ),
              ),
              actions: [
                loadingButtonGetPhotoToko == false
                    ? Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                "Lain Kali",
                                style: TextStyle(
                                    color: mainColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setStateBuilder(() {
                                  loadingButtonGetPhotoToko = true;
                                });
                                setState(() {
                                  loadingButtonGetPhotoToko = true;
                                });
                                getPhotoToko(context).then((_) {
                                  fetchStores();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainColor,
                              ),
                              icon: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Lanjut",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const ElevatedButton(
                        onPressed: null,
                        child: Center(
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator()),
                        ),
                      )
              ],
            );
          });
        },
      );
    }
  }

  Future getPhotoToko(BuildContext context) async {
    ImagePicker _picker = ImagePicker();
    String geoReverseString = "";

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
        // Get reverse geotagging
        try {
          List<Placemark>? placemarks = await placemarkFromCoordinates(
              position.latitude, position.longitude);
          if (placemarks.isEmpty) {
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

            geoReverseString =
                "$street, $subLocality, $locality, $administrativeArea, $country";

            // log("Reverse geolocation: ${storeObject.reverseGeotagging}");
          }
        } catch (e) {
          log("Error fetching reverse geotagging: $e");
        }

        // ===> Upload the image to a cloud storage service and get the URL
        String storeImageUrl = await uploadStoreImage(file, selectedStoreID);
        log("Uploaded image URL: $storeImageUrl");

        // ===> Update Firestore
        await updateStoreData(
          storeImageUrl: storeImageUrl,
          lat: position.latitude,
          lng: position.longitude,
          reverseGeotagging: geoReverseString,
          storeId: selectedStoreID,
        );
        log("Store data updated in Firestore.");

        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green.shade800,
              content: const Text('Berhasil mengupdate data geolotagging toko',
                  style: TextStyle(color: Colors.white)),
            ),
          );
        }
      }
    } catch (e) {
      log("Error in getPhotoToko: $e");
    }
  }

  Future<String> uploadStoreImage(XFile file, String storeId) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('store_images/$storeId-${DateTime.now()}.jpg');
    await storageRef.putFile(File(file.path));
    return await storageRef.getDownloadURL();
  }

  Future updateStoreData({
    required String storeImageUrl,
    required double lat,
    required double lng,
    required String reverseGeotagging,
    required String storeId,
  }) async {
    DocumentReference storeRef =
        FirebaseFirestore.instance.collection('stores').doc(storeId);

    await storeRef.update({
      'storeImageUrl': storeImageUrl,
      'latitude': lat,
      'longitude': lng,
      'reverseGeotagging': reverseGeotagging,
    });
  }

  static Future<String> uploadImage(XFile imageFile) async {
    String fileName = basename(imageFile.name);
    final storage =
        FirebaseStorage.instanceFor(bucket: 'gs://auctussfa.appspot.com');
    Reference ref = storage.ref().child(fileName);
    UploadTask task = ref.putFile(File(imageFile.path));
    TaskSnapshot snapshot = await task;

    return snapshot.ref.getDownloadURL();
  }

  String emailString = '';
  void fetchUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.documentID)
        .get();

    if (userDoc.exists) {
      setState(() {
        emailController.text = userDoc['email'] ?? '';
        emailString = userDoc['email'] ?? '';
        nameController.text = userDoc['name'] ?? '';
      });
      fetchStores();
    }
  }

  Future fetchStores() async {
    listStore = [];
    log("emailString => $emailString");
    QuerySnapshot storeDocs =
        await stores.where('email', isEqualTo: emailString).get();
    setState(() {
      listStore = storeDocs.docs.map((doc) {
        log('store.email => ${doc['email']}');
        return StoreObject(storeId: doc.id, storeName: doc["storeName"]);
      }).toList();
    });
    await Future.delayed(Duration(milliseconds: 150));
    setState(() {
      loadingButtonGetPhotoToko = false;
    });
  }

  void fetchStoreDetails(
      BuildContext context, String storeID, String storeName) async {
    DocumentSnapshot storeDoc = await stores.doc(storeID).get();
    double latitude = 0.0;
    double longitude = 0.0;
    String selectedPlan = "";
    bool isOfflineStore = false;
    if (storeDoc.exists) {
      var storeData = storeDoc.data() as Map<String, dynamic>;
      setState(() {
        selectedStoreID = storeDoc.id;
        addressController.text = storeData['address'] ?? '';
        picNameController.text = storeData['picName'] ?? '';
        picContactController.text = storeData['contactToko'] ?? '';
        selectedProvince = provinces.firstWhere(
            (province) => province.name == storeData['selectedProvince'],
            orElse: () => provinces.first);
        selectedKabupaten = selectedProvince?.kabupatens.firstWhere(
            (kabupaten) => kabupaten.name == storeData['selectedKabupaten'],
            orElse: () => selectedProvince!.kabupatens.first);
        latitude = storeData['latitude'] is double
            ? storeData['latitude']
            : double.tryParse(storeData['latitude'].toString()) ?? 0.0;
        longitude = storeData['longitude'] is double
            ? storeData['longitude']
            : double.tryParse(storeData['longitude'].toString()) ?? 0.0;
      });

      selectedPlan = storeData['selectedPlan'] ?? "";
      isOfflineStore = selectedPlan.contains('offline');
      log('isOfflineStore = ${storeData['selectedPlan']}');
      if (!context.mounted) return;

      dialogGetLatLong(
        context,
        storeName,
        isOfflineStore,
        lat: latitude,
        long: longitude,
      );
    }
  }

  Map<String, dynamic> callVariable = {};
  void saveCallDataAndNavigate(
      BuildContext context, CallResult callResult) async {
    String imageURL = await uploadImage(XFile(imagePath));
    // String callID = '';
    callVariable = {
      'email': emailController.text,
      'name': nameController.text,
      'storeName': selectedStore!.storeName,
      'storeID': selectedStore!.storeId,
      'address': addressController.text,
      'picName': picNameController.text,
      'picContact': picContactController.text,
      'province': selectedProvince?.name,
      'kabupaten': selectedKabupaten?.name,
      'imageURL': imageURL,
      'planType': selectedPlan?.toString().split('.').last,
      'callResult': callResult.toString().split('.').last,
      'timestamp': Timestamp.now(),
      'status': 'Called',
    };
    // await calls.add({
    //   'email': emailController.text,
    //   'name': nameController.text,
    //   'storeName': selectedStore!.storeName,
    //   'storeID': selectedStore!.storeId,
    //   'address': addressController.text,
    //   'picName': picNameController.text,
    //   'picContact': picContactController.text,
    //   'province': selectedProvince?.name,
    //   'kabupaten': selectedKabupaten?.name,
    //   'imageURL': imageURL,
    //   'planType': selectedPlan?.toString().split('.').last,
    //   'callResult': callResult.toString().split('.').last,
    //   'timestamp': Timestamp.now(),
    //   'status': 'Called',
    // }).then((value) {
    // }).catchError((error) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Failed to save call data: $error')),
    //   );
    // });

    // callID = value.id;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Isi Form Selanjutnya'),
        backgroundColor: mainColor,
      ),
    );
    if (callResult == CallResult.purchase) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MainCatalog(
                  userID: widget.documentID,
                  imageURL: imageURL,
                  callVariable: callVariable,
                  // callID: callID,
                )),
      );
    } else if (callResult == CallResult.reject) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RejectedScreen(
                  userID: widget.documentID,
                  storeID: selectedStore!.storeId,
                  callVariable: callVariable,
                  // callID: callID,
                )),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
    // Fetch the stores when the widget is initialized
  }

  List<DropdownMenuItem<Province>> getProvinceDropdownItems(
      List<Province> provinces) {
    return provinces.map((province) {
      return DropdownMenuItem<Province>(
        value: province,
        child: Text(province.name),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = (screenWidth - 32 - 20) / 2;
    double cardHeight = screenHeight * 0.07;
    late String source;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: mainColor,
        automaticallyImplyLeading: true,
        title: const Text(
          'Form Call',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Call Details:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 20),
              const Text(
                'Select Store',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              loadingButtonGetPhotoToko == true
                  ? const Center(
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator()),
                    )
                  : DropdownButtonFormField2<StoreObject>(
                      isExpanded: false,
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                      dropdownSearchData: DropdownSearchData(
                        searchController: searchStoreController,
                        searchInnerWidgetHeight: 50,
                        searchInnerWidget: Container(
                          height: 50,
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 4,
                            right: 8,
                            left: 8,
                          ),
                          child: TextFormField(
                            expands: true,
                            maxLines: null,
                            controller: searchStoreController,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              hintText: 'Cari nama customer',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        searchMatchFn: (item, searchValue) {
                          return (item.value?.storeName ?? "")
                              .toLowerCase()
                              .toString()
                              .contains(searchValue.toLowerCase());
                        },
                      ),
                      hint: Text(
                        "Pilih customer",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                      value: listStore.isEmpty || loadingButtonGetPhotoToko
                          ? null
                          : selectedStore,
                      items: listStore
                          .map(
                            (e) => DropdownMenuItem<StoreObject>(
                              value: e,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  child: Text(
                                    e.storeName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Silahkan pilih salah satu toko';
                        }
                        return null;
                      },
                      onChanged: (value) async {
                        setState(() {
                          selectedStore = value;
                          fetchStoreDetails(
                            context,
                            selectedStore!.storeId,
                            selectedStore!.storeName,
                          );
                        });
                      },
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.only(right: 10),
                      ),
                      iconStyleData: const IconStyleData(
                        icon: Icon(
                          Icons.keyboard_arrow_down_outlined,
                          color: Colors.black45,
                        ),
                        iconSize: 16,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                      ),
                    ),
              const SizedBox(height: 20),
              const Text(
                'Select Type',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 10,
                childAspectRatio: (cardWidth / cardHeight),
                children: List.generate(2, (index) {
                  PlanType planType;
                  String title;

                  switch (index) {
                    case 0:
                      planType = PlanType.online;
                      title = 'Online Call';
                      break;
                    case 1:
                      planType = PlanType.offline;
                      title = 'Offline Call';
                      break;
                    default:
                      planType = PlanType.offline;
                      title = 'Offline Call';
                  }

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        source = title;
                        selectedPlan = planType;
                      });
                    },
                    child: PlanCard(
                      title: title,
                      isSelected: selectedPlan == planType,
                      width: cardWidth,
                      height: cardHeight,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'Photo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 30),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(mainColor),
                      foregroundColor:
                          WidgetStateProperty.all<Color>(Colors.white),
                    ),
                    onPressed: () async {
                      XFile file = await getImageCall();
                      setState(() {
                        imagePath = file.path;
                      });
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.camera_alt_outlined),
                        SizedBox(width: 10),
                        Text('Take a photo'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _image != null
                  ? Image.file(
                      File(_image!.path),
                      width: 100,
                      height: 100,
                    )
                  : const SizedBox(),
              const SizedBox(height: 20),
              const Divider(
                height: 10,
                thickness: 4,
                color: mainColor,
              ),
              const SizedBox(height: 20),
              const Text(
                'Store Details:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Personal Data',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: emailController,
                      readOnly: true,
                      style: const TextStyle(color: Colors.grey),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextField(
                      controller: nameController,
                      readOnly: true,
                      style: const TextStyle(color: Colors.grey),
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Address',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: addressController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Store Address',
                  labelStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.black), // Change the label style
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black), // Change the input text style
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  DropdownButtonFormField<Province>(
                    items: getProvinceDropdownItems(provinces),
                    onChanged: (value) {
                      setState(() {
                        selectedProvince = value;
                        selectedKabupaten =
                            null; // Reset the kabupaten selection
                      });
                    },
                    value: selectedProvince,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Province',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 12.0), // Adjust the padding here
                    ),
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black), // Adjust the font size here
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<Kabupaten>(
                    items: selectedProvince?.kabupatens.map((kabupaten) {
                      return DropdownMenuItem<Kabupaten>(
                        value: kabupaten,
                        child: Text(
                          kabupaten.name,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedKabupaten = value!;
                      });
                    },
                    value: selectedKabupaten,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Kabupaten',
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    ),
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    isExpanded: true,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 20),
              const Text(
                'PIC Contact',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: picNameController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Please insert name...',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.black),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: picContactController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Contact Toko',
                  hintText: 'Please insert contact number...',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.black),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: 20),
              const Divider(
                height: 10,
                thickness: 4,
                color: mainColor,
              ),
              const SizedBox(height: 20),
              const Text(
                'Result:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 10,
                childAspectRatio: (cardWidth / cardHeight),
                children: List.generate(2, (index) {
                  CallResult callResult;
                  String title;

                  switch (index) {
                    case 0:
                      callResult = CallResult.purchase;
                      title = 'Purchase';
                      break;
                    case 1:
                      callResult = CallResult.reject;
                      title = 'Rejected';
                      break;
                    default:
                      callResult = CallResult.purchase;
                      title = 'Purchase';
                  }

                  return GestureDetector(
                    onTap: () {
                      saveCallDataAndNavigate(context, callResult);
                    },
                    child: PlanCard(
                      title: title,
                      isSelected: selectedCall == callResult,
                      width: cardWidth,
                      height: cardHeight,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  XFile? _image;
  Future<XFile> getImageCall() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path);
      });
    }
    return pickedFile!;
  }
}

class StoreObject {
  String storeName;
  String storeId;

  StoreObject({required this.storeName, required this.storeId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreObject &&
          runtimeType == other.runtimeType &&
          storeId == other.storeId;

  @override
  int get hashCode => storeId.hashCode;
}
