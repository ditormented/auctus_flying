import 'package:auctus_call/utilities/colors.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(PromotionList());
}

class PromotionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PromotionListScreen();
  }
}

class PromotionListScreen extends StatelessWidget {
  final List<Map<String, String>> promotions = [
    {
      'title': 'Diskon 50% untuk Sepatu',
      'description':
          'Dapatkan diskon 50% untuk semua sepatu. Penawaran terbatas!',
    },
    {
      'title': 'Beli 1 Gratis 1',
      'description': 'Beli satu item dan dapatkan satu lagi secara gratis!',
    },
    {
      'title': 'Sale Musim Panas',
      'description': 'Diskon hingga 70% untuk koleksi musim panas.',
    },
    {
      'title': 'Produk Baru',
      'description': 'Lihat koleksi produk terbaru kami.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Text(
          'Promosi',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: promotions.length,
        itemBuilder: (context, index) {
          final promotion = promotions[index];
          return PromotionCard(
            title: promotion['title']!,
            description: promotion['description']!,
            icon: Icons.local_offer,
          );
        },
      ),
    );
  }
}

class PromotionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const PromotionCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
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
                child: Icon(
                  icon,
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
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Tambahkan aksi di sini
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
