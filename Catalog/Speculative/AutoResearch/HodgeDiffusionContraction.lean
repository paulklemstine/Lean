/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Hodge Diffusion Message Passing: Harmonic Invariance of the Heat Step

This file *extends* the spectral-positivity layer
(`Catalog/Speculative/AutoResearch/HodgeSpectralPositivity.lean` — `hodgeLap_isSymmetric`,
`hodgeLap_quadratic_eq_zero_iff`) and the harmonic projector
(`Catalog/Speculative/AutoResearch/HodgeHarmonicProjector.lean` — `harmonicProjection_*`)
to the *dynamical* layer of the discrete Hodge program: **diffusion message passing**.

For a two-step complex `U --e--> V --d--> W` with `d ∘ e = 0`, the explicit-Euler heat / diffusion
step with rate `a` is the linear map

  `S = id - a • Δ  : V →ₗ V`        (`diffStep d e a`),

the elementary building block of Hodge-Laplacian graph/simplicial message passing.  This file
establishes the **invariant-splitting backbone** behind any convergence-onto-the-harmonic-space
statement (fifth-cycle Research Direction 3):

* The range of `Δ` is exactly the orthogonal complement of the harmonic space
  (`hodgeLap_range_eq_orthogonal_ker`), so every diffusion increment `Δ x` is purely
  non-harmonic.
* The diffusion step *fixes* every harmonic cochain (`diffStep_harmonic_fixed`) and, by
  induction, so does every iterate (`diffStep_pow_harmonic_fixed`): the harmonic space is the
  fixed-point set of message passing.
* The harmonic projector is **conserved** by a single step (`harmonicProjection_diffStep`) and by
  every iterate (`harmonicProjection_diffStep_pow`): `P (Sᵏ x) = P x`.  The harmonic component of
  a signal is a conserved quantity of diffusion — it is never created or destroyed, only the
  non-harmonic part evolves.

## Main results

* `hodgeLap_apply_mem_orthogonal_ker` — `Δ x ∈ (ker Δ)ᗮ` (increments are non-harmonic).
* `hodgeLap_range_eq_orthogonal_ker`  — `range Δ = (ker Δ)ᗮ`.
* `diffStep_harmonic_fixed`           — `S h = h` for harmonic `h`.
* `diffStep_pow_harmonic_fixed`       — `Sᵏ h = h` for harmonic `h`.
* `harmonicProjection_diffStep`       — `P (S x) = P x` (one-step conservation).
* `harmonicProjection_diffStep_pow`   — `P (Sᵏ x) = P x` (conservation along the orbit).

## Catalog synthesis

