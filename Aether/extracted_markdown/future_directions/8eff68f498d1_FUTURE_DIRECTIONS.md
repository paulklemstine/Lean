# Future Directions — Tropical Moduli, Edge Contraction, and the Tropical Jacobian Form

## Synthesis

This cycle extends the numerical backbone of the tropical moduli space `M_g^trop`
(the `StableType` structure of `Catalog/Applications/TropicalModuliDimension.lean`,
with its `genus_formula`, `stability`, `connected`, and the bounds `vertex_bound`,
`edge_bound`, `jacobianDim_eq`) in two complementary directions, each realising one
of the previous cycle's conjectures.

* **Edge contraction (`Catalog/Applications/TropicalModuliContraction.lean`).**  The
  defining gluing of the generalized cone complex `M_g^trop` — sending an edge length
  to `0` — is realised as two explicit total maps on `StableType`: `contractNonLoop`
  (merge two vertices) and `contractLoop` (absorb a vanishing cycle into a vertex
  weight).  Both *preserve genus by `rfl`*; a non-loop move fixes the tropical
  Jacobian dimension, a loop move drops it by exactly one; and the edge count is a
  strict termination measure.  This confirms Direction 3 of the prior cycle: because
  the genus identity `g + v = e + 1 + W` is additive, the boundary stratification is
  governed by structural `omega`/`rfl` facts, not geometry.

* **Tropical Jacobian form (`Catalog/Applications/TropicalJacobianForm.lean`).**  The
  scalar `jacobianDim = b₁ = g − W` is upgraded to its metric incarnation, the
  edge-length quadratic form `Q ℓ γ = Σ_e ℓ(e) γ(e)²` — the principal polarization of
  the tropical Jacobian.  We prove it positive semidefinite for non-negative lengths
  (`jacobianForm_nonneg`), positive definite for strictly positive lengths
  (`jacobianForm_eq_zero_iff_of_pos`, `jacobianForm_pos_of_ne_zero`).  This confirms
  Direction 2: the "Torelli image lands in `A_g^trop`" half is a finite sum of
  squares, orthogonal to the rank theorem.

The unifying discovery across both files: once `M_g^trop` is recorded additively,
its *combinatorial dynamics* (contraction, stratification, termination) are linear
arithmetic, while its *metric/Torelli data* (the Jacobian polarization) is elementary
sum-positivity. The two layers never interfere, which is what makes the whole theory
mechanizable.

## Results Summary

* `StableType.contractNonLoop`, `StableType.contractLoop` — edge contraction as total
  maps on combinatorial types, under the geometric side-conditions "an edge exists"
  and (for a loop) "a cycle exists, `v ≤ e`".
* `StableType.genus_contractNonLoop`, `genus_contractLoop` — genus is preserved (`rfl`).
* `StableType.jacobianDim_contractNonLoop` — non-loop contraction preserves `b₁`.
* `StableType.jacobianDim_contractLoop` — loop contraction drops `b₁` by exactly one.
* `StableType.edges_contractNonLoop_lt`, `edges_contractLoop_lt` — `edges` is a strict
  termination measure for any contraction chain (length `≤ e ≤ 3g − 3`).
* `jacobianForm` with `jacobianForm_nonneg` (PSD), `jacobianForm_eq_zero_iff_of_pos`
  (positive definite vanishing criterion), `jacobianForm_pos_of_ne_zero`.

All main results are `sorry`-free and use only `propext`, `Classical.choice`,
`Quot.sound`.

## Bold, Falsifiable Research Directions

