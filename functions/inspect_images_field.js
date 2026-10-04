require('dotenv').config({ path: __dirname + '/.env' });
const axios = require('axios');

async function checkImagesField() {
  const key = process.env.OPENROUTER_API_KEY;
  const userPhoto = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d';
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
            text: 'Generate an edited image showing the person in image 1 wearing the suit in image 2.'
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
    modalities: ['image']
  };

  try {
    const res = await axios.post('https://openrouter.ai/api/v1/chat/completions', payload, {
      headers: {
        'Authorization': `Bearer ${key.trim()}`,
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://camermode.app',
        'X-Title': 'CamerMode Virtual TryOn'
      },
      timeout: 90000
    });

    const msg = res.data.choices[0].message;
    console.log('--- IMAGES FIELD TYPE ---:', typeof msg.images);
    console.log('--- IS ARRAY? ---:', Array.isArray(msg.images));
    console.log('--- IMAGES LENGTH ---:', msg.images ? msg.images.length : 0);
    console.log('--- IMAGES DATA ---:', JSON.stringify(msg.images, null, 2));

  } catch (err) {
    console.error('ERROR:', err.response?.data || err.message);
  }
}

checkImagesField();
