
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

**Title**: This cycle rebuilt the discrete Hodge program on a **self-contained Mathlib foun
**Domain**: Applications
**Mathematical framing**: # Future Directions — Discrete Hodge Laplacian, Green's Operator & Diffusion Message Passing

## Synthesis

This cycle rebuilt the discrete Hodge program on a **self-contained Mathlib foundation**, after
discovering that the catalog's entire `Hodge*` stack was non-elaborating: the files
`HodgeGreenOperator`, `HodgeHarmonicProjector`, `HodgeIsomorphism`, `HodgeResolutionIdentity` and
`HodgeThreeWayDecomposition` all `import` foundation modules (`HodgeBettiRank`,
`HodgeSpectralPositivity`, `HodgeDiffusionContraction`) that **do not exist** in the repository, and
the package declared no `srcDir`, so even the present files could not be located by `lake`. A
one-line infrastructure repair (`srcDir = "Catalog"` in `lakefile.toml`) restored module
resolution, and the new file `Catalog/Speculative/AutoResearch/HodgeLaplacianGreen.lean` re-derives
the operator-algebra, spectral, analytic and dynamical layers of the program from Mathlib alone.

The central object is the discrete **Hodge Laplacian** of a two-step cochain complex
`U --e--> V --d--> W`,
```
Δ = d* ∘ d + e ∘ e*
```
on the middle space `V`, with `d*`, `e*` the Mathlib adjoints. The single organizing identity is
the sum-of-squares **Dirichlet energy**
```
⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖²,
```
from which everything else follows: the harmonic space `ker Δ` is exactly the closed-and-co-closed
cochains (`d x = 0 ∧ e* x = 0`); the Rayleigh form is strictly positive off `ker Δ`; self-adjointness
turns `(ker Δ)ᗮ` into `range Δ`; and `Δ` is therefore invertible on the complement, yielding the
unique **Green's operator** value. On the dynamical side, the explicit-Euler diffusion step
`S = id − a·Δ` fixes the harmonic space pointwise and conserves the harmonic projection along the
whole trajectory `P (Sᵏ x) = P x`: diffusion never creates or destroys the topological (harmonic)
component, it only relaxes the exact/co-exact part.

This is the **local-to-global** picture of the engine's theme made discrete: local data (the maps
`d`, `e` on individual cochains) glues, via the Hodge decomposition, into the global obstruction
object `ker Δ`, and the Green's operator is the cohomological measurement of how the non-harmonic
part is inverted.

## Results summary

| Theorem | Statement |
|---|---|
| `hodgeLap_isSymmetric` | `Δ` is self-adjoint |
| `hodgeLap_quadratic_form` | `⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖²` |
| `hodgeLap_apply_eq_zero_iff` | `Δ x = 0 ↔ d x = 0 ∧ e* x = 0` (harmonic ⇔ closed & co-closed) |
| `hodgeLap_quadratic_eq_zero_iff` | `⟪Δ x, x⟫ = 0 ↔ Δ x = 0` (strict positivity off the kernel) |
| `hodgeLap_apply_mem_orthogonal_ker` | `Δ x ∈ (ker Δ)ᗮ` |
| `hodgeLap_range_eq_orthogonal_ker` | `range Δ = (ker Δ)ᗮ` |
| `hodgeLap_injOn_orthogonal_ker` | `Δ` is injective on `(ker Δ)ᗮ` |
| `sub_harmonicProjection_mem_orthogonal_ker` | `x − P x ∈ (ker Δ)ᗮ` |
| `hodgeLap_green_existsUnique` | unique `z ∈ (ker Δ)ᗮ` with `Δ z = x − P x` (Green value) |
| `diffStep_harmonic_fixed` / `diffStep_pow_harmonic_fixed` | `Sᵏ h = h` for harmonic `h` |
| `harmonicProjection_diffStep` / `harmonicProjection_diffStep_pow` | `P (Sᵏ x) = P x` |

All main results depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research directions

