import { cpSync, mkdirSync, rmSync, readdirSync, writeFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';

for (const file of readdirSync('src').filter(file => file.endsWith('.js'))) {
  execFileSync(process.execPath, ['--check', `src/${file}`], { stdio: 'inherit' });
}
rmSync('dist', { recursive: true, force: true });
mkdirSync('dist');
cpSync('src', 'dist/src', { recursive: true });
for (const file of ['package.json', 'package-lock.json', 'Dockerfile', '.dockerignore']) {
  cpSync(file, `dist/${file}`);
}

const artifactReadme = `# SecureBank API · Distribución de laboratorio

Este paquete contiene la API en Node.js 24 y el Dockerfile de la entrega.
Desde el directorio descomprimido, usar las siguientes órdenes.

\`\`\`sh
npm ci --omit=dev --ignore-scripts
npm start
\`\`\`

La ruta GET /health comprueba la disponibilidad en el puerto 3000.
Para usar SQLite persistente, definir DB_PATH en un directorio con escritura.
En producción, el entorno debe proporcionar JWT_SECRET de al menos 32 bytes.

[Bitácora y pruebas del proyecto](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API)
`;
writeFileSync('dist/README.md', artifactReadme);
console.log('Build validado: dist/ contiene un paquete ejecutable.');
