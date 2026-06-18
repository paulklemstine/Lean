# Discrete Hodge Program — Future Directions

This cycle established a **self-contained discrete Hodge foundation** in
`Combinatorics/DiscreteHodge/Core.lean`, built directly on Mathlib's
finite-dimensional `LinearMap.adjoint`:

- the Weitzenböck/Bochner identity `⟪Δx,x⟫ = ‖Aᵀx‖² + ‖Bx‖²`;
- the harmonic characterization `Δx = 0 ↔ closed ∧ co-closed`;
- the three-piece Hodge decomposition `V = range A ⊕ harmonic ⊕ range Bᵀ`;
- the Hodge isomorphism `harmonic ≃ ker B / range A` (homology);
- the combinatorial payoff: the cut-space ⊕ cycle-space decomposition of a finite
  graph's edge space, with `dim cut + dim cycle = |E|` (cycle rank / first Betti
  number).

The conjectures below are concrete and testable in follow-up cycles.

## C1. Full-length Hodge complexes (arbitrary degree `k`)

Generalize the two-map segment `U →A V →B W` to a finite cochain complex
`C⁰ → C¹ → ⋯ → Cⁿ` with `dₖ₊₁ ∘ dₖ = 0` and inner products on every `Cₖ`.
**Conjecture:** with `Δₖ = dₖ dₖᵀ + dₖ₊₁ᵀ dₖ₊₁`, the harmonic space
`ker Δₖ` is linearly isomorphic to the `k`-th homology `ker dₖ ⧸ range dₖ₋₁`,
and `Cₖ = range dₖ₋₁ ⊕ ker Δₖ ⊕ range dₖ₊₁ᵀ` orthogonally — recovering the present
file as the `n = 1` case. Testable milestone: derive `harmonic_equiv_homology` for
each `k` purely by iterating the two-step lemmas already proved.

## C2. Combinatorial Hodge index / Euler characteristic

For a finite cochain complex as in C1, define Betti numbers `bₖ = finrank (ker Δₖ)`.
**Conjecture:** `∑ₖ (-1)ᵏ bₖ = ∑ₖ (-1)ᵏ dim Cₖ` (Euler–Poincaré), and in the graph
case this specializes to `b₀ - b₁ = |V| - |E|`, i.e. `b₁ = |E| - |V| + b₀` where
`b₀` is the number of connected components. Testable: instantiate the graph
incidence matrix and prove `finrank (cycleSpace B) = |E| - |V| + (number of
components)` by combining `finrank_cut_add_cycle` with `rank` of the incidence
matrix = `|V| - (#components)`.

## C3. Spectral gap ⇒ small harmonic space (quantitative Hodge)

The Laplacian `Δ` is self-adjoint and PSD (`⟪Δx,x⟫ ≥ 0` is immediate from the
Weitzenböck identity already proved). **Conjecture:** if the smallest nonzero
eigenvalue of `Δ` (the spectral gap) is `λ > 0`, then for every `x`,
`dist(x, harmonic)² ≤ ⟪Δx,x⟫ / λ`. This makes "almost harmonic ⇒ almost
cohomologous to a harmonic representative" quantitative. Testable: prove the
PSD lemma `0 ≤ ⟪Δx,x⟫` as a one-liner from `inner_laplacian_self`, then the bound
via the spectral theorem (`LinearMap.IsSymmetric.orthogonalProjection`/eigenbasis).

## C4. Weighted / matroid duality of cuts and cycles

Replace the standard inner product on `Cₖ` by a positive-definite weighted inner
product (positive edge weights `w`). **Conjecture:** the weighted cut space and
weighted cycle space remain orthogonal complements, and the orthogonal projector
onto the cycle space is the network's *current-flow* operator; for the uniform
weight it reduces to `hodge_graph_isCompl`. Sharper testable form: the determinant
of the weighted Laplacian `dᵀ W d` restricted to a spanning-tree complement equals
the weighted spanning-tree count (a weighted Matrix–Tree statement), linking the
present file to `Tropical/ChipFiring`.

## C5. Discrete Hodge ↔ Baker–Norine bridge

The existing `Tropical/ChipFiring` divisor theory uses the *integer* Laplacian
`lap G`. **Conjecture:** the real cycle space `cycleSpace B` of this file is the
tensor-up `ℝ ⊗ (lattice of integer cycles)`, and the kernel of `lap G` over `ℝ`
is exactly the constants iff the graph is connected; consequently the genus
`g = |E| - |V| + 1` of `ChipFiring/Defs.lean` equals `finrank (cycleSpace B)` for a
connected graph. Testable: prove `finrank (cycleSpace B) = genus G` under a
connectivity hypothesis, directly connecting the two Catalog developments.
