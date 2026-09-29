require('dotenv').config({ path: __dirname + '/.env' });
const funcs = require('./index.js');

async function testLocalHandlers() {
  console.log('--- TEST 1 : testOpenRouter ---');
  let testResData = null;
  const mockReq1 = {};
  const mockRes1 = {
    status: function(code) {
      this.statusCode = code;
      return this;
    },
    json: function(data) {
      testResData = data;
      console.log(`HTTP Status: ${this.statusCode}`);
      console.log('Response:', JSON.stringify(data, null, 2));
    }
  };

  await funcs.testOpenRouter(mockReq1, mockRes1);

  console.log('\n--- TEST 2 : virtualTryOn (Nano Banana 2 / OpenRouter) ---');
  let tryOnResData = null;
  const mockReq2 = {
    method: 'POST',
    body: {
      photoUtilisateur: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
      photoArticle: 'https://images.unsplash.com/photo-1590736969955-71cc94801759',
      category: 'couture'
    }
  };
  const mockRes2 = {
    status: function(code) {
      this.statusCode = code;
      return this;
    },
    json: function(data) {
      tryOnResData = data;
      console.log(`HTTP Status: ${this.statusCode}`);
      console.log('Response Flutter JSON:', JSON.stringify(data, null, 2));
    }
  };

  await funcs.virtualTryOn(mockReq2, mockRes2);
}

testLocalHandlers();
