/-
# Selberg sieve weight identity

This module proves the combinatorial identity underlying the Selberg sieve weights:
for every positive integer `n`,
$$\mu^2(n) = \sum_{d^2 \mid n} \mu(d),$$
where `μ` is the Möbius function.

The proof proceeds by introducing the *square-root part* `sqrtPart n`, the largest
integer `m` such that `m^2 ∣ n` (equivalently the number whose `p`-adic valuation is
`⌊v_p(n)/2⌋`).  The key observations are:

* `d ^ 2 ∣ n ↔ d ∣ sqrtPart n` (`dvd_sq_iff`), so the divisors `d` with `d^2 ∣ n`
  are exactly the divisors of `sqrtPart n`;
* `∑_{d ∣ m} μ(d) = if m = 1 then 1 else 0` (Möbius inversion of the constant
  function `1`, via `moebius_mul_coe_zeta`);
* `Squarefree n ↔ sqrtPart n = 1` (`squarefree_iff_sqrtPart`), matching the value of
  `μ^2(n)` given by `moebius_sq`.

Only the definition and basic properties of `μ` and prime factorizations are used; no
results about prime distribution (π(x), Chebyshev bounds, etc.) enter the argument.
-/
import Mathlib

open ArithmeticFunction

namespace SelbergSieveWeight

/-- The square-root part of `n`: the integer whose `p`-adic valuation is `⌊v_p(n) / 2⌋`.
This is the largest `m` with `m ^ 2 ∣ n`. -/
noncomputable def sqrtPart (n : ℕ) : ℕ :=
  (n.factorization.mapRange (· / 2) (Nat.zero_div 2)).prod (· ^ ·)

/-- The `p`-adic valuation of `sqrtPart n` is `⌊v_p(n) / 2⌋`. -/
theorem sqrtPart_fact (n : ℕ) (p : ℕ) :
    (sqrtPart n).factorization p = n.factorization p / 2 := by
  have : (sqrtPart n).factorization = n.factorization.mapRange (· / 2) (Nat.zero_div 2) := by
    apply Nat.prod_pow_factorization_eq_self
    intro q hq
    have h2 : q ∈ n.factorization.support := Finsupp.support_mapRange hq
    rw [Nat.support_factorization] at h2
    exact Nat.prime_of_mem_primeFactors h2
  rw [this, Finsupp.mapRange_apply]

theorem sqrtPart_ne_zero (n : ℕ) : sqrtPart n ≠ 0 := by
  have : 0 < sqrtPart n := by
    apply Nat.prod_pow_pos_of_zero_notMem_support
    intro H
    rw [Finsupp.mem_support_iff, Finsupp.mapRange_apply] at H
    exact H (by simp)
  omega

/-- `d ^ 2` divides `n` iff `d` divides the square-root part of `n`. -/
theorem dvd_sq_iff (n d : ℕ) (hn : n ≠ 0) (hd : d ≠ 0) :
    d ^ 2 ∣ n ↔ d ∣ sqrtPart n := by
  rw [← Nat.factorization_le_iff_dvd (by positivity) hn,
      ← Nat.factorization_le_iff_dvd hd (sqrtPart_ne_zero n)]
  constructor
  · intro h p
    have := h p
    rw [Nat.factorization_pow] at this
    rw [sqrtPart_fact]
    simp only [Finsupp.coe_smul, Pi.smul_apply, smul_eq_mul] at this
    omega
  · intro h p
    have := h p
    rw [sqrtPart_fact] at this
    rw [Nat.factorization_pow]
    simp only [Finsupp.coe_smul, Pi.smul_apply, smul_eq_mul]
    omega

/-- `n` is squarefree iff its square-root part is `1`. -/
theorem squarefree_iff_sqrtPart (n : ℕ) (hne : n ≠ 0) :
    Squarefree n ↔ sqrtPart n = 1 := by
  rw [Nat.squarefree_iff_factorization_le_one hne]
  constructor
  · intro h
    have hz : (sqrtPart n).factorization = 0 := by
      ext p; rw [sqrtPart_fact, Finsupp.coe_zero, Pi.zero_apply]
      have := h p; omega
    rcases (Nat.factorization_eq_zero_iff' (sqrtPart n)).mp hz with h0 | h1
    · exact absurd h0 (sqrtPart_ne_zero n)
    · exact h1
  · intro h p
    have : (sqrtPart n).factorization p = 0 := by rw [h]; simp
    rw [sqrtPart_fact] at this; omega

/-- **Selberg sieve weight identity.** For every positive integer `n`,
`μ(n) ^ 2 = ∑_{d^2 ∣ n} μ(d)`. -/
theorem selberg_sieve_weight (n : ℕ) (hn : 0 < n) :
    (moebius n) ^ 2 = ∑ d ∈ n.divisors.filter (fun d => d ^ 2 ∣ n), moebius d := by
  have hne : n ≠ 0 := hn.ne'
  have hset : n.divisors.filter (fun d => d ^ 2 ∣ n) = (sqrtPart n).divisors := by
    ext d
    simp only [Nat.mem_divisors, Finset.mem_filter]
    constructor
    · rintro ⟨⟨hd, _⟩, hd2⟩
      have hdne : d ≠ 0 := by rintro rfl; exact hne (by simpa using hd)
      exact ⟨(dvd_sq_iff n d hne hdne).mp hd2, sqrtPart_ne_zero n⟩
    · rintro ⟨hdvd, _⟩
      have hdne : d ≠ 0 := by rintro rfl; exact (sqrtPart_ne_zero n) (zero_dvd_iff.mp hdvd)
      have hd2 := (dvd_sq_iff n d hne hdne).mpr hdvd
      exact ⟨⟨dvd_trans (dvd_pow_self d (by norm_num)) hd2, hne⟩, hd2⟩
  rw [hset]
  have hsum : ∑ d ∈ (sqrtPart n).divisors, moebius d = if sqrtPart n = 1 then 1 else 0 := by
    have h2 : (moebius * (ArithmeticFunction.zeta) : ArithmeticFunction ℤ) (sqrtPart n)
        = ∑ d ∈ (sqrtPart n).divisors, moebius d := ArithmeticFunction.coe_mul_zeta_apply
    rw [← h2, ArithmeticFunction.moebius_mul_coe_zeta, ArithmeticFunction.one_apply]
  rw [hsum, ArithmeticFunction.moebius_sq]
  simp only [squarefree_iff_sqrtPart n hne]

end SelbergSieveWeight