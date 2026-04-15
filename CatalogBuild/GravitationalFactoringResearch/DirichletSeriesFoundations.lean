/-! # CatalogBuild.GravitationalFactoringResearch.DirichletSeriesFoundations

Auto-generated from theorem catalog database.
Domain: GravitationalFactoringResearch
Declarations: 12
-/

import Mathlib

noncomputable section

/-- The Möbius function μ(n) using Mathlib's squarefree. -/
noncomputable def mobiusFn : ℕ → ℤ := fun n =>
  if n = 0 then 0
  else if n = 1 then 1
  else if ¬ Squarefree n then 0
  else if Even (n.primeFactorsList.length) then 1
  else -1

/-- μ(1) = 1. -/

theorem mobius_one : mobiusFn 1 = 1 := by
  simp [mobiusFn]

/-- μ(p) = -1 for prime p. -/

theorem mobius_prime' (p : ℕ) (hp : Nat.Prime p) : mobiusFn p = -1 := by
  simp [mobiusFn, hp.ne_one, hp.ne_zero, hp.squarefree, Nat.primeFactorsList_prime hp]

/-- Dirichlet convolution of arithmetic functions. -/

noncomputable def dirichletConv (f g : ℕ → ℤ) (n : ℕ) : ℤ :=
  ∑ d ∈ n.divisors, f d * g (n / d)

/-- The identity function for Dirichlet convolution: ε(1) = 1, ε(n) = 0 for n > 1. -/

def dirichletId : ℕ → ℤ := fun n => if n = 1 then 1 else 0

/-
Σ_{d|n} μ(d) = [n = 1] (Möbius inversion foundation).
-/

theorem mobius_sum_eq_indicator (n : ℕ) (hn : 0 < n) :
    ∑ d ∈ n.divisors, mobiusFn d = if n = 1 then 1 else 0 := by
  -- By definition of mobiusFn, we know that mobiusFn(n) = μ(n), where μ(n) is the Möbius function.
  have h_mobius_def : mobiusFn = ArithmeticFunction.moebius := by
    funext n; simp [mobiusFn, ArithmeticFunction.moebius];
    split_ifs <;> simp_all +decide [ ArithmeticFunction.cardFactors ];
  -- By definition of Dirichlet convolution, we know that $(\mu * 1)(n) = \sum_{d \mid n} \mu(d)$.
  have h_dirichlet_conv : (ArithmeticFunction.moebius * ArithmeticFunction.zeta) n = ∑ d ∈ n.divisors, ArithmeticFunction.moebius d := by
    exact ArithmeticFunction.coe_mul_zeta_apply;
  aesop

/-- The prime-counting function π(x). -/

def primeCountFn (x : ℕ) : ℕ :=
  ((Finset.Icc 2 x).filter Nat.Prime).card

/-- π(10) = 4: the primes up to 10 are 2, 3, 5, 7. -/

theorem prime_counting_10' : primeCountFn 10 = 4 := by
  native_decide

/-- An arithmetic function f is completely multiplicative if f(mn) = f(m)f(n) for all m, n. -/

def liouvilleFn (n : ℕ) : ℤ :=
  if n = 0 then 0
  else (-1) ^ n.primeFactorsList.length

/-- λ(1) = 1. -/

theorem liouville_one : liouvilleFn 1 = 1 := by
  simp [liouvilleFn]

/-- λ(p) = -1 for prime p. -/

theorem liouville_prime' (p : ℕ) (hp : Nat.Prime p) : liouvilleFn p = -1 := by
  simp [liouvilleFn, hp.ne_zero, Nat.primeFactorsList_prime hp]

/-
The Liouville function is completely multiplicative.
-/

theorem liouville_completely_multiplicative :
    IsCompletelyMultiplicative liouvilleFn := by
  constructor;
  · exact liouville_one;
  · intro m n; by_cases hm : m = 0 <;> by_cases hn : n = 0 <;> simp +decide [ *, liouvilleFn ] ; ring;
    -- Since $m$ and $n$ are not zero, their prime factors lists are non-empty and their lengths are well-defined.
    have h_prime_factors : (m * n).primeFactorsList.Perm (m.primeFactorsList ++ n.primeFactorsList) := by
      exact perm_primeFactorsList_mul hm hn;
    rw [ ← pow_add, h_prime_factors.length_eq, List.length_append ]

end
