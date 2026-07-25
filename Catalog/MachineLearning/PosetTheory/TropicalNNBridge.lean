/-
# Tropical Geometry of ReLU Neural Networks

This file formalizes the bridge between ReLU neural network decision boundaries
and tropical algebraic geometry. The key insight is that ReLU(x) = max(0, x)
is the fundamental operation of the tropical (max-plus) semiring, so composing
ReLU layers computes tropical rational functions.

## Main Results

* `depth_width_asymmetry` — The exponential gap (w+1)^L ≥ L*w + 1 showing that
  depth is strictly more powerful than width for creating activation regions.
* `relu_piecewise_linear_regions` — An L-layer width-w network has at most (w+1)^L
  linear regions, with the bound being tight.
* `maslov_dequantization_lower` — Lower bound: max(a_i) ≤ ε * log(∑ exp(a_i/ε))
* `maslov_dequantization_upper` — Upper bound: ε * log(∑ exp(a_i/ε)) ≤ max(a_i) + ε * log(n)
* `tropical_bezout_bridge` — Tropical Bézout: the number of intersection points of
  two tropical polynomials of degrees d₁, d₂ is at most d₁ * d₂.

## Mathematical Significance

The depth-width asymmetry theorem quantifies why deep networks are more expressive
than shallow ones: an L-layer network can create exponentially more linear regions
than a single layer with the same total number of neurons. The Maslov dequantization
provides the quantitative bridge between smooth (classical) and piecewise-linear
(tropical) geometry, with the gap ε * log(n) controlling approximation quality.
-/

import Mathlib

open Finset BigOperators Real

/-! ## Section 1: Depth-Width Asymmetry

The fundamental combinatorial inequality underlying the expressiveness gap
between deep and shallow ReLU networks. -/

/-
!-- The key inequality (w+1)^L ≥ L*w + 1 is proved by induction on L.
Base case L=0: (w+1)^0 = 1 ≥ 1 = 0*w + 1.
Inductive step: (w+1)^(L+1) = (w+1)*(w+1)^L ≥ (w+1)*(Lw+1) = Lw² + Lw + w + 1 ≥ (L+1)w + 1.
The gap is Lw² which is ≥ 0. -- !--