### 1. Bundle the Green's operator into an honest self-adjoint linear map
`hodgeLap_green_existsUnique` currently delivers a *pointwise* `∃!`. Conjecture it bundles into a
genuine `G : V →ₗ[ℝ] V` with `G ∘ Δ = Δ ∘ G = id − P_harmonic`, `G ∘ P_harmonic = 0`, and `G`
self-adjoint (`⟪G x, y⟫ = ⟪x, G y⟫`). Falsifiable by any candidate `G` with `Δ (G x) ≠ x − P x` on
some `x`, or with `⟪G x, y⟫ ≠ ⟪x, G y⟫`. **The key insight is** that uniqueness is the *only*
obstruction to linearity of a solver: `z(x+y)` and `z(x)+z(y)` both solve the same `∃!` problem
(`hodgeLap_injOn_orthogonal_ker` forces them equal), so `G x := Classical.choose (hodgeLap_green_exists x)`
is automatically additive and homogeneous, and `LinearMap.mk` closes the construction.
**Why now?** Injectivity on the complement is a theorem this cycle, so each `LinearMap` axiom is a
one-line uniqueness argument, with self-adjointness following from `hodgeLap_isSymmetric` restricted
to the invariant complement.

### 2. The diffusion energy is a strict Lyapunov function with harmonic limit
Conjecture the Dirichlet energy `E(x) = ⟪Δ x, x⟫` is non-increasing along admissible diffusion,
`E(S x) ≤ E(x)` for `0 < a < 2/λ_max`, with equality iff `x` is harmonic, and that `Sᵏ x → P x` as
`k → ∞`. Falsifiable by an `x` and admissible `a` with `E(S x) > E(x)`, or a non-harmonic fixed
point of `S`. **The key insight is** that `hodgeLap_quadratic_form` already exhibits `E` as a sum of
squares whose zero set is exactly `ker Δ` (`hodgeLap_quadratic_eq_zero_iff`), and
`harmonicProjection_diffStep_pow` pins the limit's harmonic part to `P x`, so only the complementary
part must be shown to vanish. **Why now?** Both the Lyapunov candidate (the proven quadratic form)
and the conserved target (`P x`) are in hand; monotonicity reduces to a single algebraic estimate on
`E(x) − E(Sx) = 2a⟪Δx,Δx⟫ − a²⟪Δx,Δ(Δx)⟫` once `Δ` is bounded by `λ_max` on the complement.

### 3. Quantitative contraction at the spectral-gap rate
Conjecture that for an admissible step `0 < a < 2/λ_max`,
`‖Sᵏ x − P x‖ ≤ ρᵏ ‖x − P x‖` with `ρ = max_{λ>0} |1 − aλ| < 1` over the nonzero eigenvalues of `Δ`.
Falsifiable by a complex, an admissible `a`, and an iterate failing to contract by `ρ`. **The key
insight is** that `harmonicProjection_diffStep_pow` makes `x − P x` the only part that moves, and on
`(ker Δ)ᗮ` the Laplacian has strictly positive eigenvalues (`hodgeLap_quadratic_eq_zero_iff` plus
`hodgeLap_injOn_orthogonal_ker`), so `‖S y‖ ≤ ρ‖y‖` for `y ∈ (ker Δ)ᗮ` collapses to the
one-dimensional estimate `|1 − aλ| ≤ ρ` per eigenvector. **Why now?** The invariant splitting and
strict positivity are theorems, so contraction is a geometric per-eigenvalue bound rather than a
fresh dynamical-systems study — it needs only the spectral resolution of Direction 4.

### 4. Spectral resolution `Δ = Σ λᵢ Pᵢ` with `P₀ = P_harmonic` and `G = Σ_{λᵢ>0} λᵢ⁻¹ Pᵢ`
Conjecture the finite-dimensional spectral theorem for `Δ`: an orthonormal eigenbasis with
`0 = λ₀ ≤ λ₁ ≤ …`, the `0`-eigenprojection equal to `P_harmonic`, `Δ = Σ λᵢ Pᵢ`, and the Green's
operator of Direction 1 equal to `G = Σ_{λᵢ>0} λᵢ⁻¹ Pᵢ`. Falsifiable by a negative eigenvalue, a
non-harmonic `0`-eigenvector, or a mismatch `G ≠ Σ λᵢ⁻¹ Pᵢ`. **The key insight is** that
`hodgeLap_isSymmetric` feeds Mathlib's finite-dimensional spectral theorem directly, the quadratic
form pins the spectrum to `[0,∞)`, and `hodgeLap_quadratic_eq_zero_iff` identifies the `0`-eigenspace
with `ker Δ`, so the eigendecomposition is an *application* rather than a new theory. **Why now?** All
three hypotheses of the spectral theorem are theorems, and `hodgeLap_green_existsUnique` forces the
Green-operator formula once eigenprojections exist.

