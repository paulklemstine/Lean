# Future Directions — Tropical Convexity: Helly, Caratheodory, Radon

## Synthesis

This cycle laid down a clean, self-contained first-principles foundation for
**tropical (min-plus) convexity** over `Fin n → ℝ`, located in
`Tropical/ConvexityHellyCaratheodory.lean`. Rather than re-importing a missing
`Tropical.Defs` module (the previously catalogued `Catalog/Tropical/Convexity.lean`
depends on a `Tropical.Defs` file that is absent from the repository and therefore
does not build), we rebuilt the theory directly on top of Mathlib so that every
statement is machine-checked end to end.

The organising object is the **tropical combination**
`tropComb a b x y = fun i => min (a + xᵢ, b + yᵢ)`, and a set is *tropically
convex* exactly when it is closed under all such combinations. From this single
definition we derived the standard structural toolkit (closure under arbitrary
intersections, convexity of halfspaces and segments) and the canonical
**tropical convex hull** as the intersection of all convex supersets, proving it
is the smallest such set — a Caratheodory-style minimality statement.

The conceptual payoff is the **dimension-one classification**: every nonempty
tropically convex subset of the tropical line is the *entire* line, because
tropical scaling shifts all coordinates simultaneously and hence acts transitively
on a single coordinate. This immediately yields a **tropical Helly theorem in
dimension one with Helly number 1** — strictly sharper than the classical interval
Helly number 2, and a phenomenon with no Euclidean analogue.

## Results Summary

Proved (sorry-free, axioms `propext`/`Classical.choice`/`Quot.sound` only):

- `isTropicallyConvex_iInter`, `isTropicallyConvex_univ` — closure under intersections and the ambient space.
- `tropMin_tropComb_le`, `le_tropMin_tropComb` — two-sided control of `tropMin` along combinations.
- `isTropicallyConvex_tropicalHalfspace` — tropical halfspaces are convex.
- `isTropicallyConvex_tropSegment`, `tropSegment_mem_left`, `tropSegment_mem_right` — tropical segments are convex and contain both endpoints (Caratheodory with two generators).
- `isTropicallyConvex_tropConvexHull`, `subset_tropConvexHull`, `tropConvexHull_minimal` — the hull is convex, contains its generators, and is minimal.
- `tropicallyConvex_dim_one` — dimension-one classification.
- `tropicalHelly_dim_one` — dimension-one tropical Helly theorem (Helly number 1).

## Research Directions

### 1. Tropical Caratheodory with the sharp generator bound `n`

The hull `tropConvexHull V` is currently defined abstractly as an intersection.
The classical tropical Caratheodory theorem (Develin–Sturmfels) asserts that every
point of the hull of a set `V ⊆ TPⁿ⁻¹` is already a tropical combination of at most
`n` points of `V`. **The key insight is** that the coordinatewise `min` structure
lets one read off, for each coordinate `i`, a single generator achieving the
minimum, so a point in the hull is "witnessed" by at most `n` generators — one per
coordinate. **Why now?** We already have `tropComb`, `tropConvexHull`, and the
minimality lemma `tropConvexHull_minimal`; formalising the explicit finite-span
description and proving it equals the abstract hull is the natural next brick, and
the coordinate-witness argument is concrete and falsifiable (test it on random
finite `V` via `#eval` before proving).

### 2. Tropical Radon in low dimension and the partition map

Radon's theorem states that any `n + 2` points in tropical `n`-space can be split
into two groups whose tropical convex hulls intersect. **The key insight is** that
the intersection point can be located by a min-plus "balancing" condition: assign
each point to the group on which it is coordinatewise dominant, and the shared
boundary supplies the common hull point. **Why now?** With segments and hulls in
place, the `n = 1` case (any 3 points on the line, where every nonempty convex set
is the whole line) is essentially immediate from `tropicallyConvex_dim_one`, giving
a verified base case from which to attempt `n = 2` and conjecture the general
balancing partition.

### 3. The exact tropical Helly number in every dimension

We proved Helly number `1` on the line. The conjecture (Gaubert–Sergeev) is that
the tropical Helly number in `TPⁿ⁻¹` is exactly `n`. **The key insight is** that
tropical Helly should reduce to feasibility of min-plus inequality systems: a family
of tropical halfspaces has a common point iff every `n`-element subsystem does,
because feasibility is governed by `n` coordinatewise tightness conditions. **Why
now?** `isTropicallyConvex_tropicalHalfspace` plus the `tropMin` distribution lemmas
give exactly the algebra needed to phrase subsystem feasibility, and the dimension-one
theorem (`tropicalHelly_dim_one`) already confirms the bound `n` at `n = 1`,
pinning the induction's base.

### 4. Singletons, projectivisation, and the right ambient space

Our dimension-one classification exposes that singletons are **not** tropically
convex in `Fin n → ℝ` (since `min (a, b) + p` ranges over all reals). **The key
insight is** that genuine tropical convexity lives in the *tropical projective
torus* `ℝⁿ / ℝ·𝟙`, where tropical scaling is quotiented out and points become
genuine convex atoms. **Why now?** Re-deriving the entire toolkit over the quotient
(a `Setoid` on `Fin n → ℝ` modulo the diagonal `ℝ`-action) would make singletons
convex, recover the expected Helly number `n`, and align the formalisation with the
literature — and the quotient is a small, well-understood Mathlib construction.

### 5. Tropical convexity ↔ ordinary convexity bridge via Maslov dequantisation

Min-plus arithmetic is the `ℏ → 0` limit of `x ⊕_ℏ y = -ℏ log(e^{-x/ℏ} + e^{-y/ℏ})`.
**The key insight is** that each tropically convex set should arise as a Hausdorff
limit of ordinary log-convex sets, so classical Helly/Caratheodory/Radon could be
*transported* to the tropical world by a single dequantisation argument rather than
re-proved combinatorially. **Why now?** The structural theorems proved here
(intersection closure, halfspace convexity, hull minimality) are exactly the
"limit-stable" properties one would check survive the dequantisation, making this a
concrete cross-domain bridge between the Tropical catalog and Mathlib's existing
convex-analysis library.
