# Future Directions: Finite Tropical Hodge Theory

## Synthesis

This research cycle closed the gap between the catalog's *static* tropical-Hodge
scaffolding (`Catalog/Tropical/HodgeDecomposition/Defs.lean` — the
`WeightedCoboundary` structure, the `adjunction` theorem, and the single
kernel characterization `ker_laplacianUp_eq_ker_d`) and an actual *spectral*
and *multi-degree* theory.

Two new files were produced, both compiling with **zero `sorry`** and using only
the standard axioms (`propext`, `Classical.choice`, `Quot.sound`):

* `Catalog/Tropical/HodgeDecomposition/Decomposition.lean` — the spectral
  side of a single weighted coboundary `d : ℝ^m → ℝ^n`:
  the Dirichlet **energy identity** `⟨Δᵘᵖ u, u⟩_src = ⟨d u, d u⟩_tgt`
  (`laplacianUp_energy`), **Rayleigh non-negativity**
  (`laplacianUp_energy_nonneg`) and **strict positivity off `ker d`**
  (`rayleigh_quotient_pos`), **self-adjointness** of the Laplacian
  (`laplacianUp_self_adjoint`), **coexact ⊥ closed** orthogonality
  (`closed_orthogonal_coexact`), and the dual **down** energy identity and
  kernel characterization `ker(Δᵈᵒʷⁿ) = ker(δ)` (`laplacianDown_energy`,
  `ker_laplacianDown_eq_ker_delta`).

* `Catalog/Tropical/HodgeDecomposition/MultiDegree.lean` — the genuine
  two-step complex `ℝ^l →d₀ ℝ^m →d₁ ℝ^n` with `d₁ ∘ d₀ = 0`
  (`WeightedTwoStep`), the **full Hodge Laplacian**
  `Δ = d₀ δ₀ + δ₁ d₁` (`hodgeLaplacian`), the **exact ⊥ coexact** cross-term
  vanishing (`exact_orthogonal_coexact`), the **Hodge energy split**
  `⟨Δ u, u⟩ = ‖d₁ u‖² + ‖δ₀ u‖²` (`hodgeLaplacian_energy`), the
  **Hodge–Kodaira kernel identity** `ker Δ = ker d₁ ∩ ker δ₀`
  (`hodgeLaplacian_kernel`), and self-adjointness of the full Laplacian
  (`hodgeLaplacian_self_adjoint`).

The unifying lesson: in finite dimensions over ℝ with positive-definite weighted
inner products, the entire Hodge package is a *corollary of one adjunction* plus
positive definiteness. The chain condition `d₁ d₀ = 0` enters in exactly one
place — the vanishing of the exact/coexact cross term — and nowhere else.

## Results Summary

| Theorem | Statement | File |
|---|---|---|
| `laplacianUp_energy` | `⟨Δᵘᵖ u, u⟩_src = ⟨d u, d u⟩_tgt` | Decomposition |
| `rayleigh_quotient_pos` | `d u ≠ 0 ⇒ ⟨Δᵘᵖ u, u⟩ > 0` | Decomposition |
| `laplacianUp_self_adjoint` | `⟨Δᵘᵖ u, v⟩ = ⟨u, Δᵘᵖ v⟩` | Decomposition |
| `ker_laplacianDown_eq_ker_delta` | `ker(Δᵈᵒʷⁿ) = ker(δ)` | Decomposition |
| `hodgeLaplacian_energy` | `⟨Δ u, u⟩ = ‖d₁ u‖² + ‖δ₀ u‖²` | MultiDegree |
| `hodgeLaplacian_kernel` | `ker Δ = ker d₁ ∩ ker δ₀` | MultiDegree |

## Direction 1 — The three-way orthogonal decomposition `C = im d₀ ⊕ im δ₁ ⊕ ker Δ`

We now have all three pairwise orthogonality facts (`closed_orthogonal_coexact`,
`exact_orthogonal_coexact`) and the harmonic characterization
(`hodgeLaplacian_kernel`). The missing step is the *direct-sum* statement: the
middle cochain space `ℝ^m`, as an inner-product space for the middle weight,
equals the internal orthogonal direct sum of `im d₀`, `im δ₁`, and the harmonic
subspace `ker Δ`. Falsifiable form: for the explicit two-step complex coming from
a triangle (3 vertices, 3 edges, 1 face) with unit weights, the dimensions must
satisfy `dim(im d₀) + dim(im δ₁) + dim(ker Δ) = m` with all three summands
mutually orthogonal.

