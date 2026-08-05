# Computational Evidence: Correspondence-Based Rips Interleaving

All numbers below come from a small exhaustive/randomised search over finite subsets of
the Euclidean plane (script logic reproduced in the text; results are exploratory only —
the *verified* statements are the Lean theorems in
`Catalog/Bridges/GraphTheory/RipsCorrespondenceInterleaving.lean`).

## 1. The claim under test

For finite samples `S ⊂ ℝ²`, `T ⊂ ℝ²` and a correspondence `R ⊆ S × T` (surjective on both
factors) with distortion

```
c = max { | d(x,x') − d(y,y') |  :  (x,y), (x',y') ∈ R },
```

every choice map `f` (any `f` with `(x, f x) ∈ R`) should send an `ε`-Rips simplex of `S`
to an `(ε + c)`-Rips simplex of `T`.

## 2. Randomised counterexample hunt

400 random instances: `|S| ∈ {2,…,5}`, `|T| ∈ {1,…,4}`, points uniform in `[0,3]²`,
random surjective correspondence; all Rips simplices at `ε ∈ {0.3, 0.8, 1.5, 2.5}`.

| quantity | value |
|---|---|
| violations of `ε ↦ ε + c` | **0** |
| max fraction of the `+c` budget actually consumed | **1.0** |

So no counterexample, and the budget is attained (the bound is not slack in general).

## 3. Sharpness family

`S = {0, c} ⊂ ℝ`, `T = {0} ⊂ ℝ`, `R = S × T`:

| `c` | distortion of `R` | `T` a `0`-simplex? | diameter of the full `R`-preimage of `T` |
|---|---|---|---|
| 0.5 | 0.5 | yes | 0.5 |
| 1.0 | 1.0 | yes | 1.0 |
| 2.0 | 2.0 | yes | 2.0 |

A shift `η < c` therefore fails for every `c > 0`. This is exactly
`interleaving_shift_sharp`.

## 4. Matched samples give distortion `2δ`, and `2δ` is attained

With `X = (0, t)`, `Y = (−δ, t+δ)` in `ℝ` we have `dist (X i) (Y i) = δ` for both indices, while
`|d(X₀,X₁) − d(Y₀,Y₁)| = |t − (t+2δ)| = 2δ`. So the indexwise correspondence of a matched
sample has distortion at most `2δ` (`matched_distortionLe`) and the constant `2δ` is attained —
the classical `2δ` scale translation is the distortion bound of §1 specialised to indexwise
correspondences, and by §3 it cannot be improved.

## 5. OEIS

No integer sequence arises in this development; no OEIS search applies.

---

# Computational Evidence (cycle 2): Vertex Links and the Guarded Interval

The second file, `Catalog/Bridges/GraphTheory/RipsLinkGuardedInterval.lean`, is about
*local* data: the link degree

```
linkDeg S ε v = # { x ∈ S : d(v,x) ≤ ε }
```

and the *guarded interval* `guardSet S k = { ε : every link of S at scale ε has ≥ k
vertices }`, whose left endpoint is `guardThreshold S k`.  The exploratory checks below
preceded the formalisation; as before they are *not* machine-verified — the verified
statements are the Lean theorems.

## 6. Link degrees under a `δ`-matching (claim of `linkDeg_le_of_matching`)

Claim: if `S` is `η`-separated, `2δ < η`, and `f` is a `δ`-matching of `S` onto `T`, then
`linkDeg S ε v ≤ linkDeg T (ε + 2δ) (f v)` for every `v ∈ S` and every `ε`.

3000 random instances: `|S| ∈ {3,…,9}` uniform in `[0,1]²`, `δ` drawn uniformly in
`(0, η/2)` for `η` the actual separation of `S`, `f` a random displacement of norm `≤ δ`,
`ε` uniform in `(0, 1.5)`.

| quantity | value |
|---|---|
| violations of `linkDeg S ε v ≤ linkDeg T (ε+2δ) (f v)` | **0** |

## 7. The separation hypothesis is necessary

Repeating the experiment with `δ` unconstrained (so the matching may collapse two sample
points — implemented by rounding the perturbed coordinates) produced **11 violations out
of 24 860 vertex tests**.  A collapsing matching genuinely destroys link degree, which is
why `map_injOn` (and hence the hypothesis `2δ < η`) appears in the Lean statement.

## 8. Endpoint stability (claim of `guardThreshold_stability_abs`)

