# Future Directions — Stereographic Capacity Theory

## Synthesis

The research cycle set out to validate a *stereographic capacity* bound for packing
spherical caps, `N(n,r) ≤ (2/cos r)^n · V_n/V_n(r)`, motivated by the conformal distortion
of stereographic projection. Carrying the mathematics out rigorously in Lean
(`Catalog/Geometry/StereographicCapacity.lean`) produced a sharper and cleaner picture than
the original conjecture, and exposed an error in its proposed test data.

Two genuinely complementary upper bounds govern cap packings on a Euclidean unit sphere:

1. **The area (volume) bound** `N ≤ V_n/V_n(r)`. For `S²` this is
   `capPackingBound r = 2/(1 - cos r)`, proved abstractly through the measure-theoretic
   lemma `measure_packing_card_mul_le` (disjoint sets' measures add and are dominated by the
   total measure). Numerically it yields `N(2,π/4) ≤ 6` and `N(2,π/6) ≤ 14`.

2. **The Gram / linear-algebra bound** `N ≤ 1 + 1/α` for unit centres with pairwise inner
   product `≤ -α`, proved in full generality as `spherical_code_card_bound` from the single
   inequality `0 ≤ ‖∑ vᵢ‖²`. Specialized via `cap_packing_bound_of_radius`, caps of radius
   `r` with `cos 2r < 0` satisfy `N ≤ 1 - sec 2r`; in particular `cap_packing_pi_div_three`
   gives `N(2,π/3) ≤ 3`.

The decisive observation is that the proposed conformal factor `(2/cos r)² ≥ 1` only
*enlarges* the area bound (`area_bound_le_stereographic`), so the stereographic bound is
never binding. The real cross-domain content is the opposite of what was conjectured: it is
**plane linear algebra (Gram positivity) that sharpens the spherical area bound**, and it
does so precisely in the large-cap regime `r > π/4` where the area bound is loosest. We also
found that the conjecture's datum `N(2,π/3) = 4` (tetrahedron) is false under the standard
"centres ≥ 2r apart" convention — the tetrahedral angle `arccos(-1/3) ≈ 109.47°` is below
`120°`, so those caps overlap; the true optimum is `3`, matching our Gram bound exactly.

## Results Summary

- `spherical_code_card_bound` — master Gram inequality `N ≤ 1 + 1/α` (sorry-free).
- `nonoverlap_iff_inner_le` — geodesic non-overlap `2r ≤ d(x,y) ↔ ⟪x,y⟫ ≤ cos 2r`.
- `cap_packing_bound_of_radius` — radius form `N ≤ 1 - 1/cos 2r` for `cos 2r < 0`.
- `cap_packing_pi_div_three` — `N(2,π/3) ≤ 3` (corrects conjectured `4`).
- `measure_packing_card_mul_le` — abstract area bound `card · c ≤ μ(univ)`.
- `capPackingBound_pi_div_three / _four_bounds / _six_bounds` — numerics `= 4`, `∈(6,7)`,
  `∈(14,15)`.
- `area_bound_le_stereographic` — the proposed factor only weakens the area bound.

## Research Directions

### 1. Tightness of the Gram bound and achievability of the spherical-code optimum
Prove that `cap_packing_pi_div_three` is *tight* by exhibiting three unit vectors at pairwise
angle exactly `120°` (equilateral triangle on a great circle) whose caps of radius `π/3` are
non-overlapping, giving `N(2,π/3) = 3`. More generally, characterize when the Gram bound
`1 + 1/α` is achieved (the simplex / regular-cross-polytope configurations).
**The key insight is** that `‖∑ vᵢ‖² = 0` forces the centroid to vanish, so equality in the
Gram bound is equivalent to the centres forming a balanced, equiangular tight frame — a
purely linear-algebraic equality condition that can be discharged constructively.
**Why now?** The general inequality is already formalized and sorry-free, so equality
reduces to building one explicit witness and re-running the same `‖∑ vᵢ‖²` computation with
`=` in place of `≤` — a self-contained next step requiring no new theory.

