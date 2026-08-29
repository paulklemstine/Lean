# Computational evidence — MA-1 effectivity sweep (Bridges cycle)

All numbers below come from short self-contained Python runs (plain sieve + Kronecker
symbol + truncated `L(1,χ)` series) executed during this cycle.  They are *exploratory*:
the verified content of this cycle is the Lean development in `Catalog/Bridges/`, and
nothing in this file is machine-checked.  Its purpose is (i) an independent toy-scale
replication of the reported null, and (ii) numerical sanity checks of the exact identities
that were then proved in Lean.

## 1. Independent toy replication of the sweep (x = 2²²)

Setup mirrors the registered carrier: `π(x) = 295 947` primes below `x = 2²² = 4 194 304`;
moduli `m ∈ [3, 200]`; response `D(m) = max_{(a,m)=1} |π(x;m,a) − E| / √E` with
`E = π(x)/φ(m)`; predictor `P(m) = Σ |L(1,χ_D)|` over the fundamental discriminants `D ≠ 1`
with `|D| | m` (truncated series, `N = 2·10⁵` terms).  198 moduli survived the filter.

| regression (log–log)      | R²      | slope   |
|---------------------------|---------|---------|
| `log D ~ log P`           | 0.0214  | +0.0781 |
| `log D ~ log m`           | 0.7166  | +0.4239 |
| `log D ~ log φ(m)`        | 0.8378  | +0.4175 |
| `D ~ log m` (raw readout) | 0.6154  | +0.2601 |

This reproduces the reported pattern at a smaller scale and with an independent
implementation: the character-L predictor is null (`R² = 0.021`, far below the 0.5 bar),
while a pure size covariate — here `log φ(m)`, the natural size feature for this readout —
explains `R² = 0.84`.  The deviation field is size-dominated.

*Counterexample hunt.*  No modulus in the sample shows large deviation together with small
L-mass in a way that separates the sample: the best univariate log-log fit on `P` has
essentially zero explanatory power, so no threshold in `P` produces a usable split.  This
is exactly the situation that `Ma1Effectivity.margin_criterion_rsq_lower` converts into a
*bound*: a small `R²` caps the margin of every threshold criterion, including nonlinear
ones.

## 2. Verification of the exact `L`-value path

* `L(1, χ₋₃)`: truncated series `0.60459962` versus the exact class-number value
  `π/(3√3) = 0.60459979` (relative error `2.8·10⁻⁷`).
* `L(1, χ₅)`: truncated series `0.430409`, matching the standard value `0.4304089` —
  the off-by-one failure mode recorded in the source ledger (`0.127`) is absent here.

## 3. Numerical checks of the identities later proved in Lean

* **Two-group (between/within) identity** — `Ma1Effectivity.two_group_rss`:
  `‖y − ĝ‖² = TSS − (n₁n₂/n)(m₁−m₂)²` for the two-valued group-mean predictor.
  Verified on 5 random samples (`n = 40`, random split), max absolute error `< 10⁻⁹`.

* **Sign-blindness separation** — `Ma1Effectivity.signblind_misses_alignment`, at `p = 7`
  (`7 ≡ 3 mod 4`), `χ = (·|7) = [0, 1, 1, −1, 1, −1, −1]`, `E = 10`,
  `c₁(a) = E + χ(a)`, `c₂(a) = c₁(−a)`:

  | statistic | `c₁`     | `c₂`     |
  |-----------|----------|----------|
  | `maxDev`  | 0.316228 | 0.316228 |
  | `χ²`      | 0.600000 | 0.600000 |
  | `align`   | **+6**   | **−6**   |

  Both registered readouts agree exactly while the signed alignment attains `±(p−1) = ±6`.
  This is the finite instance of the general theorem proved for all primes `p ≡ 3 (mod 4)`.

## 4. OEIS

No new integer sequence is produced by this cycle (the objects are real-valued statistics),
so no OEIS lookup applies.

## 5. Numerical check of the cell-gap ceiling

`Ma1Effectivity.cell_mean_gap_le_of_rsq` asserts
`(m_a − m_b)² ≤ R²·TSS·(1/n_a + 1/n_b)` for any two level sets of the feature, where `R²`
is the correlation ratio of the feature partition.  Randomised check: 2000 random samples
(`n` between 4 and 30, 2–4 random cells, Gaussian responses), all cell pairs tested — **0
violations**.

## 5. Randomised checks for the multi-cell cycle

Exploratory (not machine-checked; the Lean file `Catalog/Bridges/Ma1EffectivityMultiCell.lean`
is the verified content).  3000 random samples were generated with `n ∈ [4, 20]` points,
`k ∈ [2, 5]` feature levels, response `y_i = N(0,1) + 0.3·P(i)`; for each sample the exact
correlation ratio `R² = 1 − withinSS/TSS` was computed and both new inequalities were tested
with random weights and a random split of the cells into two groups:

| checked inequality | violations / 3000 |
|--------------------|-------------------|
| contrast ceiling `(Σ w_c(m_c−m))² ≤ R²·TSS·Σ w_c²/n_c` | 0 |
| group-gap ceiling `(M_A−M_B)² ≤ R²·TSS·(1/N_A+1/N_B)`  | 0 |

No sample exceeded either bound (largest observed excess of the left side over the right
side: `0.0`, i.e. none).

## 6. Randomised checks for the power-curve / sharpness cycle

Exploratory (not machine-checked; the Lean file
`Catalog/Bridges/Ma1EffectivityPowerCurve.lean` is the verified content).

| checked statement | sample | result |
|-------------------|--------|--------|
| `k`-cell equality case `(Σ w_c(m_c−m))² = TSS·Σ w_c²/n_c` with `w_c = n_c(m_c−m)`, cell-constant response, `k ∈ [3,6]` | 2000 random profiles | worst relative error `8.4e-16` (floating point only) |
| contrast weights sum to zero, `Σ_c n_c(m_c−m) = 0` | same 2000 profiles | max `|Σ w|` below `1e-9` |
| two-point p-value of the `χ²` readout equals `1/2` on `0 < t < 2|B|/A` | 2000 random count fields, `n ∈ [2,8]` | 0 deviations from `1/2` |

The first row is the numerical shadow of `multicell_contrast_eq_of_measurable`: the
Cauchy–Schwarz ceiling is attained exactly, with no deficiency once there are three or more
cells.
