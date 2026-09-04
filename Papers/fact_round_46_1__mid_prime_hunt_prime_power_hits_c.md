# Computational evidence — prime-power hits and the smoothness budget (exp 505 arc)

All numbers below were produced by `#eval` against the Lean definitions that the
theorems are stated in (`PrimePowerBudget.smoothCount`, `.hitCount`,
`.bigOmega`, `Sm`), i.e. by evaluating the same objects the proofs talk about.
They are exploratory measurements: the *claims* in the `.lean` files are proved,
not sampled.

## 1. The exact-rescaling identity `hit(p²) = Ψ_B(x/p²)`

| B | p | x | Ψ_B(x) | hit(p²) | Ψ_B(x/p²) |
|---|---|-----|--------|---------|-----------|
| 13 | 2 | 100 | 62 | 22 | 22 |
| 13 | 2 | 1000 | 242 | 111 | 111 |
| 13 | 2 | 10000 | 733 | 387 | 387 |
| 13 | 3 | 1000 | 242 | 66 | 66 |
| 13 | 5 | 1000 | 242 | 32 | 32 |
| 13 | 13 | 10000 | 733 | 42 | 42 |
| 50 | 2 | 10000 | 2463 | 1003 | 1003 |
| 100 | 2 | 10000 | 3716 | 1352 | 1352 |

Agreement in every case; proved in general as
`PrimePowerBudget.hitCount_eq_smoothCount` / `hitCount_primeSq`.

## 2. Hit fraction depends on the tight-`u` parameter

`u ≈ log x / log B`, hit fraction = `hit(p²)/Ψ_B(x)` (per mille).

| B | p | x | Ψ_B(x) | hit(p²) | fraction | u (approx.) |
|---|---|------|--------|---------|----------|-------------|
| 7 | 2 | 10³ | 141 | 75 | 0.531 | 4.5 |
| 7 | 2 | 10⁴ | 338 | 205 | 0.606 | 6.5 |
| 7 | 2 | 10⁵ | 694 | 458 | 0.659 | 8.0 |
| 13 | 2 | 10³ | 242 | 111 | 0.458 | 3.0 |
| 13 | 2 | 10⁴ | 733 | 387 | 0.527 | 4.3 |
| 13 | 2 | 10⁵ | 1848 | 1078 | 0.583 | 5.3 |
| 50 | 2 | 10⁵ | 9639 | 4322 | 0.448 | 3.2 |
| 13 | 3 | 10⁵ | 1848 | 767 | 0.415 | 5.3 |
| 13 | 13 | 10⁵ | 1848 | 182 | 0.098 | 5.3 |

The fraction is *not* a constant of the pool: it moves with both `u` and `p`,
and at fixed `x` it drops sharply as `p` grows.  That non-constancy is exactly
what a prime-power feature can contribute over a squarefree-hit feature, and the
proved statements `uParam_hit_le` and `shift_antitone_in_B` give its mechanism:
the hit costs `2 log p / log B` of budget, more at smaller `B`.

## 3. Graded valuation spectrum (telescoping)

`B = 13`, `x = 10⁴`, `p = 3`, counts of smooth `v` with `v₃(v) = j`:

| j | direct count | Ψ(x/3^j) − Ψ(x/3^(j+1)) |
|---|--------------|--------------------------|
| 0 | 289 | 289 |
| 1 | 188 | 188 |
| 2 | 116 | 116 |
| 3 | 70 | 70 |

Proved as `PrimePowerBudget.gradeCount_eq_sub`.

## 4. Budget decomposition `∑ Ω(v) = ∑_p ∑_j hit(p^j)`

| B | x | ∑ Ω over pool | ∑_{p ≤ B} ∑_{j≥1} hit(p^j) |
|---|-----|---------------|-----------------------------|
| 13 | 200 | 324 | 324 |
| 7 | 5000 | 1535 | 1535 (rescaled form ∑ Ψ(x/p^j)) |
| 13 | 20000 | 6074 | 6074 (rescaled form) |

Proved as `sum_bigOmega_eq_sum_hitCount` and `sum_bigOmega_eq_sum_smoothCount`.

## 5. Exactly solvable case `B = 2`

`Ψ₂(x) = ⌊log₂ x⌋ + 1` checked at `x = 2^k + 3` for `k ≤ 7` (all agree), and
`hit(4) + 2 = Ψ₂(x)` at `x ∈ {10, 100, 1000, 10000}` giving `(4,4), (7,7),
(10,10), (14,14)`.  Proved as `smoothCount_two` and `hitCount_two_four`.

## 6. Abundance check

`B = 7`: primorial `P₇ = 210`, `π(7) = 4`.  With `m = 2`, `P₇² = 44100 ≤ x`, the
proved bracket `smoothCount_bracket` reads `81 ≤ Ψ₇(44100) ≤ (⌊log₂ 44100⌋+1)^4
= 16^4 = 65536`; the measured value is `547`.  Both bounds hold and have the
same exponent `π(B) = 4`, confirming the degree of the polynomial-in-`log x`
growth even though neither constant is tight.

## 7. Counterexample hunt

* Searched for a modulus `m` where `hit(m) ≠ Ψ_B(x/m)` with `m` *not* `B`-smooth:
  found immediately (e.g. `B = 5`, `m = 7`, `x = 100`: `hit = 0`, `Ψ(14) = 10`),
  which is why smoothness of `m` is a hypothesis of `hitCount_eq_smoothCount`.
* Searched for a squarefree-hit collision at `B = 2` (predicted by
  `exists_sqfHits_collision_two`): `v = 4`, `w = 8` both have squarefree-hit
  vector `{2}` while `Ω` differs.
* No counterexample was found to any statement that is proved in the `.lean`
  files; where a naive version failed (unsmooth modulus, `x < p²` in the
  real-valued budget bound) the hypothesis is present in the theorem.

## 8. OEIS

`Ψ₂(x)` is `⌊log₂ x⌋ + 1` (A000523 shifted); the smooth-count sequences
`Ψ₁₃(10^k) = 62, 242, 733, 1848, …` are counts of 13-smooth numbers, the
finite-`B` analogues of A080197 (13-smooth numbers).  No new sequence is claimed.