### 5. The discrete Hodge isomorphism `H = ker d / range e ≃ ker Δ` as a quotient isometry
Conjecture that the harmonic representative realizes the cohomology quotient: every class `[x]` with
`d x = 0` has a *unique* harmonic representative `P x ∈ ker Δ`, giving a linear isomorphism
`ker d / range e ≃ ker Δ`, and that it is an **isometry** for the quotient norm,
`‖[x]‖ = ‖P x‖`. Falsifiable by a closed `x` whose harmonic projection leaves the class, or a class
whose quotient norm differs from `‖P x‖`. **The key insight is** that `range Δ = (ker Δ)ᗮ` already
splits any closed cochain into a harmonic part `P x` and a part in `range Δ = range d* ⊕ range e`;
restricted to closed cochains the `d*`-component vanishes, so `x − P x ∈ range e` and `P x` is the
canonical class representative, with the energy minimization `‖P x‖ ≤ ‖x − e u‖` making the quotient
infimum attained exactly at `P x`. **Why now?** The orthogonal splitting and the harmonic-projection
identities are theorems this cycle; only the identification of Mathlib's `Submodule.Quotient.norm_mk`
infimum with this attained minimum remains, upgrading the linear iso to a `LinearIsometryEquiv`.

**Concept description**: # Future Directions — Discrete Hodge Laplacian, Green's Operator & Diffusion Message Passing

## Synthesis

This cycle rebuilt the discrete Hodge program on a **self-contained Mathlib foundation**, after
discovering that the catalog's entire `Hodge*` stack was non-elaborating: the files
`HodgeGreenOperator`, `HodgeHarmonicProjector`, `HodgeIsomorphism`, `HodgeResolutionIdentity` and
`HodgeThreeWayDecomposition` all `import` foundation modules (`HodgeBettiRank`,
`HodgeSpectralPositivity`, `HodgeDiffusionContraction`) that **do not exist** in the repository, and
the package declared no `srcDir`, so even the present files could not be located by `lake`. A
one-line infrastructure repair (`srcDir = "Catalog"` in `lakefile.toml`) restored module
resolution, and the new file `Catalog/Speculative/AutoResearch/HodgeLaplacianGreen.lean` re-derives
the operator-algebra, spectral, analytic and dynamical layers of the program from Mathlib alone.

The central object is the discrete **Hodge Laplacian** of a two-step cochain complex
`U --e--> V --d--> W`,
```
Δ = d* ∘ d + e ∘ e*
```
on the middle space `V`, with `d*`, `e*` the Mathlib adjoints. The single organizing identity is
the sum-of-squares **Dirichlet energy**
```
⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖²,
```
from which everything else follows: the harmonic space `ker Δ` is exactly the closed-and-co-closed
cochains (`d x = 0 ∧ e* x = 0`); the Rayleigh form is strictly positive off `ker Δ`; self-adjointness
turns `(ker Δ)ᗮ` into `range Δ`; and `Δ` is therefore invertible on the complement, yielding the
unique **Green's operator** value. On the dynamical side, the explicit-Euler diffusion step
`S = id − a·Δ` fixes the harmonic space pointwise and conserves the harmonic projection along the
whole trajectory `P (Sᵏ x) = P x`: diffusion never creates or destroys the topological (harmonic)
component, it only relaxes the exact/co-exact part.

This is the **local-to-global** picture of the engine's theme made discrete: local data (the maps
`d`, `e` on individual cochains) glues, via the Hodge decomposition, into the global obstruction
object `ker Δ`, and the Green's operator is the cohomological measurement of how the non-harmonic
part is inverted.

## Results summary

