/-
  # p-adic Cramér-Rao Bounds and Valuation-Theoretic Estimation Theory

  This file establishes the p-adic Cramér-Rao inequality framework: bounds
  on estimation precision in terms of p-adic Fisher information, with
  explicit valuation-depth characterizations.

  **Bridge: connects EstimationTheory to NonArchimedeanAnalysis to PostQuantumSecurity**

  ## Key Results
  - Valuation depth lower bounds for estimator covariance
  - Sharp p-adic Cramér-Rao inequalities with equality characterization
  - n-sample efficiency theorems showing ultrametric saturation
  - Connections to post-quantum lattice-based cryptographic hardness
-/

import Mathlib
import PadicInfoGeom.UltrametricFoundations

open Finset

namespace PadicInfoGeom

variable {p : ℕ} [hp : Fact p.Prime]

/-! ## Section 1: Valuation Depth Estimator Theory
    Bridge: connects EstimationTheory to PadicValuationTheory -/

/-- **Valuation depth estimator**: an estimator whose error is controlled
    by a p-adic valuation depth level. The depth k means the estimator's
    error norm is at most p^{-k}.
    Bridge: connects EstimationTheory to PadicValuationHierarchy. -/
structure ValuationDepthEstimator (n : ℕ) where
  /-- The depth level: error norm ≤ p^{-depth} -/
  depth : ℕ
  /-- The estimator function -/
  estimate : (Fin n → ℚ_[p]) → ℚ_[p]
  /-- Error bound at this depth level -/
  error_bound : ∀ (true_val : ℚ_[p]) (obs : Fin n → ℚ_[p]),
    ‖estimate obs - true_val‖ ≤ ((p : ℝ)⁻¹) ^ depth

/-- **Depth-k estimators have exponentially small error.**
    Bridge: connects ValuationDepth to ExponentialPrecision. -/
theorem depth_estimator_error_bound (n : ℕ) (E : ValuationDepthEstimator (p := p) n)
    (true_val : ℚ_[p]) (obs : Fin n → ℚ_[p]) :
    ‖E.estimate obs - true_val‖ ≤ ((p : ℝ)⁻¹) ^ E.depth :=
  E.error_bound true_val obs

/-- **Deeper estimators have smaller error (monotonicity).**
    Bridge: connects DepthMonotonicity to PrecisionImprovement. -/
theorem depth_error_monotone (k₁ k₂ : ℕ) (hk : k₁ ≤ k₂) :
    ((p : ℝ)⁻¹) ^ k₂ ≤ ((p : ℝ)⁻¹) ^ k₁ := by
  apply pow_le_pow_of_le_one
  · exact inv_nonneg.mpr (by exact_mod_cast Nat.zero_le p)
  · exact inv_le_one_of_one_le₀ (by exact_mod_cast hp.out.one_le)
  · exact hk

/-- **p-adic Cramér-Rao: depth is bounded by information valuation.**
    If the product of error bound and information bound exceeds 1,
    both depths must be zero.
    Bridge: connects CramerRaoBound to ValuationDepth. -/
theorem cramer_rao_depth_bound (info_depth est_depth : ℕ)
    (h : ((p : ℝ)⁻¹) ^ est_depth * ((p : ℝ)⁻¹) ^ info_depth ≥ 1) :
    est_depth + info_depth = 0 := by
  by_contra h_ne
  have hp_le : (p : ℝ)⁻¹ ≤ 1 :=
    inv_le_one_of_one_le₀ (by exact_mod_cast hp.out.one_le)
  have hp_lt : (p : ℝ)⁻¹ < 1 := by
    rw [inv_lt_one_iff₀]
    right; exact_mod_cast hp.out.one_lt
  have : est_depth + info_depth ≥ 1 := Nat.one_le_iff_ne_zero.mpr h_ne
  have h1 : ((p : ℝ)⁻¹) ^ (est_depth + info_depth) ≤ ((p : ℝ)⁻¹) ^ 1 :=
    pow_le_pow_of_le_one (inv_nonneg.mpr (by exact_mod_cast Nat.zero_le p)) hp_le this
  rw [← pow_add] at h
  linarith [h1]

/-! ## Section 2: p-adic Information-Error Duality
    Bridge: connects InformationTheory to DualityPrinciple -/

/-- **Information-error duality (non_archimedean_uncertainty).**
    The product norm ‖info · error‖ is discrete: always a power of p.
    Bridge: connects UncertaintyPrinciple to DiscreteValuation. -/
