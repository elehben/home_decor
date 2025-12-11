import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}

class CartProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<CartItem> _cartItems = [];
  String? _userId;
  StreamSubscription? _cartSubscription;

  List<CartItem> get cartItems => _cartItems;

  /// Set user ID and start listening to cart changes
  void setUserId(String? userId) {
    print('DEBUG setUserId called: old=$_userId, new=$userId');
    if (_userId == userId) return;
    
    _userId = userId;
    _cartSubscription?.cancel();
    
    if (userId != null) {
      print('DEBUG: Starting to listen to cart for userId=$userId');
      // Listen to cart changes from Firebase
      _cartSubscription = _firebaseService
          .streamCart(userId)
          .listen((cartData) {
        print('DEBUG: Received cart data from Firebase: ${cartData.length} items');
        _cartItems = cartData.map((data) {
          return CartItem(
            product: Product(
              id: data['id'] ?? data['productId'] ?? '',
              name: data['name'] ?? '',
              price: (data['price'] ?? 0).toDouble(),
              image: data['image'] ?? '',
              description: data['description'] ?? '',
              category: data['category'],
            ),
            quantity: data['quantity'] ?? 1,
          );
        }).toList();
        notifyListeners();
      });
    } else {
      _cartItems = [];
      notifyListeners();
    }
  }

  /// Load cart from Firebase (one-time)
  Future<void> loadCart() async {
    if (_userId == null) return;
    
    final cartData = await _firebaseService.getCart(_userId!);
    _cartItems = cartData.map((data) {
      return CartItem(
        product: Product(
          id: data['id'] ?? data['productId'] ?? '',
          name: data['name'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          image: data['image'] ?? '',
          description: data['description'] ?? '',
          category: data['category'],
        ),
        quantity: data['quantity'] ?? 1,
      );
    }).toList();
    notifyListeners();
  }

  /// Jumlah total item di cart
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  /// Subtotal harga
  double get subtotal =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  /// Cek apakah produk ada di cart berdasarkan nama atau id
  bool isInCart(Product product) {
    return _cartItems.any((item) => 
      item.product.id == product.id || item.product.name == product.name);
  }

  /// Ambil CartItem berdasarkan produk
  CartItem? getCartItem(Product product) {
    try {
      return _cartItems.firstWhere((item) => 
        item.product.id == product.id || item.product.name == product.name);
    } catch (e) {
      return null;
    }
  }

  /// Tambah produk ke cart
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    print('DEBUG addToCart: userId=$_userId, productId=${product.id}, productName=${product.name}');
    
    if (_userId == null) {
      // Local only if not logged in
      print('DEBUG: User not logged in, saving locally');
      final existingItem = getCartItem(product);
      if (existingItem != null) {
        existingItem.quantity += quantity;
      } else {
        _cartItems.add(CartItem(product: product, quantity: quantity));
      }
      notifyListeners();
      return;
    }

    // Firebase sync
    print('DEBUG: Saving to Firebase for userId=$_userId');
    try {
      await _firebaseService.addToCart(_userId!, product, quantity);
      print('DEBUG: Successfully saved to Firebase');
    } catch (e) {
      print('DEBUG: Error saving to Firebase: $e');
    }
  }

  /// Hapus produk dari cart
  Future<void> removeFromCart(Product product) async {
    if (_userId == null) {
      _cartItems.removeWhere((item) => 
        item.product.id == product.id || item.product.name == product.name);
      notifyListeners();
      return;
    }

    final productId = product.id ?? product.name.replaceAll(' ', '_').toLowerCase();
    await _firebaseService.removeFromCart(_userId!, productId);
  }

  /// Update quantity item di cart
  Future<void> updateQuantity(Product product, int quantity) async {
    if (_userId == null) {
      final existingItem = getCartItem(product);
      if (existingItem != null) {
        if (quantity <= 0) {
          _cartItems.removeWhere((item) => 
            item.product.id == product.id || item.product.name == product.name);
        } else {
          existingItem.quantity = quantity;
        }
        notifyListeners();
      }
      return;
    }

    final productId = product.id ?? product.name.replaceAll(' ', '_').toLowerCase();
    await _firebaseService.updateCartQuantity(_userId!, productId, quantity);
  }

  /// Tambah quantity
  Future<void> incrementQuantity(Product product) async {
    final existingItem = getCartItem(product);
    if (existingItem != null) {
      await updateQuantity(product, existingItem.quantity + 1);
    }
  }

  /// Kurangi quantity
  Future<void> decrementQuantity(Product product) async {
    final existingItem = getCartItem(product);
    if (existingItem != null) {
      await updateQuantity(product, existingItem.quantity - 1);
    }
  }

  /// Bersihkan cart
  Future<void> clearCart() async {
    if (_userId == null) {
      _cartItems.clear();
      notifyListeners();
      return;
    }

    await _firebaseService.clearCart(_userId!);
  }

  /// Create order from cart
  Future<String?> checkout({
    String? shippingAddress,
    String? paymentMethod,
  }) async {
    if (_userId == null || _cartItems.isEmpty) return null;

    final orderItems = _cartItems.map((item) => OrderItem(
      productId: item.product.id ?? '',
      productName: item.product.name,
      productImage: item.product.image,
      price: item.product.price,
      quantity: item.quantity,
    )).toList();

    final orderId = await _firebaseService.createOrder(
      userId: _userId!,
      items: orderItems,
      total: subtotal,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
    );

    // Clear cart after successful order
    await clearCart();
    return orderId;
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }
}
