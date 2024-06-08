import 'package:cloud_firestore/cloud_firestore.dart';

class StoreObject {
  String storeId;
  String address;
  String contactToko;
  String email;
  String name;
  String picName;
  String selectedCategory;
  String selectedKabupaten;
  String selectedPlan;
  String selectedProvince;
  String status;
  String storeName;
  DateTime? visitDate;
  StoreObject({
    required this.storeId,
    required this.address,
    required this.contactToko,
    required this.email,
    required this.name,
    required this.picName,
    required this.selectedCategory,
    required this.selectedKabupaten,
    required this.selectedPlan,
    required this.selectedProvince,
    required this.status,
    required this.storeName,
    this.visitDate,
  });
}
