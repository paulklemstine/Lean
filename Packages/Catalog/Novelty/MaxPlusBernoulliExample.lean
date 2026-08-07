/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# A fully computed example: the idempotent Bernoulli law

The abstract theorems of `Novelty.MaxPlusRateGeometry`, `Novelty.MaxPlusCramer` and
`Novelty.MaxPlusAccessibility` are only worth as much as their non-vacuity.  This file
instantiates all of them on the simplest nontrivial idempotent law — the max-plus
Bernoulli law with increments `0` (weight `-1`) and `1` (weight `0`) — and computes the
rate function in closed form, `rate x = 1 - x` on `[0,1]`.

It then exhibits a concrete velocity set for which the *full* large-deviation principle
`limsup Wₙ(G) = - inf_G rate` holds, with both sides computed explicitly.
-/

import Novelty.MaxPlusOpenLowerBound

open scoped BigOperators
open Finset

namespace IdempotentProbability

/-- The idempotent Bernoulli law: increment `1` has full max-plus mass, increment `0`
carries the penalty `-1`. -/
noncomputable def bern : MaxPlusLaw Bool where
  value := fun b => if b then 1 else 0
  weight := fun b => if b then 0 else -1
  weight_nonpos := by intro b; cases b <;> norm_num
  exists_weight_zero := ⟨true, by norm_num⟩

@[simp] theorem bern_value_true : bern.value true = 1 := rfl
@[simp] theorem bern_value_false : bern.value false = 0 := rfl
@[simp] theorem bern_weight_true : bern.weight true = 0 := rfl
@[simp] theorem bern_weight_false : bern.weight false = -1 := rfl

/-- **Closed form for the Bernoulli rate function.**  On the whole of its effective
domain `[0,1]` the idempotent Bernoulli rate is the affine function `1 - x`.  (Contrast
with the classical Bernoulli rate, which is the relative entropy; in the idempotent world
the entropy degenerates to a linear cost.) -/
theorem bern_rate {x : ℝ} (hx : x ∈ Set.Icc (0:ℝ) 1) : bern.rate x = 1 - x := by
  obtain ⟨hx0, hx1⟩ := hx
  set lam : Bool → ℝ := fun b => if b then x else 1 - x with hlam
  have hmix : bern.IsMixture x lam := by
    refine ⟨?_, ?_, ?_⟩
    · intro b; cases b <;> simp [hlam] <;> linarith
    · simp [hlam]
    · simp [hlam]
  have hscore : ∑ b, lam b * bern.weight b = x - 1 := by
    simp [hlam]
  have hcert : ∀ b : Bool,
      bern.weight b + (-1 : ℝ) * bern.value b ≤ (∑ b, lam b * bern.weight b) + (-1 : ℝ) * x := by
    intro b
    rw [hscore]
    cases b <;> simp
  have := bern.rate_eq_neg_of_supported_mixture hmix (-1 : ℝ) hcert
  rw [hscore] at this
  linarith

