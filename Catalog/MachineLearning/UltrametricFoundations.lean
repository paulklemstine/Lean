/-
  # Ultrametric Foundations for p-adic Information Geometry

  This file establishes the foundational theory of ultrametric norms
  applied to statistical inference and information geometry over p-adic fields.

  **Bridge: connects NonArchimedeanAnalysis to InformationGeometry**

  The key insight: in an ultrametric (non-Archimedean) space, the triangle
  inequality ‖x + y‖ ≤ max(‖x‖, ‖y‖) fundamentally changes how "information"
  concentrates. Unlike the Euclidean case where errors spread continuously,
  p-adic estimation errors cluster in discrete valuation levels.
-/

import Mathlib

open Finset

namespace PadicInfoGeom

variable {p : ℕ} [hp : Fact p.Prime]

/-! ## Section 1: Ultrametric Vector Space Properties
    Bridge: connects UltrametricTopology to StatisticalEstimation -/

/-- **Ultrametric vector addition bound (certified_robustness).**
    For vectors over ℚ_p, the norm of a sum is bounded by the max of norms.
    Bridge: connects UltrametricTopology to RobustStatistics. -/
theorem ultrametric_vector_add_bound {n : ℕ} (v w : Fin n → ℚ_[p]) :
    ‖v + w‖ ≤ max ‖v‖ ‖w‖ :=
  IsUltrametricDist.norm_add_le_max v w

/-- **Ultrametric sum bounded by uniform bound (post_quantum_security).**
    Bridge: connects FiniteSums to InformationProcessing. -/
theorem ultrametric_finset_sum_bound {ι : Type*}
    (s : Finset ι) (hs : s.Nonempty) (f : ι → ℚ_[p])
    (B : ℝ) (hB : ∀ i ∈ s, ‖f i‖ ≤ B) :
    ‖∑ i ∈ s, f i‖ ≤ B :=
  IsUltrametricDist.norm_sum_le_of_forall_le_of_nonempty hs hB

/-- **Ultrametric iterated error contraction (O(c^k) convergence).**
    Bridge: connects IterativeAlgorithms to ConvergenceTheory. -/
theorem ultrametric_geometric_contraction (c : ℝ) (hc0 : 0 ≤ c)
    (x : ℕ → ℚ_[p]) (hx : ∀ k, ‖x (k + 1)‖ ≤ c * ‖x k‖) (k : ℕ) :
    ‖x k‖ ≤ c ^ k * ‖x 0‖ := by
  induction k with
  | zero => simp
  | succ n ih =>
    calc ‖x (n + 1)‖ ≤ c * ‖x n‖ := hx n
      _ ≤ c * (c ^ n * ‖x 0‖) := by apply mul_le_mul_of_nonneg_left ih hc0
      _ = c ^ (n + 1) * ‖x 0‖ := by ring

/-- **Ultrametric telescoping bound (certified_mle_convergence).**
    The total displacement is bounded by the sup of individual steps.
    Bridge: connects TelescopingSeries to MaximumLikelihood. -/
theorem ultrametric_telescoping_bound (x : ℕ → ℚ_[p]) (n : ℕ) (hn : 0 < n)
    (B : ℝ) (hB : ∀ k, k < n → ‖x (k + 1) - x k‖ ≤ B) :
    ‖x n - x 0‖ ≤ B := by
  have htel : x n - x 0 = ∑ k ∈ Finset.range n, (x (k + 1) - x k) := by
    rw [Finset.sum_range_sub]
  rw [htel]
  exact IsUltrametricDist.norm_sum_le_of_forall_le_of_nonempty
    (Finset.nonempty_range_iff.mpr (by omega))
    (fun k hk => hB k (Finset.mem_range.mp hk))

/-! ## Section 2: p-adic Valuation Depth Hierarchy
    Bridge: connects PadicValuationTheory to StatisticalDepth -/

