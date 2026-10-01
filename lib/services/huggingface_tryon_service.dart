import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class HuggingFaceTryOnException implements Exception {
  final String message;

  HuggingFaceTryOnException(this.message);

  @override
  String toString() => message;
}

class HuggingFaceTryOnService {
  /// URL directe du Gradio Space.
  ///
  /// ATTENTION :
  /// ce n'est PAS :
  /// https://huggingface.co/spaces/yisol/IDM-VTON
  ///
  /// mais bien le serveur Gradio.
  static const String _baseUrl =
      'https://yisol-idm-vton.hf.space';

  /// Facultatif pour un Space public.
  ///
  /// Lance par exemple :
  ///
  /// flutter run --dart-define=HF_TOKEN=hf_xxxxx
  ///
  /// Le token n'est donc pas écrit dans Git.
  ///
  /// IMPORTANT : il reste malgré tout extractible d'une APK compilée.
  static const String _hfToken =
  String.fromEnvironment(
    'HF_TOKEN',
    defaultValue: '',
  );

  Map<String, String> get _headers {
    final headers = <String, String>{};

    if (_hfToken.isNotEmpty) {
      headers['Authorization'] =
      'Bearer $_hfToken';
    }

    return headers;
  }

  // ==========================================================
  // API PRINCIPALE
  // ==========================================================

  Future<Uint8List> generateTryOn({
    required Uint8List personImage,
    required String garmentImageUrl,
    required String garmentDescription,
    bool autoMask = true,
    bool autoCrop = true,
    int denoiseSteps = 30,
    int seed = 42,
  }) async {
    try {
      // --------------------------------------------------------
      // 1. Envoyer la photo locale vers Gradio
      // --------------------------------------------------------

      final String uploadedPersonPath =
      await _uploadImage(
        personImage,
        filename: 'person.jpg',
      );

      // --------------------------------------------------------
      // 2. Lancer IDM-VTON
      // --------------------------------------------------------

      final String eventId =
      await _startPrediction(
        personPath: uploadedPersonPath,
        garmentImageUrl: garmentImageUrl,
        garmentDescription:
        garmentDescription,
        autoMask: autoMask,
        autoCrop: autoCrop,
        denoiseSteps: denoiseSteps,
        seed: seed,
      );

      // --------------------------------------------------------
      // 3. Attendre la génération
      // --------------------------------------------------------

      final String resultUrl =
      await _waitForResult(
        eventId,
      );

      // --------------------------------------------------------
      // 4. Télécharger l'image finale
      // --------------------------------------------------------

      return await _downloadResult(
        resultUrl,
      );
    } on HuggingFaceTryOnException {
      rethrow;
    } on TimeoutException {
      throw HuggingFaceTryOnException(
        "Le service IA met trop de temps à répondre.",
      );
    } catch (e) {
      throw HuggingFaceTryOnException(
        "Erreur pendant l'essayage IA : $e",
      );
    }
  }

  // ==========================================================
  // UPLOAD DE LA PHOTO UTILISATEUR
  // ==========================================================

  Future<String> _uploadImage(
      Uint8List imageBytes, {
        required String filename,
      }) async {
    final Uri uri = Uri.parse(
      '$_baseUrl/upload',
    );

    final request =
    http.MultipartRequest(
      'POST',
      uri,
    );

    request.headers.addAll(
      _headers,
    );

    // Gradio attend le champ "files".
    request.files.add(
      http.MultipartFile.fromBytes(
        'files',
        imageBytes,
        filename: filename,
      ),
    );

    final streamedResponse =
    await request.send().timeout(
      const Duration(seconds: 60),
    );

    final response =
    await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw HuggingFaceTryOnException(
        "Échec upload photo "
            "(${response.statusCode}) : "
            "${response.body}",
      );
    }

    final dynamic decoded =
    jsonDecode(response.body);

    if (decoded is! List ||
        decoded.isEmpty) {
      throw HuggingFaceTryOnException(
        "Hugging Face n'a retourné "
            "aucun fichier après l'upload.",
      );
    }

    final dynamic first = decoded.first;

    // Selon la version de Gradio,
    // /upload peut retourner directement
    // le chemin sous forme de String.
    if (first is String) {
      return first;
    }

    // Compatibilité avec certaines
    // versions retournant un objet.
    if (first is Map) {
      final dynamic path =
      first['path'];

      if (path != null) {
        return path.toString();
      }
    }

