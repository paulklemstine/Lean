# Future Directions — Hodge–Laplacian Message Passing, Sixth Cycle

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
