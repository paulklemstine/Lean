/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Green's Operator: Inverting the Hodge Laplacian off the Harmonic Space

This file *extends* the spectral-positivity layer
(`Catalog/Speculative/AutoResearch/HodgeSpectralPositivity.lean` —
`hodgeLap_quadratic_eq_zero_iff`), the harmonic projector
(`Catalog/Speculative/AutoResearch/HodgeHarmonicProjector.lean`), and the diffusion layer
(`Catalog/Speculative/AutoResearch/HodgeDiffusionContraction.lean` —
`hodgeLap_range_eq_orthogonal_ker`) to construct the **Green's operator** of the Hodge Laplacian:
the Moore–Penrose pseudoinverse that inverts `Δ` exactly on the orthogonal complement of the
harmonic space.

For a two-step complex `U --e--> V --d--> W` with `d ∘ e = 0`, the Hodge decomposition splits
`V` into the harmonic block `ker Δ` (where `Δ = 0`) and its complement `(ker Δ)ᗮ`.  This file
shows that on the complement `Δ` is **injective** and **surjective onto `(ker Δ)ᗮ`**, hence
invertible there, so for every cochain `x` there is a *unique* coexact-or-exact cochain whose
Laplacian recovers the non-harmonic part `x − P_harmonic x`.  That unique solution is the value
of the Green's operator.

## Main results

* `hodgeLap_injOn_orthogonal_ker` — `Δ` is injective on `(ker Δ)ᗮ`:
  `x ∈ (ker Δ)ᗮ → Δ x = 0 → x = 0`.
* `sub_harmonicProjection_mem_orthogonal_ker` — `x − P x ∈ (ker Δ)ᗮ` (the non-harmonic part).
* `hodgeLap_green_exists` — for every `x` there exists `z ∈ (ker Δ)ᗮ` with
  `Δ z = x − P x` (existence of the Green value).
