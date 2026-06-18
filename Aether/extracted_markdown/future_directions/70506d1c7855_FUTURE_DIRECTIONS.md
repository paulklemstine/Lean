# FUTURE DIRECTIONS — Functorial Tropical Ultrametric from Pythagorean Lorentz Triples

This cycle produced two compiling, `sorry`-free Lean files (standard axioms only):

- `Catalog/Bridges/FunctorialTropicalPythagorean.lean` — the canonical **tree ultrametric**
  `d` on the boundary `Addr = ℕ → Fin 3` of the ternary Berggren tree, with the six
  metric/ultrametric axioms (`d_self`, `d_comm`, `d_eq_zero_iff`, `d_triangle`, `d_ultra`,
  `d_le_one`), the tropical min-plus core (`firstDiff_ge_min`, `firstDiff_cons_tropical`),
  the exact `(1/2)`-similarities (`d_cons_same`, `d_cons_diff`), the **two-sided** depth↔
  hypotenuse window `5·3ⁿ ≤ c ≤ 5·7ⁿ` along the all-`B` ray (`bchild_iter_hyp_growth`,
  `seed_hyp_growth`), and the functorial Gaussian bridge (`gaussianSupportCarrier`,
  `gaussian_reconstruct_ultrametric`, `gaussian_norm_eq`, `gaussian_norm_mul`) into the
  catalog functor `CategoricalTropicalUltrametric.valuationReconstruct`.
- `Catalog/Bridges/FunctorialTropicalPythagoreanMetric.lean` — the Mathlib packaging:
  `instMetricSpaceAddr : MetricSpace Addr` and `instIsUltrametricDistAddr : IsUltrametricDist
  Addr`, with the half-scale similarity and maximal-separation facts restated through the
  Mathlib `dist`.

The following conjectures are **bold but testable** in Lean, each refined by this cycle's
findings and partial evidence.

## C1′. Cantor-space completeness and compactness of `(Addr, d)`
**Conjecture.** `(Addr, dist)` is **complete** and **compact** (a Cantor space), i.e.
`CompleteSpace Addr` and `CompactSpace Addr` hold for the registered `MetricSpace` instance.
*Evidence.* This cycle delivered `instMetricSpaceAddr` and `instIsUltrametricDistAddr`, so
the space is already a bona fide ultrametric space; `dist_le_one` bounds the diameter by `1`.
**The key insight is** that an address sequence is Cauchy iff every coordinate stabilizes
(each `2⁻ⁿ`-ball is the depth-`n` cylinder), so the coordinatewise limit is the unique limit
and totally-bounded + complete ⇒ compact. **Why now?** The metric instance is in place, so
the proof reduces to a single coordinate-stabilization lemma plus the standard
`isCompact_of_totallyBounded_isComplete` route — no new geometry is required.

## C2. Hausdorff dimension of the Berggren boundary = log 3 / log 2
**Conjecture.** `dimH (Set.univ : Set Addr) = Real.log 3 / Real.log 2`.
*Evidence.* `d_cons_same` gives contraction ratio exactly `1/2`; `d_cons_diff` makes the
three branch images pairwise distance-`1`, i.e. disjoint clopen balls (the open-set
condition). **The key insight is** that there are exactly `3ⁿ` depth-`n` cylinders, each of
diameter `2⁻ⁿ`, so the natural cover gives the upper bound `log 3 / log 2`, and the disjoint
`(1/2)`-similarities give the matching lower bound via a mass-distribution argument. **Why
now?** Both the contraction ratio and the separation constant are now theorems, pinning the
two sides of the dimension estimate to concrete, already-proven numbers.

## C3′. The depth–size window is sharp and ray-uniform
**Conjecture.** For *every* infinite branch word `w` (not just all-`B`), the depth-`n`
hypotenuse `c` satisfies `α·ρ_min^n ≤ c ≤ β·ρ_max^n` with branch-uniform constants, and the
all-`B` window `5·3ⁿ ≤ c ≤ 5·7ⁿ` is the extremal case. *Evidence.* `bchild_iter_hyp_growth`
proves the two-sided window on the all-`B` ray, and `bIter_pos_le` shows `a ≤ c, b ≤ c` is
preserved (the engine of the upper bound). **The key insight is** that each Berggren
generator multiplies the hypotenuse by a factor in `[3, 7]` whenever the legs are bounded by
the hypotenuse, an invariant preserved along *every* word, so metric depth is `Θ(log c)`
uniformly. **Why now?** The leg-≤-hypotenuse invariant is already proven for the `B`-ray;
generalizing it to arbitrary words is a finite per-generator check (`childA`, `childC`).

## C4. The Berggren monoid acts by ultrametric `(1/2)`-similarities
**Conjecture.** The map `k ↦ cons k` extends to a faithful action of the free monoid on three
letters by `(1/2)`-Lipschitz endomorphisms of `(Addr, dist)`, and word composition is
functorial; distinct words never collapse. *Evidence.* `dist_cons_same` (exact factor `1/2`),
`dist_cons_diff` (maximal separation), and the catalog functoriality theorems
`tropicalization_map_comp`, `valuationReconstruct_map_comp`. **The key insight is** that
`cons` is injective and distance-multiplying by exactly `1/2`, so a length-`ℓ` word is a
`2⁻ℓ`-similarity whose image is a single depth-`ℓ` cylinder — different words land in
different cylinders, forcing freeness. **Why now?** The exact contraction constant is a
theorem (not an estimate), so faithfulness follows from cylinder-disjointness rather than
from a hard dynamical argument.

## C5. A nontrivial `(1+i)`-adic valuation refines the Gaussian bridge
**Conjecture.** Replacing the trivial support valuation `gval` by the `(1+i)`-adic valuation
`v` on `ℤ[i]` yields a *nontrivial* `TropicalValuationCarrier` whose value on the encoding
`m + n·i` of a primitive triple equals the `2`-adic valuation of the even leg `2mn`.
*Evidence.* `gaussian_norm_eq` (norm `= m²+n²`, the hypotenuse) and `gaussian_norm_mul`
(multiplicativity) fix the arithmetic; `gaussianSupportCarrier` is the trivial endpoint of
this family. **The key insight is** that `(1+i)` is the unique ramified prime over `2` in
`ℤ[i]`, so `v(m+n·i)` counts exactly the power of `2` dividing the even leg — turning the
trivial `{0,1}` valuation into a graded `ℕ`-valued one that still satisfies the carrier
axioms. **Why now?** The multiplicative backbone (`gaussian_norm_mul`) is already proven, so
only the single even-leg identity `v(m+n·i) = ν₂(2mn)` remains to upgrade the bridge from
trivial to informative.
