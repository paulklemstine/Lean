import Mathlib

/-!
# The supplementary laws of quadratic reciprocity

The two supplementary laws describe when `-1` and `2` are quadratic residues mod an
odd prime `p`, in terms of the residue of `p` modulo `4` and `8` respectively.  We
record them in fully explicit, decision-procedure-friendly forms for the Legendre
symbol, derived from Mathlib's character computations `legendreSym.at_neg_one`
(`= χ₄ p`) and `legendreSym.at_two` (`= χ₈ p`).

* `(-1/p) = (-1)^((p-1)/2)`, equal to `1 ⇔ p ≡ 1 [4]` and `-1 ⇔ p ≡ 3 [4]`.
* `(2/p) = 1 ⇔ p ≡ ±1 [8]` and `-1 ⇔ p ≡ ±3 [8]`.

-- !-- Lab Notes -- !--
HYPOTHESIS.  Both supplementary laws are *purely congruential*: the value of the
Legendre symbol is a function of `p mod 4` (for `-1`) and `p mod 8` (for `2`).  The
classical proofs go through Gauss's lemma / Gauss sums, but the residue formulas
should reduce, given Mathlib's `χ₄`/`χ₈` evaluations, to finite case analysis.

EXPERIMENT.  Rewrite with `legendreSym.at_neg_one`/`at_two`, expand `χ₄`/`χ₈` with
`ZMod.χ₄_nat_eq_if_mod_four` / `ZMod.χ₈_nat_eq_if_mod_eight`, and discharge the
residue bookkeeping with `omega` after recording that `p` is odd.

ANALYSIS.  The subtlety is that the `if`-branches are stated mod `2`, `4`, `8`; the
oddness fact `p % 2 = 1` (from `Nat.Prime.eq_two_or_odd`) is exactly what lets
`omega` collapse the nested conditionals to the residue classes.

CRITIQUE.  These are non-vacuous biconditionals (each direction is realised by
concrete primes, e.g. `5 ≡ 1 [4]`, `7 ≡ 3 [4]`, `7 ≡ 7 [8]`, `3 ≡ 3 [8]`), proved
without `decide` on the prime; the `omega` step does real congruence reasoning.

SYNTHESIS.  Together with `Eisenstein.lean` and `GaussSum.lean`, this completes the
classical package: the main reciprocity law plus its two supplements.
-/

open ZMod

namespace QuadraticReciprocity.Supplementary

variable {p : ℕ} [Fact p.Prime]

/-
An odd prime is congruent to `1` or `3` modulo `4`.
-/
theorem odd_prime_mod_four (hp : p ≠ 2) : p % 4 = 1 ∨ p % 4 = 3 := by
  cases Nat.Prime.eq_two_or_odd ( Fact.out : Nat.Prime p ) <;> omega

/-
**First supplementary law (power form).**  `(-1/p) = (-1)^((p-1)/2)`.
-/
theorem legendreSym_neg_one_eq_pow (hp : p ≠ 2) :
    legendreSym p (-1) = (-1) ^ (p / 2) := by
  rw [ legendreSym.at_neg_one hp ];
  convert ZMod.χ₄_eq_neg_one_pow _;
  exact Nat.Prime.eq_two_or_odd ( Fact.out : Nat.Prime p ) |> Or.resolve_left <| hp

/-
**First supplementary law.**  `-1` is a quadratic residue mod `p` iff `p ≡ 1 [4]`.
-/
theorem legendreSym_neg_one_eq_one_iff (hp : p ≠ 2) :
    legendreSym p (-1) = 1 ↔ p % 4 = 1 := by
  rw [ legendreSym.at_neg_one hp ];
  rw [ ZMod.χ₄_nat_eq_if_mod_four ];
  lia

/-
`-1` is a quadratic nonresidue mod `p` iff `p ≡ 3 [4]`.
-/
theorem legendreSym_neg_one_eq_neg_one_iff (hp : p ≠ 2) :
    legendreSym p (-1) = -1 ↔ p % 4 = 3 := by
  rw [ legendreSym.at_neg_one ];
  · rw [ ZMod.χ₄_nat_eq_if_mod_four ] ; split_ifs <;> simp_all +decide [ Nat.ModEq ];
    · grind;
    · omega;
  · assumption

/-
**Second supplementary law.**  `2` is a quadratic residue mod `p` iff
`p ≡ 1` or `7` modulo `8`.
-/
theorem legendreSym_two_eq_one_iff (hp : p ≠ 2) :
    legendreSym p 2 = 1 ↔ p % 8 = 1 ∨ p % 8 = 7 := by
  have h_odd : p % 2 = 1 := by
    exact Nat.Prime.eq_two_or_odd ( Fact.out : Nat.Prime p ) |> Or.resolve_left <| hp;
  rw [ legendreSym.at_two ];
  · rw [ ZMod.χ₈_nat_eq_if_mod_eight ] ; split_ifs <;> simp_all +decide;
  · assumption

/-
`2` is a quadratic nonresidue mod `p` iff `p ≡ 3` or `5` modulo `8`.
-/
theorem legendreSym_two_eq_neg_one_iff (hp : p ≠ 2) :
    legendreSym p 2 = -1 ↔ p % 8 = 3 ∨ p % 8 = 5 := by
  convert legendreSym.at_two hp using 1;
  rw [ ZMod.χ₈_nat_eq_if_mod_eight ] ; split_ifs <;> simp_all +decide [ Nat.ModEq ] ;
  · cases Nat.Prime.eq_two_or_odd ( Fact.out : Nat.Prime p ) <;> simp_all +decide;
  · have := legendreSym_two_eq_one_iff hp; aesop;
  · lia

end QuadraticReciprocity.Supplementary