This realizes the *invariant-splitting* half of **Research Direction 3** ("diffusion message
passing contracts onto `P_harmonic`") of `HodgeResolutionIdentity`'s FUTURE_DIRECTIONS.  The
self-adjointness `hodgeLap_isSelfAdjoint` (via `IsSymmetric.orthogonal_range`) makes
`range Δ = (ker Δ)ᗮ`, which simultaneously kills `P` on every increment and identifies `ker Δ`
with the fixed-point set of `S`.  The remaining quantitative contraction rate (a one-dimensional
geometric-series estimate per eigenvector) is deferred to the next cycle once the spectral
resolution is in hand.
-/
import Mathlib
import Speculative.AutoResearch.HodgeBettiRank
import Speculative.AutoResearch.HodgeSpectralPositivity
import Speculative.AutoResearch.HodgeHarmonicProjector

namespace HodgeDiffusionContraction

open LinearMap RealInnerProductSpace
open scoped InnerProductSpace
open HodgeBettiRank

variable {U V W : Type*}
  [NormedAddCommGroup U] [InnerProductSpace ℝ U] [FiniteDimensional ℝ U]
  [NormedAddCommGroup V] [InnerProductSpace ℝ V] [FiniteDimensional ℝ V]
  [NormedAddCommGroup W] [InnerProductSpace ℝ W] [FiniteDimensional ℝ W]

/-
!-- Lab Notebook -- !--
Hypothesis: The diffusion step `S = id - a Δ` should fix the harmonic space pointwise and conserve
the harmonic projection of any signal, because `Δ` is self-adjoint (so `range Δ ⊥ ker Δ`) and
vanishes on `ker Δ`.  This is the invariant-splitting backbone of "diffusion contracts onto
`P_harmonic`".
Result: All six statements are proven sorry-free.
Insight: Self-adjointness gives `range Δ = (ker Δ)ᗮ` (`IsSymmetric.orthogonal_range` + double
orthogonal complement), so `P (Δ x) = 0` by `starProjection_apply_eq_zero_iff`; linearity of `S`
and of `P` then yields one-step conservation, and `Nat`-induction lifts both the fixed-point and
the conservation facts to every iterate `Sᵏ`.
Failure analysis: the iterate uses the endomorphism power `S ^ k` (the `Module.End` monoid);
`pow_succ'` (`S^(k+1) = S * S^k`) unfolds it as `S ((S^k) x)`, the orientation the induction needs.
!-- end Lab Notebook -- !--
-/

/-- The explicit-Euler **diffusion / heat step** of the Hodge Laplacian with rate `a`:
`S = id - a • Δ`. -/
noncomputable def diffStep (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (a : ℝ) : V →ₗ[ℝ] V :=
  LinearMap.id - a • hodgeLap d e

/-
!-- Diffusion increments are non-harmonic: `Δ x ∈ (ker Δ)ᗮ`.  For harmonic `k`,
`⟪Δ x, k⟫ = ⟪x, Δ k⟫ = 0`, by self-adjointness `hodgeLap_isSelfAdjoint`. -- !--
-/
theorem hodgeLap_apply_mem_orthogonal_ker (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (x : V) :
    hodgeLap d e x ∈ (LinearMap.ker (hodgeLap d e))ᗮ := by
  intro y hy;
  convert congr_arg ( fun z => ⟪z, x⟫_ℝ ) hy using 1;
  · rw [ ← LinearMap.adjoint_inner_right ];
    rw [ HodgeHarmonicProjector.hodgeLap_isSelfAdjoint ];
  · simp +decide

/-
!-- `range Δ = (ker Δ)ᗮ`.  By `IsSymmetric.orthogonal_range` (`hodgeLap_isSymmetric`),
`(range Δ)ᗮ = ker Δ`; take orthogonal complements and use `Kᗮᗮ = K`. -- !--
-/
theorem hodgeLap_range_eq_orthogonal_ker (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) :
    LinearMap.range (hodgeLap d e) = (LinearMap.ker (hodgeLap d e))ᗮ := by
  rw [ ← (HodgeSpectralPositivity.hodgeLap_isSymmetric d e).orthogonal_range,
    Submodule.orthogonal_orthogonal ]

/-
!-- The diffusion step fixes harmonic cochains: `S h = h − a • Δ h = h − 0 = h`. -- !--
-/
theorem diffStep_harmonic_fixed (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (a : ℝ)
    (h : V) (hh : h ∈ LinearMap.ker (hodgeLap d e)) :
    diffStep d e a h = h := by
  unfold diffStep; simp_all +decide [ LinearMap.mem_ker ] ;

/-
!-- Every iterate fixes harmonic cochains: `Sᵏ h = h`, by induction using
`diffStep_harmonic_fixed`. -- !--
-/
theorem diffStep_pow_harmonic_fixed (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (a : ℝ)
    (h : V) (hh : h ∈ LinearMap.ker (hodgeLap d e)) (k : ℕ) :
    ((diffStep d e a) ^ k) h = h := by
  induction' k with k ih;
  · rfl;
  · simp +decide [ *, pow_succ' ];
    exact diffStep_harmonic_fixed d e a h hh

/-
!-- One-step conservation of the harmonic projection: `P (S x) = P x`.
`P (S x) = P x − a • P (Δ x)` and `P (Δ x) = 0` because `Δ x ∈ (ker Δ)ᗮ`
(`hodgeLap_apply_mem_orthogonal_ker`, `starProjection_apply_eq_zero_iff`). -- !--
-/
theorem harmonicProjection_diffStep (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (a : ℝ) (x : V) :
    (LinearMap.ker (hodgeLap d e)).starProjection (diffStep d e a x)
      = (LinearMap.ker (hodgeLap d e)).starProjection x := by
  unfold diffStep; simp +decide [ sub_eq_add_neg ] ;
  exact Or.inr ( Submodule.starProjection_apply_eq_zero_iff _ |>.2 ( hodgeLap_apply_mem_orthogonal_ker d e x ) )

/-
!-- Conservation along the whole orbit: `P (Sᵏ x) = P x`, by induction using
`harmonicProjection_diffStep`. -- !--
-/
theorem harmonicProjection_diffStep_pow (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (a : ℝ) (x : V) (k : ℕ) :
    (LinearMap.ker (hodgeLap d e)).starProjection (((diffStep d e a) ^ k) x)
      = (LinearMap.ker (hodgeLap d e)).starProjection x := by
  induction k <;> simp_all +decide [ pow_succ' ];
  rw [ ← ‹ ( hodgeLap d e ).ker.starProjection ( ( diffStep d e a ^ _ ) x ) = ( hodgeLap d e ).ker.starProjection x ›, harmonicProjection_diffStep ]

end HodgeDiffusionContraction