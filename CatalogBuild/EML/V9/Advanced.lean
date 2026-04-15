/-! # CatalogBuild.EML.V9.Advanced

Auto-generated from theorem catalog database.
Domain: EML/V9
Declarations: 25
-/

import Mathlib

noncomputable section

/-- [Section: ## Definitions] -/
def emlA (x y : ℝ) : ℝ := Real.exp x - Real.log y

def diagA (z : ℝ) : ℝ := Real.exp z - Real.log z

def gmapA (z : ℝ) : ℝ := Real.exp 1 - Real.log z


def diagIterA : ℕ → ℝ → ℝ
  | 0, z => z
  | n + 1, z => diagA (diagIterA n z)


/-- [Section: ## Section 1: Enhanced Diagonal Bounds] -/
theorem diagA_gt_z (z : ℝ) : diagA z > z := by
  unfold diagA;
  nontriviality;
  by_cases h3 : z ≤ 0;
  · by_contra h_neg;
    exact h_neg <| by have := Real.log_le_sub_one_of_pos ( neg_pos.mpr <| lt_of_le_of_ne h3 <| by rintro rfl; norm_num at * ) ; norm_num at * ; linarith [ Real.exp_pos z, Real.exp_neg z, mul_inv_cancel₀ <| ne_of_gt <| Real.exp_pos z, Real.add_one_le_exp z, Real.add_one_le_exp <| -z ] ;
  · have := Real.add_one_le_exp ( z - 1 );
    rw [ show z = z - 1 + 1 by ring, Real.exp_add ];
    nlinarith [ Real.add_one_le_exp 1, Real.log_le_sub_one_of_pos ( by linarith : 0 < z - 1 + 1 ) ]


theorem diagA_ge_z_add_one (z : ℝ) : diagA z ≥ z + 1 := by
  unfold diagA;
  by_cases h : 0 < z;
  · have := Real.log_le_sub_one_of_pos ( div_pos ( Real.exp_pos z ) h );
    rw [ Real.log_div ( by positivity ) ( by positivity ), Real.log_exp ] at this;
    nlinarith [ Real.add_one_le_exp z, Real.log_le_sub_one_of_pos h, mul_div_cancel₀ ( Real.exp z ) h.ne' ];
  · by_cases hz : z = 0;
    · norm_num [ hz ];
    · nlinarith [ Real.exp_pos z, Real.exp_neg z, mul_inv_cancel₀ ( ne_of_gt ( Real.exp_pos z ) ), Real.add_one_le_exp z, Real.log_le_sub_one_of_pos ( neg_pos.mpr ( lt_of_le_of_ne ( le_of_not_gt h ) hz ) ), Real.log_neg_eq_log z ]


theorem diagA_strong_bound (z : ℝ) (hz : 1 ≤ z) :
    diagA z ≥ Real.exp z - z + 1 := by
  unfold diagA; nlinarith [ Real.add_one_le_exp 1, Real.exp_pos z, Real.log_le_sub_one_of_pos ( by linarith : 0 < z ) ] ;


theorem diagA_orbit_linear (z : ℝ) (n : ℕ) :
    diagIterA n z ≥ z + n := by
  induction' n with n ih generalizing z <;> norm_num [ diagIterA ] at *;
  linarith [ ih z, diagA_ge_z_add_one ( diagIterA n z ) ]


theorem diagA_orbit_gap_mono (z : ℝ) (hz : 0 < z) (n : ℕ) :
    diagA (diagIterA (n + 1) z) - diagIterA (n + 1) z ≥
    diagA (diagIterA n z) - diagIterA n z := by
  -- The minimum value occurs at $w=0$. For $w > 0$, $\exp(w)$ grows faster than $\log(w)$, so $g(w)$ is increasing.
  have hg_deriv_pos : ∀ w ≥ 2, 0 < deriv (fun w => Real.exp w - Real.log w - w) w := by
    intro w hw; norm_num [ Real.differentiableAt_exp, Real.differentiableAt_log, ne_of_gt ( zero_lt_two.trans_le hw ) ] ;
    nlinarith [ inv_mul_cancel₀ ( by linarith : w ≠ 0 ), Real.add_one_le_exp w ];
  -- Since $g(w)$ is increasing for $w \geq 2$, and $diagIterA n z \geq 2$ for $n \geq 1$, we have $g(diagIterA (n + 1) z) \geq g(diagIterA n z)$.
  have hg_monotone : ∀ n ≥ 1, diagIterA n z ≥ 2 := by
    intro n hn; induction hn <;> simp_all +decide [ diagA ] ;
    · exact show 2 ≤ Real.exp z - Real.log z from by linarith [ Real.add_one_le_exp z, Real.log_le_sub_one_of_pos hz ] ;
    · exact le_trans ‹_› ( by exact le_trans ( by norm_num ) ( diagA_ge_z_add_one _ ) );
  by_cases hn : n ≥ 1;
  · -- Since $g$ is increasing for $w \geq 2$, we have $g(diagIterA (n + 1) z) \geq g(diagIterA n z)$.
    have hg_inc : ∀ w1 w2 : ℝ, 2 ≤ w1 → w1 ≤ w2 → Real.exp w1 - Real.log w1 - w1 ≤ Real.exp w2 - Real.log w2 - w2 := by
      intros w1 w2 hw1 hw2
      by_contra h_contra;
      have := exists_deriv_eq_slope ( fun w => Real.exp w - Real.log w - w ) ( show w1 < w2 from lt_of_le_of_ne hw2 ( by aesop_cat ) ) ; norm_num at *;
      exact absurd ( this ( by exact ContinuousOn.sub ( ContinuousOn.sub ( Real.continuousOn_exp ) ( Real.continuousOn_log.mono ( by intro x hx; norm_num; linarith [ hx.1 ] ) ) ) continuousOn_id ) ( by exact DifferentiableOn.sub ( DifferentiableOn.sub ( Real.differentiable_exp.differentiableOn ) ( Real.differentiableOn_log.mono ( by intro x hx; norm_num; linarith [ hx.1 ] ) ) ) differentiableOn_id ) ) ( by rintro ⟨ c, ⟨ h₁, h₂ ⟩, h₃ ⟩ ; rw [ eq_div_iff ] at h₃ <;> nlinarith [ hg_deriv_pos c ( by linarith ) ] );
    exact hg_inc _ _ ( hg_monotone _ hn ) ( show diagIterA n z ≤ diagIterA ( n + 1 ) z from by { exact le_of_lt ( show diagIterA n z < diagIterA ( n + 1 ) z from by { exact diagA_gt_z _ } ) } );
  · interval_cases n ; norm_num [ diagA, diagIterA ];
    -- We'll use that $Real.exp z - Real.log z \geq 2$ for $z > 0$.
    have h_exp_log : Real.exp z - Real.log z ≥ 2 := by
      linarith [ hg_monotone 1 le_rfl, show diagIterA 1 z = Real.exp z - Real.log z from by rfl ];
    have := Real.add_one_le_exp ( Real.exp z - Real.log z - 1 );
    rw [ show Real.exp ( Real.exp z - Real.log z ) = Real.exp ( Real.exp z - Real.log z - 1 ) * Real.exp 1 by rw [ ← Real.exp_add ] ; ring ];
    have := Real.log_le_sub_one_of_pos ( by linarith : 0 < ( Real.exp z - Real.log z ) / 2 );
    rw [ Real.log_div ] at this <;> norm_num at * <;> try linarith;
    have := Real.exp_one_gt_d9.le ; norm_num1 at * ; nlinarith [ Real.log_le_sub_one_of_pos zero_lt_two, Real.log_le_sub_one_of_pos hz ]


/-- The Bregman divergence for f(x) = eˣ is D_f(x,y) = eˣ − eʸ − eʸ(x−y).
This connects to EML via: D_f(x,y) = eml(x,1) − eml(y,1) − eʸ(x−y). -/
theorem eml_bregman_exp (x y : ℝ) :
    Real.exp x - Real.exp y - Real.exp y * (x - y) =
    (emlA x 1 - emlA y 1) - Real.exp y * (x - y) := by
  simp [emlA, Real.log_one]


/-- Chain identity: eml(eml(x,1), 1) = exp(exp(x)). -/
theorem eml_chain (x : ℝ) : emlA (emlA x 1) 1 = Real.exp (Real.exp x) := by
  simp [emlA, Real.log_one]


/-- Triple chain: eml³(x) = exp(exp(exp(x))). -/
theorem eml_triple_chain (x : ℝ) :
    emlA (emlA (emlA x 1) 1) 1 = Real.exp (Real.exp (Real.exp x)) := by
  simp [emlA, Real.log_one]


/-- Shift identity: eml(x + a, y) = eᵃ · eml(x, y^(eᵃ)) + eᵃ·ln(y) − ln(y).
Simplified: eml(x+a, y) = eᵃ · eˣ − ln(y). -/
theorem eml_shift (x a y : ℝ) :
    emlA (x + a) y = Real.exp a * Real.exp x - Real.log y := by
  simp [emlA, Real.exp_add]; ring


/-- Scale identity for the second argument.
eml(x, y^n) = eml(x, y) − (n−1)·ln(y) for y > 0. -/
theorem eml_power_snd (x y : ℝ) (n : ℕ) (hy : 0 < y) :
    emlA x (y ^ n) = emlA x y - (n - 1) * Real.log y := by
  simp [emlA, Real.log_pow]; ring


/-- [Section: ## Section 5: Integral Identities] -/
theorem eml_integral_log :
    ∫ t in (1:ℝ)..Real.exp 1, emlA 0 t = Real.exp 1 - 2 := by
      norm_num [ emlA ];
      ring


/-- exp(x) − x ≥ 1 for all x (fundamental lower bound). -/
theorem exp_sub_x_ge_one (x : ℝ) : Real.exp x - x ≥ 1 := by
  linarith [Real.add_one_le_exp x]


/-- exp(x) − x is minimized at x = 0. -/
theorem exp_sub_x_min_at_zero : ∀ x : ℝ, Real.exp x - x ≥ Real.exp 0 - 0 := by
  intro x; simp; linarith [Real.add_one_le_exp x]


/-- g(e) = e − 1 < e, so g maps [1, e] into itself. -/
theorem gmapA_at_e : gmapA (Real.exp 1) = Real.exp 1 - 1 := by
  simp [gmapA, Real.log_exp]


/-- g(1) = e > 1. -/
theorem gmapA_at_one : gmapA 1 = Real.exp 1 := by
  simp [gmapA, Real.log_one]


/-- g maps (0, ∞) to ℝ. -/
theorem gmapA_deriv (z : ℝ) (hz : 0 < z) :
    HasDerivAt gmapA (-z⁻¹) z := by
  unfold gmapA
  exact ((hasDerivAt_const z (Real.exp 1)).sub (Real.hasDerivAt_log hz.ne'))
    |>.congr_deriv (by ring)


/-- For a, b > 0: eml(ln a, b) + eml(ln b, a) ≥ 2. -/
theorem eml_amgm_trace_ge_two (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    emlA (Real.log a) b + emlA (Real.log b) a ≥ 2 := by
  simp [emlA, Real.exp_log ha, Real.exp_log hb]
  linarith [Real.log_le_sub_one_of_pos ha, Real.log_le_sub_one_of_pos hb]


/-- The diagonal satisfies exp(x) − ln(x) ≥ 2 for x > 0. -/
theorem diagA_ge_two (z : ℝ) (hz : 0 < z) : diagA z ≥ 2 := by
  unfold diagA
  have h1 := Real.add_one_le_exp z
  have h2 := Real.log_le_sub_one_of_pos hz
  linarith


/-- [Section: ## Section 11: Tropical EML] -/
theorem tropEml_noncomm : ∃ x y : ℝ, tropEml x y ≠ tropEml y x := by
  use 0, 1; simp [tropEml]


theorem tropEml_diag (x : ℝ) : tropEml x x = |x| := by
  simp only [tropEml, abs_eq_max_neg]


/-- Tropical EML is idempotent when x = −y is impossible:
trop(x, −x) = max(x, x) = x. -/
theorem tropEml_neg_snd (x : ℝ) : tropEml x (-x) = x := by
  simp [tropEml]


end
