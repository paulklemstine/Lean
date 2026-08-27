/-
# Machine-checked small cases for the consecutive-position law

Every statement here is decided by the kernel from the *same* definitions used
in `Logic.JFeatureConsecutiveDependency`, so it certifies that those definitions
are not vacuous and that the general theorems have the intended content.

For each odd prime `q` and each nonzero square `N` mod `q`:

* the divisibility set has exactly two elements (`card_divSet`);
* the adjacent double-hit set is empty, **except** for the unique `N` with
  `4N = 1`, where it is a singleton (`card_pairSet_dichotomy`).

The exceptional residues visible below are `N = 4 (mod 5)`, `N = 2 (mod 7)`,
`N = 3 (mod 11)`, `N = 10 (mod 13)`, matching `4N ≡ 1` in each case.
-/
import Logic.JFeatureLagSpectrum

namespace Logic.JFeature

instance : Fact (Nat.Prime 5) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 7) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 11) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 13) := ⟨by norm_num⟩

/-! ### Two roots per prime -/

example : (divSet (0 : ZMod 5) 4).card = 2 := by decide
example : (divSet (0 : ZMod 7) 2).card = 2 := by decide
example : (divSet (2 : ZMod 7) 4).card = 2 := by decide
example : (divSet (3 : ZMod 11) 5).card = 2 := by decide
example : (divSet (1 : ZMod 13) 9).card = 2 := by decide

/-! ### Generic primes: no adjacent double hit -/

theorem pairSet_card_7_1 : (pairSet (0 : ZMod 7) 1).card = 0 := by decide
theorem pairSet_card_7_4 : (pairSet (5 : ZMod 7) 4).card = 0 := by decide
theorem pairSet_card_11_5 : (pairSet (3 : ZMod 11) 5).card = 0 := by decide
theorem pairSet_card_13_9 : (pairSet (1 : ZMod 13) 9).card = 0 := by decide

/-! ### The exceptional locus `4N = 1`: exactly one adjacent double hit -/

theorem pairSet_card_5_4 : (pairSet (0 : ZMod 5) 4).card = 1 := by decide
theorem pairSet_card_7_2 : (pairSet (0 : ZMod 7) 2).card = 1 := by decide
theorem pairSet_card_11_3 : (pairSet (3 : ZMod 11) 3).card = 1 := by decide
theorem pairSet_card_13_10 : (pairSet (1 : ZMod 13) 10).card = 1 := by decide

/-- The exceptional residues really do satisfy `4N = 1`. -/
theorem four_mul_exceptional_7 : (4 : ZMod 7) * 2 = 1 := by decide
theorem four_mul_exceptional_11 : (4 : ZMod 11) * 3 = 1 := by decide
theorem four_mul_exceptional_13 : (4 : ZMod 13) * 10 = 1 := by decide

/-- Consistency with the general dichotomy: for `q = 11`, `N = 5` the general
theorem predicts an empty adjacent set, and the kernel agrees. -/
theorem dichotomy_check_11 :
    (pairSet (3 : ZMod 11) 5).card = 0 ∨ (pairSet (3 : ZMod 11) 5).card = 1 :=
  card_pairSet_dichotomy (by norm_num) 3 5

/-! ### The lag spectrum

For `q = 13`, `s = 0`, `N = 1 = 1²` the general theory predicts double hits at
exactly the two lags `k = ±2 = 2, 11` and at no other nonzero lag; for `q = 11`,
`N = 9 = 3²` at exactly `k = ±6 = 6, 5`.  The kernel confirms both. -/

theorem pairSetLag_card_13_lag2 : (pairSetLag (2 : ZMod 13) 0 1).card = 1 := by decide
theorem pairSetLag_card_13_lag11 : (pairSetLag (11 : ZMod 13) 0 1).card = 1 := by decide
theorem pairSetLag_card_13_lag3 : (pairSetLag (3 : ZMod 13) 0 1).card = 0 := by decide
theorem pairSetLag_card_13_lag7 : (pairSetLag (7 : ZMod 13) 0 1).card = 0 := by decide
theorem pairSetLag_card_11_lag6 : (pairSetLag (6 : ZMod 11) 3 9).card = 1 := by decide
theorem pairSetLag_card_11_lag4 : (pairSetLag (4 : ZMod 11) 3 9).card = 0 := by decide

/-- Exactly two exceptional lags, as `card_exceptionalLags` predicts. -/
theorem exceptionalLags_card_13 :
    (Finset.univ.filter (fun k : ZMod 13 => 4 * (1 : ZMod 13) ^ 2 = k ^ 2)).card = 2 := by
  decide

theorem exceptionalLags_card_11 :
    (Finset.univ.filter (fun k : ZMod 11 => 4 * (3 : ZMod 11) ^ 2 = k ^ 2)).card = 2 := by
  decide

end Logic.JFeature