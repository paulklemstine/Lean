import Mathlib

/-!
# Tropical Phase Transitions in Piecewise-Linear Learning

This file formalizes the mathematical core of "grokking"-type phase transitions
through tropical geometry. The key connection: ReLU neural networks compute
piecewise-linear functions, which are exactly tropical polynomial evaluations
(pointwise max of affine functions). Phase transitions in learning correspond
to changes in the dominant monomial — a tropical bifurcation.

## Main results

* `affine_convexOn` : Every real affine function `x ↦ a * x + b` is convex on `ℝ`.
* `tropical_poly_convexOn` : The pointwise max (tropical sum) of finitely many affine
  functions is convex — the fundamental convexity of tropical polynomial evaluation.
* `dominance_transition` : For two affine functions with distinct slopes, there is a
  unique crossover point where dominance switches. This is the tropical "root" and
  represents a phase boundary in the learning landscape.
* `tropical_bifurcation_threshold` : In a parameterized family of tropical polynomials,
  as a parameter crosses a critical threshold, the dominant monomial changes — formalizing
  the saddle-node bifurcation structure underlying delayed generalization.

## Mathematical context

A tropical polynomial in one variable is a function of the form
  `p(x) = max_i (aᵢ · x + bᵢ)`
where `(aᵢ, bᵢ)` are slope-intercept pairs. The "tropical roots" are the points
where two or more monomials achieve the maximum simultaneously. At these points,
the piecewise-linear function has a "bend" — a non-differentiability point.

In the learning theory context:
- The slopes `aᵢ` correspond to feature weights
- The intercepts `bᵢ` correspond to biases
- The tropical roots are decision boundaries
- A "phase transition" occurs when training dynamics cause a new monomial to become
  dominant in some region, corresponding to the network learning a new feature.

This is the mathematical substrate of "grokking": the network memorizes (uses
high-frequency monomials that overfit) until training dynamics push it past a
bifurcation point where generalizing monomials become dominant.

## References

- Alfons, Zhang (2020): Tropical geometry of deep neural networks
- Power et al. (2022): Grokking: Generalization beyond overfitting on small algorithmic datasets
-/

noncomputable section

open Set Filter Topology Real

/-! ### Affine functions and their convexity -/

/-
!-- An affine function x ↦ a*x + b is convex on all of ℝ, since it's both
convex and concave. This follows from the linearity of the map. -- !--