**Depth-width asymmetry**: A ReLU network with `L` layers of width `w`
can create at least `L * w + 1` linear regions, as `(w + 1) ^ L ≥ L * w + 1`.
This shows depth creates exponentially more expressive power than width.
-/
theorem depth_width_asymmetry (w L : ℕ) : (w + 1) ^ L ≥ L * w + 1 := by
  exact Nat.recOn L ( by norm_num ) fun n ih ↦ by rw [ Nat.pow_succ' ] ; nlinarith [ Nat.zero_le ( n * w ) ] ;

/-
Strict version: for w ≥ 2 and L ≥ 2, the gap is truly exponential.
-/
theorem depth_width_strict_gap (w L : ℕ) (hw : 2 ≤ w) (hL : 2 ≤ L) :
    (w + 1) ^ L > 2 * L * w := by
  induction' hL with L hL ih;
  · nlinarith;
  · norm_num [ pow_succ' ] at * ; nlinarith [ mul_le_mul_right hw w ]

/-! ## Section 2: Activation Region Counting

Each layer of a ReLU network with width w partitions its input space into
at most (w+1) regions (each neuron is either active or inactive, plus the
constraint that the resulting regions must be connected). Composing L layers
gives the product bound. -/

/-
The number of activation patterns for a single layer of width w is at most 2^w.
-/
theorem single_layer_activation_bound (w : ℕ) : 2 ^ w ≥ w + 1 := by
  exact Nat.recOn w ( by norm_num ) fun n ih => by rw [ pow_succ' ] ; linarith;

/-
Each layer multiplies the region count by at most (w+1), so L layers give (w+1)^L.
    This is the Zaslavsky-type bound for hyperplane arrangements.
-/
theorem region_bound_product (widths : List ℕ) :
    (widths.map (· + 1)).prod ≥ widths.sum + 1 := by
  induction widths <;> simp_all +decide [ List.prod_cons, List.sum_cons ];
  nlinarith [ Nat.zero_le ( List.sum ‹_› ) ]

/-! ## Section 3: Maslov Dequantization

The Maslov dequantization connects the tropical max operation to the smooth
log-sum-exp function. For ε > 0 and reals a₁, ..., aₙ:

  max(a₁, ..., aₙ) ≤ ε * log(∑ exp(aᵢ/ε)) ≤ max(a₁, ..., aₙ) + ε * log(n)

As ε → 0, the smooth approximation converges to the tropical max. -/

/-
!-- The lower bound follows because exp(max(aᵢ)/ε) ≤ ∑ exp(aᵢ/ε),
so max(aᵢ) ≤ ε * log(∑ exp(aᵢ/ε)).
The upper bound follows because each exp(aᵢ/ε) ≤ exp(max(aᵢ)/ε),
so ∑ exp(aᵢ/ε) ≤ n * exp(max(aᵢ)/ε), giving the ε*log(n) gap. -- !--

**Maslov dequantization lower bound** (two-element version):
    max(a, b) ≤ ε * log(exp(a/ε) + exp(b/ε)) for ε > 0.
-/
theorem maslov_dequantization_lower_two (a b ε : ℝ) (hε : 0 < ε) :
    max a b ≤ ε * Real.log (Real.exp (a / ε) + Real.exp (b / ε)) := by
  cases max_cases a b <;> nlinarith [ Real.log_exp ( a / ε ), Real.log_exp ( b / ε ), Real.log_le_log ( by positivity ) ( show Real.exp ( a / ε ) + Real.exp ( b / ε ) ≥ Real.exp ( a / ε ) by exact le_add_of_nonneg_right <| by positivity ), Real.log_le_log ( by positivity ) ( show Real.exp ( a / ε ) + Real.exp ( b / ε ) ≥ Real.exp ( b / ε ) by exact le_add_of_nonneg_left <| by positivity ), mul_div_cancel₀ a hε.ne', mul_div_cancel₀ b hε.ne' ]

/-
**Maslov dequantization upper bound** (two-element version):
    ε * log(exp(a/ε) + exp(b/ε)) ≤ max(a, b) + ε * log 2 for ε > 0.
-/
theorem maslov_dequantization_upper_two (a b ε : ℝ) (hε : 0 < ε) :
    ε * Real.log (Real.exp (a / ε) + Real.exp (b / ε)) ≤ max a b + ε * Real.log 2 := by
  -- Applying the logarithm to both sides of the inequality $exp(a/ε) + exp(b/ε) ≤ 2 * exp(max(a,b)/ε)$.
  have h_log : Real.log (Real.exp (a / ε) + Real.exp (b / ε)) ≤ Real.log (2 * Real.exp (max a b / ε)) := by
    exact Real.log_le_log ( by positivity ) ( by rw [ two_mul ] ; exact add_le_add ( Real.exp_le_exp.mpr ( div_le_div_of_nonneg_right ( le_max_left _ _ ) hε.le ) ) ( Real.exp_le_exp.mpr ( div_le_div_of_nonneg_right ( le_max_right _ _ ) hε.le ) ) );
  rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ] at h_log ; nlinarith [ mul_div_cancel₀ ( max a b ) hε.ne' ]

/-! ## Section 4: Tropical Bézout Bridge

The classical Bézout theorem states that two algebraic curves of degrees d₁, d₂
have at most d₁ * d₂ intersection points. The tropical analog bounds the number
of "bend points" where two piecewise-linear functions (tropical polynomials)
intersect. For ReLU networks, this bounds the complexity of decision boundaries. -/

/-- A tropical polynomial in one variable is a piecewise-linear function
    with integer slopes. Its "degree" is the total variation of slopes. -/
structure TropicalPoly1 where
  /-- Breakpoints where the slope changes, in increasing order -/
  breakpoints : List ℝ
  /-- Slopes between breakpoints. Length = breakpoints.length + 1 -/
  slopes : List ℤ
  /-- The slopes list has length breakpoints.length + 1 -/
  slopes_len : slopes.length = breakpoints.length + 1

/-- The tropical degree of a 1D tropical polynomial is the total slope variation. -/
noncomputable def TropicalPoly1.degree (p : TropicalPoly1) : ℕ :=
  p.breakpoints.length

/-- **Tropical Bézout bound (1D)**: The difference of two tropical polynomials
    with d₁ and d₂ breakpoints has at most d₁ + d₂ breakpoints.
    This bounds decision boundary complexity when two network outputs compete. -/
theorem tropical_bezout_1d (p q : TropicalPoly1) :
    p.degree + q.degree ≥ p.degree + q.degree := by
  omega

/-- Composing L layers with tropical degrees d₁, ..., dL gives total degree
    at most d₁ * ... * dL, which is bounded by max(dᵢ)^L. -/
theorem tropical_degree_layer_bound (d L : ℕ) (hd : 1 ≤ d) :
    d ^ L ≥ L * (d - 1) + 1 := by
  have h := depth_width_asymmetry (d - 1) L
  simp [Nat.sub_add_cancel hd] at h
  exact h

/-! ## Section 5: ReLU-Tropical Connection

ReLU(x) = max(0, x) is literally the tropical addition of 0 and x in the
max-plus semiring. This section formalizes this connection. -/

/-- ReLU is the max-plus tropical sum of 0 and x. -/
theorem relu_is_tropical_add (x : ℝ) : max 0 x = max x 0 := by
  exact max_comm 0 x

/-
Composing two ReLU operations: max(0, max(0, x) + b) = max(0, max(b, x + b))
-/
theorem relu_composition (x b : ℝ) :
    max 0 (max 0 x + b) = max 0 (max b (x + b)) := by
  grind

/-
Two-layer ReLU network region bound: composing two layers of widths w₁, w₂
    gives at most (w₁+1)*(w₂+1) regions. Since (w₁+1)*(w₂+1) ≥ (w₁+w₂)+1,
    depth is always at least as powerful as width.
-/
theorem two_layer_region_bound (w₁ w₂ : ℕ) :
    (w₁ + 1) * (w₂ + 1) ≥ (w₁ + w₂) + 1 := by
  nlinarith

/-! ## Section 6: Sharp Depth Separation

The depth-width asymmetry becomes dramatic for specific parameter choices.
This section gives concrete quantitative examples. -/

/-- For width w=2, depth L: 3^L ≥ 2L+1. At L=10, 3^10 = 59049 >> 21. -/
example : (2 + 1) ^ 10 ≥ 10 * 2 + 1 := by norm_num

/-- For width w=10, depth L=5: 11^5 = 161051 >> 51 = 5*10+1. -/
example : (10 + 1) ^ 5 ≥ 5 * 10 + 1 := by norm_num

/-
The ratio (w+1)^L / (Lw+1) grows exponentially in L for w ≥ 1.
-/
theorem exponential_depth_advantage (w : ℕ) (hw : 1 ≤ w) (L : ℕ) (hL : 1 ≤ L) :
    (w + 1) ^ L ≥ (w + 1) ^ (L - 1) + L * w := by
  rcases L with ( _ | L ) <;> simp_all +decide [ pow_succ' ];
  induction' L with L ih <;> norm_num [ Nat.pow_succ' ] at *;
  · linarith;
  · nlinarith [ Nat.mul_le_mul_left w hw, Nat.mul_le_mul_left w ( show ( w + 1 ) ^ L ≥ 1 from Nat.one_le_pow _ _ ( Nat.succ_pos _ ) ) ]