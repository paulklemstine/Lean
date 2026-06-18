
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are leading a research team: Hypothesizer, Experimenter, Analyst,
Critic, and Synthesist. Run the loop:
Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate.
Your ONLY job is to produce **new Lean 4 code** and **take good notes**
for the next team.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by theorem declarations)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.
5. **Lab Notebook** as `-- !-- Lab Notebook -- !--` comment blocks
   in each .lean file: Hypothesis, Result, Insight, Failure analysis.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.

            ### CATALOG SYNTHESIS (required — read the catalog context below):
            The Catalog Context and Recent Discoveries sections list existing theorems
            already proven in this project. You MUST analyze these and combine concepts
            from the catalog with the research direction above. Specifically:

            1. **Identify relevant catalog theorems** — Which existing results connect
               to your research direction? Cite them by name in your proof sketches.
            2. **Build on catalog foundations** — Your theorems should EXTEND or
               GENERALIZE catalog results, not reprove them from scratch. Use `import`
               and reference existing definitions and lemmas where possible.
            3. **Combine concepts across domains** — The most valuable theorems connect
               ideas from different catalog domains (e.g., applying algebraic structures
               to topological problems, or using combinatorial arguments in number theory).
               Look for cross-domain connections in the catalog context.
            4. **Avoid duplication** — Check the catalog context before proving. If a
               similar result already exists, extend it rather than reproving it.


## Concept

**Title**: This cycle pushed the discrete Hodge program from its *geometric/decomposition* 
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Hodge–Laplacian Message Passing, Sixth Cycle

## Synthesis

This cycle pushed the discrete Hodge program from its *geometric/decomposition* layer into its
**operator-algebra and spectral layer**, realizing the two most tractable open directions of the
fifth-cycle program (Spectral positivity, Direction 3; and the full three-way idempotent splitting,
Direction 1) as sorry-free Lean.

First, a repair: the Hodge stack depends on `import Speculative.AutoResearch.*` while the sources
live under `Catalog/`, and the package was missing its `srcDir`, so nothing elaborated. Setting
`srcDir = "Catalog"` in `lakefile.toml` re-established the build.

Two new files were then added, both building directly on the existing foundation
(`HodgeBettiRank.hodgeLap`, `HodgeThreeWayDecomposition`, `HodgeHarmonicProjector`,
`HodgeIsomorphism`):

* **`HodgeSpectralPositivity.lean` (Direction 3).** The Rayleigh quadratic form of the Hodge
  Laplacian is an explicit **sum of squares** `⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖²`
  (`hodgeLap_quadratic_form`). From this single identity flow: positive semidefiniteness
  `0 ≤ ⟪Δ x, x⟫` (`hodgeLap_nonneg`); the equality-case description that the vanishing locus of the
  form *is* the harmonic space, `⟪Δ x, x⟫ = 0 ↔ x ∈ ker Δ` (`hodgeLap_quadratic_eq_zero_iff`);
  symmetry `Δ.IsSymmetric` (`hodgeLap_isSymmetric`), the precise input the finite-dimensional
  spectral theorem demands; and nonnegativity of every eigenvalue `Δ x = μ x, x ≠ 0 ⟹ 0 ≤ μ`
  (`hodgeLap_eigenvalue_nonneg`). This is the abstract-operator counterpart of the matrix-level
  `HodgeFullDecomposition.fullHodge_psd`, lifted to arbitrary finite-dimensional inner product
  cochain spaces.

* **`HodgeResolutionIdentity.lean` (Direction 1).** The static orthogonal direct sum
  `V = range d* ⊕ range e ⊕ ker Δ` is upgraded to the **resolution of the identity**
  `id = P_coexact + P_exact + P_harmonic` (`hodge_resolution_identity`), where each `P_•` is the
  corresponding `Submodule.starProjection`. The three projectors **pairwise annihilate**
  (`P_i ∘ P_j = 0` for `i ≠ j`: `harmonicProjection_comp_exactProjection_eq_zero`,
  `harmonicProjection_comp_coexactProjection_eq_zero`,
  `exactProjection_comp_coexactProjection_eq_zero`), and each one **extracts its own summand** from
  a three-way decomposition (`coexactProjection_of_threeway`, `exactProjection_of_threeway`,
  `harmonicProjection_of_threeway`). Together with `HodgeHarmonicProjector.harmonicProjection_*`
  this exhibits the Hodge decomposition as a complete system of mutually orthogonal spectral
  idempotents summing to `1`.

