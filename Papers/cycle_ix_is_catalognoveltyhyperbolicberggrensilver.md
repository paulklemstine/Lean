# Computational evidence for cycle X (`Catalog/NumberTheory/BerggrenSilverExtremal.lean`)

All data below were produced by direct enumeration of the Berggren tree in Euclid-seed
coordinates, with the three moves

```
B₁ : (m,n) ↦ (2m−n, m)      B₂ : (m,n) ↦ (2m+n, m)      B₃ : (m,n) ↦ (m+2n, n)
```

starting from the root seed `(2,1)`.  Every claim below that is used in the paper is
subsequently *proved* in Lean; the tables only guided the choice of statement.

## 1. Extremality of the Pell spine at each depth (conjecture I2)

`λ = 1+√2`, `Φ(m,n) = m + (√2−1)n`, and `mspine k` is the pure-`B₂` node at depth `k`.

| k | max m at depth k | (mspine k).1 | max Φ | λ^{k+1} | # maximisers of m | max m / λ^{k+1} |
|---|---|---|---|---|---|---|
| 0 | 2 | 2 | 2.4142 | 2.4142 | 1 | 0.828427 |
| 1 | 5 | 5 | 5.8284 | 5.8284 | 1 | 0.857864 |
| 2 | 12 | 12 | 14.0711 | 14.0711 | 1 | 0.852814 |
| 3 | 29 | 29 | 33.9706 | 33.9706 | 1 | 0.853680 |
| 4 | 70 | 70 | 82.0122 | 82.0122 | 1 | 0.853532 |
| 5 | 169 | 169 | 197.9949 | 197.9949 | 1 | 0.853557 |
| 6 | 408 | 408 | 478.0021 | 478.0021 | 1 | 0.853553 |
| 8 | 2378 | 2378 | 2786.0004 | 2786.0004 | 1 | 0.853553 |
| 10 | 13860 | 13860 | 16238.0001 | 16238.0001 | 1 | 0.853553 |
| 12 | 80782 | 80782 | 94642.0 | 94642.0 | 1 | 0.853553 |

Observations, all now theorems:

* `max Φ = λ^{k+1}` exactly, and the maximiser is the pure-`B₂` node — proved as
  `pot_eq_silver_iff`, with the quantitative off-spine gap `Φ ≤ λ^{k+1} − √2`
  (`reaches_pot_le_gap`).
* the maximum of `m` (and of the hypotenuse) is also attained *only* on the Pell spine —
  proved as `reaches_fst_eq_mspine`, `reaches_hypot_eq_mspine`; the underlying fact is the
  coordinatewise domination `reaches_le_mspine`.
* the limiting ratio is **0.8535533905…**, i.e. `(2+√2)/4`, **not** `1/√2 = 0.7071067…` as
  the cycle-IX conjecture I2 predicted.  Proved as `max_fst_ratio_tendsto` together with
  `max_fst_constant_ne`.  The Pell first coordinates `2, 5, 12, 29, 70, 169, …` are the
  even-index Pell numbers (OEIS A001542 / A000129 at even indices); the exact closed form
  is `mspine_binet`.

## 2. Rates of two `B₁`-free periodic paths with the same `B₂`-frequency (conjecture I1)

One period of `(B₂B₃)` is `(m,n) ↦ (4m+n, m)`; one period of `(B₂B₂B₃B₃)` is
`(m,n) ↦ (13m+6n, 2m+n)`.  Both words have middle-move frequency exactly `1/2`.

| word | node after 15 periods | depth | `log m / depth` |
|---|---|---|---|
| `(B₂B₃)^15` | `(5374978561, 1268860318)` | 30 | 0.74683 |
| `(B₂B₂B₃B₃)^15` | `(331110227445025052, …)` | 60 | 0.67235 |

The period matrices are `[[4,1],[1,0]]` (trace 4, det −1, Perron root `2+√5 = 4.2360…`)
and `[[13,6],[2,1]]` (trace 14, det 1, Perron root `7+4√3 = 13.9282… = (2+√3)²`).  Hence
the predicted rates are

```
½ log(2+√5) = 0.7218177…      ¼ log(7+4√3) = ½ log(2+√3) = 0.6584789…
```

and the observed ratios above approach them from above (the `O(1/j)` additive constant).
Both values are strictly between the two extreme rates `0` and `log(1+√2) = 0.8813735…`
of cycle IX.  Proved as `wordA_rate_tendsto`, `wordB_rate_tendsto`,
`rate_gammaB_lt_rate_alphaA`, `berggren_spectrum_two_interior_values`.

