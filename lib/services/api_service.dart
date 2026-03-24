import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {

  static const String baseUrl = 'http://10.0.2.2:3000';

  static Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return response;
  }


  static Future<List<dynamic>> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(url);

    // print('GET $endpoint -> ${response.statusCode}');
    // print('BODY: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is Map && decoded['data'] is List) {
        return decoded['data'];
      } else if (decoded is List) {
        return decoded;
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load data from $endpoint');
    }
  }
}







