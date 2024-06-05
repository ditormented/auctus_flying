import 'package:auctus_call/utilities/categ_list.dart';
import 'package:auctus_call/utilities/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  PlanType? selectedPlan;
  Province? selectedProvince;
  Kabupaten? selectedKabupaten;
  int selectedGridIndex = -1;
  CollectionReference stores = FirebaseFirestore.instance.collection('stores');

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

  Future<void> submitForm() async {
    if (storeNameController.text.isEmpty ||
        picNameController.text.isEmpty ||
        contactTokoController.text.isEmpty ||
        selectedPlan == null ||
        selectedProvince == null ||
        selectedKabupaten == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
      'selectedPlan': selectedPlan.toString(),
      'selectedProvince': selectedProvince?.name,
      'selectedKabupaten': selectedKabupaten?.name,
      'selectedCategory':
          selectedGridIndex != -1 ? categoryToko[selectedGridIndex] : null,
      'timestamp': FieldValue.serverTimestamp(),
      'status': "scraped",
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
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
    late String source;
    bool _isExpanded = false;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: submitForm,
        backgroundColor: secColor,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'NEW SCRAPE',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: mainColor,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
              TextField(
                controller: picNameController,
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
                controller: contactTokoController,
                decoration: const InputDecoration(
                  labelText: 'Contact Toko',
                  hintText: '+6281031972',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.black),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