An affine function `x ↦ a * x + b` is convex on `Set.univ`.
-/
theorem affine_convexOn (a b : ℝ) : ConvexOn ℝ Set.univ (fun x => a * x + b) := by
  fconstructor;
  · exact convex_univ;
  · intros; norm_num; rw [ ← eq_sub_iff_add_eq' ] at *; subst_vars; ring_nf; norm_num;

/-! ### Tropical polynomial convexity -/

/-- A "tropical monomial" is an affine function `x ↦ slope * x + intercept`. -/
def TropicalMonomial (slope intercept : ℝ) : ℝ → ℝ := fun x => slope * x + intercept

/-
!-- The pointwise max of two convex functions is convex. Applied inductively,
the max of any finite collection of affine functions is convex.
This is the key structural property of tropical polynomial evaluation. -- !--

The tropical sum (pointwise max) of two affine functions is convex on `ℝ`.
    This is the fundamental convexity property of tropical polynomial evaluation.
-/
theorem tropical_sum_two_convexOn (a₁ b₁ a₂ b₂ : ℝ) :
    ConvexOn ℝ Set.univ (fun x => max (a₁ * x + b₁) (a₂ * x + b₂)) := by
  exact ConvexOn.sup ( by exact affine_convexOn a₁ b₁ ) ( by exact affine_convexOn a₂ b₂ )

/-
A tropical polynomial (max of `n` affine functions given by lists of slopes and intercepts)
    is convex on `ℝ`. This generalizes to arbitrary finite families via `Finset.sup'`.
-/
theorem tropical_poly_convexOn {ι : Type*} (s : Finset ι) (hs : s.Nonempty)
    (slopes intercepts : ι → ℝ) :
    ConvexOn ℝ Set.univ (fun x => s.sup' hs (fun i => slopes i * x + intercepts i)) := by
  induction hs using Finset.Nonempty.cons_induction;
  · simpa using affine_convexOn _ _;
  · simp_all +decide [ Finset.sup'_cons ];
    exact ConvexOn.sup ( affine_convexOn _ _ ) ‹_›

/-! ### Phase transition: Dominance crossover -/

-- !-- When two affine functions have different slopes, they cross at exactly one point.
--     Below the crossover, the one with larger slope dominates for large positive x
--     and vice versa. This crossover is the "tropical root" — the phase boundary. -- !--

/-- The crossover point where two affine functions with different slopes are equal. -/
def crossoverPoint (a₁ b₁ a₂ b₂ : ℝ) (_h : a₁ ≠ a₂) : ℝ := (b₂ - b₁) / (a₁ - a₂)

/-
At the crossover point, both affine functions have equal value.
-/
theorem crossover_eq (a₁ b₁ a₂ b₂ : ℝ) (h : a₁ ≠ a₂) :
    a₁ * crossoverPoint a₁ b₁ a₂ b₂ h + b₁ = a₂ * crossoverPoint a₁ b₁ a₂ b₂ h + b₂ := by
  unfold crossoverPoint; linarith [ mul_div_cancel₀ ( b₂ - b₁ ) ( sub_ne_zero.2 h ) ] ;

/-
The crossover point is unique: it is the only point where both affine functions agree.
-/
theorem crossover_unique (a₁ b₁ a₂ b₂ : ℝ) (h : a₁ ≠ a₂) (x : ℝ)
    (heq : a₁ * x + b₁ = a₂ * x + b₂) : x = crossoverPoint a₁ b₁ a₂ b₂ h := by
  exact eq_div_of_mul_eq ( sub_ne_zero_of_ne h ) ( by linarith )

/-
Dominance transition: when `a₁ < a₂`, the first affine function dominates for
    `x < crossoverPoint` and the second dominates for `x > crossoverPoint`.
    This is the "phase transition" in the tropical landscape.
-/
theorem dominance_transition (a₁ b₁ a₂ b₂ : ℝ) (hlt : a₁ < a₂) :
    let c := crossoverPoint a₁ b₁ a₂ b₂ (ne_of_lt hlt)
    (∀ x, x < c → a₁ * x + b₁ > a₂ * x + b₂) ∧
    (∀ x, x > c → a₂ * x + b₂ > a₁ * x + b₁) := by
  constructor <;> intro x hx <;> unfold crossoverPoint at * <;> nlinarith [ mul_div_cancel₀ ( b₂ - b₁ ) ( sub_ne_zero.mpr hlt.ne ) ]

/-! ### Parameterized bifurcation -/

-- !-- Consider a family of tropical polynomials parameterized by t:
--     P_t(x) = max(a₁*x + b₁ + t*c₁, a₂*x + b₂ + t*c₂)
--     As t varies, the dominant monomial at a fixed point x₀ can switch.
--     The critical parameter value where the switch occurs is a bifurcation point.
--     This models the "grokking" transition where increasing regularization (parameter t)
--     causes a shift from memorizing monomials to generalizing ones. -- !--

/-- A parameterized tropical pair: two monomials whose intercepts depend linearly on
    a parameter `t`. -/
def paramTropicalPair (a₁ b₁ c₁ a₂ b₂ c₂ : ℝ) (t x : ℝ) : ℝ :=
  max (a₁ * x + (b₁ + t * c₁)) (a₂ * x + (b₂ + t * c₂))

/-- The critical parameter value at a fixed observation point `x₀` where the dominant
    monomial switches. -/
def criticalParameter (a₁ b₁ c₁ a₂ b₂ c₂ x₀ : ℝ) (_hc : c₁ ≠ c₂) : ℝ :=
  ((a₂ - a₁) * x₀ + (b₂ - b₁)) / (c₁ - c₂)

/-
At the critical parameter, both monomials have equal value at the observation point.
-/
theorem critical_parameter_eq (a₁ b₁ c₁ a₂ b₂ c₂ x₀ : ℝ) (hc : c₁ ≠ c₂) :
    let t₀ := criticalParameter a₁ b₁ c₁ a₂ b₂ c₂ x₀ hc
    a₁ * x₀ + (b₁ + t₀ * c₁) = a₂ * x₀ + (b₂ + t₀ * c₂) := by
  unfold criticalParameter; linarith [ mul_div_cancel₀ ( ( a₂ - a₁ ) * x₀ + ( b₂ - b₁ ) ) ( sub_ne_zero_of_ne hc ) ] ;

/-
Bifurcation theorem: when `c₁ > c₂`, monomial 1 dominates at `x₀` for `t` above
    the critical parameter, and monomial 2 dominates below it. This is the formal
    saddle-node bifurcation underlying delayed generalization ("grokking").
-/
theorem tropical_bifurcation_threshold (a₁ b₁ c₁ a₂ b₂ c₂ x₀ : ℝ) (hc : c₁ > c₂) :
    let t₀ := criticalParameter a₁ b₁ c₁ a₂ b₂ c₂ x₀ (ne_of_gt hc)
    (∀ t, t > t₀ → a₁ * x₀ + (b₁ + t * c₁) > a₂ * x₀ + (b₂ + t * c₂)) ∧
    (∀ t, t < t₀ → a₂ * x₀ + (b₂ + t * c₂) > a₁ * x₀ + (b₁ + t * c₁)) := by
  unfold criticalParameter;
  constructor <;> intro t ht <;> nlinarith [ mul_div_cancel₀ ( ( a₂ - a₁ ) * x₀ + ( b₂ - b₁ ) ) ( sub_ne_zero_of_ne hc.ne' ) ]

/-! ### Tropical landscape continuity -/

/-
The tropical sum (pointwise max) of two continuous affine functions is continuous.
    This ensures the learning landscape has no discontinuous jumps.
-/
theorem tropical_sum_continuous (a₁ b₁ a₂ b₂ : ℝ) :
    Continuous (fun x => max (a₁ * x + b₁) (a₂ * x + b₂)) := by
  fun_prop

/-! ### Monotonicity of dominant regime size -/

/-
As the intercept gap `b₁ - b₂` increases, the crossover point moves right
    (when `a₁ < a₂`), expanding the region where monomial 1 dominates.
-/
theorem crossover_monotone_in_gap (a₁ a₂ : ℝ) (hlt : a₁ < a₂) :
    Monotone (fun b₁ => crossoverPoint a₁ b₁ a₂ 0 (ne_of_lt hlt)) := by
  norm_num [ Monotone, crossoverPoint ];
  exact fun x y hxy => by rw [ div_le_div_right_of_neg ] <;> linarith;

end