### 1. Genus-pure contraction posets and a "top type reaches every type" theorem
Define the reflexive-transitive closure of `contractNonLoop`/`contractLoop` as a
relation `≼` on `StableType`s of a fixed genus `g`, and conjecture that `topType g`
(the trivalent type with `e = 3g − 3`) dominates every genus-`g` type: every legal
type is a finite iterate of contractions of the top type. **The key insight is** that
each contraction strictly decreases `edges` (`edges_contractNonLoop_lt`,
`edges_contractLoop_lt`) while preserving genus, so the poset is graded by
`(3g − 3) − e` and well-founded, turning "reaches every type" into a finite downward
induction on the edge gap. *Why now?* The contraction maps, genus invariance, and the
strict edge measure are all proved, so the poset is definable and its grading is a
ready-made well-founded recursion — only the surjectivity step remains.

### 2. The cographic / cycle lattice realising the Jacobian form's rank
The form `jacobianForm` is currently defined over all of `E → ℝ`; embed the genuine
cycle lattice `ℤ^{b₁} ↪ ℝ^E` and prove the restricted form has rank exactly
`b₁ = g − W`, matching `jacobianDim_eq`. **The key insight is** that the cycle space
is the kernel of the (graph) boundary map, a `LinearMap` whose rank-nullity over the
finite edge set gives `b₁` directly, so pairing `jacobianForm_pos_of_ne_zero`
(definiteness on the lattice) with rank-nullity pins the rank without spectral theory.
*Why now?* Definiteness on nonzero cycles is already proved and Mathlib's
`LinearMap.rank`/rank-nullity API is mature, so the only new object is the explicit
incidence/boundary matrix of a realising `SimpleGraph`.

### 3. A `Fintype` of genus-`g` combinatorial types, refined by contraction
Upgrade `stableTypes_finite` (a `Set.Finite` on invariant vectors) to a `Fintype`
instance and show the contraction maps act *within* this finite type, giving a finite
directed graph whose sinks are the genus-`g` "stable cores" (no contractible edge).
**The key insight is** that `vertex_bound` and `edge_bound` confine every type to a
fixed finite box, so `Fintype.ofFinset` plus decidability of `IsGenusType` makes the
type computable, and contraction becomes an endo-function on a `DecidableEq Fintype` —
its iteration is then a terminating computation. *Why now?* Finiteness and the explicit
box `Icc (0,0,0,0) (2g,2g,3g,g)` are already proved, so only the `DecidablePred` and
`Fintype.ofFinset` plumbing is missing, all standard Mathlib.

### 4. Berkovich-skeleton contractibility via tropical scaling on the cones
Equip each cone `σ_S = ℝ_{≥0}^{e}` (edge lengths of a type `S`) with the scaling
homotopy `ℓ ↦ t·ℓ`, `t ∈ [0,1]`, contracting to the apex, and prove each cone is
contractible; then conjecture the glued complex (cones identified along contraction,
Direction 1) is contractible of pure dimension `3g − 3`. **The key insight is** that
the apex homotopy is `ContinuousMap`-level max-plus homogeneity — a straight-line
homotopy in `ℝ^e` — so per-cone contractibility is `Convex.contractible` of the
nonnegative orthant, and the dimension is exactly `edge_bound`. *Why now?* The
dimension formula is sharp (`topType_edge_bound_sharp`) and the gluing maps now exist
(this cycle's contractions), so the metric realisation reduces to assembling
contractible convex cones along proven face maps.

### 5. Functoriality of the Jacobian form under loop contraction
Conjecture that loop contraction is *compatible* with the Jacobian polarization: the
form `jacobianForm` of the contracted type is the restriction of the original form to
the codimension-one cycle sublattice killing the contracted loop, consistent with
`jacobianDim_contractLoop` dropping `b₁` by one. **The key insight is** that deleting a
loop edge `e₀` from the sum `Σ_e ℓ(e) γ(e)²` is literally `Finset.sum_erase`, so
"contraction restricts the form" is the additivity of a finite sum over `univ.erase e₀`
paired with the already-proved rank drop. *Why now?* Both halves — the scalar rank drop
(`jacobianDim_contractLoop`) and the sum-of-squares form — are in hand, so their
compatibility is a single `Finset.sum_erase` bridging this cycle's two files into one
Torelli-functoriality statement.
