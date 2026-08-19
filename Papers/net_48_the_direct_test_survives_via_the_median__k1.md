# Computational evidence — NET-48 knee data, geometric reading

All numbers below were first obtained by direct exploratory computation (plain arithmetic on
the reported knee values) and are **not** the verified artefacts by themselves: every claim
that is asserted as a result is proved in the Lean files
`Catalog/Geometry/KneeFermatWeber.lean`, `Catalog/Geometry/KneeMedianProjection.lean`,
`Catalog/Geometry/KneeScalingRays.lean`, `Catalog/Geometry/KneeFourthSeed.lean`,
`Catalog/Geometry/FermatWeberMedian.lean`, `Catalog/Geometry/FermatWeberCharacterisation.lean`
(all sorry-free, axioms `propext`, `Classical.choice`, `Quot.sound` only).

## 1. Fermat–Weber cost of the measured knee triples

Cost function `C(t) = Σ_i |t − k_i|`, exhaustive search on a grid.

| context | knees | grid argmin | optimal cost | spread `max − min` |
|---|---|---|---|---|
| 1024 (8×) | {96, 112, 128} | 112 | 32 | 32 |
| 2048 (16×) | {160, 224, 256} | 224 | 96 | 96 |

The argmin coincides with the reported median in both rows, and the optimal cost equals the
spread. Proved: `net48_fermatWeber_8`, `net48_fermatWeber_16` (existence, value **and**
uniqueness of the minimiser).

## 2. Normalised (ratio) configurations and the "50 % wider spread"

Ratios `k*/P`, `P = d·ctx/32`:

| context | ratios | Fermat–Weber point | optimal cost |
|---|---|---|---|
| 8× | {3/4, 7/8, 1} | 7/8 | 1/4 = 0.25 |
| 16× | {5/8, 7/8, 1} | 7/8 | 3/8 = 0.375 |

Ratio of optimal costs `0.375 / 0.25 = 1.5` exactly. Proved: `net48_cost8_normalised`,
`net48_cost16_normalised`, `net48_spread_ratio`.

## 3. Rays in the `(ctx, k*)` plane

`cross(p,q) = p₁q₂ − p₂q₁` (twice the signed area of the triangle with the origin):

| pair | cross | on a common ray? |
|---|---|---|
| top: (1024,128), (2048,256) | 0 | yes, slope 1/8 |
| median: (1024,112), (2048,224) | 0 | yes, slope 7/64 = (7/8)·(1/8) |
| low tail: (1024,96), (2048,160) | −32768 | **no** (triangle area 16384) |

Proved: `top_on_ray`, `median_on_ray`, `low_tail_not_on_ray`, `low_tail_triangle_area`,
`median_slope_unique`.

## 4. Median level set in ℝ³ — a non-convexity check

`med(5/8, 7/8, 1) = 7/8` and `med(7/8, 1, 5/8) = 7/8`, but the midpoint
`(3/4, 15/16, 13/16)` has median `13/16 ≠ 7/8`. So the level set is not convex, and the fact
that the two measured contexts lie on a *common flat edge* `{(t, 7/8, 1) : t ≤ 7/8}` is a real
structural feature. Proved: `median_levelSet_not_convex`, `median_levelSet_edge`,
`ratio_segment_in_levelSet`, `median_levelSet_exit`.

## 5. Third-seed stability set (refutation of the informal claim)

`median{256, 224, x}` as a function of `x`:

| x | 160 | 192 | 224 | 240 | 256 | 300 |
|---|---|---|---|---|---|---|
| median | 224 | 224 | 224 | **240** | 256 | 256 |

The stability set is the ray `x ≤ 224`, **not** `x < 256`: the value `240` already moves the
centre, contradicting the informal statement "only values ≥ 256 would shift it". Proved:
`net48_stability_ray`, `net48_informal_claim_false` (this reproduces, in projection form, the
same correction already recorded in `Catalog/Tropical/KneeMedian/NET48SeedLaws.lean`).

## 6. Counterexample hunt for the fourth-seed prediction

Claim tested: *for every fourth seed `x`, the value 224 is a minimiser of
`C(t) = |t−160| + |t−224| + |t−256| + |t−x|`.*

Scan `x ∈ {0, …, 599}` against a fine grid of `t` (step 0.25 over `[0,1000]`): **0
counterexamples**, and in every case the optimal cost equalled `96 + |224 − x|`:

| x | 96 | 160 | 192 | 224 | 240 | 256 | 300 |
|---|---|---|---|---|---|---|---|
| `C(224)` | 224 | 160 | 128 | 96 | 112 | 128 | 172 |
| grid optimum | 224 | 160 | 128 | 96 | 112 | 128 | 172 |

Proved (for all real `x`, no grid): `net48_fourth_seed_keeps_224`, `net48_fourth_seed_cost`;
the shape of the optimal set is `net48_fourth_seed_low_tail`, `net48_fourth_seed_high`,
and the uniqueness knife edge is `net48_fourth_seed_unique_iff`.

## 7. No OEIS entry

The knee sequences {96,112,128} and {160,224,256} are short arithmetic-looking triples with
no distinctive continuation; no OEIS identification was attempted or is claimed.


## 8. Second/third-cycle checks

* The general odd-sample theorem was checked against the catalog's own multisets `K16`, `K8`
  (rationals): `fwCost K16 224 = 96`, `fwCost K8 112 = 32` (`fwCost_values`), matching §1.
* Balance counts for the four-seed sample `{160, 224, 256, y}` at `m = 224`: for `y ≤ 224` the
  weak-below/strict-above counts are `3/1`, for `y > 224` they are `2/2`; both are balanced, in
  agreement with the exhaustive scan of §6 (`net48_224_isBalanced`).
* Non-convexity check of §4 is the reason the interval statement `minimiser_set_convex` is about
  the *minimiser set* (which is convex) and not about level sets of the median (which are not).
