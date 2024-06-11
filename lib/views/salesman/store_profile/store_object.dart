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
  DateTime visitDate;
  double latitude;
  double longitude;
  String storeImageUrl;
  String reverseGeotagging;

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
    required this.visitDate,
    required this.latitude,
    required this.longitude,
    required this.storeImageUrl,
    required this.reverseGeotagging,
  });
}
