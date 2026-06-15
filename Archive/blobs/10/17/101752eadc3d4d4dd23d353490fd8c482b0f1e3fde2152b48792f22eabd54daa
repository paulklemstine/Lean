/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Three-Way Resolution of the Identity by Hodge Projectors

This file *extends* the strong three-way Hodge decomposition
(`Catalog/Speculative/AutoResearch/HodgeThreeWayDecomposition.lean` —
`hodge_three_way_span`, `range_e_le_orthogonal_range_adjoint_d`,
`harmonic_le_orthogonal_range_adjoint_d`) and the harmonic projector
(`Catalog/Speculative/AutoResearch/HodgeHarmonicProjector.lean` —
`range_e_le_orthogonal_harmonic`) by promoting the *static* orthogonal direct sum

  `V = range d* ⊕ range e ⊕ ker Δ`     (coexact ⊕ exact ⊕ harmonic)

into the *operator* statement that the three orthogonal projectors form a **resolution of the
identity**:

  `id = P_coexact + P_exact + P_harmonic`,

with the three star-projections `P_• = (·).starProjection` pairwise annihilating
(`P_i ∘ P_j = 0` for `i ≠ j`).  This is the operator-algebra ("spectral idempotents") face of
the Hodge decomposition: each cochain is uniquely the sum of a coexact, an exact, and a
harmonic part, and these parts are extracted by mutually orthogonal idempotents summing to `1`.

## Main results

* `coexactProjection_of_threeway` / `exactProjection_of_threeway` /
  `harmonicProjection_of_threeway` — each projector returns its own summand from a three-way
  decomposition `x = c + a + h` (`c` coexact, `a` exact, `h` harmonic).
* `harmonicProjection_comp_exactProjection_eq_zero`,
  `harmonicProjection_comp_coexactProjection_eq_zero`,
  `exactProjection_comp_coexactProjection_eq_zero` — pairwise annihilation `P_i ∘ P_j = 0`.
* `hodge_resolution_identity` — `P_coexact x + P_exact x + P_harmonic x = x` (resolution of `1`).

## Catalog synthesis

This realizes **Research Direction 1** ("the full three-way idempotent splitting") of the
`HodgeHarmonicProjector` FUTURE_DIRECTIONS.  The pairwise orthogonality lemmas
(`range_e_le_orthogonal_range_adjoint_d`, `harmonic_le_orthogonal_range_e`,
`harmonic_le_orthogonal_range_adjoint_d`, `range_e_le_orthogonal_harmonic`) together with the
span `hodge_three_way_span` are already theorems, so the resolution of identity is pure
projector bookkeeping: `Submodule.starProjection_eq_self_iff` on the matching summand and
`Submodule.starProjection_apply_eq_zero_iff` on the two orthogonal summands.
-/
import Mathlib
import Speculative.AutoResearch.HodgeBettiRank
import Speculative.AutoResearch.HodgeThreeWayDecomposition
import Speculative.AutoResearch.HodgeHarmonicProjector

namespace HodgeResolutionIdentity

open LinearMap RealInnerProductSpace
open scoped InnerProductSpace
open HodgeBettiRank HodgeThreeWayDecomposition HodgeHarmonicProjector

variable {U V W : Type*}
  [NormedAddCommGroup U] [InnerProductSpace ℝ U] [FiniteDimensional ℝ U]
  [NormedAddCommGroup V] [InnerProductSpace ℝ V] [FiniteDimensional ℝ V]
  [NormedAddCommGroup W] [InnerProductSpace ℝ W] [FiniteDimensional ℝ W]

/-
!-- Lab Notebook -- !--
Hypothesis: The orthogonal direct sum `V = range d* ⊕ range e ⊕ ker Δ` is realized by three
star-projections that sum to the identity and pairwise annihilate, the operator form of the
Hodge decomposition.
Result: All ten statements are proven sorry-free; `hodge_resolution_identity` is the capstone.
Insight: For a fixed summand `K`, `starProjection_K` is `id` on `K` (`starProjection_eq_self_iff`)
and `0` on every orthogonal summand (`starProjection_apply_eq_zero_iff`).  So on a decomposition
`x = c + a + h` each projector picks out its own term, and additivity (`ContinuousLinearMap.map_add`)
gives the resolution.  The only new orthogonality facts needed are `range d* ≤ (range e)ᗮ` and
`range d* ≤ (ker Δ)ᗮ`, obtained from the existing reversed inclusions by `Submodule.orthogonal`
monotonicity and `le_orthogonal_orthogonal`.
Failure analysis: the only proof needing a nudge was `exactProjection_of_threeway` — the generic
`convert`/`congr` search wandered; rewriting it in the same explicit `have h_proj_c/h_proj_h := …`
shape as the coexact/harmonic siblings closed it immediately.  Extracting `x = c + a + h` from the
left-associated span `(range d* ⊔ range e) ⊔ ker Δ = ⊤` is a double `Submodule.mem_sup`.
!-- end Lab Notebook -- !--

