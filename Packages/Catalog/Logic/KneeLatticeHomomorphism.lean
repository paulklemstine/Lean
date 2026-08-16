/-
# The knee is a lattice homomorphism from retained curves to budgets (NET-44, cycle 4)

The previous cycles treated seeds one at a time.  This one identifies the algebraic
structure behind the two-seed bracket: the knee functional turns the *pointwise lattice
operations on retained-accuracy curves* into the *lattice operations on budgets*, with
the order reversed.

* `KneeLattice.passingSet_isUpSet` : for a monotone curve the set of grid points clearing
  the bar is an up-set of the grid, and `KneeLattice.isKnee_iff_min'` identifies the knee
  with its minimum.  A sweep therefore carries exactly the information of an up-set of
  `G`, and nothing more.
* `KneeLattice.knee_inf` / `KneeLattice.knee_sup` : the pointwise minimum of two curves
  has knee `max k₁ k₂`, the pointwise maximum has knee `min k₁ k₂`.  So the knee is an
  order-reversing lattice homomorphism `(curves, ⊓, ⊔) → (ℕ, max, min)`.
* `KneeLattice.knee_worstCase` : the capstone.  For a finite ensemble of seeds the
  pointwise-infimum curve — the worst case over seeds — has knee exactly
  `KneeEnsemble.certifiedBudget K = max_i k*_i`.  The budget a sweep certifies is not an
  ad hoc maximum: it *is* the knee of the worst-case curve.  Dually
  `KneeLattice.knee_bestCase` shows the best-case curve realises `min_i k*_i`.
* `KneeLattice.net44_worst_and_best` : at `(d = 4, ctx = 1024)` the worst-case knee is
  `128` (the product law, a proven-safe budget) and the best-case knee is `96`; the gap
  is one grid step and the deployment cost of insisting on the worst case is the factor
  `4/3` computed in `KneeEnsemble.net44_waste_ratio`.
-/

import Mathlib
import Logic.KneeFluctuationTwoSeed
import Logic.KneeSeedEnsembleBracket

namespace KneeLattice

open Finset KneeFluctuation KneeEnsemble

section Abstract

variable {G : Finset ℕ} {bar : ℝ}

/-! ## 1.  A sweep is an up-set of the grid -/

/-- The set of grid budgets clearing the bar. -/
noncomputable def passingSet (G : Finset ℕ) (bar : ℝ) (c : ℕ → ℝ) : Finset ℕ :=
  G.filter (fun x => bar ≤ c x)

