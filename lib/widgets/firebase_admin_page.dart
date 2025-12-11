import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../models/product.dart';
import '../providers/settings_provider.dart';

// =====================
// Firebase Admin Page
// =====================

/// Halaman Admin Firebase untuk mengelola semua produk
class FirebaseProductsPage extends StatefulWidget {
  const FirebaseProductsPage({super.key});

  @override
  State<FirebaseProductsPage> createState() => _FirebaseProductsPageState();
}

class _FirebaseProductsPageState extends State<FirebaseProductsPage> {
  final firebaseService = FirebaseService();
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Firebase Admin',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? theme.appBarTheme.backgroundColor : Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter kategori
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? theme.cardColor : Colors.brown.shade50,
            child: Row(
              children: [
                Text(
                  'Filter: ',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all', isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip('Best Seller', 'best_seller', isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip('New Collection', 'new_collection', isDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Daftar produk
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _selectedCategory == 'all'
                  ? firebaseService.streamAllProducts()
                  : firebaseService.streamProductsByCategory(_selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        ),
                      ],
                    ),
                  );
                }

                final products = snapshot.data ?? [];

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada produk',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap tombol + untuk menambah produk baru',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductCard(product, isDark, theme);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        backgroundColor: isDark ? theme.colorScheme.primary : Colors.brown,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isDark) {
    final isSelected = _selectedCategory == value;
    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          color: isSelected 
              ? Colors.white 
              : (isDark ? Colors.white70 : Colors.brown),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedCategory = value),
      backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
      selectedColor: isDark ? Colors.brown.shade700 : Colors.brown,
      checkmarkColor: Colors.white,
      side: BorderSide.none,
    );
  }

  /// Helper widget untuk menampilkan gambar (support asset dan network URL)
  Widget _buildImageWidget(String imageUrl, double size, bool isDark) {
    if (imageUrl.startsWith('http')) {
      // Network image from Firebase Storage
      return Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: size,
            height: size,
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    } else {
      // Local asset image
      return Image.asset(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          child: const Icon(Icons.image, color: Colors.grey),
        ),
      );
    }
  }

  Widget _buildProductCard(Product product, bool isDark, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImageWidget(product.image, 60, isDark),
            ),
            const SizedBox(width: 12),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11, 
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: product.category == 'best_seller'
                              ? (isDark ? Colors.orange.shade900 : Colors.orange.shade100)
                              : (isDark ? Colors.blue.shade900 : Colors.blue.shade100),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category == 'best_seller'
                              ? 'Best Seller'
                              : 'New Collection',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: product.category == 'best_seller'
                                ? (isDark ? Colors.orange.shade200 : Colors.orange.shade800)
                                : (isDark ? Colors.blue.shade200 : Colors.blue.shade800),
                          ),
                        ),
                      ),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.brown.shade300 : Colors.brown,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            // Menu Button
            PopupMenuButton(
              icon: Icon(
                Icons.more_vert, 
                size: 20,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              color: theme.cardColor,
              padding: EdgeInsets.zero,
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.blue, size: 18),
                      const SizedBox(width: 8),
                      Text('Edit', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                    ],
                  ),
                  onTap: () => Future.delayed(
                    Duration.zero,
                    () => _showEditProductDialog(context, product),
                  ),
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                    ],
                  ),
                  onTap: () => Future.delayed(
                    Duration.zero,
                    () => _showDeleteConfirmation(context, product),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    final imageUrlController = TextEditingController();
    String category = 'best_seller';
    String previewUrl = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Tambah Produk Baru', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image Preview
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: previewUrl.isNotEmpty
                        ? Image.network(
                            previewUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 40, color: Colors.grey.shade500),
                              const SizedBox(height: 4),
                              Text('Preview Gambar', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                // Image URL Input
                TextField(
                  controller: imageUrlController,
                  decoration: InputDecoration(
                    labelText: 'URL Gambar',
                    labelStyle: GoogleFonts.poppins(),
                    hintText: 'https://example.com/image.jpg',
                    hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.preview, color: Colors.brown),
                      onPressed: () {
                        setDialogState(() {
                          previewUrl = imageUrlController.text;
                        });
                      },
                    ),
                  ),
                  onChanged: (value) {
                    // Auto preview when URL looks complete
                    if (value.startsWith('http') && (value.endsWith('.jpg') || value.endsWith('.png') || value.endsWith('.jpeg') || value.endsWith('.webp'))) {
                      setDialogState(() => previewUrl = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Produk',
                    labelStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Harga (\$)',
                    labelStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    labelStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    labelStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'best_seller', child: Text('Best Seller')),
                    DropdownMenuItem(value: 'new_collection', child: Text('New Collection')),
                  ],
                  onChanged: (value) => setDialogState(() => category = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || priceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nama dan harga harus diisi!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.pop(ctx);
                
                try {
                  String imageUrl = imageUrlController.text.isNotEmpty 
                      ? imageUrlController.text 
                      : 'assets/images/default_product.png';

                  await firebaseService.addProduct(
                    name: nameController.text,
                    price: double.tryParse(priceController.text) ?? 0,
                    description: descController.text,
                    image: imageUrl,
                    category: category,
                  );
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Produk berhasil ditambahkan!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(text: product.price.toString());
    final descController = TextEditingController(text: product.description);
    final imageUrlController = TextEditingController(text: product.image);
    String category = product.category ?? 'best_seller';
    String previewUrl = product.image;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit Produk', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image Preview
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: previewUrl.startsWith('http')
                        ? Image.network(
                            previewUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                            ),
                          )
                        : previewUrl.startsWith('assets')
                            ? Image.asset(
                                previewUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.image, size: 40, color: Colors.grey),
                                ),
                              )
                            : const Center(
                                child: Icon(Icons.image, size: 40, color: Colors.grey),
                              ),
                  ),
                ),
                const SizedBox(height: 12),
                // Image URL Input
                TextField(
                  controller: imageUrlController,
                  decoration: InputDecoration(
                    labelText: 'URL Gambar',
                    labelStyle: GoogleFonts.poppins(),
                    hintText: 'https://example.com/image.jpg',
                    hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.preview, color: Colors.brown),
                      onPressed: () {
                        setDialogState(() {
                          previewUrl = imageUrlController.text;
                        });
                      },
                    ),
                  ),
                  onChanged: (value) {
                    if (value.startsWith('http') && (value.endsWith('.jpg') || value.endsWith('.png') || value.endsWith('.jpeg') || value.endsWith('.webp'))) {
                      setDialogState(() => previewUrl = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Produk',
                    labelStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Harga (\$)',
                    labelStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    labelStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    labelStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'best_seller', child: Text('Best Seller')),
                    DropdownMenuItem(value: 'new_collection', child: Text('New Collection')),
                  ],
                  onChanged: (value) => setDialogState(() => category = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                
                try {
                  await firebaseService.updateProduct(
                    productId: product.id!,
                    name: nameController.text,
                    price: double.tryParse(priceController.text) ?? product.price,
                    description: descController.text,
                    image: imageUrlController.text,
                    category: category,
                  );
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Produk berhasil diupdate!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
              child: const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus Produk', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${product.name}"?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await firebaseService.deleteProduct(product.id!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Produk berhasil dihapus!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
