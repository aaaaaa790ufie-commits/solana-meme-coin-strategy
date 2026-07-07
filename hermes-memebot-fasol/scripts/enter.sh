#!/usr/bin/env bash
# enter.sh — вход в позицию: swap?wait=true + TP + trailing (замена cooking order).
# Параметры берутся из config/strategy.json.
# Использование: ./enter.sh <coin_address>
#
# ВНИМАНИЕ (агент): перед запуском обязан быть выполнен vet.sh и проверены
# лимиты RISK_RULES.md (баланс, число позиций, входы за день, убытки за день).
set -euo pipefail

ADDR="${1:?usage: enter.sh <coin_address>}"

ENV_FILE="${FASOL_ENV_FILE:-$HOME/.config/fasol/.env}"
[ -f "$ENV_FILE" ] && { set -a; source "$ENV_FILE"; set +a; }
: "${FASOL_API_KEY:?FASOL_API_KEY is not set (see SETUP.md)}"
BASE="${FASOL_API_BASE_URL:-https://api.fasol.trade/trading_bot/agent}"

CONFIG="$(dirname "$0")/../config/strategy.json"
SIZE=$(jq -r '.position.size_sol' "$CONFIG" 2>/dev/null || echo 0.025)
SLIPPAGE=$(jq -r '.position.slippage_cap_pct' "$CONFIG" 2>/dev/null || echo 3)
TP=$(jq -r '.exits.take_profit_pct' "$CONFIG" 2>/dev/null || echo 80)
TP_PORTION=$(jq -r '.exits.take_profit_sell_portion_pct' "$CONFIG" 2>/dev/null || echo 50)
TRAIL=$(jq -r '.exits.trailing_stop_pct' "$CONFIG" 2>/dev/null || echo 25)
TRAIL_ACT=$(jq -r '.exits.trailing_activation_pct' "$CONFIG" 2>/dev/null || echo 0)

echo "Entering $ADDR: size=${SIZE} SOL, slippage cap=${SLIPPAGE}%," >&2
echo "TP=+${TP}% (sell ${TP_PORTION}%), trailing SL=-${TRAIL}% from peak" >&2

echo "=== 1/3 instant buy (synchronous) ===" >&2
BUY=$(curl -s -X POST \
  -H "Authorization: Bearer $FASOL_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"direction\":\"buy\",\"coin_address\":\"$ADDR\",\"amount_sol\":\"$SIZE\",\"slippage_p\":\"$SLIPPAGE\"}" \
  "$BASE/swap?wait=true")
echo "$BUY"

STATUS=$(echo "$BUY" | jq -r '.data.status // .error // "unknown"')
if [ "$STATUS" != "success" ]; then
  echo "" >&2
  echo "BUY NOT CONFIRMED (status: $STATUS). If tx_wait_timeout (504)," >&2
  echo "check GET /trades once before assuming failure. DO NOT place" >&2
  echo "exit orders for a position that does not exist. ABORTING." >&2
  exit 1
fi

echo "=== 2/3 take profit +${TP}% (sell ${TP_PORTION}%) ===" >&2
curl -sf -X POST \
  -H "Authorization: Bearer $FASOL_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"type\":\"take_profit\",\"coin_address\":\"$ADDR\",\"trigger_p\":\"$TP\",\"sell_p\":\"$TP_PORTION\"}" \
  "$BASE/orders"

echo "=== 3/3 trailing stop -${TRAIL}% from peak ===" >&2
curl -sf -X POST \
  -H "Authorization: Bearer $FASOL_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"type\":\"trailing\",\"coin_address\":\"$ADDR\",\"trailing_p\":\"$TRAIL\",\"activation_p\":\"$TRAIL_ACT\",\"sell_p\":\"100\"}" \
  "$BASE/orders"

echo "" >&2
echo "AGENT: record all order IDs (ord_...). Verify via GET /coin/$ADDR/orders" >&2
echo "that both exits are live. Naked position > 60s = critical." >&2
echo "Fasol orders PERSIST and re-arm on next buy — on manual exit you MUST" >&2
echo "DELETE /orders/:id for this coin." >&2
