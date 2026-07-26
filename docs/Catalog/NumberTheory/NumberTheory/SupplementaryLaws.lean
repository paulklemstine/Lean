import Mathlib

/-!
# The two supplementary laws of quadratic reciprocity

We prove, for an odd prime `p`, the two supplementary laws of quadratic reciprocity
in their classical power form:

* `legendreSym_neg_one : legendreSym p (-1) = (-1) ^ ((p - 1) / 2)`;
* `legendreSym_two     : legendreSym p 2 = (-1) ^ ((p ^ 2 - 1) / 8)`.

## Anti-circularity

These laws are proved *independently* of the main quadratic reciprocity theorem and
of the Gauss-sum machinery.  Concretely:

* The first law is obtained from `legendreSym.at_neg_one` (Legendre symbol at `-1`
  equals `χ₄ p`), which is proved in `Mathlib` from Euler's criterion
  (`quadraticChar_eq_pow_of_char_ne_two`) and `ZMod.χ₄_eq_neg_one_pow`, with **no
  dependence on Gauss sums or on quadratic reciprocity**.

* The second law is obtained from **Gauss's lemma** (`gauss_lemma`), which is proved
  in `Mathlib` purely from Euler's criterion and a counting argument
  (`Mathlib/NumberTheory/LegendreSymbol/GaussEisensteinLemmas.lean`, importing only
  `Basic`), and is likewise **independent of Gauss sums and of quadratic
  reciprocity**.

In particular none of the forbidden results (`quadratic_reciprocity`,
`gaussSum_sq`/`gauss_sum_sq_value`, `quadraticChar_odd_prime`, or anything depending
on the supplementary laws) is used, and neither target theorem is used in the proof
of the other.
-/

open ZMod Finset

namespace QuadraticReciprocity.SupplementaryLaws

/-- If two exponents are congruent mod `2`, then `(-1)` raised to them agree (over `ℤ`). -/
theorem neg_one_pow_eq_of_mod_two_eq (N M : ℕ) (h : N % 2 = M % 2) :
    ((-1 : ℤ)) ^ N = (-1) ^ M := by
  conv_lhs => rw [← Nat.div_add_mod N 2, pow_add, pow_mul]
  conv_rhs => rw [← Nat.div_add_mod M 2, pow_add, pow_mul]
  simp [h]

/-- `2` is nonzero in `ZMod p` for an odd prime `p` (stated for the integer `2`). -/
theorem two_ne_zero_zmod (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) : ((2 : ℤ) : ZMod p) ≠ 0 := by
  have hpr := (Fact.out : p.Prime)
  rw [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]
  intro hd
  have hp2 : p ∣ 2 := by exact_mod_cast hd
  exact hp ((Nat.prime_dvd_prime_iff_eq hpr Nat.prime_two).mp hp2)

/-- The parity bookkeeping behind the second supplementary law: for odd `p`,
`(p/2 - p/4)` and `(p² - 1)/8` have the same parity.  (Verified by a residue
computation modulo `8`.) -/
theorem parity_two (p : ℕ) (hodd : p % 2 = 1) :
    (p / 2 - p / 4) % 2 = ((p ^ 2 - 1) / 8) % 2 := by
  obtain ⟨k, r, hr, hp⟩ : ∃ k r, r < 8 ∧ p = 8 * k + r :=
    ⟨p / 8, p % 8, Nat.mod_lt _ (by norm_num), (Nat.div_add_mod p 8).symm⟩
  have hsq : p ^ 2 = 64 * (k * k) + 16 * r * k + r ^ 2 := by subst hp; ring
  interval_cases r <;> omega

/-- The count appearing in Gauss's lemma for `a = 2`: the number of `x ∈ [1, p/2]`
with `2x` reducing above `p/2` (mod `p`) equals `p/2 - p/4`.  For `x` in this range
we have `2x < p`, so `(2x : ZMod p).val = 2x`, and the condition `p/2 < 2x` is
equivalent to `p/4 < x`. -/
theorem count_two (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    #{x ∈ Ico 1 (p / 2).succ | p / 2 < (((2 : ℤ) : ZMod p) * ((x : ℕ) : ZMod p)).val} =
      p / 2 - p / 4 := by
  have hpr := (Fact.out : p.Prime)
  have hodd : p % 2 = 1 := hpr.eq_two_or_odd.resolve_left hp
  have hset : {x ∈ Ico 1 (p / 2).succ | p / 2 < (((2 : ℤ) : ZMod p) * ((x : ℕ) : ZMod p)).val}
      = Ico (p / 4 + 1) (p / 2 + 1) := by
    ext x
    simp only [mem_filter, mem_Ico, Nat.lt_succ_iff]
    constructor
    · rintro ⟨⟨hx1, hx2⟩, hx3⟩
      have hlt : 2 * x < p := by omega
      have hc : (((2 : ℤ) : ZMod p) * ((x : ℕ) : ZMod p) : ZMod p) = ((2 * x : ℕ) : ZMod p) := by
        push_cast; ring
      rw [hc, ZMod.val_natCast_of_lt hlt] at hx3
      omega
    · rintro ⟨hx1, hx2⟩
      refine ⟨⟨by omega, by omega⟩, ?_⟩
      have hlt : 2 * x < p := by omega
      have hc : (((2 : ℤ) : ZMod p) * ((x : ℕ) : ZMod p) : ZMod p) = ((2 * x : ℕ) : ZMod p) := by
        push_cast; ring
      rw [hc, ZMod.val_natCast_of_lt hlt]
      omega
  rw [hset, Nat.card_Ico]
  omega

/-- **First supplementary law of quadratic reciprocity.**
For an odd prime `p`, `legendreSym p (-1) = (-1) ^ ((p - 1) / 2)`. -/
lemma legendreSym_neg_one (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    legendreSym p (-1) = (-1) ^ ((p - 1) / 2) := by
  have hpr := (Fact.out : p.Prime)
  have hodd : p % 2 = 1 := hpr.eq_two_or_odd.resolve_left hp
  rw [legendreSym.at_neg_one hp, ZMod.χ₄_eq_neg_one_pow hodd]
  congr 1
  omega

/-- **Second supplementary law of quadratic reciprocity.**
For an odd prime `p`, `legendreSym p 2 = (-1) ^ ((p ^ 2 - 1) / 8)`. -/
lemma legendreSym_two (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    legendreSym p 2 = (-1) ^ ((p ^ 2 - 1) / 8) := by
  have hpr := (Fact.out : p.Prime)
  have hodd : p % 2 = 1 := hpr.eq_two_or_odd.resolve_left hp
  rw [gauss_lemma hp (two_ne_zero_zmod p hp), count_two p hp]
  exact neg_one_pow_eq_of_mod_two_eq _ _ (parity_two p hodd)

end QuadraticReciprocity.SupplementaryLaws