/-- For a monotone retained curve the passing set is an up-set of the grid. -/
theorem passingSet_isUpSet {c : ℕ → ℝ} (hc : Monotone c) {j j' : ℕ}
    (hj : j ∈ passingSet G bar c) (hjj : j ≤ j') (hj' : j' ∈ G) :
    j' ∈ passingSet G bar c := by
  classical
  rw [passingSet, Finset.mem_filter] at hj ⊢
  exact ⟨hj', hj.2.trans (hc hjj)⟩

/-- The knee is precisely the minimum of the passing set. -/
theorem isKnee_iff_min' {c : ℕ → ℝ} {k : ℕ} :
    IsKnee G bar c k ↔ ∃ h : (passingSet G bar c).Nonempty, (passingSet G bar c).min' h = k := by
  classical
  constructor
  · intro hk
    have hne : (passingSet G bar c).Nonempty :=
      ⟨k, by rw [passingSet, Finset.mem_filter]; exact ⟨hk.1, hk.2.1⟩⟩
    refine ⟨hne, le_antisymm ?_ ?_⟩
    · exact Finset.min'_le _ _ (by rw [passingSet, Finset.mem_filter]; exact ⟨hk.1, hk.2.1⟩)
    · obtain ⟨hm, hp⟩ := Finset.mem_filter.mp (Finset.min'_mem _ hne)
      exact hk.le_of_passes hm hp
  · rintro ⟨hne, rfl⟩
    obtain ⟨hm, hp⟩ := Finset.mem_filter.mp (Finset.min'_mem _ hne)
    refine ⟨hm, hp, fun j hj hpass => Finset.min'_le _ _ ?_⟩
    rw [passingSet, Finset.mem_filter]
    exact ⟨hj, hpass⟩

/-! ## 2.  Knee of a meet and of a join -/

/-- **Meet.**  The pointwise minimum of two monotone curves — the worst case of two
seeds — has knee `max k₁ k₂`. -/
theorem knee_inf {c₁ c₂ : ℕ → ℝ} {k₁ k₂ : ℕ} (h₁ : Monotone c₁) (h₂ : Monotone c₂)
    (hk₁ : IsKnee G bar c₁ k₁) (hk₂ : IsKnee G bar c₂ k₂) :
    IsKnee G bar (fun x => min (c₁ x) (c₂ x)) (max k₁ k₂) := by
  have hmem : max k₁ k₂ ∈ G := by
    rcases max_cases k₁ k₂ with ⟨he, _⟩ | ⟨he, _⟩ <;> rw [he]
    exacts [hk₁.1, hk₂.1]
  refine ⟨hmem, ?_, ?_⟩
  · exact le_min (hk₁.2.1.trans (h₁ (le_max_left _ _))) (hk₂.2.1.trans (h₂ (le_max_right _ _)))
  · intro j hj hpass
    have p₁ : bar ≤ c₁ j := le_trans hpass (min_le_left _ _)
    have p₂ : bar ≤ c₂ j := le_trans hpass (min_le_right _ _)
    exact max_le (hk₁.le_of_passes hj p₁) (hk₂.le_of_passes hj p₂)

/-- **Join.**  The pointwise maximum — the best case of two seeds — has knee
`min k₁ k₂`. -/
theorem knee_sup {c₁ c₂ : ℕ → ℝ} {k₁ k₂ : ℕ}
    (hk₁ : IsKnee G bar c₁ k₁) (hk₂ : IsKnee G bar c₂ k₂) :
    IsKnee G bar (fun x => max (c₁ x) (c₂ x)) (min k₁ k₂) := by
  have hmem : min k₁ k₂ ∈ G := by
    rcases min_cases k₁ k₂ with ⟨he, _⟩ | ⟨he, _⟩ <;> rw [he]
    exacts [hk₁.1, hk₂.1]
  refine ⟨hmem, ?_, ?_⟩
  · rcases min_cases k₁ k₂ with ⟨he, _⟩ | ⟨he, _⟩ <;> rw [he]
    exacts [le_max_of_le_left hk₁.2.1, le_max_of_le_right hk₂.2.1]
  · intro j hj hpass
    simp only at hpass
    rcases le_total (c₂ j) (c₁ j) with hle | hle
    · have hp : bar ≤ c₁ j := by rwa [max_eq_left hle] at hpass
      exact le_trans (min_le_left _ _) (hk₁.le_of_passes hj hp)
    · have hp : bar ≤ c₂ j := by rwa [max_eq_right hle] at hpass
      exact le_trans (min_le_right _ _) (hk₂.le_of_passes hj hp)

/-! ## 3.  Ensembles: the certified budget is the knee of the worst-case curve -/

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-- **Capstone.**  The pointwise infimum over a finite ensemble of seeds — the worst-case
retained curve — has knee exactly `certifiedBudget K = max_i k*_i`.  The budget certified
by a sweep is the knee of an actual curve, not merely a bookkeeping maximum. -/
theorem knee_worstCase {c : ι → ℕ → ℝ} {K : ι → ℕ} (hmono : ∀ i, Monotone (c i))
    (hknee : ∀ i, IsKnee G bar (c i) (K i)) :
    IsKnee G bar (fun x => Finset.univ.inf' Finset.univ_nonempty (fun i => c i x))
      (certifiedBudget K) := by
  obtain ⟨i₀, hi₀⟩ := certifiedBudget_mem_range K
  refine ⟨hi₀ ▸ (hknee i₀).1, ?_, ?_⟩
  · refine Finset.le_inf' _ _ (fun i _ => ?_)
    exact (hknee i).2.1.trans (hmono i (le_certifiedBudget K i))
  · intro j hj hpass
    have hall : ∀ i, bar ≤ c i j := fun i =>
      hpass.trans (Finset.inf'_le _ (Finset.mem_univ i))
    rw [hi₀]
    exact (hknee i₀).le_of_passes hj (hall i₀)

/-- Dually, the pointwise supremum — the best case over seeds — realises the smallest
measured knee. -/
theorem knee_bestCase {c : ι → ℕ → ℝ} {K : ι → ℕ} {m : ι}
    (hknee : ∀ i, IsKnee G bar (c i) (K i)) (hm : ∀ i, K m ≤ K i) :
    IsKnee G bar (fun x => Finset.univ.sup' Finset.univ_nonempty (fun i => c i x)) (K m) := by
  refine ⟨(hknee m).1, ?_, ?_⟩
  · exact le_trans (hknee m).2.1
      (Finset.le_sup' (fun i => c i (K m)) (Finset.mem_univ m))
  · intro j hj hpass
    simp only at hpass
    obtain ⟨i, -, hi⟩ := Finset.exists_mem_eq_sup' (Finset.univ_nonempty (α := ι))
      (fun i => c i j)
    have hp : bar ≤ c i j := by rw [hi] at hpass; exact hpass
    exact le_trans (hm i) ((hknee i).le_of_passes hj hp)

end Abstract

/-! ## 4.  The NET-44 cell -/

/-- The seed-2 knee read on the *seed-1* grid (which omits the pinning point `112`) is
still `96`, so the two sweeps can be compared on a common grid. -/
theorem net44_seed2_knee_gridS1 {c : ℕ → ℝ} (h : Seed2Data c) : IsKnee gridS1 bar c 96 := by
  obtain ⟨hm, h64, h96, h112, h128⟩ := h
  have h32 : c 32 ≤ 0.979 := h64 ▸ hm (by norm_num : (32 : ℕ) ≤ 64)
  refine ⟨by decide, by rw [h96]; norm_num [bar], ?_⟩
  intro j hj hpass
  fin_cases hj <;> simp_all [bar] <;> linarith

/-- At `(d = 4, ctx = 1024)` the worst-case two-seed curve `min (c₁, c₂)` has knee `128`
— the product law, certified safe — while the best-case curve `max (c₁, c₂)` has knee
`96`.  Both are read off the same pair of sweeps on the common grid; the gap is exactly
one grid step. -/
theorem net44_worst_and_best {c₁ c₂ : ℕ → ℝ} (h₁ : Seed1Data c₁) (h₂ : Seed2Data c₂) :
    IsKnee gridS1 bar (fun x => min (c₁ x) (c₂ x)) 128 ∧
      IsKnee gridS1 bar (fun x => max (c₁ x) (c₂ x)) 96 := by
  have hk₁ : IsKnee gridS1 bar c₁ 128 := net44_seed1_knee h₁
  have hk₂ : IsKnee gridS1 bar c₂ 96 := net44_seed2_knee_gridS1 h₂
  refine ⟨?_, ?_⟩
  · simpa using knee_inf h₁.mono h₂.mono hk₁ hk₂
  · simpa using knee_sup hk₁ hk₂

end KneeLattice