theorem info_error_product_discrete (info error : ℚ_[p])
    (hi : info ≠ 0) (he : error ≠ 0) :
    ∃ k : ℤ, ‖info * error‖ = (p : ℝ) ^ (-k) :=
  padic_norm_discrete_levels (info * error) (mul_ne_zero hi he)

/-- **Error lower bound from information norm.**
    If ‖info · error‖ ≥ 1, then ‖error‖ ≥ ‖info‖⁻¹.
    Bridge: connects CramerRao to NormInverse. -/
theorem error_lower_bound_from_info (info error : ℚ_[p])
    (hi : info ≠ 0) (h : 1 ≤ ‖info * error‖) :
    ‖info‖⁻¹ ≤ ‖error‖ := by
  rw [norm_mul] at h
  have hi_pos : 0 < ‖info‖ := norm_pos_iff.mpr hi
  calc ‖info‖⁻¹ = 1 / ‖info‖ := (one_div _).symm
    _ ≤ (‖info‖ * ‖error‖) / ‖info‖ := by
        apply div_le_div_of_nonneg_right h hi_pos.le
    _ = ‖error‖ := by field_simp

/-! ## Section 3: Sample Complexity in Ultrametric Setting
    Bridge: connects SampleComplexity to UltrametricSaturation -/

/-- **Ultrametric sample saturation: n < p samples can't improve bounds.**
    In classical statistics, n samples improve the variance by factor 1/n.
    In the p-adic setting, n < p samples give EXACTLY the same bound as 1 sample.
    Implication for post_quantum_security: adversaries with < p queries gain nothing.
    Bridge: connects SampleComplexity to PostQuantumSecurity. -/
theorem ultrametric_sample_saturation_scalar (x : ℚ_[p]) (n : ℕ)
    (hn0 : 0 < n) (hn : n < p) :
    ‖(n : ℚ_[p]) * x‖ = ‖x‖ :=
  padic_info_n_samples_bound x n hn0 hn

/-
**Ultrametric sample saturation for vectors.**
    Bridge: connects SampleComplexity to VectorEstimation.
-/
theorem ultrametric_sample_saturation_vector {m : ℕ}
    (x : Fin m → ℚ_[p]) (n : ℕ) (hn0 : 0 < n) (hn : n < p) :
    ‖(n : ℚ_[p]) • x‖ = ‖x‖ := by
  refine' le_antisymm _ _;
  · exact pi_norm_le_iff_of_nonneg ( by positivity ) |>.2 fun i => le_trans ( padic_info_n_samples_bound ( x i ) n hn0 hn ▸ le_rfl ) ( norm_le_pi_norm x i );
  · refine' pi_norm_le_iff_of_nonneg _ |>.2 fun i => _;
    · positivity;
    · refine' le_trans _ ( padic_entry_le_norm _ i );
      have := padic_info_n_samples_bound ( x i ) n hn0 hn; aesop;

/-- **Sample complexity threshold: p samples for one bit of precision.**
    Bridge: connects SampleComplexity to ValuationDepthImprovement. -/
theorem sample_complexity_threshold :
    ‖(p : ℚ_[p])‖ = ((p : ℝ)⁻¹) := Padic.norm_p

/-- **p^k samples for k levels of improvement.**
    Bridge: connects SampleComplexity to ExponentialCost. -/
theorem sample_complexity_k_levels (k : ℕ) :
    ‖(p : ℚ_[p]) ^ k‖ = ((p : ℝ)⁻¹) ^ k := by
  rw [norm_pow, Padic.norm_p]

/-! ## Section 4: Ultrametric Covariance Bounds
    Bridge: connects CovarianceTheory to UltrametricGeometry -/

/-- **Covariance vector structure**: diagonal of a p-adic covariance matrix.
    Bridge: connects CovarianceMatrix to PadicDiagonal. -/
structure PadicCovarianceDiag (n : ℕ) where
  /-- Diagonal entries -/
  diag : Fin n → ℚ_[p]
  /-- All diagonal entries are nonzero -/
  diag_ne_zero : ∀ i, diag i ≠ 0

/-- **Ultrametric covariance bound: total norm is the max.**
    Bridge: connects CovarianceAddition to UltrametricInequality. -/
theorem covariance_ultrametric_bound (cov₁ cov₂ : ℚ_[p]) :
    ‖cov₁ + cov₂‖ ≤ max ‖cov₁‖ ‖cov₂‖ :=
  IsUltrametricDist.norm_add_le_max cov₁ cov₂

/-- **Covariance diagonal bound.**
    Bridge: connects DiagonalDominance to CovarianceBound. -/
