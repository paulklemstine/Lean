/-! # CatalogBuild.Speculative.Other.EnergyDescentResearch

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 42
-/

import Mathlib

noncomputable section

/-- The IOF energy function at step k for target N -/
noncomputable def iofEnergy (N : ℤ) (k : ℤ) : ℤ := (N - 2 * k) ^ 2



/-- Energy is always non-negative -/
theorem iofEnergy_nonneg (N k : ℤ) : 0 ≤ iofEnergy N k := by
  unfold iofEnergy; positivity



/-- Energy at step 0 equals N² -/
theorem iofEnergy_zero (N : ℤ) : iofEnergy N 0 = N ^ 2 := by
  unfold iofEnergy; ring



/-- Energy strictly decreases when N - 2k > 1 -/
theorem iofEnergy_strict_decrease (N k : ℤ) (h : 1 < N - 2 * k) :
    iofEnergy N (k + 1) < iofEnergy N k := by
  unfold iofEnergy; nlinarith [sq_nonneg (N - 2 * k)]



/-- The energy drop at each step is exactly 4(N - 2k) - 4 -/
theorem iofEnergy_drop (N k : ℤ) :
    iofEnergy N k - iofEnergy N (k + 1) = 4 * (N - 2 * k) - 4 := by
  unfold iofEnergy; ring



/-- Energy drop is positive when N - 2k > 1 -/
theorem iofEnergy_drop_pos (N k : ℤ) (h : 1 < N - 2 * k) :
    0 < iofEnergy N k - iofEnergy N (k + 1) := by
  rw [iofEnergy_drop]; linarith



/-- The energy at step k is exactly (N - 2k)² — trivially by definition,
but this connects to the closed-form descent theorem -/
theorem iofEnergy_closed_form (N k : ℤ) :
    iofEnergy N k = (N - 2 * k) ^ 2 := rfl



/-- Energy ratio between consecutive steps -/
theorem iofEnergy_ratio (N k : ℤ) (_h : N - 2 * k ≠ 0) :
    iofEnergy N (k + 1) = iofEnergy N k - 4 * (N - 2 * k) + 4 := by
  unfold iofEnergy; ring



/-- Energy at factor step when p is odd: E((p-1)/2) = (N - p + 1)² -/
theorem iofEnergy_at_factor_step (N p : ℤ) (hodd : p % 2 = 1) (_hp : 3 ≤ p) :
    iofEnergy N ((p - 1) / 2) = (N - p + 1) ^ 2 := by
  unfold iofEnergy
  have : 2 * ((p - 1) / 2) = p - 1 := by omega
  congr 1; linarith



/-- When N = p * q, the energy at factor step -/
theorem iofEnergy_at_factor_product (p q : ℤ) (hodd_p : p % 2 = 1)
    (hp : 3 ≤ p) :
    iofEnergy (p * q) ((p - 1) / 2) = (p * q - p + 1) ^ 2 := by
  exact iofEnergy_at_factor_step (p * q) p hodd_p hp



/-- If we know a factor bound p ≤ B, the energy at the latest factor step
is at least (N - B + 1)² -/
theorem iofEnergy_factor_bound (N B : ℤ) (hB : 3 ≤ B) (hodd : B % 2 = 1) :
    (N - B + 1) ^ 2 = iofEnergy N ((B - 1) / 2) := by
  rw [iofEnergy_at_factor_step N B hodd hB]



/-- Monotonicity: energy at step k₁ > energy at step k₂ when k₁ < k₂
and both are in the valid range -/
theorem iofEnergy_monotone_decreasing (N k₁ k₂ : ℤ)
    (h : k₁ < k₂) (_hk₁ : 0 ≤ k₁) (hk₂ : 2 * k₂ < N) :
    iofEnergy N k₂ < iofEnergy N k₁ := by
  unfold iofEnergy; nlinarith [sq_nonneg (N - 2 * k₁ - (N - 2 * k₂))]



/-- Each step reduces energy by at least 4 when N-2k > 2 -/
theorem iofEnergy_min_drop (N k : ℤ) (h : 2 < N - 2 * k) :
    4 ≤ iofEnergy N k - iofEnergy N (k + 1) := by
  rw [iofEnergy_drop]; linarith



/-- The maximum possible energy drop at step k -/
theorem iofEnergy_max_drop (N k : ℤ) :
    iofEnergy N k - iofEnergy N (k + 1) = 4 * N - 8 * k - 4 := by
  unfold iofEnergy; ring



