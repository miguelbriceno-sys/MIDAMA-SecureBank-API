#!/usr/bin/env bash
set -euo pipefail
dest=${1:-evidence/images}
mkdir -p "$dest"
cmp Dockerfile docker/Dockerfile.v2
trivy --version > "$dest/trivy-version.txt"
for version in v1 v2; do
  tag="securebank:$version"
  docker build --platform linux/amd64 -f "docker/Dockerfile.$version" -t "$tag" .
  docker image inspect "$tag" --format '{{json .}}' > "$dest/$version-inspect.json"
  docker run --rm --entrypoint node "$tag" -p 'process.getuid()' > "$dest/$version-uid.txt" || {
    docker run --rm --entrypoint /nodejs/bin/node "$tag" -p 'process.getuid()' > "$dest/$version-uid.txt"
  }
  trivy image --scanners vuln --pkg-types os,library --list-all-pkgs --format json \
    --output "$dest/$version.json" "$tag"
done
python3 docker/compare.py "$dest"
