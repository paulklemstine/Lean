# Future Directions — Gödel's Casino: Incomplete but Winnable Games

This cycle formalized the doubling (martingale) casino in
`Catalog/Logic/GodelsCasino.lean`. We established the "incomplete but winnable"
dichotomy (`winProb_lt_one` / `winProb_tendsto_one` / `incomplete_but_winnable`),
the closed-form house edge `expectedGain p n = 1 - (2(1-p))^n`
(`expectedGain_closed_form`), the fair/subfair/superfair trichotomy, the uniqueness
of the fair point `p = 1/2` (`expectedGain_fair_iff`), honesty monotonicity
(`expectedGain_strictMonoOn_p`), and the divergence of worst-case exposure
(`exposure_tendsto_atTop`).

The following conjectures are precise and falsifiable; each is a candidate Lean
target for a follow-up cycle.

## C1 — General geometric stake schedules (the minimality of doubling)
Replace the doubling stakes `2^k` by a geometric schedule with ratio `r > 1`,
stake `r^k` on round `k`. Conjecture: the strategy yields a guaranteed unit-style
profit on the first win **iff** `r ≥ 2`, and for every `r > 1` the win probability
still tends to `1` while the closed-form expected gain generalizes to
`expectedGain_r p n = 1 - ((1+r)(1-p)/?)^n`-type single-power form, with the fair
boundary shifting away from `p = 1/2`. Falsifier: exhibit `r ∈ (1,2)` for which the
first-win payoff is still a fixed positive constant independent of the round.

## C2 — The exact tail-risk / expectation trade-off law
For the fair casino (`p = 1/2`) we have `E = 0` yet exposure `2^n - 1 → ∞`.
Conjecture: there is a sharp conservation law of the form
`winProb · (typical gain) + ruinProb · (catastrophic loss) = 0` that **forces**
any betting schedule achieving `winProb → 1` in a fair game to have unbounded
worst-case exposure; i.e. bounded exposure ⟹ `liminf winProb < 1`. Formalize as:
no schedule with uniformly bounded stake-sums attains `winProb_tendsto_one` in a
fair casino. Falsifier: a bounded-exposure fair schedule with win probability → 1.

## C3 — Almost-sure winning via Borel–Cantelli
Model the infinite play as the product measure on `{win,lose}^ℕ`. Conjecture: for
`0 < p ≤ 1` the event "a win eventually occurs" has probability exactly `1`
(`∏ (1-p) = 0`), so the gambler wins almost surely, yet the first-win time `T` is
a.s. finite with `P(T > n) = (1-p)^n` and **unbounded** essential supremum. This is
the measure-theoretic upgrade of `incomplete_but_winnable`. Target: a `PMF`/`MeasureTheory`
formalization with `winProb` recovered as a finite marginal.

## C4 — A genuinely undecidable casino
Let `f : ℕ → Bool` be the characteristic function of a non-computable set (e.g. the
halting set). Define a casino whose round `k` is "rigged" exactly when `f k = true`.
Conjecture: the predicate "the doubling gambler is guaranteed to profit by round `n`"
is undecidable as a function of `n`, while the probabilistic win bound
`1 - (1-p)^n` remains a computable lower bound holding *unconditionally*. This makes
the Gödel analogy literal: a computable certainty bound for an undecidable winning
predicate. Falsifier: a decision procedure for the guaranteed-profit predicate.

## C5 — Kelly-optimal play and the entropy of the fair boundary
For a superfair casino (`1/2 < p ≤ 1`), conjecture that among all constant-fraction
(Kelly) strategies the long-run growth rate is maximized at fraction `2p - 1`
(the per-round edge appearing in `expectedGain_one_round`), with growth rate equal
to `log 2 - H(p)` where `H` is binary entropy, vanishing exactly at the fair
boundary `p = 1/2`. This links the fairness point `p = 1/2` of this cycle to the
information-theoretic boundary `H(1/2) = log 2`. Falsifier: a constant-fraction
strategy beating fraction `2p-1` in long-run growth for some `p`.
