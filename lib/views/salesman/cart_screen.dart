import 'package:auctus_call/utilities/colors.dart';
import 'package:auctus_call/views/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final String userID;
  final String callID;

  CartScreen({
    required this.cartItems,
    required this.userID,
    required this.callID,
  });

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 2);
  String storeName = '';
  TextEditingController reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStoreName();
    for (var item in widget.cartItems) {
      item['quantity'] = item['quantity'] ?? 1;
    }
  }

  Future<void> _fetchStoreName() async {
    try {
      DocumentSnapshot storeDoc = await FirebaseFirestore.instance
          .collection('stores')
          .doc(widget.callID)
          .get();
      if (storeDoc.exists) {
        setState(() {
          storeName = storeDoc['storeName'] ?? 'Unknown Store';
        });
      }
    } catch (e) {
      print('Error fetching store name: $e');
    }
  }

  void _incrementQuantity(int index) {
    setState(() {
      widget.cartItems[index]['quantity']++;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (widget.cartItems[index]['quantity'] > 1) {
        widget.cartItems[index]['quantity']--;
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      widget.cartItems.removeAt(index);
    });
  }

  double _calculateTotal() {
    double total = 0.0;
    for (var item in widget.cartItems) {
      total += (item['ppnPrice']?.toDouble() ?? 0.0) * (item['quantity'] ?? 1);
    }
    return total;
  }

  Future<void> _savePurchase() async {
    try {
      await FirebaseFirestore.instance.collection('purchases').add({
        'callID': widget.callID,
        'items': widget.cartItems,
        'total': _calculateTotal(),
        'timestamp': FieldValue.serverTimestamp(),
        'userID': widget.userID,
        'caption': reasonController.text, // Menambahkan caption
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase saved successfully')),
      );
      setState(() {
        widget.cartItems.clear();
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(ID: widget.userID)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save purchase: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Text(
          'Cart',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: widget.cartItems.isEmpty
          ? Center(child: Text('No items in the cart'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      var item = widget.cartItems[index];
                      String imageUrl =
                          item['image'] ?? 'https://via.placeholder.com/150';
                      String itemName = item['Name'] ?? 'Unknown';
                      double itemPrice = item['ppnPrice']?.toDouble() ?? 0.0;
                      int itemQuantity = item['quantity'] ?? 1;

                      return ListTile(
                        leading: Image.network(
                          imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Center(child: Icon(Icons.error)),
                        ),
                        title: Text(itemName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price: ${currencyFormat.format(itemPrice)}',
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () => _decrementQuantity(index),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: TextField(
                                    textAlign: TextAlign.center,
                                    controller: TextEditingController(
                                        text: itemQuantity.toString()),
                                    keyboardType: TextInputType.number,
                                    maxLength: 5,
                                    decoration: InputDecoration(
                                      counterText: '',
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        widget.cartItems[index]['quantity'] =
                                            int.tryParse(value) ?? itemQuantity;
                                      });
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () => _incrementQuantity(index),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _removeItem(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: reasonController,
                    maxLines: 3, // Membuat text field lebih besar
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Caption',
                      hintText: 'Enter caption for purchase...',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16.0),
                  margin: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Store Name: $storeName',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                              height:
                                  4), // Spacing between the store name and total
                          Row(
                            children: [
                              Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                currencyFormat.format(_calculateTotal()),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: _savePurchase,
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(10, 30),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_forward,
                                  color: mainColor,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
