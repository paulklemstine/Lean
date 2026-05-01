/-! # CatalogBuild.Algebra.Factoring.CrossCollisionProbability

Auto-generated from theorem catalog database.
Domain: Algebra/Factoring
Declarations: 10
-/

import Mathlib

/-- Number of cross-collision pairs from two k-tuples. -/
def crossCollisionPairs (k : ℕ) : ℕ := k * k


/-- Each pair gives a GCD factor candidate. -/
theorem collision_gives_gcd_candidate (x y N : ℤ) :
    ↑(Int.gcd (x - y) N) ∣ N := Int.gcd_dvd_right _ _


/-- Two tuples sharing hypotenuse d have equal sums of squares. -/
theorem shared_hypotenuse_sum_eq {k : ℕ}
    (x y : Fin k → ℤ) (d : ℤ)
    (hx : (∑ i, (x i) ^ 2) = d ^ 2)
    (hy : (∑ i, (y i) ^ 2) = d ^ 2) :
    (∑ i, (x i) ^ 2) = (∑ i, (y i) ^ 2) := by
  rw [hx, hy]


/-- Peel channel difference from shared hypotenuse. -/
theorem shared_peel_equality {k : ℕ}
    (x y : Fin k → ℤ) (d : ℤ) (j : Fin k)
    (hx : (∑ i, (x i) ^ 2) = d ^ 2)
    (hy : (∑ i, (y i) ^ 2) = d ^ 2) :
    (d - x j) * (d + x j) - ((d - y j) * (d + y j)) =
      (y j) ^ 2 - (x j) ^ 2 := by ring


/-- Difference of squares factorization. -/
theorem cross_collision_diff_sq (x y : ℤ) :
    x ^ 2 - y ^ 2 = (x - y) * (x + y) := by ring


/-- Total unique channels from two k-tuples. -/
def totalUniqueChannels (k : ℕ) : ℕ := k + Nat.choose k 2 + k * k


/-- For k = 4 (quaternion dimension): 26 channels. -/
theorem channels_dim4 : totalUniqueChannels 4 = 26 := by
  unfold totalUniqueChannels; decide


/-- For k = 8 (octonion dimension): 100 channels. -/
theorem channels_dim8 : totalUniqueChannels 8 = 100 := by
  unfold totalUniqueChannels; decide


/-- Channel amplification: k+1 has more channels than k. -/
theorem channel_amplification (k : ℕ) (hk : 1 ≤ k) :
    totalUniqueChannels k < totalUniqueChannels (k + 1) := by
  unfold totalUniqueChannels
  have h := Nat.choose_le_choose 2 (show k ≤ k + 1 by omega)
  linarith


/-- The quadratic term k² dominates for large k. -/
theorem quadratic_dominance (k : ℕ) (hk : 2 ≤ k) :
    k ≤ k * k := by nlinarith


