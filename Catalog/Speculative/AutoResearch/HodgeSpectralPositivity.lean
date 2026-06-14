/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Spectral Positivity of the Hodge Laplacian

This file *extends* the Hodge–Betti theory
(`Catalog/Speculative/AutoResearch/HodgeBettiRank.lean` — `hodgeLap`, `hodgeLap_ker`) and the
self-adjointness statement of
(`Catalog/Speculative/AutoResearch/HodgeHarmonicProjector.lean` — `hodgeLap_isSelfAdjoint`)
by establishing the **spectral / variational** face of the Hodge Laplacian on the middle
cochain space of a two-step complex `U --e--> V --d--> W`:

  `Δ = d* ∘ d + e ∘ e*  : V →ₗ V`     (`HodgeBettiRank.hodgeLap`).

The Rayleigh quadratic form of `Δ` is an honest **sum of squares**

  `⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖²`        (`hodgeLap_quadratic_form`),

from which positive semidefiniteness, the equality-case kernel description, symmetry, and
eigenvalue nonnegativity all follow.  This is the "duality" picture: the operator `Δ` is
represented by its quadratic form, and the geometry of the form (sum of squares, vanishing
locus) reads off the spectral facts (`Δ ⪰ 0`, `spec Δ ⊆ [0, ∞)`, `0`-eigenspace `= ker Δ`).

## Main results

* `hodgeLap_quadratic_form`       — `⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖²` (Rayleigh form is a sum of squares).
* `hodgeLap_nonneg`               — `Δ` is positive semidefinite: `0 ≤ ⟪Δ x, x⟫`.
* `hodgeLap_quadratic_eq_zero_iff`— `⟪Δ x, x⟫ = 0 ↔ x ∈ ker Δ` (the vanishing locus is the harmonic space).
* `hodgeLap_isSymmetric`          — `Δ` is a symmetric operator (spectral-theorem input).
* `hodgeLap_eigenvalue_nonneg`    — every eigenvalue of `Δ` is `≥ 0`.

## Catalog synthesis

This realizes **Research Direction 3** ("spectral positivity") of the
`HodgeHarmonicProjector` FUTURE_DIRECTIONS.  The quadratic-form identity reuses exactly the
sum-of-squares decomposition already latent inside the proof of `HodgeBettiRank.hodgeLap_ker`,
promoting it from a kernel description to the full positivity + spectral statement, and is the
abstract-operator counterpart of the matrix-level `HodgeFullDecomposition.fullHodge_psd`.
-/
import Mathlib
import Speculative.AutoResearch.HodgeBettiRank
import Speculative.AutoResearch.HodgeHarmonicProjector

namespace HodgeSpectralPositivity

open LinearMap RealInnerProductSpace
open scoped InnerProductSpace
open HodgeBettiRank

variable {U V W : Type*}
  [NormedAddCommGroup U] [InnerProductSpace ℝ U] [FiniteDimensional ℝ U]
  [NormedAddCommGroup V] [InnerProductSpace ℝ V] [FiniteDimensional ℝ V]
  [NormedAddCommGroup W] [InnerProductSpace ℝ W] [FiniteDimensional ℝ W]

/-
!-- Lab Notebook -- !--
Hypothesis: The Rayleigh quadratic form of `Δ = d* d + e e*` should be an explicit sum of two
squared norms `‖d x‖² + ‖e* x‖²`, from which positive semidefiniteness, the kernel-as-vanishing-
locus description, symmetry, and eigenvalue nonnegativity follow with no spectral machinery.
Result: All five statements are proven sorry-free.
Insight: `⟪Δ x, x⟫ = ⟪d* d x, x⟫ + ⟪e e* x, x⟫ = ⟪d x, d x⟫ + ⟪e* x, e* x⟫` by the adjoint
adjunction `adjoint_inner_left/right`, and `⟪y, y⟫_ℝ = ‖y‖²` by `real_inner_self_eq_norm_sq`.
Positivity (`positivity`), the equality case (`add_eq_zero_iff_of_nonneg` + `norm_eq_zero` +
`hodgeLap_ker`), and the eigenvalue sign (`mu * ‖x‖² ≥ 0` with `‖x‖² > 0`) are then real
arithmetic on a sum of squares.
Failure analysis: none; once the quadratic form is in hand every downstream fact is one
`positivity`/`nlinarith` step.  No spectral theorem is invoked — positivity is purely the
sum-of-squares shape of the Rayleigh form.
!-- end Lab Notebook -- !--

