import Cryptography.ResidueDial.Converse
import Cryptography.HintSumDifference.PrecisionLaw

/-!
# Refuting the mod-8 explanation of `D₄@8` sum-sufficiency (paper 105)

Paper 105 claims: "`(p+q) mod 8` determines `p mod 8` and `q mod 8` uniquely
(`q = N·p⁻¹ mod 8`)".  We read the pair through the catalog's `factorSwap`
(`ResidueDial/Converse.lean`): given the class `c = N mod 8`, the partner of the
factor class `u` is `factorSwap c u = c·u⁻¹`, and the observable is the *pair sum*
`u + c·u⁻¹ ∈ ZMod 8`.

Results:

* `pairSum_eq_mul` — because every unit of `ZMod 8` is an involution, the pair sum
  is `u·(1 + c)`, and `1 + c` is even: the sum loses a full bit.
* `pairSum_shift_invariant` / `paper105_ordered_claim_false` — `u ↦ 5u` (i.e.
  `u ↦ u + 4`) never changes the pair sum, so the ordered claim fails for every `N`.
* `pairSum_const_of_three_mod_four` — for `N ≡ 3 (mod 4)` the pair sum is a
  function of `N` alone: zero information.
* `unordered_determined_iff_five` — even the **unordered** pair of residues is
  determined by the pair sum iff `N ≡ 5 (mod 8)`: one class out of four.
* `paper105_prime_counterexample` — genuine primes: `17·41` and `5·13` have
  `N ≡ 1`, `p+q ≡ 2 (mod 8)`, but factor classes `{1,1}` versus `{5,5}` mod 8.
* `sign_sum_determines_pair` — the contrast paper 105 drew for `S₃` is backwards:
  for `±1`-valued symbols the sum *does* determine the unordered pair.

The positive replacement is `HintSD.d4_pair_determined_mod32`: sum and `N` modulo
`32` suffice, and `HintSD.d4_pair_not_determined_mod16` shows `16` does not.
-/

namespace HintSD

open ResidueDial

/-- The observable of a sum-hint at modulus `8`: factor class plus partner class. -/
def pairSum (c u : (ZMod 8)ˣ) : ZMod 8 := (u : ZMod 8) + ((factorSwap c u : (ZMod 8)ˣ) : ZMod 8)

/-- Every unit modulo `8` is its own inverse (the group is `C₂ × C₂`). -/
theorem units8_inv_eq_self (u : (ZMod 8)ˣ) : u⁻¹ = u := by
  revert u; decide

/-- Every unit modulo `8` is odd: `1 + c` is always even, i.e. `4·(1 + c) = 0`. -/
theorem four_mul_one_add_unit (c : (ZMod 8)ˣ) : (4 : ZMod 8) * (1 + (c : ZMod 8)) = 0 := by
  revert c; decide

/-- **The pair-sum formula.**  `u + c·u⁻¹ = u·(1 + c)` in `ZMod 8`. -/
theorem pairSum_eq_mul (c u : (ZMod 8)ˣ) : pairSum c u = (u : ZMod 8) * (1 + (c : ZMod 8)) := by
  unfold pairSum
  rw [factorSwap_apply, units8_inv_eq_self, Units.val_mul]
  ring

/-- The unit `5` of `ZMod 8`; multiplication by it is the shift `u ↦ u + 4`. -/
def five8 : (ZMod 8)ˣ := ⟨5, 5, by decide, by decide⟩

/-- **Shift invariance.**  Replacing the factor class `u` by `5u = u + 4` never changes
the pair sum. -/
theorem pairSum_shift_invariant (c u : (ZMod 8)ˣ) :
    pairSum c (five8 * u) = pairSum c u := by
  rw [pairSum_eq_mul, pairSum_eq_mul, Units.val_mul]
  have h5 : ((five8 : (ZMod 8)ˣ) : ZMod 8) = 1 + 4 := by decide
  rw [h5]
  have := four_mul_one_add_unit c
  linear_combination (u : ZMod 8) * this

