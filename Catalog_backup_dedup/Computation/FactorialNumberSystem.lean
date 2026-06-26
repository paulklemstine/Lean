import Mathlib

/-!
# The Factorial Number System (Factoradic Representation)

This file develops the factorial number system from first principles, with a focus
on a **direct, non-circular** proof of uniqueness of factoradic representations.

A length-`k` factoradic value of a digit function `c : Nat → Nat` is
`value c k = ∑_{i < k} c i * i!` subject to the validity condition `c i ≤ i`.

The main theorem `value_unique` shows that valid representations are unique.  Its
proof is **direct**: it relies only on
* the digit-bound estimate `value_lt : Valid c k → value c k < k!`, and
* the mixed-radix splitting identities `splitting_div` and `splitting_mod`,
both of which are proved using nothing but arithmetic and the definition of `Valid`.

In particular `value_unique` does **not** go through surjectivity, cardinality,
`Finset.card`, a bijection theorem or any enumeration theorem.  The optional
existence / bijection results at the end of the file *may* depend on
`value_unique`, but `value_unique` never depends on them.
-/

namespace FactorialNumberSystem

open Finset

/-- The length-`k` factoradic value of a digit function `c`. -/
def value (c : Nat → Nat) (k : Nat) : Nat :=
  ∑ i ∈ Finset.range k, c i * i.factorial

/-- A digit function is valid up to length `k` if every digit `c i` (for `i < k`)
satisfies the factoradic bound `c i ≤ i`. -/
def Valid (c : Nat → Nat) (k : Nat) : Prop := ∀ i < k, c i ≤ i

@[simp] theorem value_zero (c : Nat → Nat) : value c 0 = 0 := by
  simp [value]

/-- The defining recurrence: peeling off the top digit. -/
theorem value_succ (c : Nat → Nat) (k : Nat) :
    value c (k + 1) = value c k + c k * k.factorial := by
  simp [value, Finset.sum_range_succ]

/-- `Valid` is monotone in the length: validity up to `k+1` implies validity up to `k`. -/
theorem Valid.of_succ {c : Nat → Nat} {k : Nat} (h : Valid c (k + 1)) :
    Valid c k := fun i hi => h i (Nat.lt_succ_of_lt hi)

/-! ## 1. The digit-bound estimate (independent) -/

/-- A valid length-`k` factoradic value is strictly less than `k!`.
This is proved by induction using only arithmetic and the definition of `Valid`. -/
theorem value_lt {c : Nat → Nat} {k : Nat} : Valid c k → value c k < k.factorial := by
  induction' k with k ih <;> simp_all +decide [Valid];
  intro h; specialize ih fun i hi => h i hi.le; rw [ Nat.factorial_succ ] ; rw [ value_succ ] ; nlinarith [ h k le_rfl ] ;

/-! ## 2. The mixed-radix splitting identities (independent) -/

/-- Dividing a valid length-`(k+1)` value by `k!` recovers the top digit `c k`. -/
theorem splitting_div {c : Nat → Nat} {k : Nat} :
    Valid c (k + 1) → value c (k + 1) / k.factorial = c k := by
  intro h;
  convert Nat.add_mul_div_right _ _ ( Nat.factorial_pos k ) using 1;
  rw [ value_succ ];
  rw [ Nat.div_eq_of_lt ( value_lt ( Valid.of_succ h ) ) ] ; norm_num

/-- Reducing a valid length-`(k+1)` value mod `k!` recovers the lower part `value c k`. -/
theorem splitting_mod {c : Nat → Nat} {k : Nat} :
    Valid c (k + 1) → value c (k + 1) % k.factorial = value c k := by
  intro h;
  convert Nat.mod_eq_of_lt ( value_lt ( Valid.of_succ h ) ) using 1;
  simp +decide [ value, Finset.sum_range_succ ]

/-! ## 3. Uniqueness (direct, via splitting) -/

/-- **Uniqueness of valid factoradic representations.**  If two valid digit functions
have the same length-`k` value, then they agree on all digits below `k`.

The proof is by induction on `k`, using `splitting_div` to recover the top digit `c k = d k`
and `splitting_mod` to reduce the equality of values to the tail `value c k = value d k`,
to which the induction hypothesis applies.  It does not use surjectivity, cardinality, or
any bijection/enumeration theorem; moreover the optional results below are declared *after*
this theorem, so they cannot participate in its proof. -/
theorem value_unique {c d : Nat → Nat} {k : Nat} :
    Valid c k → Valid d k → value c k = value d k → ∀ i < k, c i = d i := by
  induction k generalizing c d with
  | zero => intro _ _ _ i hi; exact absurd hi (Nat.not_lt_zero i)
  | succ k ih =>
    intro hc hd hv i hi
    have hck : c k = d k := by
      rw [← splitting_div hc, ← splitting_div hd, hv]
    have htail : value c k = value d k := by
      rw [← splitting_mod hc, ← splitting_mod hd, hv]
    have hrec := ih (Valid.of_succ hc) (Valid.of_succ hd) htail
    rcases Nat.lt_succ_iff_lt_or_eq.mp hi with h | h
    · exact hrec i h
    · subst h; exact hck

/-! ## Optional: explicit digit extraction, existence and bijection.

These results come **after** `value_unique` and may depend on it; `value_unique`
does not depend on any of them. -/

/-- Explicit factoradic digit extraction for a natural number `n`. -/
def digit (n : Nat) (i : Nat) : Nat := (n / i.factorial) % (i + 1)

/-- The extracted digits are valid. -/
theorem digit_valid (n : Nat) (k : Nat) : Valid (digit n) k := by
  intro i _
  have : (n / i.factorial) % (i + 1) ≤ i := Nat.lt_succ_iff.mp (Nat.mod_lt _ (Nat.succ_pos i))
  simpa [digit] using this

/-- **Existence / surjectivity**: every `n < k!` is the factoradic value of its own
extracted digits. -/
theorem value_digit {n : Nat} {k : Nat} (hn : n < k.factorial) :
    value (digit n) k = n := by
  -- By definition of `digit`, we can write the value as the sum of each digit multiplied by its factorial.
  have h_value : value (digit n) k = ∑ i ∈ Finset.range k, ((n / i.factorial) % (i + 1)) * i.factorial := by
    rfl;
  have h_split : ∀ k, n = (∑ i ∈ Finset.range k, (n / i.factorial) % (i + 1) * i.factorial) + (n / k.factorial) * k.factorial := by
    intro k; induction' k with k ih <;> simp +decide [ Finset.sum_range_succ, Nat.factorial_succ ] at *;
    rw [ show n / ( ( k + 1 ) * k.factorial ) = n / k.factorial / ( k + 1 ) by rw [ Nat.div_div_eq_div_mul ] ; ring ];
    nlinarith [ Nat.mod_add_div ( n / k.factorial ) ( k + 1 ), Nat.factorial_pos k ];
  nlinarith [ h_split k, Nat.div_eq_of_lt hn ]

end FactorialNumberSystem