# Future Directions — Discrete Hodge Laplacian, Green's Operator & Diffusion Message Passing

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