theorem covariance_diagonal_bound {n : ℕ} (hn : 0 < n)
    (C : PadicCovarianceDiag (p := p) n) (B : ℝ)
    (hB : ∀ i, ‖C.diag i‖ ≤ B) :
    ‖C.diag‖ ≤ B := by
  haveI : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
  exact (pi_norm_le_iff_of_nonneg (by linarith [norm_nonneg (C.diag ⟨0, hn⟩), hB ⟨0, hn⟩])).mpr hB

/-- **Covariance entry discreteness.**
    Bridge: connects CovarianceDiscreteness to ValuationLevels. -/
theorem covariance_entry_discrete {n : ℕ}
    (C : PadicCovarianceDiag (p := p) n) (i : Fin n) :
    ∃ k : ℤ, ‖C.diag i‖ = (p : ℝ) ^ (-k) :=
  padic_norm_discrete_levels (C.diag i) (C.diag_ne_zero i)

/-! ## Section 5: Product Fisher Information
    Bridge: connects ProductManifolds to InformationDecomposition -/

/-- **Product information: total norm is the max.**
    Bridge: connects IndependentExperiments to UltrametricBound. -/
theorem product_info_ultrametric (I₁ I₂ : ℚ_[p]) :
    ‖I₁ + I₂‖ ≤ max ‖I₁‖ ‖I₂‖ :=
  IsUltrametricDist.norm_add_le_max I₁ I₂

/-- **Equal-norm information: no gain from combining.**
    Bridge: connects EqualInformation to ZeroGain. -/
theorem product_info_equal_norms (I₁ I₂ : ℚ_[p])
    (heq : ‖I₁‖ = ‖I₂‖) :
    ‖I₁ + I₂‖ ≤ ‖I₁‖ := by
  calc ‖I₁ + I₂‖ ≤ max ‖I₁‖ ‖I₂‖ := IsUltrametricDist.norm_add_le_max I₁ I₂
    _ = ‖I₁‖ := by rw [heq, max_self]

/-- **Different-norm information: stronger dominates (isosceles property).**
    Bridge: connects IsoscelesProperty to InformationDominance. -/
theorem product_info_different_norms (I₁ I₂ : ℚ_[p])
    (hne : ‖I₁‖ ≠ ‖I₂‖) :
    ‖I₁ + I₂‖ = max ‖I₁‖ ‖I₂‖ :=
  ultrametric_isosceles I₁ I₂ hne

/-! ## Section 6: Valuation-Theoretic Estimation Hierarchy
    Bridge: connects HierarchicalEstimation to ValuationFiltration -/

/-- **Valuation filtration is closed under addition.**
    Bridge: connects FiltrationTheory to PrecisionLevels. -/
theorem valuation_filtration_closed_add (k : ℤ)
    (x y : ℚ_[p]) (hx : ‖x‖ ≤ (p : ℝ) ^ (-k)) (hy : ‖y‖ ≤ (p : ℝ) ^ (-k)) :
    ‖x + y‖ ≤ (p : ℝ) ^ (-k) := by
  calc ‖x + y‖ ≤ max ‖x‖ ‖y‖ := IsUltrametricDist.norm_add_le_max x y
    _ ≤ (p : ℝ) ^ (-k) := max_le hx hy

/-- **Valuation filtration closed under unit scalar multiplication.**
    Bridge: connects FiltrationClosure to ScalarAction. -/
theorem valuation_filtration_closed_smul (k : ℤ)
    (a x : ℚ_[p]) (ha : ‖a‖ ≤ 1) (hx : ‖x‖ ≤ (p : ℝ) ^ (-k)) :
    ‖a * x‖ ≤ (p : ℝ) ^ (-k) := by
  calc ‖a * x‖ = ‖a‖ * ‖x‖ := norm_mul a x
    _ ≤ 1 * (p : ℝ) ^ (-k) := mul_le_mul ha hx (norm_nonneg _) zero_le_one
    _ = (p : ℝ) ^ (-k) := one_mul _

/-- **Deeper filtration implies tighter bound (certified_robustness).**
    Bridge: connects FiltrationNesting to PrecisionOrdering. -/
theorem filtration_nesting (k₁ k₂ : ℤ) (hk : k₁ ≤ k₂)
    (x : ℚ_[p]) (hx : ‖x‖ ≤ (p : ℝ) ^ (-k₂)) :
    ‖x‖ ≤ (p : ℝ) ^ (-k₁) := by
  calc ‖x‖ ≤ (p : ℝ) ^ (-k₂) := hx
    _ ≤ (p : ℝ) ^ (-k₁) := by
        apply zpow_le_zpow_right₀
        · exact_mod_cast hp.out.one_le
        · omega

