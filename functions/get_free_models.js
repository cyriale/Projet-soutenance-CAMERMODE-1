require('dotenv').config({ path: __dirname + '/.env' });
const axios = require('axios');

async function getFreeModels() {
  try {
    const res = await axios.get('https://openrouter.ai/api/v1/models');
    const models = res.data?.data || [];
    const freeModels = models.filter(m => m.id.endsWith(':free')).map(m => m.id);
    console.log('--- FREE MODELS ON OPENROUTER ---');
    console.log(JSON.stringify(freeModels, null, 2));
  } catch (e) {
    console.error('Error:', e.message);
  }
}

getFreeModels();
