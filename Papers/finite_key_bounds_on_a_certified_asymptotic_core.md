# Computational Evidence — Finite-Key BB84 on a Certified Asymptotic Core

All numbers below were obtained with **exact rational arithmetic** (Python
`fractions.Fraction` on the exact integers `N = 2^(a+c)·a^(2a)·c^(2c)` and
`D = (a+c)^(2(a+c))`), with floating point used only to *display* the results.
Every claim that survives into the Lean files is re-derived there from integer
certificates; nothing in the formal chain depends on these computations.

## 1. The rational core at `Q = 11 %`

`N/D = 2^100 · 11^22 · 89^178 / 100^200 = 1.011718805686342…` (823-digit integers).

| bound on `log(N/D)` | value | rate `r = log(N/D)/100` (nats) | in bits |
|---|---|---|---|
| naive `1 − 1/x` (catalog) | 0.0115647 | 1.15647·10⁻⁴ | 1.66843·10⁻⁴ |
| **Padé `2(x−1)/(x+1)`**   | 0.0116319 | 1.16319·10⁻⁴ | **1.67811·10⁻⁴** |
| exact                     | 0.0116507 | 1.16507·10⁻⁴ | 1.68084·10⁻⁴ |

The Padé bound recovers 94 % of the deficit of the naive bound.  The certified
rational constant used in Lean is `1/6000 = 1.66667·10⁻⁴` bits per sifted bit:
the Padé bound clears it by 0.7 %, the naive bound only by 0.1 % (too tight to be
robust against the `log 2` rounding), which is why the Padé lemma was proved.

## 2. Dyadic certificates (the parameter table)

For each QBER `a/100` the largest `m` with `2^m·D ≤ N` was searched exhaustively:

| `Q` | `100·r_bits` (exact) | certified `m` | `m+1` valid? | `rho = m/100` |
|---|---|---|---|---|
| 1 %  | 83.8414 | 83 | no | 0.83 |
| 2 %  | 71.7119 | 71 | no | 0.71 |
| 5 %  | 42.7206 | 42 | no | 0.42 |
| 8 %  | 19.5642 | 19 | no | 0.19 |
| 10 % |  6.2009 |  6 | no | 0.06 |
| 11 % |  0.0168 |  0 | — | (dyadic scheme degenerates; Padé used) |

Each certificate is therefore *sharp* for the given denominator.

## 3. Break-even block sizes (`C = 10`, `ε = 2⁻⁵⁰`, `ln(1/ε) = 50 log 2 = 34.657`)

Break-even is `n* = C²·ln(1/ε)/rho²`; half the asymptotic rate is recovered at
`4n*`.

| `Q` | `rho` (bits) | `n*` | `4n*` | Lean-certified block size |
|---|---|---|---|---|
| 1 %  | 0.83   | 5.03·10³  | 2.01·10⁴  | `n ≥ 2.5·10⁴` |
| 5 %  | 0.42   | 1.96·10⁴  | 7.86·10⁴  | `n ≥ 10⁵` |
| 8 %  | 0.19   | 9.60·10⁴  | 3.84·10⁵  | `n ≥ 4·10⁵` |
| 10 % | 0.06   | 9.63·10⁵  | 3.85·10⁶  | `n ≥ 4·10⁶` |
| 11 % | 1/6000 | 1.25·10¹¹ | 4.99·10¹¹ | `n ≥ 10¹²` |

Seven orders of magnitude separate the `1 %` and `11 %` rows although the
asymptotic rates differ by only a factor `5·10³` — this quadratic amplification is
what `breakeven_ge_of_gap` formalizes.

## 4. Threshold-gap law: numerical check

`r'(Q) = −2 log((1−Q)/Q)`, so near the certified threshold `Q* ∈ (0.1100, 0.1101)`
the rate falls at `6.01` bits per unit QBER.  Predicted break-even from the gap
`Q* − Q`:

| gap `δ` | predicted `n*` = `C²ln(1/ε)/(6.01δ)²` |
|---|---|
| 10⁻³ | 9.6·10⁷ |
| 10⁻⁴ | 9.6·10⁹ |
| 2.8·10⁻⁵ (at `Q = 0.11`) | 1.2·10¹¹ |

