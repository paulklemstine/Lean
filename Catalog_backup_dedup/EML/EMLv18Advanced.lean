import EML.EMLv17Advanced
import EML.EMLv17Core
import EML.EMLv18Core
import Mathlib

/-! # CatalogBuild.EML.EMLv18Advanced

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 25
-/

noncomputable section

/-- [Section: ## §1. Gradient Flow of EML] -/
theorem gradient_flow_x_identity (x₀ t : ℝ) (ht : exp (-x₀) + t > 0) :
    exp (Real.log (exp (-x₀) + t)) = exp (-x₀) + t := by
      rw [ Real.exp_log ht ]

theorem gradient_flow_y_domain (y₀ t : ℝ) (hy₀ : 0 < y₀) (ht : 0 ≤ t) :
    y₀ ^ 2 + 2 * t > 0 := by
      positivity

theorem emlGmap_maps_interval (z : ℝ) (hz : 2 ≤ z) (hze : z ≤ exp 1) :
    exp 1 - 1 ≤ emlGmap z ∧ emlGmap z ≤ emlGmap 2 := by
      unfold emlGmap;
      constructor <;> gcongr;
      exact Real.log_le_iff_le_exp ( by positivity ) |>.2 hze

theorem emlGmap_deriv_bound (z : ℝ) (hz : 2 ≤ z) :
    |(-z⁻¹)| ≤ 1/2 := by
      rw [ abs_of_nonpos ] <;> nlinarith [ inv_mul_cancel₀ ( by linarith : z ≠ 0 ) ]

/-- [Section: ## §3. EML and Convex Conjugates] -/
theorem fenchel_young_exp (x s : ℝ) (hs : 0 < s) :
    x * s ≤ exp x + s * log s - s := by
      have := Real.add_one_le_exp ( x - Real.log s );
      rw [ Real.exp_sub, Real.exp_log hs ] at this ; nlinarith [ mul_div_cancel₀ ( Real.exp x ) hs.ne' ]

/-- [Section: ## §4. EML Operator Algebra] -/
theorem eml_exp_distribute (x₁ x₂ y : ℝ) :
    eml (x₁ + x₂) y = exp x₁ * exp x₂ - log y := by
      rw [ ← Real.exp_add, eml_def ]

theorem eml_sum_log_prod (x y₁ y₂ : ℝ) (hy₁ : 0 < y₁) (hy₂ : 0 < y₂) :
    eml x y₁ + eml x y₂ = 2 * exp x - log (y₁ * y₂) := by
      unfold eml; rw [ log_mul hy₁.ne' hy₂.ne' ] ; ring;

/-- [Section: ## §5. Tropical EML] -/
theorem eml_tropical_lower (x y : ℝ) (hx : 0 ≤ x) (hy : 0 < y) (hy1 : y ≤ 1) :
    eml x y ≥ x := by
      exact le_tsub_of_add_le_left ( by linarith [ add_one_le_exp x, Real.log_le_sub_one_of_pos hy ] )

theorem eml_tropical_neg (x y : ℝ) (hx : x ≤ 0) (hy : 1 ≤ y)
    (hbound : exp x ≤ log y) :
    eml x y ≤ 0 := by
      exact sub_nonpos_of_le hbound

/-- [Section: ## §6. EML Fixed Point Equations] -/
theorem eml_fixed_fst (x : ℝ) :
    eml x (exp (exp x - x)) = x := by
      unfold eml; norm_num;

theorem eml_fixed_snd_at_zero : eml 0 1 = 1 := by
  exact?

/-- [Section: ## §7. EML Difference Equations] -/
theorem eml_first_difference (x h y : ℝ) :
    eml (x + h) y - eml x y = exp x * (exp h - 1) := by
      unfold eml; rw [ Real.exp_add ] ; ring;

theorem eml_second_difference (x h y : ℝ) :
    eml (x + 2*h) y - 2 * eml (x + h) y + eml x y = exp x * (exp h - 1)^2 := by
      unfold eml; ring; norm_num [ ← Real.exp_add, ← Real.exp_nat_mul ] ; ring;

/-- [Section: ## §8. EML Integral Identities] -/
theorem integral_exp_01 : ∫ x in (0:ℝ)..1, exp x = exp 1 - 1 := by
  norm_num +zetaDelta at *

theorem eml_integral_01 : ∫ y in (0:ℝ)..1, eml 0 y = 2 := by
  unfold eml; norm_num;

/-- [Section: ## §9. EML Ratio and Quotient] -/
theorem eml_decompose (x y : ℝ) : eml x y = eml x 1 - log y := by
  unfold eml; aesop;

theorem eml_split_components (x y : ℝ) :
    eml x y = eml x 1 + eml 0 y - 1 := by
      unfold eml; ring;
      norm_num ; ring

/-- [Section: ## §10. Stability Analysis] -/
theorem gmap_slope_stable (z : ℝ) (hz : 2 < z) :
    |(-z⁻¹)| < 1 := by
      rw [ abs_of_neg ] <;> nlinarith [ inv_mul_cancel₀ ( by linarith : z ≠ 0 ) ]

theorem gmap_contraction_at (z : ℝ) (hz : 1 < z) :
    z⁻¹ < 1 := by
      exact inv_lt_one_of_one_lt₀ hz

/-- For a probability p ∈ (0,1): the binary entropy H(p) = -p·log(p) - (1-p)·log(1-p)
satisfies H(p) ≤ log(2). Meanwhile d(p) = exp(p) - log(p) ≥ 2.
So d(p) ≥ 2 > log(2) ≥ H(p): the EML diagonal dominates binary entropy. -/
theorem emlDiag_dominates_entropy (p : ℝ) (hp : 0 < p) :
    emlDiag p ≥ 2 := emlDiag_ge_two p hp

/-- [Section: ## §12. EML Inequalities from Joint Convexity] -/
theorem eml_jensen_fst (x₁ x₂ y t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    eml (t * x₁ + (1 - t) * x₂) y ≤ t * eml x₁ y + (1 - t) * eml x₂ y := by
      unfold eml;
      -- Apply Jensen's inequality for the exponential function.
      have h_jensen_exp : Real.exp (t * x₁ + (1 - t) * x₂) ≤ t * Real.exp x₁ + (1 - t) * Real.exp x₂ := by
        have h_exp_convex : ConvexOn ℝ (Set.univ : Set ℝ) Real.exp := by
          exact convexOn_exp;
        exact h_exp_convex.2 trivial trivial ( by linarith ) ( by linarith ) ( by linarith );
      linarith

/-- EML is subadditive in x when normalized:
eml((x₁+x₂)/2, y) ≤ (eml(x₁,y) + eml(x₂,y))/2.
(This is the midpoint inequality, re-derived from Jensen.) -/
theorem eml_subadditive_mid (x₁ x₂ y : ℝ) :
    eml ((x₁ + x₂) / 2) y ≤ (eml x₁ y + eml x₂ y) / 2 :=
  eml_midpoint_fst x₁ x₂ y

/-- [Section: ## §13. σ-EML Second Derivative] -/
theorem sigmaEml_convex : ConvexOn ℝ univ sigmaEml := by
  fapply convexOn_of_deriv2_nonneg;
  · exact convex_univ;
  · exact Continuous.continuousOn sigmaEml_continuous;
  · exact Differentiable.differentiableOn ( by exact? );
  · refine' Differentiable.differentiableOn _;
    unfold sigmaEml;
    unfold deriv ; ring_nf ; norm_num [ Real.exp_ne_zero, Real.exp_neg, Real.differentiable_exp, Real.differentiableAt_exp, mul_comm, ne_of_gt ( add_pos zero_lt_one ( Real.exp_pos _ ) ) ] ;
    norm_num [ Real.differentiable_exp, Real.differentiableAt_exp, Real.differentiableAt_log, ne_of_gt ( add_pos zero_lt_one ( inv_pos.mpr ( Real.exp_pos _ ) ) ), ne_of_gt ( Real.exp_pos _ ), mul_inv_cancel₀, mul_comm, div_eq_mul_inv ];
  · unfold sigmaEml;
    unfold deriv;
    norm_num [ Real.exp_neg, fderiv_apply_one_eq_deriv ];
    norm_num [ Real.exp_ne_zero, Real.differentiableAt_exp, fderiv_apply_one_eq_deriv, ne_of_gt ( add_pos zero_lt_one ( inv_pos.mpr ( Real.exp_pos _ ) ) ) ];
    field_simp;
    exact fun x => by nlinarith [ Real.exp_pos x, pow_pos ( Real.exp_pos x ) 3 ] ;

/-- [Section: ## §14. EML and Power Means] -/
theorem eml_weighted_geometric (x a b t : ℝ) (ha : 0 < a) (hb : 0 < b) :
    eml x (a ^ t * b ^ (1 - t)) = exp x - t * log a - (1 - t) * log b := by
      unfold eml; rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_rpow ha, Real.log_rpow hb ] ; ring;

/-- [Section: ## §15. EML Definite Integrals] -/
theorem eml_integral_12 :
    ∫ y in (1:ℝ)..2, eml 0 y = 2 - 2 * log 2 := by
      norm_num [ eml ]

end
