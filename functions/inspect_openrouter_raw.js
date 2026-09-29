require('dotenv').config({ path: __dirname + '/.env' });
const axios = require('axios');

async function inspectRawResponse() {
  const key = process.env.OPENROUTER_API_KEY;
  if (!key) {
    console.error('❌ KEY IS MISSING!');
    return;
  }

  // Photo 1 : Modèle Homme
  const userPhoto = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d';
  // Photo 2 : Vêtement / Costume
  const articlePhoto = 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35';

  const payload = {
    model: 'google/gemini-3.1-flash-image',
    max_tokens: 1500,
    messages: [
      {
        role: 'user',
        content: [
          {
            type: 'text',
            text: 'Génère une image modifiée montrant la personne de la première photo portant le costume de la seconde photo.'
          },
          {
            type: 'image_url',
            image_url: { url: userPhoto }
          },
          {
            type: 'image_url',
            image_url: { url: articlePhoto }
          }
        ]
      }
    ],
    modalities: ['image', 'text']
  };

  try {
    console.log('📡 Sending request to OpenRouter with userPhoto:', userPhoto, 'and articlePhoto:', articlePhoto);
    const res = await axios.post('https://openrouter.ai/api/v1/chat/completions', payload, {
      headers: {
        'Authorization': `Bearer ${key.trim()}`,
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://camermode.app',
        'X-Title': 'CamerMode Virtual TryOn'
      },
      timeout: 90000
    });

    console.log('\n--- 1. HTTP RESPONSE STATUS ---:', res.status);
    console.log('\n--- 2. RAW OPENROUTER RESPONSE BODY ---:');
    console.log(JSON.stringify(res.data, null, 2));

    const messageObj = res.data?.choices?.[0]?.message || {};
    console.log('\n--- 3. MESSAGE OBJECT KEYS ---:', Object.keys(messageObj));
    console.log('\n--- 4. MESSAGE CONTENT ---:', messageObj.content);
    console.log('\n--- 5. MESSAGE IMAGES ---:', messageObj.images || messageObj.content_images || 'None');

  } catch (err) {
    console.error('❌ ERROR STATUS:', err.response?.status);
    console.error('❌ ERROR DATA:', JSON.stringify(err.response?.data || err.message, null, 2));
  }
}

inspectRawResponse();
