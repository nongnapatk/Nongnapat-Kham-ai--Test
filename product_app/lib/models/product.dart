class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double? discountPercentage;
  final double? discountedPrice;
  final double rating;
  final int stock;
  final String brand;
  final String thumbnail;
  final List<String> images;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    this.discountPercentage,
    this.discountedPrice,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.thumbnail,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final price = (json['price'] as num).toDouble();
    final discountPercentage = (json['discountPercentage'] as num?)?.toDouble();

    final discountedPrice = discountPercentage != null
        ? double.parse(
            (price * (1 - discountPercentage / 100)).toStringAsFixed(2),
          )
        : null;

    return Product(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: price,
      discountPercentage: discountPercentage,
      discountedPrice: discountedPrice,
      rating: (json['rating'] as num).toDouble(),
      stock: json['stock'] ?? 0,
      brand: json['brand'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      images: List<String>.from(json['images'] ?? []),
    );
  }
}
