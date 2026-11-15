import 'package:dio/dio.dart';
import '../models/product.dart';

class ProductRepository {
  final Dio dio;

  ProductRepository(this.dio);

  static const String baseUrl = 'https://dummyjson.com';

  Future<Map<String, dynamic>> getProducts({
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/products',
        queryParameters: {
          'limit': limit,
          'skip': skip,
        },
      );

      final data = response.data;

      return {
        'products': (data['products'] as List)
            .map((item) => Product.fromJson(item))
            .toList(),
        'total': data['total'] as int,
      };
    } on DioException catch (e) {
      throw Exception(
        e.message ?? 'Cannot connect to server',
      );
    }
  }

  Future<Product> getProductById(int id) async {
    try {
      final response = await dio.get(
        '$baseUrl/products/$id',
      );

      return Product.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.message ?? 'Cannot load product detail',
      );
    }
  }
}
