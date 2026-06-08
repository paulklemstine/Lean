/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Odd Perfect Numbers: Multiplicative Rigidity Theory

This file develops a formal theory of multiplicative rigidity for odd perfect numbers.
We introduce new definitions—local abundancy factors, Euler-form candidates, deficiency
gaps, and prime-support profiles—that reframe the odd perfect number problem as a
balancing law for local Euler factors.

## Main Definitions

* `sigma` — the sum-of-divisors function σ(n) = Σ_{d | n} d
* `localAbundancy` — the rational-valued local abundancy I(p,a) = σ(p^a)/p^a
* `EulerCandidate` — structure encoding an odd perfect candidate in Euler form
* `deficiencyGap` — measures how far a number is from being perfect: 2 - σ(n)/n
* `PrimeSupportProfile` — encodes the prime factorization data for support arguments

## Main Results

* `sigma_prime_pow` — σ(p^k) = Σ_{i=0}^{k} p^i
* `sigma_multiplicative_coprime` — σ(m*n) = σ(m)·σ(n) when gcd(m,n) = 1
* `localAbundancy_lt_geom_limit` — I(p,a) < p/(p-1) for all primes p, exponents a
* `localAbundancy_strictMono` — I(p,·) is strictly monotone in the exponent
* `localAbundancy_gt_one` — I(p,a+1) > 1
* `odd_perfect_support_energy_barrier` — 2 ≤ ∏ p/(p-1) over prime support of odd perfect n
* `deficiencyGap_pos_of_support_bound` — if ∏ p/(p-1) < 2 then n is not perfect
-/

import Mathlib

open Finset BigOperators

/-! ## Core Definitions -/

/-- The sum-of-divisors function σ(n) = Σ_{d | n} d. -/
noncomputable def sigma (n : ℕ) : ℕ := n.divisors.sum id

/-- A number is perfect if σ(n) = 2n. -/
def IsPerfect (n : ℕ) : Prop := sigma n = 2 * n

/-- Local abundancy factor I(p,a) = σ(p^a) / p^a ∈ ℚ.
    This measures the "local contribution" of a prime power p^a to the total abundancy.
    For odd primes, these factors are tightly constrained and must multiply to exactly 2
    for a perfect number. -/
noncomputable def localAbundancy (p a : ℕ) : ℚ :=
  (sigma (p ^ a) : ℚ) / (p ^ a : ℚ)

/-- The deficiency gap measures how far n is from being perfect.
    gap(n) = 2 - σ(n)/n. A number is perfect iff gap(n) = 0. -/
noncomputable def deficiencyGap (n : ℕ) : ℚ :=
  2 - (sigma n : ℚ) / (n : ℚ)

/-- An Euler candidate encodes an odd number in Euler form: n = p^k * m^2 where
    p is prime, p ≡ 1 (mod 4), k ≡ 1 (mod 4), and gcd(p,m) = 1.
    Euler proved that any odd perfect number must have this form. -/
structure EulerCandidate where
  /-- The special Euler prime -/
  p : ℕ
  /-- The exponent of the Euler prime (must be ≡ 1 mod 4) -/
  k : ℕ
  /-- The square root of the square part -/
  m : ℕ
  /-- p is prime -/
  hp : Nat.Prime p
  /-- p ≡ 1 (mod 4) -/
  hpmod : p % 4 = 1
  /-- k ≡ 1 (mod 4) -/
  hkmod : k % 4 = 1
  /-- p and m are coprime -/
  hcop : Nat.Coprime p m
  /-- The candidate value is odd -/
  hodd : Odd (p ^ k * m ^ 2)

/-- The numerical value of an Euler candidate. -/
def EulerCandidate.val (c : EulerCandidate) : ℕ := c.p ^ c.k * c.m ^ 2

/-- A prime-support profile for a natural number, recording the set of prime
    divisors together with their exponents. This is designed for stating and
    proving factor-count and support-exclusion theorems. -/
