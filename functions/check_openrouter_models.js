require('dotenv').config({ path: __dirname + '/.env' });
const axios = require('axios');

async function getModels() {
  try {
    const res = await axios.get('https://openrouter.ai/api/v1/models');
    const models = res.data?.data || [];

    // Filtre les modèles d'images / vision / gemini
    const imageModels = models.filter(m =>
      m.id.includes('image') ||
      m.id.includes('gemini') ||
      m.id.includes('flux') ||
      m.id.includes('sdxl') ||
      m.id.includes('dall-e') ||
      m.id.includes('banana')
    ).map(m => ({ id: m.id, name: m.name, pricing: m.pricing }));

    console.log('--- MODÈLES IMAGES DISPONIBLES SUR OPENROUTER ---');
    console.log(JSON.stringify(imageModels, null, 2));
  } catch (e) {
    console.error('Error fetching models:', e.message);
  }
}

getModels();
