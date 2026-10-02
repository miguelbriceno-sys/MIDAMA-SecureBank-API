import test from 'node:test';
import assert from 'node:assert/strict';
import { randomBytes } from 'node:crypto';
import { createBank } from '../src/bank.js';
const password = () => randomBytes(24).toString('hex');
function fixture(t, options = {}) {
  const bank = createBank(options); t.after(() => bank.close());
  const pa = password(), pb = password();
  const a = bank.register({ username: 'alice', password: pa });
  const b = bank.register({ username: 'bob', password: pb });
  const token = bank.login({ username: 'alice', password: pa }).token;
  const ua = bank.authenticate(token), ub = bank.authenticate(bank.login({ username: 'bob', password: pb }).token);
  bank.fundForTest(a.accountId, 1000);
  return { bank, a, b, ua, ub, token, pa };
}
const denied = (fn, status) => assert.throws(fn, e => e.status === status);
test('registro y login; credenciales erróneas no autentican', t => {
  const { bank, a, ua } = fixture(t); assert.equal(ua.id, a.id);
  denied(() => bank.login({ username: 'alice', password: password() }), 401);
  denied(() => bank.login({ username: 'missing', password: password() }), 401);
  denied(() => bank.register({ username: 'bad', password: 'short' }), 400);
  denied(() => bank.register({ username: 'alice', password: password() }), 409);
});
test('BOLA: cuenta ajena devuelve 403 sin revelar saldo', t => {
  const { bank, a, ub, b } = fixture(t);
  denied(() => bank.account(ub, a.accountId), 403);
  denied(() => bank.movements(ub, a.accountId), 403);
  assert.deepEqual(bank.accounts(ub).map(a => a.id), [b.accountId]);
});
test('BOLA: transferencia ajena devuelve 403 y conserva ambos saldos', t => {
  const { bank, a, b, ua, ub } = fixture(t);
  denied(() => bank.transfer(ub, { originAccount: a.accountId, targetAccount: b.accountId, amount: 500 }), 403);
  assert.equal(bank.account(ua, a.accountId).balance, 1000);
  assert.equal(bank.account(ub, b.accountId).balance, 0);
  assert.ok(bank.audit.some(x => x.outcome === 'denied'));
});
test('transferencia válida conserva fondos y crea movimiento', t => {
  const { bank, a, b, ua, ub } = fixture(t);
  bank.transfer(ua, { originAccount: a.accountId, targetAccount: b.accountId, amount: 250 });
  assert.equal(bank.account(ua, a.accountId).balance, 750);
  assert.equal(bank.account(ub, b.accountId).balance, 250);
  assert.equal(bank.movements(ua, a.accountId).length, 1);
});
test('montos inválidos, saldo insuficiente y destino inválido revierten', t => {
  const { bank, a, b, ua } = fixture(t);
  for (const amount of [-1, 0, 1.5, '10', 1000001]) denied(() => bank.transfer(ua, { originAccount: a.accountId, targetAccount: b.accountId, amount }), 400);
  denied(() => bank.transfer(ua, { originAccount: a.accountId, targetAccount: b.accountId, amount: 1001 }), 409);
  denied(() => bank.transfer(ua, { originAccount: a.accountId, targetAccount: 'missing', amount: 10 }), 400);
  denied(() => bank.transfer(ua, { originAccount: a.accountId, targetAccount: a.accountId, amount: 10 }), 400);
  assert.equal(bank.account(ua, a.accountId).balance, 1000);
  assert.equal(bank.movements(ua, a.accountId).length, 0);
});
test('SQLi en login y cuenta se trata como dato', t => {
  const { bank, ua } = fixture(t);
  denied(() => bank.login({ username: "' OR 1=1 --", password: password() }), 401);
  denied(() => bank.account(ua, "' OR 1=1 --"), 403);
  assert.equal(bank.accounts(ua).length, 1);
});
test('JWT falsificado, alg none y role admin son rechazados', t => {
  const { bank, token } = fixture(t);
  const parts = token.split('.');
  const role = JSON.parse(Buffer.from(parts[1], 'base64url')); role.role = 'admin';
  denied(() => bank.authenticate(`${parts[0]}.${Buffer.from(JSON.stringify(role)).toString('base64url')}.${parts[2]}`), 401);
  denied(() => bank.authenticate(`${Buffer.from(JSON.stringify({ alg: 'none', typ: 'JWT' })).toString('base64url')}.${parts[1]}.`), 401);
  denied(() => bank.authenticate('bad'), 401);
  denied(() => bank.register({ username: 'mallory', password: password(), role: 'admin' }), 400);
});
test('JWT expira después de 15 minutos y clave débil bloquea inicio', t => {
  let clock = Date.now(); const { bank, token } = fixture(t, { now: () => clock });
  clock += 901000; denied(() => bank.authenticate(token), 401);
  assert.throws(() => createBank({ jwtSecret: 'short' }));
});
test('auditoría encadenada excluye contraseñas y tokens', t => {
  const { bank, token, pa } = fixture(t);
  for (let i = 1; i < bank.audit.length; i++) assert.equal(bank.audit[i].previous, bank.audit[i - 1].hash);
  assert.equal(JSON.stringify(bank.audit).includes(token), false);
  assert.equal(JSON.stringify(bank.audit).includes(pa), false);
});
