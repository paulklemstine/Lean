/-! # CatalogBuild.Shared.Sigma1

Auto-generated from theorem catalog database.
Domain: FutureResearch
Declarations: 2
-/

import Mathlib

/-- [Section: # Euclid-Euler Theorem — Complete Biconditional — v10
## Main Results
* `sigma1_def` — Sum of divisors function
* `sigma1_prime` — σ₁(p) = p + 1 for prime p
* `sigma1_pow2` — σ₁(2^k) = 2^(k+1) - 1
* `euclid_perfect` — Forward: if 2^p - 1 is Mersenne prime, 2^(p-1)(2^p-1) is perfect
* `even_perfect_euler_form` — Reverse: every even perfect number has Euclid's form
* `euclid_euler_iff` — The complete biconditional
* `no_small_odd_perfect_10000` — No odd perfect number below 10000
* `perfect_number_even_ge_6` — The smallest perfect number is 6
* `perfect_6` — 6 is perfect
* `perfect_28` — 28 is perfect
* `perfect_496` — 496 is perfect] -/
def sigma1 (n : ℕ) : ℕ := ∑ d ∈ n.divisors, d


/-- σ₁(2^k) = 2^(k+1) - 1. -/
theorem sigma1_pow2 (k : ℕ) : sigma1 (2 ^ k) = 2 ^ (k + 1) - 1 := by
  unfold sigma1
  norm_num [Nat.geomSum_eq]

