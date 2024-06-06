import 'package:auctus_call/utilities/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductList extends StatefulWidget {
  final String userID;

  const ProductList({
    super.key,
    required this.userID,
  });

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  late TextEditingController _searchController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterItems);
    _fetchItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchItems() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('products').get();
      List<Map<String, dynamic>> loadedItems = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      setState(() {
        items = loadedItems;
        filteredItems = loadedItems;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching items: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterItems() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredItems = items;
      } else {
        filteredItems = items.where((item) {
          final code = item['Code']?.toString().toLowerCase() ?? '';
          final name = item['Name']?.toString().toLowerCase() ?? '';
          return code.contains(query) || name.contains(query);
        }).toList();
      }
    });
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: const EdgeInsets.all(8.0),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(
                  item['image'] ?? 'https://via.placeholder.com/150',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 150,
                  errorBuilder: (context, error, stackTrace) =>
                      Center(child: Icon(Icons.error)),
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              item['Name'] ?? 'No name',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Code: ${item['Code']?.toString() ?? 'No code'}',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
            Text(
              'Price: Rp ${item['ppnPrice']?.toString() ?? 'No price'}',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
            Text(
              'Stock: ${item['quantityCbr']?.toString() ?? 'No stock info'}',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categories = [
      'Nivea Sun',
      'Nivea Men',
      'Nivea Deodorant',
      'NCRM Cremes',
      'Nivea Body',
      'Nivea Deodorant Men',
      'Nivea Face Care',
      'NCL Lip Care'
    ];

    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        backgroundColor: mainColor,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          elevation: 5,
          backgroundColor: mainColor,
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.white,
                filled: true,
                prefixIcon: Icon(Icons.search, color: mainColor),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
              ),
              style: TextStyle(color: mainColor),
            ),
          ),
          bottom: TabBar(
            isScrollable: true,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: secColor, width: 4.0),
              insets: EdgeInsets.symmetric(horizontal: 16.0),
            ),
            unselectedLabelColor: Colors.white,
            labelColor: Colors.white,
            tabs: categories.map((String category) {
              return Tab(text: category);
            }).toList(),
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                children: categories.map((String category) {
                  List<Map<String, dynamic>> categoryItems =
                      filteredItems.where((item) {
                    return item['Category'] == category;
                  }).toList();
                  return GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: categoryItems.length,
                    itemBuilder: (context, index) {
                      final item = categoryItems[index];
                      return _buildItemCard(item);
                    },
                  );
                }).toList(),
              ),
      ),
    );
  }
}