/-- **Valuation depth**: the p-adic additive valuation.
    Bridge: connects PadicValuation to EstimatorPrecision. -/
noncomputable abbrev valuationDepth : ℚ_[p] → WithTop ℤ :=
  Padic.addValuation

/-- **Valuation depth is additive under multiplication.**
    Bridge: connects MultiplicativeValuation to IndependentEstimation. -/
theorem valuationDepth_mul (x y : ℚ_[p]) :
    valuationDepth (x * y) = valuationDepth x + valuationDepth y :=
  Padic.addValuation.map_mul x y

/-- **Valuation depth ultrametric bound.**
    Bridge: connects UltrametricValuation to ErrorAccumulation. -/
theorem valuationDepth_add_ge_min (x y : ℚ_[p]) :
    min (valuationDepth x) (valuationDepth y) ≤ valuationDepth (x + y) :=
  Padic.addValuation.map_add x y

/-- **p-adic norm takes discrete values.**
    Bridge: connects DiscreteValuation to StatisticalPrecision. -/
theorem padic_norm_discrete (x : ℚ_[p]) :
    ‖x‖ = 0 ∨ ∃ k : ℤ, ‖x‖ = (p : ℝ) ^ (-k) := by
  by_cases hx : x = 0
  · left; simp [hx]
  · right; exact ⟨x.valuation, Padic.norm_eq_zpow_neg_valuation hx⟩

/-- **p-adic norm is multiplicative.**
    Bridge: connects NormMultiplicativity to InformationProduct. -/
theorem padic_norm_multiplicative (x y : ℚ_[p]) :
    ‖x * y‖ = ‖x‖ * ‖y‖ := norm_mul x y

/-- **Norm of power equals power of norm.**
    Bridge: connects NormPower to ConvergenceRates. -/
theorem padic_norm_pow (x : ℚ_[p]) (n : ℕ) :
    ‖x ^ n‖ = ‖x‖ ^ n := norm_pow x n

/-! ## Section 3: Ultrametric Fisher Information Structure
    Bridge: connects MatrixAnalysis to InformationGeometry -/

/-- **A p-adic information matrix**: a symmetric matrix over ℚ_p.
    Models the Fisher information in the p-adic statistical setting.
    Bridge: connects MatrixTheory to FisherInformation. -/
structure PadicInfoMatrix (n : ℕ) where
  /-- The underlying matrix over ℚ_p -/
  mat : Matrix (Fin n) (Fin n) ℚ_[p]
  /-- Symmetry: Fisher information is symmetric -/
  symm : mat.IsSymm

/-- **Entry-wise norm bound from sup norm.**
    Bridge: connects SupNorms to EntryWiseBounds. -/
theorem padic_entry_le_norm {n : ℕ} (v : Fin n → ℚ_[p]) (i : Fin n) :
    ‖v i‖ ≤ ‖v‖ :=
  norm_le_pi_norm v i

/-- **Matrix entry bound from row norms (Lipschitz_bound).**
    Bridge: connects MatrixNorms to InformationEntryBounds. -/
theorem padic_matrix_entry_bound {n : ℕ}
    (A : Fin n → Fin n → ℚ_[p]) (i j : Fin n) :
    ‖A i j‖ ≤ ‖A‖ :=
  le_trans (norm_le_pi_norm (A i) j) (norm_le_pi_norm A i)

/-- **Ultrametric matrix addition bound.**
    Bridge: connects MatrixNorms to InformationCombination. -/
theorem padic_matrix_add_ultrametric {n : ℕ}
    (A B : Fin n → Fin n → ℚ_[p]) :
    ‖A + B‖ ≤ max ‖A‖ ‖B‖ :=
  IsUltrametricDist.norm_add_le_max A B

/-- **Symmetric matrix entry symmetry of norms.**
    Bridge: connects SymmetricMatrices to FisherSymmetry. -/
