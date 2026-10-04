# Round 104 — the budget-escape pitfall: a methodology result, and a caught false positive

**2026-10-04. No exponent beaten. This round tests whether the birthday
obstruction (round 96b) is fundamental or a *restriction/sampler* artifact, using
the catalog's proven Kelley–Meka restriction operator (`BernoulliSprinkling.lean`,
never applied to factoring). It finds an apparent 16× breakthrough that is a
BUDGET ESCAPE — caught, reproduced, and recorded as a reusable guard.**

Companion: `Experiments/UMWWindow/budget_pitfall.py` (deterministic, `out_pitfall.txt`).

---

## 1. The scientific question

Round 96b showed random divisor-covers of size `n^γ` cover a vanishing fraction
for `γ < 1/2`. Two readings:
* **F (fundamental):** the covering *problem* is hard at `γ<1/2` — no family works.
* **R (restriction):** it is an artifact of *uniform random sampling*; a
  structured or restricted family (Kelley–Meka, thinning, design) could beat it.

The catalog has `BernoulliSprinkling.lean` — the sprinkling/thinning + k-th-root
trick as a **proven** operator on product measures — the exact tool to test R.
The program had never used it for factoring.

## 2. A systematic family search — and an apparent 16× win

Screening seven construction archetypes (random, primes, lcm-prefix, products,
consecutive, multiples, high-smooth) at sizes below the random-failure threshold
(`γ ∈ {0.40,0.45,0.48}`, n=2000–3000), the **`lcm-prefix`** family
(`S = {lcm(1..j₁),…,lcm(1..j_k)}`) appeared to crush random:

| γ | lcm-prefix | random |
|---|---|---|
| 0.40 | 1875 | 113 |
| 0.45 | 1872 | 165 |
| 0.48 | 1891 | 192 |

A `k`-set of `lcm(1..j)` elements covering `[1..n]` at `γ=0.48` would be a
massive break. **It was too good — which is the tell.**

## 3. The catch: it violates the magnitude budget

The whole difficulty of the UMW divisor-cover problem is the **budget**
`M = exp(n^γ)`: every cover element must be `≤ exp(n^γ)`. But `lcm(1..j) ~ exp(j)`,
and the "beating" family used `j` up to 200 — i.e. elements `~exp(200)`, while
the budget at `γ=0.4, n=3000` is `exp(3000^{0.4}) = exp(24.6) ≈ 5×10¹⁰`. The
family was operating **~exp(175) beyond the budget**.

Enforcing the budget (`j ≤ n^γ`):

| γ | lcm-prefix (≤ M) | random (≤ M) |
|---|---|---|
| 0.40 | 24 | 124 |
| 0.48 | 46 | 235 |

> **The 16× win evaporates.** One budget-legal `lcm(1..j)` element covers exactly
> `[1..j]` with `j ≤ n^γ`, i.e. `n^γ` indices — far fewer than random achieves
> at the same budget.

## 4. The reusable guard

This is the **second** time a budget escape produced a false positive in this
investigation (the first: round 96c's retracted "complete cover at γ=0.36",
`max(S)=384151 > M=65816`). The pattern is now explicit and codified:

> **Any claim that a divisor-cover family "beats random" must enforce
> `max(element) ≤ exp(n^γ)`. Without it, the comparison is meaningless: the
> easiest construction (an un-budgeted lcm) looks like a breakthrough while
> actually ignoring the problem's only hard constraint.**

This complements the record's existing rule (5) ("never trust a test that has
never failed") with a factoring-specific instance: *never trust a coverage
comparison that does not check the magnitude budget.* The other families
(smooth, consecutive, multiples, primes) also failed to beat budgeted random, and
several (smooth, multiples, primes) are *worse* than random — consistent with the
round-102/103c principle that structure concentrates differences.

## 5. Answer to the scientific question

> **Hypothesis F (fundamental) survives.** Across a systematic search of seven
> construction archetypes — with the budget enforced — **none beats uniform
> random** at divisor coverage below `γ=1/2`. Restriction/thinning (Kelley–Meka)
> has no purchase here, because the obstruction is a property of the *covering
> problem* (rough-semiprime indivisibility, round 103c), not of the sampler.

## 6. Honest scope

* **No exponent beaten.** The one apparent breakthrough was a budget escape,
  caught and reproduced as a guard.
* **New:** (a) the systematic family search — **no budget-legal family beats
  random** (evidence for F); (b) the **budget-escape pitfall** as a codified,
  reproducible methodology guard (second occurrence; generalizes rule (5)).
* **Not claimed:** a proof that no cover exists. Two independent walls (96b
  residue, 103c semiprime) plus this family search all point at `γ = 1/2`; the
  Umans–Wang conjecture is exactly this and remains open.