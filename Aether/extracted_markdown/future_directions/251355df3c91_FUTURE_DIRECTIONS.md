# Future Directions — Combinatorial Hodge Theory: the Convergence Cycle

## Synthesis

This cycle closed the gap between the project's two standing pictures of combinatorial Hodge
theory on graphs. The **spectral strand** lived inside Mathlib's `SimpleGraph.lapMatrix`
machinery: the 0-Hodge Laplacian is positive semidefinite, its quadratic form is the Dirichlet
energy, and `card_connectedComponent_eq_finrank_ker_toLin'_lapMatrix` identifies the dimension
of its kernel with the zeroth Betti number `b₀` (number of connected components). The
**homological strand** wanted Betti numbers, cycle spaces, and an Euler characteristic, but had
no operator to differentiate.

`Catalog/Applications/HodgeLaplacianConvergence.lean` supplies the missing operator. We model the
oriented coboundary `d₀` as an arbitrary real "incidence" matrix `B : Matrix (Fin n) (Fin m) ℝ`
(rows = `n` vertices, columns = `m` edges) and realize the Laplacian as the Gram matrix
`L₀ = B Bᵀ`. From this single object we recover, fully `sorry`-free, the entire local theory:
the Dirichlet energy identity, positive semidefiniteness, the **discrete Hodge theorem**
(harmonic ⇔ closed-and-coclosed, both pointwise and as submodules), the co-rank identity
`rank L₀ = rank B`, and the **Euler–Poincaré formula** `b₁ + n = b₀ + m`, i.e.
`b₀ - b₁ = (#vertices) - (#edges)`.

The decisive observation is that *none of this needs a graph*. Rank–nullity plus row-rank =
column-rank delivers Euler–Poincaré with no subtraction and no orientation choice; reality of
the field (sum of squares vanishes ⇒ each term vanishes) is the *only* analytic ingredient, and
it is exactly what powers the Hodge theorem. The result is a dimension-uniform, orientation-free
core on which the graph-specific spectral results become corollaries.

## Results Summary

| Theorem | Statement | Role |
|---|---|---|
| `dirichlet_energy` | `xᵀ L₀ x = ∑ₑ (Bᵀx)ₑ²` | foundational energy identity |
| `hodgeLaplacian_posSemidef` | `(B Bᵀ).PosSemidef` | positivity |
| `harmonic_iff_coboundary_zero` | `L₀x = 0 ⇔ Bᵀx = 0` | discrete Hodge theorem (pointwise) |
| `ker_hodgeLaplacian_eq_ker_coboundary` | `ker L₀ = ker d₀ᵀ` | discrete Hodge theorem (submodule) |
| `hodgeLaplacian_rank` | `rank L₀ = rank B` | co-rank identity |
| `euler_poincare` | `b₁ + n = b₀ + m` | Euler–Poincaré / Euler characteristic |

All six are proved with no `sorry` and depend only on `import Mathlib`.

## Research Directions

### 1. Connect the abstract coboundary to Mathlib's `lapMatrix` and certify `b₀ = #components`.

Build the oriented incidence matrix `B_G` of a `SimpleGraph G` (one column per edge, entries
`+1/-1` at the endpoints) and prove `B_G * B_Gᵀ = G.lapMatrix ℝ`. Combined with this cycle's
`ker_hodgeLaplacian_eq_ker_coboundary` and Mathlib's
`card_connectedComponent_eq_finrank_ker_toLin'_lapMatrix`, this would upgrade the abstract
`b₀ = dim ker d₀ᵀ` into the genuinely topological `b₀ = #connected components`, and turn
`euler_poincare` into the classical statement `#components − dim(cycle space) = |V| − |E|`.
**The key insight is** that the Gram factorization `lapMatrix = B Bᵀ` is the precise bridge that
makes the spectral kernel (Mathlib) and the homological cycle space (this file) literally the
same vector space, so no new analysis is required — only the bookkeeping of an orientation.
**Why now?** This cycle just proved both halves (`ker L₀ = ker Bᵀ` here; `ker lapMatrix ≅ ℝ^{components}` in Mathlib); only the one-line matrix identity `B Bᵀ = lapMatrix` is missing to fuse them.

