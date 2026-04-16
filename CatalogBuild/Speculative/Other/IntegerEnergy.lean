/-! # CatalogBuild.Speculative.Other.IntegerEnergy

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 19
-/

import Mathlib

noncomputable section

/-- The abundance ratio of a prime p is (p+1)/p. -/
theorem abundanceRatio_prime {p : ℕ} (hp : p.Prime) :
    abundanceRatio p = (p + 1 : ℚ) / p := by
  simp [abundanceRatio, hp.ne_zero, sigma_one_prime hp]



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



/-- Among numbers ≤ 12, the number 12 has the most divisors. -/
theorem twelve_max_divisors_le_12 :
    ∀ m : ℕ, 0 < m → m ≤ 12 → m.divisors.card ≤ (12 : ℕ).divisors.card := by
  intro m hm hm12
  interval_cases m <;> decide



/-- The abundance ratio of 5040: σ(5040)/5040 = 19344/5040. -/
theorem abundanceRatio_5040 :
    abundanceRatio 5040 = 19344 / 5040 := by
  simp [abundanceRatio, sigma_5040]



/-- 2520 = 5040 / 2. -/
theorem two520_half_5040 : 2520 = 5040 / 2 := by norm_num



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



/-- A number with d(n) divisors provides d(n) potential divisibility witnesses. -/
theorem divisor_handles (n : ℕ) :
    ∀ d ∈ n.divisors, d ∣ n := by
  intro d hd
  exact Nat.mem_divisors.mp hd |>.1



end
