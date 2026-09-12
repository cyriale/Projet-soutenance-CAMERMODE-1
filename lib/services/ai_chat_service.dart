import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class AIChatService {
  static final AIChatService _instance = AIChatService._internal();
  factory AIChatService() => _instance;
  AIChatService._internal();

  // Clé API configurable dynamiquement
  static String _apiKey = "AIzaSyAf3c6sj2_o6iKZySlvQTETCMHk6Lh_uvQI"; // Clé Google Services du projet
  GenerativeModel? _generativeModel;

  void updateApiKey(String newKey) {
    if (newKey.trim().isNotEmpty) {
      _apiKey = newKey.trim();
      _initModel();
    }
  }

  void _initModel() {
    try {
      if (_apiKey.isNotEmpty && _apiKey.startsWith("AIza")) {
        _generativeModel = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: _apiKey,
        );
      }
    } catch (e) {
      debugPrint("Erreur init GenerativeModel: $e");
    }
  }

  /// Répondre intelligemment à l'utilisateur dans n'importe quel langage
  Future<String> getAIResponse(String userPrompt, {String? userMorphology, String? userFaceShape}) async {
    final cleanPrompt = userPrompt.trim();
    if (cleanPrompt.isEmpty) return "Posez-moi une question sur votre style, un tissu ou une tenue !";

    // 1. Tenter l'appel Gemini en ligne si configuré
    if (_generativeModel == null) _initModel();

    if (_generativeModel != null) {
      try {
        final systemPrompt = """
Tu es l'assistant d'intelligence artificielle officiel de l'application CamerMode, la plateforme camerounaise de mode africaine sur-mesure et coiffure.
Tu es polyglotte : réponds dans la langue utilisée par l'utilisateur (Français, Anglais, Camfranglais, etc.).
Contexte utilisateur :
- Morphologie : ${userMorphology ?? 'Non spécifiée'}
- Forme de visage : ${userFaceShape ?? 'Non spécifiée'}

Conseille avec précision sur :
- Les tissus traditionnels et modernes (Ndop de l'Ouest, Toghu du Nord-Ouest, Bazin riche, Wax, Soie, Lin).
- Les coupes adaptées à la silhouette (Sablier X, Rectangle H, Pyramide A, V, Ronde O).
- Les coiffures africaines selon la forme du visage (Tresses fulani, Knotless braids, Locks, Nappy afro, Dégradé wave).
- Les estimations de prix en Francs CFA (FCFA) et le temps de confection au Cameroun.
- Reste bienveillant, inspirant, élégant et concis.
""";

        final content = [
          Content.text("$systemPrompt\n\nQuestion de l'utilisateur : $cleanPrompt")
        ];

        final response = await _generativeModel!.generateContent(content);
        if (response.text != null && response.text!.trim().isNotEmpty) {
          return response.text!.trim();
        }
      } catch (e) {
        debugPrint("Gemini indisponible ou quota atteint ($e). Activation du moteur local expert.");
      }
    }

    // 2. Moteur IA expert local multilingue intégré (100% fiable, zéro échec)
    return _generateLocalExpertResponse(cleanPrompt, userMorphology, userFaceShape);
  }

  /// Moteur IA Styliste intégré adapté aux expressions et réalités africaines
  String _generateLocalExpertResponse(String prompt, String? morphology, String? faceShape) {
    final lower = prompt.toLowerCase();

    // Détection Anglais
    bool isEnglish = lower.contains("how") || lower.contains("what") || lower.contains("dress") || lower.contains("hair") || lower.contains("wedding") || lower.contains("price");
    // Détection Camfranglais
    bool isCamfranglais = lower.contains("waka") || lower.contains("mougou") || lower.contains("mbeng") || lower.contains("kaba") || lower.contains("ndop") || lower.contains("toghu") || lower.contains("dos") || lower.contains("le way");

    // 1. Tissus & Traditions (Ndop, Toghu, Bazin, Wax)
    if (lower.contains("ndop") || lower.contains("ouest") || lower.contains("grassfields") || lower.contains("bamileke")) {
      if (isEnglish) {
        return "✨ **Ndop Fabric (Cameroon Grassfields Heritage)**:\n"
            "Ndop is a prestigious indigo textile with royal geometric symbols from Western Cameroon.\n"
            "• **For Women**: A fitted bustier gown with a Ndop train, or a modern blazer paired with plain trousers.\n"
            "• **For Men**: A modern tunic shirt with Ndop borders on the collar and chest.\n"
            "• **Average Tailoring Cost in Cameroon**: 25,000 to 60,000 FCFA depending on finishing.\n"
            "• **Best Accessorizing**: Cowrie jewelry, wooden beads or subtle gold.";
      }
      return "👑 **Le Tissu Ndop (Héritage Bamiléké / Grassfields)** :\n"
          "Le Ndop est un textile traditionnel noble teinté à l'indigo avec des symboles royaux géométriques.\n"
          "• **Pour femme** : Robe sirène avec traîne en Ndop, ou veste tailleur contemporaine cintrée avec revers en Ndop.\n"
          "• **Pour homme** : Tunique moderne avec plastron et col Mao brodé en Ndop, parfait pour une dot ou gala.\n"
          "• **Prix moyen de confection** : 25 000 à 65 000 FCFA selon le niveau de broderie.\n"
          "• **Astuce style** : Associez-le avec du noir uni ou du blanc cassé pour mettre en valeur les motifs.";
    }

    if (lower.contains("toghu") || lower.contains("nord-ouest") || lower.contains("bamenda")) {
      return "✨ **Le Toghu Royal (Nord-Ouest Cameroun)** :\n"
          "Le Toghu est un tissu lourd en velours noir richement brodé de fils colorés (or, rouge, jaune, blanc).\n"
          "• **Tenues recommandées** : Boubou royal, robe longue sculptée pour mariage coutumier, ou veste de soirée.\n"
          "• **Occasions idéales** : Dots traditionnelles, investitures, mariages et soirées de prestige.\n"
          "• **Budget moyen** : Tissu brodé + couture sur-mesure de 35 000 à 100 000 FCFA.\n"
          "• **Entretien** : Nettoyage à sec recommandé pour préserver les fils de broderie.";
    }

    if (lower.contains("bazin") || lower.contains("boubou")) {
      return "🌟 **Le Bazin Riche & Boubou Chic** :\n"
          "Le Bazin brille par sa texture damassée et sa tenue impériale.\n"
          "• **Coupes tendance** : Grand boubou 3 pièces avec broderie ton sur ton, ou ensemble pantalon pour femme avec manches ballon.\n"
          "• **Couleurs phares** : Blanc éclatant, vert émeraude, bleu roi, moutarde et violet nuit.\n"
          "• **Prix moyen confection** : 30 000 à 75 000 FCFA.";
    }

    // 2. Mariage, Dot & Cérémonies
    if (lower.contains("mariage") || lower.contains("dot") || lower.contains("coutumier") || lower.contains("wedding")) {
      if (isEnglish) {
        return "💍 **Traditional Wedding & Traditional Engagement Guide**:\n"
            "• **Bride & Groom Matching**: Choose coordinated Toghu or Ndop fabrics with complementary patterns.\n"
            "• **For the Bride**: An off-shoulder corset dress with flared peplum or mermaid silhouette highlights elegance.\n"
            "• **Hairstyle**: Braided crown with golden beads or sophisticated updos.\n"
            "• **Tailoring Deadline**: Plan at least 3 to 4 weeks ahead with your CamerMode provider to allow fittings.";
      }
      return "💍 **Tenue de Mariage Traditionnel & Dot au Cameroun** :\n"
          "• **Pour la mariée** : Robe sirène cintrée en Toghu ou Ndop avec bustier perlé, ou kaba moderne revisité.\n"
          "• **Pour le marié** : Tunique longue col officier assortie aux motifs de la mariée, pantalon droit ajusté.\n"
          "• **Coiffure conseillée** : Chignon haut sculpté avec perles dorées ou tresses fulani royales.\n"
          "• **Délai conseillé** : Commandez chez votre couturier CamerMode 3 à 4 semaines avant l'événement pour les retouches.";
    }

    // 3. Conseils selon la Morphologie
    if (lower.contains("morphologie") || lower.contains("corps") || lower.contains("taille") || lower.contains("silhouette") || morphology != null) {
      final morph = morphology ?? "X (Sablier)";
      return "👗 **Conseil Morphologique Sur-Mesure ($morph)** :\n"
          "• **Silhouette X (Sablier)** : Marquez votre taille ! Privilégiez les robes portefeuilles, jupes crayons et ceintures larges en pagne.\n"
          "• **Silhouette A (Pyramide)** : Étoffez le haut du corps avec des manches bouffantes, encolures bateau et épaulettes légères.\n"
          "• **Silhouette V (Pyramide inversée)** : Donnez du volume en bas avec des jupes évasées, péplums et coupes trapèzes.\n"
          "• **Silhouette H (Rectangle)** : Créez l'illusion de courbes avec des coupes croisées, ceinturées ou drapées en wax.\n"
          "• **Silhouette O (Ronde)** : Préférez les coupes fluides, décolletés en V et lignes verticales allongeantes.";
    }

    // 4. Coiffure & Forme de Visage
    if (lower.contains("coiffure") || lower.contains("tresse") || lower.contains("cheveux") || lower.contains("hair") || lower.contains("locks") || lower.contains("nappy") || faceShape != null) {
      final shape = faceShape ?? "Ovale";
      return "💇 **Conseil Coiffure Personnalisé (Visage $shape)** :\n"
          "• **Visage Ovale** : Pratiquement tout vous va ! Tresses knotless mi-longues, chignons tressés, perruques courtes ou afro naturel.\n"
          "• **Visage Rond** : Privilégiez le volume sur le dessus de la tête (chignon haut, tresses longues plongeantes) pour allonger les traits.\n"
          "• **Visage Carré** : Adoucissez la mâchoire avec des ondulations douces, mèches sur le côté ou tresses bohèmes libres.\n"
          "• **Tendances Actuelles** : Knotless braids avec mèches bouclées (style Goddess), vanilles sénégalaises, locks twistées et dégradés waves pour hommes.";
    }

    // 5. Prix & Tarifs au Cameroun
    if (lower.contains("prix") || lower.contains("tarif") || lower.contains("combien") || lower.contains("coût") || lower.contains("price")) {
      return "💰 **Grille des Tarifs Moyens de la Mode au Cameroun (Douala / Yaoundé)** :\n"
          "• **Robe simple en pagne wax** : 10 000 - 20 000 FCFA\n"
          "• **Robe de soirée ou de cérémonie travaillée** : 25 000 - 65 000 FCFA\n"
          "• **Ensemble costume / veste africaine homme** : 30 000 - 75 000 FCFA\n"
          "• **Tresses africaines (Knotless / Braids)** : 5 000 - 25 000 FCFA selon la longueur\n"
          "• **Pose perruque lace frontal & coiffage** : 10 000 - 30 000 FCFA\n"
          "• *Tous nos prestataires sur CamerMode affichent leurs tarifs exacts sur chaque création.*";
    }

    // Réponse générale riche et personnalisée
    if (isCamfranglais) {
      return "🇨🇲 **Le way est simple ! CamerMode gère ton style de A à Z :**\n"
          "Dis-moi le style que tu cherches : une sape pour la dot, un modèle chic pour le bureau, ou une coupe de coiffure bien tracée ?\n"
          "Tu peux aussi scanner ta morphologie pour voir les robes qui collent pile à tes mesures !";
    }

    if (isEnglish) {
      return "✨ **Welcome to CamerMode AI Fashion & Beauty Stylist!**\n"
          "I can assist you with:\n"
          "• Tailored African outfits (Ndop, Toghu, Bazin, Wax prints)\n"
          "• Body silhouette matching (Sandglass, Triangle, Athletic, Plus size)\n"
          "• Hair styling and barber cuts matched to your face shape\n"
          "• Real-time tailoring estimates in FCFA\n"
          "How can I style you today?";
    }

    return "✨ **Bienvenue chez CamerMode Styliste IA !**\n"
        "Je suis votre conseiller expert en mode africaine et beauté sur-mesure au Cameroun.\n"
        "Je peux vous guider sur :\n"
        "• Le choix du tissu (Toghu, Ndop, Bazin riche, Pagne Wax Woodin)\n"
        "• Les modèles de tenues adaptés à votre morphologie (${morphology ?? 'Sablier, Pyramide, etc.'})\n"
        "• Les coiffures tendances adaptées à la forme de votre visage (${faceShape ?? 'Ovale, Rond, etc.'})\n"
        "• Les estimations de prix et délais de confection en FCFA.\n\n"
        "Quel événement ou style souhaitez-vous explorer ?";
  }
}
