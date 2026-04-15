/-! # CatalogBuild.Shared.Sigma1

Auto-generated from theorem catalog database.
Domain: FutureResearch
Declarations: 2
-/

import Mathlib

def sigma1 (n : ℕ) : ℕ := ∑ d ∈ n.divisors, d


/-- σ₁(2^k) = 2^(k+1) - 1. -/
theorem sigma1_pow2 (k : ℕ) : sigma1 (2 ^ k) = 2 ^ (k + 1) - 1 := by
  unfold sigma1
  norm_num [Nat.geomSum_eq]

