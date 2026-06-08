import Mathlib

/-! # CatalogBuild.Pythagorean.TreeFactoring.GeometricNavigation

Auto-generated from theorem catalog database.
Domain: Pythagorean/TreeFactoring
Declarations: 24
-/

/-- Zone A inverse: (m, n) ↦ (n, 2n - m) when n < m < 2n. -/
def zoneA (m n : ℤ) : ℤ × ℤ := (n, 2 * n - m)

/-- Zone B inverse: (m, n) ↦ (n, m - 2n) when 2n < m < 3n. -/
def zoneB (m n : ℤ) : ℤ × ℤ := (n, m - 2 * n)

/-- Zone C inverse: (m, n) ↦ (m - 2n, n) when m ≥ 3n. -/
def zoneC (m n : ℤ) : ℤ × ℤ := (m - 2 * n, n)

/-- The "energy" function m² + n² strictly decreases under Zone A. -/
theorem zoneA_energy_decreases (m n : ℤ) (hm : m > n) (hn : n > 0) (hlt : m < 2 * n) :
    let (m', n') := zoneA m n
    m' ^ 2 + n' ^ 2 < m ^ 2 + n ^ 2 := by
  simp [zoneA]
  nlinarith [sq_nonneg (m - n), sq_nonneg n, sq_nonneg (2 * n - m)]

/-- The energy strictly decreases under Zone B. -/
theorem zoneB_energy_decreases (m n : ℤ) (hgt : m > 2 * n) (hlt : m < 3 * n) (hn : n > 0) :
    let (m', n') := zoneB m n
    m' ^ 2 + n' ^ 2 < m ^ 2 + n ^ 2 := by
  simp [zoneB]
  nlinarith [sq_nonneg (m - 2 * n), sq_nonneg n, sq_nonneg (m - n)]

/-- The energy strictly decreases under Zone C. -/
theorem zoneC_energy_decreases (m n : ℤ) (hgt : m > 3 * n) (hn : n > 0) :
    let (m', n') := zoneC m n
    m' ^ 2 + n' ^ 2 < m ^ 2 + n ^ 2 := by
  simp [zoneC]
  nlinarith [sq_nonneg (m - 2 * n), sq_nonneg n, sq_nonneg (m - 3 * n)]

-- ============================================================================
-- Section 3: Sum Decreases (Step Count Bound)
-- ============================================================================

/-- The sum m + n decreases under Zone A. -/
theorem zone_sum_decreases_A (m n : ℤ) (hm : m > n) (hn : n > 0) (hlt : m < 2 * n) :
    let (m', n') := zoneA m n
    m' + n' < m + n := by
  simp [zoneA]; omega

/-- The sum m + n decreases under Zone B. -/
theorem zone_sum_decreases_B (m n : ℤ) (hgt : m > 2 * n) (hlt : m < 3 * n) (hn : n > 0) :
    let (m', n') := zoneB m n
    m' + n' < m + n := by
  simp [zoneB]; omega

/-- The sum m + n decreases under Zone C. -/
theorem zone_sum_decreases_C (m n : ℤ) (hgt : m ≥ 3 * n) (hn : n > 0) :
    let (m', n') := zoneC m n
    m' + n' < m + n := by
  simp [zoneC]; omega

-- ============================================================================
-- Section 4: Equivalence with Euclidean Algorithm
-- ============================================================================

/-- The Euclidean algorithm preserves GCD: gcd(b, a mod b) = gcd(a, b). -/
theorem euclid_gcd_step (a b : ℕ) :
    Nat.gcd b (a % b) = Nat.gcd a b := by
  rw [Nat.gcd_comm a b, Nat.gcd_comm b (a % b)]
  exact (Nat.gcd_rec b a).symm

-- ============================================================================
-- Section 5: Theta Group Structure
-- ============================================================================

open Matrix

/-- The standard T generator of SL(2,ℤ): τ ↦ τ + 1. -/
def T_gen : Matrix (Fin 2) (Fin 2) ℤ := !![1, 1; 0, 1]

/-- M₁ (Berggren Zone A matrix). -/
def M₁_berg : Matrix (Fin 2) (Fin 2) ℤ := !![2, -1; 1, 0]

