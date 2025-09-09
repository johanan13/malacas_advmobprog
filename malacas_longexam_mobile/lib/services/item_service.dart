import 'dart:convert';
import 'package:http/http.dart';
import 'package:malacas_longexam_mobile/constants.dart';


class ItemService {
  List listData = [];

  Future<List> getAllItem() async {
    try {
      final response = await get(
        Uri.parse('$host/api/items'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Dart/3.0 (Flutter)'
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        listData = decodedData['items'];

        print('List data: $listData');
        return listData;
      } else {
        print('Response: ${response.body}');
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error: $error');
      rethrow;
    }
  }


   Future<Map> createItem(dynamic item) async {
    try {
      final response = await post(
        Uri.parse('$host/api/items'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(item),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map mapData =jsonDecode(response.body);
        return mapData;
      } else {
        throw Exception('Failed to create item: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
      rethrow;
    }
  }

  Future<Map> updateItem(String id, dynamic item) async {
    try {
      final response = await put(
        Uri.parse('$host/api/items/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(item),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map mapData =jsonDecode(response.body);
        return mapData;
      } else {
        throw Exception('Failed to update item: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
      rethrow;
    }
  }

Future<Map> deleteItem(String id) async {
  try {
    final response = await delete(
      Uri.parse('$host/api/items/$id'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Map mapData = jsonDecode(response.body);
      return mapData;
    } else {
      throw Exception('Failed to delete item: ${response.statusCode} ${response.body}');
    }
  } catch (error) {
    print('Error: $error');
    rethrow;
  }
}
}