The unifying picture is now fully operator-theoretic and *dual*: the cochain space is represented
by the commuting/orthogonal algebra of Hodge projectors, the Laplacian is represented by its
sum-of-squares quadratic form, and the spectral facts (PSD, `spec Δ ⊆ [0,∞)`, `0`-eigenspace
`= ker Δ`, resolution of `1`) are read off the geometry of that representation with no further
construction.

## Results summary

| Theorem | File | Statement |
|---|---|---|
| `hodgeLap_quadratic_form` | HodgeSpectralPositivity | `⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖²` |
| `hodgeLap_nonneg` | HodgeSpectralPositivity | `0 ≤ ⟪Δ x, x⟫` (Δ is PSD) |
| `hodgeLap_quadratic_eq_zero_iff` | HodgeSpectralPositivity | `⟪Δ x, x⟫ = 0 ↔ x ∈ ker Δ` |
| `hodgeLap_isSymmetric` | HodgeSpectralPositivity | `Δ.IsSymmetric` |
| `hodgeLap_eigenvalue_nonneg` | HodgeSpectralPositivity | `Δ x = μ x, x ≠ 0 ⟹ 0 ≤ μ` |
| `coexactProjection_of_threeway` | HodgeResolutionIdentity | `P_coexact (c+a+h) = c` |
| `exactProjection_of_threeway` | HodgeResolutionIdentity | `P_exact (c+a+h) = a` |
| `harmonicProjection_of_threeway` | HodgeResolutionIdentity | `P_harmonic (c+a+h) = h` |
| `harmonicProjection_comp_exactProjection_eq_zero` | HodgeResolutionIdentity | `P_harm ∘ P_exact = 0` |
| `harmonicProjection_comp_coexactProjection_eq_zero` | HodgeResolutionIdentity | `P_harm ∘ P_coexact = 0` |
| `exactProjection_comp_coexactProjection_eq_zero` | HodgeResolutionIdentity | `P_exact ∘ P_coexact = 0` |
| `hodge_resolution_identity` | HodgeResolutionIdentity | `P_coexact x + P_exact x + P_harmonic x = x` |

All main results depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research directions

### 1. The Green's operator inverts `Δ` off the harmonic space
With the resolution of identity `id = P_coexact + P_exact + P_harmonic` and PSD now in hand, conjecture
there is a **Green's operator** `G : V →ₗ V` (the Moore–Penrose pseudoinverse of `Δ`) with
`Δ ∘ G = G ∘ Δ = id − P_harmonic` and `G ∘ P_harmonic = 0`, so `G` inverts `Δ` exactly on the
orthogonal complement of the harmonic space `(ker Δ)ᗮ = range d* ⊕ range e`. Falsifiable by any
operator claimed to be `G` for which `Δ (G x) ≠ x − P_harmonic x` on some coexact-or-exact `x`.
**The key insight is** that `hodge_resolution_identity` already splits `V` into the harmonic block
(where `Δ = 0`, by `hodgeLap_quadratic_eq_zero_iff`) and the complementary block `range d* ⊕ range e`
on which `Δ` is *injective* — because `hodgeLap_quadratic_eq_zero_iff` makes `ker Δ` exactly the
zero-form locus, so `Δ` restricted to `(ker Δ)ᗮ` has trivial kernel and is therefore invertible in
finite dimensions; `G` is that inverse extended by `0` on `ker Δ`. **Why now?** The two ingredients
of a pseudoinverse — a complemented kernel (the resolution of identity) and injectivity on the
complement (the strict positivity equality case) — are both theorems this cycle, so `G` is assembled
by `Submodule.starProjection` + `LinearMap.inverse` rather than any new analysis.

