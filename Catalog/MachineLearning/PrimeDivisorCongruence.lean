/-
  # Prime Divisor Congruence Law for n² + 1

  This file proves that every odd prime divisor of n² + 1 must be congruent
  to 1 modulo 4. This is equivalent to the classical result that -1 is a
  quadratic residue mod p if and only if p ≡ 1 (mod 4).

  ## Main result

  - `prime_dvd_sq_add_one_mod_four`: If q is an odd prime and q ∣ n² + 1,
    then q % 4 = 1.

  ## Proof strategy

  From q ∣ n² + 1, we get n² ≡ -1 (mod q). Then n⁴ ≡ 1 (mod q) but
  n² ≢ 1 (mod q) (since n² ≡ -1 and q > 2). So the multiplicative
  order of n mod q is exactly 4. By Lagrange's theorem, 4 ∣ q - 1,
  hence q ≡ 1 (mod 4).
-/
import Mathlib

/-
**Theorem C**: If q is an odd prime and q divides n² + 1, then q ≡ 1 (mod 4).

This is the exact splitting law: primes dividing values of n² + 1 must split
in the Gaussian integers ℤ[i], which forces q ≡ 1 (mod 4).
-/
theorem prime_dvd_sq_add_one_mod_four
    {q n : ℕ} (hq : Nat.Prime q) (hqodd : q ≠ 2)
    (hdiv : q ∣ (n ^ 2 + 1)) :
    q % 4 = 1 := by
  haveI := Fact.mk hq;
  simp_all +decide [ ← ZMod.natCast_eq_zero_iff ];
  have := ZMod.exists_sq_eq_neg_one_iff ( p := q );
  have := this.mp ⟨ n, by linear_combination' hdiv.symm ⟩ ; ( have := Nat.Prime.eq_two_or_odd hq; omega; )

/-
Integer version of the prime divisor congruence law.
-/
theorem prime_dvd_sq_add_one_int_mod_four
    {q : ℕ} (hq : Nat.Prime q) (hqodd : q ≠ 2) {n : ℤ}
    (hdiv : (q : ℤ) ∣ (n ^ 2 + 1)) :
    q % 4 = 1 := by
  -- From $(q : ℤ) ∣ (n^2 + 1)$, we can find a natural number representative $m$ with $q ∣ m^2 + 1$ (take $m = n.natAbs$ or work mod $q$).
  have h_nat : ∃ m : ℕ, (q : ℤ) ∣ m^2 + 1 := by
    exact ⟨ Int.natAbs n, by simpa using hdiv ⟩;
  exact prime_dvd_sq_add_one_mod_four hq hqodd ( mod_cast h_nat.choose_spec )