/-- `5u ≠ u` for every unit `u` modulo `8`. -/
theorem five_mul_ne (u : (ZMod 8)ˣ) : five8 * u ≠ u := by
  revert u; decide

/-- **Paper 105's ordered claim is false for every `N`.**  For every class `c = N mod 8`
there are two different factor classes with the same pair sum. -/
theorem paper105_ordered_claim_false (c : (ZMod 8)ˣ) :
    ∃ u v : (ZMod 8)ˣ, u ≠ v ∧ pairSum c u = pairSum c v :=
  ⟨five8 * 1, 1, five_mul_ne 1, pairSum_shift_invariant c 1⟩

/-- **Zero information when `N ≡ 3 (mod 4)`.**  Then the pair sum is the same for all
factor classes: `4` if `N ≡ 3` and `0` if `N ≡ 7 (mod 8)`. -/
theorem pairSum_const_of_three_mod_four (c : (ZMod 8)ˣ)
    (hc : (c : ZMod 8) = 3 ∨ (c : ZMod 8) = 7) (u v : (ZMod 8)ˣ) :
    pairSum c u = pairSum c v := by
  rw [pairSum_eq_mul, pairSum_eq_mul]
  rcases hc with h | h <;> rw [h] <;> revert u v <;> decide

/-- Unordered determination: the pair sum pins the unordered pair `{u, c u⁻¹}`. -/
def UnorderedDetermined (c : (ZMod 8)ˣ) : Prop :=
  ∀ u v : (ZMod 8)ˣ, pairSum c u = pairSum c v → v = u ∨ v = factorSwap c u

instance (c : (ZMod 8)ˣ) : Decidable (UnorderedDetermined c) := by
  unfold UnorderedDetermined; infer_instance

/-- **Classification.**  The sum hint modulo `8` determines the unordered pair of factor
classes exactly when `N ≡ 5 (mod 8)`. -/
theorem unordered_determined_iff_five (c : (ZMod 8)ˣ) :
    UnorderedDetermined c ↔ (c : ZMod 8) = 5 := by
  revert c; decide

/-- Exactly one of the four classes of `N mod 8` is sum-sufficient at modulus `8`. -/
theorem card_sumSufficient_classes :
    (Finset.univ.filter (fun c : (ZMod 8)ˣ => UnorderedDetermined c)).card = 1 := by
  decide

/-- **Genuine prime counterexample.**  `N₁ = 17·41` and `N₂ = 5·13` agree in
`N mod 8` and `(p+q) mod 8`, yet the factor classes are `1, 1` versus `5, 5` mod 8 —
different `D₄@8` splitting behaviour (`p ≡ 1 mod 8` splits completely in `ℚ(ζ₈)`,
`p ≡ 5` does not). -/
theorem paper105_prime_counterexample :
    Nat.Prime 17 ∧ Nat.Prime 41 ∧ Nat.Prime 5 ∧ Nat.Prime 13 ∧
    17 * 41 ≡ 5 * 13 [MOD 8] ∧ 17 + 41 ≡ 5 + 13 [MOD 8] ∧
    ¬ 17 ≡ 5 [MOD 8] ∧ ¬ 17 ≡ 13 [MOD 8] ∧
    ¬ 17 * 41 ≡ 5 * 13 [MOD 32] := by
  refine ⟨by norm_num, by norm_num, by norm_num, by norm_num, by decide, by decide,
    by decide, by decide, by decide⟩

/-- **The symbol contrast, corrected.**  For `±1`-valued symbols (Legendre symbols of
the two factors) the *sum* determines the unordered pair of symbols. -/
theorem sign_sum_determines_pair {a b a' b' : ℤ}
    (ha : a = 1 ∨ a = -1) (hb : b = 1 ∨ b = -1)
    (ha' : a' = 1 ∨ a' = -1) (hb' : b' = 1 ∨ b' = -1) (h : a + b = a' + b') :
    (a = a' ∧ b = b') ∨ (a = b' ∧ b = a') := by
  rcases ha with rfl | rfl <;> rcases hb with rfl | rfl <;>
    rcases ha' with rfl | rfl <;> rcases hb' with rfl | rfl <;> omega

end HintSD