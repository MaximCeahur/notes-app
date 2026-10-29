#!/usr/bin/env bash
# Lab 1, varianta 1: creeaza .env local, fara a afisa secretele.
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ ! -f docker-compose.yml || ! -d backend || ! -d frontend || ! -d db ]]; then
  echo 'Eroare: ruleaza acest script in copia completa a repository-ului notes-app.' >&2
  exit 1
fi
if [[ -e .env ]]; then
  echo '.env exista deja; nu a fost suprascris.'
else
  command -v openssl >/dev/null || { echo 'Instaleaza openssl.' >&2; exit 1; }
  umask 077
  {
    printf 'DB_NAME=notes\n'
    printf 'DB_USER=notes\n'
    printf 'DB_PASSWORD=%s\n' "$(openssl rand -hex 16)"
    printf 'JWT_SECRET=%s\n' "$(openssl rand -hex 32)"
  } > .env
  echo 'Fisierul .env a fost creat cu valori aleatorii; nu-l publica pe GitHub.'
fi
if command -v git >/dev/null && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if git check-ignore -q .env; then
    echo 'OK: .env este ignorat de Git.'
  else
    echo 'ATENTIE: .env nu este ignorat de Git; verifica .gitignore!' >&2
    exit 1
  fi
fi
printf '\nPasul urmator (ATENTIE: -v sterge baza de date locala a acestui proiect):\n'
printf '  docker compose down -v\n  docker compose up -d --build\n'
printf '  bash lab1-tools/02-verificare.sh\n'
