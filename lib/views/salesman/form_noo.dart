import 'dart:io';
import 'package:auctus_call/utilities/categ_list.dart';
import 'package:auctus_call/utilities/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

enum PlanType { tiktok, unirama, shopee, tokopedia, offline, others }

class FormNoo extends StatefulWidget {
  final String documentID;
  const FormNoo({super.key, required this.documentID});

  @override
  State<FormNoo> createState() => _FormNooState();
}

class _FormNooState extends State<FormNoo> {
  File? imagePhotoKtpX;
  final ImagePicker _picker = ImagePicker();

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  PlanType? selectedPlan;
  Province? selectedProvince;
  Kabupaten? selectedKabupaten;
  int selectedGridIndex = -1;
  CollectionReference stores = FirebaseFirestore.instance.collection('stores');
  bool _isChecked = false;

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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = (screenWidth - 32 - 20) / 2;
    double cardHeight = screenHeight * 0.07;
    late String source;

    return Scaffold(
      floatingActionButton: Container(
        child: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: secColor,
          icon: Icon(Icons.add, color: Colors.white),
          label: Text(
            'NEW NOO',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: mainColor,
        automaticallyImplyLeading: false,
        title: const Text(
          'Form NOO',
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
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Store Name',
                  labelStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.black), // Change the label style
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(
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
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Address and store classification are optional',
                        style: TextStyle(
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Store Classification',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                child: SingleChildScrollView(
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
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Please insert name...',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.black),
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: 15),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Contact Toko',
                  hintText: 'Please insert contact number...',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.black),
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: 20),
              const Text(
                'KTP Identification',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 15),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'NIK KTP',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.black),
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(mainColor),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: () {},
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.camera_alt_outlined),
                    SizedBox(width: 10),
                    Text('Select Photo'),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Text(
                    'NPWP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Checkbox(
                    checkColor: Colors.white,
                    fillColor: MaterialStateProperty.all<Color>(mainColor),
                    value: _isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isChecked = value ?? false;
                      });
                    },
                  ),
                ],
              ),
              if (_isChecked)
                Column(
                  children: [
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'No. NPWP',
                        labelStyle:
                            TextStyle(fontSize: 14, color: Colors.black),
                        border: OutlineInputBorder(),
                      ),
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(mainColor),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                      ),
                      onPressed: () {},
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
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
