# Hermes Memebot — Smart Money Momentum для Solana

Готовый проект для твоего hermes agent (OpenCode Zen / deepseek v4 flash free).
Стратегия торговли мемкоинами Solana через **GMGN Agent Skills API** с бюджетом **0.1 SOL**.

## Почему GMGN, а не Fasol

| | GMGN (GMGNAI/gmgn-skills) | Fasol (fasol-robot/fasol-skills) |
|---|---|---|
| Звёзды / контрибьюторы | 353 / 10 | 2 / 1 |
| Skills | 6 (token, market, portfolio, track, swap, cooking) | 1 |
| Smart Money / KOL данные | Да, real-time | Нет |
| Security-проверки (honeypot, rug ratio) | Да | Нет |
| Rat trader / bundler / insider аналитика | Да | Нет |
| Cooking orders (buy + TP/SL одной командой) | Да | Нет |
| Trailing TP/SL | Да | Да |
| Скорость исполнения | < 0.3 сек | Неизвестно |

**Вывод: регистрируйся на GMGN.** Без smart money данных и security-проверок
торговля на 0.1 SOL — это лотерея. Читай `SETUP.md` для регистрации.

## Честная математика (прочитай обязательно)

- Комиссия GMGN: ~1% на вход + ~1% на выход = ~2% за круг
- Slippage: ~1–3% за круг
- Network + priority fee + rent token account: ~0.002–0.004 SOL за круг
- При позиции 0.025 SOL полные издержки за круг: **~12–18% позиции**
- **Безубыток каждой сделки ≈ +15%.** Поэтому скальпинг запрещён.

**Никто не гарантирует прибыль.** Мемкоины — игра с отрицательной суммой после
комиссий. Этот проект максимизирует твои шансы через селективность и железный
риск-менеджмент, но 0.1 SOL нужно воспринимать как обучаемый капитал,
который можно потерять целиком.

## Структура проекта

```
hermes-memebot/
├── README.md            ← ты здесь
├── SETUP.md             ← регистрация GMGN, ключи, установка CLI
├── SKILL.md             ← главный skill для hermes agent (отдай агенту этот файл)
├── STRATEGY.md          ← полная стратегия Smart Money Momentum
├── RISK_RULES.md        ← ненарушаемые риск-правила
├── config/
│   └── strategy.json    ← все параметры стратегии (можно тюнить)
└── scripts/
    ├── scan.sh          ← сканирование трендов с фильтрами
    ├── vet.sh           ← полная проверка кандидата перед входом
    ├── enter.sh         ← вход cooking-ордером с TP/SL
    └── status.sh        ← позиции, ордера, PnL
```

## Быстрый старт

1. Выполни `SETUP.md` (регистрация GMGN + установка gmgn-cli) — ~10 минут
2. Скажи hermes agent: **"Прочитай hermes-memebot/SKILL.md и следуй ему.
   Начни торговый цикл."**
3. Агент будет сканировать → проверять → входить cooking-ордерами с
   автоматическими TP/SL → отчитываться

Агент никогда не нарушает `RISK_RULES.md`. Если хочешь изменить параметры —
редактируй `config/strategy.json`, а не проси агента "рискнуть".
