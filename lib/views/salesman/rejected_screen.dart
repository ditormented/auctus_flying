import 'package:auctus_call/utilities/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auctus_call/views/salesman/home_screen.dart';

class RejectedScreen extends StatefulWidget {
  final String storeID;
  final String callID;

  const RejectedScreen(
      {super.key, required this.storeID, required this.callID});

  @override
  _RejectedScreenState createState() => _RejectedScreenState();
}

class _RejectedScreenState extends State<RejectedScreen> {
  final TextEditingController _reasonController = TextEditingController();
  CollectionReference reason = FirebaseFirestore.instance.collection('reason');
  final List<TextEditingController> _productControllers = [];
  final List<TextEditingController> _productOurPriceControllers = [];
  final List<TextEditingController> _productCompetitorPriceControllers = [];

  int _wordCount = 0;
  bool _isValid = false;
  String? _selectedReason;
  final List<String> _reasons = ['Price War', 'Other'];

  double _calculateDifference(double ourPrice, double competitorPrice) {
    if (competitorPrice == 0) return 0;
    return ((competitorPrice - ourPrice) / competitorPrice) * 100;
  }

  @override
  void initState() {
    super.initState();
    _reasonController.addListener(_updateWordCount);
  }

  Future<void> submitForm() async {
    var productsComparison = [];
    for (int i = 0; i < _productControllers.length; i++) {
      productsComparison.add({
        'product': _productControllers[i].text,
        'ourPrice': _productOurPriceControllers[i].text,
        'competitorPrice': _productCompetitorPriceControllers[i].text,
      });
    }

    var body = {
      'storeID': widget.storeID,
      'callID': widget.callID,
      'reasonReject': _reasonController.text,
      'selectReason': _selectedReason,
      'productsComparison': productsComparison,
    };
    print('$body');
    try {
      await reason.add(body);
      // Display success notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Form submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            documentID: widget.storeID, // Adjust if needed
            callID: widget.callID, // Adjust if needed
          ),
        ),
      );
    } catch (e) {
      // Display error notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit form. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateWordCount() {
    setState(() {
      _wordCount = _reasonController.text.split(RegExp(r'\s+')).length;
      _isValid = _wordCount >= 5;
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    for (var controller in _productControllers) {
      controller.dispose();
    }
    for (var controller in _productOurPriceControllers) {
      controller.dispose();
    }
    for (var controller in _productCompetitorPriceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addProductComparison() {
    setState(() {
      _productControllers.add(TextEditingController());
      _productOurPriceControllers.add(TextEditingController());
      _productCompetitorPriceControllers.add(TextEditingController());
    });
  }

  void _removeProductComparison(int index) {
    setState(() {
      _productControllers[index].dispose();
      _productOurPriceControllers[index].dispose();
      _productCompetitorPriceControllers[index].dispose();
      _productControllers.removeAt(index);
      _productOurPriceControllers.removeAt(index);
      _productCompetitorPriceControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rejection Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: mainColor,
        iconTheme:
            IconThemeData(color: Colors.white), // Makes the back button white
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _reasonController,
                maxLines: 5,
                decoration: InputDecoration(
                  focusColor: secColor,
                  labelText: 'Reason for Rejection',
                  border: OutlineInputBorder(),
                  helperText: 'Minimum 5 words',
                  errorText: _isValid ? null : 'Minimum 5 words required',
                ),
              ),
              SizedBox(height: 8),
              Text('Word count: $_wordCount'),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
                value: _selectedReason,
                items: _reasons
                    .map((reason) => DropdownMenuItem(
                          child: Text(reason),
                          value: reason,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedReason = value;
                  });
                },
              ),
              SizedBox(height: 16),
              if (_selectedReason == 'Price War') ...[
                ElevatedButton.icon(
                  onPressed: _addProductComparison,
                  icon: Icon(Icons.add),
                  label: Text(
                    'Add Product Comparison',
                    style: TextStyle(fontSize: 13, color: mainColor),
                  ),
                ),
                SizedBox(height: 16),
                ..._productControllers.asMap().entries.map((entry) {
                  int index = entry.key;
                  TextEditingController productController = entry.value;
                  TextEditingController ourPriceController =
                      _productOurPriceControllers[index];
                  TextEditingController competitorPriceController =
                      _productCompetitorPriceControllers[index];

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('products')
                                    .snapshots(), // Get all products
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return CircularProgressIndicator();
                                  }
                                  var products = snapshot.data!.docs
                                      .map((doc) => doc['Name'] as String)
                                      .toList();
                                  return Autocomplete<String>(
                                    optionsBuilder:
                                        (TextEditingValue textEditingValue) {
                                      if (textEditingValue.text.isEmpty) {
                                        return const Iterable<String>.empty();
                                      }
                                      return products.where((String option) {
                                        return option.toLowerCase().contains(
                                            textEditingValue.text
                                                .toLowerCase());
                                      });
                                    },
                                    onSelected: (String selection) {
                                      setState(() {
                                        productController.text = selection;
                                      });
                                    },
                                    fieldViewBuilder: (context, controller,
                                        focusNode, onEditingComplete) {
                                      return TextField(
                                        controller: controller,
                                        focusNode: focusNode,
                                        decoration: InputDecoration(
                                          labelText: 'Product',
                                          labelStyle: TextStyle(
                                              fontSize:
                                                  14), // Smaller label text
                                          border: OutlineInputBorder(),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeProductComparison(index),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('products')
                              .where('Name', isEqualTo: productController.text)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return TextField(
                                controller: ourPriceController,
                                decoration: InputDecoration(
                                  labelText: 'Our Price',
                                  labelStyle: TextStyle(
                                      fontSize: 14), // Smaller label text
                                  border: OutlineInputBorder(),
                                ),
                                style: TextStyle(
                                    fontSize: 14), // Smaller input text
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                              );
                            }
                            var products = snapshot.data!.docs;
                            String productPrice = '0';
                            if (products.isNotEmpty) {
                              var productData =
                                  products.first.data() as Map<String, dynamic>;
                              if (productData.containsKey('ppnPrice')) {
                                productPrice =
                                    productData['ppnPrice'].toString();
                              }
                            }
                            return TextField(
                              controller: ourPriceController
                                ..text = productPrice,
                              decoration: InputDecoration(
                                labelText: 'Our Price',
                                labelStyle: TextStyle(
                                    fontSize: 14), // Smaller label text
                                border: OutlineInputBorder(),
                              ),
                              style:
                                  TextStyle(fontSize: 14), // Smaller input text
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: competitorPriceController,
                                decoration: InputDecoration(
                                  labelText: 'Competitor Price',
                                  labelStyle: TextStyle(
                                      fontSize: 14), // Smaller label text
                                  border: OutlineInputBorder(),
                                ),
                                style: TextStyle(
                                    fontSize: 14), // Smaller input text
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Product Price Difference: ${_calculateDifference(
                            double.tryParse(ourPriceController.text) ?? 0,
                            double.tryParse(competitorPriceController.text) ??
                                0,
                          ).toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _isValid ? submitForm : null,
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
