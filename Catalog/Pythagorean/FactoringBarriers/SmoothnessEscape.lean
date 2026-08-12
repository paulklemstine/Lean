import Pythagorean.FactoringBarriers.PolynomialBarrier

/-!
# The boundary of Barrier I: what escapes, and what does not

Barrier I says that no fixed integer polynomial invariant of `N` can split semiprimes.
A natural objection is Pollard's `p - 1` method, which *does* split many semiprimes by
taking gcds of `a^m - 1` with `N`.  This file locates the boundary exactly.

* `FactoringBarriers.pollard_splits` : the correctness theorem for the `p - 1`
  strategy.  If `p - 1 ∣ m`, `p ∤ a` and `q ∤ a^m - 1`, then `gcd(a^m - 1, N) = p`.
  So the exponential invariant genuinely splits `N`; Barrier I is not vacuous
  overreach, exponential constructions are outside its scope.

* `FactoringBarriers.pollard_fixed_exponent_eq_polyWitness` : but for a **fixed**
  exponent `m`, the quantity `a^m - 1` is a *constant*, so the `p - 1` witness is
  literally the polynomial witness of the constant polynomial `C (a^m - 1)`.  Hence
  `FactoringBarriers.no_universal_fixed_exponent_pollard` : a fixed exponent fails on
  some semiprime, by Barrier I itself.

The synthesis (`FactoringBarriers.escape_requires_growing_exponent`) is that all of the
power of the `p - 1` method comes from letting the exponent grow with the input: the
method is a *sequence* of polynomial invariants of unbounded size, never a single one.
This is exactly the loophole that Barrier I leaves open, and it is the only one.
-/

namespace FactoringBarriers

open Polynomial

/-- Fermat's little theorem in divisibility form: if `p` is prime, `p ∤ a` and
`(p-1) ∣ m`, then `p ∣ a^m - 1`. -/
theorem prime_dvd_pow_sub_one {p : ℕ} (hp : p.Prime) {a : ℤ} (ha : ¬ (p : ℤ) ∣ a)
    {m : ℕ} (hm : (p - 1) ∣ m) : (p : ℤ) ∣ a ^ m - 1 := by
  haveI : Fact p.Prime := ⟨hp⟩
  obtain ⟨t, ht⟩ := hm
  have ha' : (a : ZMod p) ≠ 0 := by
    intro h
    exact ha ((ZMod.intCast_zmod_eq_zero_iff_dvd a p).mp h)
  have hfermat : (a : ZMod p) ^ (p - 1) = 1 := ZMod.pow_card_sub_one_eq_one ha'
  have : ((a ^ m - 1 : ℤ) : ZMod p) = 0 := by
    push_cast
    rw [ht, pow_mul, hfermat, one_pow, sub_self]
  exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ p).mp this