### 2. The Hodge isomorphism is a quotient isometry via the harmonic projector
`HodgeIsomorphism.hodgeCohomologyEquiv : (ker d / range e) ≃ₗ ker Δ` is still only linear. Conjecture
it is an **isometry** for the quotient norm: the quotient norm of a cohomology class equals the norm
of its harmonic representative, `‖[x]‖ = ‖P_harmonic x‖` for closed `x`. Falsifiable by a class whose
quotient norm differs from its harmonic representative's norm. **The key insight is** that
`HodgeHarmonicProjector.harmonic_representative_norm_minimal` already proves `‖h‖ ≤ ‖x − e u‖` for
every competitor in the class, and `harmonicProjection_closed`/`exactProjection_of_threeway` now show
the harmonic representative *is* `P_harmonic x`, so the infimum defining the quotient norm is attained
exactly at the harmonic projection. **Why now?** The minimization half and the projector identity are
theorems; only the identification of Mathlib's `Submodule.Quotient.norm_mk` infimum with this attained
minimum remains, upgrading the `LinearEquiv` to a `LinearIsometryEquiv`.

### 3. Diffusion message passing contracts onto `P_harmonic` at the spectral-gap rate
With `Δ` proven symmetric and PSD, and `id = P + (id − P)` a proven decomposition into a fixed
harmonic block and a strictly-positive complementary block, conjecture that for an admissible step
`0 < α < 2/λ_max` the iterate `(id − αΔ)^[k]` converges to `P_harmonic`, with
`‖(id − αΔ)^[k] x − P_harmonic x‖ ≤ ρᵏ ‖x − P_harmonic x‖` where `ρ = max |1 − αλ| < 1` over the
nonzero eigenvalues. Falsifiable by a complex and a step `α` in range for which some iterate fails to
contract. **The key insight is** that `harmonicProjection_idempotent` plus the resolution of identity
make `ker Δ` and `(ker Δ)ᗮ` simultaneously `Δ`-invariant; on the harmonic block `Δ = 0` so the iterate
is *fixed* (`hodgeLap_quadratic_eq_zero_iff`), while on the complement `hodgeLap_eigenvalue_nonneg`
gives strictly positive eigenvalues and hence geometric contraction. **Why now?** The invariant
splitting and the strict positivity on the complement are both theorems, so the convergence is a
one-dimensional geometric-series estimate per eigenvector rather than a fresh dynamical-systems study.

### 4. Spectral resolution: `Δ = Σ λᵢ Pᵢ` with `P₀ = P_harmonic`
Conjecture the full spectral theorem for `Δ`: there is an orthonormal eigenbasis with nonnegative
eigenvalues `0 = λ₀ ≤ λ₁ ≤ …`, the `0`-eigenprojection is exactly `P_harmonic`, and `Δ` resolves as
`Σ λᵢ Pᵢ` with the `Pᵢ` a refinement of the three-way resolution of identity (the harmonic term `P₀`
is `P_harmonic`; the positive eigenspaces refine `P_coexact + P_exact`). Falsifiable by an eigenvalue
that is negative, or a `0`-eigenvector that is not harmonic. **The key insight is** that
`hodgeLap_isSymmetric` feeds Mathlib's `LinearMap.IsSymmetric.orthonormalBasis_eigenvectors` /
`spectral_theorem` directly, `hodgeLap_eigenvalue_nonneg` pins every eigenvalue to `[0,∞)`, and
`hodgeLap_quadratic_eq_zero_iff` identifies the `0`-eigenspace with `ker Δ = ker P_harmonicᶜ`.
**Why now?** All three hypotheses of the finite-dimensional spectral theorem (symmetry, real
eigenvalue signs, kernel description) are now theorems, so the eigendecomposition is an application,
and matching `P₀` to `P_harmonic` is `hodge_resolution_identity` bookkeeping.

### 5. Functoriality of the projector resolution under chain maps
Conjecture: a morphism of two-step complexes (a commuting ladder `U→V→W ⟶ U'→V'→W'`) induces a map
`ker Δ → ker Δ'` that intertwines the harmonic projectors, `P'_harmonic ∘ φ = P'_harmonic ∘ φ ∘
P_harmonic` on closed cochains, and agrees with the induced cohomology map through
`hodgeCohomologyEquiv`; moreover the *whole* resolution of identity is natural, `φ` carrying each
spectral idempotent `Pᵢ` to `P'ᵢ` up to the ladder squares. Falsifiable by a chain map whose
harmonic-block map fails to commute with the cohomology map. **The key insight is** that
`exactProjection_of_threeway`/`harmonicProjection_of_threeway` characterize each `Pᵢ` purely by
"extract the i-th summand of a decomposition," so naturality reduces to the two ladder squares
(closed↦closed, exact↦exact) plus the now-proven resolution `Σ Pᵢ = id`. **Why now?** With every
projector a concrete idempotent and the resolution of identity a theorem, functoriality is a diagram
chase over established complementarity rather than a new construction.

