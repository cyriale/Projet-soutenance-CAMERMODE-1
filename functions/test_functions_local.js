require('dotenv').config({ path: __dirname + '/.env' });
const funcs = require('./index.js');

function createMockRes(onDone) {
  return {
    statusCode: 200,
    headers: {},
    listeners: {},
    setHeader: function(name, val) { this.headers[name] = val; },
    getHeader: function(name) { return this.headers[name]; },
    on: function(event, callback) {
      this.listeners[event] = callback;
      return this;
    },
    status: function(code) {
      this.statusCode = code;
      return this;
    },
    json: function(data) {
      console.log(`[HTTP ${this.statusCode}] Response:`, JSON.stringify(data, null, 2));
      if (this.listeners['finish']) this.listeners['finish']();
      if (onDone) onDone(data);
    }
  };
}

async function testLocalHandlers() {
  console.log('--- TEST 1 : testOpenRouter ---');
  const mockReq1 = {
    headers: { origin: 'http://localhost' }
  };
  const mockRes1 = createMockRes();
  await funcs.testOpenRouter(mockReq1, mockRes1);

  console.log('\n--- TEST 2 : virtualTryOn (Nano Banana 2 / OpenRouter) ---');
  const mockReq2 = {
    method: 'POST',
    headers: { origin: 'http://localhost' },
    body: {
      photoUtilisateur: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
      photoArticle: 'https://images.unsplash.com/photo-1590736969955-71cc94801759',
      category: 'couture'
    }
  };
  const mockRes2 = createMockRes();

  await funcs.virtualTryOn(mockReq2, mockRes2);
}

testLocalHandlers();
