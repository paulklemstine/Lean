/-! # CatalogBuild.Probability.ProbabilityExploration

Auto-generated from theorem catalog database.
Domain: Probability
Declarations: 7
-/

import Mathlib

theorem dice_complement_1 : 1 - (5 : ℚ) / 6 = 1 / 6 := by norm_num

theorem dice_complement_2 : 1 - (5 : ℚ) / 6 * (5 / 6) = 11 / 36 := by norm_num


/-- Birthday problem approximation -/
theorem birthday_approx : (23 : ℚ) * 22 / 2 > 182 := by norm_num


theorem fair_die_ev :
    (∑ i ∈ Finset.range 6, ((i : ℚ) + 1)) / 6 = 7 / 2 := by
  native_decide +revert


theorem linearity_expect (n : ℕ) (X Y : Fin n → ℚ) :
    ∑ i, (X i + Y i) = ∑ i, X i + ∑ i, Y i := by
  exact Finset.sum_add_distrib


theorem data_proc {α β : Type*} [DecidableEq β] [Fintype α]
    (f : α → β) (S : Finset α) :
    (S.image f).card ≤ S.card := by
  exact Finset.card_image_le


/-- Harmonic number values -/
theorem harmonic_vals :
    (1 : ℚ) = 1 ∧
    (1 : ℚ) + 1/2 = 3/2 ∧
    (1 : ℚ) + 1/2 + 1/3 = 11/6 := by
  constructor <;> [rfl; constructor <;> norm_num]

