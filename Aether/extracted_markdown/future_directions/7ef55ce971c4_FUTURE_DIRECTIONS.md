# Future Directions — Hodge–Laplacian Message Passing, Seventh Cycle

## Synthesis

This cycle carried the discrete Hodge program from its **operator-algebra / spectral** layer
(sixth cycle: `HodgeSpectralPositivity`, `HodgeResolutionIdentity`) into its **analytic and
dynamical** layer: the *invertibility* of the Hodge Laplacian off the harmonic space and the
*dynamics* of Laplacian message passing. Two sorry-free files were added, both building directly
on the existing foundation (`HodgeBettiRank.hodgeLap`, `HodgeSpectralPositivity.hodgeLap_isSymmetric`
and `hodgeLap_quadratic_eq_zero_iff`, `HodgeHarmonicProjector`, `HodgeResolutionIdentity`).

A small infrastructure repair was needed first: the Hodge stack imports `Speculative.AutoResearch.*`
while the sources live under `Catalog/`, and the package declared no `srcDir`, so nothing
elaborated. Setting `srcDir = "Catalog"` in `lakefile.toml` re-established the build.

* **`HodgeDiffusionContraction.lean` (Direction 3, invariant-splitting half).** The explicit-Euler
  diffusion step `S = id − a·Δ` is introduced as the elementary unit of Hodge message passing. The
  self-adjoint range identity `range Δ = (ker Δ)ᗮ` (`hodgeLap_range_eq_orthogonal_ker`) shows every
  diffusion increment `Δ x` is purely non-harmonic. From it: `S` *fixes* the harmonic space
  pointwise and so does every iterate (`diffStep_harmonic_fixed`, `diffStep_pow_harmonic_fixed`),
  identifying `ker Δ` with the fixed-point set of message passing; and the harmonic projection is a
  *conserved quantity* of the dynamics, `P (Sᵏ x) = P x` for all `k`
  (`harmonicProjection_diffStep`, `harmonicProjection_diffStep_pow`). The harmonic component of a
  signal is never created or destroyed by diffusion — only the non-harmonic part evolves.

* **`HodgeGreenOperator.lean` (Direction 1, constructive core).** On the complement of the harmonic
  space `Δ` is *injective* (`hodgeLap_injOn_orthogonal_ker`, from the strict-positivity equality
  case) and *surjective onto* `(ker Δ)ᗮ` (from `hodgeLap_range_eq_orthogonal_ker`), hence invertible
  there. Consequently, for every cochain `x` there is a **unique** coexact-or-exact cochain `z`
  whose Laplacian recovers the non-harmonic part: `∃! z ∈ (ker Δ)ᗮ, Δ z = x − P x`
  (`hodgeLap_green_exists`, `hodgeLap_green_existsUnique`). That unique `z` is the value of the
  Green's operator (Moore–Penrose pseudoinverse) of `Δ`.

The picture is now *analytic*: the cochain space splits into a fixed harmonic block (the conserved
ground state of diffusion, the kernel of the pseudoinverse) and a strictly-positive complementary
block on which `Δ` is invertible and diffusion strictly evolves. Every ingredient — fixed-point
set, conserved projection, complemented kernel, injectivity on the complement, unique Green value —
is now a theorem.

## Results summary

| Theorem | File | Statement |
|---|---|---|
| `hodgeLap_apply_mem_orthogonal_ker` | HodgeDiffusionContraction | `Δ x ∈ (ker Δ)ᗮ` |
| `hodgeLap_range_eq_orthogonal_ker` | HodgeDiffusionContraction | `range Δ = (ker Δ)ᗮ` |
| `diffStep_harmonic_fixed` | HodgeDiffusionContraction | `S h = h` for harmonic `h` |
| `diffStep_pow_harmonic_fixed` | HodgeDiffusionContraction | `Sᵏ h = h` for harmonic `h` |
| `harmonicProjection_diffStep` | HodgeDiffusionContraction | `P (S x) = P x` |
| `harmonicProjection_diffStep_pow` | HodgeDiffusionContraction | `P (Sᵏ x) = P x` |
| `hodgeLap_injOn_orthogonal_ker` | HodgeGreenOperator | `x ∈ (ker Δ)ᗮ, Δ x = 0 ⟹ x = 0` |
| `sub_harmonicProjection_mem_orthogonal_ker` | HodgeGreenOperator | `x − P x ∈ (ker Δ)ᗮ` |
| `hodgeLap_green_exists` | HodgeGreenOperator | `∃ z ∈ (ker Δ)ᗮ, Δ z = x − P x` |
| `hodgeLap_green_existsUnique` | HodgeGreenOperator | `∃! z ∈ (ker Δ)ᗮ, Δ z = x − P x` |

All main results depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research directions

### 1. The Green's operator is a genuine bundled linear (self-)map
The pseudoinverse is currently a *pointwise* `∃!`. Conjecture it bundles into an honest
`G : V →ₗ[ℝ] V` (indeed a self-adjoint `V →L[ℝ] V`) with `G ∘ Δ = Δ ∘ G = id − P_harmonic`,
`G ∘ P_harmonic = P_harmonic ∘ G = 0`, and `G` self-adjoint. Falsifiable by any candidate `G`
for which `Δ (G x) ≠ x − P_harmonic x` on some `x`, or for which `⟪G x, y⟫ ≠ ⟪x, G y⟫`.
**The key insight is** that `hodgeLap_green_existsUnique` already gives a well-defined choice
function `x ↦ z(x)`, and `G x := z(x − P x) `… more precisely `G x := z(x)` with the unique
solver is *additive and homogeneous* because the solver is unique: `z(x+y)` and `z(x)+z(y)` both
solve the same `∃!` problem, so they coincide. **Why now?** Uniqueness is the only obstruction to
linearity of a solver, and it is now a theorem (`hodgeLap_injOn_orthogonal_ker`); bundling is
`LinearMap.mk` over the `Classical.choose` of `hodgeLap_green_exists` plus a one-line uniqueness
argument per linearity axiom, with self-adjointness following from symmetry of `Δ` on the
invariant complement.

