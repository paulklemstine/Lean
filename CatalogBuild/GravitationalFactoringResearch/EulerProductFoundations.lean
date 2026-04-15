/-! # CatalogBuild.GravitationalFactoringResearch.EulerProductFoundations

Auto-generated from theorem catalog database.
Domain: GravitationalFactoringResearch
Declarations: 7
-/

import Mathlib

noncomputable section

/-- The von Mangoldt function using Mathlib's ArithmeticFunction.vonMangoldt. -/
def vonMangoldtFn (n : ℕ) : ℝ := ArithmeticFunction.vonMangoldt n

/-- Chebyshev's ψ function: ψ(x) = Σ_{n ≤ x} Λ(n). -/

def chebyshevPsiFn (x : ℕ) : ℝ :=
  ∑ n ∈ Finset.range (x + 1), vonMangoldtFn n

/-- Λ(1) = 0. -/

theorem vonMangoldt_at_one : vonMangoldtFn 1 = 0 := by
  simp [vonMangoldtFn, ArithmeticFunction.vonMangoldt_apply_one]

/-- Λ(p) = log p for prime p. -/

theorem vonMangoldt_at_prime (p : ℕ) (hp : Nat.Prime p) :
    vonMangoldtFn p = Real.log p := by
  simp [vonMangoldtFn, ArithmeticFunction.vonMangoldt_apply_prime hp]

/-- Λ(p^k) = log p for prime p and k ≥ 1. -/

theorem vonMangoldt_at_prime_pow (p k : ℕ) (hp : Nat.Prime p) (hk : k ≠ 0) :
    vonMangoldtFn (p ^ k) = Real.log p := by
  simp [vonMangoldtFn, ArithmeticFunction.vonMangoldt_apply_pow hk,
        ArithmeticFunction.vonMangoldt_apply_prime hp]

/-- Every positive natural number has a prime factorization. -/

theorem prime_factorization_exists (n : ℕ) (hn : 0 < n) :
    ∃ ps : List ℕ, (∀ p ∈ ps, Nat.Prime p) ∧ ps.prod = n :=
  ⟨n.primeFactorsList, fun p hp => Nat.prime_of_mem_primeFactorsList hp,
    Nat.prod_primeFactorsList (by omega)⟩

/-- The sum Σ_{d|n} Λ(d) = log n (Mangoldt's identity), using Mathlib. -/

theorem vonMangoldt_sum (n : ℕ) :
    ∑ d ∈ n.divisors, vonMangoldtFn d = Real.log n := by
  simp only [vonMangoldtFn]
  exact ArithmeticFunction.vonMangoldt_sum


end
