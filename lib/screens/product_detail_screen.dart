import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/product_provider.dart';

class ProductDetailScreen extends ConsumerWidget {
  final int productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
      ),
      body: productAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(
                    productDetailProvider(productId),
                  );
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (product) {
          final images = [
            product.thumbnail,
            ...product.images.where(
              (image) => image != product.thumbnail,
            ),
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 280,
                  child: PageView.builder(
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        images[index],
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) {
                          return const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 60,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Product Name
                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 4),

                // Rating
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Rating: ${product.rating}'),
                ),

                const SizedBox(height: 4),

                // Price
                if (product.discountedPrice != null) ...[
                  Row(
                    children: [
                      Text(
                        '\$${product.discountedPrice!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                ] else
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                const SizedBox(height: 15),

                // Category
                Text('Category: ${product.category}'),

                const SizedBox(height: 10),

                // Stock
                Text('Stock: ${product.stock}'),

                const SizedBox(height: 20),

                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(product.description),
              ],
            ),
          );
        },
      ),
    );
  }
}
