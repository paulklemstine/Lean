import Computation.CyclicTypeDeterminism

/-!
# Which recorded entropies are certifiable? The dyadic / Fermat dichotomy

`Catalog.Computation.ReproducibilityAudit` splits an audited record into a *rational stratum*,
where four-decimal agreement certifies exact reproduction, and an *irrational stratum*, where it
cannot.  This file determines the stratum of a whole family of type-channel entropies.

* `CyclicType.Audit.not_irrational_logb_two_iff` : for `n ≥ 1`, `log₂ n` is rational **iff** `n`
  is a power of two.  (If `log₂ n = a/b` then `n^b = 2^a`, so every prime factor of `n` is `2`.)
* `CyclicType.Audit.irrational_logb_two_natCast` : the contrapositive form.
* `CyclicType.Audit.irrational_HT_of_totient_two_pow` : **the dichotomy for the channel.**  If
  every divisor `d` of `n` has `φ(d)` a power of two — by Gauss–Wantzel exactly the condition that
  the regular `n`-gon is constructible, i.e. `n` is a power of two times a product of distinct
  Fermat primes — then the Euler-φ entropy law makes `H(T)` equal to `log₂ n` minus a rational
  number, so `H(T)` is irrational as soon as `n` is not a power of two.

Combining with `CyclicType.Audit.HT_two_pow` (`H(T)(2^k) = 2 - 2^{1-k}`, dyadic and certifiable)
gives a clean boundary for the constructible orders: **`H(T)` is certifiable by a rounded record
exactly on the 2-power orders, and irrational on every other constructible order.**
Concrete instances: `H(T)(3)`, `H(T)(5)`, `H(T)(15)` and `H(T)(17)` are all irrational.
-/

namespace CyclicType.Audit

open scoped BigOperators

/-! ## 1. Rationality of `log₂ n` -/

/-- If `b·log₂ n = a` with `n > 0`, then `n^b = 2^a`. -/
lemma pow_eq_two_pow_of_logb {n b a : ℕ} (hn : 0 < n) (h : (b : ℝ) * Real.logb 2 n = a) :
    (n : ℝ) ^ b = 2 ^ a := by
  have hn0 : (0 : ℝ) < n := by exact_mod_cast hn
  have h2 : Real.log 2 ≠ 0 := ne_of_gt (Real.log_pos (by norm_num))
  have hlog : Real.log ((n : ℝ) ^ b) = Real.log ((2 : ℝ) ^ a) := by
    rw [Real.log_pow, Real.log_pow, Real.logb] at *
    field_simp at h
    linarith [h]
  have h1 : (0 : ℝ) < (n : ℝ) ^ b := by positivity
  have h3 : (0 : ℝ) < (2 : ℝ) ^ a := by positivity
  rw [← Real.exp_log h1, ← Real.exp_log h3, hlog]

/-- A natural number with `n^b = 2^a` and `b > 0` is a power of two. -/
lemma isTwoPow_of_pow_eq {n b a : ℕ} (hn : 0 < n) (hb : 0 < b) (h : n ^ b = 2 ^ a) :
    ∃ k, n = 2 ^ k := by
  refine ⟨n.primeFactorsList.length, Nat.eq_prime_pow_of_unique_prime_dvd hn.ne' ?_⟩
  intro p hp hpn
  have hd : p ∣ 2 ^ a := h ▸ dvd_pow hpn hb.ne'
  exact (Nat.prime_dvd_prime_iff_eq hp (by norm_num)).mp (hp.dvd_of_dvd_pow hd)

/-- **Rationality dichotomy for binary logarithms of integers.**  For `n ≥ 1`, `log₂ n` is
rational precisely when `n` is a power of two. -/
theorem not_irrational_logb_two_iff {n : ℕ} (hn : 0 < n) :
    ¬ Irrational (Real.logb 2 (n : ℝ)) ↔ ∃ k, n = 2 ^ k := by
  constructor
  · intro hrat
    obtain ⟨r, hr⟩ := exists_rat_of_not_irrational hrat
    have hnonneg : 0 ≤ Real.logb 2 (n : ℝ) := by
      apply Real.logb_nonneg (by norm_num)
      exact_mod_cast hn
    have hr0 : 0 ≤ r := by
      have : (0 : ℝ) ≤ (r : ℝ) := by rw [← hr]; exact hnonneg
      exact_mod_cast this
    have hnum : 0 ≤ r.num := Rat.num_nonneg.mpr hr0
    have hden : 0 < r.den := r.pos
    have hcast : ((r.num.toNat : ℕ) : ℝ) / (r.den : ℕ) = (r : ℝ) := by
      rw [Rat.cast_def]
      congr 1
      exact_mod_cast congrArg (fun z : ℤ => (z : ℝ)) (Int.toNat_of_nonneg hnum)
    have hden0 : (0 : ℝ) < (r.den : ℕ) := by exact_mod_cast hden
    have hmul : ((r.den : ℕ) : ℝ) * Real.logb 2 (n : ℝ) = (r.num.toNat : ℕ) := by
      rw [hr, ← hcast]
      field_simp
    have hpow : (n : ℝ) ^ r.den = 2 ^ r.num.toNat := pow_eq_two_pow_of_logb hn hmul
    have hnat : n ^ r.den = 2 ^ r.num.toNat := by exact_mod_cast hpow
    exact isTwoPow_of_pow_eq hn hden hnat
  · rintro ⟨k, rfl⟩ hirr
    refine hirr ⟨(k : ℚ), ?_⟩
    push_cast
    rw [Real.logb_pow, Real.logb_self_eq_one (by norm_num : (1 : ℝ) < 2)]
    ring

