import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

/// Client pour l'API StockImg.
/// Permet de stocker des images sur un serveur externe et d'obtenir une URL.
class StockImgClient {
  // CONFIGURATION : Remplacez par vos vraies infos
  static const String _baseUrl = "https://stockimg.onrender.com"; 
  static const String _apiKey = "7|C0k5uA7aU92Zp8q0v9X1b2c3d4e5f6g7h8i9j0"; // Exemple, à remplacer

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_apiKey',
    'Accept': 'application/json',
  };

  /// Envoie une image (XFile) et renvoie son URL publique.
  Future<String?> uploadXFile(XFile file) async {
    try {
      debugPrint("🚀 [StockImg] Début de l'envoi du fichier...");
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/v1/files'),
      );

      request.headers.addAll(_headers);

      // Support Mobile et Web via les bytes
      Uint8List bytes = await file.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: file.name,
        ),
      );

      debugPrint("📤 [StockImg] Envoi de la requête vers $_baseUrl...");
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      debugPrint("📊 [StockImg] Statut réponse : ${response.statusCode}");
      
      if (response.statusCode == 201) {
        var data = jsonDecode(response.body);
        String url = data['data']['url'];
        debugPrint("✅ [StockImg] Fichier uploadé avec succès : $url");
        return url;
      } else {
        debugPrint("❌ [StockImg] Échec de l'upload (${response.statusCode}) : ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ [StockImg] ERREUR critique : $e");
      return null;
    }
  }

  /// Supprime un fichier par son id.
  Future<bool> deleteFile(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/v1/files/$id'),
        headers: _headers,
      );

      if (response.statusCode == 204) {
        debugPrint("🗑️ [StockImg] Fichier supprimé.");
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("❌ [StockImg] Erreur suppression : $e");
      return false;
    }
  }
}
