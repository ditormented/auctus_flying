import 'package:auctus_call/utilities/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class InputPJP extends StatefulWidget {
  const InputPJP({super.key});

  @override
  State<InputPJP> createState() => _InputPJPState();
}

class _InputPJPState extends State<InputPJP> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  String? _selectedStoreId;
  String? _selectedStoreName;
  String? _selectedSalesmanId;
  String? _selectedSalesmanName;
  String? _selectedKabupaten;
  List<Map<String, dynamic>> _selectedStores = [];

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _selectedStores.isNotEmpty &&
        _selectedSalesmanId != null) {
      try {
        await FirebaseFirestore.instance.collection('pjp').add({
          'date': _dateController.text,
          'name': {
            'salesmanId': _selectedSalesmanId,
            'salesmanName': _selectedSalesmanName,
          },
          'store': _selectedStores,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data successfully added')),
        );
        _formKey.currentState?.reset();
        setState(() {
          _selectedStores.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the form')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now().add(
      const Duration(days: 1),
    ));
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: mainColor,
        title: const Text(
          'Input PJP',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Date',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'Salesman')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  var salesmanDocuments = snapshot.data!.docs;

                  return DropdownButtonFormField<String>(
                    value: _selectedSalesmanId,
                    items: salesmanDocuments.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc.id,
                        child: Text(doc['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSalesmanId = value;
                        var selectedSalesman = salesmanDocuments
                            .firstWhere((doc) => doc.id == value);
                        _selectedSalesmanName = selectedSalesman['name'];
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Salesman',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a salesman';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('stores').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  var kabupatenList = snapshot.data!.docs
                      .map((doc) => doc.data() as Map<String, dynamic>)
                      .where((data) =>
                          data.containsKey('selectedKabupaten') &&
                          data['selectedKabupaten'] != null &&
                          data['selectedKabupaten'].toString().isNotEmpty)
                      .map((data) => data['selectedKabupaten'] as String?)
                      .toSet()
                      .toList()
                    ..removeWhere((item) => item == null);

                  return DropdownButtonFormField<String>(
                    value: _selectedKabupaten,
                    items: kabupatenList.map((kabupaten) {
                      return DropdownMenuItem<String>(
                        value: kabupaten,
                        child: Text(kabupaten!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedKabupaten = value;
                        _selectedStoreId = null;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Kabupaten',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a kabupaten';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              if (_selectedKabupaten != null)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('stores')
                      .where('selectedKabupaten', isEqualTo: _selectedKabupaten)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    var storeDocuments = snapshot.data!.docs;

                    return DropdownButtonFormField<String>(
                      value: _selectedStoreId,
                      items: storeDocuments.map((doc) {
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text(doc['storeName']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStoreId = value;
                          var selectedStore = storeDocuments
                              .firstWhere((doc) => doc.id == value);
                          _selectedStoreName = selectedStore['storeName'];

                          var storeData = {
                            'storeId': _selectedStoreId,
                            'storeName': _selectedStoreName,
                            'address': selectedStore['address'] ?? '',
                            'province': selectedStore['selectedProvince'] ?? '',
                            'kabupaten':
                                selectedStore['selectedKabupaten'] ?? '',
                            'name': selectedStore['name'] ?? '',
                          };

                          if (!_selectedStores.any((store) =>
                              store['storeId'] == _selectedStoreId)) {
                            _selectedStores.add(storeData);
                          }
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Store',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a store';
                        }
                        return null;
                      },
                    );
                  },
                ),
              const SizedBox(height: 16),
              _selectedStores.isNotEmpty
                  ? Column(
                      children: _selectedStores.map((store) {
                        return ListTile(
                          title: Text(store['storeName']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Address: ${store['address']}'),
                              Text('Province: ${store['province']}'),
                              Text('Kabupaten: ${store['kabupaten']}'),
                              Text('Name: ${store['name']}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _selectedStores.remove(store);
                              });
                            },
                          ),
                        );
                      }).toList(),
                    )
                  : const Text('No stores selected'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
