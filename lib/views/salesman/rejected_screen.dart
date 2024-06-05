import 'package:auctus_call/utilities/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final TextEditingController _ourPriceController = TextEditingController();
  final TextEditingController _competitorPriceController =
      TextEditingController();
  CollectionReference category =
      FirebaseFirestore.instance.collection('products');
  final List<TextEditingController> _productControllers = [];
  final List<TextEditingController> _productOurPriceControllers = [];
  final List<TextEditingController> _productCompetitorPriceControllers = [];
  TextEditingController productController = TextEditingController();
  TextEditingController competitorPriceController = TextEditingController();
  TextEditingController ourPriceController = TextEditingController();
  CollectionReference reason = FirebaseFirestore.instance.collection('reason');

  int _wordCount = 0;
  bool _isValid = false;
  String? _selectedReason;
  String? _selectedCategory;
  final List<String> _reasons = ['Price War', 'Other'];
  final List<String> _categories = [
    'Nivea Sun',
    'Nivea Men',
    'Nivea Deodorant',
    'Nivea Deodorant Men',
    'Nivea Body',
    'NCRM Cremes',
    'Nivea Face Care',
    'NLC Lip Care',
  ];

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
    var body = {
      'storeID': widget.storeID,
      'callID': widget.callID,
      'reasonReject': _reasonController.text,
      'selectReason': _selectedReason,
      'itemCategory': _selectedCategory,
      'product': productController.text,
      'ourPrice': ourPriceController.text,
      'competitorPrice': competitorPriceController.text,
    };
    print('$body');
    await reason.add(body);
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
    _ourPriceController.dispose();
    _competitorPriceController.dispose();
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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

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
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCategory,
                  items: _categories
                      .map((category) => DropdownMenuItem(
                            child: Text(category),
                            value: category,
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                      _productControllers
                          .clear(); // Clear all product controllers
                      _productOurPriceControllers
                          .clear(); // Clear all our price controllers
                      _productCompetitorPriceControllers
                          .clear(); // Clear all competitor price controllers
                      _ourPriceController
                          .clear(); // Clear our price for category
                      _competitorPriceController
                          .clear(); // Clear competitor price for category
                    });
                  },
                ),
                // SizedBox(height: 16),
                // if (_selectedCategory != null)
                //   Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Row(
                //         children: [
                //           Expanded(
                //             child: TextField(
                //               controller: _ourPriceController,
                //               decoration: InputDecoration(
                //                 labelText: 'Our Price',
                //                 border: OutlineInputBorder(),
                //               ),
                //               keyboardType: TextInputType.numberWithOptions(
                //                   decimal: true),
                //               inputFormatters: [
                //                 FilteringTextInputFormatter.allow(
                //                     RegExp(r'^\d+\.?\d{0,2}')),
                //               ],
                //             ),
                //           ),
                //           SizedBox(width: 16),
                //           Expanded(
                //             child: TextField(
                //               controller: _competitorPriceController,
                //               decoration: InputDecoration(
                //                 labelText: 'Competitor Price',
                //                 border: OutlineInputBorder(),
                //               ),
                //               keyboardType: TextInputType.numberWithOptions(
                //                   decimal: true),
                //               inputFormatters: [
                //                 FilteringTextInputFormatter.allow(
                //                     RegExp(r'^\d+\.?\d{0,2}')),
                //               ],
                //             ),
                //           ),
                //         ],
                //       ),
                //       SizedBox(height: 16),
                //       Text(
                //         'Category Price Difference: ${_calculateDifference(
                //           double.tryParse(_ourPriceController.text) ?? 0,
                //           double.tryParse(_competitorPriceController.text) ?? 0,
                //         ).toStringAsFixed(2)}%',
                //         style: TextStyle(
                //           fontSize: 16,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ],
                //   ),
                SizedBox(height: 16),
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
                  productController = entry.value;
                  ourPriceController = _productOurPriceControllers[index];
                  competitorPriceController =
                      _productCompetitorPriceControllers[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('products')
                              .where('Category', isEqualTo: _selectedCategory)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            }
                            var products = snapshot.data!.docs
                                .map((doc) => doc['Name'] as String)
                                .toList();
                            return DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Product',
                                labelStyle: TextStyle(
                                    fontSize: 14), // Smaller label text
                                border: OutlineInputBorder(),
                              ),
                              value: productController.text.isNotEmpty
                                  ? productController.text
                                  : null,
                              items: products
                                  .map((product) => DropdownMenuItem(
                                        child: Text(product,
                                            style: TextStyle(
                                                fontSize:
                                                    14)), // Smaller dropdown text
                                        value: product,
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  productController.text = value!;
                                });
                              },
                            );
                          },
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
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
                              ),
                            ),
                            SizedBox(width: 16),
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
                        SizedBox(height: 16),
                      ],
                    ),
                  );
                }).toList(),
              ],
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _isValid
                      ? () {
                          submitForm();
                        }
                      : null,
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
