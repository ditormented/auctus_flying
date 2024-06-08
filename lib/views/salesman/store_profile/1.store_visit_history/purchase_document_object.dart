class PurchaseDocumentObject {
  String callID;
  List<Map<String, dynamic>> items;
  DateTime? timestamp;
  double total;
  String userID;

  PurchaseDocumentObject({
    required this.callID,
    required this.items,
    required this.timestamp,
    required this.total,
    required this.userID,
  });
}