The direct computation of row 3 gives `1.25·10¹¹`, agreeing to 5 %.  The proved
constant in `breakeven_ge_of_gap` is `44 ≥ (2 log 9/log 2)² = 40.2`, a certified
over-estimate obtained from `log 3 ≤ 2 log 2 − 1/4` and `log 2 ≥ 0.693`.

## 5. Counterexample hunt

* **Is the catalog's privacy-amplification hypothesis satisfiable?**  For a
  distribution on `2^ℓ` points, Cauchy–Schwarz forces `∑ p² ≥ 2^{-ℓ}`.  Sampling
  random distributions for `ℓ = 1,…,10` never produced `∑ p² < 2^{-ℓ}`, and the
  inequality is provable — so the catalog hypothesis `∑ p² ≤ 2^{-k}` has **no**
  instances when `ℓ < k`.  This is now the theorem
  `catalog_collision_hypothesis_vacuous`, and the repaired hypothesis
  `∑ p² ≤ 2^{-ℓ} + 2^{-k}` is witnessed by the uniform distribution.
* **Is `1/6000` safe as the rational rate at `Q = 11 %`?**  `1/5900 = 1.6949·10⁻⁴`
  exceeds the Padé bound `1.67811·10⁻⁴`, so `1/5900` is *not* certifiable by this
  route; `1/5960 = 1.6779·10⁻⁴` is the last denominator that clears it.  `1/6000`
  was chosen to leave margin.
* **Sign criterion.**  For `n` in `{1, 10, 10², …, 10¹⁵}` at `Q = 11 %` the sign of
  `n·rho − C√(n ln(1/ε))` flips exactly once, between `10¹¹` and `10¹²`,
  matching `finiteKey_nonpos_below_1e11` and `finiteKey_half_rate_above_1e12`.

No counterexample to any formalized statement was found.

## 6. Cycle 2 — hybrid dyadic–Padé certificate (exact rational data)

Write `N = 2^(a+c)·a^(2a)·c^(2c)`, `D = (a+c)^(2(a+c))`, `y = N/(2^m·D)`.

| `Q` | optimal `m` | `y = N/(2^m D)` | dyadic bits | hybrid bits | exact bits |
|---|---|---|---|---|---|
| 10/100 | 6 | 1.1494002612… | 0.060000 | 0.0620043 | 0.0620088 |
| 11/100 | 0 | 1.000168… | 0.000000 | 0.000167811 | 0.000168084 |

The hybrid residual at `Q = 10 %` is `4.5·10⁻⁶` bits against the dyadic
`2.0·10⁻³`: a 440-fold error reduction, consistent with the cubic Padé residual
`O((y−1)³)`.  At `Q = 11 %` the optimal dyadic exponent is `m = 0`, so the hybrid
degenerates to pure Padé — the near-threshold regime is Padé-dominated.  The
certifying comparison at `Q = 10 %`,
`11493·2^6·100^200 ≤ 10000·2^100·10^20·90^180`, is a 400-digit integer identity
discharged by kernel `decide`.

## 7. Cycle 3 — two-sided break-even law

Entropy derivative `h'(p) = log((1−p)/p)`, decreasing:

| interval | min slope (nats) | certified rational bound |
|---|---|---|
| `[Q, Q*]`, `Q* ≤ 1/5` | `log 4 = 1.3863` | `≥ 2 log 2` (used for the upper break-even bound) |
| `[1/10, 1/2]` | `log 9 = 2.1972` | `≤ 2.2726` (used for the lower break-even bound) |

Resulting bracket `C²ln(1/ε)/(44δ²) ≤ n*(Q) ≤ C²ln(1/ε)/(9δ²)`, ratio `4.9`.
At `Q = 1/10`, `δ > 10⁻²`, `C = 10`, `ε = 2⁻⁵⁰`: the upper bound evaluates to
`100·50·log 2/(9·10⁻⁴) < 3.86·10⁶`, so `n = 4·10⁶` suffices — in agreement with
the independently certified hybrid row of cycle 2, which reaches a positive key
at `n = 3.7·10⁶`.  The numbers in this section are exact rational/analytic
estimates used to choose the constants; the statements themselves are what the
Lean files verify (`breakeven_two_sided_law`, `breakeven_ten_percent_upper`).
