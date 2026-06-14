/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Harmonic Projector and the Minimal-Norm Representative

This file *extends* the Hodge–Betti theory
(`Catalog/Speculative/AutoResearch/HodgeBettiRank.lean` — `hodgeLap`, `hodgeLap_ker`) and the
three-way decomposition
(`Catalog/Speculative/AutoResearch/HodgeThreeWayDecomposition.lean` —
`harmonic_le_orthogonal_range_e`, `closed_eq_exact_sup_harmonic`) by turning the *static*
harmonic decomposition into the *operator* that realizes it: the **harmonic projector**
`P = orthogonal projection onto ker Δ`, and by establishing the **variational** characterization
of harmonic representatives (Research Directions 1 and 2 of the fourth-cycle program).

For a two-step cochain complex `U --e--> V --d--> W` with `d ∘ e = 0`:

* **Self-adjointness.** `Δ = d* d + e e*` is self-adjoint (`hodgeLap_isSelfAdjoint`).
* **Pythagoras.** A harmonic cochain is orthogonal to every exact cochain, so
  `‖h + e u‖² = ‖h‖² + ‖e u‖²` (`harmonic_exact_norm_add_sq`).
* **Minimal norm (Direction 1).** The harmonic representative is the unique minimal-norm element
  of its cohomology class: `‖h‖ ≤ ‖y‖` for every `y` cohomologous to a harmonic `h`
  (`harmonic_representative_norm_minimal`).
* **The harmonic projector (Direction 2).** Writing `P = (ker Δ).starProjection`, it kills exact
  cochains (`harmonicProjection_exact_eq_zero`), it is idempotent
  (`harmonicProjection_idempotent`), and on a *closed* cochain it returns precisely the harmonic
  representative `P (e u + h) = h` (`harmonicProjection_closed`).

## Main results

* `hodgeLap_isSelfAdjoint`            — `Δ* = Δ`.
* `harmonic_exact_norm_add_sq`        — Pythagoras: `‖h + e u‖² = ‖h‖² + ‖e u‖²`, `h` harmonic.
* `harmonic_representative_norm_minimal` — the harmonic representative minimizes the class norm.
* `harmonicProjection_exact_eq_zero`  — `P (e u) = 0`.
* `harmonicProjection_idempotent`     — `P (P x) = P x`.
* `harmonicProjection_closed`         — `P (e u + h) = h` for harmonic `h` (Hodge projector).

## Catalog synthesis

This realizes **Research Directions 1 & 2** of the `HodgeIsomorphism` FUTURE_DIRECTIONS.
`harmonic_le_orthogonal_range_e` (from the three-way file) supplies the harmonic ⊥ exact
orthogonality that powers Pythagoras and pins the projector down on the exact channel; the
minimal-norm law is then the geometric refinement of `harmonic_representative_unique`
(uniqueness from `HodgeIsomorphism`) — not just *one* harmonic representative per class, but the
*shortest* representative overall.
-/
import Mathlib
import Speculative.AutoResearch.HodgeBettiRank
import Speculative.AutoResearch.HodgeThreeWayDecomposition

namespace HodgeHarmonicProjector

open LinearMap RealInnerProductSpace
open scoped InnerProductSpace
open HodgeBettiRank HodgeThreeWayDecomposition

variable {U V W : Type*}
  [NormedAddCommGroup U] [InnerProductSpace ℝ U] [FiniteDimensional ℝ U]
  [NormedAddCommGroup V] [InnerProductSpace ℝ V] [FiniteDimensional ℝ V]
  [NormedAddCommGroup W] [InnerProductSpace ℝ W] [FiniteDimensional ℝ W]

/-
!-- Lab Notebook -- !--
Hypothesis: The harmonic decomposition `V = exact ⊕ harmonic` (on closed cochains) should be
*realized* by the orthogonal projector `P = (ker Δ).starProjection`, and the harmonic
representative of a cohomology class should be its unique minimal-norm element.
Result: All six statements are proven sorry-free.  `harmonicProjection_closed` is the
capstone: on a closed cochain `P` extracts exactly the harmonic summand.
Insight: Everything flows from one orthogonality fact, `harmonic_le_orthogonal_range_e`
(`ker Δ ≤ (range e)ᗮ`): symmetrized it gives `range e ≤ (ker Δ)ᗮ`, so `P` annihilates the
exact channel; Pythagoras `norm_add_sq_real` then collapses to `‖h‖² + ‖e u‖²` because the
cross term `⟪h, e u⟫` vanishes, which simultaneously yields the minimal-norm law and pins
the projector on closed cochains.
Failure analysis: the projector lives on the *whole* space `V` (via `Submodule.starProjection`,
an `E →L[ℝ] E` self-map), not on the subtype `↥(ker Δ)`; idempotency is then
`starProjection_eq_self_iff` applied to `starProjection_apply_mem`, and the exact-kill uses
`starProjection_apply_eq_zero_iff` after re-orienting the orthogonality `range e ≤ (ker Δ)ᗮ`.
!-- end Lab Notebook -- !--

