# Future Directions — Non-Well-Founded Proofs in Geometry

Research theme: **"Non-Well-Founded Proofs: Proofs That Reference Themselves"**, domain **Geometry**.

Across two cycles we established the thesis that *self-reference / non-well-foundedness =
self-similarity*, realized by two formal engines — **coinductive data** (`Stream'`, `corec`)
and **contraction fixed points** (`x* = f x*`) — and unified the geometric series, the affine
attractor, and the (golden / metallic) continued fractions as one phenomenon: *a quantity
that is the unique solution of its own equation*. All results live, fully verified, in
`SelfSimilar.lean`.

**Status of earlier conjectures (now closed):**
- **C3 (bisimulation rigidity)** — PROVED (`selfSimilar_unique`): the self-similarity law
  `map (· * r) s = s.tail` with fixed head characterizes `geomStream a r` uniquely.
- **C4 (metallic ratios)** — PROVED (`metallicRatio_sq`, `metallicRatio_selfReferential`,
  `metallicGnomon_selfSimilar`, `metallicRatio_one`): the golden lemmas generalize to the
  whole family `φ_m = (m + √(m²+4))/2`.
- **C5 (similarity dimension)** — core PROVED (`simDim_spec`, `simDim_pos`): `D = log k/log(1/r)`
  solves `k·r^D = 1` and is positive; *monotonicity remains open* (see D3 below).

The following are the bold, falsifiable conjectures for subsequent cycles.

## Conjecture D1 — IFS attractor in ℝⁿ via Banach (multidimensional self-reference)
For an affine contraction `f x = A x + b` on `EuclideanSpace ℝ (Fin n)` with operator norm
`‖A‖ < 1`, there is a **unique** self-referential point `x* = f x*`, every orbit
`f^[k] x₀ → x*`, and `‖f^[k] x₀ - x*‖ ≤ ‖A‖^k · ‖x₀ - x*‖`.
*Test:* lift `affine_fixed`, `affine_fixed_unique`, `affine_iterate_error`,
`affine_tendsto_fix` from `ℝ` to `ℝⁿ`, ideally through Mathlib's `ContractingWith`/`edist`
API. Falsified if no `ℝⁿ` statement closes under just `‖A‖ < 1`.

## Conjecture D2 — Coinductive geometric trees and self-similar measure
Define an infinite binary **coinductive tree** whose node at depth `d` carries scale `r^d`.
Conjecture: the depth-`d` level holds `2^d` copies of scale `r^d`, and the total-measure
recursion `M = 1 + 2 r · M` has the self-referential closed form `M = 1/(1 - 2r)` for
`2r < 1` — the tree analogue of `geometricSum_selfReferential`. *Test:* build the tree with
`corec`, prove the level identity by induction and the measure equation by the fixed-point
uniqueness pattern of `geometricSum_unique`.

## Conjecture D3 — Monotonicity of the similarity dimension
The similarity dimension `simDim k r = log k / log(1/r)` is strictly increasing in `k`
(for `0 < r < 1`) and strictly increasing in `r` on `(0,1)` (for `k ≥ 2`). Moreover it is the
*unique* real solving `k·r^D = 1`. *Test:* prove both monotonicities and uniqueness of the
exponent; falsified if either monotonicity reverses on any admissible `(k, r)`.

## Conjecture D4 — Mixed-ratio IFS and the Moran equation
For a finite list of ratios `r₁,…,r_k ∈ (0,1)`, the similarity dimension is the unique `D`
solving the **self-referential Moran equation** `∑ᵢ rᵢ^D = 1`. Conjecture: the left side is
continuous and strictly decreasing in `D`, equals `k > 1` at `D = 0` and `→ 0` as `D → ∞`, so
a unique root exists, and it reduces to `simDim` when all `rᵢ = r`. *Test:* prove existence,
uniqueness, and the uniform-ratio reduction via the intermediate value theorem + strict
antitonicity.

## Conjecture D5 — Banach contraction on the space of compact sets (Hutchinson attractor)
The IFS operator `F(K) = ⋃ᵢ fᵢ(K)` on the complete metric space of nonempty compact subsets
of `ℝⁿ` under the **Hausdorff metric** is a contraction when each `fᵢ` is, hence has a unique
self-referential compact set `K* = F(K*)` — the genuine fractal attractor, the set-level
`x* = f x*`. *Test:* assemble the Hausdorff-metric completeness + contraction estimate and
invoke Banach; falsified if the operator fails to contract under `maxᵢ Lip(fᵢ) < 1`.
