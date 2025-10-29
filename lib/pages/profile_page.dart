import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> options = [
      {"icon": Icons.shopping_bag_outlined, "title": "My Orders"},
      {"icon": Icons.location_on_outlined, "title": "Shipping Address"},
      {"icon": Icons.payment_outlined, "title": "Payment Methods"},
      {"icon": Icons.favorite_outline, "title": "Wishlist"},
      {"icon": Icons.settings_outlined, "title": "Settings"},
      {"icon": Icons.logout, "title": "Logout"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        titleTextStyle: GoogleFonts.poppins(
            color: Colors.brown, 
            fontSize: 24, 
            fontWeight: FontWeight.bold
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.brown.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage("assets/images/profile.jpg"),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("John Doe",
                        style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold
                        )
                      ),
                      Text("johndoe@email.com",
                        style: GoogleFonts.poppins(
                          color: Colors.grey
                        )
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Option Menu
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: options.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = options[index];
                return ListTile(
                  leading: Icon(item["icon"], color: Colors.brown),
                  title: Text(item["title"],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500
                    )
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
