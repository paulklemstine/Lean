# Computational evidence for the MA-1 effectivity claim (exp 509 re-check)

All numbers below were produced by `evidence/exp509_check.py` (a plain sieve of Eratosthenes
up to `2^24 = 16 777 216` plus a Simpson-rule evaluation of `Li(x) = ∫₂ˣ dt/log t`).
**Status: numerical exploration, not machine-verified.**  The Lean file
`Catalog/Bridges/Ma1EffectiveEquidistribution.lean` proves only the *deductive* layer: what
an `ε`-equidistribution certificate implies.  The measurements below are what motivates
taking `ε ≈ 4.5 · 10⁻⁴` as the hypothesis at `x = 2³⁰`.

## 1. Maximal relative deviation `max_a |π(x;m,a) − Li(x)/φ(m)| / (Li(x)/φ(m))`

| m  | φ(m) | x = 2²⁰  | x = 2²²  | x = 2²⁴  |
|----|------|----------|----------|----------|
| 3  | 2    | 0.002034 | 0.001296 | 0.000683 |
| 4  | 2    | 0.002838 | 0.000830 | 0.000670 |
| 5  | 4    | 0.002205 | 0.001222 | 0.000635 |
| 7  | 6    | 0.002740 | 0.001580 | 0.000674 |
| 8  | 4    | 0.003958 | 0.001789 | 0.001213 |
| 11 | 10   | 0.004226 | 0.002593 | 0.001464 |
| 31 | 30   | 0.010922 | 0.005411 | 0.003912 |

Sample raw counts (`x = 2²⁴`, `m = 3`): `π = {1 ↦ 538756, 2 ↦ 539114}`, target
`Li(x)/2 = 539124.1`.

Observations.

* **H3 (deviations shrink)** is confirmed here for **7/7** moduli and for both scale steps:
  every entry decreases left to right.  Extrapolating the observed `≈ 2^{-1/2}` per doubling
  of the exponent from `2²⁴` to `2³⁰` gives `≈ 0.00012–0.0002` for the small moduli and
  `≈ 0.0007` for `m = 31`, bracketing the reported `0.000446`.
* The deviation scale is `≍ √x / (Li(x)/φ(m))`, i.e. square-root cancellation, as the
  Riemann-hypothesis heuristic predicts; nothing in the data suggests a systematic bias.

## 2. Worst class per modulus (H2)

| m  | worst class at 2²⁰ | 2²² | 2²⁴ | stable? |
|----|--------------------|-----|-----|---------|
| 3  | 1 | 1 | 1 | yes |
| 4  | 1 | 1 | 1 | yes |
| 5  | 4 | 4 | 1 | no  |
| 7  | 2 | 1 | 4 | no  |
| 8  | 1 | 1 | 1 | yes |
| 11 | 3 | 5 | 8 | no  |
| 31 | 1 | 17| 20| no  |

So at these (smaller) scales the stable set is `{3, 4, 8}`, a subset of the reported
`{3, 4, 7, 8, 11}` at `x = 2³⁰`; the instability of `m = 5, 31` is reproduced.  This is a
*counterexample hunt against reading H2 as a law*: worst-class identity is not a stable
invariant of the modulus.  The Lean file replaces the empirical dichotomy with the exact
one it can only ever be (`worst_class_stable_of_gap`): the worst class is stable precisely
when the top-two gap exceeds twice the drift of the deviation field between the two scales.
For `m = 3` the two classes differ by `358` counts at `2²⁴` against a drift of order the
deviations themselves, whereas for `m = 31` the top two classes differ by `8` counts out of
`36 000` — a genuine near-tie, exactly the regime in which switching is forced to be
possible.

## 3. The effective cap constant

With `capConst ε = (4/3)·(1+ε)/(1−ε)`:

| ε        | capConst ε | relative perturbation |
|----------|------------|-----------------------|
| 0        | 1.3333333  | 0        |
| 0.000446 | 1.3345232  | 0.000892 |
| 0.001    | 1.3360027  | 0.002002 |
| 0.003912 (`m = 31` at 2²⁴) | 1.3438050 | 0.00785 |

Only the first three significant figures survive at `ε = 0.000446`
(`1.33452… → 1.33`), and the perturbation `0.0892 %` is below `0.1 %` but **above** the
`0.05 %` figure quoted in the mission brief — the brief appears to compare `ε` itself
against the cap rather than the two-sided transfer ratio `(1+ε)/(1−ε)`, which costs a factor
`2` (`0.0446 % → 0.0892 %`).  The Lean statement
`capConst_exp509_rel_error` certifies the honest two-sided bound `< 0.1 %`, and
`ratio_bound_sharp` shows the factor `2` cannot be removed.

## 4. OEIS

The per-class count sequences are the standard prime-counting-in-progressions data
(e.g. `π(x; 4, 3) − π(x; 4, 1)`, the Chebyshev bias, OEIS A007350/A051024 for the sign
changes).  No new integer sequence is claimed here.

## 5. The information price, linear vs quadratic (cycles 3–6)

All four numbers in this table are **theorems**, not measurements: each is the value of an
explicit bound at `ε = 0.000446`, machine-checked in the files named alongside.

| quantity | bound | at `ε = 0.000446` | Lean name |
|---|---|---|---|
| per-scale price, linear envelope | `2ε/(1−ε)` | `< 9·10⁻⁴` nats | `exp509_kl_le` (`Ma1EffectiveEntropy`) |
| total over all dyadic scales, halving certificates | `4ε₀/(1−ρ)` | `< 3.57·10⁻³` nats | `exp509_total_information_price_le` (`Ma1EffectiveTotalPrice`) |
| per-scale price, quadratic envelope | `(2ε/(1−ε))²` | `< 8·10⁻⁷` nats | `exp509_kl_quadratic` (`Ma1EffectiveQuadraticPrice`) |
| total, quadratic envelope | `16ε₀²/(1−ρ²)` | `< 4.3·10⁻⁶` nats | `exp509_quadratic_total_price` (`Ma1EffectiveQuadraticPrice`) |

The quadratic exponent cannot be improved: a saturated two-class certificate costs at least
`ε²/4` (`kl_two_class_ge`, `quadratic_price_exponent_sharp` in `Ma1EffectiveQuadraticSharp`),
so the price of a saturated certificate lies between `ε²/4` and `16ε²` and no cubic bound
holds (`no_cubic_price_bound`).  For orientation, the exact two-class value
`((1+t)log(1+t) + (1−t)log(1−t))/2` at `t = 1/4` is `0.0316…`, comfortably inside the proved
window `[t²/4, 16t²] = [0.0156, 1]`; this last arithmetic is exploratory and is not part of
any Lean statement.
