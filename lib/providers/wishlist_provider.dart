import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';

class WishlistProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Product> _wishlistItems = [];
  String? _userId;
  StreamSubscription? _wishlistSubscription;

  List<Product> get wishlistItems => _wishlistItems;

  /// Set user ID and start listening to wishlist changes
  void setUserId(String? userId) {
    if (_userId == userId) return;
    
    _userId = userId;
    _wishlistSubscription?.cancel();
    
    if (userId != null) {
      // Listen to wishlist changes from Firebase
      _wishlistSubscription = _firebaseService
          .streamWishlist(userId)
          .listen((products) {
        _wishlistItems = products;
        notifyListeners();
      });
    } else {
      _wishlistItems = [];
      notifyListeners();
    }
  }

  /// Load wishlist from Firebase (one-time)
  Future<void> loadWishlist() async {
    if (_userId == null) return;
    
    _wishlistItems = await _firebaseService.getWishlist(_userId!);
    notifyListeners();
  }

  /// Cek apakah produk ada di wishlist berdasarkan nama atau id
  bool isInWishlist(Product product) {
    return _wishlistItems.any((item) => 
      item.id == product.id || item.name == product.name);
  }

  /// Toggle produk di wishlist (tambah jika belum ada, hapus jika sudah ada)
  Future<void> toggleWishlist(Product product) async {
    if (_userId == null) {
      // Local only if not logged in
      if (isInWishlist(product)) {
        _wishlistItems.removeWhere((item) => 
          item.id == product.id || item.name == product.name);
      } else {
        _wishlistItems.add(product.copyWith(isFavorite: true));
      }
      notifyListeners();
      return;
    }

    // Firebase sync
    if (isInWishlist(product)) {
      await _firebaseService.removeFromWishlist(_userId!, product.id ?? '');
    } else {
      await _firebaseService.addToWishlist(_userId!, product);
    }
  }

  /// Hapus produk dari wishlist
  Future<void> removeFromWishlist(Product product) async {
    if (_userId == null) {
      _wishlistItems.removeWhere((item) => 
        item.id == product.id || item.name == product.name);
      notifyListeners();
      return;
    }

    await _firebaseService.removeFromWishlist(_userId!, product.id ?? '');
  }

  /// Tambah produk ke wishlist
  Future<void> addToWishlist(Product product) async {
    if (isInWishlist(product)) return;
    
    if (_userId == null) {
      _wishlistItems.add(product.copyWith(isFavorite: true));
      notifyListeners();
      return;
    }

    await _firebaseService.addToWishlist(_userId!, product);
  }

  /// Bersihkan semua wishlist
  void clearWishlist() {
    _wishlistItems.clear();
    notifyListeners();
  }

  /// Jumlah item di wishlist
  int get itemCount => _wishlistItems.length;

  @override
  void dispose() {
    _wishlistSubscription?.cancel();
    super.dispose();
  }
}
