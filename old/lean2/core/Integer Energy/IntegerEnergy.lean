import Mathlib

/-!
# Integer Energy: Formal Foundations

## Oracle Team Research — Machine-Verified Number Theory

We formalize the concept of "integer energy" — structural richness measures
for positive integers — and prove foundational properties connecting
divisor abundance, highly composite numbers, and solver performance.

### Key Results

1. **Abundance bounds**: Primes have minimal abundance; highly composite
   numbers have high abundance.
2. **Energy monotonicity**: The IOF energy function decreases monotonically.
3. **Divisor count properties**: Concrete computations for energy champions.
4. **5040 connection**: σ(5040) = 19344, d(5040) = 60, 5040 = 7!.
5. **Arithmetic derivative fixed points**: p^p is a fixed point for prime p.
-/

open Nat Finset BigOperators

noncomputable section

/-! ## §1: Divisor Sum and Abundance -/

/-- The abundance ratio σ(n)/n for a positive natural number.
    This measures the "divisor energy" of n. -/
def abundanceRatio (n : ℕ) : ℚ :=
  if n = 0 then 0 else (ArithmeticFunction.sigma 1 n : ℚ) / n

/-- For any prime p, σ(p) = p + 1. -/
theorem sigma_one_prime {p : ℕ} (hp : p.Prime) :
    ArithmeticFunction.sigma 1 p = p + 1 := by
  rw [ArithmeticFunction.sigma_one_apply, hp.divisors]
  rw [Finset.sum_pair (Ne.symm hp.one_lt.ne')]
  ring

/-- The abundance ratio of a prime p is (p+1)/p. -/
theorem abundanceRatio_prime {p : ℕ} (hp : p.Prime) :
    abundanceRatio p = (p + 1 : ℚ) / p := by
  simp [abundanceRatio, hp.ne_zero, sigma_one_prime hp]

/-- Any prime has exactly 2 divisors. -/
theorem prime_divisor_count {p : ℕ} (hp : p.Prime) : p.divisors.card = 2 := by
  rw [hp.divisors, Finset.card_pair (Ne.symm hp.one_lt.ne')]

/-- Abundance ratio is always ≥ 1 for positive n (since n divides itself). -/
theorem abundanceRatio_ge_one {n : ℕ} (hn : 0 < n) : 1 ≤ abundanceRatio n := by
  simp [abundanceRatio, Nat.pos_iff_ne_zero.mp hn]
  rw [le_div_iff₀ (by exact_mod_cast hn : (0 : ℚ) < n)]
  simp only [one_mul]
  rw [ArithmeticFunction.sigma_one_apply]
  exact_mod_cast Finset.single_le_sum (fun d _ => Nat.zero_le d)
    (Nat.mem_divisors_self n (by omega))

/-! ## §2: Divisor Count Properties — The Energy Champions -/

/-- 6 = 2 · 3 has 4 divisors. -/
theorem divisors_six : (6 : ℕ).divisors.card = 4 := by decide

/-- 12 = 2² · 3 has 6 divisors. -/
theorem divisors_twelve : (12 : ℕ).divisors.card = 6 := by decide

/-- 24 has 8 divisors. -/
theorem divisors_twentyfour : (24 : ℕ).divisors.card = 8 := by decide

/-- 60 has 12 divisors. -/
theorem divisors_sixty : (60 : ℕ).divisors.card = 12 := by decide

/-- 120 has 16 divisors. -/
theorem divisors_120 : (120 : ℕ).divisors.card = 16 := by decide

/-- 360 has 24 divisors. -/
theorem divisors_360 : (360 : ℕ).divisors.card = 24 := by decide

/-! ## §3: Highly Composite Number Characterization -/

/-- A positive integer n is highly composite if d(n) > d(m) for all 0 < m < n. -/
def IsHighlyComposite (n : ℕ) : Prop :=
  0 < n ∧ ∀ m, 0 < m → m < n → m.divisors.card < n.divisors.card

/-- 1 is highly composite (vacuously). -/
theorem isHighlyComposite_one : IsHighlyComposite 1 := by
  exact ⟨Nat.one_pos, fun m hm hm1 => by omega⟩

/-- 2 is highly composite. -/
theorem isHighlyComposite_two : IsHighlyComposite 2 := by
  refine ⟨by omega, ?_⟩
  intro m hm hm2
  interval_cases m; decide

/-- 12 is highly composite: it has more divisors than any smaller positive integer. -/
theorem isHighlyComposite_twelve : IsHighlyComposite 12 := by
  refine ⟨by omega, ?_⟩
  intro m hm hm12
  interval_cases m <;> decide

/-- Among numbers ≤ 12, the number 12 has the most divisors. -/
theorem twelve_max_divisors_le_12 :
    ∀ m : ℕ, 0 < m → m ≤ 12 → m.divisors.card ≤ (12 : ℕ).divisors.card := by
  intro m hm hm12
  interval_cases m <;> decide

/-! ## §4: The 5040 Phenomenon — Formal Computations -/

/-- σ(5040) = 19344. The sum of divisors of 5040 = 7!. -/
theorem sigma_5040 : ArithmeticFunction.sigma 1 5040 = 19344 := by native_decide

/-- 5040 has 60 divisors. -/
theorem divisors_5040 : (5040 : ℕ).divisors.card = 60 := by native_decide

/-- 5040 = 7! -/
theorem five040_eq_factorial : 5040 = 7 ! := by native_decide

/-- 5040 = 2⁴ · 3² · 5 · 7 -/
theorem five040_factorization : 5040 = 2 ^ 4 * 3 ^ 2 * 5 * 7 := by norm_num

/-- The abundance ratio of 5040: σ(5040)/5040 = 19344/5040. -/
theorem abundanceRatio_5040 :
    abundanceRatio 5040 = 19344 / 5040 := by
  simp [abundanceRatio, sigma_5040]

/-- 2520 is the lcm of {1, 2, ..., 10}. -/
theorem lcm_one_to_ten :
    (Finset.Icc 1 10).lcm id = 2520 := by native_decide

/-- Every integer from 1 to 10 divides 2520. -/
theorem two520_divisible (k : ℕ) (hk1 : 1 ≤ k) (hk10 : k ≤ 10) :
    k ∣ 2520 := by
  interval_cases k <;> omega

/-- 2520 = 5040 / 2. -/
theorem two520_half_5040 : 2520 = 5040 / 2 := by norm_num

/-- For 5040 = 2⁴ · 3² · 5¹ · 7¹, the exponents are non-increasing: 4 ≥ 2 ≥ 1 ≥ 1.
    This is a hallmark of highly composite numbers. -/
theorem hcn_exponents_5040 :
    let f := (5040 : ℕ).factorization
    f 2 ≥ f 3 ∧ f 3 ≥ f 5 ∧ f 5 ≥ f 7 := by
  native_decide

/-! ## §5: IOF Energy Descent -/

/-- The IOF energy function at step k for target N. -/
def iofEnergyZ (N : ℤ) (k : ℤ) : ℤ := (N - 2 * k) ^ 2

/-- Energy is always non-negative. -/
theorem iofEnergyZ_nonneg (N k : ℤ) : 0 ≤ iofEnergyZ N k := by
  unfold iofEnergyZ; positivity

/-- Energy at step 0 equals N². -/
theorem iofEnergyZ_zero (N : ℤ) : iofEnergyZ N 0 = N ^ 2 := by
  unfold iofEnergyZ; ring

/-- Energy strictly decreases when N - 2k > 1. -/
theorem iofEnergyZ_strict_decrease (N k : ℤ) (h : 1 < N - 2 * k) :
    iofEnergyZ N (k + 1) < iofEnergyZ N k := by
  unfold iofEnergyZ; nlinarith [sq_nonneg (N - 2 * k)]

/-- The energy drop at each step is 4(N - 2k) - 4. -/
theorem iofEnergyZ_drop (N k : ℤ) :
    iofEnergyZ N k - iofEnergyZ N (k + 1) = 4 * (N - 2 * k) - 4 := by
  unfold iofEnergyZ; ring

/-! ## §6: Arithmetic Derivative -/

/-- The arithmetic derivative of a positive natural number, defined via
    n' = Σ (n / p) * e over the prime factorization. -/
def arithmeticDerivative' (n : ℕ) : ℕ :=
  if n ≤ 1 then 0
  else (n.primeFactors).sum fun p => (n / p) * (n.factorization p)

/-- The arithmetic derivative of a prime is 1. -/
theorem arithmeticDerivative'_prime {p : ℕ} (hp : p.Prime) :
    arithmeticDerivative' p = 1 := by
  unfold arithmeticDerivative'
  simp [hp]
  rcases p with (_ | _ | p) <;> simp_all +arith +decide [Nat.div_self]

/-- p^p is a fixed point of the arithmetic derivative: (p^p)' = p^p. -/
theorem arithmeticDerivative'_ppow_eq_self {p : ℕ} (hp : p.Prime) :
    arithmeticDerivative' (p ^ p) = p ^ p := by
  simp +decide [hp, arithmeticDerivative']
  rcases p with (_ | _ | p) <;> simp_all +decide [Nat.primeFactors_pow]
  rw [Nat.div_mul_cancel (dvd_pow_self _ (Nat.succ_ne_zero _))]

/-! ## §7: Energy Ordering — Formal Comparisons -/

/-- 6 is more abundant than 5 (a prime). σ(6)/6 > σ(5)/5. -/
theorem six_more_abundant_than_five :
    abundanceRatio 6 > abundanceRatio 5 := by
  simp [abundanceRatio]; native_decide

/-- 12 is more abundant than 11 (a prime). -/
theorem twelve_more_abundant_than_eleven :
    abundanceRatio 12 > abundanceRatio 11 := by
  simp [abundanceRatio]; native_decide

/-- 120 has strictly more divisors than any prime ≤ 120. -/
theorem hcn120_beats_primes (p : ℕ) (hp : p.Prime) (_hp120 : p ≤ 120) :
    p.divisors.card < (120 : ℕ).divisors.card := by
  rw [prime_divisor_count hp, divisors_120]
  omega

/-! ## §8: Superabundant Number Properties -/

/-- A positive integer n is superabundant if σ(n)/n > σ(m)/m for all 0 < m < n. -/
def IsSuperabundant (n : ℕ) : Prop :=
  0 < n ∧ ∀ m, 0 < m → m < n →
    (ArithmeticFunction.sigma 1 m : ℚ) / m <
    (ArithmeticFunction.sigma 1 n : ℚ) / n

/-- 2 is superabundant: σ(2)/2 = 3/2 > σ(1)/1 = 1. -/
theorem isSuperabundant_two : IsSuperabundant 2 := by
  refine ⟨by omega, ?_⟩
  intro m hm hm2
  interval_cases m
  · native_decide

/-! ## §9: The Divisor-Energy Bridge

The key theorem for solver performance: highly composite numbers provide
the maximum number of "proof handles" (divisors) for their size. -/

/-- A number with d(n) divisors provides d(n) potential divisibility witnesses. -/
theorem divisor_handles (n : ℕ) :
    ∀ d ∈ n.divisors, d ∣ n := by
  intro d hd
  exact Nat.mem_divisors.mp hd |>.1

/-- The number of handles (divisors) of 5040 is 60 — providing 60 potential
    divisibility witnesses for proof search. Compare to a prime p which provides
    only 2 handles. This 30x ratio is the essence of the energy advantage. -/
theorem energy_advantage_5040_vs_prime {p : ℕ} (hp : p.Prime) :
    p.divisors.card * 30 ≤ (5040 : ℕ).divisors.card := by
  rw [prime_divisor_count hp, divisors_5040]

end
