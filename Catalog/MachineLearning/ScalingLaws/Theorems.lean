/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Spectral Scaling Laws: Theorems

This file contains the main results on neural network scaling laws derived
from kernel spectral theory:

1. **Spectral truncation monotonicity**: Captured variance increases with model size.
2. **Tail sum antitone**: Approximation error decreases with model size.
3. **Harmonic exponent identity**: The optimal scaling exponent satisfies 1/γ = 1/α + 1/β.
4. **Optimal allocation balance**: At optimum, exponents partition compute growth.
5. **Marginal balance**: At optimum, marginal contributions are proportional to exponents.
6. **Power-law positivity and monotonicity**: Structural properties of the loss landscape.
7. **Harmonic exponent bounds**: The optimal exponent is bounded by both individual exponents.
8. **Symmetric scaling law**: Equal exponents give equal allocation.

## Key Mathematical Insight

The fundamental theorem shows that when loss decomposes as
L = A·P^(-α) + B·D^(-β) and compute C = P·D is fixed, the optimal loss
scales as L* ∝ C^(-αβ/(α+β)). The exponent αβ/(α+β) is the harmonic
mean of α and β — a universal relationship emerging from the spectral
structure of the kernel, independent of architecture details.
-/
import Mathlib
import Catalog.MachineLearning.ScalingLaws.Defs

open Finset Real BigOperators

/-! ## Section 1: Spectral Truncation Properties -/

/-
!-- Proof sketch: The partial sum of a non-negative sequence is non-decreasing,
since adding one more term adds a non-negative value.
Use Monotone, show f(n+1) = f(n) + eigenvalue(n) ≥ f(n). -- !--

**Theorem 1 (Spectral Truncation Monotonicity).**
    The cumulative eigenvalue sum is monotonically non-decreasing in the
    number of modes P. Adding more parameters always captures more spectral mass.

    **Example**: For ev_k = 1/k², sum(3) = 1+1/4+1/9 ≤ sum(4) = 1+1/4+1/9+1/16.
    **Generalization**: Holds for any non-negative sequence, not just power-law.
    **Boundary**: At P=0, sum=0; as P→∞, sum→tr(K).
-/
theorem spectral_sum_monotone (ev : ℕ → ℝ) (hev : ∀ k, 0 ≤ ev k) :
    Monotone (fun P => ∑ k ∈ Finset.range P, ev k) := by
  exact fun n m hnm => Finset.sum_le_sum_of_subset_of_nonneg ( Finset.range_mono hnm ) fun _ _ _ => hev _

/-
!-- Proof sketch: For a summable non-negative sequence, the tail sum
∑_{k≥P} ev_k is antitone in P because shifting the summation index
by one removes a non-negative term. Use tsum_eq_zero_add and bound. -- !--

**Theorem 2 (Tail Sum Antitone).**
    The tail sum (approximation error) is non-increasing in the truncation
    point P. More parameters → less approximation error.

    **Example**: For summable ev_k = 1/k², tail(3) ≥ tail(4).
    **Generalization**: Holds for any summable non-negative sequence.
    **Boundary**: tail(0) = total trace; tail → 0.
