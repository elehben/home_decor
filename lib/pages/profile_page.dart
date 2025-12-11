import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/firebase_admin_page.dart';
import '../pages/login_page.dart';
import '../pages/wishlist_page.dart';
import '../pages/profile_subpages.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;
    final theme = Theme.of(context);
    
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final isLoggedIn = authProvider.isLoggedIn;

        final List<Map<String, dynamic>> options = [
          {"icon": Icons.shopping_bag_outlined, "title": "My Orders"},
          {"icon": Icons.location_on_outlined, "title": "Shipping Address"},
          {"icon": Icons.payment_outlined, "title": "Payment Methods"},
          {"icon": Icons.favorite_outline, "title": "Wishlist"},
          {"icon": Icons.cloud_upload_outlined, "title": "Firebase Admin"},
          {"icon": Icons.settings_outlined, "title": "Settings"},
          if (isLoggedIn) {"icon": Icons.logout, "title": "Logout"},
        ];

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text("Profile"),
            titleTextStyle: GoogleFonts.poppins(
              color: theme.colorScheme.primary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: theme.appBarTheme.backgroundColor,
            foregroundColor: theme.appBarTheme.foregroundColor,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                GestureDetector(
                  onTap: () {
                    if (!isLoggedIn) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3D3D3D) : Colors.brown.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: isDark ? const Color(0xFFD7A86E) : Colors.brown.shade200,
                          child: isLoggedIn
                              ? Text(
                                  user!.name[0].toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.white,
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isLoggedIn ? user!.name : 'Guest User',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF2B2B2B),
                                ),
                              ),
                              Text(
                                isLoggedIn
                                    ? user!.email
                                    : 'Tap to login or register',
                                style: GoogleFonts.poppins(
                                  color: isDark ? Colors.grey.shade400 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isLoggedIn)
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: isDark ? Colors.grey.shade400 : Colors.grey,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Option Menu
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: options.length,
                  separatorBuilder: (_, __) => Divider(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                  itemBuilder: (context, index) {
                    final item = options[index];
                    final isLogoutItem = item["title"] == "Logout";

                    return ListTile(
                      leading: Icon(
                        item["icon"],
                        color: isLogoutItem ? Colors.red : theme.colorScheme.primary,
                      ),
                      title: Text(
                        item["title"],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: isLogoutItem 
                              ? Colors.red 
                              : (isDark ? Colors.white : Colors.black),
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios, 
                        size: 16,
                        color: isDark ? Colors.grey.shade400 : Colors.grey,
                      ),
                      onTap: () => _handleOptionTap(
                        context,
                        item["title"],
                        authProvider,
                        isDark,
                        theme,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleOptionTap(
    BuildContext context,
    String title,
    AuthProvider authProvider,
    bool isDark,
    ThemeData theme,
  ) {
    switch (title) {
      case "My Orders":
        if (!authProvider.isLoggedIn) {
          _showLoginRequired(context, isDark, theme);
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyOrdersPage()),
        );
        break;

      case "Shipping Address":
        if (!authProvider.isLoggedIn) {
          _showLoginRequired(context, isDark, theme);
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ShippingAddressPage()),
        );
        break;

      case "Payment Methods":
        if (!authProvider.isLoggedIn) {
          _showLoginRequired(context, isDark, theme);
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaymentMethodsPage()),
        );
        break;

      case "Wishlist":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WishlistPage()),
        );
        break;

      case "Firebase Admin":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FirebaseProductsPage()),
        );
        break;

      case "Settings":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsPage()),
        );
        break;

      case "Logout":
        _showLogoutDialog(context, authProvider, isDark, theme);
        break;
    }
  }

  void _showLoginRequired(BuildContext context, bool isDark, ThemeData theme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Login Required',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'Please login to access this feature.',
          style: GoogleFonts.poppins(
            color: isDark ? Colors.grey.shade300 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Login',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider, bool isDark, ThemeData theme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(
            color: isDark ? Colors.grey.shade300 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              authProvider.logout();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Logged out successfully',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
