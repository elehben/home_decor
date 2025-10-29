import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/product.dart';
import 'package:google_fonts/google_fonts.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late List<Product> _cartItems;

  @override
  void initState() {
    super.initState();
    _cartItems = List.from(cartProducts); // Ambil data dari dummy_data
  }

  double get subtotal =>
      _cartItems.fold(0, (sum, item) => sum + (item.price ?? 0));

  @override
  Widget build(BuildContext context) {
    const double shipping = 20.0;
    final double total = subtotal + shipping;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
        titleTextStyle: GoogleFonts.poppins(
            color: Colors.brown, 
            fontSize: 24, 
            fontWeight: FontWeight.bold
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _cartItems.isEmpty
                  ? Center(
                      child: Text(
                        "Your cart is empty 🛒",
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final product = _cartItems[index];
                        return _cartItem(product, index);
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.brown.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _priceRow("Subtotal", subtotal),
                  _priceRow("Shipping", shipping),
                  const Divider(thickness: 1),
                  _priceRow("Total", total, isBold: true),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Proceeding to checkout...",
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Center(
                      child: Text(
                        "Checkout",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, 
                          fontSize: 16,
                          color: Colors.white
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartItem(Product product, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(product.image ?? '',
              width: 60, height: 60, fit: BoxFit.cover),
        ),
        title: Text(
          product.name ?? 'Unknown',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text("\$${product.price?.toStringAsFixed(2) ?? '0.00'}",
            style: GoogleFonts.poppins(color: Colors.brown, fontWeight: FontWeight.w500)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () {
            setState(() {
              _cartItems.removeAt(index);
            });
          },
        ),
      ),
    );
  }

  Widget _priceRow(String title, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