    throw HuggingFaceTryOnException(
      "Format de réponse upload inconnu : "
          "${response.body}",
    );
  }

  // ==========================================================
  // LANCER IDM-VTON
  // ==========================================================

  Future<String> _startPrediction({
    required String personPath,
    required String garmentImageUrl,
    required String garmentDescription,
    required bool autoMask,
    required bool autoCrop,
    required int denoiseSteps,
    required int seed,
  }) async {
    final Uri uri = Uri.parse(
      '$_baseUrl/call/tryon',
    );

    // ImageEditor de Gradio :
    //
    // {
    //   background: image,
    //   layers: [],
    //   composite: null
    // }
    final personEditorData = {
      'background': {
        'path': personPath,
      },
      'layers': <dynamic>[],
      'composite': null,
    };

    // Pour le vêtement, ton imageUrl est
    // déjà une URL Internet accessible.
    final garmentData = {
      'path': garmentImageUrl,
    };

    final Map<String, dynamic> payload = {
      'data': [
        // 1 - Image personne
        personEditorData,

        // 2 - Image vêtement
        garmentData,

        // 3 - Description vêtement
        garmentDescription,

        // 4 - Auto masking
        autoMask,

        // 5 - Auto crop
        autoCrop,

        // 6 - Denoising steps
        denoiseSteps,

        // 7 - Seed
        seed,
      ],
    };

    final Map<String, String> headers = {
      'Content-Type':
      'application/json',
      ..._headers,
    };

    final response =
    await http
        .post(
      uri,
      headers: headers,
      body: jsonEncode(payload),
    )
        .timeout(
      const Duration(
        seconds: 60,
      ),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw HuggingFaceTryOnException(
        "Impossible de démarrer l'IA "
            "(${response.statusCode}) : "
            "${response.body}",
      );
    }

    final Map<String, dynamic> data =
    jsonDecode(response.body);

    final String? eventId =
    data['event_id']?.toString();

    if (eventId == null ||
        eventId.isEmpty) {
      throw HuggingFaceTryOnException(
        "Hugging Face n'a pas retourné "
            "d'event_id.",
      );
    }

    return eventId;
  }

  // ==========================================================
  // ATTENDRE LE RESULTAT SSE
  // ==========================================================

  Future<String> _waitForResult(
      String eventId,
      ) async {
    final Uri uri = Uri.parse(
      '$_baseUrl/call/tryon/$eventId',
    );

    final request =
    http.Request(
      'GET',
      uri,
    );

    request.headers.addAll(
      _headers,
    );

    final response =
    await request.send().timeout(
      const Duration(
        seconds: 60,
      ),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw HuggingFaceTryOnException(
        "Impossible de récupérer "
            "le résultat IA "
            "(${response.statusCode}).",
      );
    }

    String currentEvent = '';

    await for (final line
    in response.stream
        .transform(utf8.decoder)
        .transform(
      const LineSplitter(),
    )
        .timeout(
      const Duration(
        minutes: 5,
      ),
    )) {
      // Exemple :
      //
      // event: heartbeat
      //
      // event: complete
      // data: [...]

      if (line.startsWith('event:')) {
        currentEvent = line
            .substring(
          'event:'.length,
        )
            .trim();

        continue;
      }

      if (!line.startsWith('data:')) {
        continue;
      }

      final String rawData = line
          .substring(
        'data:'.length,
      )
          .trim();

      if (currentEvent == 'error') {
        throw HuggingFaceTryOnException(
          "Le modèle IDM-VTON "
              "a rencontré une erreur : "
              "$rawData",
        );
      }

      if (currentEvent != 'complete') {
        continue;
      }

      final dynamic result =
      jsonDecode(rawData);

      if (result is! List ||
          result.isEmpty) {
        throw HuggingFaceTryOnException(
          "Résultat IDM-VTON vide.",
        );
      }

      // IDM-VTON retourne :
      //
      // [0] = image finale
      // [1] = masque
      final dynamic output =
      result[0];

      if (output is Map) {
        final dynamic url =
        output['url'];

        if (url != null &&
            url.toString().isNotEmpty) {
          return url.toString();
        }

        // Certaines versions peuvent
        // seulement fournir "path".
        final dynamic path =
        output['path'];

        if (path != null) {
          return _convertPathToUrl(
            path.toString(),
          );
        }
      }

      if (output is String) {
        if (output.startsWith(
          'http',
        )) {
          return output;
        }

        return _convertPathToUrl(
          output,
        );
      }

      throw HuggingFaceTryOnException(
        "Format du résultat IDM-VTON "
            "inconnu : $output",
      );
    }

    throw HuggingFaceTryOnException(
      "La génération s'est terminée "
          "sans retourner d'image.",
    );
  }

  // ==========================================================
  // CONVERTIR PATH GRADIO -> URL
  // ==========================================================

  String _convertPathToUrl(
      String path,
      ) {
    final encoded =
    Uri.encodeComponent(path);

    return '$_baseUrl/file=$encoded';
  }

  // ==========================================================
  // TELECHARGER RESULTAT
  // ==========================================================

  Future<Uint8List> _downloadResult(
      String url,
      ) async {
    final Uri uri =
    Uri.parse(url);

    final response =
    await http
        .get(
      uri,
      headers: _headers,
    )
        .timeout(
      const Duration(
        seconds: 60,
      ),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw HuggingFaceTryOnException(
        "Impossible de télécharger "
            "l'image générée "
            "(${response.statusCode}).",
      );
    }

    return response.bodyBytes;
  }
}