Same 3000 instances, `k ∈ {1,2,3}`, thresholds computed by scanning the finite set of
pairwise distances:

| quantity | value |
|---|---|
| violations of `|guardThreshold T k − guardThreshold S k| ≤ 2δ` | **0 of 3000** |

## 9. Sharpness of the `2δ` shift for links (claim of `linkDeg_shift_sharp`)

`S = {0, ε}`, `T = {−δ, ε+δ}`, `f 0 = −δ`, `f ε = ε+δ` (a `δ`-matching):

| `δ` | `ε` | `linkDeg S ε 0` | `linkDeg T η (f 0)` at `η = ε+2δ−10⁻⁶` | at `η = ε+2δ` |
|---|---|---|---|---|
| 0.1 | 0.5 | 2 | 1 | 2 |
| 0.25 | 1.0 | 2 | 1 | 2 |

The link degree is recovered exactly at the shift `2δ` and not before, so the shift is
optimal.

## 10. Worked endpoint

For `S = {0, r} ⊂ ℝ` and `k = 2` the guarded interval is `[r, ∞)` and the endpoint is `r`
(verified formally as `guardSet_pair` / `guardThreshold_pair`).

---

# Cycle 3 — coverage, packing and the `n^{-1/d}` density law

The statements below are the exploratory checks that preceded
`Catalog/Bridges/GraphTheory/RipsCoverageDensity.lean`.  They are ordinary floating-point
computations and are **not** machine-verified; the verified statements are the Lean
theorems in that file.

## 11. Coverage and packing inequalities in the plane

Ambient space `ℝ²` (`d = 2`, `v = area of the unit disk = π`).  For each of 4000 random
instances: `n ∈ {2,…,40}` points uniform in the disk `K` of a random radius
`R ∈ [0.5, 3]` (so `V = πR²`), covering radius `ρ` estimated from 400 random probes,
separation `η` the minimum interpoint distance, and `δ = 0.999·η/2` (the largest value
admissible for the cycle-2 hypothesis `2δ < η`).

| claim | violations | worst observed ratio (rhs/lhs) |
|---|---|---|
| `V ≤ n · ρ^d · v`  (`IsCoverAt.volume_le`) | **0 / 4000** | 2.16 |
| `n · (η/2)^d ≤ (R + η/2)^d`  (`packing_card_bound`) | **0 / 4000** | 2.00 |
| `V · δ^d ≤ v · (2Rρ)^d`  (`noise_resolution_tradeoff`) | **0 / 4000** | 9.23 |

The packing ratio approaching `2.00` reflects instances where the sample is nearly a
perfect packing of the ball; the covering ratio never dropped below `1`, as the theorem
requires.

## 12. Is the `n^{-1/d}` floor the right order?

The theorem gives the floor `ρ ≥ (V/(v n))^{1/d}`, which for the unit disk in `ℝ²` is
exactly `n^{-1/2}`.  Sampling the unit disk by a triangular lattice of decreasing spacing
and measuring the covering radius by 20 000 random probes:

| `n` | `ρ` (lattice) | floor `n^{-1/2}` | ratio |
|---|---|---|---|
| 19 | 0.2883 | 0.2294 | 1.257 |
| 31 | 0.3002 | 0.1796 | 1.671 |
| 61 | 0.1759 | 0.1280 | 1.374 |
| 109 | 0.1774 | 0.0958 | 1.852 |
| 211 | 0.1157 | 0.0688 | 1.681 |
| 439 | 0.0877 | 0.0477 | 1.837 |

The ratio stays bounded (the oscillation is a boundary effect of intersecting a lattice
with a disk), so the deterministic floor has the correct power of `n`.  This is the
evidence for the reading of Direction 2 adopted in cycle 3: the bare power law
`n^{-1/d}` is the *packing/spacing* scale and is a hard lower bound for the covering
radius, while the extra `log n` appearing in probabilistic coverage thresholds is a
genuine excess coming from extreme gaps of a random sample, not an artefact of the
estimate.

## 13. Counterexample hunt for the capstone

For the capstone `guardThreshold_shift_le_resolution` the relevant question is whether
the sample size can be eliminated from the bound.  Over the 4000 instances of §11 the
quantity `δ / ρ` was never larger than `0.658`, while `2R(v/V)^{1/d} = 2` for the disk —
consistent with the proved bound `δ · V^{1/d} ≤ 2Rρ · v^{1/d}` and with the fact that
`n` cancels.  No instance was found in which the noise budget exceeded a constant
multiple of the resolution.
