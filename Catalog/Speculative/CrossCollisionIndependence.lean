/-! # CatalogBuild.Speculative.CrossCollisionIndependence

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 11
-/

import Mathlib

/-- [Section: # CatalogBuild.Speculative.CrossCollisionIndependence
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 11] -/
theorem cross_channels (k : ℕ) : k * k = k ^ 2 := by ring




/-- [Section: # CatalogBuild.Speculative.CrossCollisionIndependence
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 11] -/
theorem within_channels (k : ℕ) : Nat.choose k 2 = k * (k - 1) / 2 :=
  Nat.choose_two_right k




theorem total_channels_formula (k : ℕ) (hk : 2 ≤ k) :
    k ^ 2 + 2 * Nat.choose k 2 = 2 * k ^ 2 - k := by
  exact eq_tsub_of_add_eq ( by induction hk <;> norm_num [ Nat.choose ] at * ; linarith )




theorem channels_k4_total : 4 ^ 2 + 2 * Nat.choose 4 2 = 28 := by decide



theorem channels_k8_total : 8 ^ 2 + 2 * Nat.choose 8 2 = 120 := by decide




theorem channel_lower_bound (k : ℕ) :
    k ^ 2 ≤ k ^ 2 + 2 * Nat.choose k 2 := Nat.le_add_right _ _




theorem channel_upper_bound (k : ℕ) :
    k ^ 2 + 2 * Nat.choose k 2 ≤ 2 * k ^ 2 := by
  induction k <;> simp +arith +decide [ Nat.choose ] at * ; linarith




theorem birthday_tuples_needed (N k : ℕ) (hk : 0 < k) :
    Nat.sqrt (N / k ^ 2) ≤ Nat.sqrt N / k := by
  rw [ Nat.le_div_iff_mul_le hk ];
  exact Nat.le_sqrt.2 ( by nlinarith [ Nat.sqrt_le ( N / k ^ 2 ), Nat.div_mul_le_self N ( k ^ 2 ) ] )




theorem marginal_channels (k : ℕ) (hk : 2 ≤ k) :
    (k + 1) ^ 2 + 2 * Nat.choose (k + 1) 2 -
    (k ^ 2 + 2 * Nat.choose k 2) = 4 * k + 1 := by
  exact Nat.sub_eq_of_eq_add <| by induction hk <;> norm_num [ Nat.choose ] at * ; linarith;




theorem nontrivial_divisor_count (m : ℕ) (hm : 2 ≤ m) :
    2 ≤ 2 ^ m - 2 := by
  exact le_tsub_of_add_le_left ( by linarith [ Nat.pow_le_pow_right two_pos hm ] )




theorem channel_efficiency_bound (k : ℕ) (hk : 1 ≤ k) :
    1 ≤ k ^ 2 := by nlinarith


