import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Client pour l'API StockImg.
/// Permet de stocker des images sur un serveur externe et d'obtenir une URL.
class StockImgClient {
  // Récupération de la clé depuis le fichier .env
  String get _apiKey => dotenv.env['STOCKIMG_API_KEY'] ?? "";
  
  // CONFIGURATION : UTILISEZ VOTRE URL EXACTE ICI
  static const String _baseUrl = "https://storage.mrsergio.dev";

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_apiKey',
    'Accept': 'application/json',
  };

  /// Envoie une image (XFile) et renvoie son URL publique.
  Future<String?> uploadXFile(XFile file) async {
    try {
      if (_apiKey.isEmpty) {
        debugPrint("❌ [StockImg] ERREUR : La clé API est vide ! Vérifiez votre fichier .env");
        return null;
      }

      debugPrint("🚀 [StockImg] Préparation de l'envoi...");
      debugPrint("🔗 [StockImg] URL cible : $_baseUrl/api/v1/files");
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/v1/files'),
      );

      request.headers.addAll(_headers);

      // Lecture sécurisée des bytes
      Uint8List bytes = await file.readAsBytes();
      debugPrint("📊 [StockImg] Taille du fichier à envoyer : ${bytes.length} bytes");

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: file.name,
        ),
      );

      debugPrint("📤 [StockImg] Connexion au serveur en cours...");
      
      // Ajout d'un délai d'attente plus long pour Render (serveurs gratuits lents au démarrage)
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 45),
        onTimeout: () => throw "Le serveur met trop de temps à répondre (TimeOut).",
      );
      
      var response = await http.Response.fromStream(streamedResponse);

      debugPrint("📊 [StockImg] Réponse reçue ! Code : ${response.statusCode}");
      
      if (response.statusCode == 201) {
        var data = jsonDecode(response.body);
        String url = data['data']['url'];
        debugPrint("✅ [StockImg] SUCCÈS ! Image disponible ici : $url");
        return url;
      } else {
        debugPrint("❌ [StockImg] ÉCHEC (Code ${response.statusCode}) : ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ [StockImg] ERREUR RÉSEAU : $e");
      if (e.toString().contains("Failed to fetch")) {
        debugPrint("💡 [Conseil] Vérifiez que l'URL $_baseUrl est accessible dans votre navigateur.");
      }
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
