/-! # CatalogBuild.Shared.Sigma1

Auto-generated from theorem catalog database.
Domain: FutureResearch
Declarations: 2
-/

import Mathlib

def sigma1 (n : ℕ) : ℕ := ∑ d ∈ n.divisors, d

/-- σ₁(p) = p + 1 for prime p. -/

theorem sigma1_pow2 (k : ℕ) : sigma1 (2 ^ k) = 2 ^ (k + 1) - 1 := by
  unfold sigma1
  norm_num [Nat.geomSum_eq]

/-! ### Euclid's Direction -/

/-
If 2^p - 1 is prime, then 2^(p-1) · (2^p - 1) is perfect.
-/
