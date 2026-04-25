/-! # CatalogBuild.Algebra.IntegerEnergy.RiemannConnection

Auto-generated from theorem catalog database.
Domain: Algebra/IntegerEnergy
Declarations: 36
-/

import Mathlib

noncomputable section

/-- Robin's inequality as a proposition. This is equivalent to the
Riemann Hypothesis by Robin's theorem (1984). -/
def RobinInequality : Prop :=
  ∀ n : ℕ, n ≥ 5041 →
    (ArithmeticFunction.sigma 1 n : ℝ) <
    Real.exp Real.eulerMascheroniConstant * n * Real.log (Real.log n)





/-- The Robin ratio R(n) = σ(n) / (e^γ · n · ln(ln(n))). RH ⟺ R(n) < 1 for n ≥ 5041. -/
def robinRatio (n : ℕ) : ℝ :=
  if n ≤ 2 then 0
  else (ArithmeticFunction.sigma 1 n : ℝ) /
       (Real.exp Real.eulerMascheroniConstant * n * Real.log (Real.log n))





/-- σ(5040) = 19344. -/
theorem sigma_5040 : ArithmeticFunction.sigma 1 5040 = 19344 := by native_decide





/-- d(5040) = 60 (5040 has 60 divisors). -/
theorem divisors_5040 : (5040 : ℕ).divisors.card = 60 := by native_decide





/-- 5040 = 7! -/
theorem five040_eq_factorial : 5040 = 7 ! := by native_decide





/-- 5040 = 2⁴ · 3² · 5 · 7 -/
theorem five040_factorization : 5040 = 2 ^ 4 * 3 ^ 2 * 5 * 7 := by norm_num





/-- The factorization exponents of 5040 are non-increasing: 4 ≥ 2 ≥ 1 ≥ 1.
This is the hallmark of highly composite numbers (Ramanujan, 1915). -/
theorem hcn_exponents_5040 :
    let f := (5040 : ℕ).factorization
    f 2 ≥ f 3 ∧ f 3 ≥ f 5 ∧ f 5 ≥ f 7 := by native_decide





/-- σ(10080) = 39312. -/
theorem sigma_10080 : ArithmeticFunction.sigma 1 10080 = 39312 := by native_decide





/-- d(10080) = 72. -/
theorem divisors_10080 : (10080 : ℕ).divisors.card = 72 := by native_decide





/-- σ(2520) = 9360. -/
theorem sigma_2520 : ArithmeticFunction.sigma 1 2520 = 9360 := by native_decide





/-- d(2520) = 48. -/
theorem divisors_2520 : (2520 : ℕ).divisors.card = 48 := by native_decide





