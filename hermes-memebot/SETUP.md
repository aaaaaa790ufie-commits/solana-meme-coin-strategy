# SETUP — регистрация GMGN и подготовка окружения

Выполни один раз. Части, помеченные "(агент)", может сделать твой hermes agent.

## 1. Установка CLI и Skills (агент)

```bash
npx skills add GMGNAI/gmgn-skills
npm install -g gmgn-cli
```

Проверка на публичном демо-ключе (только для теста, торговать им нельзя):

```bash
GMGN_API_KEY=gmgn_solbscbaseethmonadtron gmgn-cli market trending --chain sol --interval 1h --limit 3
```

Если видишь JSON — CLI работает.

> Если 401/403 при верных ключах — проверь, не идёт ли трафик через IPv6
> (`curl -s https://ipv6.icanhazip.com`). GMGN API работает только по IPv4.

## 2. Генерация Ed25519 ключей (агент)

```bash
openssl genpkey -algorithm ed25519 -out ~/.config/gmgn/gmgn_private.pem 2>/dev/null && \
  openssl pkey -in ~/.config/gmgn/gmgn_private.pem -pubout
```

Агент покажет **публичный ключ** — он нужен для формы на сайте.
**Приватный ключ никому и никогда не отправляй**, включая любые сайты.
Он хранится только локально.

## 3. Регистрация API-ключа (ты, в браузере)

1. Открой **https://gmgn.ai/ai**
2. Создай API Key: вставь **публичный** ключ из шага 2
3. Для торговли (swap) включи торговый scope и добавь свой egress IP
   в whitelist (узнать: `curl ip.me`)
4. Скопируй выданный API Key

## 4. Конфигурация (агент)

```bash
mkdir -p ~/.config/gmgn
cat > ~/.config/gmgn/.env << 'EOF'
GMGN_API_KEY=<твой_api_key>
GMGN_PRIVATE_KEY="<содержимое gmgn_private.pem>"
EOF
chmod 600 ~/.config/gmgn/.env
```

## 5. Пополнение кошелька

- Узнай кошелёк, привязанный к API-ключу:
  `gmgn-cli portfolio holdings --chain sol` (или спроси агента: "which wallets
  are linked to my API key")
- Переведи туда **0.1 SOL**
- Используй реферальный код при регистрации GMGN, если есть — снижает
  комиссию с 1% до ~0.7–0.9%

## 6. Финальная проверка (агент)

```bash
gmgn-cli market trending --chain sol --interval 1h --limit 3
gmgn-cli portfolio holdings --chain sol
```

Обе команды вернули данные без ошибок → всё готово. Дальше — `SKILL.md`.

## Безопасность

- НИКОГДА не давай приватный ключ (PEM) чему-либо кроме локального
  `~/.config/gmgn/.env`
- Ключ GMGN — это ключ **API-подписи**, не seed-фраза кошелька. Seed-фразу
  основного кошелька не вводи нигде
- Держи на торговом кошельке только торговый бюджет (0.1 SOL), не больше
- Не устанавливай "skills" из репозиториев с < 50 звёзд без проверки кода —
  в экосистеме много репозиториев-стилеров