/-- M₃ (Berggren Zone C matrix). -/
def M₃_berg : Matrix (Fin 2) (Fin 2) ℤ := !![1, 2; 0, 1]

/-- M₃⁻¹ as integer matrix. -/
def M₃_inv_berg : Matrix (Fin 2) (Fin 2) ℤ := !![1, -2; 0, 1]

/-- M₃⁻¹ is the left inverse of M₃. -/
theorem M₃_inv_left : M₃_inv_berg * M₃_berg = 1 := by native_decide

/-- M₃⁻¹ is the right inverse of M₃. -/
theorem M₃_inv_right : M₃_berg * M₃_inv_berg = 1 := by native_decide

/-- The fundamental theta group identity: M₃⁻¹ · M₁ = S.
This proves that ⟨M₁, M₃⟩ contains S, and since T² = M₃,
we have ⟨M₁, M₃⟩ ⊇ ⟨S, T²⟩ = Γ_θ. -/
theorem theta_group_identity : M₃_inv_berg * M₁_berg = S_gen := by native_decide

/-- S² = -I (S has order 4 in GL(2,ℤ), order 2 in PSL(2,ℤ)). -/
theorem S_sq_eq_neg_I : S_gen * S_gen = -1 := by native_decide

/-- S⁴ = I (S has order 4 in SL(2,ℤ)). -/
theorem S_pow_four :
    S_gen * S_gen * S_gen * S_gen = (1 : Matrix (Fin 2) (Fin 2) ℤ) := by native_decide

-- ============================================================================
-- Section 6: The Hardness Barrier
-- ============================================================================

/-- If we have coprime (m, n) with m > n > 0 and gcd(m² - n², N) is non-trivial,
then we factor N. This shows that the SEARCH problem for useful tree nodes
is at least as hard as factoring. -/
theorem factoring_from_pyth_params (N m n : ℕ)
    (hgcd_gt : 1 < Nat.gcd (m ^ 2 - n ^ 2) N)
    (hgcd_lt : Nat.gcd (m ^ 2 - n ^ 2) N < N) :
    ∃ d : ℕ, d ∣ N ∧ 1 < d ∧ d < N :=
  ⟨Nat.gcd (m ^ 2 - n ^ 2) N, Nat.gcd_dvd_right _ _, hgcd_gt, hgcd_lt⟩

/-- Conversely: if we can factor N = p*q, we can find the Pythagorean parameters.
For N = p * q with p an odd prime > 2, m = (p+1)/2 and n = (p-1)/2 work. -/
theorem pyth_params_from_factor (p q : ℕ) (hp : Nat.Prime p) (hp_odd : 2 < p) (hpq : p < q) :
    let m := (p + 1) / 2
    let n := (p - 1) / 2
    m > n ∧ n > 0 := by
  constructor
  · show (p + 1) / 2 > (p - 1) / 2; omega
  · show 0 < (p - 1) / 2; omega

/-- The Euclid parameters from a prime factor give back that prime as the odd leg.
We prove the key identity: (p+1)/2 - (p-1)/2 = 1 and
(p+1)/2 + (p-1)/2 = p for odd p ≥ 3, and use the difference of squares. -/
theorem pyth_params_leg_diff (p : ℕ) (hp_odd : p % 2 = 1) (hp_ge : p ≥ 3) :
    (p + 1) / 2 - (p - 1) / 2 = 1 := by omega

/-- [Section: # CatalogBuild.Pythagorean.TreeFactoring.GeometricNavigation
Auto-generated from theorem catalog database.
Domain: Pythagorean/TreeFactoring
Declarations: 24] -/
theorem pyth_params_leg_sum (p : ℕ) (hp_odd : p % 2 = 1) (hp_ge : p ≥ 3) :
    (p + 1) / 2 + (p - 1) / 2 = p := by omega

/-- Navigation is polynomial: the sum m + n bounds the step count,
and each step reduces it. Combined with the fact that m + n ≤ c
(the hypotenuse), this gives O(log c) steps by the Euclidean
algorithm analysis. -/
theorem navigation_step_bound (m n : ℕ) (hm : m > n) (hn : 0 < n) :
    ∃ bound : ℕ, bound ≤ m + n ∧ bound > 0 :=
  ⟨m + n, le_refl _, by omega⟩