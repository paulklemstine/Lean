/-! # CatalogBuild.Algebra.Core.ArithmeticDerivative

Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 5
-/

import Mathlib

noncomputable section

/-- The arithmetic derivative of a positive natural number, defined via
the formula n' = n · ∑(eᵢ/pᵢ) where n = ∏ pᵢ^eᵢ.
For the purpose of this formalization, we define it as the sum
n' = ∑ (n / p) * e over the prime factorization. -/
def arithmeticDerivative (n : ℕ) : ℕ :=
  if n ≤ 1 then 0
  else (n.primeFactors).sum fun p => (n / p) * (n.factorization p)


/-- The arithmetic derivative of a prime is 1. -/
theorem arithmeticDerivative_prime {p : ℕ} (hp : p.Prime) :
    arithmeticDerivative p = 1 := by
  unfold arithmeticDerivative
  simp [hp]
  rcases p with (_ | _ | p) <;> simp_all +arith +decide [Nat.div_self]


/-- Key identity: p^p / p * factorization(p^p)(p) = p^p.
This follows from p | p^p and the factorization exponent being p. -/
theorem ppow_self_div_mul_exp (p : ℕ) (hp : p.Prime) :
    p ^ p / p * (p ^ p).factorization p = p ^ p := by
  cases p <;> simp_all +decide [Nat.factorization_pow]
  rw [Nat.div_mul_cancel (dvd_pow_self _ (Nat.succ_ne_zero _))]


/-- The prime factorization of p^p has support {p}. -/
theorem primeFactors_prime_pow_self {p : ℕ} (hp : p.Prime) :
    (p ^ p).primeFactors = {p} := by
  rw [Nat.primeFactors_pow] <;> aesop


/-- p^p is a fixed point of the arithmetic derivative: (p^p)' = p^p. -/
theorem arithmeticDerivative_ppow_eq_self {p : ℕ} (hp : p.Prime) :
    arithmeticDerivative (p ^ p) = p ^ p := by
  simp +decide [hp, arithmeticDerivative]
  rcases p with (_ | _ | p) <;> simp_all +decide [Nat.primeFactors_pow]
  rw [Nat.div_mul_cancel (dvd_pow_self _ (Nat.succ_ne_zero _))]


end