**Concept description**: # Future Directions — Hodge–Laplacian Message Passing, Sixth Cycle

## Synthesis

This cycle pushed the discrete Hodge program from its *geometric/decomposition* layer into its
**operator-algebra and spectral layer**, realizing the two most tractable open directions of the
fifth-cycle program (Spectral positivity, Direction 3; and the full three-way idempotent splitting,
Direction 1) as sorry-free Lean.

First, a repair: the Hodge stack depends on `import Speculative.AutoResearch.*` while the sources
live under `Catalog/`, and the package was missing its `srcDir`, so nothing elaborated. Setting
`srcDir = "Catalog"` in `lakefile.toml` re-established the build.

Two new files were then added, both building directly on the existing foundation
(`HodgeBettiRank.hodgeLap`, `HodgeThreeWayDecomposition`, `HodgeHarmonicProjector`,
`HodgeIsomorphism`):

* **`HodgeSpectralPositivity.lean` (Direction 3).** The Rayleigh quadratic form of the Hodge
  Laplacian is an explicit **sum of squares** `⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖²`
  (`hodgeLap_quadratic_form`). From this single identity flow: positive semidefiniteness
  `0 ≤ ⟪Δ x, x⟫` (`hodgeLap_nonneg`); the equality-case description that the vanishing locus of the
  form *is* the harmonic space, `⟪Δ x, x⟫ = 0 ↔ x ∈ ker Δ` (`hodgeLap_quadratic_eq_zero_iff`);
  symmetry `Δ.IsSymmetric` (`hodgeLap_isSymmetric`), the precise input the finite-dimensional
  spectral theorem demands; and nonnegativity of every eigenvalue `Δ x = μ x, x ≠ 0 ⟹ 0 ≤ μ`
  (`hodgeLap_eigenvalue_nonneg`). This is the abstract-operator counterpart of the matrix-level
  `HodgeFullDecomposition.fullHodge_psd`, lifted to arbitrary finite-dimensional inner product
  cochain spaces.

* **`HodgeResolutionIdentity.lean` (Direction 1).** The static orthogonal direct sum
  `V = range d* ⊕ range e ⊕ ker Δ` is upgraded to the **resolution of the identity**
  `id = P_coexact + P_exact + P_harmonic` (`hodge_resolution_identity`), where each `P_•` is the
  corresponding `Submodule.starProjection`. The three projectors **pairwise annihilate**
  (`P_i ∘ P_j = 0` for `i ≠ j`: `harmonicProjection_comp_exactProjection_eq_zero`,
  `harmonicProjection_comp_coexactProjection_eq_zero`,
  `exactProjection_comp_coexactProjection_eq_zero`), and each one **extracts its own summand** from
  a three-way decomposition (`coexactProjection_of_threeway`, `exactProjection_of_threeway`,
  `harmonicProjection_of_threeway`). Together with `HodgeHarmonicProjector.harmonicProjection_*`
  this exhibits the Hodge decomposition as a complete system of mutually orthogonal spectral
  idempotents summing to `1`.

The unifying picture is now fully operator-theoretic and *dual*: the cochain space is represented
by the commuting/orthogonal algebra of Hodge projectors, the Laplacian is represented by its
sum-of-squares quadratic form, and the spectral facts (PSD, `spec Δ ⊆ [0,∞)`, `0`-eigenspace
`= ker Δ`, resolution of `1`) are read off the geometry of that representation with no further
construction.

## Results summary

