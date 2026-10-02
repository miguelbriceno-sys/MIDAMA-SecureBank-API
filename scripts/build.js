import { cpSync, mkdirSync, rmSync, readdirSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
for (const file of readdirSync('src').filter(f => f.endsWith('.js'))) {
  execFileSync(process.execPath, ['--check', `src/${file}`], { stdio: 'inherit' });
}
rmSync('dist', { recursive: true, force: true });
mkdirSync('dist');
cpSync('src', 'dist/src', { recursive: true });
for (const file of ['package.json', 'package-lock.json', 'Dockerfile', 'README.md']) cpSync(file, `dist/${file}`);
console.log('Build validado: dist/ contiene un paquete ejecutable.');
