import Mathlib
import Tropical.NeuralNetworks.NDimLogSumExp
import Tropical.NeuralNetworks.SoftMaxConvergence

/-! # Tropical Semiring Properties via Dequantization

Algebraic properties connecting LSE and tropical max:
1. LSE shift invariance
2. SoftMax translation equivariance
3. Tropical max super-additivity
4. LSE sub-additivity
-/

noncomputable section

open Real

namespace TropicalSemiringHom

/-- LogSumExp respects shift: LSE(a+d, b+d) = LSE(a,b) + d -/
theorem logsumexp_shift (a b d : ℝ) :
    log (exp (a + d) + exp (b + d)) = log (exp a + exp b) + d := by
  have h : exp (a + d) + exp (b + d) = exp d * (exp a + exp b) := by
    rw [exp_add, exp_add]; ring
  rw [h, log_mul (ne_of_gt (exp_pos d)) (ne_of_gt (add_pos (exp_pos a) (exp_pos b)))]
  rw [log_exp, add_comm]

/-- SoftMax is translation-equivariant: softMax c (x₁+d) (x₂+d) = softMax c x₁ x₂ + d -/
theorem softMax_shift (c x₁ x₂ d : ℝ) (hc : 0 < c) :
    SoftMaxConvergence.softMax c (x₁ + d) (x₂ + d) =
    SoftMaxConvergence.softMax c x₁ x₂ + d := by
  unfold SoftMaxConvergence.softMax
  rw [mul_add c x₁ d, mul_add c x₂ d]
  have h := logsumexp_shift (c * x₁) (c * x₂) (c * d)
  -- h: log(exp(c*x₁ + c*d) + exp(c*x₂ + c*d)) = log(exp(c*x₁)+exp(c*x₂)) + c*d
  -- Multiply by (1/c): (1/c)*LHS = (1/c)*(RHS) = (1/c)*log(...) + d
  rw [h]
  field_simp

/-- Tropical max is super-additive: max(x₁,x₂) + max(y₁,y₂) ≥ max(x₁+y₁, x₂+y₂) -/
theorem tropical_max_superadd (x₁ x₂ y₁ y₂ : ℝ) :
    max x₁ x₂ + max y₁ y₂ ≥ max (x₁ + y₁) (x₂ + y₂) := by
  have h1 : x₁ + y₁ ≤ max x₁ x₂ + max y₁ y₂ :=
    add_le_add (le_max_left x₁ x₂) (le_max_left y₁ y₂)
  have h2 : x₂ + y₂ ≤ max x₁ x₂ + max y₁ y₂ :=
    add_le_add (le_max_right x₁ x₂) (le_max_right y₁ y₂)
  exact sup_le h1 h2

/-- LSE is sub-additive: LSE(a+b, c+d) ≤ LSE(a,c) + LSE(b,d) -/
theorem logsumexp_subadd (a b c d : ℝ) :
    log (exp (a + b) + exp (c + d)) ≤
    log (exp a + exp c) + log (exp b + exp d) := by
  -- Key: (exp(a)+exp(c))*(exp(b)+exp(d)) ≥ exp(a+b)+exp(c+d)
  have h_ineq : exp (a + b) + exp (c + d) ≤ (exp a + exp c) * (exp b + exp d) := by
    have : (0 : ℝ) ≤ exp a * exp d := mul_nonneg (exp_pos a).le (exp_pos d).le
    have : (0 : ℝ) ≤ exp c * exp b := mul_nonneg (exp_pos c).le (exp_pos b).le
    calc exp (a + b) + exp (c + d)
        = exp a * exp b + exp c * exp d := by rw [exp_add a b, exp_add c d]
    _ ≤ exp a * exp b + exp a * exp d + exp c * exp b + exp c * exp d := by nlinarith
    _ = (exp a + exp c) * (exp b + exp d) := by ring
  have h_pos : (0 : ℝ) < exp (a + b) + exp (c + d) := add_pos (exp_pos (a + b)) (exp_pos (c + d))
  -- log_le_log : 0 < x → x ≤ y → log x ≤ log y
  have h_log : log (exp (a + b) + exp (c + d)) ≤ log ((exp a + exp c) * (exp b + exp d)) :=
    log_le_log h_pos h_ineq
  rwa [log_mul (ne_of_gt (add_pos (exp_pos a) (exp_pos c)))
                  (ne_of_gt (add_pos (exp_pos b) (exp_pos d)))] at h_log

end TropicalSemiringHom
