import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductService {
  Future<Map<String, dynamic>> getProducts() async {
    final url = Uri.parse('https://dummyjson.com/products');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }
}
