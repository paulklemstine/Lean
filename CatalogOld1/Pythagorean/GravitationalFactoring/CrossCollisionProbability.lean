import Mathlib

/-!
# Cross-Collision Probability Theory

## Direction 3: Cross-collision probability analysis

We formalize the cross-collision mechanism and structural results about
factor extraction from pairs of k-tuples sharing a hypotenuse.
-/

set_option maxHeartbeats 1600000

open Finset BigOperators Nat Int

/-! ## §1. Cross-Collision Pairs -/

/-- Number of cross-collision pairs from two k-tuples. -/
def crossCollisionPairs (k : ℕ) : ℕ := k * k

/-- Each pair gives a GCD factor candidate. -/
theorem collision_gives_gcd_candidate (x y N : ℤ) :
    ↑(Int.gcd (x - y) N) ∣ N := Int.gcd_dvd_right _ _

/-- The total number of pair checks is k². -/
theorem cross_collision_pair_count (k : ℕ) :
    crossCollisionPairs k = k ^ 2 := by
  unfold crossCollisionPairs; ring

/-! ## §2. The Collision Mechanism -/

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

/-! ## §3. Factor Extraction -/

/-- If p | N and p | (xᵢ - yⱼ), then p | gcd(xᵢ - yⱼ, N). -/
theorem factor_divides_gcd (p x y N : ℤ)
    (hpN : p ∣ N) (hpxy : p ∣ (x - y)) :
    p ∣ ↑(Int.gcd (x - y) N) := Int.dvd_coe_gcd hpxy hpN

/-- GCD always divides N. -/
theorem gcd_divides_N (x y N : ℤ) :
    ↑(Int.gcd (x - y) N) ∣ N := Int.gcd_dvd_right _ _

/-- A nontrivial GCD gives a factorization. -/
theorem nontrivial_gcd_factors (g N : ℕ) (hN : 1 < N)
    (hg : g ∣ N) (hg1 : 1 < g) (hgN : g < N) :
    ∃ a b : ℕ, N = a * b ∧ 1 < a ∧ 1 < b :=
  ⟨g, N / g,
   (Nat.mul_div_cancel' hg).symm,
   hg1,
   by { have h1 := Nat.div_pos (Nat.le_of_dvd (by omega) hg) (by omega : 0 < g)
        have h2 := Nat.div_lt_self (by omega : 0 < N) hg1
        have : N / g ≠ 1 := by
          intro heq; have := Nat.div_mul_cancel hg; rw [heq] at this; simp at this; omega
        omega }⟩

/-! ## §4. Channel Count and Amplification -/

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

/-! ## §5. Quadratic Advantage -/

/-- The quadratic term k² dominates for large k. -/
theorem quadratic_dominance (k : ℕ) (hk : 2 ≤ k) :
    k ≤ k * k := by nlinarith