!-- Coexact ⊥ exact (the orientation that kills the exact projector on coexact vectors):
`range e ≤ (range d*)ᗮ` (`range_e_le_orthogonal_range_adjoint_d`), so taking orthogonals and
using `K ≤ Kᗮᗮ` gives `range d* ≤ (range e)ᗮ`. -- !--
-/
omit [FiniteDimensional ℝ U] in
theorem range_adjoint_d_le_orthogonal_range_e (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V)
    (hde : d ∘ₗ e = 0) :
    LinearMap.range (LinearMap.adjoint d) ≤ (LinearMap.range e)ᗮ := by
  convert Submodule.orthogonal_le (range_e_le_orthogonal_range_adjoint_d d e hde) using 1
  rw [Submodule.orthogonal_orthogonal]

/-
!-- Coexact ⊥ harmonic: from `ker Δ ≤ (range d*)ᗮ` (`harmonic_le_orthogonal_range_adjoint_d`),
take orthogonals to get `range d* ≤ (ker Δ)ᗮ`. -- !--
-/
theorem range_adjoint_d_le_orthogonal_harmonic (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) :
    LinearMap.range (LinearMap.adjoint d) ≤ (LinearMap.ker (hodgeLap d e))ᗮ := by
  convert Submodule.orthogonal_le ( HodgeThreeWayDecomposition.harmonic_le_orthogonal_range_adjoint_d d e ) using 1;
  rw [ Submodule.orthogonal_orthogonal ]

