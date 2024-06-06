import 'dart:io';
import 'package:auctus_call/utilities/categ_list.dart';
import 'package:auctus_call/utilities/colors.dart';
import 'package:auctus_call/views/salesman/cart_screen.dart';
import 'package:auctus_call/views/salesman/main_catalog_screen.dart';
import 'package:auctus_call/views/salesman/rejected_screen.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:dropdown_search/dropdown_search.dart';

enum PlanType { online, offline }

enum CallResult { purchase, reject }

class FormCall extends StatefulWidget {
  final String documentID;
  final String callID;

  const FormCall({
    super.key,
    required this.documentID,
    required this.callID,
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
  String? selectedStoreID;

  static Future<String> uploadImage(XFile imageFile) async {
    String fileName = basename(imageFile.name);
    final storage =
        FirebaseStorage.instanceFor(bucket: 'gs://auctussfa.appspot.com');
    Reference ref = storage.ref().child(fileName);
    UploadTask task = ref.putFile(File(imageFile.path));
    TaskSnapshot snapshot = await task;

    return snapshot.ref.getDownloadURL();
  }

  void fetchUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.documentID)
        .get();

    if (userDoc.exists) {
      setState(() {
        emailController.text = userDoc['email'] ?? '';
        nameController.text = userDoc['name'] ?? '';
      });
    }
  }

  void fetchStores() async {
    QuerySnapshot storeDocs = await stores.get();
    setState(() {
      listStore = storeDocs.docs
          .map((doc) =>
              StoreObject(storeId: doc.id, storeName: doc["storeName"]))
          .toList();
    });
  }

  void fetchStoreDetails(String storeName) async {
    QuerySnapshot storeDocs =
        await stores.where('storeName', isEqualTo: storeName).get();
    if (storeDocs.docs.isNotEmpty) {
      var storeData = storeDocs.docs.first.data() as Map<String, dynamic>;
      setState(() {
        selectedStoreID = storeDocs.docs.first.id;
        addressController.text = storeData['address'] ?? '';
        picNameController.text = storeData['picName'] ?? '';
        picContactController.text = storeData['contactToko'] ?? '';
        selectedProvince = provinces.firstWhere(
            (province) => province.name == storeData['selectedProvince'],
            orElse: () => provinces.first);
        selectedKabupaten = selectedProvince?.kabupatens.firstWhere(
            (kabupaten) => kabupaten.name == storeData['selectedKabupaten'],
            orElse: () => selectedProvince!.kabupatens.first);
      });
    }
  }

  void saveCallDataAndNavigate(
      BuildContext context, CallResult callResult) async {
    String imageURL = await uploadImage(XFile(imagePath));
    String callID = '';
    await calls.add({
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
    }).then((value) {
      callID = value.id;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Call data saved successfully'),
          backgroundColor: mainColor,
        ),
      );
      if (callResult == CallResult.purchase) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MainCatalog(
                    userID: widget.documentID,
                    callID: callID,
                  )),
        );
      } else if (callResult == CallResult.reject) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RejectedScreen(
                    storeID: selectedStore!.storeId,
                    callID: callID,
                  )),
        );
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save call data: $error')),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchStores(); // Fetch the stores when the widget is initialized
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
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
              DropdownButtonFormField2<StoreObject>(
                isExpanded: false,
                decoration: const InputDecoration(border: OutlineInputBorder()),
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
                // inputDecoration(context,
                //     contentPadding:
                //         EdgeInsets.symmetric(vertical: 1.8.h, horizontal: 0)),
                hint: Text(
                  "Pilih tipe customer",
                  style: TextStyle(color: Colors.grey.shade500),
                ),
                // style: primaryTextStyle1(),
                value: selectedStore,
                items: listStore
                    .map(
                      (e) => DropdownMenuItem<StoreObject>(
                        value: e,
                        child: Text(
                          e.storeName,
                          // style: primaryTextStyle1(),
                        ),
                      ),
                    )
                    .toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Silihkan pilih salah satu toko';
                  }
                  return null;
                },
                onChanged: (value) {
                  // controller.tipeCustomerSelect.value = value;
                  // controller.resetOption(value ?? "");
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
                  padding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
              // DropdownSearch<StoreObject>(

              //   filterFn: (listStore, string) {
              //     listStore.storeName;
              //   },
              //   items: listStore,
              //   itemAsString: (StoreObject? u) => u?.storeName ?? '',
              //   onChanged: (value) {
              //     setState(() {
              //       selectedStore = value;
              //       print(selectedStore!.storeId);
              //       fetchStoreDetails(value!.storeName);
              //       print(value.storeName.runtimeType);
              //     });
              //   },
              // ),
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
                      XFile file = await getImage();
                      imagePath = file.path;

                      setState(() {});
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.camera_alt_outlined),
                        SizedBox(width: 10),
                        Text('Select Photo'),
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
                  : SizedBox(),
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
                  hintText: 'John Doe',
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
                  hintText: '+6281031972',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.black),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: 20),
              Divider(
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
  Future<XFile> getImage() async {
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
}
