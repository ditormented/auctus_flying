import 'package:auctus_call/utilities/colors.dart';
import 'package:auctus_call/views/salesman/form_inputpromotion.dart';
import 'package:auctus_call/views/salesman/promotiondetail.dart';
import 'package:auctus_call/views/salesman/session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PromotionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: mainColor,
        title: Text(
          'Promotion List',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final SessionManager sessionManager = SessionManager();
              String? role = await sessionManager.getRole();
              if (role == 'Administrator' || role == 'Head Of C2C') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PromotionForm()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Anda tidak memiliki izin untuk menambah promosi')),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('promotion')
            .where('onInvoice', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No promotions found.'));
          }

          final promotions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: promotions.length,
            itemBuilder: (context, index) {
              final promotion = promotions[index];
              return PromotionCard(
                promotionID: promotion.id,
                title: promotion['title'],
                description: promotion['description'],
                period: promotion['periode'],
                imageUrl: promotion['bannerURL'] ?? '',
                isClaim: promotion['isClaim'],
              );
            },
          );
        },
      ),
    );
  }
}

class PromotionCard extends StatelessWidget {
  final String title;
  final String description;
  final String period;
  final String imageUrl;
  final bool isClaim;
  final String promotionID;

  const PromotionCard({
    Key? key,
    required this.promotionID,
    required this.title,
    required this.description,
    required this.period,
    required this.imageUrl,
    required this.isClaim,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: Container(
              height: 200,
              color: mainColor,
              child: Center(
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.error,
                          size: 100,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        Icons.image,
                        size: 100,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Periode: $period',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PromotionDetail(
                          promotionID: promotionID,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Pelajari Lebih Lanjut',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
