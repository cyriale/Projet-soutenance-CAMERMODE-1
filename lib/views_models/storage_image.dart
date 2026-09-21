import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Client minimal pour l'API StockImg.
class StockImgClient {
  StockImgClient({required this.baseUrl, required this.apiKey});

  final String baseUrl;
  final String apiKey;

  Map<String, String> get _headers => {'Authorization': 'Bearer $apiKey'};

  /// Envoie un fichier (image ou PDF) et renvoie son URL publique.
  Future<String> uploadFile(File file) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/v1/files'),
    )
      ..headers.addAll(_headers)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 201) {
      throw Exception('Upload échoué (${response.statusCode}): $body');
    }

    final data = jsonDecode(body) as Map<String, dynamic>;
    return (data['data'] as Map<String, dynamic>)['url'] as String;
  }

  /// Liste les fichiers déjà envoyés par l'utilisateur.
  Future<List<Map<String, dynamic>>> listFiles() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/files'),
      headers: _headers,
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['data'] as List).cast<Map<String, dynamic>>();
  }

  /// Supprime un fichier par son id.
  Future<void> deleteFile(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/v1/files/$id'),
      headers: _headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Suppression échouée (${response.statusCode})');
    }
  }
}