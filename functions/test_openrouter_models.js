require('dotenv').config({ path: __dirname + '/.env' });
const axios = require('axios');

async function testModels() {
  const key = process.env.OPENROUTER_API_KEY;
  const userPhoto = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d';
  const articlePhoto = 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35';

  const testList = [
    'google/gemini-3.1-flash-image',
    'google/gemini-2.5-flash-image',
    'google/gemini-2.0-flash-exp:free',
    'meta-llama/llama-3.2-11b-vision-instruct:free'
  ];

  for (const model of testList) {
    console.log(`\n--- TESTING MODEL: ${model} ---`);
    try {
      const payload = {
        model: model,
        max_tokens: 500,
        messages: [
          {
            role: 'user',
            content: [
              { type: 'text', text: 'Combines the article in image 2 onto the person in image 1.' },
              { type: 'image_url', image_url: { url: userPhoto } },
              { type: 'image_url', image_url: { url: articlePhoto } }
            ]
          }
        ]
      };

      const res = await axios.post('https://openrouter.ai/api/v1/chat/completions', payload, {
        headers: {
          'Authorization': `Bearer ${key.trim()}`,
          'Content-Type': 'application/json'
        },
        timeout: 30000
      });

      console.log(`✅ [${model}] SUCCESS Status:`, res.status);
      console.log('Message response:', JSON.stringify(res.data.choices[0].message, null, 2));

    } catch (err) {
      console.error(`❌ [${model}] FAILED Status:`, err.response?.status, err.response?.data?.error?.message || err.message);
    }
  }
}

testModels();