A crude rational separation, sufficient by itself to refute I1 and formalised first, is:
`m ≥ 2·4^j` after `2j` moves of the first word (rate `≥ log 2 = 0.6931`), while
`m ≤ 32·14^{j−1}` after `4j` moves of the second (rate `≤ log 14/4 = 0.6598`), the
invariant `6n ≤ m` being preserved by the second period map.

## 3. The family `(B₂B₃^b)^∞` and the accumulation of rates at `0`

One period of `(B₂B₃^b)` is `(m,n) ↦ (2m + (4b+1)n, m + 2bn)`, a matrix of trace `2+2b` and
determinant `−1`, so its Perron root is `ρ_b = (1+b) + √((1+b)²+1)` and the predicted rate
is `log ρ_b/(b+1)`.  Empirical rates after 40 periods:

| b | `log m / depth` after 40 periods | `log ρ_b/(b+1)` |
|---|---|---|
| 1 | 0.731199 | 0.721818 |
| 2 | 0.612359 | 0.606149 |
| 3 | 0.528290 | 0.523678 |
| 5 | 0.418325 | 0.415297 |
| 10 | 0.282813 | 0.281191 |

The `B₂`-frequency of the word is `1/(b+1)`, and the rates decrease to `0`; each is proved
exactly in `berggren_spectrum_infinite`.

## 4. Counterexample hunt

* Exhaustive search over all `3^k` nodes for `k ≤ 12` found **no** node off the Pell spine
  attaining `max Φ`, `max m`, or `max` hypotenuse: the maximiser count is `1` at every
  depth.  (Consistent with the proved uniqueness statements.)
* Exhaustive search over all 924 `B₁`-free words of length 12 with exactly six `B₂`'s gives
  `log m/|w|` ranging from `0.63700` (word `MMMMMRRRRRRM`) to `0.78841` (word
  `RMRMRMRMRMMR`), a spread of `0.1514`: at a fixed `B₂`-frequency the rate varies with the
  *arrangement* of the letters, as the two periodic families above predict.

## 5. Cycle XI: the two-parameter family `(B₂^a B₃^b)^∞` and density

One period of `(B₂^a B₃^b)` is the matrix `M^a R^b` with `M = [[2,1],[1,0]]`,
`R = [[1,2],[0,1]]`; its entries are Pell numbers, its determinant is `(−1)^a`, and its
trace is `T(a,b) = P_{a+1} + 2b P_a + P_{a−1}`.  For **odd** `a` the determinant is `−1`,
the first coordinate obeys `x_{j+2} = T x_{j+1} + x_j`, and the predicted rate is
`log σ(a,b)/(a+b)` with `σ = (T + √(T²+4))/2`.  Predicted rates:

| a \ b | 0 | 1 | 2 | 3 | 4 | 5 | 8 |
|---|---|---|---|---|---|---|---|
| 1 | 0.88137 | 0.72182 | 0.60615 | 0.52368 | 0.46249 | 0.41530 | 0.32149 |
| 3 | 0.88137 | 0.79495 | 0.70544 | 0.63078 | 0.56990 | 0.51989 | 0.41304 |
| 5 | 0.88137 | 0.82362 | 0.75547 | 0.69315 | 0.63882 | 0.59189 | 0.48482 |
| 9 | 0.88137 | 0.84672 | 0.80125 | 0.75588 | 0.71345 | 0.67459 | 0.57812 |
| 15 | 0.88137 | 0.85971 | 0.82953 | 0.79771 | 0.76648 | 0.73663 | 0.65723 |

The column `b = 0` is `log(1+√2) = 0.8813735…` for every odd `a`, confirming
`rateG_top` (`σ(a,0) = (1+√2)^a`).  Each row decreases to `0` as `b → ∞`, and the largest
one-step gap along a row shrinks with `a`: `0.15956` for `a = 1` but `0.03181` for
`a = 15` (both comfortably below the proved envelope `3 log 3/(a+b+1)`, e.g. `0.20599`
for `a = 15`).  This is exactly the discrete intermediate-value input of
`berggren_spectrum_dense`.

Direct simulation of the words confirms the predicted rates (the `O(1/j)` discrepancy is
the additive constant of the sandwich `1·σ^j ≤ m_j ≤ 3·σ^j`):

| (a,b) | `log m / |w|` after 30 periods | `log σ(a,b)/(a+b)` |
|---|---|---|
| (1,1) | 0.734326 | 0.721818 |
| (3,2) | 0.710888 | 0.705445 |
| (5,1) | 0.828014 | 0.823616 |
| (1,4) | 0.467366 | 0.462488 |

Consistency check: `(a,b) = (1,1)` reproduces the cycle-X value `½ log(2+√5)` of the
alternating path, and `(a,b) = (1,b)` reproduces the family `(B₂B₃^b)^∞` of
`berggren_spectrum_infinite`.