!-- `Δ* = Δ`.  `adjoint (d*∘d + e∘e*) = adjoint(d*∘d) + adjoint(e∘e*)`, and each summand is
self-adjoint by `adjoint_comp` + `adjoint_adjoint`. -- !--
-/
theorem hodgeLap_isSelfAdjoint (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) :
    LinearMap.adjoint (hodgeLap d e) = hodgeLap d e := by
  ext; simp [hodgeLap]

/-
!-- Exact cochains are orthogonal to harmonic cochains: `range e ≤ (ker Δ)ᗮ`, the symmetric
re-orientation of `ker Δ ≤ (range e)ᗮ` (`harmonic_le_orthogonal_range_e`). -- !--
-/
theorem range_e_le_orthogonal_harmonic (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) :
    LinearMap.range e ≤ (LinearMap.ker (hodgeLap d e))ᗮ := by
  convert Submodule.orthogonal_le ( harmonic_le_orthogonal_range_e d e ) using 1;
  rw [ Submodule.orthogonal_orthogonal ]

/-
!-- Pythagoras for a harmonic + exact split.  `h ⊥ e u` (from `harmonic_le_orthogonal_range_e`),
so the cross term in `norm_add_sq_real` vanishes. -- !--
-/
theorem harmonic_exact_norm_add_sq (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V)
    (h : V) (hh : h ∈ LinearMap.ker (hodgeLap d e)) (u : U) :
    ‖h + e u‖ ^ 2 = ‖h‖ ^ 2 + ‖e u‖ ^ 2 := by
  rw [ @norm_add_pow_two_real V ];
  simp +zetaDelta at *;
  have h_orthogonal : ∀ (x : V), x ∈ LinearMap.ker (hodgeLap d e) → ∀ (y : V), y ∈ LinearMap.range e → ⟪x, y⟫_ℝ = 0 := by
    exact fun x hx y hy => Submodule.inner_right_of_mem_orthogonal hx ( range_e_le_orthogonal_harmonic d e hy );
  exact h_orthogonal h hh _ ( LinearMap.mem_range_self e u )

/-
!-- Minimal-norm representative (Direction 1).  If `y` is cohomologous to the harmonic `h`
(`y - h ∈ range e`), then `y = h + e u`, so Pythagoras gives `‖y‖² = ‖h‖² + ‖e u‖² ≥ ‖h‖²`. -- !--
-/
theorem harmonic_representative_norm_minimal (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V)
    (h y : V) (hh : h ∈ LinearMap.ker (hodgeLap d e))
    (hcohom : y - h ∈ LinearMap.range e) : ‖h‖ ≤ ‖y‖ := by
  -- From `hcohom : y - h ∈ range e`, obtain `u` with `e u = y - h`, so `y = h + e u`.
  obtain ⟨u, hu⟩ : ∃ u : U, e u = y - h := by
    exact hcohom;
  have := HodgeHarmonicProjector.harmonic_exact_norm_add_sq d e h hh u;
  rw [ hu, add_sub_cancel ] at this ; nlinarith [ norm_nonneg h, norm_nonneg y ]

/-
!-- The harmonic projector kills exact cochains.  `e u ∈ (ker Δ)ᗮ`
(`range_e_le_orthogonal_harmonic`), so `starProjection (e u) = 0`. -- !--
-/
theorem harmonicProjection_exact_eq_zero (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (u : U) :
    (LinearMap.ker (hodgeLap d e)).starProjection (e u) = 0 := by
  by_contra h_nonzero;
  exact h_nonzero ( by simpa using Submodule.starProjection_apply_eq_zero_iff ( K := LinearMap.ker ( hodgeLap d e ) ) |>.2 ( by simpa using range_e_le_orthogonal_harmonic d e ( LinearMap.mem_range_self e u ) ) )

/-
!-- The harmonic projector is idempotent.  `P x ∈ ker Δ` (`starProjection_apply_mem`), so
`P (P x) = P x` (`starProjection_eq_self_iff`). -- !--
-/
theorem harmonicProjection_idempotent (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (x : V) :
    (LinearMap.ker (hodgeLap d e)).starProjection
        ((LinearMap.ker (hodgeLap d e)).starProjection x)
      = (LinearMap.ker (hodgeLap d e)).starProjection x := by
  simp +decide [ Submodule.starProjection_eq_self_iff ]

/-
!-- The Hodge projector on closed cochains.  `P (e u + h) = P (e u) + P h = 0 + h = h`, using
linearity, `harmonicProjection_exact_eq_zero`, and `starProjection_eq_self_iff` for `h`. -- !--
-/
theorem harmonicProjection_closed (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V)
    (h : V) (hh : h ∈ LinearMap.ker (hodgeLap d e)) (u : U) :
    (LinearMap.ker (hodgeLap d e)).starProjection (e u + h) = h := by
  rw [ ContinuousLinearMap.map_add, harmonicProjection_exact_eq_zero ];
  rw [ zero_add, Submodule.starProjection_eq_self_iff.mpr ] ; aesop

end HodgeHarmonicProjector