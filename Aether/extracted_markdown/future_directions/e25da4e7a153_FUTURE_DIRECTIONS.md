# Future Directions — Tropical Hodge Theory

## Synthesis

This cycle closed the conceptual gap in the catalog's tropical Hodge programme.
The catalog file `Tropical/HodgeDecomposition/Defs.lean` had built the *pieces* —
the `WeightedCoboundary` model of a weighted polyhedral complex, the weighted
inner product `weightedIP`, the adjunction `d ⊣ δ`, and the single kernel
identity `ker Δ↑ = ker d` — but stopped short of the decomposition theorem that
gives the whole subject its name. The new file
`Tropical/HodgeTheory/Decomposition.lean` assembles those pieces into the full
Hodge package:

* the Laplacian `Δ↑ = δ∘d` is **self-adjoint** (`laplacianUp_self_adjoint`);
* its **Rayleigh quotient** equals `‖d v‖²` and is therefore
  **positive-semidefinite** (`laplacianUp_rayleigh`, `laplacianUp_psd`);
* the **dual kernel identity** `ker Δ↓ = ker δ` (`ker_laplacianDown_eq_ker_delta`),
  the mirror of the catalog's `ker Δ↑ = ker d`;
* **orthogonality** of exact and coclosed forms, `im d ⊥ ker δ`
  (`range_d_orthogonal_ker_delta`);
* **uniqueness** of the harmonic/exact splitting (`hodge_decomp_unique`); and
* the coordinate-free **existence + uniqueness** of `F = im f ⊕ (im f)ᗮ`
  (`hodge_decomposition_abstract`, `hodge_decomposition_unique_abstract`).

The unifying discovery is that *every* analytic-looking statement in Hodge
theory here collapses to one algebraic identity, `⟨Δ x, x⟩ = ‖∂ x‖²`, plus
positive-definiteness of the weight pairing. No completeness, no elliptic
regularity, no spectral theorem is needed — the finiteness of the complex does
all the work. This is exactly the "idempotent/finite" promise that motivates
tropical Hodge theory, now realized formally.

## Results Summary

Nine theorems, zero `sorry`, only the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`). Five concrete theorems live in
the weighted-matrix model and reuse the catalog's `adjunction` and
`weightedIP_eq_zero_iff`; two abstract theorems give the reusable
inner-product-space form via Mathlib's
`sup_orthogonal_of_hasOrthogonalProjection`.

## Research Directions

### 1. Concretize existence inside the weighted-matrix model

The existence half of the decomposition is currently proved abstractly (over an
inner product space) rather than directly for `WeightedCoboundary`. The missing
step is the rank identity `im(δ∘d) = im δ`, equivalently that the normal
equation `Δ↑ u = δ w` is always solvable. **The key insight is** that
`ker(δd) = ker d` (already proved) forces `rank(δd) = rank d = rank δ`, and a
subspace contained in another of equal finite dimension must coincide, so
`im(δd) = im δ ∋ δ w`. **Why now?** All ingredients (`ker_laplacianUp_eq_ker_d`,
`Matrix.rank`, `Matrix.rank_transpose`) are already in scope; this turns the two
abstract theorems into a single self-contained `WeightedCoboundary` statement
`∀ w, ∃ u h, w = d u + h ∧ δ h = 0`, completing the picture in one file.

### 2. The full graded complex and the harmonic Künneth formula

The present model is a *two-term* complex `ℝᵐ → ℝⁿ`. Extending to a graded
chain `C⁰ → C¹ → ⋯ → Cⁿ` with `dᵏ⁺¹∘dᵏ = 0` yields harmonic spaces `Hᵏ` in
every degree, and one conjectures a **tropical Künneth isomorphism**
`H*(A ⊗ B) ≅ H*(A) ⊗ H*(B)` for the tropical product complex already defined in
`Tropical/Product.lean`. **The key insight is** that the degreewise Laplacian of
a tensor product splits as `Δ_A ⊗ I + I ⊗ Δ_B`, so a form is harmonic iff it is
a sum of tensor products of harmonic factors — the same eigenvalue-additivity
that drives heat-kernel proofs of Künneth. **Why now?** Both the graded
`d²=0` machinery (`tropD1_comp_tropD0`) and a tropical product construction
already exist in the catalog, so the conjecture is one definition
(graded `WeightedCochainComplex`) away from being statable and testable.

### 3. Hodge–Lefschetz unimodality from positive-semidefiniteness

The catalog states the Hard Lefschetz Property (`SatisfiesHLP`) only as a
predicate on Betti numbers. Conjecture: for a `WeightedCoboundary` arising from
a *balanced* fan, the harmonic Betti numbers `bᵏ = dim ker Δᵏ` form a
**unimodal** sequence, and the Lefschetz operator `L = ∧ω` is injective below
the middle degree. **The key insight is** that `laplacianUp_psd` makes each `Δᵏ`
a genuine positive-semidefinite Gram matrix `dᵀ W d`, so its nullity is
controlled by the rank of `d`, and balancedness pins those ranks into the
unimodal staircase — recasting a hard combinatorial theorem (Adiprasito–Huh–Katz)
as a statement about Gram-matrix ranks. **Why now?** With self-adjointness and
PSD now formal, `bᵏ` is a well-defined rank, so the unimodality inequality
`bᵏ ≤ bᵏ⁺¹` for `2k < n` becomes a concrete, falsifiable rank inequality testable
on the matroid examples (`U_{2,4}` → `(1,3,1)`) named in the catalog.

### 4. A weighted-inner-product `InnerProductSpace` instance bridging both models

The concrete and abstract theorems are currently linked only informally. Build
an honest `InnerProductSpace ℝ (Fin n → ℝ)` instance whose inner product *is*
`weightedIP W.tgtWeight`, and prove the matrix adjoint of `d` under it equals
`δ`. **The key insight is** that `weightedIP w` is `⟪·,·⟫` of `PiLp 2` after the
diagonal change of variables `xᵢ ↦ √wᵢ · xᵢ`, so the instance is a transported
`EuclideanSpace` and `δ = d.adjoint` becomes a one-line consequence of
`LinearMap.adjoint` uniqueness. **Why now?** It would let
`hodge_decomposition_abstract` be *applied* to `d` to discharge Direction 1
without any rank argument, unifying the two halves of this file under a single
Mathlib API.

### 5. Tropical heat flow and the spectral gap as a min-plus contraction rate

Foundations already proves the tropical Bellman operator is non-expansive
(`tropical_bellman_nonexpansive`). Conjecture: the *linear* heat semigroup
`e^{-tΔ↑}` converges to the harmonic projection at rate equal to the smallest
nonzero eigenvalue `λ₁` of `Δ↑`, and `λ₁` coincides with the tropical spectral
gap governing min-plus mixing in `Tropical/MixingTheory.lean`. **The key insight
is** that `laplacianUp_psd` gives `⟨Δ↑ v, v⟩ ≥ λ₁ ‖v - πv‖²` on the orthogonal
complement of the harmonic space, the Poincaré inequality that yields exponential
decay — and the tropical limit `t → ∞` of `−t⁻¹ log e^{−tΔ}` recovers exactly the
min-plus operator. **Why now?** PSD and the kernel characterization are precisely
the two hypotheses a Poincaré-inequality argument needs, so the linear decay rate
is now provable, giving the first rigorous bridge between the linear (heat) and
idempotent (Bellman) sides of the catalog's tropical mixing theory.
