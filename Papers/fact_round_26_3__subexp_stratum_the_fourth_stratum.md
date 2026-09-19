# Computational Evidence — SUBEXP-STRATUM (round-26 #3 follow-up)

All computations below are exploratory scratch calculations used to *choose* the
statements; the certified content is the Lean code in
`Catalog/Algebra/SubexpStratumDickmanTail.lean` and
`Catalog/Algebra/SubexpStratumSecondMoment.lean`, which compiles with no `sorry`
and no non-standard axioms.  Numbers here are **not** themselves verified.

## 1. Dickman `ρ` versus the leading-term surrogate

`ρ` computed by Euler integration of `u ρ'(u) = -ρ(u-1)` with step `10^{-4}`
(the same scheme as the experiment); surrogate
`L(u) = exp(-u(log u + log log u - 1))`.

| u | ρ(u) numeric | L(u) | L/ρ | rigorous bound proved in Lean |
|---|---|---|---|---|
| 2 | 0.30685 | 3.8448 | 12.5 | `ρ 2 ≤ 1 - log 2 = 0.30685` (hypothesis, catalog closed form) |
| 3 | 0.04862 | 0.56103 | 11.5 | `ρ 3 ≤ (1-log 2)/3 = 0.10228` |
| 4 | 0.00492 | 0.05775 | 11.7 | `ρ 4 ≤ (1-log 2)/12 = 0.02557` |
| 5 | 0.000362 | 0.004398 | 12.2 | `ρ 5 ≤ 1/120 = 0.00833` |
| 6 | 0.0000250 | 0.000261 | 10.3 | `ρ 6 ≤ 1/720 = 0.00139` |

The certified overshoot is therefore a factor `> 5` at `u = 3`
(`5 · 0.10228 = 0.5114 < 0.540 < L(3) = 0.5610`) and strict at `u = 4`
(`0.02557 < 0.038 < L(4) = 0.05775`).  The gap between `5` and the measured
`11.5` is entirely the slack in the rigorous one-step tail bound, not in the
surrogate.

Numerical inputs verified for the Lean numerics:
`log 3 = 1.09861 < 1.1` (checked through `2.7182818283 · 1.01^10 = 3.00267 > 3`),
`0.95^12 = 0.54036 < exp(-0.6) = 0.54881`, `0.9^31 = 0.038152 < exp(-3.1) = 0.045049`.

## 2. Hit pattern of `x^2 - N` mod p — moments and pair correlation

`h_p(a) = #{x mod p : x² ≡ a}`; brute force over all residues.

| p | ∑ h | ∑ h² | ∑ (h-1)² | p-1 | pair corr. `∑_a h(a)h(a+c)`, all `c ≠ 0` | msd = (1-1/p) |
|---|---|---|---|---|---|---|
| 3 | 3 | 5 | 2 | 2 | {2} | 0.667 |
| 5 | 5 | 9 | 4 | 4 | {4} | 0.800 |
| 7 | 7 | 13 | 6 | 6 | {6} | 0.857 |
| 11 | 11 | 21 | 10 | 10 | {10} | 0.909 |
| 13 | 13 | 25 | 12 | 12 | {12} | 0.923 |
| 17 | 17 | 33 | 16 | 16 | {16} | 0.941 |
| 19 | 19 | 37 | 18 | 18 | {18} | 0.947 |
| 23 | 23 | 45 | 22 | 22 | {22} | 0.957 |

Three exact patterns, all three now theorems: `∑ h = p`, `∑ (h-1)² = p-1`
(so the normalised dispersion is `1 - 1/p`, *increasing* to `1`, never
stabilising), and `∑_a h(a)h(a+c) = p-1` independent of `c ≠ 0` — the pair
correlation of the random model.  The zero-lag/nonzero-lag difference is exactly
`(2p-1) - (p-1) = p`.

OEIS: the sequence `∑ h² = 2p-1` over odd primes (5, 9, 13, 21, 25, 33, …) is
just `2p-1` and was not pursued further; no new sequence arises.

## 3. Counterexample hunt

* `∑_a h(a) h(a+c) = p-1` was tested for **every** nonzero lag `c` at each prime
  above (not a sample): no exception.
* The claim "`L(u) > ρ(u)` for all `u ≥ 2`" survives numerically through `u = 6`
  but is only certified here at `u = 3, 4`, because at `u ≥ 5` the rigorous tail
  bound `1/⌊u⌋₊!` is weaker than `L(u)` (e.g. `1/120 = 0.0083 > L(5) = 0.0044`).
  This is a genuine limitation of the bound, stated honestly rather than
  papered over.

## 4. The toy cost model and its floor

Cost exponent `f(b) = b + (L/b - 2) log 2` (from `C(b) = e^b/ρ(L/b)` and the
rigorous `1/ρ ≥ ⌊u⌋₊! ≥ 2^{⌊u⌋₊-1}`), minimised numerically against the proved
floor `2√(L log 2) - 2 log 2`:

| L | min_b f(b) | proved floor | optimal b |
|---|---|---|---|
| 20 | 6.0603 | 6.0603 | 3.72 |
| 50 | 10.3878 | 10.3878 | 5.89 |
| 100 | 15.2648 | 15.2648 | 8.33 |
| 200 | 22.1619 | 22.1619 | 11.77 |

The floor is *attained* (AM–GM is tight at `b = √(L log 2)`), so the
`L[1/2]`-shaped lower bound `exp(2√(L log 2) - 2 log 2)` proved in
`DickmanUpper.cost_floor` is the exact minimum of the model, not a lossy bound.

## 5. The sharpened floor from `n! ≥ (n/e)^n`

Using the Stirling-type bound instead of `2^{n-1}` the model exponent is
`g(b) = b + (L/b)(log(L/b) - 1)`; the Legendre-transform floor
`√(2 L log L) - √L` (theorem `cost_floor_model_sqrt_log`) is compared with the
numerically minimised exponent:

| L | min_b g(b) | proved sharp floor `√(2L log L) - √L` | earlier `2^n` floor |
|---|---|---|---|
| 10 | 3.629 | 3.624 | 3.879 |
| 100 | 20.901 | 20.349 | 15.265 |
| 1000 | 89.533 | 85.917 | 51.269 |

The sharp floor is valid (always below the minimum) and within 4 % of it at
`L = 1000`, whereas the `2^n` floor loses a factor `1.7` in the exponent there.
(The `L = 10` row shows the `2^n` floor above the sharp one only because the two
floors bound *different* model exponents.)
