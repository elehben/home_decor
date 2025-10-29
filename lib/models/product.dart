class Product {
  final String name;
  final String image;
  final double price;
  final String description;
  bool isFavorite;

  Product({
    required this.name,
    required this.image,
    required this.price,
    required this.description,
    this.isFavorite = false,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      name: map['title'] ?? '',
      image: map['image'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? 'No description available',
    );
  }
}
