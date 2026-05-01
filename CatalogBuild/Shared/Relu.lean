/-! # CatalogBuild.Shared.Relu

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 6
-/

import Mathlib

noncomputable section

/-- The ReLU (Rectified Linear Unit) function. -/
def relu (x : ℝ) : ℝ := max 0 x


/-- ReLU(x) ≥ 0. -/
theorem relu_nonneg (x : ℝ) : 0 ≤ relu x := le_max_left 0 x


/-- [Section: # Tropical–Neural Network Bridge
New theorems formalizing the connection between tropical algebra and neural networks.
ReLU networks compute piecewise-linear functions, which are precisely the functions
expressible as differences of tropical polynomials. This file establishes key
theoretical foundations.
## Main Results
- `relu_max_form`: ReLU(x) = max(0, x)
- `relu_lipschitz`: ReLU is 1-Lipschitz
- `relu_idempotent`: ReLU(ReLU(x)) = ReLU(x)
- `relu_homogeneous`: ReLU(c·x) = c·ReLU(x) for c ≥ 0
- `max_as_relu`: max(a,b) = b + ReLU(a - b)
- `tropical_add_comm/assoc`: max is commutative and associative (tropical addition)
- `softplus_bounds`: Softplus approximation bounds
- `composition_lipschitz_bridge`: Composition of Lipschitz functions bound] -/
theorem relu_pos_homogeneous (c x : ℝ) (hc : 0 ≤ c) :
    relu (c * x) = c * relu x := by
  unfold relu;
  cases max_cases ( 0 : ℝ ) x <;> cases max_cases ( 0 : ℝ ) ( c * x ) <;> nlinarith


/-- ReLU(x) ≥ x. -/
theorem relu_ge (x : ℝ) : x ≤ relu x := le_max_right 0 x


theorem relu_lipschitz (x y : ℝ) : |relu x - relu y| ≤ |x - y| := by
  unfold relu;
  cases max_cases ( 0 : ℝ ) x <;> cases max_cases ( 0 : ℝ ) y <;> cases abs_cases ( x - y ) <;> cases abs_cases ( max 0 x - max 0 y ) <;> linarith


/-- ReLU is idempotent: ReLU(ReLU(x)) = ReLU(x). -/
theorem relu_idempotent (x : ℝ) : relu (relu x) = relu x := by
  simp [relu]


end
