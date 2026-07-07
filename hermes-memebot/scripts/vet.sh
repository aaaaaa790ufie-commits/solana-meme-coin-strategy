#!/usr/bin/env bash
# vet.sh — собирает все данные для проверки кандидата перед входом.
# Агент анализирует вывод по фильтрам из config/strategy.json (SKILL.md Step 2).
# Использование: ./vet.sh <token_address>
set -euo pipefail

ADDR="${1:?usage: vet.sh <token_address>}"

echo "=== token info ==="
gmgn-cli token info --chain sol --address "$ADDR" --raw

echo "=== token security ==="
gmgn-cli token security --chain sol --address "$ADDR" --raw

echo "=== token holders ==="
gmgn-cli token holders --chain sol --address "$ADDR" --raw

echo "=== smart money trades (recent, for direction check) ==="
gmgn-cli track smart-money --chain sol --limit 20 --raw

echo ""
echo "REMINDER (agent): reject if honeypot, rug_ratio>0.30, on curve," >&2
echo "liq<\$30k, rat>15%, bundler>20%, insider>20%, top10>30%, dev>5%," >&2
echo "smart_degen_count<3, age>72h, 1h pump>400%, or smart money net selling." >&2
