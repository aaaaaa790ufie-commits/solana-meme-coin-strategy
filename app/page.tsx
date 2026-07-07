const files = [
  { path: "hermes-memebot/README.md", desc: "Обзор проекта, сравнение GMGN vs Fasol, честная математика комиссий" },
  { path: "hermes-memebot/SETUP.md", desc: "Регистрация на gmgn.ai/ai, генерация Ed25519 ключей, установка gmgn-cli" },
  { path: "hermes-memebot/SKILL.md", desc: "Главный skill для hermes agent — торговый цикл: scan → vet → enter → manage → report" },
  { path: "hermes-memebot/STRATEGY.md", desc: "Стратегия Smart Money Momentum: тезис, EV-математика, чеклист входа, система выходов" },
  { path: "hermes-memebot/RISK_RULES.md", desc: "17 ненарушаемых риск-правил (hard stop 0.07 SOL, резерв 0.05 SOL, лимиты дня)" },
  { path: "hermes-memebot/config/strategy.json", desc: "Все параметры стратегии в одном месте — тюнинг без правки промптов" },
  { path: "hermes-memebot/scripts/*.sh", desc: "scan.sh, vet.sh, enter.sh, status.sh — обёртки над gmgn-cli" },
]

const rules = [
  "Позиция 0.025 SOL, максимум 2 одновременно",
  "Резерв 0.05 SOL — неприкосновенен (газ на выходы)",
  "Только токены после градации с bonding curve, ликвидность от $30k",
  "Вход только при smart money net buying + все security-фильтры пройдены",
  "Cooking order: TP +80% (продажа 50%) + trailing stop -25% сразу при входе",
  "Hard stop: баланс < 0.07 SOL → полная остановка",
  "2 убытка за день → стоп до завтра. Ноль сделок — нормальный день",
]

export default function Page() {
  return (
    <main className="min-h-screen bg-background text-foreground font-sans">
      <div className="mx-auto max-w-2xl px-6 py-16 flex flex-col gap-10">
        <header className="flex flex-col gap-3">
          <p className="text-sm font-mono text-muted-foreground">hermes-memebot v1.0.0</p>
          <h1 className="text-3xl font-semibold text-balance">Smart Money Momentum для Solana</h1>
          <p className="text-muted-foreground leading-relaxed">
            Готовый торговый проект для hermes agent на базе GMGN Agent Skills. Бюджет 0.1 SOL,
            стратегия построена вокруг реальной математики комиссий: безубыток сделки ≈ +15%,
            поэтому — редкие входы с целью +50–100% и автоматические выходы.
          </p>
        </header>

        <section className="flex flex-col gap-3">
          <h2 className="text-lg font-semibold">Файлы проекта</h2>
          <ul className="flex flex-col gap-2">
            {files.map((f) => (
              <li key={f.path} className="rounded-md border border-border p-3">
                <p className="font-mono text-sm">{f.path}</p>
                <p className="text-sm text-muted-foreground">{f.desc}</p>
              </li>
            ))}
          </ul>
        </section>

        <section className="flex flex-col gap-3">
          <h2 className="text-lg font-semibold">Ключевые правила</h2>
          <ul className="flex flex-col gap-1.5 list-disc pl-5 text-sm leading-relaxed">
            {rules.map((r) => (
              <li key={r}>{r}</li>
            ))}
          </ul>
        </section>

        <section className="rounded-md border border-border bg-muted p-4">
          <h2 className="text-sm font-semibold mb-1">Как запустить</h2>
          <ol className="list-decimal pl-5 text-sm leading-relaxed text-muted-foreground">
            <li>Выполни hermes-memebot/SETUP.md (регистрация GMGN + gmgn-cli)</li>
            <li>Пополни привязанный кошелёк на 0.1 SOL</li>
            <li>{'Скажи агенту: "Прочитай hermes-memebot/SKILL.md и начни торговый цикл"'}</li>
          </ol>
        </section>

        <footer className="text-xs text-muted-foreground leading-relaxed">
          Прибыль не гарантирована. Мемкоины — высокорисковый актив; 0.1 SOL следует
          рассматривать как капитал, который можно потерять целиком.
        </footer>
      </div>
    </main>
  )
}
