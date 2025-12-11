import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';
import '../widgets/product_card.dart';
import '../providers/settings_provider.dart';
import 'best_seller_page.dart';
import 'new_collection_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Home Decor"),
        titleTextStyle: GoogleFonts.poppins(
            color: theme.colorScheme.primary, 
            fontSize: 24, 
            fontWeight: FontWeight.bold
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner Section
            Container(
              margin: const EdgeInsets.all(16),
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/images/banner.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            // Best Seller Section
            _buildSectionTitle("Best Seller", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BestSellerPage()),
              );
            }, isDark, theme),
            _buildFirebaseProductList('best_seller'),
            // New Collection Section
            _buildSectionTitle("New Collection", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NewCollectionPage()),
              );
            }, isDark, theme),
            _buildFirebaseProductList('new_collection'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback onTap, bool isDark, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
            style:
              GoogleFonts.poppins(
                color: isDark ? Colors.white : const Color(0xFF2B2B2B),
                fontSize: 20, 
                fontWeight: FontWeight.bold
              )
          ),
          TextButton(
            onPressed: onTap,
            child: Text(
              "See All",
              style: GoogleFonts.poppins(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirebaseProductList(String category) {
    return SizedBox(
      height: 220,
      child: StreamBuilder<List<Product>>(
        stream: _firebaseService.streamProductsByCategory(category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading products',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            );
          }
          
          final products = snapshot.data ?? [];
          
          if (products.isEmpty) {
            return Center(
              child: Text(
                'No products available',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            );
          }
          
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(
                product: products[index],
                onFavoriteToggle: () {
                  setState(() {
                    products[index].isFavorite = !products[index].isFavorite;
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