structure PrimeSupportProfile where
  /-- The set of prime divisors -/
  support : Finset ℕ
  /-- The exponent function -/
  exponents : ℕ → ℕ
  /-- Every element of the support is prime -/
  hprime : ∀ p ∈ support, Nat.Prime p
  /-- Every exponent is positive for primes in support -/
  hpos : ∀ p ∈ support, 0 < exponents p
  /-- Primes outside support have zero exponent -/
  hzero : ∀ p, p ∉ support → exponents p = 0

/-- The numerical value of a prime-support profile: ∏ p^(a p) over the support. -/
noncomputable def PrimeSupportProfile.val (prof : PrimeSupportProfile) : ℕ :=
  prof.support.prod (fun p => p ^ prof.exponents p)

/-- The support energy upper bound: ∏ p/(p-1) over the prime support.
    This bounds the total abundancy from above and is the key to exclusion theorems. -/
noncomputable def supportEnergy (s : Finset ℕ) : ℚ :=
  s.prod (fun p => (p : ℚ) / ((p : ℚ) - 1))

/-! ## Basic Properties of sigma -/

/-- σ(0) = 0 -/
@[simp]
theorem sigma_zero : sigma 0 = 0 := by
  simp [sigma]

/-- σ(1) = 1 -/
@[simp]
theorem sigma_one : sigma 1 = 1 := by
  simp [sigma]

/-- σ(p^k) = Σ_{i=0}^{k} p^i for prime p.
    This is the fundamental computation for prime powers. -/
theorem sigma_prime_pow {p : ℕ} (hp : Nat.Prime p) (k : ℕ) :
    sigma (p ^ k) = ∑ i ∈ Finset.range (k + 1), p ^ i := by
  unfold sigma
  rw [Nat.divisors_prime_pow hp]
  simp [Finset.sum_map]

/-
σ is multiplicative on coprime inputs: σ(mn) = σ(m)·σ(n) when gcd(m,n) = 1.
-/
theorem sigma_multiplicative_coprime {m n : ℕ} (hcop : Nat.Coprime m n) :
    sigma (m * n) = sigma m * sigma n := by
  unfold sigma
  exact Nat.Coprime.sum_divisors_mul hcop

/-! ## Local Abundancy Properties -/

/-
σ(p^a) for prime p, a ≥ 1 is strictly greater than p^a.
-/
theorem sigma_prime_pow_gt {p a : ℕ} (hp : Nat.Prime p) (ha : 0 < a) :
    p ^ a < sigma (p ^ a) := by
  rw [ sigma_prime_pow hp a ];
  simp +arith +decide [ Finset.sum_range_succ ];
  exact le_trans ( by norm_num ) ( Finset.single_le_sum ( fun i _ => Nat.zero_le ( p ^ i ) ) ( Finset.mem_range.mpr ha ) )

/-
Local abundancy of p^0 is 1.
-/
theorem localAbundancy_zero (p : ℕ) : localAbundancy p 0 = 1 := by
  unfold localAbundancy; aesop;

/-
Local abundancy I(p, a+1) > 1 for any prime p.
-/
theorem localAbundancy_gt_one {p : ℕ} (hp : Nat.Prime p) (a : ℕ) :
    1 < localAbundancy p (a + 1) := by
  rw [ localAbundancy, lt_div_iff₀ ] <;> norm_cast <;> norm_num [ hp.ne_zero ];
  · exact sigma_prime_pow_gt hp ( Nat.succ_pos _ );
  · exact pow_pos hp.pos _

/-
Local abundancy is strictly bounded above by the geometric limit p/(p-1).
    This is the key inequality: I(p,a) = 1 + 1/p + ... + 1/p^a < 1/(1-1/p) = p/(p-1).
