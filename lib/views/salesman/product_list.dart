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

class _ProductListState extends State<ProductList>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  late TextEditingController _searchController;
  bool isLoading = true;

  late TabController _brandTabController;
  late TabController _categoryTabController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterItems);
    _fetchItems();
    _brandTabController = TabController(length: brands.length, vsync: this);
    _categoryTabController =
        TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _brandTabController.dispose();
    _categoryTabController.dispose();
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
      margin: const EdgeInsets.all(12.0), // Increased margin
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Increased padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(
                  item['image'] ?? 'Icon(Icons.adobe_rounded)',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 150,
                  errorBuilder: (context, error, stackTrace) =>
                      Center(child: Icon(Icons.error)),
                ),
              ),
            ),
            SizedBox(height: 12), // Increased spacing
            Text(
              item['Name'] ?? 'No name',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18, // Increased font size
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6), // Increased spacing
            Text(
              'Code: ${item['Code']?.toString() ?? 'No code'}',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            Text(
              'Price: Rp ${item['ppnPrice']?.toString() ?? 'No price'}',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            Text(
              'Stock Cibubur: ${item['quantityCbr']?.toString() ?? 'No stock info'}',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            Text(
              'Stock Sidoarjo: ${item['quantitySda']?.toString() ?? 'No stock info'}',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

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
  final List<String> brands = ['Beiersdorf', 'PASEO'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(110.0),
          child: Column(
            children: [
              TabBar(
                controller: _brandTabController,
                isScrollable: true,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(color: secColor, width: 4.0),
                  insets: EdgeInsets.symmetric(horizontal: 16.0),
                ),
                unselectedLabelColor: Colors.white,
                labelColor: Colors.white,
                tabs: brands.map((String brand) {
                  return Tab(text: brand);
                }).toList(),
              ),
              TabBar(
                controller: _categoryTabController,
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
            ],
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _brandTabController,
              children: brands.map((String brand) {
                List<Map<String, dynamic>> brandItems =
                    filteredItems.where((item) {
                  return item['brand'] == brand;
                }).toList();
                return Column(
                  children: [
                    Expanded(
                      child: TabBarView(
                        controller: _categoryTabController,
                        children: categories.map((String category) {
                          List<Map<String, dynamic>> categoryItems =
                              brandItems.where((item) {
                            return item['Category'] == category;
                          }).toList();
                          return GridView.builder(
                            padding: const EdgeInsets.all(8.0),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
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
                  ],
                );
              }).toList(),
            ),
    );
  }
}