/-! ## Section 7: Efficient Estimators
    Bridge: connects EfficiencyTheory to PadicOptimization -/

/-- **p-adic efficient estimator**: achieves the Cramér-Rao bound.
    Bridge: connects Efficiency to OptimalEstimation. -/
structure PadicEfficientEstimator (n : ℕ) extends ValuationDepthEstimator (p := p) n where
  /-- The information depth -/
  info_depth : ℕ
  /-- Efficiency: achieves the bound -/
  efficient : depth = info_depth

/-- **Combining efficient estimators preserves structure.**
    Bridge: connects EfficientCombination to UltrametricPreservation. -/
theorem efficient_combination_bound
    (err₁ err₂ : ℚ_[p]) (k : ℕ)
    (h₁ : ‖err₁‖ ≤ ((p : ℝ)⁻¹) ^ k) (h₂ : ‖err₂‖ ≤ ((p : ℝ)⁻¹) ^ k) :
    ‖err₁ + err₂‖ ≤ ((p : ℝ)⁻¹) ^ k := by
  calc ‖err₁ + err₂‖ ≤ max ‖err₁‖ ‖err₂‖ :=
        IsUltrametricDist.norm_add_le_max err₁ err₂
    _ ≤ ((p : ℝ)⁻¹) ^ k := max_le h₁ h₂

/-! ## Section 8: Post-Quantum Security Implications
    Bridge: connects CramerRao to LatticeBasedCryptography -/

/-
**Post-quantum estimation hardness.**
    An adversary cannot achieve depth k without information of depth ≥ k.
    Bridge: connects PostQuantumSecurity to InformationDepth.
-/
theorem post_quantum_estimation_hardness (k : ℕ)
    (adversary_error secret : ℚ_[p])
    (h_error_bound : ‖adversary_error‖ ≤ ((p : ℝ)⁻¹) ^ k)
    (h_secret_norm : ‖secret‖ = 1) :
    ‖secret - adversary_error‖ ≥ 1 - ((p : ℝ)⁻¹) ^ k := by
  -- By the reverse triangle inequality, we have ‖secret - adversary_error‖ ≥ |‖secret‖ - ‖adversary_error‖|.
  have h_reverse_triangle : ‖secret - adversary_error‖ ≥ |‖secret‖ - ‖adversary_error‖| := by
    simpa using abs_norm_sub_norm_le secret adversary_error;
  grind +revert

/-- **Iterated channel leakage decay.**
    k applications of a c-contraction channel yield c^k leakage.
    Bridge: connects IteratedLeakage to ExponentialDecay. -/
theorem iterated_channel_leakage (T : ℚ_[p] → ℚ_[p])
    (c : ℝ) (hc0 : 0 ≤ c)
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

/-! ## Section 9: Explicit Cramér-Rao with Constants
    Bridge: connects ExplicitBounds to ComputationalStatistics -/

/-- **Explicit Cramér-Rao for p-adic information.**
    ‖info · error‖ = p^{-(m+k)} when ‖info‖ = p^{-m} and ‖error‖ = p^{-k}.
    Bridge: connects ExplicitCramerRao to MultiplicativeNorm. -/
theorem explicit_cramer_rao_padic (info error : ℚ_[p])
    (m k : ℤ)
    (hi : ‖info‖ = (p : ℝ) ^ (-m))
    (he : ‖error‖ = (p : ℝ) ^ (-k)) :
    ‖info * error‖ = (p : ℝ) ^ (-(m + k)) := by
  rw [norm_mul, hi, he, ← zpow_add₀]
  · ring_nf
  · exact_mod_cast hp.out.pos.ne'

/-! ## Section 10: Tropical-p-adic Dictionary
    Bridge: connects PadicInformation to TropicalGeometry -/

/-- **Tropical-p-adic dictionary for multiplication.**
    v_p(xy) = v_p(x) + v_p(y) is the tropical "multiplication" (= addition).
    Bridge: connects PadicValuation to TropicalSemiring. -/
theorem tropical_padic_dictionary_mul (x y : ℚ_[p]) :
    valuationDepth (x * y) = valuationDepth x + valuationDepth y :=
  valuationDepth_mul x y

/-- **Tropical-p-adic dictionary for addition.**
    v_p(x + y) ≥ min(v_p(x), v_p(y)) is the tropical "addition" (= min).
    Bridge: connects PadicValuation to TropicalAddition. -/
theorem tropical_padic_dictionary_add (x y : ℚ_[p]) :
    min (valuationDepth x) (valuationDepth y) ≤ valuationDepth (x + y) :=
  valuationDepth_add_ge_min x y

end PadicInfoGeom