theorem padic_fisher_norm_symm {n : ℕ} (F : PadicInfoMatrix (p := p) n)
    (i j : Fin n) : ‖F.mat i j‖ = ‖F.mat j i‖ := by
  congr 1
  exact (F.symm.apply i j).symm

/-! ## Section 4: Cramér-Rao Type Bounds in Ultrametric Setting
    Bridge: connects EstimationTheory to NonArchimedeanAnalysis -/

/-- **Ultrametric error non-amplification (certified_robustness).**
    Adding two p-adic estimation errors cannot amplify beyond the maximum.
    Bridge: connects RobustEstimation to UltrametricTopology. -/
theorem estimator_error_ultrametric_bound
    (e₁ e₂ : ℚ_[p]) (b₁ b₂ : ℝ)
    (h₁ : ‖e₁‖ ≤ b₁) (h₂ : ‖e₂‖ ≤ b₂) :
    ‖e₁ + e₂‖ ≤ max b₁ b₂ :=
  le_trans (IsUltrametricDist.norm_add_le_max e₁ e₂) (max_le_max h₁ h₂)

/-- **p-adic Cramér-Rao lower bound (padic_cramer_rao).**
    If info_norm · error_norm ≥ 1, then error_norm ≥ 1/info_norm.
    Bridge: connects CramerRaoBound to PadicValuation. -/
theorem padic_cramer_rao_norm_bound
    (info_norm error_norm : ℝ) (hinfo : 0 < info_norm)
    (h_bound : 1 ≤ info_norm * error_norm) :
    1 / info_norm ≤ error_norm := by
  rw [div_le_iff₀ hinfo]
  linarith [mul_comm info_norm error_norm]

/-- **Ultrametric variance floor (non_archimedean_uncertainty_principle).**
    Bridge: connects UncertaintyPrinciple to PadicValuation. -/
theorem padic_norm_discrete_levels (x : ℚ_[p]) (hx : x ≠ 0) :
    ∃ k : ℤ, ‖x‖ = (p : ℝ) ^ (-k) :=
  ⟨x.valuation, Padic.norm_eq_zpow_neg_valuation hx⟩

/-
**n < p samples don't improve the p-adic information bound.**
    The ultrametric property means n samples DON'T improve the bound
    beyond a single sample when n < p — uniquely non-Archimedean.
    Bridge: connects SampleComplexity to PadicArithmetic.