-/
theorem tail_sum_antitone (ev : ℕ → ℝ) (hev : ∀ k, 0 ≤ ev k)
    (hsum : Summable ev) :
    Antitone (fun P => ∑' k, ev (k + P)) := by
  refine' antitone_nat_of_succ_le fun P => _;
  rw [ Summable.tsum_eq_zero_add <| show Summable fun k => ev ( k + P ) from hsum.comp_injective <| add_left_injective _ ];
  grind

/-! ## Section 2: Bias-Variance Non-negativity -/

/-
!-- Proof sketch: rpow_pos_of_pos gives x^(-a) > 0 for x > 0.
Multiplying by positive A gives A * x^(-a) ≥ 0, and similarly for B * y^(-b). -- !--

**Theorem 3 (Power-Law Terms Non-negative).**
    Each power-law term is non-negative at positive arguments.

    **Example**: A=1, a=0.5, P=4: 1*4^(-0.5) = 0.5 ≥ 0.
    **Generalization**: Holds for any positive coefficient and real exponent.
    **Boundary**: As P→∞, term→0; as P→0⁺, term→∞.
-/
theorem bias_variance_nonneg (A B a b : ℝ) (hA : 0 < A) (hB : 0 < B)
    (P N : ℝ) (hP : 0 < P) (hN : 0 < N) :
    0 ≤ A * P ^ (-a) ∧ 0 ≤ B * N ^ (-b) := by
  exact ⟨ mul_nonneg hA.le ( Real.rpow_nonneg hP.le _ ), mul_nonneg hB.le ( Real.rpow_nonneg hN.le _ ) ⟩

/-! ## Section 3: Harmonic Exponent Identity -/

/-
!-- Proof sketch: Direct field arithmetic.
(a*b/(a+b))⁻¹ = (a+b)/(a*b) = a/(a*b) + b/(a*b) = 1/b + 1/a = a⁻¹ + b⁻¹. -- !--

**Theorem 4 (Harmonic Exponent Identity).**
    The optimal scaling exponent γ = ab/(a+b) satisfies the harmonic
    mean relation: 1/γ = 1/a + 1/b.

    This is the core algebraic identity underlying compute-optimal scaling:
    the effective exponent is the harmonic mean of individual exponents.

    **Example**: a=0.5, b=0.5 → γ=0.25, 1/0.25 = 1/0.5 + 1/0.5 = 4. ✓
    **Generalization**: For n resources, 1/γ = Σ 1/aᵢ.
    **Boundary**: As a→∞, γ→b. As b→∞, γ→a.
-/
theorem harmonic_exponent_identity (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    (a * b / (a + b))⁻¹ = a⁻¹ + b⁻¹ := by
  grind

/-
!-- Proof sketch: b/(a+b) + a/(a+b) = (a+b)/(a+b) = 1 by field arithmetic. -- !--

**Theorem 5 (Optimal Exponents Sum to Unity).**
    The optimal model-size and data-size exponents sum to 1:
      b/(a+b) + a/(a+b) = 1.
    This reflects the constraint PD = C: compute increases must be
    distributed, and the exponents partition this optimally.

    **Example**: a=0.34, b=0.28 → 0.452 + 0.548 = 1. ✓
    **Generalization**: For n resources, exponents sum to 1.
    **Boundary**: When a=b, both exponents are 1/2.
-/
theorem optimal_exponents_sum_to_one (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    b / (a + b) + a / (a + b) = 1 := by
  rw [ ← add_div, add_comm, div_self <| ne_of_gt <| add_pos ha hb ]

/-! ## Section 4: Marginal Balance at Optimum -/

/-
!-- Proof sketch: Given the critical point condition x^(a+b) = (a*A)/(b*B) * C^b,
we compute A*x^(-a) / (B*C^(-b)*x^b):
= A*x^(-a) * x^(-b) * C^b / B  [using C^(-b) * x^b → rearrange]
Wait, let me be more careful.
A*x^(-a) / (B * C^(-b) * x^b) = A / (B * C^(-b)) * x^(-a-b)
= A * C^b / B * x^(-(a+b))
= A * C^b / B * ((a*A)/(b*B) * C^b)^(-1)  [using the critical point]
= A * C^b / B * b*B / (a*A * C^b)
= b / a.
Uses field operations and rpow identities. -- !--

**Theorem 6 (Marginal Balance Identity).**
    At the compute-optimal allocation, the bias-to-variance ratio equals b/a.
    If x^(a+b) = (a·A)/(b·B) · C^b (the critical point condition from
    Lagrange multipliers), then A·x^(-a) / (B·C^(-b)·x^b) = b/a.

    **Example**: A=B=1, a=b=1, C=1 → x*=1, ratio = 1 = b/a. ✓
    **Generalization**: For n resources, n-1 pairwise balance equations.
    **Boundary**: When a≫b, ratio→0 (variance dominates at optimum).
-/
theorem marginal_balance_identity (A B a b C : ℝ)
    (_hA : 0 < A) (hB : 0 < B) (ha : 0 < a) (hb : 0 < b)
    (hC : 0 < C) (x : ℝ) (hx : 0 < x)
    (hcrit : x ^ (a + b) = (a * A) / (b * B) * C ^ b) :
    A * x ^ (-a) / (B * C ^ (-b) * x ^ b) = b / a := by
  norm_num [ Real.rpow_add hx, Real.rpow_neg hx.le, Real.rpow_neg hC.le ] at *;
  field_simp [mul_comm, mul_assoc, mul_left_comm] at *;
  grind

/-! ## Section 5: Power-Law Loss Properties -/

/-
!-- Proof sketch: x^(-a) > 0 for x > 0 (rpow_pos_of_pos).
A * x^(-a) > 0 since A > 0. Similarly B * y^(-b) > 0.
Sum of two positive reals is positive. -- !--

**Theorem 7 (Two-Term Power-Law Positivity).**
    The loss A·x^(-a) + B·y^(-b) is strictly positive for all positive x, y.

    **Example**: A=2, a=1, x=3, B=1, b=2, y=5 → 2/3 + 1/25 > 0. ✓
    **Generalization**: Any finite sum of positive power laws is positive.
    **Boundary**: Diverges as x→0⁺ or y→0⁺.
-/
theorem power_law_loss_pos (A B a b x y : ℝ)
    (hA : 0 < A) (hB : 0 < B) (hx : 0 < x) (hy : 0 < y) :
    0 < A * x ^ (-a) + B * y ^ (-b) := by
  positivity

/-
!-- Proof sketch: For 0 < x₁ < x₂ and a > 0, t ↦ t^(-a) is strictly
decreasing on (0,∞). Use rpow_lt_rpow_of_exponent... or the inverse
relationship: x^(-a) = (x^a)⁻¹, and x^a is strictly increasing. -- !--

**Theorem 8 (Bias Strict Decrease).**
    The bias term A·P^(-a) is strictly decreasing in P for a > 0.
    Larger models have strictly lower approximation error.

    **Example**: A=1, a=2: f(2)=1/4 > f(3)=1/9.
    **Generalization**: Any x^(-a) with a>0 is strictly decreasing on ℝ₊.
    **Boundary**: f(P) → 0 as P → ∞; f(P) → ∞ as P → 0⁺.
-/
theorem bias_strict_decrease (A a : ℝ) (hA : 0 < A) (ha : 0 < a)
    (x₁ x₂ : ℝ) (hx₁ : 0 < x₁) (hx₂ : x₁ < x₂) :
    A * x₂ ^ (-a) < A * x₁ ^ (-a) := by
  rw [ Real.rpow_neg ( by linarith ), Real.rpow_neg ( by linarith ) ];
  gcongr

/-! ## Section 6: Harmonic Exponent Bounds -/

/-
!-- Proof sketch: For the positivity: a*b > 0 and a+b > 0, so a*b/(a+b) > 0.
For a*b/(a+b) < a: equivalent to b < a+b, i.e., 0 < a, which holds.
Similarly for < b. -- !--

**Theorem 9 (Harmonic Exponent Bounds).**
    The harmonic scaling exponent γ = ab/(a+b) satisfies:
    (a) 0 < γ
    (b) γ < a
    (c) γ < b

    Compute-optimal scaling is always slower than scaling either resource alone.

    **Example**: a=0.5, b=0.8 → γ=0.308 < min(0.5,0.8). ✓
    **Generalization**: For n resources, γ < min(aᵢ).
    **Boundary**: γ → min(a,b) as max(a,b) → ∞.
-/
theorem harmonic_exponent_bounds (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    0 < a * b / (a + b) ∧
    a * b / (a + b) < a ∧
    a * b / (a + b) < b := by
  exact ⟨ by positivity, by rw [ div_lt_iff₀ ] <;> nlinarith, by rw [ div_lt_iff₀ ] <;> nlinarith ⟩

/-
!-- Proof sketch: a*a/(a+a) = a²/(2a) = a/2.
a/(a+a) = a/(2a) = 1/2. -- !--

**Theorem 10 (Symmetric Scaling Law).**
    When both exponents equal a, the harmonic exponent is a/2 and the
    optimal allocation is perfectly symmetric (exponent 1/2 for each).

    **Example**: a=1 → γ=1/2, P*∝√C, D*∝√C. ✓
    **Generalization**: For n equal exponents, γ = a/n.
    **Boundary**: Symmetric case divides model-limited from data-limited.
-/
theorem symmetric_scaling_law (a : ℝ) (ha : 0 < a) :
    a * a / (a + a) = a / 2 ∧
    a / (a + a) = 1 / 2 := by
  exact ⟨ by rw [ div_eq_div_iff ] <;> nlinarith, by rw [ div_eq_div_iff ] <;> linarith ⟩