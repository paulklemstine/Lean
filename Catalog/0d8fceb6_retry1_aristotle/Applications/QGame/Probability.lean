/-
# QGame probability range certification

This module proves that the `q`-game probability sequence `P q n` defined in
`Applications.QGame.Recurrence` is a genuine probability: it is nonnegative,
strictly positive for `n > 0`, and bounded above by `1` when `1 ≤ q`. In
particular it lands in the unit interval.
-/
import Applications.QGame.Recurrence

namespace QGame

open Finset

/-- Every member of `Finset.range ((n+1) - q)` is `< n`, provided `1 ≤ q`. -/
theorem mem_range_lt (q n : ℕ) (hq : 1 ≤ q) {j : ℕ}
    (hj : j ∈ Finset.range ((n + 1) - q)) : j < n := by
  simp only [Finset.mem_range] at hj
  omega

/-- The sequence is nonnegative. -/
theorem P_nonneg (q n : ℕ) : 0 ≤ P q n := by
  -- We proceed by induction on $n$.
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | n ) <;> simp_all +decide [ P_succ ];
  exact div_nonneg ( add_nonneg zero_le_one ( Finset.sum_nonneg fun _ _ => ih _ ( Nat.le_of_lt_succ ( by linarith [ Finset.mem_range.mp ‹_›, Nat.sub_le ( n + 1 ) q ] ) ) ) ) ( by positivity )

/-- The sequence is strictly positive for positive indices. -/
theorem P_pos (q n : ℕ) (hn : 0 < n) : 0 < P q n := by
  induction' hn with n hn ih;
  · rcases q with ( _ | _ | q ) <;> norm_num [ Finset.sum_range_succ, P_succ ];
  · exact P_succ q n ▸ div_pos ( add_pos_of_pos_of_nonneg zero_lt_one ( Finset.sum_nonneg fun _ _ => P_nonneg _ _ ) ) ( Nat.cast_add_one_pos _ )

/-- The sequence is bounded above by `1` when `1 ≤ q`. -/
theorem P_le_one (q n : ℕ) (hq : 1 ≤ q) : P q n ≤ 1 := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ P_succ ];
  exact div_le_one_of_le₀ ( by linarith [ show ( ∑ j ∈ Finset.range ( n + 1 + 1 - q ), P q j ) ≤ n + 1 by exact le_trans ( Finset.sum_le_sum fun _ _ => ih _ <| by linarith [ Finset.mem_range.mp ‹_›, Nat.sub_le ( n + 1 + 1 ) q ] ) <| mod_cast by norm_num; omega ] ) <| by positivity;

/-- The sequence lands in the unit interval when `1 ≤ q`. -/
theorem P_mem_unitInterval (q n : ℕ) (hq : 1 ≤ q) : P q n ∈ Set.Icc (0 : ℚ) 1 :=
  ⟨P_nonneg q n, P_le_one q n hq⟩

end QGame