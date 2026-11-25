import assert from 'node:assert/strict';
import { randomBytes } from 'node:crypto';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { createBank } from '../src/bank.js';

test('rotar la clave de sesión invalida el token anterior y conserva la cuenta', () => {
  const directory = mkdtempSync(join(tmpdir(), 'securebank-rotacion-'));
  const database = join(directory, 'laboratorio.sqlite');
  const credentials = { username: 'titular', password: randomBytes(24).toString('hex') };
  let bank;
  try {
    bank = createBank({ database, jwtSecret: randomBytes(32) });
    const { id, accountId } = bank.register(credentials);
    const originalToken = bank.login(credentials).token;
    assert.equal(bank.authenticate(originalToken).id, id);
    bank.close();
    bank = undefined;

    bank = createBank({ database, jwtSecret: randomBytes(32) });
    assert.throws(() => bank.authenticate(originalToken), { status: 401 });
    const user = bank.authenticate(bank.login(credentials).token);
    assert.equal(user.id, id);
    assert.equal(bank.account(user, accountId).owner, id);
  } finally {
    bank?.close();
    rmSync(directory, { recursive: true, force: true });
  }
});
