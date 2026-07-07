# Strategy: Smart Money Momentum (post-graduation)

## Thesis

On a 0.1 SOL budget the only mathematically viable approach is:
**few trades, high selectivity, asymmetric payoff, automated exits.**

Why not the alternatives:

| Approach | Why it fails at 0.1 SOL |
|---|---|
| Launch sniping | Priority fees 0.005–0.02 SOL per attempt, most snipes lose to bundlers with bigger capital |
| Scalping (+5–10% targets) | Round-trip cost ~15% of position → every scalp is a guaranteed loss |
| Copy-trading blindly | You enter after the smart wallet, exit after it too — the lag eats the small edge |
| Holding "moonbags" long-term | 95%+ of memecoins go to ~0 within weeks |

What remains: enter **freshly graduated** tokens (survived the bonding curve →
real liquidity, honeypot risk mostly filtered) that **smart money is actively
accumulating**, with **volume acceleration**, and let a trailing stop capture
the fat tail of the distribution.

## The math

Budget allocation (0.1 SOL):
- 2 concurrent positions max × 0.025 SOL = 0.05 SOL at risk
- 0.05 SOL permanent reserve — gas, priority fees for EXITS, rent. Never traded.

Per-trade cost model (0.025 SOL position):
- GMGN fee: 1% + 1% = ~0.0005 SOL
- Slippage (3% cap each way, ~1.5% typical): ~0.00075 SOL
- Network + priority + token account rent: ~0.0025 SOL
- **Total ≈ 0.0037 SOL ≈ 15% of position → break-even ≈ +15%**

Expected value per trade (target profile):
- Win (trailing stop captures avg +60% net): P ≈ 0.35 → +0.015 SOL
- Loss (trailing stop -25%, net -40% with costs): P ≈ 0.65 → -0.010 SOL
- EV ≈ +0.35×0.015 − 0.65×0.010 ≈ **-0.0013…+0.005 SOL/trade** depending on
  filter quality. The filters in SKILL.md are what push EV positive; without
  them EV is firmly negative. This is why thresholds are never lowered.

The strategy is long-tail dependent: most profit comes from 1 in ~10 trades
that runs +150–300% and the trailing stop rides it. Cutting losers fast and
never capping winners early (beyond the 50% de-risk TP) is the whole edge.

## Entry checklist (mirror of SKILL.md Step 2)

A token must pass ALL:
1. Graduated from bonding curve, liquidity ≥ $30k
2. Age ≤ 72h, not up >400% in last 1h
3. Security: no honeypot, no wash-trade flag, rug_ratio ≤ 0.30
4. Distribution: top10 ≤ 30%, insiders ≤ 20%, dev ≤ 5%
5. Manipulation: rat traders ≤ 15% of volume, bundlers ≤ 20%
6. Smart money: ≥ 3 smart wallets holding AND net buying in last 1h
7. Momentum: 5m volume accelerating vs 1h average

## Exit system

- **Entry order**: cooking order = buy + TP + trailing SL atomically
- **De-risk TP**: sell 50% at +80% → after it fires, worst case is near break-even
- **Trailing stop**: -25% from peak; tightened to -15% once position is +50%
- **Time stop**: flat after 12h → market exit, rotate capital
- **Portfolio stop**: balance < 0.07 SOL → full halt (see RISK_RULES.md)

## Cadence & discipline

- Scan every 15–30 min; expect 0–3 qualifying setups per day, often zero
- 2 realized losses in a day → done for the day (variance control)
- Weekly review: if 20+ trades taken and cumulative PnL < 0, halt and
  re-examine filter thresholds with the user instead of continuing

## Scaling plan

- 0.10 → 0.15 SOL: same size (0.025), 2 positions
- 0.15 → 0.25 SOL: size 0.03, 3 positions
- ≥ 0.25 SOL: size 4–5% of balance, reserve stays ≥ 40%
- Never scale after a winning streak by more than one step
