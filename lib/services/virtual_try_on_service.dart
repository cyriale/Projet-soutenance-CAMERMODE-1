import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'stockimg_client.dart';

/// CLASSE DE RÉSULTAT DE L'ESSAYAGE VIRTUEL IA
class VirtualTryOnResult {
  final bool success;
  final String? resultImageUrl;
  final String message;

  VirtualTryOnResult({
    required this.success,
    this.resultImageUrl,
    required this.message,
  });
}

/// SERVICE D'ESSAYAGE VIRTUEL CONNECTÉ À FIREBASE CLOUD FUNCTIONS & OPENROUTER
class VirtualTryOnService {
  static final VirtualTryOnService _instance = VirtualTryOnService._internal();
  factory VirtualTryOnService() => _instance;
  VirtualTryOnService._internal();

  final StockImgClient _stockImgClient = StockImgClient();

  /// Renvoie l'URL de la Cloud Function selon la plateforme de dev
  String _getFunctionUrl() {
    if (kIsWeb) {
      return "http://127.0.0.1:5001/camermode-2a49d/us-central1/virtualTryOn";
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return "http://10.0.2.2:5001/camermode-2a49d/us-central1/virtualTryOn";
    }
    return "http://127.0.0.1:5001/camermode-2a49d/us-central1/virtualTryOn";
  }

  /// Appelle la Firebase Cloud Function `virtualTryOn` avec des octets bruts (Uint8List)
  Future<VirtualTryOnResult> generateVirtualTryOnBytes({
    required Uint8List personImageBytes,
    required String garmentImageUrl,
    required String articleTitle,
    required String category, // "coiffure" ou "couture"
    String? selectedColor,
  }) async {
    try {
      final String photoUtilisateurPayload = "data:image/jpeg;base64,${base64Encode(personImageBytes)}";
      final functionUrl = _getFunctionUrl();
      debugPrint("📡 [VirtualTryOnService] Envoi HTTP POST (${category.toUpperCase()}) vers : $functionUrl");

      final response = await http.post(
        Uri.parse(functionUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "photoUtilisateur": photoUtilisateurPayload,
          "photoArticle": garmentImageUrl,
          "category": category,
        }),
      ).timeout(
        const Duration(seconds: 90),
        onTimeout: () => throw TimeoutException("Le serveur d'essayage virtuel met trop de temps à répondre (TimeOut)."),
      );

      debugPrint("📊 [VirtualTryOnService] Code statut HTTP : ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bool isSuccess = data['success'] == true;
        final String? resultImg = data['resultImageUrl'];
        final String msg = data['message'] ?? "Essayage généré.";

        if (isSuccess && resultImg != null && resultImg.isNotEmpty) {
          debugPrint("✅ [VirtualTryOnService] Succès Cloud Function Nano Banana 2 !");
          return VirtualTryOnResult(
            success: true,
            resultImageUrl: resultImg,
            message: msg,
          );
        } else {
          return VirtualTryOnResult(
            success: false,
            message: msg,
          );
        }
      } else {
        String errorMsg = "Erreur lors de la génération de l'essayage virtuel (Code ${response.statusCode}).";
        try {
          final data = jsonDecode(response.body);
          if (data['message'] != null) errorMsg = data['message'];
        } catch (_) {}
        return VirtualTryOnResult(
          success: false,
          message: errorMsg,
        );
      }
    } on TimeoutException {
      return VirtualTryOnResult(
        success: false,
        message: "Délai d'attente dépassé. Le serveur d'essayage virtuel n'a pas répondu à temps.",
      );
    } catch (e) {
      debugPrint("❌ [VirtualTryOnService] Erreur réseau ou serveur : $e");
      return VirtualTryOnResult(
        success: false,
        message: "Impossible de contacter le serveur d'essayage local. Vérifiez que l'émulateur Firebase est démarré sur le port 5001.",
      );
    }
  }

  /// Appelle la Firebase Cloud Function `virtualTryOn` qui communique avec OpenRouter (Nano Banana 2)
  Future<VirtualTryOnResult> generateVirtualTryOn({
    required XFile personImageFile,
    required String garmentImageUrl,
    required String articleTitle,
    required String category, // "coiffure" ou "couture"
    String? selectedColor,
  }) async {
    try {
      final bytes = await personImageFile.readAsBytes();
      return await generateVirtualTryOnBytes(
        personImageBytes: bytes,
        garmentImageUrl: garmentImageUrl,
        articleTitle: articleTitle,
        category: category,
        selectedColor: selectedColor,
      );
    } catch (e) {
      return VirtualTryOnResult(
        success: false,
        message: "Erreur lecture de l'image : $e",
      );
    }
  }
}