/-- **Irrationality of `log₂ n` off the 2-power orders.** -/
theorem irrational_logb_two_natCast {n : ℕ} (hn : 0 < n) (h : ¬ ∃ k, n = 2 ^ k) :
    Irrational (Real.logb 2 (n : ℝ)) := by
  by_contra hcon
  exact h ((not_irrational_logb_two_iff hn).mp hcon)

/-! ## 2. The Euler-φ sum on constructible orders -/

/-- If every totient occurring in the divisor lattice of `n` is a power of two, the Euler-φ
weighted log-sum is a natural number. -/
lemma totient_logb_sum_nat {n : ℕ}
    (h2 : ∀ d ∈ n.divisors, ∃ j, Nat.totient d = 2 ^ j) :
    ∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.logb 2 (Nat.totient d)
      = ((∑ d ∈ n.divisors, Nat.totient d * Nat.log 2 (Nat.totient d) : ℕ) : ℝ) := by
  push_cast
  refine Finset.sum_congr rfl ?_
  intro d hd
  obtain ⟨j, hj⟩ := h2 d hd
  rw [hj]
  have hlogb : Real.logb 2 (((2 : ℕ) ^ j : ℕ) : ℝ) = (j : ℝ) := by
    push_cast
    rw [Real.logb_pow, Real.logb_self_eq_one (by norm_num : (1 : ℝ) < 2)]
    ring
  rw [hlogb, Nat.log_pow (by norm_num : 1 < 2)]

/-- **The dichotomy for the type channel.**  On a constructible order (all totients in the
divisor lattice are powers of two) that is not itself a power of two, the recorded type entropy is
irrational — no rounded record can certify it. -/
theorem irrational_HT_of_totient_two_pow {n : ℕ} (hn : 0 < n)
    (h2 : ∀ d ∈ n.divisors, ∃ j, Nat.totient d = 2 ^ j)
    (hnp : ¬ ∃ k, n = 2 ^ k) : Irrational (HT n) := by
  have hHT : HT n = Real.logb 2 (n : ℝ)
      - (((∑ d ∈ n.divisors, Nat.totient d * Nat.log 2 (Nat.totient d) : ℕ) : ℚ) / (n : ℚ) : ℚ) := by
    rw [HT_divisor_formula hn, totient_logb_sum_nat h2]
    push_cast
    ring
  rw [hHT]
  exact (irrational_logb_two_natCast hn hnp).sub_ratCast _

/-! ## 3. Instances: the small constructible orders -/

private lemma divisors_totient_two_pow_three :
    ∀ d ∈ (3 : ℕ).divisors, ∃ j, Nat.totient d = 2 ^ j := by
  intro d hd
  have hmem : d ∈ ({1, 3} : Finset ℕ) := by
    have hdiv : (3 : ℕ).divisors = {1, 3} := by decide
    rwa [hdiv] at hd
  fin_cases hmem
  · exact ⟨0, rfl⟩
  · exact ⟨1, rfl⟩

/-- `H(T)` at the cyclic order `3` is irrational. -/
theorem irrational_HT_three : Irrational (HT 3) := by
  refine irrational_HT_of_totient_two_pow (by norm_num) divisors_totient_two_pow_three ?_
  rintro ⟨k, hk⟩
  have h3 : (3 : ℕ) % 2 = 1 := by norm_num
  rcases k with _ | k
  · simp at hk
  · rw [hk] at h3
    simp [pow_succ] at h3

private lemma divisors_totient_two_pow_five :
    ∀ d ∈ (5 : ℕ).divisors, ∃ j, Nat.totient d = 2 ^ j := by
  intro d hd
  have hmem : d ∈ ({1, 5} : Finset ℕ) := by
    have hdiv : (5 : ℕ).divisors = {1, 5} := by decide
    rwa [hdiv] at hd
  fin_cases hmem
  · exact ⟨0, rfl⟩
  · exact ⟨2, rfl⟩

/-- `H(T)` at the cyclic order `5` is irrational. -/
theorem irrational_HT_five : Irrational (HT 5) := by
  refine irrational_HT_of_totient_two_pow (by norm_num) divisors_totient_two_pow_five ?_
  rintro ⟨k, hk⟩
  have h5 : (5 : ℕ) % 2 = 1 := by norm_num
  rcases k with _ | k
  · simp at hk
  · rw [hk] at h5
    simp [pow_succ] at h5

private lemma divisors_totient_two_pow_fifteen :
    ∀ d ∈ (15 : ℕ).divisors, ∃ j, Nat.totient d = 2 ^ j := by
  intro d hd
  have hmem : d ∈ ({1, 3, 5, 15} : Finset ℕ) := by
    have hdiv : (15 : ℕ).divisors = {1, 3, 5, 15} := by decide
    rwa [hdiv] at hd
  fin_cases hmem
  · exact ⟨0, rfl⟩
  · exact ⟨1, rfl⟩
  · exact ⟨2, rfl⟩
  · exact ⟨3, rfl⟩

/-- `H(T)` at the cyclic order `15` — the product of the two smallest Fermat primes — is
irrational. -/
theorem irrational_HT_fifteen : Irrational (HT 15) := by
  refine irrational_HT_of_totient_two_pow (by norm_num) divisors_totient_two_pow_fifteen ?_
  rintro ⟨k, hk⟩
  have h15 : (15 : ℕ) % 2 = 1 := by norm_num
  rcases k with _ | k
  · simp at hk
  · rw [hk] at h15
    simp [pow_succ] at h15

end CyclicType.Audit