/-- **Correctness of the `p - 1` strategy.**  With `N = p q` a semiprime, if the
exponent `m` is a multiple of `p - 1`, `a` is not divisible by `p`, and `q` does not
divide `a^m - 1`, then the gcd witness is exactly the prime `p`. -/
theorem pollard_splits {p q : ℕ} (hp : p.Prime) (hq : q.Prime) {a : ℤ} {m : ℕ}
    (ha : ¬ (p : ℤ) ∣ a) (hm : (p - 1) ∣ m) (hq' : ¬ (q : ℤ) ∣ a ^ m - 1) :
    Int.gcd (a ^ m - 1) ((p * q : ℕ) : ℤ) = p := by
  set d : ℕ := Int.gcd (a ^ m - 1) ((p * q : ℕ) : ℤ) with hd
  have hdN : d ∣ p * q := by
    have : (d : ℤ) ∣ ((p * q : ℕ) : ℤ) := Int.gcd_dvd_right _ _
    exact_mod_cast this
  have hpd : p ∣ d := by
    have h1 : (p : ℤ) ∣ a ^ m - 1 := prime_dvd_pow_sub_one hp ha hm
    have h2 : (p : ℤ) ∣ ((p * q : ℕ) : ℤ) := by
      push_cast; exact Dvd.intro q rfl
    have h3 := Int.dvd_gcd h1 h2
    exact_mod_cast h3
  have hqd : ¬ q ∣ d := by
    intro hqd
    have h1 : (q : ℤ) ∣ (d : ℤ) := Int.natCast_dvd_natCast.mpr hqd
    exact hq' (h1.trans (Int.gcd_dvd_left _ _))
  have hcop : Nat.Coprime d q := (hq.coprime_iff_not_dvd.mpr hqd).symm
  have hdp : d ∣ p := hcop.dvd_of_dvd_mul_right hdN
  exact Nat.dvd_antisymm hdp hpd

/-- A concrete escape: `N = 35`, `a = 2`, `m = 4` (a multiple of `5 - 1`) yields the
factor `5`.  Barrier I is therefore not an artefact of an empty class of methods. -/
theorem pollard_example : Int.gcd ((2 : ℤ) ^ 4 - 1) ((35 : ℕ) : ℤ) = 5 := by
  have h := pollard_splits (p := 5) (q := 7) (a := 2) (m := 4)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  norm_num at h ⊢

/-- **The other failure mode: too much smoothness.**  If the exponent is a multiple of
both `p - 1` and `q - 1`, the witness returns all of `N` and no factor is found.  The
`p - 1` strategy therefore lives in a narrow window: the exponent must be divisible by
`p - 1` but not by `q - 1`. -/
theorem pollard_fails_when_both_smooth {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p ≠ q) {a : ℤ} {m : ℕ} (hpa : ¬ (p : ℤ) ∣ a) (hqa : ¬ (q : ℤ) ∣ a)
    (hmp : (p - 1) ∣ m) (hmq : (q - 1) ∣ m) :
    Int.gcd (a ^ m - 1) ((p * q : ℕ) : ℤ) = p * q := by
  have h1 : (p : ℤ) ∣ a ^ m - 1 := prime_dvd_pow_sub_one hp hpa hmp
  have h2 : (q : ℤ) ∣ a ^ m - 1 := prime_dvd_pow_sub_one hq hqa hmq
  have hcop : IsCoprime (p : ℤ) (q : ℤ) := by
    rw [Int.isCoprime_iff_gcd_eq_one]
    simpa [Int.gcd_natCast_natCast] using (Nat.coprime_primes hp hq).mpr hpq
  have hN : ((p * q : ℕ) : ℤ) ∣ a ^ m - 1 := by
    push_cast
    exact hcop.mul_dvd h1 h2
  simpa using Int.gcd_eq_natAbs_right_iff_dvd.mpr hN

/-! ### ... but a fixed exponent is just a constant polynomial -/

/-- For a **fixed** exponent, the `p - 1` witness is the polynomial witness of a
constant polynomial. -/
theorem pollard_fixed_exponent_eq_polyWitness (a : ℤ) (m : ℕ) (N : ℕ) :
    Int.gcd (a ^ m - 1) (N : ℤ) = polyWitness (C (a ^ m - 1)) N := by
  simp [polyWitness]

/-- **A fixed exponent cannot be universal.**  For every fixed `a` and `m` there is a
semiprime on which the `p - 1` witness fails to produce a nontrivial factor — an
immediate consequence of Barrier I, since a fixed exponent makes the invariant a
constant polynomial. -/
theorem no_universal_fixed_exponent_pollard (a : ℤ) (m : ℕ) :
    ¬ ∀ N : ℕ, IsDistinctSemiprime N →
      1 < Int.gcd (a ^ m - 1) (N : ℤ) ∧ Int.gcd (a ^ m - 1) (N : ℤ) < N := by
  intro h
  refine no_universal_polynomial_witness (C (a ^ m - 1)) ?_
  intro N hN
  obtain ⟨h1, h2⟩ := h N hN
  rw [pollard_fixed_exponent_eq_polyWitness] at h1 h2
  exact ⟨h1, h2⟩

/-- **Synthesis: the escape requires a growing exponent.**  The `p - 1` strategy does
split some semiprimes, yet for each fixed exponent it fails on some semiprime.  All of
its power therefore comes from letting the exponent (equivalently, the size of the
integer invariant) grow with the input — precisely the one loophole Barrier I leaves
open. -/
theorem escape_requires_growing_exponent :
    (∃ (N : ℕ) (a : ℤ) (m : ℕ), IsDistinctSemiprime N ∧
        1 < Int.gcd (a ^ m - 1) (N : ℤ) ∧ Int.gcd (a ^ m - 1) (N : ℤ) < N) ∧
    (∀ (a : ℤ) (m : ℕ), ¬ ∀ N : ℕ, IsDistinctSemiprime N →
        1 < Int.gcd (a ^ m - 1) (N : ℤ) ∧ Int.gcd (a ^ m - 1) (N : ℤ) < N) := by
  refine ⟨⟨35, 2, 4, ⟨5, 7, by norm_num, by norm_num, by norm_num, by norm_num⟩, ?_, ?_⟩,
    no_universal_fixed_exponent_pollard⟩
  · rw [pollard_example]; norm_num
  · rw [pollard_example]; norm_num

end FactoringBarriers