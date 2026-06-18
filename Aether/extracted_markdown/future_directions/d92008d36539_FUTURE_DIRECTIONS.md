# Future Directions — Spectral Gap Rigidity for Hodge Laplacians under Coarse-Graining

## Synthesis

This cycle built the linear-algebraic skeleton of the conjecture *Spectral Gap
Rigidity for Hypergraph Hodge Laplacians Under Simplicial Coarse-Graining* in
`Speculative/AutoResearch/HodgeSpectralRigidity.lean`. Rather than attack the full
asymptotic renormalization statement, we isolated the *exact*, finite, sorry-free
core that every asymptotic version must rest on. Working with a length-three real
cochain complex `E₀ --e--> E₁ --d--> E₂` of finite-dimensional inner product
spaces, we *construct* the middle-degree Hodge Laplacian `Δ = dᵀ d + e eᵀ` from
honest coboundary data and prove, rather than assume, the facts that abstract
Hodge–message-passing theory takes as hypotheses:

* the **Hodge energy identity** `⟪Δ x, x⟫ = ‖d x‖² + ‖eᵀ x‖²`
  (`hodge_inner_self`), giving positive semidefiniteness for free
  (`hodge_nonneg`);
* **harmonic = closed ∩ co-closed**, `ker Δ = ker d ⊓ ker eᵀ` (`ker_hodge`),
  built on `ker eᵀ = (range e)ᗮ` (`ker_adjoint_eq_orthogonal`);
* the **orthogonal Hodge decomposition** `ker d = range e ⊕ ker Δ`
  (`harmonic_inf_range` for the direct-sum transversality and
  `harmonic_sup_range` for spanning, via the modular law);
* the **discrete Hodge theorem** `dim ker Δ + dim range e = dim ker d`
  (`betti_eq_harmonic_finrank`), i.e. harmonic dimension is the real Betti number;
* **Laplacian covariance** under a coarse-graining isometry, `Δ' = U Δ U⁻¹`
  (`hodge_coarse_grain`), and the resulting **harmonic-dimension rigidity**
  `dim ker Δ' = dim ker Δ` (`harmonic_finrank_rigidity`), supported by the general
  conjugation invariance `finrank_ker_conj`.

The key conceptual move is that over `ℝ` the Hodge theorem holds *unconditionally*
— there is no torsion term — so the "vanishing higher-order torsion density"
hypothesis of the governing conjecture is automatically satisfied in the real
model. This is why the spectral bottom's multiplicity is rigid: it equals a
topological invariant that an isometric coarse-graining cannot move. A pleasant
surprise of the formalization is that no neighbouring isometries are needed:
coarse-graining only the middle degree (`d' = d U⁻¹`, `e' = U e`) already
conjugates `Δ`, because the adjoint of an isometry is its inverse.

## Results Summary

Ten theorems, all sorry-free, axioms limited to `propext`, `Classical.choice`,
`Quot.sound`: `hodge_inner_self`, `hodge_nonneg`, `ker_adjoint_eq_orthogonal`,
`ker_hodge`, `harmonic_inf_range`, `harmonic_sup_range`,
`betti_eq_harmonic_finrank`, `hodge_coarse_grain`, `finrank_ker_conj`,
`harmonic_finrank_rigidity`.

## Research Directions

### 1. Spectral rigidity beyond the kernel: the full spectrum is conjugation-invariant

We proved that the *multiplicity of the eigenvalue 0* (the harmonic dimension) is
preserved by a coarse-graining isometry. The natural strengthening is that the
*entire* spectrum is preserved: for every `λ`, `dim ker (Δ' - λ•1) = dim ker (Δ - λ•1)`,
and indeed `Δ'` and `Δ` are unitarily equivalent. The key insight is that
`hodge_coarse_grain` already gives `Δ' = U Δ U⁻¹` with `U` an isometry, so
`Δ' - λ•1 = U (Δ - λ•1) U⁻¹` and `finrank_ker_conj` applies verbatim to each
shifted operator — the eigenvalue rigidity is a short corollary, since
`U (Δ - λ•1) U⁻¹ = U Δ U⁻¹ - λ•1` follows from `U U⁻¹ = 1`. *Why now?* The
covariance theorem `hodge_coarse_grain` is the only nontrivial ingredient and it
is already proved; this direction converts a proven equation into a proven
spectral-universality statement with almost no new machinery, and it is the
precise finite-scale shadow of the conjecture's "renormalization fixed profile."