* `hodgeLap_green_existsUnique` — that `z` is **unique** (the Green's operator is well defined):
  `∃! z, z ∈ (ker Δ)ᗮ ∧ Δ z = x − P x`.

## Catalog synthesis

This realizes the *constructive core* of **Research Direction 1** ("the Green's operator inverts
`Δ` off the harmonic space") of `HodgeResolutionIdentity`'s FUTURE_DIRECTIONS.  Injectivity on the
complement is the strict-positivity equality case `hodgeLap_quadratic_eq_zero_iff` (the only
`0`-locus of the Rayleigh form is `ker Δ`), and surjectivity onto the complement is the
self-adjoint range identity `hodgeLap_range_eq_orthogonal_ker`.  Together — a complemented kernel
plus injectivity on the complement — they are exactly the two ingredients of a pseudoinverse, so
the Green value is assembled by witness extraction rather than any new analysis.
-/
import Mathlib
import Speculative.AutoResearch.HodgeBettiRank
import Speculative.AutoResearch.HodgeSpectralPositivity
import Speculative.AutoResearch.HodgeHarmonicProjector
import Speculative.AutoResearch.HodgeDiffusionContraction

namespace HodgeGreenOperator

open LinearMap RealInnerProductSpace
open scoped InnerProductSpace
open HodgeBettiRank HodgeDiffusionContraction

variable {U V W : Type*}
  [NormedAddCommGroup U] [InnerProductSpace ℝ U] [FiniteDimensional ℝ U]
  [NormedAddCommGroup V] [InnerProductSpace ℝ V] [FiniteDimensional ℝ V]
  [NormedAddCommGroup W] [InnerProductSpace ℝ W] [FiniteDimensional ℝ W]

/-
!-- Lab Notebook -- !--
Hypothesis: On `(ker Δ)ᗮ` the Hodge Laplacian is invertible — injective (strict positivity) and
surjective onto `(ker Δ)ᗮ` (self-adjoint range) — so the non-harmonic part `x − P x` of any signal
has a unique preimage `z ∈ (ker Δ)ᗮ`, the value of the Green's operator / Moore–Penrose
pseudoinverse.
Result: All four statements are proven sorry-free; `hodgeLap_green_existsUnique` is the capstone.
Insight: Injectivity is `x ∈ (ker Δ)ᗮ` plus `Δ x = 0 ⟹ x ∈ ker Δ` (so `x ∈ ker Δ ⊓ (ker Δ)ᗮ = 0`).
For existence, `x − P x ∈ (ker Δ)ᗮ = range Δ` (`hodgeLap_range_eq_orthogonal_ker`) gives a raw
preimage `z₀`; subtracting its harmonic part `z = z₀ − P z₀ ∈ (ker Δ)ᗮ` keeps `Δ z = Δ z₀` because
`Δ (P z₀) = 0`.  Uniqueness is injectivity applied to the difference of two solutions.
Failure analysis: the membership `x − P x ∈ (ker Δ)ᗮ` is exactly `sub_starProjection_mem_orthogonal`;
the `ker Δ ⊓ (ker Δ)ᗮ = ⊥` step is `Submodule.inf_orthogonal_eq_bot`.
!-- end Lab Notebook -- !--

!-- `Δ` is injective on `(ker Δ)ᗮ`.  If `x ∈ (ker Δ)ᗮ` and `Δ x = 0` then `x ∈ ker Δ`
(`mem_ker`), so `x ∈ ker Δ ⊓ (ker Δ)ᗮ = ⊥`. -- !--
-/
theorem hodgeLap_injOn_orthogonal_ker (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V)
    (x : V) (hx : x ∈ (LinearMap.ker (hodgeLap d e))ᗮ) (hxk : hodgeLap d e x = 0) :
    x = 0 := by
  exact inner_self_eq_zero.mp (hx x hxk)

/-
!-- The non-harmonic part lies in the complement: `x − P x ∈ (ker Δ)ᗮ`, by
`sub_starProjection_mem_orthogonal`. -- !--
-/
theorem sub_harmonicProjection_mem_orthogonal_ker (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (x : V) :
    x - (LinearMap.ker (hodgeLap d e)).starProjection x ∈ (LinearMap.ker (hodgeLap d e))ᗮ := by
  exact Submodule.sub_starProjection_mem_orthogonal x

/-
!-- Existence of the Green value.  `x − P x ∈ (ker Δ)ᗮ = range Δ`, so pick `z₀` with
`Δ z₀ = x − P x`; then `z = z₀ − P z₀ ∈ (ker Δ)ᗮ` satisfies `Δ z = Δ z₀ = x − P x` since
`Δ (P z₀) = 0`. -- !--
-/
theorem hodgeLap_green_exists (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (x : V) :
    ∃ z : V, z ∈ (LinearMap.ker (hodgeLap d e))ᗮ ∧
      hodgeLap d e z = x - (LinearMap.ker (hodgeLap d e)).starProjection x := by
  obtain ⟨z0, hz0⟩ : ∃ z0 : V, (hodgeLap d e) z0 = x - (LinearMap.ker (hodgeLap d e)).starProjection x := by
    have h_range : LinearMap.range (hodgeLap d e) = (LinearMap.ker (hodgeLap d e))ᗮ := by
      exact hodgeLap_range_eq_orthogonal_ker d e;
    exact LinearMap.mem_range.mp ( h_range.symm ▸ sub_harmonicProjection_mem_orthogonal_ker d e x );
  refine' ⟨ z0 - ( LinearMap.ker ( hodgeLap d e ) ).starProjection z0, _, _ ⟩ <;> simp_all +decide;
  exact LinearMap.mem_ker.mp ( Submodule.starProjection_apply_mem _ _ )

/-
!-- The Green value is unique: the Green's operator is well defined.  Existence is
`hodgeLap_green_exists`; uniqueness is `hodgeLap_injOn_orthogonal_ker` applied to the difference
of two candidate solutions, which lies in `(ker Δ)ᗮ` and is killed by `Δ`. -- !--
-/
theorem hodgeLap_green_existsUnique (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (x : V) :
    ∃! z : V, z ∈ (LinearMap.ker (hodgeLap d e))ᗮ ∧
      hodgeLap d e z = x - (LinearMap.ker (hodgeLap d e)).starProjection x := by
  obtain ⟨ z, hz ⟩ := hodgeLap_green_exists d e x;
  refine' ⟨ z, hz, fun w hw => _ ⟩;
  have := hodgeLap_injOn_orthogonal_ker d e ( w - z ) ?_ ?_ <;> simp_all +decide [ sub_eq_zero ];
  exact Submodule.sub_mem _ hw.1 hz.1

end HodgeGreenOperator