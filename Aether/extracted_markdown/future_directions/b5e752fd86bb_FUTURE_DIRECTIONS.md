# Future Directions — Discrete Hodge Laplacian, Harmonic Space & Diffusion Message Passing

## Synthesis

This cycle rebuilds the discrete Hodge program on a **self-contained Mathlib foundation**.
The previous catalog `Hodge*` stack did not elaborate: `HodgeMessagePassingConvergence`
imports a module `Speculative.AutoResearch.HodgeSpectralThreshold` that does not exist in the
repository, and the package declared no `srcDir`, so `lake` could not even locate the catalog
sources. Two infrastructure repairs were made — adding `srcDir = "Catalog"` to `lakefile.toml`
so module resolution works at all — and a new, dependency-free file
`Catalog/Speculative/AutoResearch/HodgeLaplacianGreen.lean` re-derives the operator-algebra,
analytic, and dynamical layers of the program from Mathlib alone.

The central object is the discrete **Hodge Laplacian** of a two-step cochain complex of
finite-dimensional real inner-product spaces

```
U --e--> V --d--> W ,        Δ = d* ∘ d + e ∘ e*   on   V ,
```

with `d* = LinearMap.adjoint d` and `e* = LinearMap.adjoint e`. The single organizing identity
is the sum-of-squares **Dirichlet energy**

```
⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖² ,
```

from which everything else follows. The harmonic space `ker Δ` is exactly the
closed-and-co-closed cochains (`d x = 0 ∧ e* x = 0`); the Rayleigh form is strictly positive
off `ker Δ`; self-adjointness places the image of `Δ` inside `(ker Δ)ᗮ`. On the dynamical
side, the explicit-Euler diffusion step `S = id − a·Δ` fixes the harmonic space pointwise and
conserves the harmonic projection along the whole trajectory, `P (Sᵏ x) = P x`: diffusion
never creates or destroys the topological (harmonic) component, it only relaxes the
exact / co-exact part. This is the local-to-global picture made discrete: local data (the maps
`d`, `e` on individual cochains) glues, via the Hodge decomposition, into the global
obstruction object `ker Δ`.

## Results summary (proved sorry-free; axioms `propext, Classical.choice, Quot.sound`)

| Theorem | Statement |
|---|---|
| `hodgeLap_isSymmetric` | `Δ` is self-adjoint |
| `hodgeLap_quadratic_form` | `⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖²` |
| `hodgeLap_apply_eq_zero_iff` | `Δ x = 0 ↔ d x = 0 ∧ e* x = 0` (harmonic ⇔ closed & co-closed) |
| `hodgeLap_quadratic_eq_zero_iff` | `⟪Δ x, x⟫ = 0 ↔ Δ x = 0` (strict positivity off the kernel) |
| `hodgeLap_apply_mem_orthogonal_ker` | `Δ x ∈ (ker Δ)ᗮ` |
| `diffStep_harmonic_fixed` / `diffStep_pow_harmonic_fixed` | `Sᵏ h = h` for harmonic `h` |
| `harmonicProjection_diffStep` / `harmonicProjection_diffStep_pow` | `P (Sᵏ x) = P x` |

## Research directions

### 1. From "image in `(ker Δ)ᗮ`" to the orthogonal splitting `range Δ = (ker Δ)ᗮ`
This cycle proves the easy inclusion `Δ x ∈ (ker Δ)ᗮ` (`hodgeLap_apply_mem_orthogonal_ker`).
Conjecture the full identity `range Δ = (ker Δ)ᗮ`, and consequently that `Δ` is a linear
isomorphism of `(ker Δ)ᗮ` onto itself. Falsifiable by any `y ∈ (ker Δ)ᗮ` not of the form
`Δ x`, or any nonzero `z ∈ (ker Δ)ᗮ` with `Δ z = 0`. **The key insight is** that injectivity
on the complement is immediate from strict positivity — if `z ∈ (ker Δ)ᗮ` and `Δ z = 0` then
`z ∈ ker Δ ∩ (ker Δ)ᗮ = 0` — and in finite dimensions an injective self-map of `(ker Δ)ᗮ` is
surjective, so the rank–nullity count `dim(range Δ) = dim V − dim(ker Δ) = dim (ker Δ)ᗮ`
closes the inclusion to an equality. **Why now?** Self-adjointness, strict positivity, and the
membership lemma are all theorems this cycle, so the remaining step is a dimension count using
Mathlib's `LinearMap.finrank_range_add_finrank_ker` and `Submodule.finrank_add_finrank_orthogonal`.