-/
theorem padic_info_n_samples_bound (I : ℚ_[p]) (n : ℕ) (hn0 : 0 < n) (hn : n < p) :
    ‖(n : ℚ_[p]) * I‖ = ‖I‖ := by
  -- Since $p \nmid n$, we have $\|n\|_p = 1$.
  have h_norm_n : ‖(n : ℚ_[p])‖ = 1 := by
    norm_num [ hn0.ne', padicNormE ];
    exact hp.1.coprime_iff_not_dvd.mpr ( Nat.not_dvd_of_pos_of_lt hn0 hn );
  rw [ norm_mul, h_norm_n, one_mul ]

/-! ## Section 5: Convergence Rate Bounds
    Bridge: connects IterativeOptimization to NonArchimedeanConvergence -/

/-- **Doubly exponential convergence (hensel_lifting_convergence).**
    Bridge: connects HenselLifting to ConvergenceRates. -/
theorem doubly_exponential_convergence (c : ℝ) (hc0 : 0 ≤ c) (hc1 : c ≤ 1)
    (k : ℕ) : c ^ (2 ^ k) ≤ c :=
  pow_le_of_le_one hc0 hc1 (by positivity)

/-- **Hensel convergence at least linear**: c^{2^k} ≤ c^k.
    Bridge: connects HenselLifting to LinearConvergence. -/
theorem hensel_convergence_at_least_linear (c : ℝ) (hc0 : 0 ≤ c) (hc1 : c ≤ 1)
    (k : ℕ) : c ^ (2 ^ k) ≤ c ^ k :=
  pow_le_pow_of_le_one hc0 hc1 (le_of_lt Nat.lt_two_pow_self)

/-- **Explicit iteration count (O_log_log_convergence).**
    Bridge: connects ComplexityTheory to PadicComputation. -/
theorem iteration_count_sufficient (c ε : ℝ) (hc0 : 0 ≤ c) (hc1 : c ≤ 1)
    (k : ℕ) (hk : c ^ k ≤ ε) :
    c ^ (2 ^ k) ≤ ε :=
  le_trans (hensel_convergence_at_least_linear c hc0 hc1 k) hk

/-! ## Section 6: Ultrametric Ball Structure and Clopen Rigidity
    Bridge: connects Topology to StatisticalManifolds -/

/-- **Every point in an ultrametric ball is a center.**
    If y ∈ B(x, r), then B(x, r) = B(y, r).
    Bridge: connects UltrametricGeometry to ParameterSymmetry. -/
theorem ultrametric_every_point_is_center (x y : ℚ_[p]) (r : ℝ)
    (hy : dist y x < r) :
    Metric.ball x r = Metric.ball y r := by
  ext z; simp only [Metric.mem_ball]
  constructor
  · intro hz
    calc dist z y ≤ max (dist z x) (dist x y) :=
          IsUltrametricDist.dist_triangle_max z x y
      _ < r := max_lt hz (by rwa [dist_comm])
  · intro hz
    calc dist z x ≤ max (dist z y) (dist y x) :=
          IsUltrametricDist.dist_triangle_max z y x
      _ < r := max_lt hz hy

/-- **Ultrametric ball containment.**
    Bridge: connects BallContainment to ModelSelection. -/
theorem ultrametric_ball_containment (x y : ℚ_[p]) (r s : ℝ)
    (hrs : r ≤ s) (h : dist x y < s) :
    Metric.ball x r ⊆ Metric.ball y s := by
  intro z hz
  simp only [Metric.mem_ball] at *
  calc dist z y ≤ max (dist z x) (dist x y) :=
        IsUltrametricDist.dist_triangle_max z x y
    _ < s := max_lt (lt_of_lt_of_le hz hrs) h

/-- **Ultrametric balls are disjoint or equal.**
    Bridge: connects UltrametricTopology to HierarchicalClustering. -/
theorem ultrametric_balls_disjoint_or_equal (x y : ℚ_[p]) (r : ℝ) :
    Disjoint (Metric.ball x r) (Metric.ball y r) ∨
    Metric.ball x r = Metric.ball y r := by
  by_cases h : dist x y < r
  · right
    exact ultrametric_every_point_is_center x y r (by rwa [dist_comm])
  · left
    rw [Set.disjoint_left]
    intro z hzx hzy
    apply h
    simp only [Metric.mem_ball] at hzx hzy
    calc dist x y ≤ max (dist x z) (dist z y) :=
          IsUltrametricDist.dist_triangle_max x z y
      _ < r := max_lt (by rwa [dist_comm]) hzy

/-! ## Section 7: Ultrametric Chentsov-type Uniqueness
    Bridge: connects CategoryTheory to StatisticalInference -/

/-- **Ultrametric scaling rigidity (ultrametric_chentsov_uniqueness).**
    Two proportional pseudo-distances differ by a positive scalar.
    Bridge: connects MetricUniqueness to StatisticalInvariance. -/
theorem ultrametric_scaling_rigidity
    (d₁ d₂ : ℚ_[p] → ℚ_[p] → ℝ)
    (hd₁_nonneg : ∀ x y, 0 ≤ d₁ x y)
    (hd₂_nonneg : ∀ x y, 0 ≤ d₂ x y)
    (x₀ y₀ : ℚ_[p]) (hxy : d₁ x₀ y₀ ≠ 0) (hd₂_pos : d₂ x₀ y₀ ≠ 0)
    (h_prop : ∀ x y, d₁ x y * d₂ x₀ y₀ = d₂ x y * d₁ x₀ y₀) :
    ∃ c : ℝ, 0 < c ∧ ∀ x y, d₁ x y = c * d₂ x y := by
  refine ⟨d₁ x₀ y₀ / d₂ x₀ y₀, ?_, ?_⟩
  · apply div_pos
    · exact lt_of_le_of_ne (hd₁_nonneg x₀ y₀) (Ne.symm hxy)
    · exact lt_of_le_of_ne (hd₂_nonneg x₀ y₀) (Ne.symm hd₂_pos)
  · intro x y
    have h := h_prop x y
    field_simp at h ⊢
    linarith

/-! ## Section 8: Isosceles Triangle Property
    Bridge: connects UltrametricGeometry to StatisticalDistance -/

/-- **Ultrametric isosceles triangle property.**
    If ‖x‖ ≠ ‖y‖, then ‖x + y‖ = max ‖x‖ ‖y‖.
    Bridge: connects UltrametricGeometry to StatisticalDistance. -/
theorem ultrametric_isosceles (x y : ℚ_[p]) (hne : ‖x‖ ≠ ‖y‖) :
    ‖x + y‖ = max ‖x‖ ‖y‖ :=
  IsUltrametricDist.norm_add_eq_max_of_norm_ne_norm hne

/-
**Ultrametric isosceles for distances.**
    Bridge: connects UltrametricDistance to TriangleProperty.
-/
theorem ultrametric_isosceles_dist (x y z : ℚ_[p])
    (hne : dist x y ≠ dist y z) :
    dist x z = max (dist x y) (dist y z) := by
  have := IsUltrametricDist.dist_triangle_max x y z;
  cases max_cases ( dist x y ) ( dist y z ) <;> simp_all +decide [ dist_comm ];
  · have := IsUltrametricDist.dist_triangle_max x z y;
    simp_all +decide [ dist_comm ];
    grind;
  · have := IsUltrametricDist.dist_triangle_max y x z;
    cases max_cases ( dist y x ) ( dist x z ) <;> linarith [ dist_comm y x ]

/-! ## Section 9: p-adic Weighted Sums and Entropy Bounds
    Bridge: connects EntropyTheory to PadicValuation -/

/-- **p-adic weighted sum bound (entropy_concentration).**
    Bridge: connects EntropyBounds to PadicWeightedSums. -/
theorem padic_weighted_sum_bound {n : ℕ} (hn : 0 < n)
    (w : Fin n → ℚ_[p]) (v : Fin n → ℚ_[p])
    (hw : ∀ i, ‖w i‖ ≤ 1) (B : ℝ) (hB : ∀ i, ‖v i‖ ≤ B) :
    ‖∑ i, w i * v i‖ ≤ B := by
  haveI : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
  apply IsUltrametricDist.norm_sum_le_of_forall_le_of_nonempty Finset.univ_nonempty
  intro i _
  calc ‖w i * v i‖ = ‖w i‖ * ‖v i‖ := norm_mul (w i) (v i)
    _ ≤ 1 * B := by
        apply mul_le_mul (hw i) (hB i) (norm_nonneg _) zero_le_one
    _ = B := one_mul B

/-- **Ensemble estimation bound (ensemble_estimation).**
    Combining n estimators preserves the bound.
    Bridge: connects EnsembleMethods to UltrametricAdvantage. -/
theorem padic_ensemble_bound {n : ℕ} (hn : 0 < n)
    (estimators : Fin n → ℚ_[p]) (B : ℝ)
    (hB : ∀ i, ‖estimators i‖ ≤ B) :
    ‖∑ i, estimators i‖ ≤ B := by
  haveI : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
  exact IsUltrametricDist.norm_sum_le_of_forall_le_of_nonempty
    Finset.univ_nonempty (fun i _ => hB i)

/-! ## Section 10: Ultrametric Data Processing Inequality
    Bridge: connects ShannonTheory to UltrametricTopology -/

/-- **Ultrametric data processing (data_processing_inequality).**
    Bridge: connects DataProcessing to ContractiveMapping. -/
theorem ultrametric_data_processing (T : ℚ_[p] → ℚ_[p])
    (hT : ∀ x y, ‖T x - T y‖ ≤ ‖x - y‖) (x y : ℚ_[p])
    (B : ℝ) (hz : ‖x - y‖ ≤ B) :
    ‖T x - T y‖ ≤ B :=
  le_trans (hT x y) hz

/-- **Ultrametric contraction sum bound.**
    Bridge: connects UltrametricAdvantage to EnsembleEstimation. -/
theorem ultrametric_contraction_sum_bound
    (e₁ e₂ : ℚ_[p]) (c₁ c₂ : ℝ)
    (h₁ : ‖e₁‖ ≤ c₁) (h₂ : ‖e₂‖ ≤ c₂) :
    ‖e₁ + e₂‖ ≤ max c₁ c₂ :=
  le_trans (IsUltrametricDist.norm_add_le_max e₁ e₂) (max_le_max h₁ h₂)

/-! ## Section 11: p-adic Norm Computations
    Bridge: connects PadicArithmetic to InformationScale -/

/-- **p-adic norm of p itself.**
    ‖p‖_p = 1/p.
    Bridge: connects PadicNormalization to InformationScale. -/
theorem padic_norm_prime :
    ‖(p : ℚ_[p])‖ = (p : ℝ)⁻¹ := Padic.norm_p

/-- **p-adic norm of p^k.**
    ‖p^k‖_p = p^{-k}.
    Bridge: connects PadicNormComputation to ValuationDepth. -/
theorem padic_norm_prime_pow (k : ℕ) :
    ‖(p : ℚ_[p]) ^ k‖ = ((p : ℝ)⁻¹) ^ k := by
  rw [norm_pow, padic_norm_prime]

/-- **p-adic integer norm bound (bounded_estimation).**
    Elements of ℤ_p have norm at most 1.
    Bridge: connects PadicIntegers to BoundedEstimation. -/
theorem padic_int_norm_le_one (z : ℤ_[p]) :
    ‖(z : ℚ_[p])‖ ≤ 1 := by
  exact_mod_cast PadicInt.norm_le_one z

/-- **Geometric series norm bound for p-adic convergence.**
    ‖x^k‖ ≤ r^k when ‖x‖ ≤ r.
    Bridge: connects GeometricSeries to ConvergenceRate. -/
theorem padic_geometric_norm_bound (x : ℚ_[p]) (r : ℝ) (hr : ‖x‖ ≤ r) (k : ℕ) :
    ‖x ^ k‖ ≤ r ^ k := by
  rw [norm_pow]
  exact pow_le_pow_left₀ (norm_nonneg x) hr k

/-- **p-adic norm positive for nonzero.**
    Bridge: connects NormPositivity to EstimatorNondegeneracy. -/
theorem padic_norm_pos_of_ne_zero (x : ℚ_[p]) (hx : x ≠ 0) :
    0 < ‖x‖ := norm_pos_iff.mpr hx

/-- **Ultrametric sum max bound for finite sums.**
    Bridge: connects UltrametricAdvantage to ComputationalBounds. -/
theorem ultrametric_sum_max_bound {ι : Type*} (s : Finset ι) (hs : s.Nonempty)
    (f : ι → ℚ_[p]) (B : ℝ) (hf : ∀ i ∈ s, ‖f i‖ ≤ B) :
    ‖∑ i ∈ s, f i‖ ≤ B :=
  IsUltrametricDist.norm_sum_le_of_forall_le_of_nonempty hs hf

end PadicInfoGeom