### 2. Prove the orthogonal Hodge decomposition `C¹ = im d₀ ⊕ ker d₀ᵀ`.

Promote the *dimension-level* decomposition (implicit in `euler_poincare`) to a genuine
orthogonal direct sum on `EuclideanSpace ℝ (Fin m)`: `(ker B.mulVecLin)ᗮ = range Bᵀ.mulVecLin`,
so every 1-cochain splits uniquely as a gradient plus a harmonic/cycle component.
**The key insight is** that over a real inner-product space the adjoint of `toEuclideanLin B` is
`toEuclideanLin Bᵀ`, so the abstract identity `(ker f)ᗮ = range fᵀ` specializes directly — the
combinatorics is already done, what remains is transporting the matrix operators into
`EuclideanSpace`. **Why now?** `harmonic_iff_coboundary_zero` already isolates the harmonic
subspace as `ker d₀ᵀ`; the orthogonal complement statement is the natural geometric closure of
the very identity we proved, and Mathlib's finite-dimensional adjoint API is in place.

### 3. Higher Hodge Laplacians and a `k`-cochain Euler characteristic.

Replace the single operator `B` by a length-two chain `C² →^{d₁} C¹ →^{d₀} C⁰` with `d₀ ∘ d₁ = 0`
and define the middle Hodge Laplacian `L₁ = d₀ᵀ d₀ + d₁ d₁ᵀ`. Prove `L₁` positive semidefinite,
the harmonic decomposition `ker L₁ = ker d₀ ∩ ker d₁ᵀ`, and the alternating-sum Euler identity
`b₀ - b₁ + b₂ = n₀ - n₁ + n₂`. **The key insight is** that the two-term proof here already
contains the inductive seed: each `Lₖ` is again a sum of Gram matrices, so positivity and the
"harmonic = closed ∩ coclosed" theorem are *the same* sum-of-squares argument applied twice, and
the Euler alternating sum is rank–nullity telescoped along the complex. **Why now?** We have a
clean, orientation-free length-one template (`B`); generalizing to a cochain complex with
`d ∘ d = 0` is the canonical next dimension and reuses every lemma in this file verbatim.

### 4. Spectral gap ⇒ connectivity (algebraic connectivity / Fiedler bound).

Use `hodgeLaplacian_posSemidef` and `harmonic_iff_coboundary_zero` to prove that the second
smallest eigenvalue `λ₂(L₀)` is strictly positive **iff** `dim ker L₀ = 1`, i.e. iff the graph
is connected, giving a Lean formalization of the Fiedler "algebraic connectivity" criterion.
**The key insight is** that `ker L₀ = ker d₀ᵀ` reduces the multiplicity of the eigenvalue `0` to
a *purely combinatorial* count (`b₀`), so the spectral gap statement becomes a statement about
the rank of `B` — exactly the quantity this cycle controls. **Why now?** Mathlib's `PosSemidef`
spectral theory plus `card_connectedComponent_eq_finrank_ker_toLin'_lapMatrix` gives the
eigenvalue-`0` multiplicity for free; the only new content is the strict-positivity of the next
eigenvalue, which the energy identity `dirichlet_energy` is built to expose.

### 5. Stress-test failure over non-real fields: classify when `BBᵀx = 0` but `Bᵀx ≠ 0`.

The Hodge theorem `harmonic_iff_coboundary_zero` is *false* over fields admitting isotropic
vectors (e.g. `ℂ` with the bilinear, non-Hermitian form, or `𝔽_p`). Prove an explicit
counterexample matrix `B` over `ZMod p` (or `ℚ(i)` with the symmetric form) where
`B Bᵀ x = 0` yet `Bᵀ x ≠ 0`, and conversely characterize exactly the fields/forms for which the
implication survives (real-closed, or any formally real field). **The key insight is** that the
entire analytic strength of combinatorial Hodge theory is concentrated in one inequality —
`∑ aᵢ² = 0 ⇒ aᵢ = 0` — so its failure set *is* the failure set of formal reality, making the
counterexample search a sharp adversarial probe of the theory's boundary. **Why now?** This cycle
explicitly flagged reality as the sole analytic hypothesis; turning that remark into a proved
counterexample (and a positive characterization) is the adversarial ground-truth obligation the
engine is configured to discharge.
