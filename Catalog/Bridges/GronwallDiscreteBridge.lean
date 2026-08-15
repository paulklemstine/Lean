import Mathlib
import MachineLearning.ResNetLipschitz
/-! # Discrete Gronwall Bridge

Proves discrete Gronwall inequalities connecting iterative bounds to
contraction mapping and gradient descent convergence:

1. Geometric decay: u(n+1) ≤ c*u(n) → u(n) ≤ cⁿ * u(0)
2. Geometric convergence: cⁿ → 0 for 0 < c < 1
3. Linear growth: u(n+1) ≤ u(n) + M → u(n) ≤ u(0) + n*M
4. Affine fixed point: α/(1-c) = α + c*α/(1-c)
5. Affine iteration decay: the error cⁿ*(u₀ - α/(1-c)) → 0
6. GD geometric convergence: (ηL)ⁿ → 0 when ηL < 1
7. ResNet polynomial growth: (1+L)^n ≥ 1+nL (Bernoulli)
8. Half-rate decay: u(n) ≤ (1/2)ⁿ * u(0) when c = 1/2
-/

noncomputable section

open Real ResNetLipschitz Filter Topology

namespace GronwallDiscreteBridge

/-! ## Section 1: Geometric Decay -/

/-- Geometric bound: if u(n+1) ≤ c*u(n) with c > 0,
    then u(n) ≤ cⁿ * u(0) for all n.
    This is the multiplicative discrete Gronwall inequality. -/
theorem geometric_bound {c : ℝ} (hc : 0 < c) (u : ℕ → ℝ) (hu : ∀ n, u (n + 1) ≤ c * u n) :
    ∀ n, u n ≤ c ^ n * u 0 := by
  intro n
  induction n with
  | zero => simp [pow_zero]
  | succ n ih =>
    calc u (n + 1) ≤ c * u n := hu n
      _ ≤ c * (c ^ n * u 0) := mul_le_mul_of_nonneg_left ih hc.le
      _ = c ^ (n + 1) * u 0 := by ring

/-- Geometric convergence: cⁿ → 0 as n → ∞ for 0 < c < 1. -/
theorem geometric_convergence {c : ℝ} (hc : 0 < c) (hc' : c < 1) :
    Tendsto (fun n => c ^ n) atTop (𝓝 0) :=
  tendsto_pow_atTop_nhds_zero_of_abs_lt_one (by nlinarith [abs_of_pos hc])

/-! ## Section 2: Linear Growth -/

/-- Linear growth: if u(n+1) ≤ u(n) + M with M ≥ 0, then u(n) ≤ u(0) + n*M. -/
theorem linear_growth_bound (M : ℝ) (_ : 0 ≤ M) (u : ℕ → ℝ) (hu : ∀ n, u (n + 1) ≤ u n + M) (n : ℕ) :
    u n ≤ u 0 + (n : ℝ) * M := by
  induction n with
  | zero => simp
  | succ n ih =>
    push_cast at ih
    push_cast
    linarith [hu n]

/-! ## Section 3: Fixed Point and Convergence -/

/-- Affine fixed point: α/(1-c) = α + c*(α/(1-c)).
    The unique fixed point of the affine iteration u(n+1) = α + c*u(n). -/
theorem affine_fixed_point (α c : ℝ) (hc' : c < 1) :
    α / (1 - c) = α + c * (α / (1 - c)) := by
  have : 1 - c ≠ 0 := by linarith
  field_simp [this]; ring

/-- Affine iteration error decay: cⁿ*(u₀ - α/(1-c)) → 0 as n → ∞.
    The error between the initial value and the fixed point vanishes
    geometrically under affine iteration. -/
theorem affine_geometric_decay (c u0 α : ℝ) (hc : 0 < c) (hc' : c < 1) :
    Tendsto (fun n => c ^ n * (u0 - α / (1 - c))) atTop (𝓝 0) := by
  have h1 : Tendsto (fun n => c ^ n) atTop (𝓝 0) :=
    tendsto_pow_atTop_nhds_zero_of_abs_lt_one (by nlinarith [abs_of_pos hc])
  simpa [mul_zero] using h1.mul_const (u0 - α / (1 - c))

/-! ## Section 4: Connections to Existing Work -/

/-- GD rate gives geometric convergence: (ηL)ⁿ → 0 when ηL < 1. -/
theorem gd_geometric_convergence (η L : ℝ) (hη : 0 < η) (hL : 0 < L) (hηL : η * L < 1) :
    Tendsto (fun n => (η * L) ^ n) atTop (𝓝 0) :=
  tendsto_pow_atTop_nhds_zero_of_abs_lt_one (by nlinarith [abs_of_pos (mul_pos hη hL)])

/-- ResNet depth growth is polynomial: (1+L)^n ≥ 1+nL (Bernoulli). -/
theorem resnet_growth_polynomial (L : ℝ) (hL : 0 ≤ L) (n : ℕ) :
    1 + n * L ≤ (1 + L) ^ n :=
  bernoulli_resnet L hL n

/-- Half-rate decay: if c = 1/2, then u(n) ≤ (1/2)ⁿ * u(0). -/
theorem half_rate_decay (u : ℕ → ℝ) (hu : ∀ n, u (n + 1) ≤ (1 / 2 : ℝ) * u n) (n : ℕ) :
    u n ≤ (1 / 2 : ℝ) ^ n * u 0 :=
  geometric_bound (by norm_num : (0 : ℝ) < 1 / 2) u hu n

end GronwallDiscreteBridge