/-
# Continuous Retraction onto Compact Convex Sets

This file constructs the metric projection (nearest-point projection) onto
a nonempty compact convex subset of a real inner product space, proves it
is 1-Lipschitz, and packages it as a continuous retraction.

## Main results

* `MetricProjection.exists_unique` — existence and uniqueness of nearest point
* `MetricProjection.lipschitzWith_one` — the projection is 1-Lipschitz
* `MetricProjection.mapsTo_univ` — the projection maps into `C`
* `MetricProjection.fixedOn` — the projection fixes points in `C`
* `exists_continuous_retraction_compact_convex` — the main retraction theorem:
  there exists a continuous map `r : E → E` with `Set.MapsTo r Set.univ C`
  and `∀ x ∈ C, r x = x`.

## References

The metric projection onto a closed convex set in a Hilbert space is classical.
See e.g. Brezis, *Functional Analysis*, Chapter 5, or any convex analysis text.
-/
import Mathlib

noncomputable section

open Set InnerProductSpace

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

namespace MetricProjection

/-! ### Existence and uniqueness of the nearest point -/

/-
For a nonempty compact convex set `C` in a real inner product space,
every point has a unique nearest point in `C`.
-/
theorem exists_unique_nearest
    {C : Set E} (hne : C.Nonempty) (hcpt : IsCompact C) (hcvx : Convex ℝ C)
    (u : E) :
    ∃! v, v ∈ C ∧ ∀ w ∈ C, ‖u - v‖ ≤ ‖u - w‖ := by
  -- Use IsCompact.exists_isMinOn to get existence of a minimizer.
  obtain ⟨v, hvc, hmin⟩ : ∃ v ∈ C, ∀ w ∈ C, ‖u - v‖ ≤ ‖u - w‖ := by
    exact hcpt.exists_isMinOn hne ( continuous_norm.comp ( continuous_const.sub continuous_id' ) |> Continuous.continuousOn );
  refine' ⟨ v, ⟨ hvc, hmin ⟩, fun w ⟨ hwC, hminw ⟩ ↦ _ ⟩;
  -- By the properties of the inner product and the definition of the norm, we have:
  have h_inner : ‖u - v‖^2 + ‖u - w‖^2 = 2 * ‖u - (1 / 2 : ℝ) • (v + w)‖^2 + (1 / 2 : ℝ) * ‖v - w‖^2 := by
    norm_num [ @norm_sub_sq ℝ, @norm_add_sq ℝ ] ; ring;
    norm_num [ norm_smul, inner_add_left, inner_add_right, inner_smul_left, inner_smul_right ] ; ring;
  -- Since $C$ is convex, $(1 / 2 : ℝ) • (v + w) \in C$.
  have h_half : (1 / 2 : ℝ) • (v + w) ∈ C := by
    simpa using hcvx hvc hwC ( by norm_num ) ( by norm_num ) ( by norm_num );
  exact sub_eq_zero.mp ( norm_eq_zero.mp ( by nlinarith [ hmin _ h_half, hminw _ h_half, norm_nonneg ( u - v ), norm_nonneg ( u - w ), norm_nonneg ( u - ( 1 / 2 : ℝ ) • ( v + w ) ) ] ) ) ▸ rfl

/-- The nearest-point projection onto a nonempty compact convex set. -/
def proj {C : Set E} (hne : C.Nonempty) (hcpt : IsCompact C) (hcvx : Convex ℝ C)
    (u : E) : E :=
  (exists_unique_nearest hne hcpt hcvx u).choose

theorem proj_mem {C : Set E} (hne : C.Nonempty) (hcpt : IsCompact C) (hcvx : Convex ℝ C)
    (u : E) : proj hne hcpt hcvx u ∈ C :=
  (exists_unique_nearest hne hcpt hcvx u).choose_spec.1.1

theorem proj_nearest {C : Set E} (hne : C.Nonempty) (hcpt : IsCompact C) (hcvx : Convex ℝ C)
    (u : E) (w : E) (hw : w ∈ C) : ‖u - proj hne hcpt hcvx u‖ ≤ ‖u - w‖ :=
  (exists_unique_nearest hne hcpt hcvx u).choose_spec.1.2 w hw

theorem proj_eq_of_nearest {C : Set E} (hne : C.Nonempty) (hcpt : IsCompact C) (hcvx : Convex ℝ C)
    (u v : E) (hv : v ∈ C) (hmin : ∀ w ∈ C, ‖u - v‖ ≤ ‖u - w‖) :
    proj hne hcpt hcvx u = v := by
  have huniq := (exists_unique_nearest hne hcpt hcvx u).choose_spec.2
  exact (huniq v ⟨hv, hmin⟩).symm

/-! ### Fixed-point property -/

theorem proj_self {C : Set E} (hne : C.Nonempty) (hcpt : IsCompact C) (hcvx : Convex ℝ C)
    (u : E) (hu : u ∈ C) : proj hne hcpt hcvx u = u := by
  apply proj_eq_of_nearest
  · exact hu
  · intro w _
    simp

/-! ### 1-Lipschitz property -/

/-
The metric projection is 1-Lipschitz (nonexpansive).
-/
theorem lipschitzWith_one {C : Set E} (hne : C.Nonempty) (hcpt : IsCompact C) (hcvx : Convex ℝ C) :
    LipschitzWith 1 (proj hne hcpt hcvx) := by
  have h_proj_inner_le (u v : E) : inner ℝ (u - (proj hne hcpt hcvx) u) ((proj hne hcpt hcvx) v - (proj hne hcpt hcvx) u) ≤ 0 := by
    have h_proj_nearest : ∀ t ∈ Set.Ioo (0 : ℝ) 1, ‖u - (proj hne hcpt hcvx u)‖^2 ≤ ‖u - ((1 - t) • (proj hne hcpt hcvx u) + t • (proj hne hcpt hcvx v))‖^2 := by
      intro t ht
      have h_convex : (1 - t) • (proj hne hcpt hcvx u) + t • (proj hne hcpt hcvx v) ∈ C := by
        exact hcvx ( proj_mem hne hcpt hcvx u ) ( proj_mem hne hcpt hcvx v ) ( by linarith [ ht.1, ht.2 ] ) ( by linarith [ ht.1, ht.2 ] ) ( by linarith [ ht.1, ht.2 ] );
      exact pow_le_pow_left₀ ( norm_nonneg _ ) ( proj_nearest hne hcpt hcvx u _ h_convex ) _;
    -- Expanding the squared norm on the right-hand side, we get:
    have h_expand : ∀ t ∈ Set.Ioo (0 : ℝ) 1, ‖u - ((1 - t) • (proj hne hcpt hcvx u) + t • (proj hne hcpt hcvx v))‖^2 = ‖u - (proj hne hcpt hcvx u)‖^2 + 2 * t * inner ℝ (u - (proj hne hcpt hcvx u)) (proj hne hcpt hcvx u - proj hne hcpt hcvx v) + t^2 * ‖proj hne hcpt hcvx u - proj hne hcpt hcvx v‖^2 := by
      simp +decide [ norm_sub_sq_real, inner_sub_left, inner_sub_right, inner_smul_left, inner_smul_right ] ; intros ; ring;
      norm_num [ norm_add_sq_real, norm_smul, inner_add_left, inner_add_right, inner_smul_left, inner_smul_right ] ; ring;
      rw [ sq_abs, sq_abs ] ; ring;
    -- Dividing both sides of the inequality by $t$ and taking the limit as $t$ approaches $0$ from the right, we get:
    have h_limit : Filter.Tendsto (fun t : ℝ => (2 * inner ℝ (u - (proj hne hcpt hcvx u)) ((proj hne hcpt hcvx u) - (proj hne hcpt hcvx v)) + t * ‖(proj hne hcpt hcvx u) - (proj hne hcpt hcvx v)‖^2) / 1) (nhdsWithin 0 (Set.Ioi 0)) (nhds (2 * inner ℝ (u - (proj hne hcpt hcvx u)) ((proj hne hcpt hcvx u) - (proj hne hcpt hcvx v)))) := by
      exact tendsto_nhdsWithin_of_tendsto_nhds ( Continuous.tendsto' ( by continuity ) _ _ ( by simp +decide ) );
    have h_limit_ineq : ∀ᶠ t in nhdsWithin 0 (Set.Ioi 0), (2 * inner ℝ (u - (proj hne hcpt hcvx u)) ((proj hne hcpt hcvx u) - (proj hne hcpt hcvx v)) + t * ‖(proj hne hcpt hcvx u) - (proj hne hcpt hcvx v)‖^2) / 1 ≥ 0 := by
      filter_upwards [ Ioo_mem_nhdsGT_of_mem ⟨ le_rfl, zero_lt_one ⟩ ] with t ht using by nlinarith [ h_proj_nearest t ht, h_expand t ht, ht.1, ht.2 ] ;
    have := le_of_tendsto_of_tendsto tendsto_const_nhds h_limit h_limit_ineq; simp_all +decide [ inner_sub_left, inner_sub_right ] ;
  rw [ lipschitzWith_iff_norm_sub_le ];
  -- Apply the inner product inequality to get the desired result.
  intro x y
  have : inner ℝ (x - y) ((proj hne hcpt hcvx) x - (proj hne hcpt hcvx) y) ≥ ‖(proj hne hcpt hcvx) x - (proj hne hcpt hcvx) y‖ ^ 2 := by
    simp_all +decide [ @norm_sub_sq ℝ, inner_sub_left, inner_sub_right ];
    linarith [ h_proj_inner_le x x, h_proj_inner_le x y, h_proj_inner_le y x, h_proj_inner_le y y, real_inner_comm ( proj hne hcpt hcvx x ) ( proj hne hcpt hcvx y ) ];
  have := abs_le.mp ( abs_real_inner_le_norm ( x - y ) ( proj hne hcpt hcvx x - proj hne hcpt hcvx y ) );
  norm_num; nlinarith [ norm_nonneg ( x - y ), norm_nonneg ( proj hne hcpt hcvx x - proj hne hcpt hcvx y ) ] ;

/-- The metric projection is continuous. -/
theorem continuous_proj {C : Set E} (hne : C.Nonempty) (hcpt : IsCompact C) (hcvx : Convex ℝ C) :
    Continuous (proj hne hcpt hcvx) :=
  (lipschitzWith_one hne hcpt hcvx).continuous

/-! ### MapsTo and retraction properties -/

theorem mapsTo_univ {C : Set E} (hne : C.Nonempty) (hcpt : IsCompact C) (hcvx : Convex ℝ C) :
    MapsTo (proj hne hcpt hcvx) univ C :=
  fun _ _ => proj_mem hne hcpt hcvx _

theorem fixedOn {C : Set E} (hne : C.Nonempty) (hcpt : IsCompact C) (hcvx : Convex ℝ C) :
    ∀ x ∈ C, proj hne hcpt hcvx x = x :=
  fun x hx => proj_self hne hcpt hcvx x hx

end MetricProjection

/-! ### Main retraction theorem -/

/-- **Continuous retraction onto a compact convex set.**
For any nonempty compact convex subset `C` of a real inner product space,
there exists a continuous map `r : E → E` that maps everything into `C`
and fixes every point of `C`. Moreover, `r` is 1-Lipschitz. -/
theorem exists_continuous_retraction_compact_convex
    {C : Set E} (hne : C.Nonempty) (hcpt : IsCompact C) (hcvx : Convex ℝ C) :
    ∃ r : E → E,
      Continuous r ∧
      MapsTo r univ C ∧
      (∀ x ∈ C, r x = x) ∧
      LipschitzWith 1 r :=
  ⟨MetricProjection.proj hne hcpt hcvx,
   MetricProjection.continuous_proj hne hcpt hcvx,
   MetricProjection.mapsTo_univ hne hcpt hcvx,
   MetricProjection.fixedOn hne hcpt hcvx,
   MetricProjection.lipschitzWith_one hne hcpt hcvx⟩

end