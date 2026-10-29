#!/usr/bin/env bash
# Lab 1, varianta 1: rezultat vizibil pentru capturile de ecran.
set -uo pipefail
cd "$(dirname "$0")/.."
errors=0
check() { if "$@"; then echo "[OK] $*"; else echo "[EROARE] $*"; errors=$((errors+1)); fi; }

echo 'LABORATORUL 1 — VARIANTA 1 (SCOALA)'
echo '=================================='
echo '[1] Starea containerelor / porturile publicate:'
docker compose ps || errors=$((errors+1))
echo

echo '[2] Raspuns prin Nginx la http://localhost:8081/api/health:'
if curl --fail --silent --show-error --max-time 5 http://localhost:8081/api/health; then
  echo; echo '[OK] API-ul este accesibil prin portul web 8081.'
else
  echo '[EROARE] Accesul la API prin Nginx a esuat.'; errors=$((errors+1))
fi
echo

echo '[3] Acces direct la portul 3000 (trebuie sa esueze):'
if curl --fail --silent --max-time 3 http://localhost:3000/api/health >/dev/null 2>&1; then
  echo '[EROARE] Portul 3000 raspunde (verifica cine il foloseste).'; errors=$((errors+1))
else
  echo '[OK] Portul 3000 nu raspunde la cererea directa.'
fi
echo

echo '[4] Utilizatorul din containerul api (asteptat: node):'
api_user="$(docker compose exec -T api whoami 2>/dev/null)" || api_user=''
echo "${api_user:-<nu a putut fi determinat>}"
if [[ "$api_user" == 'node' ]]; then echo '[OK] API-ul ruleaza ca node.'; else echo '[EROARE] API-ul nu ruleaza ca node.'; errors=$((errors+1)); fi
echo

echo '[5] Verificarea fisierului .env in Git:'
if git check-ignore -q .env; then echo '[OK] .env este ignorat de Git.'; else echo '[EROARE] .env nu este ignorat de Git.'; errors=$((errors+1)); fi
git status --short || true
echo

echo 'ATENTIE: login-ul alice / alice123 si capturile de ecran se verifica manual in browser.'
if [[ $errors -eq 0 ]]; then echo 'Rezultat: controalele automate au trecut.'; else echo "Rezultat: $errors controale automate nu au trecut."; fi
exit "$( [[ $errors -eq 0 ]] && echo 0 || echo 1 )"
