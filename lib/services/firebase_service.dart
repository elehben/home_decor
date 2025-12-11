import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_storage/firebase_storage.dart';
import '../models/product.dart';

// User model untuk Firestore
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? profileImage;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.profileImage,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'profileImage': profileImage,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      address: map['address'],
      profileImage: map['profileImage'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profileImage,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Order model
class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double total;
  final String status; // 'pending', 'processing', 'shipping', 'delivered', 'cancelled'
  final String? shippingAddress;
  final String? paymentMethod;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    this.shippingAddress,
    this.paymentMethod,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'status': status,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    return OrderModel(
      id: docId,
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item))
              .toList() ??
          [],
      total: (map['total'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      shippingAddress: map['shippingAddress'],
      paymentMethod: map['paymentMethod'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
    );
  }
}

// Payment Method model
class PaymentMethodModel {
  final String id;
  final String type; // 'credit_card', 'paypal', 'bank_transfer'
  final String name;
  final String detail;
  final bool isDefault;

  PaymentMethodModel({
    required this.id,
    required this.type,
    required this.name,
    required this.detail,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'detail': detail,
      'isDefault': isDefault,
    };
  }

  factory PaymentMethodModel.fromMap(Map<String, dynamic> map, String docId) {
    return PaymentMethodModel(
      id: docId,
      type: map['type'] ?? 'credit_card',
      name: map['name'] ?? '',
      detail: map['detail'] ?? '',
      isDefault: map['isDefault'] ?? false,
    );
  }
}

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // =====================
  // 📷 Image Storage
  // =====================

  /// Upload image to Firebase Storage and return download URL
  Future<String?> uploadProductImage(File imageFile, String productId) async {
    try {
      final ref = _storage.ref().child('products/$productId.jpg');
      
      // Upload file
      await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      // Get download URL
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Delete image from Firebase Storage
  Future<void> deleteProductImage(String productId) async {
    try {
      final ref = _storage.ref().child('products/$productId.jpg');
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  /// Upload user profile image
  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      final ref = _storage.ref().child('profiles/$userId.jpg');
      await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  // =====================
  // 🔐 Authentication
  // =====================

  /// Get current user
  fb_auth.User? get currentUser => _auth.currentUser;

  /// Auth state changes stream
  Stream<fb_auth.User?> get authStateChanges => _auth.authStateChanges();

  /// Register new user
  Future<UserModel?> register(
      String name, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(name);

        // Create user in Firestore
        final userModel = UserModel(
          uid: credential.user!.uid,
          name: name,
          email: email,
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userModel.toMap());

        return userModel;
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      print('Register error: ${e.message}');
      rethrow;
    }
    return null;
  }

  /// Login user
  Future<UserModel?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        return await getUserData(credential.user!.uid);
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      print('Login error: ${e.message}');
      rethrow;
    }
    return null;
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // =====================
  // 👤 User Data
  // =====================

  /// Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  /// Update user profile
  Future<void> updateUserProfile(String uid,
      {String? name, String? phone, String? address}) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (address != null) updates['address'] = address;

    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(uid).update(updates);
    }
  }

  /// Stream user data
  Stream<UserModel?> streamUserData(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!) : null);
  }

  // =====================
  // 📤 Upload Products
  // =====================

  /// Upload semua produk best seller ke Firestore
  Future<void> uploadBestSellerProducts(
      List<Map<String, dynamic>> products) async {
    final batch = _firestore.batch();
    final collection = _firestore.collection('products');

    for (var product in products) {
      final docRef = collection.doc();
      batch.set(docRef, {
        ...product,
        'category': 'best_seller',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    print('✅ Best seller products uploaded successfully!');
  }

  /// Upload semua produk new collection ke Firestore
  Future<void> uploadNewCollectionProducts(
      List<Map<String, dynamic>> products) async {
    final batch = _firestore.batch();
    final collection = _firestore.collection('products');

    for (var product in products) {
      final docRef = collection.doc();
      batch.set(docRef, {
        ...product,
        'category': 'new_collection',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    print('✅ New collection products uploaded successfully!');
  }

  /// Upload semua dummy data sekaligus
  Future<void> uploadAllDummyData({
    required List<Map<String, dynamic>> bestSellers,
    required List<Map<String, dynamic>> newCollection,
  }) async {
    await uploadBestSellerProducts(bestSellers);
    await uploadNewCollectionProducts(newCollection);
    print('✅ All dummy data uploaded to Firebase!');
  }

  // =====================
  // 📥 Fetch Products
  // =====================

  /// Ambil semua produk
  Future<List<Product>> getAllProducts() async {
    final snapshot = await _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Product.fromMap({
        'id': doc.id,
        ...data,
      });
    }).toList();
  }

  /// Ambil produk berdasarkan kategori
  Future<List<Product>> getProductsByCategory(String category) async {
    final snapshot = await _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Product.fromMap({
        'id': doc.id,
        ...data,
      });
    }).toList();
  }

  /// Ambil produk best seller
  Future<List<Product>> getBestSellerProducts() async {
    return getProductsByCategory('best_seller');
  }

  /// Ambil produk new collection
  Future<List<Product>> getNewCollectionProducts() async {
    return getProductsByCategory('new_collection');
  }

  /// Stream produk (realtime updates)
  Stream<List<Product>> streamProductsByCategory(String category) {
    return _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Product.fromMap({
                'id': doc.id,
                ...data,
              });
            }).toList());
  }

  /// Stream semua produk (realtime updates)
  Stream<List<Product>> streamAllProducts() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Product.fromMap({
                'id': doc.id,
                ...data,
              });
            }).toList());
  }

  /// Tambah produk baru
  Future<String> addProduct({
    required String name,
    required double price,
    required String description,
    required String image,
    required String category,
  }) async {
    final docRef = await _firestore.collection('products').add({
      'name': name,
      'price': price,
      'description': description,
      'image': image,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// Update produk
  Future<void> updateProduct({
    required String productId,
    required String name,
    required double price,
    required String description,
    required String image,
    required String category,
  }) async {
    await _firestore.collection('products').doc(productId).update({
      'name': name,
      'price': price,
      'description': description,
      'image': image,
      'category': category,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Hapus produk
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  // =====================
  // ❤️ Wishlist (per User)
  // =====================

  /// Tambah produk ke wishlist user
  Future<void> addToWishlist(String userId, Product product) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(product.id)
        .set({
      'productId': product.id,
      'name': product.name,
      'price': product.price,
      'image': product.image,
      'description': product.description,
      'category': product.category,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Hapus produk dari wishlist
  Future<void> removeFromWishlist(String userId, String productId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(productId)
        .delete();
  }

  /// Stream wishlist user
  Stream<List<Product>> streamWishlist(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Product(
                id: doc.id,
                name: data['name'] ?? '',
                price: (data['price'] ?? 0).toDouble(),
                image: data['image'] ?? '',
                description: data['description'] ?? '',
                category: data['category'],
                isFavorite: true,
              );
            }).toList());
  }

  /// Get wishlist (one-time)
  Future<List<Product>> getWishlist(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Product(
        id: doc.id,
        name: data['name'] ?? '',
        price: (data['price'] ?? 0).toDouble(),
        image: data['image'] ?? '',
        description: data['description'] ?? '',
        category: data['category'],
        isFavorite: true,
      );
    }).toList();
  }

  // =====================
  // 🛒 Cart (per User)
  // =====================

  /// Tambah produk ke cart
  Future<void> addToCart(
      String userId, Product product, int quantity) async {
    // Use product.id or generate from name if id is null
    final productId = product.id ?? product.name.replaceAll(' ', '_').toLowerCase();
    
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId);

    final doc = await docRef.get();
    if (doc.exists) {
      final currentQty = doc.data()?['quantity'] ?? 0;
      await docRef.update({'quantity': currentQty + quantity});
    } else {
      await docRef.set({
        'productId': productId,
        'name': product.name,
        'price': product.price,
        'image': product.image,
        'description': product.description,
        'category': product.category,
        'quantity': quantity,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Update quantity di cart
  Future<void> updateCartQuantity(
      String userId, String productId, int quantity) async {
    if (productId.isEmpty) return;
    
    if (quantity <= 0) {
      await removeFromCart(userId, productId);
    } else {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .update({'quantity': quantity});
    }
  }

  /// Hapus produk dari cart
  Future<void> removeFromCart(String userId, String productId) async {
    if (productId.isEmpty) return;
    
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  /// Clear cart
  Future<void> clearCart(String userId) async {
    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Stream cart user
  Stream<List<Map<String, dynamic>>> streamCart(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                ...data,
              };
            }).toList());
  }

  /// Get cart (one-time)
  Future<List<Map<String, dynamic>>> getCart(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }

  // =====================
  // 📦 Orders
  // =====================

  /// Create new order
  Future<String> createOrder({
    required String userId,
    required List<OrderItem> items,
    required double total,
    String? shippingAddress,
    String? paymentMethod,
  }) async {
    final docRef = _firestore.collection('orders').doc();
    final order = OrderModel(
      id: docRef.id,
      userId: userId,
      items: items,
      total: total,
      status: 'pending',
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
    );

    await docRef.set(order.toMap());

    // Also add to user's orders subcollection for easy querying
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc(docRef.id)
        .set(order.toMap());

    return docRef.id;
  }

  /// Get user orders
  Future<List<OrderModel>> getUserOrders(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Stream user orders
  Stream<List<OrderModel>> streamUserOrders(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Update order status
  Future<void> updateOrderStatus(
      String userId, String orderId, String status) async {
    await _firestore
        .collection('orders')
        .doc(orderId)
        .update({'status': status});

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc(orderId)
        .update({'status': status});
  }

  // =====================
  // 💳 Payment Methods
  // =====================

  /// Add payment method
  Future<void> addPaymentMethod(
      String userId, PaymentMethodModel paymentMethod) async {
    // If this is default, remove default from others
    if (paymentMethod.isDefault) {
      await _setAllPaymentMethodsNotDefault(userId);
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('paymentMethods')
        .doc(paymentMethod.id)
        .set(paymentMethod.toMap());
  }

  /// Remove payment method
  Future<void> removePaymentMethod(String userId, String paymentId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('paymentMethods')
        .doc(paymentId)
        .delete();
  }

  /// Set payment method as default
  Future<void> setDefaultPaymentMethod(String userId, String paymentId) async {
    await _setAllPaymentMethodsNotDefault(userId);

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('paymentMethods')
        .doc(paymentId)
        .update({'isDefault': true});
  }

  Future<void> _setAllPaymentMethodsNotDefault(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('paymentMethods')
        .where('isDefault', isEqualTo: true)
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }
    await batch.commit();
  }

  /// Get payment methods
  Future<List<PaymentMethodModel>> getPaymentMethods(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('paymentMethods')
        .get();

    return snapshot.docs
        .map((doc) => PaymentMethodModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Stream payment methods
  Stream<List<PaymentMethodModel>> streamPaymentMethods(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('paymentMethods')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaymentMethodModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // =====================
  // ⚙️ User Settings
  // =====================

  /// Save user settings
  Future<void> saveUserSettings(
      String userId, Map<String, dynamic> settings) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('preferences')
        .set(settings, SetOptions(merge: true));
  }

  /// Get user settings
  Future<Map<String, dynamic>?> getUserSettings(String userId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('preferences')
        .get();

    return doc.exists ? doc.data() : null;
  }

  /// Stream user settings
  Stream<Map<String, dynamic>?> streamUserSettings(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('preferences')
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }
}
