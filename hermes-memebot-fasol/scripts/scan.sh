#!/usr/bin/env bash
# scan.sh — дискавери свежих мигрировавших токенов через POST /snapshot/scan.
# ⚠️ HEAVY endpoint (5 rpm) — максимум ОДИН вызов за торговый цикл.
# Использование: ./scan.sh
set -euo pipefail

ENV_FILE="${FASOL_ENV_FILE:-$HOME/.config/fasol/.env}"
[ -f "$ENV_FILE" ] && { set -a; source "$ENV_FILE"; set +a; }
: "${FASOL_API_KEY:?FASOL_API_KEY is not set (see SETUP.md)}"
BASE="${FASOL_API_BASE_URL:-https://api.fasol.trade/trading_bot/agent}"

CONFIG="$(dirname "$0")/../config/strategy.json"
MIN_LIQ=$(jq -r '.scan.min_liquidity_usd' "$CONFIG" 2>/dev/null || echo 30000)
MAX_AGE_H=$(jq -r '.scan.max_token_age_hours' "$CONFIG" 2>/dev/null || echo 72)

echo "=== snapshot/scan: migrated, liq>=\$${MIN_LIQ}, age<=${MAX_AGE_H}h ===" >&2
# Точную схему body сверяй с /tmp/fasol-skills/fasol-agent/skills/snapshot-scan.md
# (агент обязан прочитать sub-skill перед первым вызовом — контракт может меняться).
curl -sf -X POST \
  -H "Authorization: Bearer $FASOL_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"filters\": {
      \"is_migrated\": true,
      \"liq_min\": \"${MIN_LIQ}\",
      \"coin_created_seconds_ago_max\": $((MAX_AGE_H * 3600))
    },
    \"order_by\": \"vol_5m\",
    \"limit\": 30
  }" \
  "$BASE/snapshot/scan"

echo "" >&2
echo "=== tracked wallets live trades (smart flow confirmation, HEAVY) ===" >&2
curl -sf -H "Authorization: Bearer $FASOL_API_KEY" \
  "$BASE/tracked_wallets/live_trades" || echo '{"note":"no tracked wallets yet — run wallet_search first (SKILL.md Step 0b)"}'

echo "" >&2
echo "AGENT: shortlist <=5 candidates; priority to coins bought by >=2" >&2
echo "tracked wallets in last hour. Then vet.sh each. Do NOT re-run scan" >&2
echo "this cycle (heavy tier, 5 rpm)." >&2
