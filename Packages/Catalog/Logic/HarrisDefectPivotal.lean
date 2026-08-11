/-
# The exact Harris defect at a single site, and strict correlation for grid crossings

The catalog theorem `crossing_harris_open_site` states the Harris bound
`p · θ_n(p) ≤ P_p(crossing ∩ {v open})` for the `n × n` grid.  Conjecture 3 of
the previous cycle of this research thread asks whether the inequality is
*strict*.  This file answers yes, and does so by computing the defect exactly.

For an increasing event `A` and a site `v`,

`bernProb p (A ∩ {η | η v = true}) = p * bernProb p A + p * (1 - p) * bernProb p (pivotalSet A v)`,

so the Harris defect at a single site is exactly `p(1-p)` times the pivotal
probability of that site (`bernProb_inter_openSite_eq`).  Consequently, for
`p ∈ (0,1)` the Harris bound at a site is strict precisely when the site is
pivotal for at least one configuration (`harris_openSite_strict_iff`).

For horizontal crossings of the grid, every site is pivotal: the configuration
that opens exactly the column through `v` crosses, and closing `v` disconnects
it, because a walk confined to one column changes its row index by one at each
step and therefore cannot jump over the removed row
(`gridWalk_column_row_invariant`).  This gives the strict Harris inequality at
every site of every grid (`crossing_harris_open_site_strict`).

## Main results

* `bernProb_inter_openSite_eq`: the exact one-site Harris defect formula.
* `harris_openSite_strict_iff`: strictness of the one-site Harris bound is
  equivalent to the existence of a pivotal configuration.
* `gridWalk_column_row_invariant`: a grid walk confined to a single column minus
  one row cannot cross that row.
* `crossingEvent_pivotalSet_nonempty`: every site of the grid is pivotal for the
  horizontal crossing event.
* `crossing_harris_open_site_strict`: **Conjecture 3**, the strict form of
  `crossing_harris_open_site`, for every `n ≥ 1`, every site and every
  `p ∈ (0,1)`.
-/

import Combinatorics.HarrisFKGThresholdCoupling

open Finset

namespace BernoulliThresholdCoupling

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## The exact one-site Harris defect -/

