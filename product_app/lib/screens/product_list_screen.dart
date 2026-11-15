import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/shimmer.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productListProvider);
    final notifier = ref.read(productListProvider.notifier);

    if (state.isLoading && state.products.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.error != null && state.products.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Products')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.red,
              ),
              Text(state.error!),
              ElevatedButton(
                onPressed: notifier.loadProducts,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.products.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Products')),
        body: RefreshIndicator(
          onRefresh: notifier.refreshProducts,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 200),
              Center(child: Text('No products found')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: notifier.refreshProducts,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                final crossAxisCount = width >= 900
                    ? 4
                    : width >= 600
                        ? 3
                        : 2;

                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo.metrics.extentAfter < 300 &&
                        state.hasMore &&
                        !state.isLoadingMore &&
                        state.error == null) {
                      notifier.loadMore();
                    }

                    return false;
                  },
                  child: GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: state.products.length +
                        (state.isLoadingMore || state.error != null ? 1 : 0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: width >= 600 ? 0.85 : 0.68,
                    ),
                    itemBuilder: (context, index) {
                      if (index >= state.products.length) {
                        if (state.isLoadingMore) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state.error != null) {
                          return Center(
                            child: TextButton(
                              onPressed: notifier.loadMore,
                              child: const Text('Retry loading'),
                            ),
                          );
                        }
                      }

                      final product = state.products[index];

                      return ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(
                                productId: product.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Shimmer
          if (state.isLoading && state.products.isNotEmpty)
            const Positioned.fill(
              child: IgnorePointer(
                child: ProductShimmer(),
              ),
            ),
        ],
      ),
    );
  }
}
