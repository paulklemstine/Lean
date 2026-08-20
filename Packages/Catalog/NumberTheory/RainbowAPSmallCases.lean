import Mathlib
import Catalog.Shared.RainbowAPPairThreshold
import Catalog.Shared.RainbowAPMonotone

/-!
# Verified small cases of the rainbow pair-spectrum threshold

Combining the two majority criteria with the monotonicity of the transition
(`RainbowAP.majority_iff_threshold_le`) pins `T k` inside an explicit integer window for each
small `k`.  These windows are computed here by pure numeral arithmetic; they agree with the exact
values `T 2 = 7`, `T 3 = 23`, `T 4 = 51` obtained by inclusion–exclusion outside Lean
(see `ComputationalEvidence.md`).
-/

namespace RainbowAP

/-- Numerical form of the union-bound criterion for the pair alphabet. -/
lemma T_le_of {k m : ℕ}
    (h : 2 * k ^ 2 * (k ^ 2 - 1) ^ m < (k ^ 2) ^ m) : T k ≤ m := by
  rw [T]
  refine spectrumThreshold_le_of_mem (majority_surjective_of m ?_)
  rw [card_pair_alphabet]
  exact h

/-- Numerical form of the second-moment criterion for the pair alphabet. -/
lemma lt_T_of {k m : ℕ} (hk : 2 ≤ k)
    (h : (k ^ 2) ^ m < (k ^ 2 + 1) * (k ^ 2 - 1) ^ m) : m < T k := by
  have hge := card_pair_alphabet_ge k hk
  have hcard := card_pair_alphabet k
  have hne := spectrum_set_nonempty (α := Fin k × Fin k) hge
  have hcrit : Fintype.card (Fin k × Fin k) ^ m < 2 * nonSurjCount (Fin k × Fin k) m := by
    refine majority_nonSurjective_of m hge ?_
    rw [hcard]
    exact h
  by_contra hcon
  push_neg at hcon
  rw [T] at hcon
  have hmaj := (majority_iff_threshold_le hge hne m).2 hcon
  omega

/-- `T 2 ∈ [6, 8]`: with two colours the pair spectrum fills up between 6 and 8 blocks. -/
theorem T_two_window : 6 ≤ T 2 ∧ T 2 ≤ 8 := by
  constructor
  · have := lt_T_of (k := 2) (m := 5) (by norm_num) (by norm_num)
    omega
  · exact T_le_of (k := 2) (m := 8) (by norm_num)

/-- `T 3 ∈ [20, 25]`. -/
theorem T_three_window : 20 ≤ T 3 ∧ T 3 ≤ 25 := by
  constructor
  · have := lt_T_of (k := 3) (m := 19) (by norm_num) (by norm_num)
    omega
  · exact T_le_of (k := 3) (m := 25) (by norm_num)

/-- `T 4 ∈ [44, 54]`. -/
theorem T_four_window : 44 ≤ T 4 ∧ T 4 ≤ 54 := by
  constructor
  · have := lt_T_of (k := 4) (m := 43) (by norm_num) (by norm_num)
    omega
  · exact T_le_of (k := 4) (m := 54) (by norm_num)

end RainbowAP