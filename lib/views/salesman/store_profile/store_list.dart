import 'package:auctus_call/utilities/colors.dart';
import 'package:auctus_call/views/salesman/store_profile/store_object.dart';
import 'package:auctus_call/views/salesman/store_profile/store_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StoreList extends StatefulWidget {
  final String userID;
  StoreList({super.key, required this.userID});

  @override
  State<StoreList> createState() => _StoreListState();
}

class _StoreListState extends State<StoreList> {
  CollectionReference stores = FirebaseFirestore.instance.collection('stores');
  TextEditingController searchStoreController = TextEditingController();
  List<StoreObject> listStore = [];
  List<StoreObject> filteredStore = [];
  String _userEmail = "";
  bool isLoading = true;
  int currentPage = 1;
  int totalPages = 1;
  int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    searchStoreController.addListener(_filterStores);
    getUserData();
  }

  @override
  void dispose() {
    searchStoreController.dispose();
    super.dispose();
  }

  void getUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userID)
          .get();

      if (userDoc.exists) {
        _userEmail = userDoc['email'];

        fetchStores();
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchStores() async {
    try {
      QuerySnapshot storeDocs =
          await stores.where("email", isEqualTo: _userEmail).get();

      setState(() {
        listStore = storeDocs.docs.map(
          (doc) {
            final data = doc.data()
                as Map<String, dynamic>?; // Cast to Map<String, dynamic>?
            Timestamp? docTimestamp = data?.containsKey('timestamp') == true
                ? data!['timestamp'] as Timestamp?
                : null;
            DateTime? visitDate = docTimestamp?.toDate();

            return StoreObject(
              storeId: doc.id,
              address: data?.containsKey('address') == true
                  ? data!['address'] ?? ''
                  : '',
              contactToko: data?.containsKey('contactToko') == true
                  ? data!['contactToko'] ?? ''
                  : '',
              email: data?.containsKey('email') == true
                  ? data!['email'] ?? ''
                  : '',
              name:
                  data?.containsKey('name') == true ? data!['name'] ?? '' : '',
              picName: data?.containsKey('picName') == true
                  ? data!['picName'] ?? ''
                  : '',
              selectedCategory: data?.containsKey('selectedCategory') == true
                  ? data!['selectedCategory'] ?? ''
                  : '',
              selectedKabupaten: data?.containsKey('selectedKabupaten') == true
                  ? data!['selectedKabupaten'] ?? ''
                  : '',
              selectedPlan: data?.containsKey('selectedPlan') == true
                  ? data!['selectedPlan'] ?? ''
                  : '',
              selectedProvince: data?.containsKey('selectedProvince') == true
                  ? data!['selectedProvince'] ?? ''
                  : '',
              status: data?.containsKey('status') == true
                  ? data!['status'] ?? ''
                  : '',
              storeName: data?.containsKey('storeName') == true
                  ? data!['storeName'] ?? ''
                  : '',
              visitDate: visitDate ?? DateTime.now(),
              latitude: data?.containsKey('latitude') == true
                  ? data!['latitude']
                  : 0.0,
              longitude: data?.containsKey('longitude') == true
                  ? data!['longitude']
                  : 0.0,
              storeImageUrl: data?.containsKey('storeImageUrl') == true
                  ? data!['storeImageUrl']
                  : '',
            );
          },
        ).toList();
        filteredStore = listStore;
        totalPages = (listStore.length / itemsPerPage).ceil();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterStores() {
    String query = searchStoreController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredStore = listStore;
      } else {
        filteredStore = listStore.where((store) {
          return store.storeName.toLowerCase().contains(query);
        }).toList();
      }
      totalPages = (filteredStore.length / itemsPerPage).ceil();
      currentPage = 1; // Reset to first page after filtering
    });
  }

  List<StoreObject> _getPaginatedStores() {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    return filteredStore.sublist(startIndex,
        endIndex > filteredStore.length ? filteredStore.length : endIndex);
  }

  void _nextPage() {
    if (currentPage < totalPages) {
      setState(() {
        currentPage++;
      });
    }
  }

  void _prevPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
    }
  }

  void _firstPage() {
    setState(() {
      currentPage = 1;
    });
  }

  void _lastPage() {
    setState(() {
      currentPage = totalPages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 5,
        toolbarHeight: 70,
        backgroundColor: mainColor,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            controller: searchStoreController,
            decoration: InputDecoration(
              hintText: 'Search...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.white,
              filled: true,
              prefixIcon: const Icon(Icons.search, color: mainColor),
              contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
            ),
            style: const TextStyle(color: mainColor),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(32),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 8),
                child: Text(
                  'Total Stores(${filteredStore.length})',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: filteredStore.isEmpty
                        ? const Center(child: Text('No stores found'))
                        : ListView.builder(
                            itemCount: _getPaginatedStores().length,
                            itemBuilder: (context, index) {
                              final store = _getPaginatedStores()[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                // margin: const EdgeInsets.all(8.0),
                                elevation: 5,
                                child: ListTile(
                                  // contentPadding: const EdgeInsets.all(16.0),
                                  tileColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: Text(
                                    store.storeName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: mainColor,
                                      fontSize: 18,
                                    ),
                                  ),
                                  subtitle: Text(
                                    store.email,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: mainColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: const Icon(Icons.store,
                                        color: mainColor, size: 30),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios,
                                      color: mainColor),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StoreProfile(
                                          storeObject: store,
                                          userID: widget.userID,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // First Page Button
                              GestureDetector(
                                onTap: _firstPage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFC8CEF7),
                                      borderRadius: BorderRadius.circular(24)),
                                  child: const Icon(
                                    Icons.first_page,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Prev Page Button
                              GestureDetector(
                                onTap: _prevPage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: mainColor,
                                      borderRadius: BorderRadius.circular(24)),
                                  child: const Icon(
                                    Icons.chevron_left,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text("$currentPage",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const Text(" / ",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text("$totalPages",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              // Next Page Button
                              GestureDetector(
                                onTap: _nextPage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: mainColor,
                                      borderRadius: BorderRadius.circular(24)),
                                  child: const Icon(
                                    Icons.chevron_right,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              // Last page Button
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: _lastPage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFC8CEF7),
                                      borderRadius: BorderRadius.circular(24)),
                                  child: const Icon(
                                    Icons.last_page,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
    );
  }
}
