import { DatabaseSync } from 'node:sqlite';
import { randomBytes, randomUUID, scryptSync, timingSafeEqual, createHmac, createHash } from 'node:crypto';

export class BankError extends Error {
  constructor(status, message) { super(message); this.status = status; }
}
const fail = (status, message) => { throw new BankError(status, message); };
const encode = value => Buffer.from(JSON.stringify(value)).toString('base64url');
export function createBank({ database = ':memory:', jwtSecret = randomBytes(32), now = () => Date.now(), onAudit = () => {} } = {}) {
  const secret = Buffer.from(jwtSecret);
  if (secret.length < 32) throw new Error('JWT_SECRET debe contener al menos 32 bytes.');
  const db = new DatabaseSync(database);
  db.exec(`PRAGMA foreign_keys = ON;
    CREATE TABLE IF NOT EXISTS users (id TEXT PRIMARY KEY, username TEXT UNIQUE NOT NULL, salt TEXT NOT NULL, hash TEXT NOT NULL, role TEXT NOT NULL);
    CREATE TABLE IF NOT EXISTS accounts (id TEXT PRIMARY KEY, owner TEXT NOT NULL REFERENCES users(id), balance INTEGER NOT NULL CHECK(balance >= 0));
    CREATE TABLE IF NOT EXISTS movements (id TEXT PRIMARY KEY, origin TEXT NOT NULL, target TEXT NOT NULL, amount INTEGER NOT NULL, at TEXT NOT NULL);
  `);
  const audit = [];
  let previous = '0'.repeat(64);
  function record(event, userId, outcome) {
    const item = { at: new Date(now()).toISOString(), event, userId, outcome, previous };
    const hash = createHash('sha256').update(JSON.stringify(item)).digest('hex');
    previous = hash;
    audit.push({ ...item, hash });
    if (audit.length > 1000) audit.shift();
    onAudit({ ...item, hash });
  }
  function register({ username, password, role } = {}) {
    if (role !== undefined) fail(400, 'El rol no puede ser definido por el cliente.');
    if (typeof username !== 'string' || !/^[a-zA-Z0-9_.-]{3,50}$/.test(username)) fail(400, 'Usuario inválido.');
    if (typeof password !== 'string' || password.length < 12 || password.length > 128) fail(400, 'Contraseña: 12 a 128 caracteres.');
    if (db.prepare('SELECT id FROM users WHERE username = ?').get(username)) fail(409, 'Usuario ya registrado.');
    const id = randomUUID(), accountId = randomUUID(), salt = randomBytes(16).toString('hex');
    const hash = scryptSync(password, salt, 64).toString('hex');
    db.exec('BEGIN IMMEDIATE');
    try {
      db.prepare('INSERT INTO users VALUES (?, ?, ?, ?, ?)').run(id, username, salt, hash, 'client');
      db.prepare('INSERT INTO accounts VALUES (?, ?, ?)').run(accountId, id, 0);
      db.exec('COMMIT');
    } catch (error) { db.exec('ROLLBACK'); throw error; }
    record('register', id, 'allowed');
    return { id, username, accountId };
  }
  function login({ username, password } = {}) {
    if (typeof username !== 'string' || typeof password !== 'string' || password.length > 128) fail(401, 'Credenciales inválidas.');
    const user = db.prepare('SELECT * FROM users WHERE username = ?').get(username);
    const salt = user?.salt ?? 'invalid-user-salt';
    const actual = scryptSync(password, salt, 64);
    const expected = user ? Buffer.from(user.hash, 'hex') : Buffer.alloc(64);
    if (!timingSafeEqual(actual, expected) || !user) { record('login', null, 'denied'); fail(401, 'Credenciales inválidas.'); }
    const seconds = Math.floor(now() / 1000);
    const payload = { sub: user.id, role: user.role, iss: 'midama-securebank', aud: 'securebank-api', iat: seconds, exp: seconds + 900 };
    const data = `${encode({ alg: 'HS256', typ: 'JWT' })}.${encode(payload)}`;
    const signature = createHmac('sha256', secret).update(data).digest('base64url');
    record('login', user.id, 'allowed');
    return { token: `${data}.${signature}`, expiresIn: 900 };
  }
  function authenticate(token) {
    try {
      if (typeof token !== 'string' || token.length > 4096) throw new Error();
      const parts = token.split('.');
      if (parts.length !== 3) throw new Error();
      const [header, body, signature] = parts;
      const h = JSON.parse(Buffer.from(header, 'base64url').toString());
      if (h.alg !== 'HS256' || h.typ !== 'JWT') throw new Error();
      const expected = createHmac('sha256', secret).update(`${header}.${body}`).digest();
      const received = Buffer.from(signature, 'base64url');
      if (received.length !== expected.length || !timingSafeEqual(received, expected)) throw new Error();
      const p = JSON.parse(Buffer.from(body, 'base64url').toString());
      if (p.iss !== 'midama-securebank' || p.aud !== 'securebank-api' || !Number.isInteger(p.exp) || p.exp <= Math.floor(now() / 1000)) throw new Error();
      const user = db.prepare('SELECT id, role FROM users WHERE id = ?').get(p.sub);
      if (!user || user.role !== p.role) throw new Error();
      return user;
    } catch { fail(401, 'Token inválido o expirado.'); }
  }
  function account(user, accountId) {
    const row = db.prepare('SELECT id, owner, balance FROM accounts WHERE id = ?').get(accountId);
    if (!row || row.owner !== user.id) { record('account', user.id, 'denied'); fail(403, 'Acceso denegado.'); }
    return row;
  }
  function accounts(user) { return db.prepare('SELECT id, balance FROM accounts WHERE owner = ?').all(user.id); }
  function movements(user, accountId) {
    account(user, accountId);
    return db.prepare('SELECT * FROM movements WHERE origin = ? OR target = ? ORDER BY at DESC LIMIT 100').all(accountId, accountId);
  }
  function transfer(user, { originAccount, targetAccount, amount } = {}) {
    if (typeof originAccount !== 'string' || typeof targetAccount !== 'string' || originAccount === targetAccount || !Number.isSafeInteger(amount) || amount <= 0 || amount > 1000000) fail(400, 'Transferencia inválida: monto entero CLP entre 1 y 1000000.');
    db.exec('BEGIN IMMEDIATE');
    let result;
    try {
      const origin = account(user, originAccount);
      const target = db.prepare('SELECT * FROM accounts WHERE id = ?').get(targetAccount);
      if (!target) fail(400, 'Destino inválido.');
      if (origin.balance < amount) fail(409, 'Saldo insuficiente.');
      if (!Number.isSafeInteger(target.balance + amount)) fail(400, 'Saldo destino fuera de rango.');
      db.prepare('UPDATE accounts SET balance = balance - ? WHERE id = ?').run(amount, originAccount);
      db.prepare('UPDATE accounts SET balance = balance + ? WHERE id = ?').run(amount, targetAccount);
      result = { id: randomUUID(), origin: originAccount, target: targetAccount, amount, at: new Date(now()).toISOString() };
      db.prepare('INSERT INTO movements VALUES (?, ?, ?, ?, ?)').run(result.id, originAccount, targetAccount, amount, result.at);
      db.exec('COMMIT');
    } catch (error) { db.exec('ROLLBACK'); throw error; }
    record('transfer', user.id, 'allowed');
    return result;
  }
  return { register, login, authenticate, account, accounts, movements, transfer, audit,
    close: () => db.close(),
    // Solo fixture de pruebas/local: no existe endpoint HTTP de carga de saldo.
    fundForTest(accountId, amount) {
      if (!Number.isSafeInteger(amount) || amount < 0) throw new Error('Saldo inválido.');
      db.prepare('UPDATE accounts SET balance = ? WHERE id = ?').run(amount, accountId);
    }
  };
}
