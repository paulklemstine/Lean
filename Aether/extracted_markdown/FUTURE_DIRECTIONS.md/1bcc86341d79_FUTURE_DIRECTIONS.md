# Future Directions — Tropical Hodge Theory

## Synthesis of this cycle

The catalog already contained `Catalog/Tropical/HodgeDecomposition/Defs.lean`
(the `WeightedCoboundary` structure, the weighted inner product `weightedIP`,
the codifferential `δ`, the Laplacian `Δ = δd`, the adjunction
`⟨du,v⟩_tgt = ⟨u,δv⟩_src`, and the kernel characterisation `ker Δ = ker d`)
and `Catalog/Tropical/HodgeTheory/Foundations.lean` (the combinatorial graph
Laplacian and harmonic mean-value theory). What was *missing* was the actual
decomposition theorem — the statement that gives "Hodge theory" its name.

This cycle closed that gap. In `Decomposition.lean` we proved, for any
single-degree weighted cochain complex `d : ℝ^m → ℝ^n`:

* `laplacianUp_self_adjoint` — Δ is self-adjoint for the weighted inner product;
* `dirichlet_energy_identity` — ⟨Δu,u⟩_src = ⟨du,du⟩_tgt (the energy identity);
* `laplacianUp_posSemidef` — Δ ≥ 0;
* `hodge_orthogonal` — closed (harmonic) cochains ⟂ coexact cochains;
* `harmonic_coexact_eq_zero` — the two subspaces meet only in 0;
* `rank_delta_eq_rank_d` — `rank δ = rank d` (invertible diagonal conjugation);
* `hodge_decomposition_isCompl` — **the Hodge decomposition**:
  `ℝ^m = ker d ⊕ range δ` as complementary subspaces;
* `exists_hodge_decomposition` — every cochain splits as harmonic + coexact.

**Results summary.** Eight theorems, `sorry = 0`, depending only on
`propext`, `Classical.choice`, `Quot.sound`. The whole edifice rests on a
single structural input — the adjunction — plus positive-definiteness of the
weighted inner product, with the rank identity `rank δ = rank d` supplying the
codimension count needed for completeness.

The most important structural lesson: in the *single-coboundary* (two-term)
setting, "harmonic" coincides with "closed", because there is no incoming
differential. The genuinely Hodge-theoretic phenomena — harmonic representatives
of cohomology, the (p,q) bidegree, hard Lefschetz — only appear once the complex
has length ≥ 3. The directions below are aimed squarely there.

---

## Direction 1: The three-term Hodge decomposition and harmonic representatives

Extend `WeightedCoboundary` to a genuine three-term weighted complex
`A --d₀--> B --d₁--> C` with `d₁ ∘ d₀ = 0`, and prove the full middle-degree
decomposition `B = im d₀ ⊕ ℋ ⊕ im δ₁`, where the harmonic space
`ℋ = ker Δ_B = ker d₁ ∩ ker δ₀` is canonically isomorphic to the cohomology
`ker d₁ / im d₀`.

**The key insight is** that, unlike the two-term case proven this cycle, the
middle space carries *two* orthogonal "exact-type" pieces (incoming `im d₀` and
outgoing `im δ₁`) which are mutually orthogonal *only because* `d₁ d₀ = 0`
forces `⟨d₀ a, δ₁ c⟩ = ⟨d₁ d₀ a, c⟩ = 0`; harmonicity is then exactly the
double-kernel `ker d₁ ∩ ker δ₀`, and the Hodge isomorphism is the restriction
of the quotient map to ℋ.

**Why now?** The two-term `hodge_decomposition_isCompl` already isolates the two
load-bearing facts (adjunction + `rank δ = rank d`); the three-term proof reuses
both verbatim and only adds the `d₁ d₀ = 0` orthogonality, so the marginal cost
is small while the payoff — harmonic representatives of cohomology — is the
actual theorem mathematicians mean by "Hodge decomposition".

**Falsifiable prediction:** `dim ℋ = dim(ker d₁) - rank d₀`, and dropping the
hypothesis `d₁ d₀ = 0` makes the three pieces fail to be pairwise orthogonal
(a concrete 3×3 counterexample should exhibit `im d₀ ∩ im δ₁ ≠ 0`).

## Direction 2: Spectral gap controls tropical mixing and the Bellman contraction

Define the smallest nonzero eigenvalue `λ₁(Δ)` of `laplacianUp` and prove that
it lower-bounds the contraction rate of the tropical heat/Bellman semigroup
`u ↦ u - t·Δu` on the orthogonal complement of the harmonic (constant) part,
linking to `tropical_bellman_nonexpansive` and `tropical_mixing_time` already in
`HodgeTheory/Foundations.lean`.

