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

  void updateTabController() {
    setState(() {
      _brandTabController = TabController(length: brands.length, vsync: this);
      _categoryTabController = TabController(
          length: categories[selectedIndexBrand].length, vsync: this);
    });
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
      margin: const EdgeInsets.all(8.0), // Adjusted margin
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Adjusted padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(
                  item['image'] ?? 'https://via.placeholder.com/150',
                  fit: BoxFit.cover,
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
                fontSize: 16, // Adjusted font size
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
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

  final List<List<String>> categories = [
    [
      'Nivea Sun',
      'Nivea Men',
      'Nivea Deodorant',
      'NCRM Cremes',
      'Nivea Body',
      'Nivea Deodorant Men',
      'Nivea Face Care',
      'NLC Lip Care'
    ],
    ['Jolly', 'Nice'],
  ];
  final List<String> brands = ['Beiersdorf', 'PASEO'];
  int selectedIndexBrand = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 5,
        backgroundColor: mainColor,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
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
          preferredSize: Size.fromHeight(50.0),
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
                onTap: (value) {
                  setState(() {
                    selectedIndexBrand = value;
                    updateTabController();
                  });
                },
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TabBar(
                  controller: _categoryTabController,
                  isScrollable: true,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(color: secColor, width: 4.0),
                    insets: EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  unselectedLabelColor: Colors.black,
                  labelColor: Colors.black,
                  tabs: categories[selectedIndexBrand].map((String category) {
                    return Tab(text: category);
                  }).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _brandTabController,
                    children: brands.map((String brand) {
                      List<Map<String, dynamic>> brandItems =
                          filteredItems.where((item) {
                        return item['brand'] == brand;
                      }).toList();
                      List<String> brandCategories =
                          categories[selectedIndexBrand].where((category) {
                        return brandItems
                            .any((item) => item['Category'] == category);
                      }).toList();
                      return TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        controller: _categoryTabController,
                        children: brandCategories.map((String category) {
                          List<Map<String, dynamic>> categoryItems =
                              brandItems.where((item) {
                            return item['Category'] == category;
                          }).toList();
                          return GridView.builder(
                            padding: const EdgeInsets.all(4.0),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.4, // Adjusted aspect ratio
                            ),
                            itemCount: categoryItems.length,
                            itemBuilder: (context, index) {
                              final item = categoryItems[index];
                              return _buildItemCard(item);
                            },
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