| Theorem | File | Statement |
|---|---|---|
| `hodgeLap_quadratic_form` | HodgeSpectralPositivity | `⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖²` |
| `hodgeLap_nonneg` | HodgeSpectralPositivity | `0 ≤ ⟪Δ x, x⟫` (Δ is PSD) |
| `hodgeLap_quadratic_eq_zero_iff` | HodgeSpectralPositivity | `⟪Δ x, x⟫ = 0 ↔ x ∈ ker Δ` |
| `hodgeLap_isSymmetric` | HodgeSpectralPositivity | `Δ.IsSymmetric` |
| `hodgeLap_eigenvalue_nonneg` | HodgeSpectralPositivity | `Δ x = μ x, x ≠ 0 ⟹ 0 ≤ μ` |
| `coexactProjection_of_threeway` | HodgeResolutionIdentity | `P_coexact (c+a+h) = c` |
| `exactProjection_of_threeway` | HodgeResolutionIdentity | `P_exact (c+a+h) = a` |
| `harmonicProjection_of_threeway` | HodgeResolutionIdentity | `P_harmonic (c+a+h) = h` |
| `harmonicProjection_comp_exactProjection_eq_zero` | HodgeResolutionIdentity | `P_harm ∘ P_exact = 0` |
| `harmonicProjection_comp_coexactProjection_eq_zero` | HodgeResolutionIdentity | `P_harm ∘ P_coexact = 0` |
| `exactProjection_comp_coexactProjection_eq_zero` | HodgeResolutionIdentity | `P_exact ∘ P_coexact = 0` |
| `hodge_resolution_identity` | HodgeResolutionIdentity | `P_coexact x + P_exact x + P_harmonic x = x` |

All main results depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research directions

### 1. The Green's operator inverts `Δ` off the harmonic space
With the resolution of identity `id = P_coexact + P_exact + P_harmonic` and PSD now in hand, conjecture
there is a **Green's operator** `G : V →ₗ V` (the Moore–Penrose pseudoinverse of `Δ`) with
`Δ ∘ G = G ∘ Δ = id − P_harmonic` and `G ∘ P_harmonic = 0`, so `G` inverts `Δ` exactly on the
orthogonal complement of the harmonic space `(ker Δ)ᗮ = range d* ⊕ range e`. Falsifiable by any
operator claimed to be `G` for which `Δ (G x) ≠ x − P_harmonic x` on some coexact-or-exact `x`.
**The key insight is** that `hodge_resolution_identity` already splits `V` into the harmonic block
(where `Δ = 0`, by `hodgeLap_quadratic_eq_zero_iff`) and the complementary block `range d* ⊕ range e`
on which `Δ` is *injective* — because `hodgeLap_quadratic_eq_zero_iff` makes `ker Δ` exactly the
zero-form locus, so `Δ` restricted to `(ker Δ)ᗮ` has trivial kernel and is therefore invertible in
finite dimensions; `G` is that inverse extended by `0` on `ker Δ`. **Why now?** The two ingredients
of a pseudoinverse — a complemented kernel (the resolution of identity) and injectivity on the
complement (the strict positivity equality case) — are both theorems this cycle, so `G` is assembled
by `Submodule.starProjection` + `LinearMap.inverse` rather than any new analysis.

### 2. The Hodge isomorphism is a quotient isometry via the harmonic projector
`HodgeIsomorphism.hodgeCohomologyEquiv : (ker d / range e) ≃ₗ ker Δ` is still only linear. Conjecture
it is an **isometry** for the quotient norm: the quotient norm of a cohomology class equals the norm
of its harmonic representative, `‖[x]‖ = ‖P_harmonic x‖` for closed `x`. Falsifiable by a class whose
quotient norm differs from its harmonic representative's norm. **The key insight is** that
`HodgeHarmonicProjector.harmonic_representative_norm_minimal` already proves `‖h‖ ≤ ‖x − e u‖` for
every competitor in the class, and `harmonicProjection_closed`/`exactProjection_of_threeway` now show
the harmonic representative *is* `P_harmonic x`, so the infimum defining the quotient norm is attained
exactly at the harmonic projection. **Why now?** The minimization half and the projector identity are
theorems; only the identification of Mathlib's `Submodule.Quotient.norm_mk` infimum with this attained
minimum remains, upgrading the `LinearEquiv` to a `LinearIsometryEquiv`.