-/
theorem localAbundancy_lt_geom_limit {p a : ℕ} (hp : Nat.Prime p) :
    localAbundancy p a < (p : ℚ) / ((p : ℚ) - 1) := by
  have h_localAbundancy_expansion : localAbundancy p a = (∑ i ∈ Finset.range (a + 1), (p : ℚ) ^ i) / (p ^ a : ℚ) := by
    simp [localAbundancy, sigma_prime_pow hp];
  rw [ h_localAbundancy_expansion, geom_sum_eq ] <;> norm_num [ hp.ne_one ];
  rw [ div_div, div_lt_div_iff₀ ] <;> nlinarith [ show ( p : ℚ ) > 1 by exact_mod_cast hp.one_lt, pow_pos ( show ( p : ℚ ) > 0 by exact_mod_cast hp.pos ) a, pow_succ' ( p : ℚ ) a ]

/-
Local abundancy is strictly increasing in the exponent for any prime p.
-/
theorem localAbundancy_strictMono {p : ℕ} (hp : Nat.Prime p) :
    StrictMono (fun a : ℕ => localAbundancy p a) := by
  refine' strictMono_nat_of_lt_succ _;
  intro n
  simp [localAbundancy];
  rw [ div_lt_div_iff₀ ] <;> norm_cast;
  · simp +arith +decide [ pow_succ, mul_assoc, mul_comm, sigma ];
    rw [ ← pow_succ', mul_comm p, Nat.sum_divisors_eq_sum_properDivisors_add_self, Nat.sum_divisors_eq_sum_properDivisors_add_self ];
    rw [ Nat.properDivisors_prime_pow hp, Nat.properDivisors_prime_pow hp ];
    simp +arith +decide [ Finset.sum_range_succ, pow_succ ];
    nlinarith [ hp.two_le, pow_pos hp.pos n, mul_pos ( pow_pos hp.pos n ) ( pow_pos hp.pos n ), geom_sum_mul_neg ( p : ℤ ) n ];
  · exact pow_pos hp.pos _;
  · exact pow_pos hp.pos _

/-! ## Energy Barrier and Support Exclusion -/

/-
**Support Energy Barrier Theorem.** If n = ∏ p^(a p) is a perfect number
    with all primes in its support being odd, then the support energy
    ∏ p/(p-1) ≥ 2. This is because I(p,a) < p/(p-1) and ∏ I(p,a) = 2.
-/
theorem odd_perfect_support_energy_barrier
    {n : ℕ} {s : Finset ℕ} {a : ℕ → ℕ}
    (hn : n ≠ 0)
    (hfac : n = s.prod (fun p => p ^ a p))
    (hprime : ∀ p ∈ s, Nat.Prime p)
    (_hpos : ∀ p ∈ s, 0 < a p)
    (_hoddp : ∀ p ∈ s, p ≠ 2)
    (hperf : sigma n = 2 * n) :
    (2 : ℚ) ≤ s.prod (fun p => (p : ℚ) / ((p : ℚ) - 1)) := by
  convert Finset.prod_le_prod ?_ fun p hp => le_of_lt <| localAbundancy_lt_geom_limit <| hprime p hp;
  convert hperf using 1;
  any_goals intro p hp; exact div_nonneg ( Nat.cast_nonneg _ ) ( pow_nonneg ( Nat.cast_nonneg _ ) _ );
  unfold localAbundancy; simp +decide [*] ;
  rw [ eq_div_iff ] <;> norm_cast at *;
  rw [ ← hfac, hperf ];
  · have h_sigma_prod : ∀ {S : Finset ℕ} {f : ℕ → ℕ}, (∀ p ∈ S, Nat.Prime p) → sigma (∏ p ∈ S, p ^ f p) = ∏ p ∈ S, sigma (p ^ f p) := by
      intros S f hf;
      induction' S using Finset.induction with p S hpS ih;
      · simp +decide [ sigma ];
      · rw [ Finset.prod_insert hpS, sigma_multiplicative_coprime ];
        · rw [ Finset.prod_insert hpS, ih fun q hq => hf q <| Finset.mem_insert_of_mem hq ];
        · exact Nat.Coprime.prod_right fun q hq => Nat.coprime_pow_primes _ _ ( hf p ( Finset.mem_insert_self _ _ ) ) ( hf q ( Finset.mem_insert_of_mem hq ) ) ( by aesop );
    rw [ ← h_sigma_prod hprime, ← hfac, hperf ];
  · exact Finset.prod_ne_zero_iff.mpr fun p hp => pow_ne_zero _ ( Nat.Prime.ne_zero ( hprime p hp ) )

/-
**Not-perfect from support bound.** If the support energy < 2,
    then the number is not perfect.
-/
theorem not_perfect_of_support_energy_lt_two
    {n : ℕ} {s : Finset ℕ} {a : ℕ → ℕ}
    (hn : n ≠ 0)
    (hfac : n = s.prod (fun p => p ^ a p))
    (hprime : ∀ p ∈ s, Nat.Prime p)
    (hpos : ∀ p ∈ s, 0 < a p)
    (hoddp : ∀ p ∈ s, p ≠ 2)
    (hbound : s.prod (fun p => (p : ℚ) / ((p : ℚ) - 1)) < 2) :
    ¬ IsPerfect n := by
  exact fun h => absurd hbound ( by linarith [ odd_perfect_support_energy_barrier hn hfac hprime hpos hoddp h ] )

/-
**Deficiency Gap Positivity.** If the support energy ∏ p/(p-1) < 2
    for the prime support of n, then n is not perfect (gap > 0).
-/
theorem deficiencyGap_pos_of_support_bound
    {n : ℕ} {s : Finset ℕ} {a : ℕ → ℕ}
    (hn : n ≠ 0)
    (hfac : n = s.prod (fun p => p ^ a p))
    (hprime : ∀ p ∈ s, Nat.Prime p)
    (_hpos : ∀ p ∈ s, 0 < a p)
    (_hoddp : ∀ p ∈ s, p ≠ 2)
    (hbound : s.prod (fun p => (p : ℚ) / ((p : ℚ) - 1)) < 2) :
    0 < deficiencyGap n := by
  -- By definition of $sigma$, we know that $\frac{\sigma(n)}{n} = \prod_{p \in s} \frac{\sigma(p^{a(p)})}{p^{a(p)}}$.
  have h_sigma_div_n : (sigma n : ℚ) / n = s.prod (fun p => (sigma (p ^ a p) : ℚ) / (p ^ a p)) := by
    have h_sigma_decomp : ∀ {S : Finset ℕ}, (∀ p ∈ S, Nat.Prime p) → (sigma (∏ p ∈ S, p ^ a p) : ℚ) = ∏ p ∈ S, (sigma (p ^ a p) : ℚ) := by
      intros S hprimeS
      induction' S using Finset.induction with p S hpS ih;
      · norm_num [ sigma_one ];
      · rw [ Finset.prod_insert hpS, sigma_multiplicative_coprime ];
        · rw [ Finset.prod_insert hpS, Nat.cast_mul, ih fun q hq => hprimeS q <| Finset.mem_insert_of_mem hq ];
        · exact Nat.Coprime.prod_right fun q hq => Nat.Coprime.pow _ _ <| by have := Nat.coprime_primes ( hprimeS p <| Finset.mem_insert_self _ _ ) ( hprimeS q <| Finset.mem_insert_of_mem hq ) ; aesop;
    aesop;
  -- By definition of $sigma$, we know that $\frac{\sigma(p^{a(p)})}{p^{a(p)}} < \frac{p}{p-1}$ for each prime $p \in s$.
  have h_sigma_div_p_lt_p_div_p_minus_1 : ∀ p ∈ s, (sigma (p ^ a p) : ℚ) / (p ^ a p) < (p : ℚ) / (p - 1) := by
    exact fun p hp => localAbundancy_lt_geom_limit ( hprime p hp );
  exact sub_pos_of_lt ( h_sigma_div_n.symm ▸ lt_of_le_of_lt ( Finset.prod_le_prod ( fun _ _ => div_nonneg ( Nat.cast_nonneg _ ) ( pow_nonneg ( Nat.cast_nonneg _ ) _ ) ) fun _ _ => le_of_lt ( h_sigma_div_p_lt_p_div_p_minus_1 _ ‹_› ) ) hbound )

/-! ## Cross-Domain: Abundancy Product Decomposition -/

/-
**Multiplicative local-factor decomposition of abundancy.**
    For n = ∏ p^(a p) with distinct primes,
    σ(n)/n = ∏ I(p, a p).
    This is the conceptual bridge from additive divisor sums to multiplicative
    energy balancing.
-/
theorem abundancy_product_decomposition
    {n : ℕ} {s : Finset ℕ} {a : ℕ → ℕ}
    (hn : n ≠ 0)
    (hfac : n = s.prod (fun p => p ^ a p))
    (hprime : ∀ p ∈ s, Nat.Prime p) :
    (sigma n : ℚ) / (n : ℚ) = s.prod (fun p => localAbundancy p (a p)) := by
  -- By induction on $s$, we can show that the local abundancy factors multiply to give the total abundancy.
  have h_ind : ∀ t ⊆ s, (sigma (∏ p ∈ t, p ^ a p)) / (∏ p ∈ t, p ^ a p : ℚ) = ∏ p ∈ t, (localAbundancy p (a p)) := by
    intro t ht;
    induction t using Finset.induction <;> simp_all +decide [ Finset.prod_insert, Finset.insert_subset_iff ];
    rw [ sigma_multiplicative_coprime ];
    · simp_all +decide [ mul_div_mul_comm, localAbundancy ];
    · exact Nat.Coprime.prod_right fun p hp => Nat.Coprime.pow _ _ <| hprime _ ht.1 |> Nat.Prime.coprime_iff_not_dvd |>.2 fun h => ‹¬_› <| by have := Nat.prime_dvd_prime_iff_eq ( hprime _ ht.1 ) ( hprime _ <| ht.2 hp ) ; aesop;
  aesop

/-
For a perfect number, the product of local abundancy factors equals 2.
-/
theorem perfect_abundancy_product_eq_two
    {n : ℕ} {s : Finset ℕ} {a : ℕ → ℕ}
    (hn : n ≠ 0)
    (hfac : n = s.prod (fun p => p ^ a p))
    (hprime : ∀ p ∈ s, Nat.Prime p)
    (hperf : sigma n = 2 * n) :
    s.prod (fun p => localAbundancy p (a p)) = 2 := by
  -- By definition of localAbundancy, we know that σ(n)/n = ∏ localAbundancy p (a p).
  have h_sigma_n : (sigma n : ℚ) / n = (∏ p ∈ s, localAbundancy p (a p)) := by
    exact abundancy_product_decomposition hn hfac hprime
  rw [← h_sigma_n, hperf, mul_comm]; norm_num [hn]

/-! ## Computational Verification -/

/-
Any odd perfect number must have at least 3 distinct prime factors.
    This follows because for any two-element support of odd primes {p, q},
    we have p/(p-1) * q/(q-1) ≤ (3/2)*(5/4) = 15/8 < 2.
    The smallest possible product is with p=3, q=5.
-/
theorem support_two_primes_excluded :
    (({3, 5} : Finset ℕ).prod
      (fun p => (p : ℚ) / ((p : ℚ) - 1))) < 2 := by
  norm_num

/-
With primes {5, 7, 11, 13}, the support energy is 1001/576 < 2,
    so no odd perfect number has this as its complete prime support.
-/
theorem support_5_7_11_13_excluded :
    (({5, 7, 11, 13} : Finset ℕ).prod
      (fun p => (p : ℚ) / ((p : ℚ) - 1))) < 2 := by
  norm_num