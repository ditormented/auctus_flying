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
  String latitude;
  String longitude;
  String storeImageUrl;
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
    required this.latitude,
    required this.longitude,
    required this.storeImageUrl,
    this.visitDate,
  });
}
