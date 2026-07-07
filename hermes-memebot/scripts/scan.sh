#!/usr/bin/env bash
# scan.sh — сканирует тренды Solana по фильтрам стратегии.
# Использование: ./scan.sh [1h|5m]  (по умолчанию оба окна)
set -euo pipefail

CONFIG="$(dirname "$0")/../config/strategy.json"
MIN_LIQ=$(jq -r '.scan.min_liquidity_usd' "$CONFIG" 2>/dev/null || echo 30000)
MIN_SMART=$(jq -r '.scan.min_smart_degen_count' "$CONFIG" 2>/dev/null || echo 3)
LIMIT=$(jq -r '.scan.trending_limit' "$CONFIG" 2>/dev/null || echo 30)
MAX_AGE_H=$(jq -r '.scan.max_token_age_hours' "$CONFIG" 2>/dev/null || echo 72)

scan_window() {
  local interval="$1" min_smart="$2"
  echo "=== trending ${interval} ===" >&2
  gmgn-cli market trending \
    --chain sol \
    --interval "$interval" \
    --min-liquidity "$MIN_LIQ" \
    --max-created "${MAX_AGE_H}h" \
    --min-smart-degen-count "$min_smart" \
    --filter not_risk --filter not_honeypot \
    --order-by volume --limit "$LIMIT" --raw
}

case "${1:-all}" in
  1h)  scan_window 1h "$MIN_SMART" ;;
  5m)  scan_window 5m 2 ;;
  all) scan_window 1h "$MIN_SMART"; scan_window 5m 2 ;;
  *)   echo "usage: $0 [1h|5m|all]" >&2; exit 1 ;;
esac
