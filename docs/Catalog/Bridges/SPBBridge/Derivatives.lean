import Mathlib
import Logic.StrangeLoops.Core
import Bridges.SPBBridge.AlgebraicIdentities

/-!
# SPB Derivative Theory

Full derivative formulas for SPB, including the chain rule for composed functions.

## Main Results
- ∂/∂x spb(x, a) = (1 + a²)/(1 - xa)²
- ∂/∂y spb(a, y) = (1 + a²)/(1 - ay)²
- Full chain rule: d/dt spb(f(t), g(t))
- Derivative is always positive (spb is monotone in each variable)
- Second derivative formula
-/

noncomputable section
open Real SPBResearch

namespace SPBDeriv

/-- Derivative of x ↦ spb(x, a) is (1 + a²)/(1 - xa)². -/
theorem spb_hasDerivAt_x (a x : ℝ) (h : 1 - x * a ≠ 0) :
    HasDerivAt (fun t => spb t a) ((1 + a ^ 2) / (1 - x * a) ^ 2) x := by
  unfold spb
  have := HasDerivAt.div
    (HasDerivAt.add (hasDerivAt_id x) (hasDerivAt_const x a))
    (HasDerivAt.sub (hasDerivAt_const x 1) (HasDerivAt.mul_const (hasDerivAt_id x) a))
    h
  convert this using 1
  simp [id]
  field_simp
  ring

/-- Derivative of y ↦ spb(a, y) is (1 + a²)/(1 - ay)². -/
theorem spb_hasDerivAt_y (a y : ℝ) (h : 1 - a * y ≠ 0) :
    HasDerivAt (fun t => spb a t) ((1 + a ^ 2) / (1 - a * y) ^ 2) y := by
  have h' : 1 - y * a ≠ 0 := by rwa [mul_comm]
  have key : HasDerivAt (fun t => spb t a) ((1 + a ^ 2) / (1 - y * a) ^ 2) y :=
    spb_hasDerivAt_x a y h'
  have heq : (fun t => spb a t) = (fun t => spb t a) := by
    funext t; unfold spb; ring
  rw [heq]; convert key using 1; ring

/-- The derivative is always positive (SPB is strictly increasing). -/
theorem spb_deriv_pos (a x : ℝ) (h : 1 - x * a ≠ 0) :
    0 < (1 + a ^ 2) / (1 - x * a) ^ 2 := by
  positivity

/-- Full chain rule for spb(f(t), g(t)).
    d/dt spb(f(t), g(t)) = [f'(1+g²) + g'(1+f²)] / (1-fg)² -/
theorem spb_chain_rule (f g : ℝ → ℝ) (t₀ f' g' : ℝ)
    (hf : HasDerivAt f f' t₀)
    (hg : HasDerivAt g g' t₀)
    (h : 1 - f t₀ * g t₀ ≠ 0) :
    HasDerivAt (fun t => spb (f t) (g t))
      ((f' * (1 + g t₀ ^ 2) + g' * (1 + f t₀ ^ 2)) / (1 - f t₀ * g t₀) ^ 2) t₀ := by
  unfold spb
  have hden : HasDerivAt (fun t => 1 - f t * g t) (-(f' * g t₀ + f t₀ * g')) t₀ := by
    exact (hf.mul hg).const_sub 1
  have hnum := hf.add hg
  have := hnum.div hden h
  convert this using 1
  simp only [Pi.add_apply]
  field_simp
  ring

/-- Second derivative of x ↦ spb(x, a). -/
theorem spb_second_deriv (a x : ℝ) (h : 1 - x * a ≠ 0) :
    HasDerivAt (fun t => (1 + a ^ 2) / (1 - t * a) ^ 2)
      (2 * a * (1 + a ^ 2) / (1 - x * a) ^ 3) x := by
  have h2 : (1 - x * a) ^ 2 ≠ 0 := pow_ne_zero 2 h
  have hnum : HasDerivAt (fun _ : ℝ => (1 + a ^ 2 : ℝ)) 0 x := hasDerivAt_const x _
  have hden : HasDerivAt (fun t => (1 - t * a) ^ 2) (2 * (1 - x * a) * (-a)) x := by
    have := (hasDerivAt_id x |>.mul_const a |>.const_sub 1).pow 2
    convert this using 1; simp [id]
  have := hnum.div hden h2
  convert this using 1
  field_simp
  ring

/-- Derivative of hyperbolic SPB. -/
theorem spbH_hasDerivAt_x (a x : ℝ) (h : 1 + x * a ≠ 0) :
    HasDerivAt (fun t => spbH t a) ((1 - a ^ 2) / (1 + x * a) ^ 2) x := by
  unfold spbH
  have := HasDerivAt.div
    (HasDerivAt.add (hasDerivAt_id x) (hasDerivAt_const x a))
    (HasDerivAt.add (hasDerivAt_const x 1) (HasDerivAt.mul_const (hasDerivAt_id x) a))
    h
  convert this using 1
  simp [id]
  field_simp
  ring

end SPBDeriv
end