/-- For any prime p, σ(p) = p + 1 (the only divisors are 1 and p). -/
theorem sigma_one_prime {p : ℕ} (hp : p.Prime) :
    ArithmeticFunction.sigma 1 p = p + 1 := by
  rw [ArithmeticFunction.sigma_one_apply, hp.divisors]
  rw [Finset.sum_pair (Ne.symm hp.one_lt.ne')]
  ring





/-- Any prime has exactly 2 divisors. -/
theorem prime_divisor_count {p : ℕ} (hp : p.Prime) : p.divisors.card = 2 := by
  rw [hp.divisors, Finset.card_pair (Ne.symm hp.one_lt.ne')]





/-- The abundance ratio σ(n)/n for a positive natural number. -/
def abundanceRatio (n : ℕ) : ℚ :=
  if n = 0 then 0 else (ArithmeticFunction.sigma 1 n : ℚ) / n





/-- Abundance ratio is always ≥ 1 for positive n (since n divides itself). -/
theorem abundanceRatio_ge_one {n : ℕ} (hn : 0 < n) : 1 ≤ abundanceRatio n := by
  simp [abundanceRatio, Nat.pos_iff_ne_zero.mp hn]
  rw [le_div_iff₀ (by exact_mod_cast hn : (0 : ℚ) < n)]
  simp only [one_mul]
  rw [ArithmeticFunction.sigma_one_apply]
  exact_mod_cast Finset.single_le_sum (fun d _ => Nat.zero_le d)
    (Nat.mem_divisors_self n (by omega))





/-- σ is multiplicative: σ(n·m) = σ(n)·σ(m) when gcd(n,m) = 1. -/
theorem sigma_multiplicative :
    ArithmeticFunction.IsMultiplicative (ArithmeticFunction.sigma 1) :=
  ArithmeticFunction.isMultiplicative_sigma





/-- A positive integer n is highly composite if d(n) > d(m) for all 0 < m < n. -/
def IsHighlyComposite (n : ℕ) : Prop :=
  0 < n ∧ ∀ m, 0 < m → m < n → m.divisors.card < n.divisors.card





/-- 1 is highly composite. -/
theorem isHighlyComposite_one : IsHighlyComposite 1 :=
  ⟨Nat.one_pos, fun m hm hm1 => by omega⟩





/-- 2 is highly composite. -/
theorem isHighlyComposite_two : IsHighlyComposite 2 := by
  refine ⟨by omega, ?_⟩; intro m hm hm2; interval_cases m; decide





/-- 12 is highly composite: it has more divisors than any smaller positive integer. -/
theorem isHighlyComposite_twelve : IsHighlyComposite 12 := by
  refine ⟨by omega, ?_⟩; intro m hm hm12; interval_cases m <;> decide





/-- 2 is superabundant. -/
theorem isSuperabundant_two : IsSuperabundant 2 := by
  refine ⟨by omega, ?_⟩; intro m hm hm2; interval_cases m; native_decide





/-- 5040 has exactly 30 times as many divisors as any prime. -/
theorem energy_advantage_5040_vs_prime {p : ℕ} (hp : p.Prime) :
    p.divisors.card * 30 ≤ (5040 : ℕ).divisors.card := by
  rw [prime_divisor_count hp, divisors_5040]





/-- 120 has strictly more divisors than any prime. -/
theorem hcn120_beats_primes (p : ℕ) (hp : p.Prime) :
    p.divisors.card < (120 : ℕ).divisors.card := by
  have h1 : p.divisors.card = 2 := prime_divisor_count hp
  have h2 : (120 : ℕ).divisors.card = 16 := by native_decide
  omega





/-- 6 is more abundant than 5 (a prime). -/
theorem six_more_abundant_than_five :
    abundanceRatio 6 > abundanceRatio 5 := by
  unfold abundanceRatio; native_decide





/-- 12 is more abundant than 11 (a prime). -/
theorem twelve_more_abundant_than_eleven :
    abundanceRatio 12 > abundanceRatio 11 := by
  unfold abundanceRatio; native_decide





/-- 5040 is more abundant than 5039 (a prime). -/
theorem five040_more_abundant_than_5039 :
    abundanceRatio 5040 > abundanceRatio 5039 := by
  unfold abundanceRatio; native_decide





/-- 5039 is prime. -/
theorem prime_5039 : Nat.Prime 5039 := by native_decide





/-- σ(5039) = 5040. Since 5039 is prime, σ(5039) = 5039 + 1 = 5040. -/
theorem sigma_5039 : ArithmeticFunction.sigma 1 5039 = 5040 := by native_decide





/-- 5041 = 71² (not prime). -/
theorem five041_eq : 5041 = 71 ^ 2 := by norm_num





/-- σ(5041) = 5113 = 1 + 71 + 5041. -/
theorem sigma_5041 : ArithmeticFunction.sigma 1 5041 = 5113 := by native_decide





/-- σ(7560) = 28800. The superabundant number just above 5040. -/
theorem sigma_7560 : ArithmeticFunction.sigma 1 7560 = 28800 := by native_decide





/-- The LCM of 1 through 10 is 2520. -/
theorem lcm_one_to_ten :
    (Finset.Icc 1 10).lcm id = 2520 := by native_decide





/-- Every integer from 1 to 7 divides 5040 (because 5040 = 7!). -/
theorem five040_divisible (k : ℕ) (hk1 : 1 ≤ k) (hk7 : k ≤ 7) :
    k ∣ 5040 := by
  interval_cases k <;> omega





/-- Every integer from 1 to 10 divides 2520. -/
theorem two520_divisible (k : ℕ) (hk1 : 1 ≤ k) (hk10 : k ≤ 10) :
    k ∣ 2520 := by
  interval_cases k <;> omega





/-- Under Robin's inequality, the abundance ratio of any n ≥ 5041
is bounded by e^γ · ln(ln(n)). -/
theorem robin_abundance_bound (hRobin : RobinInequality) (n : ℕ) (hn : n ≥ 5041) :
    (ArithmeticFunction.sigma 1 n : ℝ) / n <
    Real.exp Real.eulerMascheroniConstant * Real.log (Real.log n) := by
  have hn_pos : (0 : ℝ) < n := by positivity
  rw [div_lt_iff₀ hn_pos]
  have h := hRobin n hn
  linarith





/-- The number of divisors of n is at least 1 for positive n. -/
theorem divisor_count_pos {n : ℕ} (hn : 0 < n) : 0 < n.divisors.card := by
  rw [Finset.card_pos]
  exact ⟨1, Nat.mem_divisors.mpr ⟨one_dvd n, by omega⟩⟩





end
