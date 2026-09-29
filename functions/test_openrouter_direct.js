require('dotenv').config({ path: __dirname + '/.env' });
const axios = require('axios');

async function runDirectTest() {
  console.log('1. Checking Key presence...');
  const key = process.env.OPENROUTER_API_KEY;
  if (!key) {
    console.error('❌ KEY IS MISSING!');
    return;
  }
  console.log('✅ KEY DETECTED! Prefix:', key.substring(0, 12) + '...');

  // Test OpenRouter models list or Chat Completions with google/gemini-3.1-flash-image
  const payload = {
    model: 'google/gemini-3.1-flash-image',
    messages: [
      {
        role: 'user',
        content: [
          {
            type: 'text',
            text: 'Analyse ces deux images pour un essayage virtuel : Image 1 (Personne) et Image 2 (Vêtement). Décris brièvement le rendu combiné de l\'article sur la personne.'
          },
          {
            type: 'image_url',
            image_url: {
              url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb'
            }
          },
          {
            type: 'image_url',
            image_url: {
              url: 'https://images.unsplash.com/photo-1590736969955-71cc94801759'
            }
          }
        ]
      }
    ],
    modalities: ['image', 'text']
  };

  try {
    console.log('2. Sending POST request to OpenRouter (model: google/gemini-3.1-flash-image)...');
    const res = await axios.post('https://openrouter.ai/api/v1/chat/completions', payload, {
      headers: {
        'Authorization': `Bearer ${key.trim()}`,
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://camermode.app',
        'X-Title': 'CamerMode Virtual TryOn'
      },
      timeout: 60000
    });

    console.log('3. ✅ RESPONSE STATUS:', res.status);
    console.log('4. ✅ RESPONSE DATA:', JSON.stringify(res.data, null, 2));
  } catch (err) {
    console.error('❌ RESPONSE ERROR STATUS:', err.response?.status);
    console.error('❌ RESPONSE ERROR DATA:', JSON.stringify(err.response?.data || err.message, null, 2));
  }
}

runDirectTest();
