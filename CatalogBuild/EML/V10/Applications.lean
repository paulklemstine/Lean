/-! # CatalogBuild.EML.V10.Applications

Auto-generated from theorem catalog database.
Domain: EML/V10
Declarations: 21
-/

import Mathlib

noncomputable section

/-- Shannon entropy term: −p·ln(p) = p·eml(0,p) − p. -/
theorem eml_entropy_decomp (p : ℝ) :
    -p * Real.log p = p * eml 0 p - p := by
  unfold eml; simp; ring


/-- KL divergence term: p·ln(p/q) = p·(eml(0,q) − eml(0,p)). -/
theorem eml_kl_decomp (p q : ℝ) (hp : 0 < p) (hq : 0 < q) :
    p * Real.log (p / q) = p * (eml 0 q - eml 0 p) := by
  unfold eml; rw [Real.log_div hp.ne' hq.ne']; ring


/-- Gibbs' inequality: p·ln(p/q) ≥ p − q for p, q > 0. -/
theorem eml_gibbs_inequality (p q : ℝ) (hp : 0 < p) (hq : 0 < q) :
    p * Real.log (p / q) ≥ p - q := by
  have h : -Real.log (p / q) ≤ q / p - 1 := by
    have := Real.log_le_sub_one_of_pos (div_pos (by positivity : (0:ℝ) < 1) (div_pos hp hq))
    rw [one_div, Real.log_inv, inv_div] at this; exact this
  have h2 := mul_le_mul_of_nonneg_left h hp.le
  have h3 : p * (q / p - 1) = q - p := by field_simp
  linarith


/-- Cross-entropy via EML: −p·ln(q) = p·(eml(0,q) − 1). -/
theorem eml_cross_entropy (p q : ℝ) :
    -p * Real.log q = p * (eml 0 q - 1) := by
  unfold eml; simp


/-- Free energy via EML: −kT·ln(Z) = kT·(eml(0,Z) − 1). -/
theorem eml_free_energy (kT Z : ℝ) :
    -kT * Real.log Z = kT * (eml 0 Z - 1) := by
  unfold eml; simp


/-- Boltzmann weight as EML: exp(−βE) = eml(−βE, 1). -/
theorem eml_boltzmann (β E : ℝ) :
    Real.exp (-β * E) = eml (-β * E) 1 := by
  simp [eml, Real.log_one]


/-- ln(Z) = −eml(0, Z) + 1. -/
theorem eml_partition_log (Z : ℝ) :
    Real.log Z = -(eml 0 Z) + 1 := by
  unfold eml; simp


/-- The log-partition function: A(θ) = −ln(θ) = eml(0, θ) − 1. -/
theorem eml_exp_family_logpartition (θ : ℝ) :
    -Real.log θ = eml 0 θ - 1 := by
  unfold eml; simp


/-- The conjugate dual: A*(η) = −1 − ln(−η) = eml(0, −η) − 2. -/
theorem eml_exp_family_conjugate (η : ℝ) :
    -1 - Real.log (-η) = eml 0 (-η) - 2 := by
  unfold eml; simp; ring


/-- EML loss ≥ 1 with minimum at 0. -/
theorem eml_loss_ge_one (r : ℝ) : emlSelfPair r ≥ 1 := by
  unfold emlSelfPair; linarith [Real.add_one_le_exp r]


/-- [Section: # CatalogBuild.EML.V10.Applications
Auto-generated from theorem catalog database.
Domain: EML/V10
Declarations: 21] -/
theorem eml_loss_at_zero : emlSelfPair 0 = 1 := by simp [emlSelfPair]


/-- The EML loss gradient vanishes at r = 0. -/
theorem eml_loss_deriv_zero :
    HasDerivAt emlSelfPair 0 0 := by
  have h := (Real.hasDerivAt_exp (0 : ℝ)).sub (hasDerivAt_id (0 : ℝ))
  simp at h; exact h


/-- EML loss dominates squared loss for r ≥ 2. -/
theorem eml_loss_dominates_sq (r : ℝ) (hr : 2 ≤ r) :
    emlSelfPair r ≥ r ^ 2 := by
  unfold emlSelfPair
  have h5 : Real.exp r ≥ 1 + r + r ^ 2 / 2 + r ^ 3 / 6 := by
    rw [Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div]
    exact le_trans (by norm_num [Finset.sum_range_succ])
      (Summable.sum_le_tsum (Finset.range 4)
        (fun i _ => by positivity) (Real.summable_pow_div_factorial r))
  nlinarith [sq_nonneg r, sq_nonneg (r - 1), sq_nonneg (r - 2)]


/-- The activation gradient: σ'(x) = eˣ − 1. -/
theorem eml_activation_deriv (x : ℝ) :
    HasDerivAt emlSelfPair (Real.exp x - 1) x := by
  unfold emlSelfPair
  exact (Real.hasDerivAt_exp x).sub (hasDerivAt_id x) |>.congr_deriv (by ring)


/-- Positive gradient for x > 0 (non-saturating). -/
theorem eml_activation_gradient_pos (x : ℝ) (hx : 0 < x) :
    Real.exp x - 1 > 0 := by
  linarith [Real.add_one_le_exp x]


/-- Negative gradient for x < 0 (nonzero except at 0). -/
theorem eml_activation_neg_gradient (x : ℝ) (hx : x < 0) :
    Real.exp x - 1 < 0 := by
  have : Real.exp x < 1 := by rw [← Real.exp_zero]; exact Real.exp_lt_exp.mpr hx
  linarith


/-- [Section: # CatalogBuild.EML.V10.Applications
Auto-generated from theorem catalog database.
Domain: EML/V10
Declarations: 21] -/
theorem eml_code_length (q : ℝ) : -Real.log q = eml 0 q - 1 := by unfold eml; simp


/-- [Section: # CatalogBuild.EML.V10.Applications
Auto-generated from theorem catalog database.
Domain: EML/V10
Declarations: 21] -/
theorem eml_redundancy (p q : ℝ) (hp : 0 < p) (hq : 0 < q) :
    p * Real.log (p / q) = p * (eml 0 q - eml 0 p) := by
  unfold eml; rw [Real.log_div hp.ne' hq.ne']; ring


theorem bregman_exp_nonneg (x y : ℝ) :
    Real.exp x - Real.exp y - Real.exp y * (x - y) ≥ 0 := by
  rw [show x = y + (x - y) by ring, Real.exp_add]
  nlinarith [Real.add_one_le_exp (x - y), Real.exp_pos y]


theorem eml_cumulant (Mt : ℝ) : Real.log Mt = -(eml 0 Mt) + 1 := by unfold eml; simp


/-- σ(x) ≥ |x| for |x| ≤ 1. -/
theorem eml_regularizer_dominates_abs (x : ℝ) (hx : |x| ≤ 1) :
    emlSelfPair x ≥ |x| := by
  unfold emlSelfPair
  rcases le_or_gt x 0 with hx0 | hx0
  · rw [abs_of_nonpos hx0]; linarith [Real.exp_pos x]
  · rw [abs_of_pos hx0] at hx ⊢
    have h5 : Real.exp x ≥ 1 + x + x ^ 2 / 2 := by
      rw [Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div]
      exact le_trans (by norm_num [Finset.sum_range_succ])
        (Summable.sum_le_tsum (Finset.range 3)
          (fun i _ => by positivity) (Real.summable_pow_div_factorial x))
    nlinarith [sq_nonneg (x - 1)]


end
