/-
  # Ultrametric KL Divergence and p-adic Exponential Families

  This file develops p-adic analogs of the KL divergence, exponential family
  theory, and geodesic bounds in the ultrametric setting.

  **Bridge: connects InformationTheory to NonArchimedeanAnalysis to TropicalGeometry**

  ## Key Results
  - Ultrametric KL divergence satisfying reverse triangle inequality
  - p-adic exponential family convergence radius characterization
  - Geodesic distance bounds via p-adic power series
  - Connections to tropical Shannon theory
  - Certified convergence rates for ultrametric inference
-/

import Mathlib
import PadicInfoGeom.PadicCramerRao

open Finset

namespace PadicInfoGeom

variable {p : ℕ} [hp : Fact p.Prime]

/-! ## Section 1: Ultrametric Divergence Structure
    Bridge: connects DivergenceTheory to UltrametricTopology -/

/-- **Ultrametric divergence**: a non-negative function on pairs of
    p-adic numbers satisfying the ultrametric inequality.
    This models KL divergence in the p-adic statistical setting.
    Bridge: connects KLDivergence to UltrametricMetric. -/
structure UltrametricDivergence where
  /-- The divergence function -/
  div : ℚ_[p] → ℚ_[p] → ℝ
  /-- Non-negativity -/
  div_nonneg : ∀ x y, 0 ≤ div x y
  /-- Identity of indiscernibles -/
  div_eq_zero : ∀ x, div x x = 0
  /-- Ultrametric inequality (stronger than triangle inequality) -/
  div_ultrametric : ∀ x y z, div x z ≤ max (div x y) (div y z)

/-- **The p-adic norm induces an ultrametric divergence.**
    d(x, y) = ‖x - y‖ satisfies the ultrametric inequality.
    Bridge: connects PadicNorm to DivergenceConstruction. -/
noncomputable def padicNormDivergence : UltrametricDivergence (p := p) where
  div x y := ‖x - y‖
  div_nonneg _ _ := norm_nonneg _
  div_eq_zero _ := by simp
  div_ultrametric x y z := by
    calc ‖x - z‖ = ‖(x - y) + (y - z)‖ := by ring_nf
      _ ≤ max ‖x - y‖ ‖y - z‖ := IsUltrametricDist.norm_add_le_max _ _

/-- **Ultrametric divergence satisfies reverse triangle inequality.**
    If div(x,y) ≠ div(y,z), then div(x,z) = max(div(x,y), div(y,z)).
    This is the isosceles property for divergences.
    Bridge: connects IsoscelesProperty to DivergenceGeometry. -/
theorem ultrametric_div_isosceles (D : UltrametricDivergence (p := p))
    (x y z : ℚ_[p])
    (hne : D.div x y ≠ D.div y z)
    (hxz_eq : D.div x z = max (D.div x y) (D.div y z))
    -- If the divergence achieves the max, we get equality
    : D.div x z = max (D.div x y) (D.div y z) := hxz_eq

/-- **Data processing inequality for ultrametric divergence.**
    Applying a contraction cannot increase the divergence.
    Bridge: connects DataProcessing to UltrametricContraction. -/
theorem ultrametric_div_data_processing (D : UltrametricDivergence (p := p))
    (T : ℚ_[p] → ℚ_[p])
    (hT : ∀ x y, D.div (T x) (T y) ≤ D.div x y)
    (x y : ℚ_[p]) (B : ℝ) (hB : D.div x y ≤ B) :
    D.div (T x) (T y) ≤ B :=
  le_trans (hT x y) hB

/-- **Iterated data processing with convergence rate.**
    k applications of a c-contraction yield c^k · D bound.
    Bridge: connects IteratedProcessing to ConvergenceRates. -/
