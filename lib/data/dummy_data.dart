import '../models/product.dart';

// =====================
// 🛏️ Best Seller Data
// =====================
final List<Map<String, dynamic>> bestSellerData = [
  {
    "title": "Green Bed",
    "image": "assets/images/bed.png",
    "price": 285.00,
    "description": "Comfortable modern green bed made with premium materials.",
  },
  {
    "title": "Kitchen Cart",
    "image": "assets/images/cart.png",
    "price": 40.00,
    "description": "Compact kitchen cart with wooden design and strong wheels.",
  },
  {
    "title": "Kitchen Shelving",
    "image": "assets/images/shelving.png",
    "price": 15.00,
    "description": "Space-saving shelving perfect for your kitchen or living room.",
  },
  {
    "title": "Kitchen Hutch",
    "image": "assets/images/hutch.png",
    "price": 620.00,
    "description": "Large wooden hutch cabinet with modern minimalist finish.",
  },
];

final List<Product> bestSellerProducts =
    bestSellerData.map((data) => Product.fromMap(data)).toList();

// =====================
// 🪑 New Collection Data
// =====================
final List<Map<String, dynamic>> newCollectionData = [
  {
    "title": "Aluminum Chair",
    "image": "assets/images/aluminum_chair.png",
    "price": 120.00,
    "description": "Modern lightweight aluminum chair for cozy living spaces.",
  },
  {
    "title": "Elegance Chair",
    "image": "assets/images/elegance_chair.png",
    "price": 126.00,
    "description": "Stylish and comfortable chair with premium fabric finish.",
  },
  {
    "title": "Modern Sofa",
    "image": "assets/images/modern_sofa.png",
    "price": 200.00,
    "description": "Soft and durable sofa perfect for modern minimalist decor.",
  },
  {
    "title": "Stylish Chair",
    "image": "assets/images/stylish_chair.png",
    "price": 120.00,
    "description": "Chic armchair with wooden legs and soft velvet cushion.",
  },
];

final List<Product> newCollectionProducts =
    newCollectionData.map((data) => Product.fromMap(data)).toList();

// =====================
// 💖 Wishlist Data
// =====================
final List<Map<String, dynamic>> wishlistData = [
  {
    "title": "Modern Sofa",
    "image": "assets/images/modern_sofa.png",
    "price": 420.00,
    "description":
        "A luxurious modern sofa with smooth fabric and solid wood legs.",
  },
  {
    "title": "Stylish Chair",
    "image": "assets/images/stylish_chair.png",
    "price": 240.00,
    "description": "Minimalist oak chair with ergonomic design for daily use.",
  },
  {
    "title": "Minimalist Lamp",
    "image": "assets/images/lamp.png",
    "price": 120.00,
    "description": "Warm white lamp designed for cozy interior lighting.",
  },
];

final List<Product> wishlistProducts =
    wishlistData.map((data) => Product.fromMap(data)).toList();

// =====================
// 🛒 Cart Data (Baru)
// =====================
final List<Map<String, dynamic>> cartData = [
  {
    "title": "Stylish Chair",
    "image": "assets/images/stylish_chair.png",
    "price": 240.00,
    "description": "Minimalist oak chair with ergonomic design for daily use.",
  },
  {
    "title": "Minimalist Lamp",
    "image": "assets/images/lamp.png",
    "price": 120.00,
    "description": "Warm white lamp designed for cozy interior lighting.",
  },
  {
    "title": "Modern Table",
    "image": "assets/images/table.png",
    "price": 350.00,
    "description": "Contemporary table made of fine wood and metal base.",
  },
];

final List<Product> cartProducts =
    cartData.map((data) => Product.fromMap(data)).toList();