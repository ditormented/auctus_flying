import 'package:auctus_call/utilities/colors.dart';
import 'package:auctus_call/views/salesman/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainCatalog extends StatefulWidget {
  final String userID;
  final String imageURL;
  final Map<String, dynamic> callVariable;

  const MainCatalog({
    super.key,
    required this.userID,
    required this.imageURL,
    required this.callVariable,
  });

  @override
  State<MainCatalog> createState() => _MainCatalogState();
}

class _MainCatalogState extends State<MainCatalog>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  List<Map<String, dynamic>> cartItems = [];
  late TextEditingController _searchController;
  bool isLoading = true;
  String selectedBrand = 'Beiersdorf';
  late TabController _categoryTabController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterItems);
    _fetchItems();
    _categoryTabController =
        TabController(length: categories[0].length, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
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

  void _addItemToCart(Map<String, dynamic> item) {
    setState(() {
      // Menambah item ke keranjang dengan jumlah default 1 jika belum ada
      int index =
          cartItems.indexWhere((element) => element['Code'] == item['Code']);
      if (index != -1) {
        cartItems[index]['quantity']++;
      } else {
        cartItems.add({...item, 'quantity': 1});
      }
    });
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['Name'] ?? 'No name',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Code: ${item['Code']?.toString() ?? 'No code'}',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
            Text(
              'Price: Rp ${item['ppnPrice']?.toString() ?? 'No price'}',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
            Text(
              'Stock Cibubur : ${item['quantityCbr']?.toString() ?? 'No stock info'}',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
            Text(
              'Stock Sidoarjo : ${item['quantitySda']?.toString() ?? 'No stock info'}',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
            Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.add_circle,
                    color: mainColor, size: 30), // Perbesar ikon
                onPressed: () {
                  _addItemToCart(item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          cartItems: cartItems,
          callVariable: widget.callVariable,
          userID: widget.userID,
          imageURL: widget.imageURL,
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
    [
      'Elegant Facial',
      'Facial Tissue',
      'Paseo Royal',
      'Toilet Core Emboss',
      'Toilet Core Non Emboss',
      'Toilet Interfold',
      'Towel Tissue',
      'Wipes Tissue'
    ],
  ];
  final List<String> brands = ['Beiersdorf', 'PASEO'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories[brands.indexOf(selectedBrand)]
          .length, // Sesuaikan panjang TabBar dengan jumlah kategori
      child: Scaffold(
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
            padding: const EdgeInsets.symmetric(vertical: 0.0),
            child: Row(
              children: [
                Expanded(
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
                SizedBox(width: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: DropdownButton<String>(
                    value: selectedBrand,
                    icon: Icon(Icons.arrow_drop_down, color: mainColor),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedBrand = newValue!;
                        _categoryTabController = TabController(
                          length:
                              categories[brands.indexOf(selectedBrand)].length,
                          vsync: this,
                        );
                      });
                    },
                    items: brands.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: mainColor, fontSize: 13),
                        ),
                      );
                    }).toList(),
                    underline: SizedBox(), // Remove the underline
                  ),
                ),
              ],
            ),
          ),
          bottom: TabBar(
            tabAlignment: TabAlignment.start,
            controller: _categoryTabController,
            isScrollable: true,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: secColor, width: 4.0),
              insets: EdgeInsets.symmetric(horizontal: 16.0),
            ),
            unselectedLabelColor: Colors.white,
            labelColor: Colors.white,
            tabs: categories[brands.indexOf(selectedBrand)]
                .map((String category) {
              return Tab(text: category);
            }).toList(),
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _categoryTabController,
                children: categories[brands.indexOf(selectedBrand)]
                    .map((String category) {
                  List<Map<String, dynamic>> categoryItems =
                      filteredItems.where((item) {
                    return item['Category'] == category &&
                        item['brand'] == selectedBrand;
                  }).toList();
                  return GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio:
                          0.6, // Menambah ruang vertikal untuk setiap kartu
                    ),
                    itemCount: categoryItems.length,
                    itemBuilder: (context, index) {
                      final item = categoryItems[index];
                      return _buildItemCard(item);
                    },
                  );
                }).toList(),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToCart,
          backgroundColor: secColor,
          child: Icon(Icons.shopping_cart,
              color: Colors.white), // Ganti warna ikon keranjang menjadi putih
        ),
      ),
    );
  }
}
