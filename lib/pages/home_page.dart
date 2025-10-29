import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product.dart';
import '../data/dummy_data.dart';
import '../widgets/product_card.dart';
import 'best_seller_page.dart';
import 'new_collection_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Product> bestSellers;
  late List<Product> newCollections;

  @override
  void initState() {
    super.initState();
    bestSellers = List.from(bestSellerProducts);
    newCollections = List.from(newCollectionProducts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f5f2),
      appBar: AppBar(
        title: const Text("Home Decor"),
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
            }),
            _buildHorizontalProductList(bestSellers),
            // New Collection Section
            _buildSectionTitle("New Collection", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NewCollectionPage()),
              );
            }),
            _buildHorizontalProductList(newCollections),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
            style:
              GoogleFonts.poppins(
                color: Color(0xFF2B2B2B),
                fontSize: 20, 
                fontWeight: FontWeight.bold
              )
          ),
          TextButton(
            onPressed: onTap,
            child: Text(
              "See All",
              style: GoogleFonts.poppins(
                color: Colors.brown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalProductList(List<Product> products) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
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
      ),
    );
  }
}