The key insight is that the *rank–nullity theorem combined with the three
already-proved orthogonalities forces the direct sum* — no surjectivity argument
is needed, because `(im d₀ ⊕ im δ₁)^⊥ = ker δ₀ ∩ ker d₁ = ker Δ` follows from the
energy split alone. Why now? Mathlib's `Submodule.orthogonal`,
`Submodule.isCompl_orthogonal_of_completeSpace`, and finite-dimensional
`Submodule.finrank_add_finrank_orthogonal` are exactly the API needed, and the
weighted inner product can be packaged as an `InnerProductSpace` instance via the
positive-definite `weightedIP` we already proved.

## Direction 2 — Betti number `β₀ = dim ker Δ` and the combinatorial Hodge index

`hodgeLaplacian_kernel` identifies harmonic cochains with `ker d₁ ∩ ker δ₀`, the
finite-dimensional model of a cohomology group. The conjecture: for a
`WeightedGraph` (the catalog's special case, `WeightedGraph.toWeightedCoboundary`)
that is connected, `dim ker(graphLaplacian) = 1`, and in general it equals the
number of connected components — the zeroth Betti number `β₀`. Falsifiable:
for the disjoint union of two triangles, `dim ker = 2`.

The key insight is that *the kernel of the Laplacian is spanned exactly by the
indicator vectors of connected components*, a statement that reduces — via our
`ker_laplacianUp_eq_ker_d` — to `ker(incidence) = locally-constant functions`,
which is pure graph combinatorics with no spectral input. Why now? The kernel
characterization removes all analysis; what remains is a `SimpleGraph`
connectivity argument, and Mathlib's `SimpleGraph.ConnectedComponent` plus
`Matrix.rank` machinery is mature enough to carry it.

## Direction 3 — Weighted Courant–Fischer and a tropical spectral gap

`rayleigh_quotient_pos` shows the Rayleigh quotient is strictly positive off
`ker d`; the natural quantitative refinement is a **min–max (Courant–Fischer)
characterization** of the smallest nonzero eigenvalue `λ₁` of `Δᵘᵖ` as the
minimum of `⟨Δ u, u⟩ / ⟨u, u⟩` over `u ⟂ ker Δ`. Falsifiable prediction: for the
path graph on 3 vertices with unit weights, `λ₁ = 1` and the minimizing vector is
`(1, 0, -1)`.

The key insight is that *self-adjointness (`laplacianUp_self_adjoint`) plus the
energy identity turns the spectral problem into a constrained optimization that
the finite-dimensional spectral theorem solves directly* — the weighted inner
product only rescales, it never obstructs. Why now? With self-adjointness in
hand, Mathlib's `LinearMap.IsSymmetric.eigenvalue` / `Matrix.IsHermitian`
spectral theorem applies after transporting `Δᵘᵖ` to a genuine self-adjoint
operator on the weighted space, giving a real, ordered spectrum for free.

## Direction 4 — Hodge decomposition is *false* without weight compatibility

A sharp falsifiable boundary of the theory: the structure `WeightedTwoStep`
imposes `middle_compat : W0.tgtWeight = W1.srcWeight`. The conjecture is that
this hypothesis is **load-bearing and not removable** — there exists a two-step
complex with `d₁ d₀ = 0` but *incompatible* middle weights for which the energy
split `⟨Δ u, u⟩ = ‖d₁ u‖² + ‖δ₀ u‖²` fails. Falsifiable: exhibit explicit
`1 → 1 → 1` data with `W0.tgtWeight = (2)`, `W1.srcWeight = (3)` and a vector `u`
with `⟨Δ u, u⟩ ≠ ‖d₁ u‖² + ‖δ₀ u‖²`, then prove the inequality in Lean.

The key insight is that *the two adjunctions live in two a-priori different inner
products on the same middle space, and only their identification makes `Δ`
self-adjoint*; dropping it produces a non-self-adjoint "Laplacian" whose
energy no longer splits into squares. Why now? Our proof isolates the single use
of `middle_compat` (in both `hodgeLaplacian_energy` and
`hodgeLaplacian_self_adjoint`), so constructing and verifying the counterexample
is a small, self-contained `Fin 1` computation — the cleanest possible test that
the hypothesis is genuinely necessary.
