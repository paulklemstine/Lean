import Mathlib
import Speculative.RiemannHypothesis.Defs

/-!
# Prime Counting Function: Unconditional Results

We prove basic but formally nontrivial properties of the prime counting function
`primeCount N = |{p ≤ N : p prime}|`. These serve as anchoring estimates
for any future RH-conditional error bound infrastructure.

## Main Results

- `primeCount_zero` : `π(0) = 0`
- `primeCount_one` : `π(1) = 0`
- `primeCount_two` : `π(2) = 1`
- `primeCount_mono` : `primeCount` is monotone
- `primeCount_le` : `π(N) ≤ N` for all `N`
- `primeCount_pos` : `π(N) > 0` for `N ≥ 2`
-/

namespace RH

/-! ## Basic Values -/

@[simp]
theorem primeCount_zero : primeCount 0 = 0 := by
  native_decide +revert

@[simp]
theorem primeCount_one : primeCount 1 = 0 := by
  rfl

theorem primeCount_two : primeCount 2 = 1 := by
  rfl

/-! ## Monotonicity -/

/-
The prime counting function is monotone: if `m ≤ n` then `π(m) ≤ π(n)`.
-/
theorem primeCount_mono : Monotone primeCount := by
  exact fun n m hnm => Finset.card_mono <| Finset.filter_subset_filter _ <| Finset.range_mono <| Nat.succ_le_succ hnm

/-! ## Upper Bounds -/

/-
Trivial upper bound: `π(N) ≤ N` for all `N`.
-/
theorem primeCount_le (N : ℕ) : primeCount N ≤ N := by
  exact le_trans ( Finset.card_le_card <| show Finset.filter Nat.Prime ( Finset.range ( N + 1 ) ) ⊆ Finset.Icc 1 N from fun p hp => Finset.mem_Icc.mpr ⟨ Nat.pos_of_ne_zero fun h => by aesop, Nat.le_of_lt_succ ( Finset.mem_range.mp <| Finset.mem_filter.mp hp |>.1 ) ⟩ ) ( by simp +arith +decide )

/-! ## Lower Bounds -/

/-
For `N ≥ 2`, there is at least one prime (namely 2).
-/
theorem primeCount_pos (N : ℕ) (hN : 2 ≤ N) : 0 < primeCount N := by
  exact Finset.card_pos.mpr ⟨ 2, Finset.mem_filter.mpr ⟨ Finset.mem_range.mpr ( by linarith ), by norm_num ⟩ ⟩

end RH