/-- The largest Bernoulli increment value is `1`. -/
theorem bern_vmax : bern.vmax = 1 := by
  apply le_antisymm
  · rw [MaxPlusLaw.vmax, Finset.sup'_le_iff]
    intro b _; cases b <;> norm_num
  · simpa using bern.value_le_vmax true

/-- The smallest Bernoulli increment value is `0`. -/
theorem bern_vmin : bern.vmin = 0 := by
  apply le_antisymm
  · simpa using bern.vmin_le_value false
  · rw [MaxPlusLaw.vmin, Finset.le_inf'_iff]
    intro b _; cases b <;> norm_num

/-- The effective domain of the Bernoulli rate is exactly `[0,1]`: outside it the
defining Legendre family is unbounded above. -/
theorem bern_domain (x : ℝ) :
    BddAbove (bern.legendreSet x) ↔ x ∈ Set.Icc (0:ℝ) 1 := by
  rw [bern.bddAbove_legendreSet_iff_mem_convexHull, bern.convexHull_range_value,
    bern_vmax, bern_vmin]

/-- **A concrete complete large-deviation principle.**  For the idempotent Bernoulli law
and the velocity window `G = [1/4, 1/2]`, the limit superior of the normalized max-plus
event weights is exactly `-1/2`, matching `- inf_{x ∈ G} rate x`.  Both the upper bound
(valid for every set) and the lower bound (valid because the minimizing velocity `1/2` is
accessible with denominator `2`) are used. -/
theorem bern_LDP_window :
    Filter.limsup (fun n => bern.eventWeightE n (Set.Icc (1/4 : ℝ) (1/2))) Filter.atTop
      = ((-sInf (bern.rate '' (Set.Icc (1/4 : ℝ) (1/2))) : ℝ) : EReal) := by
  have hval : ((1 : ℕ) : ℝ) * bern.value true + (((2 : ℕ) : ℝ) - (1 : ℕ)) * bern.value false
      = 1 := by norm_num
  have hkey : (((1 : ℕ) : ℝ) * bern.value true + (((2 : ℕ) : ℝ) - (1 : ℕ)) * bern.value false)
      / ((2 : ℕ) : ℝ) = 1/2 := by rw [hval]; norm_num
  have hscore : (((1 : ℕ) : ℝ) * bern.weight true + (((2 : ℕ) : ℝ) - (1 : ℕ)) * bern.weight false)
      / ((2 : ℕ) : ℝ) = -(1/2) := by norm_num
  refine maxPlus_LDP_of_accessible_minimizer bern _ true false
    (q := 2) (k := 1) (by norm_num) (by norm_num) (-1 : ℝ) ?_ ?_ ?_
  · rw [hkey]; constructor <;> norm_num
  · intro l
    rw [hkey, hscore]
    cases l <;> simp <;> norm_num
  · intro y hy
    obtain ⟨hy1, hy2⟩ := hy
    rw [hkey, bern_rate (by constructor <;> norm_num), bern_rate ⟨by linarith, by linarith⟩]
    linarith

/-- The rate infimum in the previous example, computed: `inf_{x ∈ [1/4,1/2]} rate x = 1/2`. -/
theorem bern_sInf_window : sInf (bern.rate '' (Set.Icc (1/4 : ℝ) (1/2))) = 1/2 := by
  have hleast : IsLeast (bern.rate '' (Set.Icc (1/4 : ℝ) (1/2))) (1/2) := by
    constructor
    · exact ⟨1/2, ⟨by norm_num, le_refl _⟩, by rw [bern_rate ⟨by norm_num, by norm_num⟩]; norm_num⟩
    · rintro _ ⟨y, ⟨hy1, hy2⟩, rfl⟩
      rw [bern_rate ⟨by linarith, by linarith⟩]
      linarith
  exact hleast.csInf_eq

/-- **The example in fully explicit form.**  For the idempotent Bernoulli law the
normalized max-plus weight of the velocity window `[1/4, 1/2]` has limit superior exactly
`-1/2`. -/
theorem bern_LDP_window_value :
    Filter.limsup (fun n => bern.eventWeightE n (Set.Icc (1/4 : ℝ) (1/2))) Filter.atTop
      = ((-(1/2 : ℝ)) : EReal) := by
  rw [bern_LDP_window, bern_sInf_window]
  norm_num

/-! ## An open window whose rate infimum is *not* attained -/

/-- On the open window `(1/4, 3/4)` the Bernoulli rate has infimum `1/4`, and the
infimum is **not** attained: no velocity in the window has rate `1/4`.  Consequently the
accessibility-conditioned principle `maxPlus_LDP_of_accessible_minimizer` does not apply
here, and the unconditional open-set bound is genuinely needed. -/
theorem bern_sInf_open_window :
    sInf (bern.rate '' (Set.Ioo (1/4 : ℝ) (3/4))) = 1/4 := by
  set S : Set ℝ := bern.rate '' (Set.Ioo (1/4 : ℝ) (3/4)) with hS
  have hhalf : bern.rate (1/2 : ℝ) = 1/2 := by
    rw [bern_rate ⟨by norm_num, by norm_num⟩]; norm_num
  have hmem : (1/2 : ℝ) ∈ S := ⟨1/2, by norm_num, hhalf⟩
  have hSne : S.Nonempty := ⟨1/2, hmem⟩
  have hSbdd : BddBelow S := ⟨0, by rintro _ ⟨y, -, rfl⟩; exact bern.rate_nonneg y⟩
  have hlb : ∀ z ∈ S, (1/4 : ℝ) ≤ z := by
    rintro _ ⟨y, ⟨hy1, hy2⟩, rfl⟩
    rw [bern_rate ⟨by linarith, by linarith⟩]
    linarith
  refine le_antisymm ?_ (le_csInf hSne hlb)
  by_contra hcon
  push_neg at hcon
  have hup : sInf S ≤ 1/2 := csInf_le hSbdd hmem
  set y : ℝ := 3/4 - (sInf S - 1/4) / 2 with hy
  have hy1 : (1/4 : ℝ) < y := by rw [hy]; linarith
  have hy2 : y < 3/4 := by rw [hy]; linarith
  have hyS : bern.rate y ∈ S := ⟨y, ⟨hy1, hy2⟩, rfl⟩
  have hry : bern.rate y = 1/4 + (sInf S - 1/4) / 2 := by
    rw [bern_rate ⟨by linarith, by linarith⟩, hy]; ring
  have := csInf_le hSbdd hyS
  rw [hry] at this
  linarith

/-- **The unconditional open-set principle, instantiated.**  For the idempotent Bernoulli
law and the *open* velocity window `G = (1/4, 3/4)`, the normalized max-plus event
weights converge to `-1/4 = - inf_G rate`, even though no velocity in `G` attains the
infimum.  This is `maxPlus_full_LDP_of_open_subset_hull` in action. -/
theorem bern_open_LDP :
    Filter.Tendsto (fun n => bern.eventWeightE n (Set.Ioo (1/4 : ℝ) (3/4))) Filter.atTop
      (nhds ((-(1/4 : ℝ)) : EReal)) := by
  have hsub : Set.Ioo (1/4 : ℝ) (3/4) ⊆ Set.Icc bern.vmin bern.vmax := by
    rw [bern_vmin, bern_vmax]
    rintro y ⟨hy1, hy2⟩
    exact ⟨by linarith, by linarith⟩
  have hne : (Set.Ioo (1/4 : ℝ) (3/4)).Nonempty := ⟨1/2, by norm_num⟩
  have := maxPlus_full_LDP_of_open_subset_hull bern isOpen_Ioo hsub hne
  rwa [bern_sInf_open_window] at this

end IdempotentProbability