### 2. Quantitative diffusion contraction at the spectral-gap rate
The invariant splitting is proven; the missing half is the *rate*. Conjecture that for an
admissible step `0 < a < 2/λ_max` the iterate obeys
`‖Sᵏ x − P_harmonic x‖ ≤ ρᵏ ‖x − P_harmonic x‖` with `ρ = max_{λ>0} |1 − aλ| < 1` ranging over
the nonzero eigenvalues of `Δ`. Falsifiable by a complex, a step `a` in range, and an iterate that
fails to contract by `ρ`. **The key insight is** that `harmonicProjection_diffStep_pow` already
makes `x − P x` the *only* part that moves, and on the complement `Δ` has strictly positive
eigenvalues (`hodgeLap_eigenvalue_nonneg` + `hodgeLap_injOn_orthogonal_ker`), so `‖S y‖ ≤ ρ‖y‖`
for `y ∈ (ker Δ)ᗮ` reduces to the operator-norm bound `‖id − aΔ‖_{(ker Δ)ᗮ} ≤ ρ`. **Why now?**
The conserved-projection and strict-positivity facts are theorems this cycle, so contraction is a
one-dimensional geometric estimate per eigenvector rather than a fresh dynamical-systems study —
it needs only the spectral theorem (Direction 4 below) to expose the eigenvalues.

### 3. Diffusion energy is monotone and its limit is the harmonic projection
Conjecture that the Dirichlet energy `E(x) = ⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖²` is *non-increasing*
along admissible diffusion, `E(S x) ≤ E(x)` for `0 < a < 2/λ_max`, with equality iff `x` is
harmonic; and that `Sᵏ x → P_harmonic x` as `k → ∞`. Falsifiable by an `x` and admissible `a`
with `E(S x) > E(x)`, or a non-harmonic fixed point of `S`. **The key insight is** that the
sum-of-squares form `hodgeLap_quadratic_form` makes `E` a Lyapunov function whose zero set is
exactly `ker Δ` (`hodgeLap_quadratic_eq_zero_iff`), and `harmonicProjection_diffStep_pow` pins the
limit's harmonic part to `P_harmonic x`, so only the complementary part needs to be shown to vanish.
**Why now?** Both the Lyapunov candidate (the proven quadratic form) and the conserved target
(`P_harmonic x`) are in hand; monotonicity is a single `nlinarith` on `E(x) − E(Sx)` once the step
is expanded, and convergence rides on Direction 2.

### 4. Spectral resolution `Δ = Σ λᵢ Pᵢ` with `P₀ = P_harmonic` and `G = Σ_{λᵢ>0} λᵢ⁻¹ Pᵢ`
Conjecture the finite-dimensional spectral theorem for `Δ`: an orthonormal eigenbasis with
`0 = λ₀ ≤ λ₁ ≤ …`, the `0`-eigenprojection equal to `P_harmonic`, `Δ = Σ λᵢ Pᵢ`, and — closing the
loop with Direction 1 — the Green's operator `G = Σ_{λᵢ > 0} λᵢ⁻¹ Pᵢ`. Falsifiable by a negative
eigenvalue, a non-harmonic `0`-eigenvector, or a mismatch `G ≠ Σ λᵢ⁻¹ Pᵢ`. **The key insight is**
that `hodgeLap_isSymmetric` feeds Mathlib's finite-dimensional spectral theorem directly,
`hodgeLap_eigenvalue_nonneg` pins the spectrum to `[0,∞)`, and `hodgeLap_quadratic_eq_zero_iff`
identifies the `0`-eigenspace with `ker Δ`, so the eigendecomposition is an *application* and
matching `P₀` to `P_harmonic` is `hodge_resolution_identity` bookkeeping. **Why now?** All three
hypotheses of the spectral theorem are theorems, and the Green-operator formula `G = Σ λᵢ⁻¹ Pᵢ` is
forced by `hodgeLap_green_existsUnique` once eigenprojections exist.

### 5. The Hodge isomorphism is a quotient isometry via the harmonic projector
`HodgeIsomorphism.hodgeCohomologyEquiv : (ker d / range e) ≃ₗ ker Δ` is still only linear.
Conjecture it is an **isometry** for the quotient norm: `‖[x]‖ = ‖P_harmonic x‖` for closed `x`.
Falsifiable by a closed class whose quotient norm differs from its harmonic representative's norm.
**The key insight is** that `HodgeHarmonicProjector.harmonic_representative_norm_minimal` proves
`‖h‖ ≤ ‖x − e u‖` over the whole class, and `harmonicProjection_closed` now shows the minimizing
representative *is* `P_harmonic x`, so the infimum defining the quotient norm is attained exactly at
the harmonic projection. **Why now?** The minimization half and the projector identity are
theorems; only the identification of Mathlib's `Submodule.Quotient.norm_mk` infimum with this
attained minimum remains, upgrading the `LinearEquiv` to a `LinearIsometryEquiv`.
