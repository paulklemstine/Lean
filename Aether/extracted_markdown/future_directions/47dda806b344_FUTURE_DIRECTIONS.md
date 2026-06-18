# Future Directions — Discrete Hodge Program

This cycle rebuilt the discrete Hodge program on a self-contained Mathlib
foundation in `Catalog/Algebra/DiscreteHodge.lean`: for a length-three cochain
complex `E₀ --d₀--> E₁ --d₁--> E₂` of finite-dimensional real inner product
spaces with `d₁ ∘ d₀ = 0`, we proved the energy identity, the harmonic
characterization `ker Δ = ker δ₀ ⊓ ker d₁`, the orthogonal Hodge decomposition
`E₁ = (im d₀ ⊔ im δ₁) ⊕ ker Δ`, and the numerical Hodge theorem
`dim(ker Δ) = dim(ker d₁) − dim(im d₀)` (the first Betti number), plus the
two-term specialization.

The following conjectures are precise, falsifiable targets for follow-up cycles.

## C1 — Hodge isomorphism as a linear equivalence (categorification)

We proved equality of *dimensions* `dim(ker Δ) = dim(ker d₁) − dim(im d₀)`.
Strengthen this to an explicit isomorphism of vector spaces:

> There is a natural `ℝ`-linear equivalence
> `hodgeIso : harmonic d₀ d₁ ≃ₗ[ℝ] (LinearMap.ker d₁ ⧸ (LinearMap.range d₀).submoduleOf (LinearMap.ker d₁))`
> realized by the inclusion `ker Δ ↪ ker d₁` followed by the quotient map, and
> this map is moreover an isometry for the induced inner products.

Testable corollary: the composite `ker Δ → ker d₁ → cohomology` is bijective
(injective by `disjoint_range_d0_harmonic`, surjective by `sup_range_d0_harmonic`).

## C2 — Full ℕ-graded complex and the Hodge–Euler identity

Generalize from three terms to an arbitrary finite cochain complex
`(Eₙ, dₙ)` of finite-dimensional inner product spaces with `dₙ₊₁ ∘ dₙ = 0`.

> Define `Δₙ = dₙ₋₁ δₙ₋₁ + δₙ dₙ`.  Then `dim(ker Δₙ) = bₙ` (the n-th Betti
> number `dim ker dₙ − dim im dₙ₋₁`), and the Euler characteristic satisfies the
> Hodge–Euler identity
> `∑ₙ (-1)ⁿ dim(ker Δₙ) = ∑ₙ (-1)ⁿ dim Eₙ`.

This is the homological backbone behind `Catalog/Tropical/HodgeTheory`'s
`tropEulerChar` and should subsume `tropEulerChar_tree`.

## C3 — Spectral gap and combinatorial connectivity (graph instantiation)

Instantiate `E₀ = ℝ^V`, `E₁ = ℝ^E`, `d₀ = ` signed incidence of a finite graph
(connecting to `TropicalHodge.WeightedGraph`).

> The down-Laplacian `Δ = d₀ δ₀` on `ℝ^V` has `dim(ker Δ) =` number of connected
> components of the graph; equivalently the harmonic 0-cochains are exactly the
> functions constant on each component.  In particular the spectral gap
> `λ₁(Δ) > 0` iff the graph is connected.

Falsifiable: for a graph with `k` components, `b₀ = k`; for a tree on `n` vertices
`b₁ = 0` and `b₀ = 1`.

## C4 — Equivalence with the weighted matrix model (catalog bridge)

`Catalog/Tropical/HodgeDecomposition/Defs.lean` develops a concrete weighted
`Matrix` model (`WeightedCoboundary`, `laplacianUp`, `ker_laplacianUp_eq_ker_d`).

> Every `WeightedCoboundary m n` induces, via the weighted inner products, a
> `DiscreteHodge` two-term datum on `EuclideanSpace ℝ (Fin m)` / `(Fin n)` whose
> `LinearMap.adjoint` equals the matrix codifferential `delta`, so that
> `WeightedCoboundary.laplacianUp` is conjugate to `DiscreteHodge.laplacian` and
> `ker_laplacianUp_eq_ker_d` follows from `ker_laplacian_eq`.

This unifies the two independent catalog treatments under one abstract theorem.

## C5 — Discrete Bochner–Weitzenböck vanishing

Seek algebraic positivity hypotheses forcing harmonics to vanish (acyclicity).

> If there exists `c > 0` with `⟨Δ x, x⟩ ≥ c ‖x‖²` for all `x ∈ E₁` (a discrete
> Bochner/curvature positivity bound), then `harmonic d₀ d₁ = ⊥`, hence
> `b₁ = 0` and `im d₁ = E₂`-surjectivity / exactness at `E₁`.

Testable: such a `c` exists iff `Δ` is injective iff `ker d₁ = im d₀` (exactness),
giving a quantitative refinement of `finrank_harmonic_eq_betti`.