| Theorem | Statement |
|---|---|
| `hodgeLap_isSymmetric` | `Δ` is self-adjoint |
| `hodgeLap_quadratic_form` | `⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖²` |
| `hodgeLap_apply_eq_zero_iff` | `Δ x = 0 ↔ d x = 0 ∧ e* x = 0` (harmonic ⇔ closed & co-closed) |
| `hodgeLap_quadratic_eq_zero_iff` | `⟪Δ x, x⟫ = 0 ↔ Δ x = 0` (strict positivity off the kernel) |
| `hodgeLap_apply_mem_orthogonal_ker` | `Δ x ∈ (ker Δ)ᗮ` |
| `hodgeLap_range_eq_orthogonal_ker` | `range Δ = (ker Δ)ᗮ` |
| `hodgeLap_injOn_orthogonal_ker` | `Δ` is injective on `(ker Δ)ᗮ` |
| `sub_harmonicProjection_mem_orthogonal_ker` | `x − P x ∈ (ker Δ)ᗮ` |
| `hodgeLap_green_existsUnique` | unique `z ∈ (ker Δ)ᗮ` with `Δ z = x − P x` (Green value) |
| `diffStep_harmonic_fixed` / `diffStep_pow_harmonic_fixed` | `Sᵏ h = h` for harmonic `h` |
| `harmonicProjection_diffStep` / `harmonicProjection_diffStep_pow` | `P (Sᵏ x) = P x` |

All main results depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research directions

### 1. Bundle the Green's operator into an honest self-adjoint linear map
`hodgeLap_green_existsUnique` currently delivers a *pointwise* `∃!`. Conjecture it bundles into a
genuine `G : V →ₗ[ℝ] V` with `G ∘ Δ = Δ ∘ G = id − P_harmonic`, `G ∘ P_harmonic = 0`, and `G`
self-adjoint (`⟪G x, y⟫ = ⟪x, G y⟫`). Falsifiable by any candidate `G` with `Δ (G x) ≠ x − P x` on
some `x`, or with `⟪G x, y⟫ ≠ ⟪x, G y⟫`. **The key insight is** that uniqueness is the *only*
obstruction to linearity of a solver: `z(x+y)` and `z(x)+z(y)` both solve the same `∃!` problem
(`hodgeLap_injOn_orthogonal_ker` forces them equal), so `G x := Classical.choose (hodgeLap_green_exists x)`
is automatically additive and homogeneous, and `LinearMap.mk` closes the construction.
**Why now?** Injectivity on the complement is a theorem this cycle, so each `LinearMap` axiom is a
one-line uniqueness argument, with self-adjointness following from `hodgeLap_isSymmetric` restricted
to the invariant complement.

### 2. The diffusion energy is a strict Lyapunov function with harmonic limit
Conjecture the Dirichlet energy `E(x) = ⟪Δ x, x⟫` is non-increasing along admissible diffusion,
`E(S x) ≤ E(x)` for `0 < a < 2/λ_max`, with equality iff `x` is harmonic, and that `Sᵏ x → P x` as
`k → ∞`. Falsifiable by an `x` and admissible `a` with `E(S x) > E(x)`, or a non-harmonic fixed
point of `S`. **The key insight is** that `hodgeLap_quadratic_form` already exhibits `E` as a sum of
squares whose zero set is exactly `ker Δ` (`hodgeLap_quadratic_eq_zero_iff`), and
`harmonicProjection_diffStep_pow` pins the limit's harmonic part to `P x`, so only the complementary
part must be shown to vanish. **Why now?** Both the Lyapunov candidate (the proven quadratic form)
and the conserved target (`P x`) are in hand; monotonicity reduces to a single algebraic estimate on
`E(x) − E(Sx) = 2a⟪Δx,Δx⟫ − a²⟪Δx,Δ(Δx)⟫` once `Δ` is bounded by `λ_max` on the complement.

