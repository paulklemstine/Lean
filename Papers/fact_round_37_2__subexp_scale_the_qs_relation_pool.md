# Computational Evidence

All numbers below were produced in this session (plain Python, exact integer /
`decimal` arithmetic where relevant). Items marked **[Lean]** are additionally
machine-checked by the Lean kernel in `Catalog/Shared/`; items marked
**[numeric]** are floating/decimal computations that are *not* part of the formal
development and are reported only as evidence.

## 1. Local hit counts of the sieve polynomial `x² − N` (small primes)

For each odd prime `p` we counted, for every residue `a` of `N`, the number of
`x ∈ Z/p` with `x² ≡ a`.

| p | observed hit counts | # nonzero admissible `a` | (p−1)/2 | Σ hit counts |
|---|---|---|---|---|
| 7 | {0,1,2} | 3 | 3 | 7 |
| 11 | {0,1,2} | 5 | 5 | 11 |
| 13 | {0,1,2} | 6 | 6 | 13 |
| 17 | {0,1,2} | 8 | 8 | 17 |
| 19 | {0,1,2} | 9 | 9 | 19 |
| 31 | {0,1,2} | 15 | 15 | 31 |

The last column is *exactly* `p` in every case: the mean hit count per period is
exactly `1`, the random-integer value. Half the moduli are excluded, and the
surviving half is hit exactly twice. This is the phenomenon proved in general as
`QSRelationPool.expected_hits_eq_one`, `root_count_of_isSquare`,
`root_count_of_not_isSquare`, `relation_pool_random_equivalent` **[Lean]**, with
`p = 7, 11, 13` instances also checked by `decide` in the Lab Notes section of
`Catalog/Shared/QSRelationPoolRandom.lean` **[Lean]**.

No counterexample hunt was needed here: the identity is exact and the general
proof is formal.

## 2. Sparsity of the smooth pool `Ψ(x, B)` versus the exponent-vector bound

Exact counts of `B`-smooth integers in `[1,x]` against the proved bound
`(⌊log₂ x⌋ + 1)^{π(B)}` (`SmoothSparsity.smoothPool_card_le` **[Lean]**):

| B | x | Ψ(x,B) | π(B) | bound | Ψ / bound |
|---|---|---|---|---|---|
| 3 | 30 | 12 | 2 | 25 | 0.48 |
| 5 | 100 | 34 | 3 | 343 | 0.099 |
| 7 | 1000 | 141 | 4 | 10000 | 0.0141 |
| 13 | 10000 | 733 | 6 | 7 529 536 | 9.7e−05 |

The bound holds in all tested cases (as it must) and is loose by a factor that
grows with `π(B)` — it is a *sparsity* statement, not an asymptotic count. Its
role is to show unconditionally that at fixed `B` the pool is polylogarithmic in
`x`, which forces `B → ∞` and hence subexponential (not polynomial) cost.

## 3. Dickman ρ versus the leading term `L(u) = exp(−u(ln u + ln ln u − 1))`

**[numeric]** ρ was computed by the interval power-series method (expansion of ρ
about the midpoints `k+1/2`, `decimal` arithmetic at 80–120 digits, 80–110 series
terms). Correctness anchor: the computed `ρ(2) = 0.3068528194400547` agrees with
the closed form `1 − ln 2 = 0.3068528194400547` to full displayed precision.
(A naive global trapezoid recursion was tried first and was rejected: it produced
*negative* values of ρ beyond `u ≈ 9`, i.e. it is dominated by cancellation
error. This is exactly the kind of failure the assignment's ledger warns about,
so the series result is reported instead, with the `ρ(2)` anchor as the check.)

| u | ρ(u) | L(u) | L/ρ | ln L / ln ρ |
|---|---|---|---|---|
| 2 | 3.069e−01 | 3.845e+00 | 12.5 | — |
| 4 | 4.911e−03 | 5.775e−02 | 11.8 | 0.536 |
| 6 | 1.965e−05 | 2.613e−04 | 13.3 | 0.761 |
| 8 | 3.232e−08 | 5.082e−07 | 15.7 | 0.840 |
| 10 | 2.770e−11 | 5.258e−10 | 19.0 | 0.879 |
| 12 | 1.420e−14 | 3.293e−13 | 23.2 | 0.901 |
| 14 | 4.761e−18 | 1.362e−16 | 28.6 | 0.916 |
| 14.75 | 2.153e−19 | 6.674e−18 | 31.0 | 0.920 |
| 20 | 2.462e−29 | 1.365e−27 | 55.5 | 0.939 |
| 40 | — | — | 602 | 0.961 |

**Correction to the assignment's framing.** The leading term is *never* accurate
in absolute terms in this range: `L/ρ` is `≈ 12` at `u = 2` and **increases**
monotonically with `u` (31 at `u = 14.75`, 602 at `u = 40`). What does converge
is the *logarithmic* accuracy: `ln L / ln ρ` rises through `0.92` exactly at
`u ≈ 14.75`. So the pre-stated "leading-term Dickman becomes valid at
`u ≈ 14.75`" must be read as a log-scale criterion (≈ 92 % agreement in the
exponent); read as an absolute-ratio criterion it is false, and the ratio
diverges. The formal counterpart proved here is the small-`u` end of this:
`DickmanFinite.leading_term_overestimates` and
`DickmanFinite.dickmanLead_two_gt_nine_mul_rho` (`L(2) > 9 ρ(2)`) **[Lean]**.

A second-order model `√(2πu)·exp(u(ln ln u − 1)/ln u)` for the ratio gives 9.1 at
`u = 14.75` versus the true 31.0, and 434 versus 602 at `u = 40`: it captures the
growth but not yet the constant — a candidate future direction.

## 4. The finite-size correction `ln ln v / ln v`

**[numeric]**

| ln v | 12 | 14 | 16 | 18 | 20 |
|---|---|---|---|---|---|
| ln ln v / ln v | 0.207 | 0.189 | 0.173 | 0.161 | 0.150 |

Over the experimental window (value sizes of 12–20 nats) the correction stays in
`[0.15, 0.21]`, bracketing the measured 17–20 % shortfall of the empirical smooth
density against ρ(u), and it decays only logarithmically. Formal counterparts:
`DickmanFinite.finiteCorrection_window` (proved bracket `[0.1, 0.25]` on
`exp 12 ≤ v ≤ exp 20`), `finiteCorrection_antitoneOn`, and
`finiteCorrection_tendsto_zero` **[Lean]**.

## 5. OEIS

The integer sequences that appear (`#{x : x² ≡ a mod p}` and `(p−1)/2`) are
classical and were not searched further; the smooth-count column
`Ψ(x, 3) = 12, Ψ(x, 5) = 34, …` are values of the standard smooth-number counting
function (A003586 etc. list the 3-smooth numbers themselves). Nothing in the
project depends on an OEIS identification.
