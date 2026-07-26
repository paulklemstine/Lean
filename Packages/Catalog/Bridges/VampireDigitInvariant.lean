import Mathlib

/-!
# Vampire digits meet modular arithmetic

This file isolates the combinatorial core of a vampire factorization: the decimal
multiset of the two fangs is a permutation of the decimal multiset of the product.
It proves that this digit permutation forces a congruence modulo nine, and then
combines it with multiplication to obtain a divisibility obstruction on the fang
residues.  Thus a base-ten recreational-number definition connects directly to
factorization in the finite ring `ZMod 9`.
-/

namespace VampireDigitInvariant

/-- The digit condition in a decimal vampire factorization.  Digits are stored
least-significant first, but `List.Perm` deliberately forgets their order while
retaining multiplicity. -/
def FangDigits (v x y : ℕ) : Prop :=
  (Nat.digits 10 x ++ Nat.digits 10 y).Perm (Nat.digits 10 v)

/-- A (minimal) vampire witness: multiplication together with the digit-multiset
condition.  Length and trailing-zero conventions can be added independently;
the bridge theorem only needs this common core. -/
def VampireWitness (v x y : ℕ) : Prop :=
  v = x * y ∧ FangDigits v x y

/-
Base-ten digit sums represent the original number modulo nine.
-/
theorem decimal_modEq_digit_sum (n : ℕ) :
    n ≡ (Nat.digits 10 n).sum [MOD 9] := by
  conv_lhs => rw [ ← Nat.ofDigits_digits 10 n ];
  norm_num [ Nat.ModEq, Nat.ofDigits_mod, Nat.ofDigits_one ]

/-
Permuting the concatenated fang digits preserves the modulo-nine class.
This is the combinatorial-to-arithmetic bridge at the heart of the result.
-/
theorem fangDigits_modEq (h : FangDigits v x y) :
    v ≡ x + y [MOD 9] := by
  -- From decimal_modEq_digit_sum, apply it to each fang, then combine these sums
  have h_sum : v % 9 = (Nat.digits 10 v).sum % 9 ∧ x % 9 = (Nat.digits 10 x).sum % 9 ∧ y % 9 = (Nat.digits 10 y).sum % 9 := by
    exact ⟨decimal_modEq_digit_sum v, decimal_modEq_digit_sum x, decimal_modEq_digit_sum y⟩

  have h_perm : (Nat.digits 10 v).sum = (Nat.digits 10 x).sum + (Nat.digits 10 y).sum := by
    rw [ ← List.sum_append, h.sum_eq ];
  exact Nat.ModEq.trans ( h_sum.1 ) ( by rw [ h_perm ] ; exact Nat.ModEq.add ( h_sum.2.1.symm ) ( h_sum.2.2.symm ) )

/-
**Vampire digit invariant.**  Any product whose two factor digit multisets
reassemble to the product's decimal digits satisfies
`9 ∣ x*y - x - y` (with integer subtraction).

Equivalently, `(x - 1)(y - 1) ≡ 1 (mod 9)`.  This connects a multiset-permutation
condition on decimal strings to a hyperbola in modular arithmetic.
-/
theorem vampire_fangs_integer_divisibility
    (hmul : v = x * y) (hdigits : FangDigits v x y) :
    (9 : ℤ) ∣ (x : ℤ) * y - x - y := by
  convert Int.dvd_neg.mpr
      (fangDigits_modEq hdigits |> Nat.modEq_iff_dvd.mp) using 1; ring_nf
  push_cast [hmul]
  ring

/-
Finite-ring formulation of the same bridge: vampire fangs lie on the affine
curve `(X - 1)(Y - 1) = 1` over `ZMod 9`.
-/
theorem vampire_fangs_zmod_curve
    (h : VampireWitness v x y) :
    ((x : ZMod 9) - 1) * ((y : ZMod 9) - 1) = 1 := by
  have h_mod : (v : ZMod 9) = (x + y : ZMod 9) := by
    have h_mod : v ≡ x + y [MOD 9] := by
      exact fangDigits_modEq h.2;
    simpa [ ← ZMod.natCast_eq_natCast_iff ] using h_mod;
  rw [h.1] at h_mod
  norm_cast at *
  simp_all +decide [sub_mul, mul_sub]

/-
Consequently, modulo nine the two fangs can occupy only six ordered
residue pairs.  This turns the geometric curve equation into an explicit
factorization sieve.
-/
theorem vampire_fangs_residue_sieve
    (h : VampireWitness v x y) :
    (x % 9, y % 9) = (0, 0) ∨
    (x % 9, y % 9) = (2, 2) ∨
    (x % 9, y % 9) = (3, 6) ∨
    (x % 9, y % 9) = (5, 8) ∨
    (x % 9, y % 9) = (6, 3) ∨
    (x % 9, y % 9) = (8, 5) := by
  have h_subst : (x * y : ZMod 9) = (x : ZMod 9) + (y : ZMod 9) := by
    obtain ⟨rfl, h⟩ := h
    simpa using congr_arg ((↑) : ℕ → ZMod 9) (fangDigits_modEq h)
  norm_cast at h_subst
  erw [ZMod.natCast_eq_natCast_iff] at h_subst
  norm_num [Nat.ModEq, Nat.add_mod, Nat.mul_mod] at h_subst
  have := Nat.mod_lt x (by decide : 0 < 9)
  have := Nat.mod_lt y (by decide : 0 < 9)
  interval_cases x % 9 <;> interval_cases y % 9 <;>
    simp +decide at h_subst ⊢

/-- The classical smallest example satisfies the exact digit-permutation
predicate, rather than merely a weakened numerical surrogate. -/
theorem vampire_1260 : VampireWitness 1260 21 60 := by
  norm_num [VampireWitness, FangDigits]
  decide

/-- The bridge specializes to a concrete certified arithmetic consequence for
`1260 = 21 * 60`. -/
theorem vampire_1260_modular_curve :
    (((21 : ℕ) : ZMod 9) - 1) * (((60 : ℕ) : ZMod 9) - 1) = 1 := by
  exact vampire_fangs_zmod_curve vampire_1260

/-- Machine-checked small-case evidence for the first seven standard decimal
vampire numbers and one choice of fangs for each. -/
theorem first_seven_vampire_witnesses :
    VampireWitness 1260 21 60 ∧
    VampireWitness 1395 15 93 ∧
    VampireWitness 1435 35 41 ∧
    VampireWitness 1530 30 51 ∧
    VampireWitness 1827 21 87 ∧
    VampireWitness 2187 27 81 ∧
    VampireWitness 6880 80 86 := by
  norm_num [VampireWitness, FangDigits]
  all_goals decide

end VampireDigitInvariant