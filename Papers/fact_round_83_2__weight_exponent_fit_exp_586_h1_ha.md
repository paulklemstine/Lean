# Computational evidence — exp-586 weight-exponent layer

All numbers in this note come from exploratory floating-point computation and are **not**
machine-verified; they were used only to choose which statements to formalize.  The
verified artifacts are the Lean theorems in `Catalog/Tropical/WeightExponent*.lean` and
`Catalog/Tropical/WeightWindowSaturation.lean`, each of which compiles with no `sorry`.

## 1. The dial statistic over the recorded window (odd primes 3..400, 77 primes)

`S_α = Σ_{ℓ prime, 3 ≤ ℓ ≤ 400} ℓ^(-α)`:

| α    | 0    | 0.25   | 0.5    | 0.75   | 1      | 1.5    | 2      |
|------|------|--------|--------|--------|--------|--------|--------|
| S_α  | 77   | 24.168 | 8.437  | 3.370  | 1.559  | 0.483  | 0.202  |

Strictly decreasing in `α` (formalized: `WeightDial.dialSum_strictAnti`) and log-convex
(formalized: `WeightDial.dialSum_sq_midpoint_le`; check: `8.437² = 71.2 ≤ 77·1.559 = 120`,
and `3.370² = 11.36 ≤ 8.437·1.559 = 13.15`).

## 2. Relative weight of the window-edge prime

`w_α(400)/w_α(3) = (3/400)^α`:

| α    | value    | reciprocal |
|------|----------|------------|
| 1/2  | 0.086603 | 11.547     |
| 1    | 0.0075   | 133.33     |

Ratio of the two: `√(400/3) = 11.547`.  Formalized as
`WeightDial.edgeRatio_half_bounds` (`1/12 < ρ(1/2) < 1/11`) and
`WeightDial.edgeRatio_gain_gt` (`11.5 · ρ(1) < ρ(1/2)`).

## 3. Window mass `T_α(B) = Σ_{B ≤ ℓ < 4B} ℓ^(-α)` (all integers in the window)

| B      | T_1(B) | T_{1/2}(B) | (3/2)·√B | 3·√B |
|--------|--------|------------|----------|------|
| 1      | 1.833  | 2.284      | 1.5      | 3    |
| 10     | 1.425  | 6.405      | 4.74     | 9.49 |
| 100    | 1.390  | 20.03      | 15.0     | 30.0 |
| 400    | 1.387  | 40.01      | 30.0     | 60.0 |
| 10000  | 1.386  | 200.00     | 150.0    | 300.0|

`T_1` is uniformly bounded (it converges to `log 4 = 1.3863`), while `T_{1/2}` grows like
`2(√(4B) − √B) = 2√B`, comfortably inside the proved envelope
`[3·4^(-α)·B^(1-α), 3·B^(1-α)]` (`WindowSaturation.windowTail_bounds`).  This is the
computational content behind `WindowSaturation.saturation_does_not_transfer`: a window
saturation scale calibrated under `1/ℓ` has no analogue under `1/√ℓ`.

## 4. Tropical limit spot-check

For `supp = {3, 5, 7}` the normalized covariate `Σ_ℓ (3/ℓ)^α` takes the values
`3, 1.544, 1.092, 1.018` at `α = 0, 2, 5, 8`, decaying to `1 = 1_{3 ∈ supp}`, matching
`TropicalLimit.tendsto_normDial`.

## 5. Counterexample hunt

* Is `α ↦ S_α` ever non-monotone?  No — checked on random supports; proved in general.
* Is the log-convexity inequality ever an equality on a two-element support with
  `α ≠ β`?  No instance found; proved impossible
  (`WeightDial.dialSum_sq_midpoint_lt_pair`).
* Is `T_1(B) ≤ 3` tight?  The supremum over `B ≥ 1` is `T_1(1) = 1.833`, so the constant
  `3` proved in Lean is safe but not optimal.
* No OEIS sequence is involved: all objects here are real-valued weight sums.