### 2. Bundle the Green's operator into an honest self-adjoint linear map
With Direction 1 in hand, every `x` has a unique `z ∈ (ker Δ)ᗮ` with `Δ z = x − P x`.
Conjecture this assembles into a genuine `G : V →ₗ[ℝ] V` with `Δ ∘ G = G ∘ Δ = id − P`,
`G ∘ P = 0`, and `G` self-adjoint (`⟪G x, y⟫ = ⟪x, G y⟫`). Falsifiable by a candidate `G` with
`Δ (G x) ≠ x − P x` on some `x`, or with `⟪G x, y⟫ ≠ ⟪x, G y⟫`. **The key insight is** that
uniqueness is the *only* obstruction to linearity of a solver: `z(x+y)` and `z(x)+z(y)` solve
the same problem, so injectivity on `(ker Δ)ᗮ` forces them equal, making
`G x := Classical.choose …` automatically additive and homogeneous, with `LinearMap.mk` closing
the construction. **Why now?** Direction 1 supplies the existence-and-uniqueness needed; each
`LinearMap` axiom is then a one-line uniqueness argument, and self-adjointness follows from
`hodgeLap_isSymmetric` restricted to the invariant complement.

### 3. The diffusion energy is a strict Lyapunov function with harmonic limit
Conjecture the Dirichlet energy `E(x) = ⟪Δ x, x⟫` is non-increasing along admissible diffusion,
`E(S x) ≤ E(x)` for `0 < a < 2/λ_max`, with equality iff `x` is harmonic, and that `Sᵏ x → P x`
as `k → ∞`. Falsifiable by an `x` and admissible `a` with `E(S x) > E(x)`, or a non-harmonic
fixed point of `S`. **The key insight is** that `hodgeLap_quadratic_form` already exhibits `E`
as a sum of squares whose zero set is exactly `ker Δ` (`hodgeLap_quadratic_eq_zero_iff`), and
`harmonicProjection_diffStep_pow` pins the limit's harmonic part to `P x`, so only the
complementary part must be shown to vanish. **Why now?** Both the Lyapunov candidate (the proven
quadratic form) and the conserved target (`P x`) are in hand; monotonicity reduces to the single
algebraic estimate `E(x) − E(Sx) = 2a⟪Δx,Δx⟫ − a²⟪Δx,Δ(Δx)⟫ ≥ 0` once `Δ` is bounded by `λ_max`
on the complement.

### 4. Spectral resolution `Δ = Σ λᵢ Pᵢ` with `P₀ = P` and `G = Σ_{λᵢ>0} λᵢ⁻¹ Pᵢ`
Conjecture the finite-dimensional spectral theorem for `Δ`: an orthonormal eigenbasis with
`0 = λ₀ ≤ λ₁ ≤ …`, the `0`-eigenprojection equal to the harmonic projection `P`, `Δ = Σ λᵢ Pᵢ`,
and the Green's operator of Direction 2 equal to `G = Σ_{λᵢ>0} λᵢ⁻¹ Pᵢ`. Falsifiable by a
negative eigenvalue, a non-harmonic `0`-eigenvector, or a mismatch `G ≠ Σ λᵢ⁻¹ Pᵢ`. **The key
insight is** that `hodgeLap_isSymmetric` feeds Mathlib's finite-dimensional spectral theorem
directly, the quadratic form pins the spectrum to `[0, ∞)`, and `hodgeLap_quadratic_eq_zero_iff`
identifies the `0`-eigenspace with `ker Δ`, so the eigendecomposition is an *application* rather
than a new theory. **Why now?** All three hypotheses of the spectral theorem are theorems this
cycle, and Direction 2's Green operator forces the inverse-eigenvalue formula once the
eigenprojections exist; the contraction rate `ρ = max_{λ>0} |1 − aλ|` of diffusion then drops out
per eigenvector.

### 5. The discrete Hodge isomorphism `ker d / range e ≃ ker Δ` as a quotient isometry
Conjecture that the harmonic representative realizes the cohomology quotient: every closed class
`[x]` (with `d x = 0`) has a unique harmonic representative `P x ∈ ker Δ`, giving a linear
isomorphism `ker d / range e ≃ ker Δ` that is moreover an **isometry** for the quotient norm,
`‖[x]‖ = ‖P x‖`. (This direction needs the cochain condition `d ∘ e = 0`, which the present file
does not yet assume.) Falsifiable by a closed `x` whose harmonic projection leaves the class, or a
class whose quotient norm differs from `‖P x‖`. **The key insight is** that Direction 1's splitting
`range Δ = (ker Δ)ᗮ` separates any closed cochain into a harmonic part `P x` and a part in
`range Δ = range d* ⊕ range e`; restricted to closed cochains the `d*`-component vanishes, so
`x − P x ∈ range e` and `P x` is the canonical representative, with `‖P x‖ ≤ ‖x − e u‖` making the
quotient infimum attained exactly at `P x`. **Why now?** The orthogonal splitting and harmonic
projection identities are (or shortly will be) theorems; only the identification of Mathlib's
`Submodule.Quotient.norm_mk` infimum with this attained minimum remains to upgrade the linear iso
to a `LinearIsometryEquiv`.
