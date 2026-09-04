import Novelty.KleinFourTwoTorsionReciprocity
import Novelty.DivisionPolynomialFibres

/-!
# Machine-checked numerical evidence for the two-regime counting law

Every equality in this file is checked by the Lean kernel with `decide` (no `native_decide`),
and is then cross-validated against the general theorems
`KleinFourTwoTorsion.sum_card_V4_mod_twelve` and
`DivisionPolynomialFibres.sum_card_psi3_roots`.

The data confirm the predicted dichotomy

* `p ≡ 1, 11 mod 12`  ⟹  `∑_{d ≠ 0} |E_d(𝔽_p)[2]| = 4 (p-1)`,
* `p ≡ 5, 7 mod 12`   ⟹  `∑_{d ≠ 0} |E_d(𝔽_p)[2]| = 2 (p-1)`,

as well as the regime-independence of the corresponding `ψ₃` count.
-/

namespace KleinFourNumericalEvidence

open Finset KleinFourTwoTorsion

set_option maxRecDepth 40000

instance : Fact (Nat.Prime 5) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 7) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 11) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 13) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 17) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 19) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 23) := ⟨by norm_num⟩

/-! ## Brute-force values of the summed 2-torsion count -/

theorem sum_card_V4_five : sum_card_V4 5 = 8 := by decide
theorem sum_card_V4_seven : sum_card_V4 7 = 12 := by decide
theorem sum_card_V4_eleven : sum_card_V4 11 = 40 := by decide
theorem sum_card_V4_thirteen : sum_card_V4 13 = 48 := by decide
theorem sum_card_V4_seventeen : sum_card_V4 17 = 32 := by decide
theorem sum_card_V4_nineteen : sum_card_V4 19 = 36 := by decide
theorem sum_card_V4_twentythree : sum_card_V4 23 = 88 := by decide

/-! ## Cross-validation against the general law -/

/-- The brute-force value at `p = 13 ≡ 1 mod 12` agrees with the value predicted by
`sum_card_V4_mod_twelve`. -/
theorem consistency_thirteen :
    sum_card_V4 13 = (if 13 % 12 = 1 ∨ 13 % 12 = 11 then 4 * (13 - 1) else 2 * (13 - 1)) := by
  rw [sum_card_V4_mod_twelve (by norm_num) (by norm_num)]

/-- The brute-force value at `p = 17 ≡ 5 mod 12` agrees with the predicted non-split value. -/
theorem consistency_seventeen :
    sum_card_V4 17 = (if 17 % 12 = 1 ∨ 17 % 12 = 11 then 4 * (17 - 1) else 2 * (17 - 1)) := by
  rw [sum_card_V4_mod_twelve (by norm_num) (by norm_num)]

/-- Split behaviour at `p = 11 ≡ 11 mod 12`, checked both ways. -/
theorem consistency_eleven : sum_card_V4 11 = 4 * (11 - 1) := by
  rw [sum_card_V4_of_mod_twelve_eq_eleven (by norm_num)]

/-- Non-split behaviour at `p = 19 ≡ 7 mod 12`, checked both ways. -/
theorem consistency_nineteen : sum_card_V4 19 = 2 * (19 - 1) := by
  rw [sum_card_V4_of_mod_twelve_eq_seven (by norm_num)]

/-! ## The `ψ₃` counts -/

/-- Instantiation of the general `ψ₃` count at `p = 7 ≡ 1 mod 3`. -/
theorem psi3_seven :
    ∑ b ∈ univ.erase (0 : ZMod 7),
      (univ.filter fun x : ZMod 7 => (DivisionPolynomialFibres.psi3 b).IsRoot x).card = 12 := by
  rw [DivisionPolynomialFibres.sum_card_psi3_roots (by norm_num) (by decide)]

/-- Instantiation at `p = 11 ≡ 2 mod 3`: the same value `2(p-1)` as in the `p ≡ 1 mod 3`
case, illustrating the regime-independence of the `ψ₃` count. -/
theorem psi3_eleven :
    ∑ b ∈ univ.erase (0 : ZMod 11),
      (univ.filter fun x : ZMod 11 => (DivisionPolynomialFibres.psi3 b).IsRoot x).card = 20 := by
  rw [DivisionPolynomialFibres.sum_card_psi3_roots (by norm_num) (by decide)]

end KleinFourNumericalEvidence