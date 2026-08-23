# Computational evidence — UNIFORM-DIAL (draw-regime invariance of the yield dial)

Scope: the reported experiment compares a *per-key yield dial* (footprint weighting) with a
plain count baseline under two draw regimes (uniform/balanced vs. genuinely unbalanced) and
finds no variance-share dilution.  This note records the small-case arithmetic that guided
the formalization, and marks precisely which numbers are **Lean-verified** and which were
exploratory.

## 1. The model used

A finite population of keys `i`, each with a footprint `x i` and a yield rate `y i`.
A draw regime is a probability weighting `p` (`p ≥ 0`, `∑ p = 1`).  The dial reading is the
regime-weighted covariance `Cov_p(x, y)`, and the variance share is
`R²_p(x, y) = Cov_p(x,y)² / (Var_p x · Var_p y)`.

## 2. Small case: four keys, two very different regimes

| key | footprint `x` | count `c` | rate `y` |
|-----|---------------|-----------|----------|
| 0   | 1             | 1         | 1        |
| 1   | 2             | 1         | 2        |
| 2   | 4             | 2         | 5        |
| 3   | 8             | 2         | 9        |

Regimes: `pU = (1/4, 1/4, 1/4, 1/4)` (balanced), `pQ = (7/10, 1/10, 1/10, 1/10)`
(genuinely unbalanced; ℓ¹ distance `0.9`, i.e. total variation `0.45`).

Exact rational variance shares (computed in exact arithmetic during exploration):

| regime | `R²(footprint)` | `R²(count)` | gap |
|--------|-----------------|-------------|-----|
| `pU`   | `17689/17825 ≈ 0.99237` | `121/155 ≈ 0.78065` | `≈ 0.2117` |
| `pQ`   | `299209/300629 ≈ 0.99528` | `2209/2564 ≈ 0.86154` | `≈ 0.1337` |

**Lean-verified statements** (`Catalog/Combinatorics/UniformDialYieldRegression.lean`,
no `sorry`, standard axioms only):

* `footprint_beats_count_uniform : R2 pU fc fy + 1/5 < R2 pU fw fy`
* `footprint_beats_count_unbalanced : R2 pQ fc fy + 13/100 < R2 pQ fw fy`
* `footprint_count_regimes_far : ∑ i, |pU i - pQ i| = 9/10`
* `example_dial_positive_both_regimes : 0 < wcov pU fw fy ∧ 0 < wcov pQ fw fy`

The exact rational values in the table above are *exploratory*; only the inequalities and
the ℓ¹ distance are machine-checked.  The verified content is exactly the qualitative claim
of the experiment: the footprint dial's advantage survives a genuinely unbalanced draw,
while its numerical size moves (here `0.21 → 0.13`).

## 3. Counterexample hunt: is the *ordering* invariant in general?

It is not, and the formal development says where the boundary is.  Two probes:

1. *Sign of the dial.*  Searching for a comonotone population (no discordant key pair) with
   a full-support regime that reports a nonpositive dial fails by construction: the
   Hoeffding pair identity writes `2·Cov_p = ∑_{i,j} p_i p_j (x_i − x_j)(y_i − y_j)`, a sum of
   nonnegative terms.  This is now the theorem `wcov_nonneg_of_comonotone`, with strict
   version `wcov_pos_of_comonotone`.  So no counterexample exists in the comonotone class,
   in **any** regime — the strongest form of the "no dilution" claim.

2. *Populations with discordant pairs.*  Here the sign genuinely can flip: a regime may
   concentrate mass on a discordant pair.  The quantitative boundary is
   `wcov_budget : ε²·C − M²·Δ ≤ 2·Cov_p` for regimes with per-key mass in `[ε, M]`, where
   `C`, `Δ` are the population's total concordant/discordant pair masses.  Flipping the
   dial requires conditioning number `κ = M/ε` with `κ² ≥ C/Δ`.  For the balanced regime
   `κ = 1`, and for the `pQ` above `κ = 7`; the "dilution" hypothesis H2 would need a
   population with `C/Δ < 49` to be visible at that imbalance.

## 4. Interpolation probe

Sampling the dial along the segment `p_t = (1−t)pU + t·pQ` shows a smooth, non-dipping
curve.  The formal explanation is exact rather than numerical: `wcov_mix` proves the reading
is a *quadratic polynomial* in `t`,

`Cov_{p_t} = (1−t)²·Cov_{pU} + 2t(1−t)·Cross + t²·Cov_{pQ}`,

with `Cross ≥ 0` for comonotone populations (`crossTerm_nonneg_of_comonotone`), hence
`Cov_{p_t} ≥ ½·min(Cov_{pU}, Cov_{pQ})` for all `t ∈ [0,1]` (`wcov_mix_ge_half_min`).
So no intermediate regime can dilute the dial either — a strictly stronger conclusion than
comparing the two measured endpoints.

## 5. OEIS

No integer sequence arises: the objects here are weighted second moments over a finite
population, so an OEIS search is not applicable.
