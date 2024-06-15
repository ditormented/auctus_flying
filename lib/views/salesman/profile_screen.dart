import 'package:auctus_call/utilities/colors.dart';
import 'package:auctus_call/views/salesman/login.dart';
import 'package:auctus_call/views/salesman/session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String documentID;
  const ProfileScreen({super.key, required this.documentID});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double dynamicFontSize = screenWidth * 0.08;
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(widget.documentID).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Something went wrong")),
          );
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("Document does not exist")),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          String role = data['role'] ?? 'N/A';
          String name = data['name'] ?? 'N/A';
          String email = data['email'] ?? 'N/A';
          String dob = data['birthday'] ?? 'N/A';
          String address = data['address'] ?? 'N/A';
          String phone = data['phone'] ?? 'N/A';
          String? imageUrl = data['imageProfile'];

          return Scaffold(
            backgroundColor: mainColor,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: dynamicFontSize,
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: mainColor,
              elevation: 0,
            ),
            body: Stack(
              children: [
                Container(
                  color: mainColor,
                  height: screenHeight * 0.3,
                  width: screenWidth,
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.1),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: imageUrl != null
                            ? NetworkImage(imageUrl)
                            : const AssetImage('images/auctus_logo.png')
                                as ImageProvider,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        phone,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: screenWidth,
                    height: screenHeight * 0.45,
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ProfileDetailRow(
                            icon: Icons.card_membership_outlined, detail: role),
                        ProfileDetailRow(icon: Icons.email, detail: email),
                        ProfileDetailRow(
                            icon: Icons.calendar_month, detail: dob),
                        ProfileDetailRow(icon: Icons.person, detail: address),
                        ProfileDetailRow(icon: Icons.phone, detail: phone),
                        const SizedBox(height: 20),
                        ProfileActionRow(
                          icon: Icons.logout,
                          text: 'Logout',
                          color: terColor,
                          onTap: () async {
                            final SessionManager sessionManager =
                                SessionManager();
                            await sessionManager.clearUserSession();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                        ),
                        ProfileActionRow(
                          icon: Icons.help,
                          text: 'Help',
                          color: terColor,
                          onTap: () {},
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const Scaffold(
          body: Center(child: Text("Loading...")),
        );
      },
    );
  }
}

class ProfileDetailRow extends StatelessWidget {
  final IconData icon;
  final String detail;

  const ProfileDetailRow({super.key, required this.icon, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: secColor),
          const SizedBox(width: 16),
          Text(
            detail,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileActionRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onTap;

  const ProfileActionRow(
      {super.key,
      required this.icon,
      required this.text,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
