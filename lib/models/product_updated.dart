class Product {
  final String? id; // Firebase document ID
  final String name;
  final String image;
  final double price;
  final String description;
  final String? category;
  bool isFavorite;

  Product({
    this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.description,
    this.category,
    this.isFavorite = false,
  });

  /// Factory untuk membuat Product dari Map (Firestore/dummy data)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['title'] ?? map['name'] ?? '',
      image: map['image'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? 'No description available',
      category: map['category'],
    );
  }

  /// Convert Product ke Map untuk upload ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': name,
      'image': image,
      'price': price,
      'description': description,
      if (category != null) 'category': category,
    };
  }

  /// Copy with untuk update properti
  Product copyWith({
    String? id,
    String? name,
    String? image,
    double? price,
    String? description,
    String? category,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