### 2. A genuine non-isometric coarse-graining and the failure boundary

Real simplicial coarse-graining (collapsing faces, merging vertices) is *not* an
isometry — it is a surjection that is the identity on a coarse subspace. The
falsifiable question: does harmonic dimension survive a non-isometric coarse-grain?
The key insight is that an orthogonal *projection* coarse-graining `P` preserves
`dim ker Δ` if and only if `P` restricts to an isomorphism on the harmonic space,
which holds exactly when the discarded fine modes are spectrally gapped away from
`0` — converting "rigidity" into a checkable transversality condition. *Why now?*
We already have `ker_hodge` pinning the harmonic space as `ker d ⊓ (range e)ᗮ`, so
testing `P`-invariance reduces to an intersection-of-subspaces computation; a
single explicit `P` that drops the harmonic dimension would sharply delimit which
coarse-grainings are admissible, refuting the naive "any functor works" reading.

### 3. The integer Hodge theorem and the appearance of torsion

Our real Hodge theorem `betti_eq_harmonic_finrank` has *no* torsion term. Over `ℤ`
the analogous statement must fail: `Hᵏ(X; ℤ)` carries torsion that the real
harmonic space cannot see. The key insight is that the gap between the integer
cohomology rank and the real harmonic dimension is *exactly* the torsion
contribution, so formalizing `dim_ℝ ker Δ_ℝ = rank Hᵏ(X;ℤ)` makes "torsion density"
a precisely measurable defect rather than a heuristic. *Why now?* The real side is
fully proved and Mathlib's `Module` / `finrank` API plus its torsion theory
(`Module.torsion`, `Module.rank`) are mature enough to state the comparison; this
direction directly operationalizes the conjecture's central "vanishing
higher-order torsion density" clause as the obstruction to integer–real agreement.

### 4. Degree-wise chain functoriality and a coarse-graining functor

We transported a *single* middle degree. A true coarse-graining is a chain map
`φ_• : C_• → C'_•` commuting with all coboundaries, inducing the transport in
every degree simultaneously. The key insight is that requiring `φ` to be a chain
map (`d' ∘ φ = φ ∘ d` and `φ ∘ e = e' ∘ φ`) forces the per-degree Laplacian
intertwiners to glue into a single endofunctor of the cochain category, so
harmonic rigidity in every degree becomes a property of *one* morphism rather than
a family of unrelated isometries. *Why now?* The single-degree covariance
(`hodge_coarse_grain`) is the base case; promoting it to a chain map is a clean
inductive packaging problem, and it is the bridge from our linear-algebra core to
the conjecture's "coarse-graining functor on the face poset."

### 5. Quantitative spectral-gap rigidity and stability under perturbation

Exact isometry is idealized; the impactful statement is *stability*: if a
coarse-graining is an `ε`-near-isometry, the bottom of the spectrum moves by
`O(ε)` and the harmonic dimension is preserved as long as `ε` is below the
spectral gap. The key insight is that the energy identity
`⟪Δ x, x⟫ = ‖d x‖² + ‖eᵀ x‖²` (already proved as `hodge_inner_self`) makes `Δ`
Lipschitz in the coboundary data, so a Weyl / min–max perturbation bound turns the
discrete spectral gap into an explicit robustness radius for dimension rigidity.
*Why now?* With the exact rigidity (`harmonic_finrank_rigidity`) and the energy
identity already in hand, the only new ingredient is a finite-dimensional min–max
eigenvalue bound (available in Mathlib's `InnerProductSpace.Rayleigh` /
`spectrum`), and a quantitative gap is exactly what makes the conjecture testable
on noisy, finite random simplicial ensembles.
