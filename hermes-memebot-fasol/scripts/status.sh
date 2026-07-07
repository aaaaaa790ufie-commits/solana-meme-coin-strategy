#!/usr/bin/env bash
# status.sh — scope, баланс, позиции, ордера, трейды, rate limit.
# Использование: ./status.sh
set -euo pipefail

ENV_FILE="${FASOL_ENV_FILE:-$HOME/.config/fasol/.env}"
[ -f "$ENV_FILE" ] && { set -a; source "$ENV_FILE"; set +a; }
: "${FASOL_API_KEY:?FASOL_API_KEY is not set (see SETUP.md)}"
BASE="${FASOL_API_BASE_URL:-https://api.fasol.trade/trading_bot/agent}"

AUTH=(-H "Authorization: Bearer $FASOL_API_KEY")

echo "=== scope (identity, bound wallet; 412 = wallet unset) ===" >&2
curl -s "${AUTH[@]}" "$BASE/scope"

echo "" && echo "=== wallet balance ===" >&2
curl -s "${AUTH[@]}" "$BASE/wallet_balance"

echo "" && echo "=== open positions ===" >&2
curl -s "${AUTH[@]}" "$BASE/positions"

echo "" && echo "=== open + sleeping orders ===" >&2
curl -s "${AUTH[@]}" "$BASE/orders"

echo "" && echo "=== recent trades (realized PnL source of truth) ===" >&2
curl -s "${AUTH[@]}" "$BASE/trades" || true

echo "" && echo "=== rate limit headroom ===" >&2
curl -s "${AUTH[@]}" "$BASE/rate_limit"

echo "" >&2
echo "AGENT checklist: (1) balance >= 0.07 SOL? (2) every position has" >&2
echo "live TP + trailing? (3) any position flat >12h -> time stop (swap sell" >&2
echo "+ DELETE its orders). (4) sleeping orders on coins you no longer hold" >&2
echo "-> cancel them (they re-arm on next buy!). (5) standard tier <20%" >&2
echo "remaining -> throttle this cycle." >&2
