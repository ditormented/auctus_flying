import 'dart:developer';
import 'dart:io';

import 'package:auctus_call/utilities/categ_list.dart';
import 'package:auctus_call/utilities/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

enum PlanType { tiktok, unirama, shopee, tokopedia, offline, others }

class ScrapingForm extends StatefulWidget {
  final String documentID;
  const ScrapingForm({super.key, required this.documentID});

  @override
  State<ScrapingForm> createState() => _ScrapingFormState();
}

class _ScrapingFormState extends State<ScrapingForm> {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController storeNameController = TextEditingController();
  TextEditingController storeAddressController = TextEditingController();
  TextEditingController picNameController = TextEditingController();
  TextEditingController contactTokoController = TextEditingController();
  TextEditingController latController = TextEditingController();
  double latNumber = 0.0;
  double lngNumber = 0.0;
  TextEditingController lngController = TextEditingController();
  TextEditingController joiningDateController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController addressByGeoReverseController = TextEditingController();

  String reverseGeotaggingString = "";

  PlanType? selectedPlan;
  Province? selectedProvince;
  Kabupaten? selectedKabupaten;
  int selectedGridIndex = -1;
  CollectionReference stores = FirebaseFirestore.instance.collection('stores');

  final ImagePicker _picker = ImagePicker();
  XFile? imagePhotoTokoX;

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
          latController.text = position.latitude.toString();
          latNumber = position.latitude;
          lngController.text = position.longitude.toString();
          lngNumber = position.longitude;
        });

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

            setState(() {
              addressByGeoReverseController.text =
                  "$street, $subLocality, $locality, $administrativeArea, $country";
            });
            // log("Reverse geolocation: ${storeObject.reverseGeotagging}");
          }
        } catch (e) {
          log("Error fetching reverse geotagging: $e");
        }

        // ===> Upload the image to a cloud storage service and get the URL
        // String storeImageUrl = await uploadImage(file);
        // log("Uploaded image URL: $storeImageUrl");

        // ===> Update Firestore
        // await updateStoreData(storeImageUrl, position.latitude,
        //     position.longitude, reverseGeotaggingString);
        // log("Store data updated in Firestore.");
      }
    } catch (e) {
      imagePhotoTokoX = null;
      log("Error in getPhotoToko: $e");
    }
  }

  Future<String> uploadImage(XFile file, String storeId) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('store_images/$storeId-${DateTime.now()}.jpg');
    await storageRef.putFile(File(file.path));
    return await storageRef.getDownloadURL();
  }

  Future updateStoreData(String storeImageUrl, String storeId) async {
    DocumentReference storeRef =
        FirebaseFirestore.instance.collection('stores').doc(storeId);

    await storeRef.update({
      'storeImageUrl': storeImageUrl,
    });
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

  @override
  void initState() {
    super.initState();
    fetchUserData();
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

  // Future<void> getCurrentLocation() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   // Check if location services are enabled.
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // Location services are not enabled, don't continue
  //     return Future.error('Location services are disabled.');
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       // Permissions are denied, next time you could try requesting permissions again
  //       return Future.error('Location permissions are denied');
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     // Permissions are denied forever, handle appropriately
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }

  //   Position position = await Geolocator.getCurrentPosition();
  //   setState(() {
  //     latController.text = position.latitude.toString();
  //     lngController.text = position.longitude.toString();
  //   });
  // }

  Future<void> submitForm() async {
    if (storeNameController.text.isEmpty ||
        picNameController.text.isEmpty ||
        contactTokoController.text.isEmpty ||
        latController.text.isEmpty ||
        lngController.text.isEmpty ||
        selectedPlan == null ||
        selectedProvince == null ||
        selectedKabupaten == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields'),
          backgroundColor: mainColor,
          duration: Duration(milliseconds: 800),
        ),
      );
      return;
    }

    await stores.add({
      'email': emailController.text,
      'name': nameController.text,
      'storeName': storeNameController.text,
      'address': storeAddressController.text,
      'picName': picNameController.text,
      'contactToko': contactTokoController.text,
      'latitude': latNumber,
      'longitude': lngNumber,
      'selectedPlan': selectedPlan.toString(),
      'selectedProvince': selectedProvince?.name,
      'selectedKabupaten': selectedKabupaten?.name,
      'selectedCategory':
          selectedGridIndex != -1 ? categoryToko[selectedGridIndex] : null,
      'reverseGeotagging': addressByGeoReverseController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'status': "scraped",
    }).then((result) async {
      updateStoreData(
        await uploadImage(imagePhotoTokoX!, result.id),
        result.id,
      );
      
    });

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form submitted successfully'),
        backgroundColor: mainColor,
        duration: Duration(
          milliseconds: 1500,
        ),
      ),
    );

    // Clear form fields after submission
    setState(() {
      storeNameController.clear();
      storeNameController.clear();
      picNameController.clear();
      contactTokoController.clear();
      latController.clear();
      lngController.clear();
      selectedPlan = null;
      selectedProvince = null;
      selectedKabupaten = null;
      selectedGridIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = (screenWidth - 32 - 20) / 2;
    double cardHeight = screenHeight * 0.07;
    String source = "";

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: submitForm,
        backgroundColor: secColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'NEW SCRAPE',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: mainColor,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Form Scraping',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personal Data',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
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
                  const SizedBox(width: 10),
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
                'Select Source',
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
                children: List.generate(6, (index) {
                  PlanType planType;
                  String title;

                  switch (index) {
                    case 0:
                      planType = PlanType.tiktok;
                      title = 'Tiktok';
                      break;
                    case 1:
                      planType = PlanType.unirama;
                      title = 'Unirama';
                      break;
                    case 2:
                      planType = PlanType.shopee;
                      title = 'Shopee';
                      break;
                    case 3:
                      planType = PlanType.tokopedia;
                      title = 'Tokopedia';
                      break;
                    case 4:
                      planType = PlanType.offline;
                      title = 'Offline';
                      break;
                    case 5:
                      planType = PlanType.others;
                      title = 'Others';
                      break;
                    default:
                      planType = PlanType.tiktok;
                      title = 'Tiktok';
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
              const Text(
                'Address',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: storeNameController,
                decoration: const InputDecoration(
                  labelText: 'Store Name',
                  labelStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.black), // Change the label style
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black), // Change the input text style
              ),
              const SizedBox(height: 15),
              TextField(
                controller: storeAddressController,
                minLines: 1,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Address',
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
              // ElevatedButton.icon(
              //   onPressed: getCurrentLocation,
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: mainColor,
              //   ),
              //   icon: const Icon(
              //     Icons.location_on,
              //     color: Colors.white,
              //   ),
              //   label: const Text(
              //     'Get Current Location',
              //     style: TextStyle(color: Colors.white),
              //   ),
              // ),
              // validasi lokasi => start
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      ? const Icon(
                          Icons.image,
                          size: 100,
                          color: Colors.grey,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
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
                ],
              ),
              // validasi lokasi => finish
              const SizedBox(height: 20),
              const Text(
                'Store Classification',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                    children: List.generate(categoryToko.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedGridIndex = index;
                      });
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                          color: selectedGridIndex == index
                              ? Colors.blue[50]
                              : Colors.white,
                          border: Border.all(
                            color: selectedGridIndex == index
                                ? Colors.blue
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                          child: Text(
                        categoryToko[index],
                        style: TextStyle(
                          color: selectedGridIndex == index
                              ? Colors.blue
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ),
                  );
                })),
              ),
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
                controller: contactTokoController,
                keyboardType: const TextInputType.numberWithOptions(),
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Please insert contact number...',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.black),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(EnumForm enumForm) {
    return TextField(
      controller: enumForm == EnumForm.latitude
          ? latController
          : enumForm == EnumForm.longitude
              ? lngController
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

class PlanCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final double width;
  final double height;

  const PlanCard({
    Key? key,
    required this.title,
    required this.isSelected,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: Card(
        color: isSelected ? Colors.blue[50] : Colors.white,
        elevation: isSelected ? 4.0 : 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isSelected ? Icons.flash_on : Icons.payment,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.blue : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