/-
!-- The exact projector returns the exact summand.  `P_exact (c + a + h) = P c + P a + P h`;
`P c = 0` (`c ∈ range d* ≤ (range e)ᗮ`), `P a = a` (`a ∈ range e`), `P h = 0`
(`h ∈ ker Δ ≤ (range e)ᗮ`). -- !--
-/
theorem exactProjection_of_threeway (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (hde : d ∘ₗ e = 0)
    (c a h : V) (hc : c ∈ LinearMap.range (LinearMap.adjoint d))
    (ha : a ∈ LinearMap.range e) (hh : h ∈ LinearMap.ker (hodgeLap d e)) :
    (LinearMap.range e).starProjection (c + a + h) = a := by
  convert Submodule.starProjection_eq_self_iff.mpr ( show a ∈ LinearMap.range e from ha ) using 1;
  rw [ ContinuousLinearMap.map_add, ContinuousLinearMap.map_add ];
  rw [ show ( LinearMap.range e ).starProjection c = 0 from ?_, show ( LinearMap.range e ).starProjection h = 0 from ?_ ] <;> simp +decide [ Submodule.starProjection_apply_eq_zero_iff ];
  · exact HodgeThreeWayDecomposition.harmonic_le_orthogonal_range_e d e hh;
  · exact range_adjoint_d_le_orthogonal_range_e d e hde hc

/-
!-- The coexact projector returns the coexact summand.  `P_coexact a = 0`
(`a ∈ range e ≤ (range d*)ᗮ`), `P_coexact h = 0` (`h ∈ ker Δ ≤ (range d*)ᗮ`),
`P_coexact c = c`. -- !--
-/
theorem coexactProjection_of_threeway (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (hde : d ∘ₗ e = 0)
    (c a h : V) (hc : c ∈ LinearMap.range (LinearMap.adjoint d))
    (ha : a ∈ LinearMap.range e) (hh : h ∈ LinearMap.ker (hodgeLap d e)) :
    (LinearMap.range (LinearMap.adjoint d)).starProjection (c + a + h) = c := by
  -- By the properties of the orthogonal projection, we have that the projection of $a$ and $h$ onto the range of the adjoint of $d$ are zero.
  have h_proj_a : (LinearMap.range (LinearMap.adjoint d)).starProjection a = 0 := by
    rw [ Submodule.starProjection_apply_eq_zero_iff ];
    have := HodgeThreeWayDecomposition.range_e_le_orthogonal_range_adjoint_d d e hde; aesop;
  have h_proj_h : (LinearMap.range (LinearMap.adjoint d)).starProjection h = 0 := by
    rw [ Submodule.starProjection_apply_eq_zero_iff ];
    exact HodgeThreeWayDecomposition.harmonic_le_orthogonal_range_adjoint_d d e hh;
  simp_all +decide [ Submodule.starProjection_eq_self_iff ]

/-
!-- The harmonic projector returns the harmonic summand.  `P_harm c = 0`, `P_harm a = 0`,
`P_harm h = h`. -- !--
-/
theorem harmonicProjection_of_threeway (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V)
    (c a h : V) (hc : c ∈ LinearMap.range (LinearMap.adjoint d))
    (ha : a ∈ LinearMap.range e) (hh : h ∈ LinearMap.ker (hodgeLap d e)) :
    (LinearMap.ker (hodgeLap d e)).starProjection (c + a + h) = h := by
  rw [ ContinuousLinearMap.map_add, ContinuousLinearMap.map_add ];
  rw [ show ( hodgeLap d e ).ker.starProjection c = 0 from _, show ( hodgeLap d e ).ker.starProjection a = 0 from _, show ( hodgeLap d e ).ker.starProjection h = h from _ ] <;> norm_num;
  · exact Submodule.starProjection_eq_self_iff.mpr hh;
  · convert HodgeHarmonicProjector.harmonicProjection_exact_eq_zero d e ( Classical.choose ha ) using 1;
    rw [ Classical.choose_spec ha ];
  · rw [ Submodule.starProjection_apply_eq_zero_iff ];
    exact range_adjoint_d_le_orthogonal_harmonic d e hc

/-
!-- Pairwise annihilation: `P_harm ∘ P_exact = 0`.  `P_exact x ∈ range e ≤ (ker Δ)ᗮ`
(`range_e_le_orthogonal_harmonic`), so `starProjection_apply_eq_zero_iff` fires. -- !--
-/
theorem harmonicProjection_comp_exactProjection_eq_zero (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V)
    (x : V) :
    (LinearMap.ker (hodgeLap d e)).starProjection
        ((LinearMap.range e).starProjection x) = 0 := by
  convert Submodule.starProjection_apply_eq_zero_iff _ |>.2 _ using 1;
  have := HodgeHarmonicProjector.range_e_le_orthogonal_harmonic d e;
  exact this ( Submodule.coe_mem _ )

/-
!-- Pairwise annihilation: `P_harm ∘ P_coexact = 0`.  `P_coexact x ∈ range d* ≤ (ker Δ)ᗮ`
(`range_adjoint_d_le_orthogonal_harmonic`). -- !--
-/
theorem harmonicProjection_comp_coexactProjection_eq_zero (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V)
    (x : V) :
    (LinearMap.ker (hodgeLap d e)).starProjection
        ((LinearMap.range (LinearMap.adjoint d)).starProjection x) = 0 := by
  have := range_adjoint_d_le_orthogonal_harmonic d e;
  exact Submodule.starProjection_apply_eq_zero_iff _ |>.2 ( this <| Submodule.starProjection_apply_mem _ _ )

/-
!-- Pairwise annihilation: `P_exact ∘ P_coexact = 0`.  `P_coexact x ∈ range d* ≤ (range e)ᗮ`
(`range_adjoint_d_le_orthogonal_range_e`). -- !--
-/
theorem exactProjection_comp_coexactProjection_eq_zero (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V)
    (hde : d ∘ₗ e = 0) (x : V) :
    (LinearMap.range e).starProjection
        ((LinearMap.range (LinearMap.adjoint d)).starProjection x) = 0 := by
  exact Submodule.starProjection_apply_eq_zero_iff _ |>.2 ( Submodule.starProjection_apply_mem _ _ |> fun h => range_adjoint_d_le_orthogonal_range_e d e hde h )

/-
!-- Resolution of the identity.  By `hodge_three_way_span` write `x = c + a + h` with `c`
coexact, `a` exact, `h` harmonic; the three `…Projection_of_threeway` lemmas return `c, a, h`,
which sum back to `x`. -- !--
-/
theorem hodge_resolution_identity (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (hde : d ∘ₗ e = 0) (x : V) :
    (LinearMap.range (LinearMap.adjoint d)).starProjection x
      + (LinearMap.range e).starProjection x
      + (LinearMap.ker (hodgeLap d e)).starProjection x = x := by
  obtain ⟨c, a, h, hc, ha, hh, hx⟩ : ∃ c a h : V, c ∈ LinearMap.range (LinearMap.adjoint d) ∧ a ∈ LinearMap.range e ∧ h ∈ LinearMap.ker (HodgeBettiRank.hodgeLap d e) ∧ x = c + a + h := by
    have h_decomp : x ∈ (LinearMap.range (LinearMap.adjoint d)) ⊔ (LinearMap.range e) ⊔ (LinearMap.ker (HodgeBettiRank.hodgeLap d e)) := by
      have := HodgeThreeWayDecomposition.hodge_three_way_span d e hde; aesop;
    simp_all +decide [ Submodule.mem_sup ];
    tauto;
  convert congr_arg₂ ( · + · ) ( congr_arg₂ ( · + · ) ( HodgeResolutionIdentity.coexactProjection_of_threeway d e hde c a h hc ha hh ) ( HodgeResolutionIdentity.exactProjection_of_threeway d e hde c a h hc ha hh ) ) ( HodgeResolutionIdentity.harmonicProjection_of_threeway d e c a h hc ha hh ) using 1;
  rw [ ← hx ]

end HodgeResolutionIdentity