# Computational Evidence

All computations below were run inside the project's Lean environment
(`lake env lean`, exact rational arithmetic for (1)–(3), `Float` for (4)).
They guided the choice of theorem statements in
`Tropical/SocialChoice/TropicalArrow.lean` and
`Tropical/SocialChoice/Dequantization.lean`.  They are *exploratory*: the
statements that matter are proved formally in those files.

## 1. Small-case exploration of the axioms

Setting: electorate `ι = {0,1}`, profiles `x : ι → ℚ`, aggregator

```
W (x₀, x₁) = min (x₀) (x₁ + 1).
```

Grid `G = {-2, -1, -1/2, 0, 1/2, 1, 2}`.

| test | range | violations |
|---|---|---|
| `W (x ⊓ y) = min (W x) (W y)` (tropical additivity) | all `x, y ∈ G²` (2401 pairs) | **0** |
| `W (x + c·1) = W x + c` (translation equivariance) | all `x ∈ G²`, `c ∈ G` (343) | **0** |
| `W (c, c) = c` (normalization) | all `c ∈ G` | **0** |
| `∃ i, W x = x i` (selectivity) | all `x ∈ G²` (49) | **12 failures** |

Example failure of selectivity: `W (1, -1) = min (1, 0) = 0 ∉ {1, -1}`.

**Conclusion.**  A normalized, translation-equivariant, min-preserving
aggregator need *not* be a minimum of coordinate projections; a nonzero tropical
weight (`δ₁ = 1`) is compatible with all three axioms.  This is the
counterexample formalized as `weightedAgg_not_min_of_projections`, and it is why
the classification theorem is stated in the *weighted* form
`F x = min_{i ∈ S} (x i + δ i)`.

## 2. Counterexample hunt for the corrected classification

The weighted representation was tested by probing candidate aggregators with
"dip" profiles `dip i t = (0,…,0,t,0,…,0)`.  For every aggregator built as
`x ↦ min_{i ∈ S} (x i + δ i)` with `δ ≥ 0`, `min δ = 0`, the probe values behave
as `F (dip i t) = min (t + δ i) 0` for `i ∈ S` and `= 0` otherwise, which
recovers `S` and `δ` uniquely.  No aggregator satisfying the three axioms was
found outside this family — matching the proof of
`exists_tropical_representation`, which shows the family is exhaustive.

No sequence of integers arises in this problem, so no OEIS search applies.

## 3. Dequantization scale

For the profile `x = 0` with support size `n` and zero weights, the softmin
`-ε log Σ_{i∈S} e^{-x_i/ε}` equals `-ε log n`, i.e. the tropical value `0`
shifted by exactly `-ε log n`:

| ε | 1 | 1/2 | 1/4 | 1/8 | 1/16 |
|---|---|---|---|---|---|
| softmin value (n = 3) | −1.0986 | −0.5493 | −0.2747 | −0.1373 | −0.0687 |

This is exactly the extremal case of the sandwich
`A − ε log|S| ≤ softmin ≤ A` proved in `logSumExp_sandwich`, and it shows the
rate `ε log |S|` in `dequant_sub_trop_abs_le` is attained.  For `n = 1` the gap
is identically `0` at every scale, which is the content of
`dequant_eq_trop_iff_card_eq_one`: exact (deformation-free) dequantization
happens precisely for dictatorships.

## Addendum: cell labels and orbit defect (small cases)

Both items below are now *theorems* in the Lean files, so these tables are
illustrations of statements that are machine-checked, not standalone numerics.

**Cell labels.** For a support `S` with `|S| = k`, the labels occurring as
`decisiveSet S δ x` are exactly the nonempty subsets of `S`
(`exists_decisiveSet_eq`, `decisiveSet_nonempty`), i.e. `2^k − 1` cells; the `k`
singleton labels give the top-dimensional chambers and the `2^k − 1 − k`
remaining labels sit inside walls.

| k | cells (2^k − 1) | top cells (k) | wall cells |
|---|---|---|---|
| 1 | 1 | 1 | 0 |
| 2 | 3 | 2 | 1 |
| 3 | 7 | 3 | 4 |
| 4 | 15 | 4 | 11 |

**Orbit defect.** Of the `binom(n,k)` coalitions in the orbit of the support,
exactly one is a dependence set (`decisive_in_orbit`), so the defect ratio is
`1 − 1/binom(n,k)` (`defect_ratio`).

| n | k | binom(n,k) | defect ratio |
|---|---|---|---|
| 3 | 1 | 3 | 2/3 |
| 3 | 2 | 3 | 2/3 |
| 3 | 3 | 1 | 0 |
| 4 | 2 | 6 | 5/6 |
| 5 | 2 | 10 | 9/10 |
