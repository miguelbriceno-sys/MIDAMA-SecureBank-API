import test from 'node:test';
import assert from 'node:assert/strict';
import { randomBytes } from 'node:crypto';
import { createBank } from '../src/bank.js';
import { createApp } from '../src/server.js';
async function app(t, options = {}) {
  const bank = createBank(), server = createApp({ bank, ...options });
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  t.after(async () => { await new Promise(resolve => server.close(resolve)); bank.close(); });
  const base = `http://127.0.0.1:${server.address().port}`;
  const post = (path, body, token) => fetch(base + path, { method: 'POST', headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) }, body: JSON.stringify(body) });
  return { bank, base, post };
}
test('HTTP registro/login/cuentas/transferencia y 403 BOLA', async t => {
  const { bank, base, post } = await app(t);
  const pa = randomBytes(24).toString('hex'), pb = randomBytes(24).toString('hex');
  const a = await (await post('/users', { username: 'alice', password: pa })).json();
  const b = await (await post('/users', { username: 'bob', password: pb })).json();
  bank.fundForTest(a.accountId, 1000);
  const ta = (await (await post('/login', { username: 'alice', password: pa })).json()).token;
  const tb = (await (await post('/login', { username: 'bob', password: pb })).json()).token;
  assert.equal((await fetch(base + '/accounts')).status, 401);
  assert.equal((await fetch(base + '/accounts', { headers: { Authorization: `Bearer ${ta}` } })).status, 200);
  assert.equal((await post('/transfer', { originAccount: a.accountId, targetAccount: b.accountId, amount: 100 }, tb)).status, 403);
  assert.equal((await post('/transfer', { originAccount: a.accountId, targetAccount: b.accountId, amount: 100 }, ta)).status, 200);
  assert.equal((await fetch(`${base}/accounts/${a.accountId}/movements`, { headers: { Authorization: `Bearer ${ta}` } })).status, 200);
});
test('HTTP limita payload, tipo de contenido y JSON', async t => {
  const { base, post } = await app(t);
  assert.equal((await post('/users', { padding: 'x'.repeat(17000) })).status, 413);
  assert.equal((await fetch(base + '/users', { method: 'POST', body: '{}' })).status, 415);
  assert.equal((await fetch(base + '/users', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{' })).status, 400);
  assert.equal((await post('/users', null)).status, 400);
  const health = await fetch(base + '/health'); assert.equal(health.status, 200); assert.equal(health.headers.get('cache-control'), 'no-store');
});
test('HTTP rate limit bloquea abuso y expira', async t => {
  let clock = Date.now(); const { post } = await app(t, { limit: 2, windowMs: 1000, now: () => clock });
  for (let i = 0; i < 2; i++) assert.equal((await post('/login', {})).status, 401);
  assert.equal((await post('/login', {})).status, 429);
  clock += 1001; assert.equal((await post('/login', {})).status, 401);
});
