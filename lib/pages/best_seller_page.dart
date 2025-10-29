import 'package:flutter/material.dart';
import '../models/product.dart';
import '../data/dummy_data.dart';
import 'package:google_fonts/google_fonts.dart';

class BestSellerPage extends StatelessWidget {
  const BestSellerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        // backgroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Best Seller',
          style: GoogleFonts.poppins(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.search, color: Colors.brown),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          children: [
            // Category Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Living Room', style: GoogleFonts.poppins(color: Color(0xFF1E1E1E), fontWeight: FontWeight.w500)),
                Text('Decorative Light', style: GoogleFonts.poppins(color: Color(0xFF1E1E1E), fontWeight: FontWeight.w500)),
                Text('Bed', style: GoogleFonts.poppins(color: Color(0xFF1E1E1E), fontWeight: FontWeight.w500)),
              ],
            ),
            const Divider(color: Color(0xFF2B2B2B), height: 24),

            // Product Grid
            Expanded(
              child: GridView.builder(
                itemCount: bestSellerProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (context, index) {
                  final Product product = bestSellerProducts[index];
                  return Container(
                    decoration: BoxDecoration(
                      // color: const Color(0xFF2C2C2E),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gambar produk
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.asset(
                              product.image,
                              // fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),

                        // Nama produk
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                          child: Text(
                            product.name,
                            style: GoogleFonts.poppins(
                              color: Color(0xFF2B2B2B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Deskripsi
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            product.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Color(0xFF2B2B2B),
                              fontSize: 12,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        ),

                        // Harga dan ikon
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  color: Color(0xFF2B2B2B),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: const [
                                  Icon(Icons.favorite_border,
                                      color: Colors.pinkAccent, size: 20),
                                  SizedBox(width: 6),
                                  Icon(Icons.add_circle_outline,
                                      color: Color(0xFF2f2f2f), size: 20),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