### 2. The dimension-`n` simplex bound and the kissing-number regime
Generalize `cap_packing_pi_div_three` to `Sⁿ⁻¹ ⊂ ℝⁿ`: pairwise inner product `≤ -1/n`
admits at most `n+1` centres, with the regular simplex attaining it. Then push toward the
boundary case `α → 0⁺` (inner products `≤ 0`), where the bound degenerates and the correct
maximum is `2n` (cross-polytope), demanding a strict (non-strict-inequality) refinement.
**The key insight is** that the `α → 0` degeneracy marks the exact transition from
"linear-algebra-limited" to "area-limited" packings, so the two bounds in this file should
*cross* at a critical radius `r* ≈ π/4`, which can be located explicitly.
**Why now?** `spherical_code_card_bound` is stated for an arbitrary inner-product space, so
the `n`-dimensional simplex bound is an immediate instantiation; only the cross-polytope
sharpening needs new (but elementary, sign-based) input.

### 3. A rigorous spherical surface measure for the area bound
Instantiate `measure_packing_card_mul_le` with the genuine Hausdorff/surface measure on the
unit sphere and the *proved* cap area `2π(1 - cos r)`, turning `capPackingBound` from a
named real expression into a theorem `N(2,r) ≤ 2/(1 - cos r)` about actual geodesic caps.
**The key insight is** that the cap area is the elementary integral `∫₀ʳ 2π sin t dt`, so the
measure computation factors through a single one-variable FTC application rather than full
spherical integration machinery.
**Why now?** Mathlib's `MeasureTheory` and `intervalIntegral` already provide the FTC and the
disjoint-union measure lemma used here; the abstract packing lemma is done, so only the cap
measure computation remains to close the loop end-to-end.

### 4. Linear-programming (Delsarte) bounds via Gegenbauer positivity
Replace the single quadratic test function `‖∑ vᵢ‖²` by nonnegative combinations of
Gegenbauer polynomials `Σ f_k Gₖ(⟪vᵢ,vⱼ⟫)` with `f_k ≥ 0`, recovering the Delsarte LP bound
of which `spherical_code_card_bound` is the degree-1 case.
**The key insight is** that the Gram argument here is exactly the `k = 1` term of the Delsarte
hierarchy, so the entire LP machinery is a "higher-degree `‖∑ vᵢ‖² ≥ 0`" — the same
positivity principle iterated over an orthogonal polynomial basis.
**Why now?** Mathlib has Gegenbauer/Jacobi polynomial groundwork and the degree-1 case is now
formalized as a template; formalizing the addition-formula positivity `Gₖ(⟪vᵢ,vⱼ⟫) ⪰ 0` for
small `k` would give the first machine-checked LP packing bound (e.g. `N(2,π/6) ≤ 13`,
closing in on the optimal `12`).

### 5. The conformal bridge made quantitative: weighted packing on the plane
Make the original stereographic intuition precise as a *weighted* packing statement: under
stereographic projection a cap maps to a Euclidean disk with the conformal weight
`(1+|x|²)²/4`, so spherical packing becomes weighted-density packing in `ℝⁿ`. Prove that the
weighted area bound reproduces the area bound of this file, and quantify the distortion error
term as a genuine `O(r²)` correction.
**The key insight is** that the conformal factor is a *multiplicative* distortion bounded on
each cap, so the spherical-to-planar transfer is an honest change-of-variables inequality
rather than the loose worst-case factor `(2/cos r)ⁿ` originally proposed.
**Why now?** The inverse stereographic map and its image-on-sphere identity already exist in
the catalog (`Geometry/InverseStereoResearch`, `Geometry/StereographicSheaf`); pairing them
with the measure-theoretic packing lemma proved here would for the first time connect the
catalog's stereographic algebra to a metric packing theorem.