**The key insight is** that the Dirichlet energy identity proven this cycle,
`⟨Δu,u⟩_src = ⟨du,du⟩_tgt`, is *exactly* a Poincaré/Rayleigh inequality in
disguise: it equates the Laplacian quadratic form with a coboundary norm, so a
lower bound on `‖du‖²/‖u‖²` over `(ker d)^⊥` is literally a spectral gap, and the
gap is the convergence rate of gradient descent on the energy.

**Why now?** `laplacianUp_posSemidef` and `dirichlet_energy_identity` give the
quadratic form and its nonnegativity for free; Mathlib's
`InnerProductSpace`/min–max (`iInf`) machinery can be transported through the
weighted inner product, so the variational characterisation of `λ₁` is within
reach without new analytic infrastructure.

**Falsifiable prediction:** for the path graph on `k` vertices the gap scales as
`λ₁ ≍ 1/k²`; if a proposed bound is independent of `k`, it is wrong.

## Direction 3: Tropical Hard Lefschetz as unimodality of harmonic dimensions

`Defs.lean` states `SatisfiesHLP` and `hlp_implies_poincare_bound` only as a
formal property. Connect it to the harmonic spaces of Direction 1 by defining a
Lefschetz operator `L : ℋ^k → ℋ^{k+1}` (cup with a strictly-convex weight class)
and proving that injectivity of `L^{n-2k}` forces the Betti/harmonic sequence to
be unimodal, recovering `b₀ ≤ b₁ ≤ … ≤ b_{⌊n/2⌋}`.

**The key insight is** that hard Lefschetz is not an analytic statement but a
*positivity* statement: the same positive-definiteness of `weightedIP` that
made `Δ ≥ 0` this cycle is what makes the Lefschetz pairing
`(x,y) ↦ ⟨x, L^{n-2k} y⟩` non-degenerate, and non-degeneracy of a positive form
is equivalent to injectivity of `L^{n-2k}`.

**Why now?** With harmonic spaces available (Direction 1) and a proven
positive-definite pairing (this cycle), HLP reduces to a finite-dimensional
non-degeneracy lemma — a `LinearMap.injective ↔ ...` statement Mathlib supports —
rather than the deep algebraic-geometry input it requires classically.

**Falsifiable prediction:** for the uniform matroid `U_{2,4}` the harmonic
sequence is `(1,3,1)` and the Lefschetz map `ℋ⁰ → ℋ²` is an isomorphism; any fan
producing a non-unimodal harmonic sequence would refute the matroid HLP.

## Direction 4: Functoriality — pullback of harmonic forms under weighted maps

Prove that a weight-preserving morphism of weighted complexes induces a map on
cohomology that commutes with the harmonic projection, i.e. the assignment
`W ↦ (ℝ^m = ker d ⊕ range δ)` is functorial and the harmonic projector is
natural.

**The key insight is** that the harmonic projector is *characterised* by the two
orthogonality facts proven this cycle (`hodge_orthogonal` and
`harmonic_coexact_eq_zero`), and a uniqueness characterisation is exactly what
makes an object natural: any map respecting `d`, `δ` and the inner product must
commute with the uniquely-determined projection onto `ker d`.

**Why now?** `hodge_decomposition_isCompl` gives the projector as
`Submodule.linearProjOfIsCompl`; Mathlib already has its universal property, so
naturality is a diagram chase rather than new mathematics.

**Falsifiable prediction:** a non-weight-preserving map (rescaling one edge
weight) breaks commwith the projector — a 2×1 example should show
`proj ∘ f ≠ f ∘ proj`.

## Direction 5: Quantitative stability of the decomposition under weight perturbation

Bound the operator-norm distance between the harmonic projectors of two weighted
complexes that differ only in their weights, in terms of the weight ratios,
proving the tropical Hodge decomposition is Lipschitz-stable away from rank
degeneration.

**The key insight is** that `rank δ = rank d` (proven this cycle) holds for
*every* strictly positive weight vector, so the decomposition's *dimensions* are
locally constant; only the *angle* between `ker d` and `range δ` moves, and that
angle is controlled by the condition number of the diagonal weight matrices via
the Dirichlet identity.

**Why now?** The certified-robustness toolkit in `HodgeTheory/Foundations.lean`
(`certifiedRobustnessRadius`, `tropProjection_nonexpansive`) provides the exact
template: a margin-over-Lipschitz radius statement, now applied to the
*projector* rather than to a scalar classifier.

**Falsifiable prediction:** the projector distance grows like the *maximum*
weight ratio `max_i w_i / min_i w_i`, and stays bounded as long as no weight
tends to 0; sending a single weight to 0 (rank drop) makes it blow up.