### 3. Diffusion message passing contracts onto `P_harmonic` at the spectral-gap rate
With `Δ` proven symmetric and PSD, and `id = P + (id − P)` a proven decomposition into a fixed
harmonic block and a strictly-positive complementary block, conjecture that for an admissible step
`0 < α < 2/λ_max` the iterate `(id − αΔ)^[k]` converges to `P_harmonic`, with
`‖(id − αΔ)^[k] x − P_harmonic x‖ ≤ ρᵏ ‖x − P_harmonic x‖` where `ρ = max |1 − αλ| < 1` over the
nonzero eigenvalues. Falsifiable by a complex and a step `α` in range for which some iterate fails to
contract. **The key insight is** that `harmonicProjection_idempotent` plus the resolution of identity
make `ker Δ` and `(ker Δ)ᗮ` simultaneously `Δ`-invariant; on the harmonic block `Δ = 0` so the iterate
is *fixed* (`hodgeLap_quadratic_eq_zero_iff`), while on the complement `hodgeLap_eigenvalue_nonneg`
gives strictly positive eigenvalues and hence geometric contraction. **Why now?** The invariant
splitting and the strict positivity on the complement are both theorems, so the convergence is a
one-dimensional geometric-series estimate per eigenvector rather than a fresh dynamical-systems study.

### 4. Spectral resolution: `Δ = Σ λᵢ Pᵢ` with `P₀ = P_harmonic`
Conjecture the full spectral theorem for `Δ`: there is an orthonormal eigenbasis with nonnegative
eigenvalues `0 = λ₀ ≤ λ₁ ≤ …`, the `0`-eigenprojection is exactly `P_harmonic`, and `Δ` resolves as
`Σ λᵢ Pᵢ` with the `Pᵢ` a refinement of the three-way resolution of identity (the harmonic term `P₀`
is `P_harmonic`; the positive eigenspaces refine `P_coexact + P_exact`). Falsifiable by an eigenvalue
that is negative, or a `0`-eigenvector that is not harmonic. **The key insight is** that
`hodgeLap_isSymmetric` feeds Mathlib's `LinearMap.IsSymmetric.orthonormalBasis_eigenvectors` /
`spectral_theorem` directly, `hodgeLap_eigenvalue_nonneg` pins every eigenvalue to `[0,∞)`, and
`hodgeLap_quadratic_eq_zero_iff` identifies the `0`-eigenspace with `ker Δ = ker P_harmonicᶜ`.
**Why now?** All three hypotheses of the finite-dimensional spectral theorem (symmetry, real
eigenvalue signs, kernel description) are now theorems, so the eigendecomposition is an application,
and matching `P₀` to `P_harmonic` is `hodge_resolution_identity` bookkeeping.

### 5. Functoriality of the projector resolution under chain maps
Conjecture: a morphism of two-step complexes (a commuting ladder `U→V→W ⟶ U'→V'→W'`) induces a map
`ker Δ → ker Δ'` that intertwines the harmonic projectors, `P'_harmonic ∘ φ = P'_harmonic ∘ φ ∘
P_harmonic` on closed cochains, and agrees with the induced cohomology map through
`hodgeCohomologyEquiv`; moreover the *whole* resolution of identity is natural, `φ` carrying each
spectral idempotent `Pᵢ` to `P'ᵢ` up to the ladder squares. Falsifiable by a chain map whose
harmonic-block map fails to commute with the cohomology map. **The key insight is** that
`exactProjection_of_threeway`/`harmonicProjection_of_threeway` characterize each `Pᵢ` purely by
"extract the i-th summand of a decomposition," so naturality reduces to the two ladder squares
(closed↦closed, exact↦exact) plus the now-proven resolution `Σ Pᵢ = id`. **Why now?** With every
projector a concrete idempotent and the resolution of identity a theorem, functoriality is a diagram
chase over established complementarity rather than a new construction.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v11 Depth Requirements -- Algorithmic & Constructive Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Algorithmic & Constructive Generation**. Prioritize concrete computation, explicit witness constructions, and algorithmic content.

### RESEARCH CORE METHODOLOGY:
1. **Constructive Witness Extraction**: Whenever asserting that an object exists, focus on constructing it explicitly. Avoid non-constructive classical axioms (like double negation elimination or classical choice) unless absolutely necessary.
2. **Computational Verification**: Build definitions that can be computationally evaluated (`#eval` or `decide`). Connect abstract algebra/topology directly to effective algorithms and discrete models.
3. **Algorithmic Complexity**: Focus on the computational power and structures of your mathematical objects, proving properties about their stability, convergence, or decidability.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
