import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/wishlist_provider.dart';
import '../providers/settings_provider.dart';
import '../pages/product_detail_page.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onFavoriteToggle;

  const ProductCard({
    super.key,
    required this.product,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () {
        // Navigate to Product Detail Page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black12,
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Hero(
                    tag: 'product-${product.name}',
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      color: isDark ? const Color(0xFF3D3D3D) : const Color(0xFFF5F5F5),
                      child: _buildProductImage(product.image, 120),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Consumer<WishlistProvider>(
                    builder: (context, wishlistProvider, child) {
                      final isWishlisted = wishlistProvider.isInWishlist(product);
                      return GestureDetector(
                        onTap: () {
                          wishlistProvider.toggleWishlist(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isWishlisted
                                    ? '${product.name} dihapus dari wishlist'
                                    : '${product.name} ditambahkan ke wishlist',
                              ),
                              duration: const Duration(seconds: 1),
                              backgroundColor: isWishlisted ? Colors.grey : Colors.green,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? Colors.black.withValues(alpha: 0.5) 
                                : Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isWishlisted ? Icons.favorite : Icons.favorite_border,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(product.name,
                style: GoogleFonts.poppins(
                  fontSize: 14, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF2B2B2B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('\$${product.price.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary,
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper widget untuk menampilkan gambar (support asset dan network URL)
  Widget _buildProductImage(String imageUrl, double height) {
    if (imageUrl.startsWith('http')) {
      // Network image from Firebase Storage
      return Image.network(
        imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
        ),
      );
    } else {
      // Local asset image
      return Image.asset(
        imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.fill,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.image, color: Colors.grey, size: 40),
        ),
      );
    }
  }
}