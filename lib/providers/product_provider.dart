import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return ProductRepository(dio);
});

final productDetailProvider = FutureProvider.family<Product, int>((ref, id) {
  final repository = ref.watch(productRepositoryProvider);

  return repository.getProductById(id);
});

class ProductListState {
  final List<Product> products;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const ProductListState({
    this.products = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  ProductListState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return ProductListState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class ProductListNotifier extends StateNotifier<ProductListState> {
  final ProductRepository repository;

  static const int pageSize = 10;

  ProductListNotifier(this.repository) : super(const ProductListState()) {
    loadProducts();
  }

  // Load products
  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await repository.getProducts(
        limit: pageSize,
        skip: 0,
      );

      final List<Product> products = result['products'];

      state = state.copyWith(
        products: products,
        isLoading: false,
        hasMore: products.length < result['total'],
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Pull to Refresh
  Future<void> refreshProducts() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      clearError: true,
    );

    try {
      final result = await repository.getProducts(
        limit: pageSize,
        skip: 0,
      );

      final List<Product> products = result['products'];

      state = state.copyWith(
        products: products,
        isLoading: false,
        isLoadingMore: false,
        hasMore: products.length < result['total'],
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Load More / Pagination
  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }

    state = state.copyWith(
      isLoadingMore: true,
      clearError: true,
    );

    try {
      final result = await repository.getProducts(
        limit: pageSize,
        skip: state.products.length,
      );

      final List<Product> newProducts = result['products'];

      final allProducts = [
        ...state.products,
        ...newProducts,
      ];

      state = state.copyWith(
        products: allProducts,
        isLoadingMore: false,
        hasMore: allProducts.length < result['total'],
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }
}

final productListProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  final repository = ref.watch(productRepositoryProvider);

  return ProductListNotifier(repository);
});