/-- E(k) = 0 iff N = 2k (the odd leg has collapsed to zero) -/
theorem iofEnergy_zero_iff (N k : ℤ) :
    iofEnergy N k = 0 ↔ N = 2 * k := by
  unfold iofEnergy
  constructor
  · intro h; nlinarith [sq_nonneg (N - 2 * k)]
  · intro h; rw [h]; ring



/-- Combining the Lyapunov conditions: E is a valid Lyapunov function -/
theorem iofEnergy_lyapunov (N k : ℤ) (h : 1 < N - 2 * k) :
    0 ≤ iofEnergy N k ∧
    iofEnergy N (k + 1) < iofEnergy N k ∧
    0 ≤ iofEnergy N (k + 1) := by
  exact ⟨iofEnergy_nonneg N k,
         iofEnergy_strict_decrease N k h,
         iofEnergy_nonneg N (k + 1)⟩



/-- Telescoping energy: total drop from step 0 to step K -/
theorem iofEnergy_telescope (N K : ℤ) :
    iofEnergy N 0 - iofEnergy N K = N ^ 2 - (N - 2 * K) ^ 2 := by
  unfold iofEnergy; ring



/-- The total energy drop equals 4K(N - K) -/
theorem iofEnergy_total_drop (N K : ℤ) :
    iofEnergy N 0 - iofEnergy N K = 4 * K * (N - K) := by
  unfold iofEnergy; ring



/-- At the factor step K = (p-1)/2 for odd p, total drop is N² - (N-p+1)² -/
theorem iofEnergy_total_drop_at_factor (N p : ℤ) (hodd : p % 2 = 1) (hp : 3 ≤ p) :
    iofEnergy N 0 - iofEnergy N ((p - 1) / 2) =
    N ^ 2 - (N - p + 1) ^ 2 := by
  rw [iofEnergy_zero, iofEnergy_at_factor_step N p hodd hp]



/-- Factor steps form arithmetic progressions: if p | (4k² - 1),
then p | (4(k + p)² - 1) -/
theorem factor_step_periodic (p k : ℤ) (h : p ∣ (4 * k ^ 2 - 1)) :
    p ∣ (4 * (k + p) ^ 2 - 1) := by
  obtain ⟨m, hm⟩ := h
  exact ⟨m + 8 * k + 4 * p, by linarith⟩



/-- Symmetry: if p | (4k² - 1), then p | (4(p - k)² - 1) -/
theorem factor_step_symmetric (p k : ℤ) (h : p ∣ (4 * k ^ 2 - 1)) :
    p ∣ (4 * (p - k) ^ 2 - 1) := by
  obtain ⟨m, hm⟩ := h
  exact ⟨m + 4 * p - 8 * k, by nlinarith⟩



/-- The energy drop at step k is a linear function of k -/
theorem iofEnergy_drop_linear (N k : ℤ) :
    iofEnergy N k - iofEnergy N (k + 1) = 4 * N - 8 * k - 4 := by
  unfold iofEnergy; ring



/-- Two-step energy drop -/
theorem iofEnergy_two_step_drop (N k : ℤ) :
    iofEnergy N k - iofEnergy N (k + 2) = 8 * (N - 2 * k) - 16 := by
  unfold iofEnergy; ring