!-- Rayleigh form is a sum of squares.  Expand `Δ = d* d + e e*` over `⟪·, x⟫`, push the
adjoints across with `adjoint_inner_left`, and rewrite `⟪y, y⟫_ℝ = ‖y‖²`. -- !--
-/
theorem hodgeLap_quadratic_form (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (x : V) :
    ⟪hodgeLap d e x, x⟫_ℝ = ‖d x‖ ^ 2 + ‖LinearMap.adjoint e x‖ ^ 2 := by
  unfold hodgeLap
  simp only [LinearMap.add_apply, LinearMap.comp_apply, inner_add_left,
    LinearMap.adjoint_inner_left, real_inner_self_eq_norm_sq]
  rw [← LinearMap.adjoint_inner_right, real_inner_self_eq_norm_sq]

/-
!-- Positive semidefiniteness.  `⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖² ≥ 0` (sum of squares). -- !--
-/
theorem hodgeLap_nonneg (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (x : V) :
    0 ≤ ⟪hodgeLap d e x, x⟫_ℝ := by
  rw [ hodgeLap_quadratic_form ] ; positivity

/-
!-- The vanishing locus of the Rayleigh form is the harmonic space.  `⟪Δ x, x⟫ = 0` iff
`‖d x‖² + ‖e* x‖² = 0` iff `d x = 0 ∧ e* x = 0` iff `x ∈ ker Δ` (`hodgeLap_ker`). -- !--
-/
theorem hodgeLap_quadratic_eq_zero_iff (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (x : V) :
    ⟪hodgeLap d e x, x⟫_ℝ = 0 ↔ x ∈ LinearMap.ker (hodgeLap d e) := by
  constructor <;> intro h;
  · rw [ HodgeSpectralPositivity.hodgeLap_quadratic_form ] at h;
    simp_all +decide [ add_eq_zero_iff_of_nonneg ];
    unfold hodgeLap; aesop;
  · aesop

/-
!-- `Δ` is a symmetric operator: `⟪Δ x, y⟫ = ⟪x, Δ y⟫`, the spectral-theorem input.  Immediate
from self-adjointness `hodgeLap_isSelfAdjoint` via `LinearMap.isSymmetric_iff_isSelfAdjoint`. -- !--
-/
theorem hodgeLap_isSymmetric (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) :
    (hodgeLap d e).IsSymmetric := by
  rw [ LinearMap.isSymmetric_iff_isSelfAdjoint ];
  exact HodgeHarmonicProjector.hodgeLap_isSelfAdjoint d e

/-
!-- Eigenvalues are nonnegative.  If `Δ x = μ • x` with `x ≠ 0`, then
`μ ‖x‖² = ⟪Δ x, x⟫ ≥ 0` and `‖x‖² > 0`, so `μ ≥ 0`. -- !--
-/
theorem hodgeLap_eigenvalue_nonneg (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V)
    (mu : ℝ) (x : V) (hx : x ≠ 0) (hxe : hodgeLap d e x = mu • x) : 0 ≤ mu := by
  have h_nonneg : 0 ≤ ⟪(hodgeLap d e) x, x⟫_ℝ := hodgeLap_nonneg d e x
  simp_all +decide [ inner_smul_left ]

end HodgeSpectralPositivity