const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Lazy-loading de la clé API
function getEnvKey() {
  try {
    require('dotenv').config({ path: __dirname + '/.env' });
  } catch (_) {}
  return process.env.OPENROUTER_API_KEY;
}

/**
 * 1. FONCTION DE TEST : testOpenRouter
 */
exports.testOpenRouter = onRequest({ cors: true }, async (req, res) => {
  try {
    const apiKey = getEnvKey();

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
 * Effectue l'essayage virtuel IA (Vêtements & Coiffures) via OpenRouter avec Nano Banana 2.
 */
exports.virtualTryOn = onRequest({ cors: true, timeoutSeconds: 120, memory: "1GiB" }, async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ success: false, message: "Méthode non autorisée. Utilisez POST." });
  }

  try {
    const axios = require("axios");
    const apiKey = getEnvKey();

    const { photoUtilisateur, photoArticle, category } = req.body || {};

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

    if (!apiKey || apiKey.trim() === '') {
      logger.error("❌ [virtualTryOn] Clé OPENROUTER_API_KEY non disponible sur le serveur.");
      return res.status(500).json({
        success: false,
        message: "Service d'essayage virtuel temporairement indisponible (Configuration serveur)."
      });
    }

    const catClean = (category || "").toString().toLowerCase().trim();
    const isCoiffure = catClean === "coiffure" || catClean === "hair" || catClean === "cheveux" || catClean === "perruque" || catClean === "tresses";

    logger.info(`🚀 [virtualTryOn] Traitement (${isCoiffure ? 'COIFFURE' : 'COUTURE'}) via Nano Banana 2...`);

    const promptText = isCoiffure
      ? "High-quality photo editing: Take image 1 showing a person. Apply the hairstyle, haircut, braids, wig, or hair texture shown in image 2 directly onto the head of the person in image 1. Seamlessly integrate the hair onto their scalp, preserving their face, facial expression, skin color, ethnicity, identity, shoulders, and background from image 1. Output ONLY the final edited photo."
      : "High-quality virtual try-on: Take image 1 showing a person. Fit and drape the clothing garment or outfit shown in image 2 onto the person's body in image 1. Preserve the person's pose, face, skin tone, identity, head, hair, and background from image 1. Output ONLY the final edited photo.";

    const openRouterPayload = {
      model: "google/gemini-3.1-flash-image",
      max_tokens: 1500,
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
      modalities: ["image"]
    };

    const response = await axios.post("https://openrouter.ai/api/v1/chat/completions", openRouterPayload, {
      headers: {
        "Authorization": `Bearer ${apiKey.trim()}`,
        "Content-Type": "application/json",
        "HTTP-Referer": "https://camermode.app",
        "X-Title": "CamerMode Virtual TryOn"
      },
      timeout: 90000
    });

    const choices = response.data?.choices;
    if (!choices || choices.length === 0) {
      logger.warn("⚠️ [virtualTryOn] Aucune réponse générée par OpenRouter.");
      return res.status(502).json({
        success: false,
        message: "L'IA n'a pas pu générer l'image. Veuillez réessayer votre tentative."
      });
    }

    const messageObj = choices[0].message || {};
    const messageContent = messageObj.content || "";
    const messageImages = messageObj.images || messageObj.content_images || [];

    let resultImageUrl = null;

    if (Array.isArray(messageImages) && messageImages.length > 0) {
      const imgItem = messageImages[0];
      if (typeof imgItem === 'string') {
        resultImageUrl = imgItem;
      } else if (imgItem?.image_url?.url) {
        resultImageUrl = imgItem.image_url.url;
      } else if (imgItem?.url) {
        resultImageUrl = imgItem.url;
      }
    }

    if (!resultImageUrl && typeof messageContent === 'string') {
      const markdownMatch = messageContent.match(/!\[.*?\]\((data:image\/[^\s\)]+|https?:\/\/[^\s\)]+)\)/);
      const directMatch = messageContent.match(/(data:image\/[a-zA-Z]+;base64,[a-zA-Z0-9+/=]+|https?:\/\/[^\s]+\.(png|jpg|jpeg|webp))/i);

      if (markdownMatch) {
        resultImageUrl = markdownMatch[1];
      } else if (directMatch) {
        resultImageUrl = directMatch[0];
      } else if (messageContent.startsWith('http') || messageContent.startsWith('data:image')) {
        resultImageUrl = messageContent.trim();
      }
    }

    if (!resultImageUrl) {
      logger.warn("⚠️ [virtualTryOn] Aucune URL ou donnée d'image générée dans la réponse OpenRouter.");
      return res.status(500).json({
        success: false,
        message: "L'IA Nano Banana 2 n'a pas renvoyé d'image générée."
      });
    }

    logger.info("✅ [virtualTryOn] Image réelle générée par Nano Banana 2 récupérée avec succès !");

    return res.status(200).json({
      success: true,
      resultImageUrl: resultImageUrl,
      message: `Jumelage IA (${isCoiffure ? 'Coiffure' : 'Vêtement'}) généré avec succès par Nano Banana 2.`
    });

  } catch (error) {
    const errorMessage = error.response?.data?.error?.message || error.message || "Erreur serveur";
    logger.error("❌ [virtualTryOn] Erreur traitement OpenRouter :", errorMessage);

    return res.status(500).json({
      success: false,
      message: "Erreur lors de la génération de l'essayage virtuel."
    });
  }
});
