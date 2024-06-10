class PurchaseDocumentObject {
  String callID;
  List<Map<String, dynamic>> items;
  DateTime timestamp; //tadi adatanda tanyanya
  double total;
  String userID;
  // Int quantity;
  String caption;

  PurchaseDocumentObject({
    required this.callID,
    required this.items,
    required this.timestamp,
    required this.total,
    required this.userID,
    // required this.quantity,
    required this.caption,
  });
}