/-- **The one-site Harris defect formula.**  For an increasing event the excess
of `P(A ∩ {v open})` over `p · P(A)` is exactly `p(1-p)` times the pivotal
probability of `v`. -/
theorem bernProb_inter_openSite_eq {A : Set (ι → Bool)} (hA : IsIncreasing A) (p : ℝ) (v : ι) :
    bernProb p (A ∩ {η : ι → Bool | η v = true}) =
      p * bernProb p A + p * (1 - p) * bernProb p (pivotalSet A v) := by
  classical
  rw [bernProb_eq_sum_mul_indicator, bernProb_eq_sum_mul_indicator,
    bernProb_eq_sum_mul_indicator, sum_split v, sum_split v, sum_split v,
    Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun η hη => ?_
  simp only [mem_filter, mem_univ, true_and] at hη
  have hwη : weight p η = p * offWeight p v η := by
    rw [weight_eq_mul_offWeight p v η, hη]; simp
  have hwη₀ : weight p (Function.update η v false) = (1 - p) * offWeight p v η := by
    rw [weight_eq_mul_offWeight p v (Function.update η v false), offWeight_update]
    simp
  have hupd : Function.update η v true = η := by
    rw [← hη]; exact Function.update_eq_self v η
  have hdom : ∀ u, Function.update η v false u = true → η u = true := by
    intro u hu
    by_cases huv : u = v
    · subst huv; simp at hu
    · rwa [Function.update_of_ne huv] at hu
  have hnotV : Function.update η v false ∉ {η : ι → Bool | η v = true} := by
    simp [Set.mem_setOf_eq]
  have hpivη₀ : (pivotalSet A v).indicator (fun _ => (1 : ℝ)) (Function.update η v false)
      = (pivotalSet A v).indicator (fun _ => (1 : ℝ)) η := by
    by_cases h : η ∈ pivotalSet A v
    · rw [Set.indicator_of_mem ((pivotalSet_update_mem_iff A v η false).mpr h),
        Set.indicator_of_mem h]
    · rw [Set.indicator_of_notMem
        (fun hc => h ((pivotalSet_update_mem_iff A v η false).mp hc)),
        Set.indicator_of_notMem h]
  rw [hwη, hwη₀, hpivη₀]
  by_cases hηA : η ∈ A
  · by_cases hη₀A : Function.update η v false ∈ A
    · have hpiv : η ∉ pivotalSet A v := by
        simp only [pivotalSet, Set.mem_setOf_eq, not_and, not_not]
        exact fun _ => hη₀A
      rw [Set.indicator_of_mem (show η ∈ A ∩ {η : ι → Bool | η v = true} from ⟨hηA, hη⟩),
        Set.indicator_of_notMem (fun hc => hnotV hc.2), Set.indicator_of_mem hηA,
        Set.indicator_of_mem hη₀A, Set.indicator_of_notMem hpiv]
      ring
    · have hpiv : η ∈ pivotalSet A v := ⟨by rwa [hupd], hη₀A⟩
      rw [Set.indicator_of_mem (show η ∈ A ∩ {η : ι → Bool | η v = true} from ⟨hηA, hη⟩),
        Set.indicator_of_notMem (fun hc => hnotV hc.2), Set.indicator_of_mem hηA,
        Set.indicator_of_notMem hη₀A, Set.indicator_of_mem hpiv]
      ring
  · have hη₀A : Function.update η v false ∉ A := fun hc => hηA (hA _ _ hdom hc)
    have hpiv : η ∉ pivotalSet A v := by
      simp only [pivotalSet, Set.mem_setOf_eq, not_and, not_not]
      intro hc
      exact absurd (hupd ▸ hc) hηA
    rw [Set.indicator_of_notMem (fun hc => hηA hc.1),
      Set.indicator_of_notMem (fun hc => hnotV hc.2), Set.indicator_of_notMem hηA,
      Set.indicator_of_notMem hη₀A, Set.indicator_of_notMem hpiv]
    ring

/-- **Strictness criterion for the one-site Harris bound.** -/
theorem harris_openSite_strict_iff {A : Set (ι → Bool)} (hA : IsIncreasing A) {p : ℝ}
    (hp0 : 0 < p) (hp1 : p < 1) (v : ι) :
    p * bernProb p A < bernProb p (A ∩ {η : ι → Bool | η v = true}) ↔
      (pivotalSet A v).Nonempty := by
  rw [bernProb_inter_openSite_eq hA]
  constructor
  · intro h
    by_contra hc
    rw [Set.not_nonempty_iff_eq_empty] at hc
    rw [hc, bernProb_empty] at h
    linarith
  · intro hne
    have hpos : 0 < bernProb p (pivotalSet A v) := bernProb_pos hne hp0 hp1
    have hprod : 0 < p * (1 - p) * bernProb p (pivotalSet A v) :=
      mul_pos (mul_pos hp0 (sub_pos.mpr hp1)) hpos
    linarith

/-- The strict Harris inequality at a pivotal site. -/
theorem harris_openSite_strict {A : Set (ι → Bool)} (hA : IsIncreasing A) {p : ℝ}
    (hp0 : 0 < p) (hp1 : p < 1) {v : ι} (hpiv : (pivotalSet A v).Nonempty) :
    p * bernProb p A < bernProb p (A ∩ {η : ι → Bool | η v = true}) :=
  (harris_openSite_strict_iff hA hp0 hp1 v).mpr hpiv

/-- At a site that is never pivotal the one-site Harris bound is an equality. -/
theorem harris_openSite_eq_of_not_pivotal {A : Set (ι → Bool)} (hA : IsIncreasing A) (p : ℝ)
    {v : ι} (hpiv : pivotalSet A v = ∅) :
    bernProb p (A ∩ {η : ι → Bool | η v = true}) = p * bernProb p A := by
  rw [bernProb_inter_openSite_eq hA, hpiv, bernProb_empty]
  ring

/-! ## Grid walks confined to one column -/

/-- A walk in the grid whose sites all lie in a single column and avoid one row
cannot cross that row: the side of the removed row is a walk invariant. -/
theorem gridWalk_column_row_invariant {n : ℕ} {c : Fin n} {r : ℕ}
    {a b : Fin n × Fin n} (w : (gridGraph n).Walk a b)
    (hsup : ∀ x ∈ w.support, x.2 = c ∧ x.1.val ≠ r) :
    (a.1.val < r ↔ b.1.val < r) := by
  induction w with
  | nil => exact Iff.rfl
  | @cons x y z hadj q ih =>
    have hx : x.2 = c ∧ x.1.val ≠ r := hsup x (by simp)
    have hy : y.2 = c ∧ y.1.val ≠ r := hsup y (by simp)
    have hstep : x.1.val + 1 = y.1.val ∨ y.1.val + 1 = x.1.val := by
      rcases hadj with ⟨h1, h2⟩ | ⟨-, h2⟩
      · exfalso
        have : x.2.val = y.2.val := by rw [hx.1, hy.1]
        omega
      · exact h2
    have hstepiff : (x.1.val < r ↔ y.1.val < r) := by
      rcases hstep with h | h <;> constructor <;> intro hlt <;> omega
    refine hstepiff.trans (ih fun u hu => hsup u ?_)
    rw [SimpleGraph.Walk.support_cons]
    exact List.mem_cons_of_mem _ hu

/-! ## Every grid site is pivotal for the crossing event -/

/-- The configuration opening exactly the sites of the column through `v`. -/
def columnConfig {n : ℕ} (c : Fin n) : Fin n × Fin n → Bool :=
  fun x => decide (x.2 = c)

theorem columnConfig_apply {n : ℕ} (c : Fin n) (x : Fin n × Fin n) :
    columnConfig c x = true ↔ x.2 = c := by
  simp [columnConfig]

/-- The column configuration crosses the grid. -/
theorem columnConfig_mem_crossingEvent (n : ℕ) (hn : 0 < n) (c : Fin n) :
    columnConfig c ∈ crossingEvent n hn := by
  obtain ⟨w, hw⟩ := gridGraph_column_walk n hn c (n - 1) (by omega)
  exact ⟨c, c, w, fun x hx => (columnConfig_apply c x).mpr (hw x hx)⟩

/-- Closing the site `v` disconnects the column configuration. -/
theorem columnConfig_update_notMem_crossingEvent (n : ℕ) (hn : 0 < n)
    (v : Fin n × Fin n) :
    Function.update (columnConfig v.2) v false ∉ crossingEvent n hn := by
  rintro ⟨a, b, w, hw⟩
  have hsup : ∀ x ∈ w.support, x.2 = v.2 ∧ x.1.val ≠ v.1.val := by
    intro x hx
    have hopen := hw x hx
    have hxv : x ≠ v := by
      intro h
      rw [h, Function.update_self] at hopen
      exact absurd hopen (by simp)
    have hx2 : x.2 = v.2 := by
      rw [Function.update_of_ne hxv] at hopen
      exact (columnConfig_apply v.2 x).mp hopen
    refine ⟨hx2, fun h => hxv ?_⟩
    exact Prod.ext (Fin.ext h) hx2
  have hstart := hsup _ w.start_mem_support
  have hend := hsup _ w.end_mem_support
  have hinv := gridWalk_column_row_invariant w hsup
  simp only at hstart hend hinv
  have hv : v.1.val < n := v.1.isLt
  omega

/-- **Every site of the grid is pivotal for the horizontal crossing event.** -/
theorem crossingEvent_pivotalSet_nonempty (n : ℕ) (hn : 0 < n) (v : Fin n × Fin n) :
    (pivotalSet (crossingEvent n hn) v).Nonempty := by
  refine ⟨columnConfig v.2, ?_, columnConfig_update_notMem_crossingEvent n hn v⟩
  have hupd : Function.update (columnConfig v.2) v true = columnConfig v.2 := by
    have : columnConfig v.2 v = true := (columnConfig_apply v.2 v).mpr rfl
    rw [← this]
    exact Function.update_eq_self v (columnConfig v.2)
  rw [hupd]
  exact columnConfig_mem_crossingEvent n hn v.2

/-- **Strict Harris correlation for grid crossings.**  For every `n ≥ 1`, every
site `v` of the `n × n` grid and every `p ∈ (0,1)`, the Harris bound
`crossing_harris_open_site` is strict. -/
theorem crossing_harris_open_site_strict (n : ℕ) (hn : 0 < n) {p : ℝ} (hp0 : 0 < p)
    (hp1 : p < 1) (v : Fin n × Fin n) :
    p * bernProb p (crossingEvent n hn) <
      bernProb p (crossingEvent n hn ∩ {η | η v = true}) :=
  harris_openSite_strict (crossingEvent_isIncreasing n hn) hp0 hp1
    (crossingEvent_pivotalSet_nonempty n hn v)

/-- The defect in the grid Harris bound, computed exactly. -/
theorem crossing_harris_open_site_defect (n : ℕ) (hn : 0 < n) (p : ℝ)
    (v : Fin n × Fin n) :
    bernProb p (crossingEvent n hn ∩ {η | η v = true}) -
        p * bernProb p (crossingEvent n hn) =
      p * (1 - p) * bernProb p (pivotalSet (crossingEvent n hn) v) := by
  rw [bernProb_inter_openSite_eq (crossingEvent_isIncreasing n hn)]
  ring

end BernoulliThresholdCoupling