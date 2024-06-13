import 'package:auctus_call/utilities/colors.dart';
import 'package:auctus_call/views/salesman/form_inputpromotion.dart';
import 'package:auctus_call/views/salesman/promotiondetail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StoreLeague extends StatefulWidget {
  const StoreLeague({super.key});

  @override
  State<StoreLeague> createState() => _StoreLeagueState();
}

class _StoreLeagueState extends State<StoreLeague> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Store League',
          style: TextStyle(color: Colors.white),
        ),
        foregroundColor: Colors.white,
        backgroundColor: mainColor,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PromotionForm()));
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('promotion')
            .where('onInvoice', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No Promotion Found.'));
          }

          final promotions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: promotions.length,
            itemBuilder: (context, index) {
              final promotion = promotions[index];
              return LeagueCard(
                promotionID: promotion['nopromotion'],
                title: promotion['title'],
                description: promotion['description'],
                period: promotion['periode'],
                isClaim: promotion['isClaim'],
                imageUrl: promotion['bannerURL'] ?? '',
              );
            },
          );
        },
      ),
    );
  }
}

class LeagueCard extends StatelessWidget {
  final String promotionID;
  final String title;
  final String description;
  final String period;
  final String imageUrl;
  final bool isClaim;

  const LeagueCard({
    Key? key,
    required this.promotionID,
    required this.title,
    required this.description,
    required this.period,
    required this.isClaim,
    required this.imageUrl,
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
