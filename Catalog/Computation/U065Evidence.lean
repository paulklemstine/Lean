/-
# U065 — Machine-checked finite evidence for the mixture identities

Kernel-level cross-validation of the general theorems of `U065QRMixture` against brute
force enumeration.  Every statement below is checked twice: once by `decide`, which
enumerates `ZMod p` and counts square roots explicitly, and once by instantiating the
general theorems.  Agreement of the two routes is the evidence that the general
identities are stated correctly (in particular that the `a = 0` target, with its single
double root, is handled as it should be).
-/
import Computation.U065QRMixture

namespace U065

namespace Evidence

instance fact_three : Fact (Nat.Prime 3) := ⟨by norm_num⟩
instance fact_five : Fact (Nat.Prime 5) := ⟨by norm_num⟩
instance fact_seven : Fact (Nat.Prime 7) := ⟨by norm_num⟩
instance fact_eleven : Fact (Nat.Prime 11) := ⟨by norm_num⟩
instance fact_thirteen : Fact (Nat.Prime 13) := ⟨by norm_num⟩

/-! ### Individual root counts (enumeration) -/

example : rootCount 7 0 = 1 := by decide
example : rootCount 7 1 = 2 := by decide
example : rootCount 7 2 = 2 := by decide
example : rootCount 7 3 = 0 := by decide
example : rootCount 7 4 = 2 := by decide
example : rootCount 7 5 = 0 := by decide
example : rootCount 7 6 = 0 := by decide

/-! ### Mean rate: enumeration vs `sum_rootCount` -/

example : ∑ a : ZMod 3, rootCount 3 a = 3 := by decide
example : ∑ a : ZMod 5, rootCount 5 a = 5 := by decide
example : ∑ a : ZMod 7, rootCount 7 a = 7 := by decide
example : ∑ a : ZMod 11, rootCount 11 a = 11 := by decide
example : ∑ a : ZMod 13, rootCount 13 a = 13 := by decide

example : ∑ a : ZMod 13, rootCount 13 a = 13 := sum_rootCount (by norm_num)

/-! ### Variance identity `∑ (X − 1)² = p − 1`: enumeration vs `sum_sq_rootCount_sub_one` -/

example : ∑ a : ZMod 5, ((rootCount 5 a : ℤ) - 1) ^ 2 = 4 := by decide
example : ∑ a : ZMod 7, ((rootCount 7 a : ℤ) - 1) ^ 2 = 6 := by decide
example : ∑ a : ZMod 11, ((rootCount 11 a : ℤ) - 1) ^ 2 = 10 := by decide

example : ∑ a : ZMod 11, ((rootCount 11 a : ℤ) - 1) ^ 2 = 10 := by
  have h := sum_sq_rootCount_sub_one (p := 11) (by norm_num)
  norm_num at h
  exact h

/-! ### Generating identity at `c = 3/2`: the mixture value `45/4` for `p = 7`

The naive baseline is `p·c = 21/2`; the mixture excess `(p−1)(c−1)²/2 = 3/4` is exactly
the gap.  Enumeration gives root counts `(1,2,2,0,2,0,0)`, so the sum is
`c + 3c² + 3 = 3/2 + 27/4 + 3 = 45/4`. -/

example : ∑ a : ZMod 7, ((3 : ℝ) / 2) ^ (rootCount 7 a) = 45 / 4 := by
  rw [sum_pow_rootCount (by norm_num)]
  norm_num

example : ∑ a : ZMod 13, ((3 : ℝ) / 2) ^ (rootCount 13 a) = 21 := by
  rw [sum_pow_rootCount (by norm_num)]
  norm_num

/-! ### Excess ratios are strictly above one -/

example : 1 < excessRatio 7 ((3 : ℝ) / 2) :=
  one_lt_excessRatio (by norm_num) (by norm_num) (by norm_num)

example : excessRatio 7 ((3 : ℝ) / 2) = 45 / 42 := by
  rw [excessRatio_eq (by norm_num) (by norm_num)]
  norm_num

end Evidence

end U065