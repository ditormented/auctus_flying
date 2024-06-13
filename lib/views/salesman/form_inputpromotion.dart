import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:auctus_call/utilities/colors.dart';

class PromotionForm extends StatefulWidget {
  @override
  _PromotionFormState createState() => _PromotionFormState();
}

class _PromotionFormState extends State<PromotionForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noPromotionController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _periodeController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  bool _isClaim = false;
  bool _onInvoice = false;
  bool _isLoading = false;
  String? _imageUrl;
  XFile? _image;

  @override
  void dispose() {
    _titleController.dispose();
    _noPromotionController.dispose();
    _descriptionController.dispose();
    _periodeController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  Future<void> _uploadImage(XFile image) async {
    try {
      String fileName = path.basename(image.path);
      Reference storageReference =
          FirebaseStorage.instance.ref().child('promotions/$fileName');
      UploadTask uploadTask = storageReference.putFile(File(image.path));
      await uploadTask;
      String imageUrl = await storageReference.getDownloadURL();

      setState(() {
        _imageUrl = imageUrl;
      });
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _submitPromotion() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_image != null) {
          await _uploadImage(_image!);
        }

        await FirebaseFirestore.instance.collection('promotion').add({
          'title': _titleController.text,
          'nopromotion': _noPromotionController.text,
          'description': _descriptionController.text,
          'periode': _periodeController.text,
          'budget': _budgetController.text,
          'isClaim': _isClaim,
          'onInvoice': _onInvoice,
          'bannerURL': _imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Promotion added successfully!')),
        );

        // Clear the form
        _formKey.currentState!.reset();
        setState(() {
          _isClaim = false;
          _isLoading = false;
          _image = null;
          _imageUrl = null;
          _onInvoice = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add promotion: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: mainColor,
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: mainColor, width: 2.0),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: mainColor),
          ),
          labelStyle: TextStyle(color: mainColor),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: Text('Add Promotion', style: TextStyle(color: Colors.white)),
          backgroundColor: mainColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                SizedBox(height: 4),
                _buildTextField(
                  controller: _noPromotionController,
                  label: 'Promotion Number',
                ),
                SizedBox(height: 10),
                _buildTextField(
                  controller: _titleController,
                  label: 'Title',
                ),
                SizedBox(height: 10),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                ),
                SizedBox(height: 10),
                _buildTextField(
                  controller: _periodeController,
                  label: 'Periode',
                ),
                SizedBox(height: 10),
                _buildTextField(
                  controller: _budgetController,
                  label: 'Budget',
                ),
                SizedBox(height: 10),
                SwitchListTile(
                  title: Text('Is Claim?', style: TextStyle(color: mainColor)),
                  activeColor: mainColor,
                  value: _isClaim,
                  onChanged: (bool value) {
                    setState(() {
                      _isClaim = value;
                    });
                  },
                ),
                SwitchListTile(
                  title:
                      Text('On Invoice ?', style: TextStyle(color: mainColor)),
                  activeColor: mainColor,
                  value: _onInvoice,
                  onChanged: (bool value) {
                    setState(() {
                      _onInvoice = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image, color: mainColor),
                  label: Text(
                    'Select Banner Promotion',
                    style: TextStyle(color: mainColor),
                  ),
                ),
                _image != null
                    ? Image.file(
                        File(_image!.path),
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      )
                    : Container(),
                SizedBox(height: 20),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: ElevatedButton(
                          onPressed: _submitPromotion,
                          child: Text(
                            'Submit',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: mainColor, width: 2.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a $label';
        }
        return null;
      },
    );
  }
}
