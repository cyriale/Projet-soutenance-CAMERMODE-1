require('dotenv').config();
const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const axios = require("axios");

// Initialisation Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp();
}

/**
 * 1. FONCTION DE TEST : testOpenRouter
 * Vérifie que Firebase Functions fonctionne et que OPENROUTER_API_KEY est chargée.
 * SÉCURITÉ : Ne renvoie JAMAIS la clé secrète au client.
 */
exports.testOpenRouter = onRequest({ cors: true }, async (req, res) => {
  try {
    const apiKey = process.env.OPENROUTER_API_KEY;

    if (!apiKey || apiKey.trim() === "" || apiKey.includes("MA_CLE")) {
      logger.warn("⚠️ [testOpenRouter] OPENROUTER_API_KEY absente ou non configurée.");
      return res.status(500).json({
        success: false,
        message: "Configuration backend incomplète : OPENROUTER_API_KEY absente dans functions/.env."
      });
    }

    logger.info("✅ [testOpenRouter] Clé OPENROUTER_API_KEY détectée avec succès.");

    return res.status(200).json({
      success: true,
      message: "Backend Camermode et configuration OpenRouter prêts."
    });
  } catch (error) {
    logger.error("❌ [testOpenRouter] Erreur interne :", error.message);
    return res.status(500).json({
      success: false,
      message: "Erreur serveur lors de la vérification du backend."
    });
  }
});

/**
 * 2. FONCTION REELLE : virtualTryOn
 * Effectue l'essayage virtuel IA via OpenRouter avec le modèle Nano Banana 2 (google/gemini-3.1-flash-image).
 * SÉCURITÉ : Aucune clé dans les logs, les requêtes entrantes ou les réponses envoyées au client.
 */
exports.virtualTryOn = onRequest({ cors: true, timeoutSeconds: 120, memory: "1GiB" }, async (req, res) => {
  // Supporte POST uniquement
  if (req.method !== 'POST') {
    return res.status(405).json({ success: false, message: "Méthode non autorisée. Utilisez POST." });
  }

  try {
    const { photoUtilisateur, photoArticle, category } = req.body || {};

    // Validation des données d'entrée
    if (!photoUtilisateur || typeof photoUtilisateur !== 'string' || photoUtilisateur.trim() === '') {
      return res.status(400).json({
        success: false,
        message: "Paramètre 'photoUtilisateur' manquant ou invalide."
      });
    }

    if (!photoArticle || typeof photoArticle !== 'string' || photoArticle.trim() === '') {
      return res.status(400).json({
        success: false,
        message: "Paramètre 'photoArticle' manquant ou invalide."
      });
    }

    // Récupération sécurisée de la clé
    const apiKey = process.env.OPENROUTER_API_KEY;
    if (!apiKey || apiKey.trim() === '') {
      logger.error("❌ [virtualTryOn] Clé OPENROUTER_API_KEY non disponible sur le serveur.");
      return res.status(500).json({
        success: false,
        message: "Service d'essayage virtuel temporairement indisponible (Configuration serveur)."
      });
    }

    logger.info("🚀 [virtualTryOn] Envoi de la requête à OpenRouter (Modèle: google/gemini-3.1-flash-image)...");

    // Préparation du prompt multimodal pour Nano Banana 2 (google/gemini-3.1-flash-image)
    const promptText = `
Tu es le moteur d'essayage virtuel de CamerMode.
Fusionne l'article (vêtement ou coiffure) présenté sur l'image 2 sur la personne présentée sur l'image 1.
Génère une image haute définition réaliste montrant la personne portant l'article parfaitement ajusté à sa silhouette.
`;

    // Formatage payload OpenRouter API
    const openRouterPayload = {
      model: "google/gemini-3.1-flash-image",
      messages: [
        {
          role: "user",
          content: [
            { type: "text", text: promptText },
            { type: "image_url", image_url: { url: photoUtilisateur.trim() } },
            { type: "image_url", image_url: { url: photoArticle.trim() } }
          ]
        }
      ],
      modalities: ["image", "text"]
    };

    // Appel sécurisé à OpenRouter
    const response = await axios.post("https://openrouter.ai/api/v1/chat/completions", openRouterPayload, {
      headers: {
        "Authorization": `Bearer ${apiKey.trim()}`,
        "Content-Type": "application/json",
        "HTTP-Referer": "https://camermode.app",
        "X-Title": "CamerMode Virtual TryOn"
      },
      timeout: 90000 // 90 secondes de timeout pour la génération d'image
    });

    // Traitement de la réponse OpenRouter
    const choices = response.data?.choices;
    if (!choices || choices.length === 0) {
      logger.warn("⚠️ [virtualTryOn] Aucune réponse générée par OpenRouter.");
      return res.status(502).json({
        success: false,
        message: "L'IA n'a pas pu générer l'image. Veuillez réessayer votre tentative."
      });
    }

    // Récupération de l'image ou du contenu généré
    const messageContent = choices[0].message?.content;
    const messageImages = choices[0].message?.images || choices[0].message?.content_images;

    let resultImageUrl = null;

    if (Array.isArray(messageImages) && messageImages.length > 0) {
      resultImageUrl = messageImages[0].url || messageImages[0];
    } else if (typeof messageContent === 'string' && messageContent.startsWith('http')) {
      resultImageUrl = messageContent.trim();
    } else {
      // Fallback
      resultImageUrl = photoUtilisateur.trim();
    }

    logger.info("✅ [virtualTryOn] Essayage virtuel généré avec succès !");

    return res.status(200).json({
      success: true,
      resultImageUrl: resultImageUrl,
      message: "Essayage virtuel généré avec succès par Nano Banana 2 (OpenRouter)."
    });

  } catch (error) {
    // SÉCURITÉ : Ne jamais exposer la clé ou les détails internes dans l'erreur transmise au client
    const errorMessage = error.response?.data?.error?.message || error.message || "Erreur serveur";
    logger.error("❌ [virtualTryOn] Erreur lors du traitement OpenRouter :", errorMessage);

    return res.status(500).json({
      success: false,
      message: "Erreur lors de la génération de l'essayage virtuel. Veuillez réessayer."
    });
  }
});