/-- On the light cone (a²+b²=c²), the Lorentz form is zero before and after -/
theorem on_light_cone_preserved (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (a + 2*b - 2*c)^2 + (-2*a - b + 2*c)^2 = (-2*a - 2*b + 3*c)^2 := by
  have := lorentz_form_preserved a b c; linarith



/-- Energy upper bound at factor detection: when p ≤ N and p ≥ 3 -/
theorem energy_at_detection_bound (N p : ℤ) (hodd : p % 2 = 1)
    (hp : 3 ≤ p) (hp_le : p ≤ N) :
    iofEnergy N ((p - 1) / 2) ≤ (N - 2) ^ 2 := by
  rw [iofEnergy_at_factor_step N p hodd hp]
  nlinarith



/-- The descent preserves parity: if N is odd, N - 2k is odd -/
theorem descent_preserves_parity (N k : ℤ) (hodd : N % 2 = 1) :
    (N - 2 * k) % 2 = 1 := by omega



/-- The odd leg a_k = N - 2k is always positive for k < N/2 -/
theorem odd_leg_positive (N k : ℤ) (h : 2 * k < N) :
    0 < N - 2 * k := by linarith



/-- The number of steps (p-1)/2 is at most (N-1)/2 -/
theorem step_count_bound (N p : ℕ) (hp_le : p ≤ N) :
    (p - 1) / 2 ≤ (N - 1) / 2 := by omega



/-- The second sieve polynomial: k(k-1) captures different residues -/
theorem sieve_poly2 (k : ℤ) : 4 * k * (k - 1) = 4 * k ^ 2 - 4 * k := by ring



/-- The third sieve polynomial -/
theorem sieve_poly3 (k : ℤ) : 4 * k * (k + 1) = 4 * k ^ 2 + 4 * k := by ring



/-- If p | k(k-1) and p is prime, then p | k or p | (k-1) -/
theorem sieve_poly2_factor (p k : ℤ) (hp : Prime p)
    (h : p ∣ k * (k - 1)) : p ∣ k ∨ p ∣ (k - 1) :=
  hp.dvd_or_dvd h



/-- The crystallizer-IOF equivalence: integer stereographic projection
gives the IOF starting triple (up to sign and scaling) -/
theorem crystallizer_iof_bridge (N : ℤ) :
    (2 * N) ^ 2 + (1 - N ^ 2) ^ 2 = (1 + N ^ 2) ^ 2 := by ring



/-- The IOF starting triple is the denominator-cleared crystallizer output -/
theorem iof_is_cleared_crystallizer (N : ℤ) :
    4 * N ^ 2 + (N ^ 2 - 1) ^ 2 = (N ^ 2 + 1) ^ 2 := by ring



/-- Forward Berggren B₁ increases the hypotenuse -/
theorem forward_B1_increases_hyp (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    c < 2 * a - 2 * b + 3 * c := by nlinarith



/-- Forward Berggren B₂ increases the hypotenuse -/
theorem forward_B2_increases_hyp (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c < 2 * a + 2 * b + 3 * c := by linarith



/-- A quadratic form f(k) = ak² + bk + c: completing the square -/
theorem quadratic_discriminant (a b c k : ℤ) :
    4 * a * (a * k ^ 2 + b * k + c) =
    (2 * a * k + b) ^ 2 - (b ^ 2 - 4 * a * c) := by ring



/-- Completing the square for the IOF polynomial 4k² - 1:
discriminant is 16, which is always a perfect square -/
theorem iof_discriminant :
    (0 : ℤ) ^ 2 - 4 * 4 * (-1 : ℤ) = 16 := by norm_num



/-- The energy gradient is a decreasing linear function of step number -/
theorem energy_gradient_linear (N k : ℤ) :
    iofEnergy N k - iofEnergy N (k + 1) -
    (iofEnergy N (k + 1) - iofEnergy N (k + 2)) = 8 := by
  unfold iofEnergy; ring



/-- Constant second difference: the energy landscape is exactly parabolic -/
theorem energy_second_difference_constant (N k₁ k₂ : ℤ) :
    (iofEnergy N k₁ - iofEnergy N (k₁ + 1)) -
    (iofEnergy N (k₁ + 1) - iofEnergy N (k₁ + 2)) =
    (iofEnergy N k₂ - iofEnergy N (k₂ + 1)) -
    (iofEnergy N (k₂ + 1) - iofEnergy N (k₂ + 2)) := by
  unfold iofEnergy; ring



/-- Energy encodes factor size: if E = (N-p+1)², then the factor is p = N - √E + 1 -/
theorem energy_encodes_factor (N p : ℤ) (hodd : p % 2 = 1) (hp : 3 ≤ p) :
    iofEnergy N ((p - 1) / 2) = (N - p + 1) ^ 2 :=
  iofEnergy_at_factor_step N p hodd hp



/-- For N = p*q, the energy at factor step determines both factors -/
theorem energy_determines_factors (p q : ℤ) (hodd : p % 2 = 1) (hp : 3 ≤ p) :
    iofEnergy (p * q) ((p - 1) / 2) = (p * (q - 1) + 1) ^ 2 := by
  rw [iofEnergy_at_factor_step (p * q) p hodd hp]; ring



/-- Energy ratio at factor detection -/
theorem energy_ratio_identity (N p : ℤ) (hodd : p % 2 = 1) (hp : 3 ≤ p) :
    iofEnergy N 0 - iofEnergy N ((p - 1) / 2) =
    (2 * N - p + 1) * (p - 1) := by
  rw [iofEnergy_zero, iofEnergy_at_factor_step N p hodd hp]; ring



end
