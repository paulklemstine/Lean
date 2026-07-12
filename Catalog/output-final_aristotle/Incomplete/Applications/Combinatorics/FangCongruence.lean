import Applications.FangMultiset

/-!
# Congruence Consequences of the Digit-Multiset Framework

This file derives the classical mod-`9` and mod-`3` congruences of vampire fang
pairs as **downstream consequences** of the purely combinatorial additivity
results in `Novelty.FangMultiset`.

## The (deliberate) logical order

To keep the development free of circular reasoning, the dependency is strictly
one-directional:

1. `Novelty.FangMultiset` establishes, using only multiset arithmetic, that the
   digit sum is additive across a fang pair
   (`FangMultiset.IsFangPair.digitsum_add`).  *No congruence appears there.*

2. Here we combine that additivity with the standard **casting out nines**
   property of the digit representation — `n ≡ digitsum n [MOD 9]` and its
   mod-`3` shadow, which are exactly `Nat.modEq_nine_digits_sum` and
   `Nat.modEq_three_digits_sum` (the same catalog-verified lemmas used in
   `Novelty.VampireNumbers` and the `NumericalMonsters` files) — to obtain the
   value congruences.

Thus the congruences are *consequences* of the digit-multiset framework, never a
hypothesis for it.

## Main results

* `FangMultiset.digitsum_modEq_nine` / `digitsum_modEq_three` — casting out
  nines / threes, phrased for `digitsum`.
* `FangMultiset.IsFangPair.modEq_nine`: `v ≡ x + y [MOD 9]`.
* `FangMultiset.IsFangPair.modEq_three`: `v ≡ x + y [MOD 3]`.
* `FangMultiset.IsFangPair.fang_not_one_mod_three`: neither fang is `≡ 1 (mod 3)`.
-/

namespace FangMultiset

/-- **Casting out nines.**  Every natural number is congruent, modulo `9`, to its
base-`10` digit sum.  This is the standard property of the digit representation
(`Nat.modEq_nine_digits_sum`), restated for `digitsum`. -/
theorem digitsum_modEq_nine (n : ℕ) : n ≡ digitsum n [MOD 9] :=
  Nat.modEq_nine_digits_sum n

/-- **Casting out threes.**  Every natural number is congruent, modulo `3`, to its
base-`10` digit sum (`Nat.modEq_three_digits_sum`), restated for `digitsum`. -/
theorem digitsum_modEq_three (n : ℕ) : n ≡ digitsum n [MOD 3] :=
  Nat.modEq_three_digits_sum n

/-- **The vampire law modulo 9.**  Any fang pair satisfies `v ≡ x + y [MOD 9]`.
The proof combines the digit-sum additivity `digitsum x + digitsum y = digitsum v`
(proved combinatorially, without congruences, in `Novelty.FangMultiset`) with
casting out nines. -/
theorem IsFangPair.modEq_nine {v x y : ℕ} (h : IsFangPair v x y) :
    v ≡ x + y [MOD 9] := by
  have hadd : digitsum x + digitsum y = digitsum v := h.digitsum_add
  calc v ≡ digitsum v [MOD 9] := digitsum_modEq_nine v
    _ = digitsum x + digitsum y := hadd.symm
    _ ≡ x + y [MOD 9] := ((digitsum_modEq_nine x).add (digitsum_modEq_nine y)).symm

/-- **The vampire law modulo 3.**  Any fang pair satisfies `v ≡ x + y [MOD 3]`.
Same argument as `IsFangPair.modEq_nine`, using casting out threes. -/
theorem IsFangPair.modEq_three {v x y : ℕ} (h : IsFangPair v x y) :
    v ≡ x + y [MOD 3] := by
  have hadd : digitsum x + digitsum y = digitsum v := h.digitsum_add
  calc v ≡ digitsum v [MOD 3] := digitsum_modEq_three v
    _ = digitsum x + digitsum y := hadd.symm
    _ ≡ x + y [MOD 3] := ((digitsum_modEq_three x).add (digitsum_modEq_three y)).symm

/-- **Fang obstruction modulo 3.**  For a fang pair, neither fang is congruent to
`1` modulo `3`.  (Since `v = x * y`, the congruence `x * y ≡ x + y [MOD 3]` would
force `y ≡ 1` or `x ≡ 1` into a contradiction.)  Checked on `1260 = 21 · 60`:
`21 ≡ 0`, `60 ≡ 0` (mod 3). -/
theorem IsFangPair.fang_not_one_mod_three {v x y : ℕ} (h : IsFangPair v x y) :
    x % 3 ≠ 1 ∧ y % 3 ≠ 1 := by
  have hv : v = x * y := h.2.symm
  have hc : x * y ≡ x + y [MOD 3] := by rw [← hv]; exact h.modEq_three
  constructor
  · intro hx1
    have hxmod : x ≡ 1 [MOD 3] := by unfold Nat.ModEq; simpa using hx1
    have e1 : x * y ≡ 1 * y [MOD 3] := hxmod.mul_right y
    have e2 : x + y ≡ 1 + y [MOD 3] := hxmod.add_right y
    have hchain : (1 * y) ≡ (1 + y) [MOD 3] := (e1.symm.trans hc).trans e2
    have hy : (1 * y) % 3 = (1 + y) % 3 := hchain
    omega
  · intro hy1
    have hymod : y ≡ 1 [MOD 3] := by unfold Nat.ModEq; simpa using hy1
    have e1 : x * y ≡ x * 1 [MOD 3] := hymod.mul_left x
    have e2 : x + y ≡ x + 1 [MOD 3] := hymod.add_left x
    have hchain : (x * 1) ≡ (x + 1) [MOD 3] := (e1.symm.trans hc).trans e2
    have hx : (x * 1) % 3 = (x + 1) % 3 := hchain
    omega

/-! ### Non-vacuity: `1260 = 21 · 60`. -/

private theorem fangPair_1260 : IsFangPair 1260 21 60 := by
  refine ⟨?_, by norm_num⟩
  unfold multiset_of_digits
  decide

/-- `1260 ≡ 21 + 60 [MOD 9]`, i.e. `0 ≡ 0`. -/
example : (1260 : ℕ) ≡ 21 + 60 [MOD 9] := fangPair_1260.modEq_nine

/-- Consistency with the taboo: `21 % 3 ≠ 1` and `60 % 3 ≠ 1`. -/
example : (21 : ℕ) % 3 ≠ 1 ∧ (60 : ℕ) % 3 ≠ 1 := fangPair_1260.fang_not_one_mod_three

end FangMultiset