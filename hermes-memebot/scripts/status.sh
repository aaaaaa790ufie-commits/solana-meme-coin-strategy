#!/usr/bin/env bash
# status.sh — баланс, открытые позиции, PnL, активные ордера.
# Использование: ./status.sh
set -euo pipefail

echo "=== holdings / positions ==="
gmgn-cli portfolio holdings --chain sol --raw

echo "=== stats / PnL ==="
gmgn-cli portfolio stats --chain sol --raw || true

echo "=== recent activity ==="
gmgn-cli portfolio activity --chain sol --limit 20 --raw || true

echo "" >&2
echo "AGENT checklist: (1) balance >= 0.07 SOL? (2) every position has" >&2
echo "live TP + trailing SL? (3) any position flat >12h -> time stop." >&2
