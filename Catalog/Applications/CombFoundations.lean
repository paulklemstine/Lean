import Mathlib

/-!
# Combinatorial Foundations

This file collects the elementary combinatorial identities that are used to give a
*non-circular* derivation of the extended Eulerian number recurrence
(`Catalog/FINAL/ExtendedEulerian.lean`).

The only inputs are:

* **Pascal's rule** for binomial coefficients (`Nat.choose_succ_succ`), recast over `ℝ`.
* The **absorption identity** `(j+1) * C(n+1, j+1) = (n+1) * C(n, j)`
  (`Nat.succ_mul_choose_eq`), recast over `ℝ`.

From these two purely arithmetic facts about binomial coefficients we build three
identities about *alternating binomial sums*

  `∑_{i < m+1} (-1)^i * C(N, i) * (c - i)^q`

which are exactly the manipulations needed for the recurrence proof:

* `alt_binom_pascal_split` — splitting `C(n+2, i)` via Pascal's rule;
* `alt_binom_absorb_sum`   — pulling the factor `i` out via the absorption identity;
* `alt_binom_pascal_recombine` — recombining two `C(n, ·)` sums into one `C(n+1, ·)` sum.

None of these identities mentions the Eulerian recurrence, so using them to prove the
recurrence introduces no circular dependency.
-/

namespace CombFoundations

open Finset

/-
**Pascal's rule**, cast to `ℝ`:
`C(n+2, j+1) = C(n+1, j) + C(n+1, j+1)`.
-/
theorem choose_succ_succ_cast (n j : ℕ) :
    ((Nat.choose (n + 2) (j + 1) : ℝ)) =
      (Nat.choose (n + 1) j : ℝ) + (Nat.choose (n + 1) (j + 1) : ℝ) := by
  exact mod_cast Nat.choose_succ_succ _ _

/-
**Absorption identity**, cast to `ℝ`:
`(j+1) * C(n+1, j+1) = (n+1) * C(n, j)`.
-/
theorem choose_absorb_cast (n j : ℕ) :
    ((j : ℝ) + 1) * (Nat.choose (n + 1) (j + 1) : ℝ) =
      ((n : ℝ) + 1) * (Nat.choose n j : ℝ) := by
  exact mod_cast by rw [ Nat.add_one_mul_choose_eq, mul_comm ] ;

/-
**Pascal split of an alternating binomial sum.**
Splitting `C(n+2, i)` via Pascal's rule and reindexing the second part gives
a difference of two `C(n+1, ·)` sums. (`c` and the exponent `q` are arbitrary.)
-/
theorem alt_binom_pascal_split (n m q : ℕ) (c : ℝ) :
    ∑ i ∈ range (m + 2), (-1 : ℝ) ^ i * (Nat.choose (n + 2) i : ℝ) * (c - i) ^ q
      = (∑ i ∈ range (m + 2), (-1 : ℝ) ^ i * (Nat.choose (n + 1) i : ℝ) * (c - i) ^ q)
        - ∑ j ∈ range (m + 1),
            (-1 : ℝ) ^ j * (Nat.choose (n + 1) j : ℝ) * (c - 1 - j) ^ q := by
  simp +decide [ Finset.sum_range_succ', choose_succ_succ_cast ];
  simpa [ mul_add, add_mul, Finset.sum_add_distrib, pow_succ, sub_sub ] using by ring;

/-
**Absorbing the linear factor `i`.**
Using the absorption identity, the factor `i` is pulled out of an alternating binomial
sum, lowering the upper binomial index from `n+1` to `n`.
-/
theorem alt_binom_absorb_sum (n m q : ℕ) (c : ℝ) :
    ∑ i ∈ range (m + 1),
        (-1 : ℝ) ^ i * (Nat.choose (n + 1) i : ℝ) * (i : ℝ) * (c - i) ^ q
      = -((n : ℝ) + 1) *
          ∑ j ∈ range m,
            (-1 : ℝ) ^ j * (Nat.choose n j : ℝ) * (c - 1 - j) ^ q := by
  convert Finset.sum_range_succ' ( fun i ↦ ( -1 : ℝ ) ^ i * ( n + 1 ).choose i * i * ( c - i ) ^ q ) m using 1 ; norm_num [ mul_assoc, Finset.mul_sum _ _ _ ] ; ring;
  grind +suggestions

/-
**Recombination via Pascal's rule.**
The difference of a `C(n, ·)` sum over `range (m+1)` and a shifted `C(n, ·)` sum over
`range m` collapses, via Pascal's rule, into a single `C(n+1, ·)` sum.
-/
theorem alt_binom_pascal_recombine (n m q : ℕ) (d : ℝ) :
    (∑ j ∈ range (m + 1), (-1 : ℝ) ^ j * (Nat.choose n j : ℝ) * (d - j) ^ q)
      - (∑ j ∈ range m, (-1 : ℝ) ^ j * (Nat.choose n j : ℝ) * (d - 1 - j) ^ q)
      = ∑ j ∈ range (m + 1),
          (-1 : ℝ) ^ j * (Nat.choose (n + 1) j : ℝ) * (d - j) ^ q := by
  simp +decide [ Finset.sum_range_succ', Nat.choose_succ_succ ];
  norm_num [ add_mul, mul_add, pow_succ', sub_sub, mul_sub ];
  simpa [ add_comm, Finset.sum_add_distrib ] using by ring;

end CombFoundations