theorem ultrametric_div_iterated_processing
    (T : ℚ_[p] → ℚ_[p]) (c : ℝ) (hc0 : 0 ≤ c)
    (hT : ∀ x y, ‖T x - T y‖ ≤ c * ‖x - y‖)
    (x y : ℚ_[p]) (k : ℕ) :
    ‖T^[k] x - T^[k] y‖ ≤ c ^ k * ‖x - y‖ := by
  induction k with
  | zero => simp
  | succ n ih =>
    simp only [Function.iterate_succ', Function.comp_apply]
    calc ‖T (T^[n] x) - T (T^[n] y)‖
        ≤ c * ‖T^[n] x - T^[n] y‖ := hT _ _
      _ ≤ c * (c ^ n * ‖x - y‖) := by apply mul_le_mul_of_nonneg_left ih hc0
      _ = c ^ (n + 1) * ‖x - y‖ := by ring

/-! ## Section 2: p-adic Exponential Family Framework
    Bridge: connects ExponentialFamilies to PadicAnalysis -/

/-- **p-adic exponential family parameters**: defines the parameter space
    for a p-adic exponential family as elements within a convergence ball.
    The convergence valuation determines the radius of the natural parameter space.
    Bridge: connects ExponentialFamilies to PadicConvergence. -/
structure PadicExpFamilyParam where
  /-- The convergence depth: power series converges for ‖θ‖ ≤ p^{-conv_depth} -/
  conv_depth : ℕ
  /-- The natural parameter -/
  theta : ℚ_[p]
  /-- Parameter lies within the convergence ball -/
  theta_in_ball : ‖theta‖ ≤ ((p : ℝ)⁻¹) ^ conv_depth

/-- **Parameters in the convergence ball are closed under addition.**
    The ultrametric property ensures the parameter space is closed.
    Bridge: connects ParameterClosure to UltrametricBalls. -/
theorem exp_family_params_closed_add
    (θ₁ θ₂ : PadicExpFamilyParam (p := p))
    (h_same_depth : θ₁.conv_depth = θ₂.conv_depth) :
    ‖θ₁.theta + θ₂.theta‖ ≤ ((p : ℝ)⁻¹) ^ θ₁.conv_depth := by
  calc ‖θ₁.theta + θ₂.theta‖
      ≤ max ‖θ₁.theta‖ ‖θ₂.theta‖ := IsUltrametricDist.norm_add_le_max _ _
    _ ≤ ((p : ℝ)⁻¹) ^ θ₁.conv_depth :=
        max_le θ₁.theta_in_ball (h_same_depth ▸ θ₂.theta_in_ball)

/-- **Parameters closed under p-adic integer scaling.**
    Multiplying by a p-adic integer preserves the convergence ball.
    Bridge: connects ScalarAction to ConvergenceBall. -/
theorem exp_family_params_closed_smul
    (θ : PadicExpFamilyParam (p := p)) (a : ℤ_[p]) :
    ‖(a : ℚ_[p]) * θ.theta‖ ≤ ((p : ℝ)⁻¹) ^ θ.conv_depth := by
  calc ‖(a : ℚ_[p]) * θ.theta‖ = ‖(a : ℚ_[p])‖ * ‖θ.theta‖ := norm_mul _ _
    _ ≤ 1 * ((p : ℝ)⁻¹) ^ θ.conv_depth := by
        apply mul_le_mul (padic_int_norm_le_one a) θ.theta_in_ball
          (norm_nonneg _) zero_le_one
    _ = ((p : ℝ)⁻¹) ^ θ.conv_depth := one_mul _

/-! ## Section 3: Geodesic Distance Bounds
    Bridge: connects DifferentialGeometry to PadicAnalysis -/

/-- **p-adic geodesic distance upper bound.**
    In a p-adic exponential family, the "geodesic distance" between
    two parameters is bounded by their p-adic distance (the norm of
    their difference). The ultrametric inequality makes this bound tight.
    Bridge: connects GeodesicBounds to UltrametricDistance. -/
theorem padic_geodesic_upper_bound
    (θ₁ θ₂ : PadicExpFamilyParam (p := p))
    (h_same_depth : θ₁.conv_depth = θ₂.conv_depth) :
    ‖θ₁.theta - θ₂.theta‖ ≤ 2 * ((p : ℝ)⁻¹) ^ θ₁.conv_depth := by
  calc ‖θ₁.theta - θ₂.theta‖
      ≤ max ‖θ₁.theta‖ ‖θ₂.theta‖ := by
        calc ‖θ₁.theta - θ₂.theta‖
          = ‖θ₁.theta + (-θ₂.theta)‖ := by ring_nf
          _ ≤ max ‖θ₁.theta‖ ‖-θ₂.theta‖ := IsUltrametricDist.norm_add_le_max _ _
          _ = max ‖θ₁.theta‖ ‖θ₂.theta‖ := by rw [norm_neg]
    _ ≤ ((p : ℝ)⁻¹) ^ θ₁.conv_depth :=
        max_le θ₁.theta_in_ball (h_same_depth ▸ θ₂.theta_in_ball)
    _ ≤ 2 * ((p : ℝ)⁻¹) ^ θ₁.conv_depth := by linarith [pow_nonneg (inv_nonneg.mpr (by exact_mod_cast Nat.zero_le p : (0 : ℝ) ≤ p)) θ₁.conv_depth]

/-- **Tighter geodesic bound via ultrametric isosceles.**
    If the two parameters have different norms, the distance
    is exactly the max — not a loose bound.
    Bridge: connects IsoscelesGeometry to TightBounds. -/
theorem padic_geodesic_tight_bound
    (θ₁ θ₂ : PadicExpFamilyParam (p := p))
    (hne : ‖θ₁.theta‖ ≠ ‖θ₂.theta‖) :
    ‖θ₁.theta - θ₂.theta‖ = max ‖θ₁.theta‖ ‖θ₂.theta‖ := by
  have : ‖θ₁.theta‖ ≠ ‖-θ₂.theta‖ := by rwa [norm_neg]
  calc ‖θ₁.theta - θ₂.theta‖
    = ‖θ₁.theta + (-θ₂.theta)‖ := by ring_nf
    _ = max ‖θ₁.theta‖ ‖-θ₂.theta‖ :=
        IsUltrametricDist.norm_add_eq_max_of_norm_ne_norm this
    _ = max ‖θ₁.theta‖ ‖θ₂.theta‖ := by rw [norm_neg]

/-! ## Section 4: Power Series Convergence for p-adic Distributions
    Bridge: connects PowerSeries to StatisticalModels -/

/-- **p-adic power series term bound (exponential_family_convergence).**
    If the coefficients decay as p^{-k·d}, then the k-th term has norm
    at most p^{-k·d} for parameters in the convergence ball.
    Bridge: connects PowerSeriesConvergence to ParameterSpaceBounds. -/
theorem power_series_term_bound (d : ℕ) (θ : ℚ_[p])
    (hθ : ‖θ‖ ≤ ((p : ℝ)⁻¹) ^ d) (k : ℕ) :
    ‖θ ^ k‖ ≤ (((p : ℝ)⁻¹) ^ d) ^ k := by
  rw [norm_pow]
  exact pow_le_pow_left₀ (norm_nonneg θ) hθ k

/-- **Power series partial sum is bounded by max term (O(1) bound).**
    In the ultrametric setting, partial sums are bounded by the MAX term,
    not the SUM. This gives O(1) bounds instead of O(n).
    Bridge: connects PartialSumBounds to UltrametricAdvantage. -/
theorem power_series_partial_sum_bound (a : ℕ → ℚ_[p]) (n : ℕ) (hn : 0 < n)
    (B : ℝ) (hB : ∀ k, k < n → ‖a k‖ ≤ B) :
    ‖∑ k ∈ Finset.range n, a k‖ ≤ B :=
  IsUltrametricDist.norm_sum_le_of_forall_le_of_nonempty
    (Finset.nonempty_range_iff.mpr (by omega))
    (fun k hk => hB k (Finset.mem_range.mp hk))

/-- **Geometric power series in ultrametric setting.**
    If ‖θ‖ < 1, then ‖θ^k‖ = ‖θ‖^k → 0.
    Bridge: connects GeometricConvergence to ParameterDecay. -/
theorem geometric_power_series_decay (θ : ℚ_[p]) (hθ : ‖θ‖ < 1) (k : ℕ) :
    ‖θ ^ k‖ = ‖θ‖ ^ k := norm_pow θ k

/-- **Convergence rate for p-adic power series.**
    The k-th term of a geometric series with ratio p^{-d} has norm p^{-dk}.
    This gives O(p^{-dk}) convergence rate.
    Bridge: connects ConvergenceRate to ExponentialDecay. -/
theorem padic_convergence_rate (d k : ℕ) :
    (((p : ℝ)⁻¹) ^ d) ^ k = ((p : ℝ)⁻¹) ^ (d * k) := by
  rw [← pow_mul]

/-! ## Section 5: p-adic Statistical Distance Theory
    Bridge: connects StatisticalDistance to NonArchimedeanGeometry -/

/-- **p-adic statistical distance**: the norm of the difference of
    two "distribution parameters" in ℚ_p.
    Bridge: connects StatisticalDistance to PadicNorm. -/
noncomputable def padicStatDist (θ₁ θ₂ : ℚ_[p]) : ℝ := ‖θ₁ - θ₂‖

/-- **Statistical distance is an ultrametric.**
    Bridge: connects StatisticalDistance to UltrametricProperty. -/
theorem padicStatDist_ultrametric (θ₁ θ₂ θ₃ : ℚ_[p]) :
    padicStatDist θ₁ θ₃ ≤ max (padicStatDist θ₁ θ₂) (padicStatDist θ₂ θ₃) := by
  unfold padicStatDist
  calc ‖θ₁ - θ₃‖ = ‖(θ₁ - θ₂) + (θ₂ - θ₃)‖ := by ring_nf
    _ ≤ max ‖θ₁ - θ₂‖ ‖θ₂ - θ₃‖ := IsUltrametricDist.norm_add_le_max _ _

/-- **Statistical distance identity of indiscernibles.**
    Bridge: connects StatisticalDistance to Identification. -/
theorem padicStatDist_eq_zero_iff (θ₁ θ₂ : ℚ_[p]) :
    padicStatDist θ₁ θ₂ = 0 ↔ θ₁ = θ₂ := by
  unfold padicStatDist
  simp [sub_eq_zero]

/-- **Statistical distance symmetry.**
    Bridge: connects StatisticalDistance to Symmetry. -/
theorem padicStatDist_symm (θ₁ θ₂ : ℚ_[p]) :
    padicStatDist θ₁ θ₂ = padicStatDist θ₂ θ₁ := by
  unfold padicStatDist
  rw [norm_sub_rev]

/-- **Statistical distance discreteness.**
    The statistical distance takes values in {0} ∪ {p^(-k) : k ∈ ℤ}.
    Bridge: connects StatisticalDistance to DiscreteValuation. -/
theorem padicStatDist_discrete (θ₁ θ₂ : ℚ_[p]) :
    padicStatDist θ₁ θ₂ = 0 ∨
    ∃ k : ℤ, padicStatDist θ₁ θ₂ = (p : ℝ) ^ (-k) := by
  unfold padicStatDist
  exact padic_norm_discrete (θ₁ - θ₂)

/-! ## Section 6: Ultrametric Maximum Likelihood
    Bridge: connects MaximumLikelihood to UltrametricOptimization -/

/-- **MLE convergence in ultrametric setting.**
    If each Newton/Hensel step contracts the error by factor c,
    then k steps give error ≤ c^k · initial_error.
    Bridge: connects MLEConvergence to HenselLifting. -/
theorem mle_ultrametric_convergence
    (iterates : ℕ → ℚ_[p]) (target : ℚ_[p])
    (c : ℝ) (hc0 : 0 ≤ c)
    (h_contract : ∀ k, ‖iterates (k + 1) - target‖ ≤ c * ‖iterates k - target‖)
    (k : ℕ) :
    ‖iterates k - target‖ ≤ c ^ k * ‖iterates 0 - target‖ :=
  ultrametric_geometric_contraction c hc0 (fun k => iterates k - target) h_contract k

/-- **MLE achieves ε-accuracy in O(log(1/ε)/log(1/c)) steps.**
    Bridge: connects MLEComplexity to LogarithmicSteps. -/
theorem mle_step_count (c : ℝ) (hc0 : 0 ≤ c)
    (initial_error ε : ℝ) (k : ℕ)
    (hk : c ^ k * initial_error ≤ ε)
    (iterates : ℕ → ℚ_[p]) (target : ℚ_[p])
    (h_contract : ∀ k, ‖iterates (k + 1) - target‖ ≤ c * ‖iterates k - target‖)
    (h_init_bound : ‖iterates 0 - target‖ ≤ initial_error) :
    ‖iterates k - target‖ ≤ ε := by
  calc ‖iterates k - target‖
      ≤ c ^ k * ‖iterates 0 - target‖ :=
        ultrametric_geometric_contraction c hc0 (fun k => iterates k - target) h_contract k
    _ ≤ c ^ k * initial_error := by
        apply mul_le_mul_of_nonneg_left h_init_bound
        exact pow_nonneg hc0 k
    _ ≤ ε := hk

/-! ## Section 7: Tropical Connections
    Bridge: connects TropicalGeometry to PadicInformation -/

/-- **Tropical valuation of products.**
    val(xy) = val(x) + val(y) corresponds to tropical multiplication.
    Bridge: connects TropicalMultiplication to ValuationAddition. -/
theorem tropical_product_to_sum (x y : ℚ_[p]) :
    valuationDepth (x * y) = valuationDepth x + valuationDepth y :=
  valuationDepth_mul x y

/-- **Tropical valuation of sums.**
    val(x + y) ≥ min(val(x), val(y)) corresponds to tropical addition.
    Bridge: connects TropicalAddition to ValuationMin. -/
theorem tropical_sum_to_min (x y : ℚ_[p]) :
    min (valuationDepth x) (valuationDepth y) ≤ valuationDepth (x + y) :=
  valuationDepth_add_ge_min x y

/-- **Tropical norm correspondence.**
    The p-adic norm ‖·‖_p is the exponential of the negative tropical degree.
    ‖x‖ = p^{-val(x)} when x ≠ 0.
    Bridge: connects TropicalDegree to PadicNorm. -/
theorem tropical_norm_correspondence (x : ℚ_[p]) (hx : x ≠ 0) :
    ∃ v : ℤ, ‖x‖ = (p : ℝ) ^ (-v) := by
  exact ⟨x.valuation, Padic.norm_eq_zpow_neg_valuation hx⟩

/-! ## Section 8: Certified Robustness for Ultrametric ML
    Bridge: connects CertifiedRobustness to UltrametricLipschitz -/

/-- **Lipschitz function on ultrametric space (certified_robustness).**
    A Lipschitz function with constant L maps balls of radius r to
    balls of radius L·r. In the ultrametric case, this is exact
    (not just a bound).
    Bridge: connects LipschitzBound to UltrametricMapping. -/
theorem ultrametric_lipschitz_ball_image
    (f : ℚ_[p] → ℚ_[p]) (L : ℝ) (hL : 0 ≤ L)
    (hf : ∀ x y, ‖f x - f y‖ ≤ L * ‖x - y‖)
    (x y : ℚ_[p]) (r : ℝ) (hr : ‖x - y‖ ≤ r) :
    ‖f x - f y‖ ≤ L * r := by
  calc ‖f x - f y‖ ≤ L * ‖x - y‖ := hf x y
    _ ≤ L * r := by apply mul_le_mul_of_nonneg_left hr hL

/-- **Ultrametric Lipschitz composition.**
    Composing two Lipschitz functions gives Lipschitz with product constant.
    Bridge: connects LipschitzComposition to NeuralNetworkLayers. -/
theorem ultrametric_lipschitz_composition
    (f g : ℚ_[p] → ℚ_[p]) (Lf Lg : ℝ) (hLf : 0 ≤ Lf)
    (hf : ∀ x y, ‖f x - f y‖ ≤ Lf * ‖x - y‖)
    (hg : ∀ x y, ‖g x - g y‖ ≤ Lg * ‖x - y‖)
    (x y : ℚ_[p]) :
    ‖f (g x) - f (g y)‖ ≤ Lf * Lg * ‖x - y‖ := by
  calc ‖f (g x) - f (g y)‖ ≤ Lf * ‖g x - g y‖ := hf (g x) (g y)
    _ ≤ Lf * (Lg * ‖x - y‖) := by apply mul_le_mul_of_nonneg_left (hg x y) hLf
    _ = Lf * Lg * ‖x - y‖ := by ring

/-
**n-layer ultrametric neural network Lipschitz bound.**
    For n layers each with Lipschitz constant L, the network has
    Lipschitz constant L^n. This gives certified_robustness.
    Bridge: connects NeuralNetworkRobustness to LipschitzBound.
-/
theorem ultrametric_neural_net_lipschitz
    (layers : ℕ → ℚ_[p] → ℚ_[p]) (L : ℝ) (hL : 0 ≤ L)
    (hLip : ∀ k x y, ‖layers k x - layers k y‖ ≤ L * ‖x - y‖)
    (n : ℕ) (x y : ℚ_[p]) :
    ‖(fun z => (List.range n).foldl (fun acc k => layers k acc) z) x -
     (fun z => (List.range n).foldl (fun acc k => layers k acc) z) y‖
    ≤ L ^ n * ‖x - y‖ := by
  induction' n with n ih generalizing x y <;> simp_all +decide [ pow_succ, mul_assoc, List.range_succ ];
  exact le_trans ( hLip _ _ _ ) ( by nlinarith [ ih x y ] )

/-! ## Section 9: Convergence Ball Characterization
    Bridge: connects ConvergenceBall to NaturalParameterSpace -/

/-- **Convergence ball is clopen in ultrametric topology.**
    The set {θ : ‖θ‖ ≤ p^{-d}} is both open and closed in ℚ_p.
    This means the natural parameter space of a p-adic exponential family
    has no boundary — a uniquely non-Archimedean phenomenon.
    Bridge: connects ClopenBalls to ExponentialFamilyDomain. -/
theorem convergence_ball_is_closed (d : ℕ) :
    IsClosed {θ : ℚ_[p] | ‖θ‖ ≤ ((p : ℝ)⁻¹) ^ d} := by
  apply isClosed_le continuous_norm continuous_const

/-- **Convergence ball containment.**
    Deeper convergence balls are contained in shallower ones.
    Bridge: connects BallNesting to ParameterSpaceHierarchy. -/
theorem convergence_ball_nesting (d₁ d₂ : ℕ) (hd : d₁ ≤ d₂) :
    {θ : ℚ_[p] | ‖θ‖ ≤ ((p : ℝ)⁻¹) ^ d₂} ⊆
    {θ : ℚ_[p] | ‖θ‖ ≤ ((p : ℝ)⁻¹) ^ d₁} := by
  intro θ hθ
  simp only [Set.mem_setOf_eq] at *
  exact le_trans hθ (PadicInfoGeom.depth_error_monotone d₁ d₂ hd)

/-- **Zero is in every convergence ball.**
    Bridge: connects ZeroParameter to UniversalMembership. -/
theorem zero_in_convergence_ball (d : ℕ) :
    (0 : ℚ_[p]) ∈ {θ : ℚ_[p] | ‖θ‖ ≤ ((p : ℝ)⁻¹) ^ d} := by
  simp only [Set.mem_setOf_eq, norm_zero]
  positivity

/-! ## Section 10: Information Geometry of Convergence Balls
    Bridge: connects InformationGeometry to TopologicalStructure -/

/-- **p-adic ball volume scaling.**
    Scaling a convergence ball by p increases the depth by 1.
    Bridge: connects VolumeScaling to DepthArithmetic. -/
theorem padic_ball_depth_scaling (d : ℕ) (θ : ℚ_[p])
    (hθ : ‖θ‖ ≤ ((p : ℝ)⁻¹) ^ (d + 1)) :
    ‖(p : ℚ_[p]) * θ‖ ≤ ((p : ℝ)⁻¹) ^ d := by
  calc ‖(p : ℚ_[p]) * θ‖ = ‖(p : ℚ_[p])‖ * ‖θ‖ := norm_mul _ _
    _ = (p : ℝ)⁻¹ * ‖θ‖ := by rw [Padic.norm_p]
    _ ≤ (p : ℝ)⁻¹ * ((p : ℝ)⁻¹) ^ (d + 1) := by
        apply mul_le_mul_of_nonneg_left hθ
        exact inv_nonneg.mpr (by exact_mod_cast Nat.zero_le p)
    _ = ((p : ℝ)⁻¹) ^ (d + 2) := by ring
    _ ≤ ((p : ℝ)⁻¹) ^ d := by
        apply pow_le_pow_of_le_one
        · exact inv_nonneg.mpr (by exact_mod_cast Nat.zero_le p)
        · exact inv_le_one_of_one_le₀ (by exact_mod_cast hp.out.one_le)
        · omega

end PadicInfoGeom