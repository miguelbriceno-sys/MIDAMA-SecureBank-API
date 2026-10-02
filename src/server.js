import { createServer } from 'node:http';
import { pathToFileURL } from 'node:url';
import { createBank, BankError } from './bank.js';

export function createApp({ bank = createBank(), limit = 60, windowMs = 60000, now = () => Date.now() } = {}) {
  const buckets = new Map();
  const server = createServer(async (req, res) => {
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('Cache-Control', 'no-store');
    const send = (status, data) => { res.writeHead(status); res.end(JSON.stringify(data)); };
    try {
      const url = new URL(req.url, 'http://localhost');
      if (req.method === 'GET' && url.pathname === '/health') return send(200, { status: 'ok' });
      const time = now();
      for (const [key, value] of buckets) if (value.until <= time) buckets.delete(key);
      const ip = req.socket.remoteAddress;
      // No confiar en X-Forwarded-For enviado por el cliente.
      if (!buckets.has(ip) && buckets.size >= 10000) throw new BankError(429, 'Demasiadas solicitudes.');
      const bucket = buckets.get(ip) ?? { count: 0, until: time + windowMs };
      bucket.count++; buckets.set(ip, bucket);
      if (bucket.count > limit) { res.setHeader('Retry-After', Math.ceil((bucket.until - time) / 1000)); throw new BankError(429, 'Demasiadas solicitudes.'); }
      let body = {};
      if (req.method === 'POST') {
        if (!/^application\/json(?:;|$)/i.test(req.headers['content-type'] ?? '')) throw new BankError(415, 'Se requiere application/json.');
        let size = 0, chunks = [];
        for await (const chunk of req) {
          size += chunk.length;
          if (size > 16384) { send(413, { error: 'Payload demasiado grande.' }); req.resume(); return; }
          chunks.push(chunk);
        }
        try { body = JSON.parse(Buffer.concat(chunks).toString()); } catch { throw new BankError(400, 'JSON inválido.'); }
        if (!body || typeof body !== 'object' || Array.isArray(body)) throw new BankError(400, 'Objeto JSON requerido.');
      }
      if (req.method === 'POST' && url.pathname === '/users') return send(201, bank.register(body));
      if (req.method === 'POST' && url.pathname === '/login') return send(200, bank.login(body));
      const bearer = req.headers.authorization?.match(/^Bearer (\S+)$/)?.[1];
      const user = bank.authenticate(bearer);
      if (req.method === 'GET' && url.pathname === '/accounts') return send(200, bank.accounts(user));
      const match = url.pathname.match(/^\/accounts\/([^/]+)(\/movements)?$/);
      if (req.method === 'GET' && match) return send(200, match[2] ? bank.movements(user, match[1]) : bank.account(user, match[1]));
      if (req.method === 'POST' && url.pathname === '/transfer') return send(200, bank.transfer(user, body));
      send(404, { error: 'Ruta no encontrada.' });
    } catch (error) {
      send(error instanceof BankError ? error.status : 500, { error: error instanceof BankError ? error.message : 'Error interno.' });
    }
  });
  server.requestTimeout = 10000;
  server.headersTimeout = 5000;
  return server;
}
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  if (process.env.NODE_ENV === 'production' && !process.env.JWT_SECRET) throw new Error('JWT_SECRET es obligatorio en producción.');
  const bank = createBank({ database: process.env.DB_PATH ?? ':memory:', jwtSecret: process.env.JWT_SECRET, onAudit: entry => console.log(JSON.stringify(entry)) });
  const server = createApp({ bank });
  server.listen(Number(process.env.PORT ?? 3000), process.env.HOST ?? '127.0.0.1', () => console.log('SecureBank API iniciada.'));
  for (const signal of ['SIGINT', 'SIGTERM']) process.on(signal, () => server.close(() => { bank.close(); process.exit(0); }));
}
