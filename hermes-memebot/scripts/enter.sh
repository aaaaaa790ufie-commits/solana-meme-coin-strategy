#!/usr/bin/env bash
# enter.sh — вход в позицию cooking-ордером (buy + TP + trailing SL атомарно).
# Параметры берутся из config/strategy.json.
# Использование: ./enter.sh <token_address>
#
# ВНИМАНИЕ (агент): перед запуском обязан быть выполнен vet.sh и проверены
# лимиты RISK_RULES.md (баланс, число позиций, входы за день, убытки за день).
set -euo pipefail

ADDR="${1:?usage: enter.sh <token_address>}"
CONFIG="$(dirname "$0")/../config/strategy.json"

SIZE=$(jq -r '.position.size_sol' "$CONFIG" 2>/dev/null || echo 0.025)
SLIPPAGE=$(jq -r '.position.slippage_cap_pct' "$CONFIG" 2>/dev/null || echo 3)
TP=$(jq -r '.exits.take_profit_pct' "$CONFIG" 2>/dev/null || echo 80)
TP_PORTION=$(jq -r '.exits.take_profit_sell_portion_pct' "$CONFIG" 2>/dev/null || echo 50)
TRAIL=$(jq -r '.exits.trailing_stop_pct' "$CONFIG" 2>/dev/null || echo 25)

echo "Entering $ADDR: size=${SIZE} SOL, slippage cap=${SLIPPAGE}%," >&2
echo "TP=+${TP}% (sell ${TP_PORTION}%), trailing SL=-${TRAIL}% from peak" >&2

# Cooking order: buy + условные ордера одной командой.
# Точный синтаксис флагов сверяй с /gmgn-cooking SKILL.md установленной версии
# gmgn-cli (`gmgn-cli cooking --help`) — API может обновляться.
gmgn-cli cooking \
  --chain sol \
  --address "$ADDR" \
  --amount "$SIZE" \
  --slippage "$SLIPPAGE" \
  --take-profit "$TP" --take-profit-percent "$TP_PORTION" \
  --trailing-stop "$TRAIL" \
  --raw

echo "" >&2
echo "AGENT: poll 'gmgn-cli order get <order_id>' until fill confirms," >&2
echo "then verify TP/SL orders are live. Naked position > 60s = critical." >&2
