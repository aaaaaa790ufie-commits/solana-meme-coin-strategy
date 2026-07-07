#!/usr/bin/env bash
# vet.sh — собирает все данные для проверки кандидата перед входом.
# Агент анализирует вывод по фильтрам из config/strategy.json (SKILL.md Step 2).
# Использование: ./vet.sh <coin_address>
set -euo pipefail

ADDR="${1:?usage: vet.sh <coin_address>}"

ENV_FILE="${FASOL_ENV_FILE:-$HOME/.config/fasol/.env}"
[ -f "$ENV_FILE" ] && { set -a; source "$ENV_FILE"; set +a; }
: "${FASOL_API_KEY:?FASOL_API_KEY is not set (see SETUP.md)}"
BASE="${FASOL_API_BASE_URL:-https://api.fasol.trade/trading_bot/agent}"

echo "=== coin stats ===" >&2
STATS=$(curl -sf -H "Authorization: Bearer $FASOL_API_KEY" "$BASE/coin/$ADDR/stats")
echo "$STATS"

DEPLOYER=$(echo "$STATS" | jq -r '.data.deployer // empty')

echo "=== candles_fast (last 5 min, momentum check) ===" >&2
curl -sf -H "Authorization: Bearer $FASOL_API_KEY" "$BASE/coin/$ADDR/candles_fast" || true

if [ -n "$DEPLOYER" ]; then
  echo "=== dev history ($DEPLOYER) ===" >&2
  curl -sf -H "Authorization: Bearer $FASOL_API_KEY" "$BASE/dev/$DEPLOYER" || true
fi

echo "" >&2
echo "REMINDER (agent): reject if not migrated, liq<\$30k, age>72h," >&2
echo "top10>30%, dev>5%, snipers>20%, bundlers>20%, bot_traders>25%," >&2
echo "1h pump>400%, serial-rugger dev (10+ launches, <20% migrated)," >&2
echo "no socials & no dex_paid, mayhem mode, sell_tx > 2x buy_tx," >&2
echo "or <2 tracked smart wallets net-buying in last hour." >&2
echo "404 on this coin = permanent — drop it from the watchlist." >&2
