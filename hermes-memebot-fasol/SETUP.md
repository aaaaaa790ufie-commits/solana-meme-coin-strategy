# SETUP — регистрация Fasol и подготовка окружения

Выполни один раз. Части, помеченные "(агент)", может сделать твой hermes agent.

## 1. Установка Skills (агент)

```bash
npx skills add fasol-robot/fasol-skills
# или напрямую:
git clone https://github.com/fasol-robot/fasol-skills /tmp/fasol-skills
```

Понадобятся `curl` и `jq` (обычно уже установлены). Скрипты этого проекта —
чистый bash + curl, отдельный CLI не нужен.

## 2. Создание агента и API-ключа (ты, в браузере)

1. Открой **https://fasol.trade** → **AI Trade** → вкладка **AI Agents**
2. **Create agent** → назови его, выбери scopes. Для этой стратегии нужны:
   - `read_coins` — CoinStat, candles, snapshot
   - `read_positions` — позиции, трейды, баланс
   - `read_dev_history` — история деплойера
   - `place_orders` — swap и ордера (TP/SL/trailing)
   - `manage_tracking` — tracked wallets (smart money слой)
   - `read_alerts` / `manage_alerts` — опционально, для alert-simulate
3. **Привяжи Solana-кошелёк к агенту** (обязательно! без этого любой вызов
   вернёт `412 agent_wallet_unset`)
4. Скопируй ключ `fsl_live_...` — он показывается один раз

## 3. Конфигурация (агент)

```bash
mkdir -p ~/.config/fasol
cat > ~/.config/fasol/.env << 'EOF'
FASOL_API_KEY=<твой_fsl_live_ключ>
FASOL_API_BASE_URL=https://api.fasol.trade/trading_bot/agent
EOF
chmod 600 ~/.config/fasol/.env
```

## 4. Пополнение кошелька

- Переведи **0.1 SOL** на кошелёк, который привязал к агенту в шаге 2
- Проверка баланса:
  ```bash
  source ~/.config/fasol/.env
  curl -s -H "Authorization: Bearer $FASOL_API_KEY" "$FASOL_API_BASE_URL/wallet_balance"
  ```

## 5. Финальная проверка (агент)

```bash
source ~/.config/fasol/.env
# Кто я, какие scopes, какой кошелёк привязан:
curl -s -H "Authorization: Bearer $FASOL_API_KEY" "$FASOL_API_BASE_URL/scope"
# Бюджет запросов:
curl -s -H "Authorization: Bearer $FASOL_API_KEY" "$FASOL_API_BASE_URL/rate_limit"
```

- `/scope` вернул agent_name, все нужные scopes и `wallet` → всё готово
- `412 agent_wallet_unset` → вернись в UI и привяжи кошелёк (шаг 2.3)
- `403 missing_scope` на каком-то вызове позже → пересоздай ключ с нужным scope

## 6. Замер реальных издержек (агент, один раз перед торговлей)

Комиссии Fasol не зафиксированы в skills-документации. Сделай тестовый круг
на ликвидном токене и запиши результат в `config/strategy.json` →
`costs.measured_round_trip_pct`:

```bash
# buy 0.005 SOL → сразу sell 100%, оба с ?wait=true
# сравни amount_sol входа и полученный SOL на выходе
```

Пока замер не сделан, стратегия использует консервативные 15% за круг.

## Безопасность

- `FASOL_API_KEY` хранится только в `~/.config/fasol/.env` (chmod 600).
  Никогда не выводится в чат, логи или файлы проекта
- Ключ Fasol — это API-ключ агента, НЕ seed-фраза. Seed-фразу кошелька
  не вводи нигде
- Кошелёк агента держит только торговый бюджет (0.1 SOL), не больше.
  Fasol-агент жёстко привязан к одному кошельку на стороне сервера —
  это плюс: даже украденный ключ не переключит кошелёк
- Используй ТОЛЬКО snake_case пути `$FASOL_API_BASE_URL/...` из SKILL.md.
  Kebab-case пути `/trading_bot/...` — это web-API, агентский ключ там
  получит 401
- Репозиторий fasol-skills имеет мало звёзд (СНГ-проект на ранней стадии) —
  прочитай код `scripts/lib/api.mjs` перед использованием их хелперов;
  наши скрипты используют только curl напрямую
