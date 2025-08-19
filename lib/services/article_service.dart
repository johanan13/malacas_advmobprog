import 'dart:convert';
import 'package:http/http.dart' as http;

class ArticleService {
  List listData = [];

  Future<List> getAllArticle() async {
    final response = await http.get(
    Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'Dart/3.0 (Flutter)'
      },
    );

    if (response.statusCode == 200) {
      listData = jsonDecode(response.body);
      return listData;
    } else {
      throw Exception('Failed to load data');
    }
  }
}