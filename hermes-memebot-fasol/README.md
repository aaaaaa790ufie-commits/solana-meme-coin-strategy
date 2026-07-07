# Hermes Memebot (Fasol Edition) — Smart Flow Momentum для Solana

Fork проекта `hermes-memebot` под терминал **Fasol** (fasol.trade).
Тот же функционал и та же философия стратегии, но все взаимодействия идут
через **Fasol Agent API** (репозиторий `fasol-robot/fasol-skills`)
с бюджетом **0.1 SOL**.

## Чем отличается от GMGN-версии

| Функция | GMGN-версия | Fasol-версия (этот проект) |
|---|---|---|
| Скан рынка | `market trending` с фильтрами | `POST /snapshot/scan` (cross-coin discovery) |
| Smart money сигнал | Готовые smart_degen данные | `wallet_search` → tracked wallets → live trades (строишь свой smart money слой) |
| Security-проверки | honeypot / rug_ratio флаги | Прокси: `is_migrated`, top10/dev/snipers/bundlers hold %, dev history |
| Dev-аналитика | базовая | **Богаче**: `dev_pf_migrated_p`, `dev_last3_avg_ath`, `dev_last_migrated` |
| Вход с TP/SL | cooking order (атомарно) | `POST /swap?wait=true` → `POST /orders` TP + trailing (2 шага, <5 сек) |
| Trailing stop | да | да, + `activation_p` (арм после порога профита) |
| Бэктест | нет | **`POST /alert/simulate`** — 1–5 дней истории с ATH-мультипликаторами |
| Streams | нет | 5 SSE-стримов (цена, сделки, tx, tracked wallets, алерты) |
| Rate limits | мягкие | Жёсткие: 120/30/5 rpm по тирам — скрипты это учитывают |

**Важно про издержки:** комиссия Fasol на своп документацией skills не
фиксируется. Перед началом торговли агент ОБЯЗАН сделать один тестовый
микро-своп (0.005 SOL туда-обратно на ликвидном токене) и замерить реальные
полные издержки за круг. Пока не замерено — модель считает консервативно
~15% позиции за круг, как в GMGN-версии.

## Честная математика (прочитай обязательно)

- Комиссия терминала + slippage + network/priority fee + rent ≈ 12–18% от
  позиции 0.025 SOL за круг
- **Безубыток каждой сделки ≈ +15%.** Скальпинг запрещён.
- Мемкоины — игра с отрицательной суммой после комиссий. Этот проект
  максимизирует шансы через селективность и железный риск-менеджмент, но
  0.1 SOL — это обучаемый капитал, который можно потерять целиком.

## Структура проекта

```
hermes-memebot-fasol/
├── README.md            ← ты здесь
├── SETUP.md             ← регистрация Fasol, ключи, привязка кошелька
├── SKILL.md             ← главный skill для hermes agent (отдай агенту этот файл)
├── STRATEGY.md          ← стратегия Smart Flow Momentum (адаптация под Fasol)
├── RISK_RULES.md        ← ненарушаемые риск-правила
├── config/
│   └── strategy.json    ← все параметры стратегии (можно тюнить)
└── scripts/
    ├── scan.sh          ← snapshot/scan дискавери свежих мигрировавших токенов
    ├── vet.sh           ← coin stats + dev history проверка кандидата
    ├── enter.sh         ← swap?wait=true + TP + trailing одной командой
    └── status.sh        ← баланс, позиции, ордера, rate limit
```

## Быстрый старт

1. Выполни `SETUP.md` (регистрация агента на fasol.trade + привязка кошелька) — ~10 минут
2. Скажи hermes agent: **"Прочитай hermes-memebot-fasol/SKILL.md и следуй ему.
   Начни торговый цикл."**
3. Агент будет: сканировать snapshot/scan → проверять CoinStat + dev history →
   входить swap с немедленными TP/trailing → отчитываться

Агент никогда не нарушает `RISK_RULES.md`. Если хочешь изменить параметры —
редактируй `config/strategy.json`, а не проси агента "рискнуть".

## Актуальность API

Fasol skills активно развиваются (v0.2.0, sub-skills в `skills/*.md`).
Агент обязан раз в сутки обновлять локальную копию репозитория и читать
`skills/changelog.md` — контракт API может меняться:

```bash
git clone https://github.com/fasol-robot/fasol-skills /tmp/fasol-skills 2>/dev/null || \
  git -C /tmp/fasol-skills pull --ff-only
cat /tmp/fasol-skills/fasol-agent/skills/changelog.md
```
