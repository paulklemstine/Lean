# Future Directions — Discrete Hodge Program

This cycle delivered, under `Catalog/Shared/DiscreteHodgeDecomposition.lean`, a
self-contained Mathlib foundation for the **discrete Hodge decomposition** of a
two-step cochain complex `U --e--> V --d--> W` of finite-dimensional real
inner-product spaces, with Hodge Laplacian `Δ = d*d + e e*`:

* `hodgeLap_quadratic_form` — the Dirichlet sum-of-squares identity;
* `hodgeLap_apply_eq_zero_iff` / `mem_harmonicSpace_iff` — harmonic ⇔ closed & co-closed;
* `exact_isOrtho_coExact`, `coExact_isOrtho_harmonic`, `exact_isOrtho_harmonic` —
  pairwise orthogonality of `range e`, `range d*`, `ker Δ`;
* `exact_sup_coExact_sup_harmonic_eq_top` / `exists_hodge_decomposition` — the
  three-way orthogonal decomposition `V = range e ⊕ range d* ⊕ ker Δ`;
* `harmonic_orthogonal_eq`, `isCompl_harmonic` — `(ker Δ)ᗮ = range e ⊔ range d*`;
* `range_e_le_ker_d`, `harmonic_inter_exact_eq_bot` — the cohomology connection.

A notable experimental finding this cycle: the **spanning** half of the
decomposition (`exact_sup_coExact_sup_harmonic_eq_top`) and the identity
`harmonic_orthogonal_eq` did **not** require the cochain condition `d ∘ e = 0`;
only the *mutual orthogonality* of `range e` and `range d*` uses it. The
decomposition `V = range e ⊕ range d* ⊕ ker Δ` is therefore valid for an arbitrary
pair `(e, d)`; the cochain condition is exactly what upgrades it to an *orthogonal*
direct sum and to a genuine cohomology theory.

The conjectures below are precise, falsifiable targets for follow-up cycles.

## Conjecture 1 — Hodge–de Rham isomorphism (harmonic = cohomology)

For the cochain complex (`d ∘ e = 0`), the orthogonal projection onto `ker Δ`
restricts to a **linear isomorphism**

    ker Δ  ≃ₗ[ℝ]  (ker d) ⧸ (range e)        (discrete cohomology of the complex).

Concretely: every cohomology class `[z] ∈ ker d / range e` has a unique harmonic
representative, and the assignment `[z] ↦ orthogonalProjection (ker Δ) z` is a
well-defined linear bijection. `harmonic_inter_exact_eq_bot` and `range_e_le_ker_d`
are the first two ingredients; the remaining content is surjectivity, i.e. every
closed cochain differs from its harmonic projection by an exact cochain.
**Falsifiable corollary:** `finrank ℝ (ker Δ) = finrank ℝ (ker d) - finrank ℝ (range e)`.

## Conjecture 2 — Spectral gap controls diffusion convergence to cohomology

Let `S = id − a·Δ` be the explicit-Euler diffusion step. If `0 < a` and
`a · λ_max(Δ) < 2`, then for every `x : V`,

    Sᵏ x  →  orthogonalProjection (ker Δ) x      as k → ∞,

with geometric rate `ρ = max(|1 − a·λ_min⁺|, |1 − a·λ_max|)`, where `λ_min⁺` is the
smallest *nonzero* eigenvalue of `Δ` (the discrete spectral gap). The harmonic
projection is already proven conserved (`harmonicProjection_diffStep_pow` in
`HodgeLaplacianGreen`); the conjecture is that the complementary (exact + co-exact)
energy contracts at exactly the spectral-gap rate, and that `a = 2/(λ_min⁺ + λ_max)`
is the optimal step size.

## Conjecture 3 — Functoriality and the Künneth-type product

A morphism of complexes (a pair of adjoint-compatible maps intertwining `e, d`)
induces a linear map on harmonic spaces commuting with the harmonic projections.
For the tensor product of two complexes, the Hodge Laplacian satisfies
`Δ_{X⊗Y} = Δ_X ⊗ 1 + 1 ⊗ Δ_Y`, hence

    ker Δ_{X⊗Y}  ≃ₗ[ℝ]  ker Δ_X ⊗ ker Δ_Y        (discrete Künneth for harmonics).

**Falsifiable corollary:** `finrank (ker Δ_{X⊗Y}) = finrank (ker Δ_X) · finrank (ker Δ_Y)`.

## Conjecture 4 — Graph Laplacian instantiation (Helmholtz decomposition)

Instantiate the abstract complex on a finite oriented graph with
`e : C⁰ → C⁰` trivial (or the vertex space) and `d : C¹(edges) → C⁰(vertices)` the
boundary map, so that `Δ₀ = d* d` is the **combinatorial graph Laplacian** and
`Δ₁` is the **1-Hodge Laplacian**. The conjecture: the abstract
`exists_hodge_decomposition` specializes to the classical **Helmholtz decomposition**
of edge flows into gradient flows ⊕ harmonic flows ⊕ cyclic flows, and
`finrank (ker Δ₁) = (#edges) − (#vertices) + (#connected components)` (the first
Betti number). This is the bridge from the abstract foundation to concrete
combinatorics and is fully checkable on small graphs by `decide`/`#eval`.

## Conjecture 5 — Positivity of the heat semigroup and Perron harmonics

The continuous-time discrete heat flow `exp(−tΔ)` (matrix exponential of `−Δ`)
satisfies `exp(−tΔ) → orthogonalProjection (ker Δ)` as `t → ∞` for all `t ≥ 0`,
monotonically decreasing every Dirichlet energy `⟪Δ x_t, x_t⟫`. Moreover, for the
graph Laplacian instantiation (Conjecture 4) with a connected graph, `ker Δ₀` is
one-dimensional and spanned by the constant cochain (the discrete Perron–Frobenius
eigenvector), giving `finrank (ker Δ₀) = #connected components`.