### 3. Quantitative contraction at the spectral-gap rate
Conjecture that for an admissible step `0 < a < 2/λ_max`,
`‖Sᵏ x − P x‖ ≤ ρᵏ ‖x − P x‖` with `ρ = max_{λ>0} |1 − aλ| < 1` over the nonzero eigenvalues of `Δ`.
Falsifiable by a complex, an admissible `a`, and an iterate failing to contract by `ρ`. **The key
insight is** that `harmonicProjection_diffStep_pow` makes `x − P x` the only part that moves, and on
`(ker Δ)ᗮ` the Laplacian has strictly positive eigenvalues (`hodgeLap_quadratic_eq_zero_iff` plus
`hodgeLap_injOn_orthogonal_ker`), so `‖S y‖ ≤ ρ‖y‖` for `y ∈ (ker Δ)ᗮ` collapses to the
one-dimensional estimate `|1 − aλ| ≤ ρ` per eigenvector. **Why now?** The invariant splitting and
strict positivity are theorems, so contraction is a geometric per-eigenvalue bound rather than a
fresh dynamical-systems study — it needs only the spectral resolution of Direction 4.

### 4. Spectral resolution `Δ = Σ λᵢ Pᵢ` with `P₀ = P_harmonic` and `G = Σ_{λᵢ>0} λᵢ⁻¹ Pᵢ`
Conjecture the finite-dimensional spectral theorem for `Δ`: an orthonormal eigenbasis with
`0 = λ₀ ≤ λ₁ ≤ …`, the `0`-eigenprojection equal to `P_harmonic`, `Δ = Σ λᵢ Pᵢ`, and the Green's
operator of Direction 1 equal to `G = Σ_{λᵢ>0} λᵢ⁻¹ Pᵢ`. Falsifiable by a negative eigenvalue, a
non-harmonic `0`-eigenvector, or a mismatch `G ≠ Σ λᵢ⁻¹ Pᵢ`. **The key insight is** that
`hodgeLap_isSymmetric` feeds Mathlib's finite-dimensional spectral theorem directly, the quadratic
form pins the spectrum to `[0,∞)`, and `hodgeLap_quadratic_eq_zero_iff` identifies the `0`-eigenspace
with `ker Δ`, so the eigendecomposition is an *application* rather than a new theory. **Why now?** All
three hypotheses of the spectral theorem are theorems, and `hodgeLap_green_existsUnique` forces the
Green-operator formula once eigenprojections exist.

### 5. The discrete Hodge isomorphism `H = ker d / range e ≃ ker Δ` as a quotient isometry
Conjecture that the harmonic representative realizes the cohomology quotient: every class `[x]` with
`d x = 0` has a *unique* harmonic representative `P x ∈ ker Δ`, giving a linear isomorphism
`ker d / range e ≃ ker Δ`, and that it is an **isometry** for the quotient norm,
`‖[x]‖ = ‖P x‖`. Falsifiable by a closed `x` whose harmonic projection leaves the class, or a class
whose quotient norm differs from `‖P x‖`. **The key insight is** that `range Δ = (ker Δ)ᗮ` already
splits any closed cochain into a harmonic part `P x` and a part in `range Δ = range d* ⊕ range e`;
restricted to closed cochains the `d*`-component vanishes, so `x − P x ∈ range e` and `P x` is the
canonical class representative, with the energy minimization `‖P x‖ ≤ ‖x − e u‖` making the quotient
infimum attained exactly at `P x`. **Why now?** The orthogonal splitting and the harmonic-projection
identities are theorems this cycle; only the identification of Mathlib's `Submodule.Quotient.norm_mk`
infimum with this attained minimum remains, upgrading the linear iso to a `LinearIsometryEquiv`.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v12 Depth Requirements -- Speculative Specifier Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Speculative Specifying (Bold Conjectures)**. Target high-risk, high-reward, grand-challenge level research.

### RESEARCH CORE METHODOLOGY:
1. **Grand Challenges**: Formulate bold, surprising, and non-trivial conjectures that challenge existing intuition. Even if a complete proof cannot be achieved in this cycle, outline precise strategies, obstacles, and partial results.
2. **Deep Speculation**: Explore radical connections that seem distant or impossible at first glance. Frame your theorems as seeds for entirely new fields of study.
3. **Long-Term Roadmap**: Dedicate significant intellectual effort to detailing the proof strategies and testable predictions in your future directions, laying out a clear path for future researchers.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
