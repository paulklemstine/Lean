# Round 96 — the UMW window: where a rank-2 divisor cover would have to live

**2026-10-04. Round 96 produced NO new factoring algorithm and NO exponent
improvement.** It did four things: it fixed the frontier against the primary
sources, it located the *exact* parameter window in which a construction would
beat Harvey's `N^{1/5}`, it machine-checked the counting wall that window lives
behind, and it measured — with a reproducible script — that the "obvious"
route into that window lands at `1/4`, not below `1/5`.

Machine-checked companion: `UMWCountingWall.lean` (**0 `sorry`, 0 `axiom`**,
axiom footprint exactly `[propext, Classical.choice, Quot.sound]`). Empirical
companion: `Experiments/UMWWindow/umw_window.py` (deterministic, fixed seed,
`out.txt` is the committed run).

---

## 1. The frontier, re-verified

| model | best bound | source |
|---|---|---|
| quantum | `poly(log N)` | Shor — **cannot be beaten** in this model |
| classical, heuristic | `L_N[1/3, (64/9)^{1/3}]` | GNFS |
| classical, **deterministic** | **`N^{1/5+o(1)}`** | Harvey, arXiv:2010.05450, *Math. Comp.* **90**(332) |
| classical, deterministic, **conditional** | `N^{1/6+o(1)}` | Umans–Wang, arXiv:2511.10851 — **only if** their Divisor Conjecture holds |

So the only complexity that is *plausibly* beatable without a new kind of idea
is Harvey's deterministic `N^{1/5}`, and the **only named route** past it is
Umans–Wang. Round 49 (`Round49_APCover.md`) already removed their prefactorisation
hypothesis (`APCoverReduction.lean`, 13 theorems). What remains is exactly one
object: **a structured set `S − T` that covers `[n]` by divisibility.**

---

## 2. The exact window (the main result of this round)

Umans–Wang Theorem 5.5: if the Strong `(α,β)`-Divisor Conjecture holds, `N`
factors deterministically in `Õ(N^{max(α,β)/2})`. Write

$$\gamma \;=\; \max(\alpha,\beta).$$

* **To beat Harvey** we need $\gamma/2 < 1/5$, i.e. $\boxed{\gamma < 2/5}$.
* A counting argument (below) forces $\alpha + 2\beta \ge 1$. On the diagonal
  $\alpha=\beta=\gamma$ this reads $3\gamma \ge 1$, i.e. $\gamma \ge 1/3$.

> **The window in which a rank-2 divisor cover would beat Harvey is exactly
> $\;\gamma \in [1/3,\;2/5)$, with slack $3\gamma - 1$ growing from $0$ at
> $\gamma=1/3$ to $0.2$ as $\gamma \to 0.4$.**

`umw_window.py` part (1) tabulates this. Two consequences:

1. **The `$1/6$` dream is the *hardest* point in the window, not the easiest.**
   $\gamma=1/3$ has *zero* capacity slack: every difference must be maximally
   efficient and the covered sets must partition `[n]` essentially perfectly.
   Anything $\gamma>1/3$ has real slack. **The record closed this door at the
   zero-slack point** (`RESEARCH.md` item 13: "short by `$n^{1/3}$`", "a
   capacity deficit"), so its closure does **not** cover the interior.
2. **A beating construction need not reach `$1/6$`.** Any $\gamma < 0.4$ with a
   genuine rank-2 GAP cover beats `1/5`. That is a materially easier target
   than `$1/3$`, and it is the number a next agent should optimise.

This is a *reframe*, not a construction. It says where to look; it does not
say the object exists.

---

## 3. The counting wall, machine-checked

`UMWCountingWall.lean` proves the exact arithmetic any cover must clear:

* `primorial_le_prod` — if every prime `≤ n` divides some member of a list `A`
  of positive integers, then `primorial n ∣ A.prod`. (Pairwise-coprime product
  of divisors, by Finset induction.)
* `primorial_le_pow` — if additionally `|A| = m` and every member is `≤ M`, then
  `primorial n ≤ M^m`.

Since `primorial n = exp(n^{1+o(1)})`, and Umans–Wang's `|A| = |S||T| ≤ n^{2β}`
with every difference `≤ exp(n^α)`, this recovers `α + 2β ≥ 1` — the
constraint above. **This is the wall. It is elementary and unconditional; it
is not a decision of the conjecture either way.**

---

## 4. The measurement: the obvious route lands at `1/4`

`umw_window.py` part (3), at `n = 100`, searches random rank-2 covers
(`S`, `T` each `n^γ` random elements in `[1, exp(n^γ)]`) and reports coverage:

| γ | `p=|S|=|T|` | nominal capacity | actual coverage | exponent γ/2 |
|---|---|---|---|---|
| 0.34 | 5 | 300 | 73/100 | 0.170 |
| 0.39 | 6 | 432 | 84/100 | 0.195 |
| 0.42 | 7 | 1176 | 95/100 | 0.210 |
| 0.45 | 8 | 1984 | 99/100 | 0.225 |
| **0.50** | 10 | 3100 | **100/100** | **0.250** |

Full coverage of `[n]` is first reached near $\gamma \approx 1/2$, i.e.
exponent $\approx 1/4$. The trivial one-set construction (`T={0}`,
`S = {products of blocks}`) also lands exactly at `1/4`
(`umw_window.py` / `trivial.py`). So:

> **A random (unstructured) rank-2 divisor cover buys exactly nothing over the
> trivial construction: both sit at `1/4`.** The entire gain from `1/4` down
> through the `1/5` barrier to `$1/6$` must come from the conjecture's
> **structure hypothesis** (Conjecture 3.3 item 3: `S`,`T` sums of `n^{o(1)}`
> arithmetic progressions), which random search does not supply.

This is a **no-free-lunch** measurement, not a proof that structured covers
fail. It localises the difficulty: not in the counting (which has slack in the
window), and not in a naive two-set difference set (which is stuck at `1/4`),
but specifically in whatever GAP arithmetic actually realises the cover.

---

## 5. Scope and honesty

* **No new factoring algorithm. No complexity beaten.** The method half is still
  absent, as it has been for 52 rounds.
* The frontier table, the `$1/6$` conditionality, and the `α+2β ≥ 1` counting
  constraint are all restated **from the primary sources** (arXiv:2511.10851
  read in full, §2–§6; Harvey's record as tabulated in `Round49_APCover.md`).
* What is genuinely new here: (a) the statement that the beating window is
  `[1/3, 2/5)` and that its slack *grows* away from `$1/3$`, which the record
  did not separate out (it closed at the zero-slack point); (b) the
  machine-checked counting wall; (c) the measurement that random rank-2
  construction sits at `1/4`.
* What is **not** claimed: that a cover exists in the window, that the
  conjecture is true or false, or that `1/6` is reachable. The record is right
  that `$1/6$` is unblocked but unachieved; this round sharpens *where* to aim
  without pretending to have moved it.

**Next attack, by expected value.**
1. The `c ≠ 1` / structured-CRT cover (Round 49's own item A) — now with the
   window target `γ<0.4` instead of the tight `γ=1/3`.
2. A GAP-realisation search: construct `S`,`T` as sums of a *few* APs (rank
   `n^{o(1)}`, not random sets) and measure coverage in the window. This is the
   only channel the measurement above leaves open.
3. Negative: prove any GAP cover is bounded below by the trivial `1/4` — that
   would close the door rigorously instead of empirically.