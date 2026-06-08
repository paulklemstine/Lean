/-
# Vampire Numbers and Arithmetic Creatures: Formal Definitions

A *vampire number* is a composite natural number v with 2n digits that can be
factored as v = x * y where x and y (called "fangs") each have n digits, and the
multiset of decimal digits of v equals the multiset union of digits of x and y.

The smallest vampire number is 1260 = 21 × 60.

We also define several novel "arithmetic creature" variants:
- **Werewolf numbers**: v = x * y where the digit multiset intersection of
  {digits(x), digits(y)} with digits(v) has exactly one element.
- **Ghost numbers**: v = x * y where the digit sets of x and y are disjoint from v.
- **Spectral numbers**: A novel concept — numbers whose digit multiset is a
  "permutation shadow" of a vampire factorization (the sorted digits match but
  the multiset doesn't).
-/

import Mathlib

namespace VampireNumbers

/-- The multiset of decimal digits of a natural number. -/
def digitMultiset (n : ℕ) : Multiset ℕ :=
  ↑(Nat.digits 10 n)

/-- The number of decimal digits of a natural number.
    We define 0 to have 1 digit. -/
def numDigits (n : ℕ) : ℕ :=
  (Nat.digits 10 n).length

/-- The digit sum of a natural number in base 10. -/
def digitSum (n : ℕ) : ℕ :=
  (Nat.digits 10 n).sum

/-- A *vampire number* is a natural number v with an even number of digits 2n (n ≥ 2)
    that admits a factorization v = x * y where:
    - x and y each have exactly n digits
    - The multiset of digits of v equals the multiset union of digits of x and y
    - Not both x and y end in 0 (to exclude trivial cases) -/
def IsVampire (v : ℕ) : Prop :=
  ∃ n : ℕ, n ≥ 2 ∧
    numDigits v = 2 * n ∧
    ∃ x y : ℕ, v = x * y ∧
      numDigits x = n ∧
      numDigits y = n ∧
      digitMultiset v = digitMultiset x + digitMultiset y ∧
      ¬(x % 10 = 0 ∧ y % 10 = 0)

/-- The fangs of a vampire number. -/
structure Fangs (v : ℕ) where
  x : ℕ
  y : ℕ
  n : ℕ
  hn : n ≥ 2
  hv_digits : numDigits v = 2 * n
  hx_digits : numDigits x = n
  hy_digits : numDigits y = n
  hprod : v = x * y
  hdigits : digitMultiset v = digitMultiset x + digitMultiset y
  htrailing : ¬(x % 10 = 0 ∧ y % 10 = 0)

/-- A *ghost number* is v = x * y where the digit *sets* of x and y are
    completely disjoint from the digit set of v. -/
def IsGhostNumber (v : ℕ) : Prop :=
  ∃ x y : ℕ, v = x * y ∧ x > 1 ∧ y > 1 ∧
    (digitMultiset v).toFinset ∩ (digitMultiset x).toFinset = ∅ ∧
    (digitMultiset v).toFinset ∩ (digitMultiset y).toFinset = ∅

/-- A *werewolf number* is v = x * y where the combined digit multiset of x and y
    shares exactly one digit (with multiplicity) with v's digit multiset. -/
def IsWerewolfNumber (v : ℕ) : Prop :=
  ∃ x y : ℕ, v = x * y ∧ x > 1 ∧ y > 1 ∧
    Multiset.card ((digitMultiset x + digitMultiset y) ∩ digitMultiset v) = 1

/-- A *spectral number* is a number v = x * y where sorting the digits of v
    gives the same result as sorting the combined digits of x and y,
    but the multisets are NOT equal (a "near-miss" vampire). -/
def IsSpectralNumber (v : ℕ) : Prop :=
  ∃ x y : ℕ, v = x * y ∧ x > 1 ∧ y > 1 ∧
    (digitMultiset v).sort (· ≤ ·) = (digitMultiset x + digitMultiset y).sort (· ≤ ·) ∧
    digitMultiset v ≠ digitMultiset x + digitMultiset y

/-- The fang constraint: for a valid vampire factorization v = x * y with n-digit fangs,
    both fangs must be at least 10^(n-1) and less than 10^n. -/
def FangBound (x y n : ℕ) : Prop :=
  10^(n-1) ≤ x ∧ x < 10^n ∧ 10^(n-1) ≤ y ∧ y < 10^n

end VampireNumbers