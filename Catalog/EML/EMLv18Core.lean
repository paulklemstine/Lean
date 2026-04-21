/-! # CatalogBuild.EML.EMLv18Core

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 39
-/

import EML.EMLv17Advanced
import EML.EMLv17Core
import Mathlib

noncomputable section

/-- The second derivative of the diagonal d(z) = e^z - ln z is e^z + 1/z²,
which is strictly positive for z > 0. -/
theorem emlDiag_second_deriv_pos' (z : ℝ) (hz : 0 < z) :
    exp z + z⁻¹ ^ 2 > 0 := by positivity


/-- [Section: ## §1. Diagonal Convexity] -/
theorem emlDiag_strictConvexOn :
    StrictConvexOn ℝ (Ioi 0) emlDiag := by
      fapply strictConvexOn_of_deriv2_pos;
      · exact convex_Ioi 0;
      · exact ContinuousOn.sub ( Real.continuousOn_exp ) ( Real.continuousOn_log.mono fun x hx => ne_of_gt hx );
      · -- Let's calculate the second derivative of $f(z) = e^z - \ln z$.
        have h_second_deriv : ∀ z > 0, deriv^[2] (fun z => Real.exp z - Real.log z) z = Real.exp z + 1 / z^2 := by
          have h_second_deriv : ∀ z > 0, deriv^[2] (fun z => Real.exp z - Real.log z) z = deriv (fun z => Real.exp z - 1 / z) z := by
            exact fun z hz => Filter.EventuallyEq.deriv_eq ( by filter_upwards [ lt_mem_nhds hz ] with x hx using by norm_num [ Real.differentiableAt_exp, Real.differentiableAt_log, hx.ne' ] );
          intro z hz; rw [ h_second_deriv z hz ] ; norm_num [ Real.differentiableAt_exp, differentiableAt_inv, hz.ne' ] ;
        exact fun x hx => h_second_deriv x ( interior_subset hx ) ▸ add_pos_of_pos_of_nonneg ( Real.exp_pos x ) ( by positivity )


theorem emlDiag_convexOn : ConvexOn ℝ (Ioi 0) emlDiag := by
  exact StrictConvexOn.convexOn emlDiag_strictConvexOn


/-- [Section: ## §2. Chain Decomposition Identity] -/
theorem eml_chain_identity (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    eml x z = eml x y - log (z / y) := by
      unfold eml; rw [ Real.log_div hz.ne' hy.ne' ] ; ring;


theorem eml_triangle_decomposition (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    eml x z + 1 = eml x y + eml 0 (z / y) := by
      unfold eml; simp +decide [ hy.ne', hz.ne', Real.log_div ] ; ring;


/-- [Section: ## §3. EML Complement Law] -/
theorem eml_complement (t : ℝ) : eml 0 (exp t) + t = 1 := by
  unfold eml; norm_num;


theorem eml_value_complement (x y : ℝ) :
    eml x y + eml 0 (exp (eml x y)) = 1 := by
      convert eml_complement ( eml x y ) using 1;
      ring


/-- [Section: ## §4. σ-EML Calculus] -/
theorem sigmaEml_hasDerivAt (x : ℝ) :
    HasDerivAt sigmaEml (exp x + exp (-x) / (1 + exp (-x))) x := by
      convert HasDerivAt.sub ( Real.hasDerivAt_exp x ) ( HasDerivAt.log ( HasDerivAt.add ( hasDerivAt_const _ _ ) <| HasDerivAt.exp <| hasDerivAt_neg x ) _ ) using 1 <;> norm_num;
      · ring;
      · positivity


theorem sigmaEml_deriv_pos (x : ℝ) :
    exp x + exp (-x) / (1 + exp (-x)) > 0 := by
      positivity


theorem sigmaEml_differentiable : Differentiable ℝ sigmaEml := by
  exact fun x => ( sigmaEml_hasDerivAt x |> HasDerivAt.differentiableAt )


theorem sigmaEml_continuous : Continuous sigmaEml := by
  convert sigmaEml_differentiable.continuous using 1


theorem sigmaEml_le_one_of_nonpos (x : ℝ) (hx : x ≤ 0) :
    sigmaEml x ≤ 1 := by
      exact le_trans ( sub_le_self _ <| Real.log_nonneg <| by linarith [ Real.exp_pos ( -x ) ] ) <| by linarith [ Real.exp_le_one_iff.mpr hx ] ;


theorem sigmaEml_tendsto_atBot :
    Tendsto sigmaEml atBot atBot := by
      rw [ Filter.tendsto_atBot_atBot ];
      unfold sigmaEml;
      intro b;
      use -2 - |b|;
      intro a ha; cases abs_cases b <;> linarith [ Real.exp_le_one_iff.mpr ( show a ≤ 0 by linarith ), Real.log_exp ( -a ), Real.log_le_log ( by positivity ) ( show 1 + Real.exp ( -a ) ≥ Real.exp ( -a ) by linarith [ Real.exp_pos ( -a ) ] ) ] ;


/-- [Section: ## §5. Diagonal Bounds] -/
theorem emlDiag_ge_one_add (z : ℝ) (hz : 0 < z) (hz1 : z ≤ 1) :
    emlDiag z ≥ 1 + z := by
      exact le_tsub_of_add_le_left ( by linarith [ Real.add_one_le_exp z, Real.log_le_sub_one_of_pos hz ] )


theorem emlDiag_ge_exp_of_le_one (z : ℝ) (hz : 0 < z) (hz1 : z ≤ 1) :
    emlDiag z ≥ exp z := by
      exact le_tsub_of_add_le_right ( by linarith [ Real.add_one_le_exp z, Real.log_le_sub_one_of_pos hz ] )


/-- [Section: ## §6. Fenchel-Young Type Inequality] -/
theorem neg_log_fenchel (y s : ℝ) (hy : 0 < y) (hs : 0 < s) :
    -log y ≥ 1 - y * s⁻¹ - log s := by
      have := Real.log_le_sub_one_of_pos ( div_pos ( inv_pos.mpr hs ) ( inv_pos.mpr hy ) );
      rw [ Real.log_div ] at this <;> norm_num at * <;> nlinarith [ inv_pos.2 hy, inv_pos.2 hs, mul_inv_cancel₀ hy.ne', mul_inv_cancel₀ hs.ne' ]


/-- [Section: ## §7. Exponential Superadditivity] -/
theorem exp_add_ge (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) :
    exp (a + b) ≥ exp a + exp b - 1 := by
      rw [ Real.exp_add ] ; nlinarith [ Real.exp_pos a, Real.exp_pos b, Real.add_one_le_exp a, Real.add_one_le_exp b ] ;


/-- [Section: ## §8. Gibbs Strengthening] -/
theorem neg_log_ge_one_sub (p : ℝ) (hp : 0 < p) (hp1 : p ≤ 1) :
    -log p ≥ 1 - p := by
      linarith [ Real.log_le_sub_one_of_pos hp ]


/-- The n-fold iterated exponential (EML tower). -/
def emlTower : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => exp (emlTower n x)


/-- [Section: ## §9. EML Tower Function] -/
theorem emlTower_zero (x : ℝ) : emlTower 0 x = x := rfl

theorem emlTower_succ (n : ℕ) (x : ℝ) : emlTower (n + 1) x = exp (emlTower n x) := rfl


theorem emlTower_eq_eml (n : ℕ) (x : ℝ) :
    emlTower (n + 1) x = eml (emlTower n x) 1 := by
      unfold eml; aesop


theorem emlTower_strictMono_nat (x : ℝ) (hx : 0 ≤ x) :
    StrictMono (fun n => emlTower n x) := by
      refine' strictMono_nat_of_lt_succ _;
      intro n; induction n <;> simp_all +decide [ emlTower_succ ] ;
      exact Real.add_one_le_exp _ |> lt_of_lt_of_le ( by linarith )


/-- [Section: ## §10. Geometric Mean Identity] -/
theorem eml_geometric_mean (x a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    eml x (Real.sqrt (a * b)) = (eml x a + eml x b) / 2 := by
      unfold eml;
      rw [ Real.log_sqrt ( by positivity ), Real.log_mul ha.ne' hb.ne' ] ; ring


/-- [Section: ## §11. Monotone Sequences] -/
theorem eml_mono_seq {x y : ℕ → ℝ} (hx : Monotone x) (hy : Antitone y)
    (hyp : ∀ n, 0 < y n) :
    Monotone (fun n => eml (x n) (y n)) := by
      -- By definition of eml, we know that if n ≤ m, then eml(x n, y n) ≤ eml(x m, y m).
      intro n m hnm
      simp [eml];
      linarith [ Real.exp_le_exp.mpr ( hx hnm ), Real.log_le_log ( hyp m ) ( hy hnm ) ]


/-- [Section: ## §12. Lambert W at Fixed Point] -/
theorem gmap_fixed_point_lambert (z : ℝ) (hz : 0 < z) (hfix : emlGmap z = z) :
    z + log z = exp 1 := by
      unfold emlGmap at hfix; linarith;


/-- [Section: ## §13. EML Antisymmetric Part] -/
theorem eml_antisymmetric (x y : ℝ) :
    eml x y - eml y x = (exp x - exp y) + (log x - log y) := by
      unfold eml; ring;


theorem eml_gap_sign (x y : ℝ) (hx : 1 ≤ x) (hy : 1 ≤ y) (hxy : x ≤ y) :
    eml y x ≥ eml x y := by
      exact sub_le_sub ( Real.exp_le_exp.mpr hxy ) ( Real.log_le_log ( by positivity ) hxy )


/-- det(Hessian) = exp(x) · (1/y²) > 0 for y > 0. -/
theorem eml_hessian_det (x y : ℝ) (hy : 0 < y) :
    exp x * (y⁻¹ ^ 2) > 0 := by positivity


/-- The Laplacian exp(x) + 1/y² is strictly positive. -/
theorem eml_laplacian_pos (x y : ℝ) (hy : 0 < y) :
    exp x + y⁻¹ ^ 2 > 0 := by positivity


/-- [Section: ## §15. New Evaluation Identities] -/
theorem eml_eval_ln3_3 : eml (log 3) 3 = 3 - log 3 := by
  unfold eml; norm_num [ Real.exp_log ] ;


theorem eml_at_inv_e (x : ℝ) : eml x (exp (-1)) = exp x + 1 := by
  unfold eml; norm_num;


theorem eml_eval_1_inv_e : eml 1 (exp (-1)) = exp 1 + 1 := by
  unfold eml; norm_num


theorem eml_eval_0_inv_e : eml 0 (exp (-1)) = 2 := by
  unfold eml; norm_num;


/-- [Section: ## §16. Joint Continuity] -/
theorem eml_continuousOn :
    ContinuousOn (fun p : ℝ × ℝ => eml p.1 p.2) (univ ×ˢ Ioi 0) := by
      exact ContinuousOn.sub ( ContinuousOn.rexp continuousOn_fst ) ( ContinuousOn.log continuousOn_snd fun p hp => ne_of_gt hp.2 )


/-- [Section: ## §17. Power Scaling] -/
theorem eml_power_snd (x y a : ℝ) (hy : 0 < y) :
    eml x (y ^ a) = exp x - a * log y := by
      unfold eml; rw [ Real.log_rpow hy ] ;


theorem eml_double_fst (x y : ℝ) :
    eml (2 * x) y = (exp x) ^ 2 - log y := by
      rw [ ← Real.exp_nat_mul, mul_comm ];
      unfold eml; ring;


/-- [Section: ## §18. Bregman Divergence from exp] -/
theorem eml_bregman_exp_nonneg (x₁ x₂ : ℝ) :
    exp x₁ - exp x₂ - exp x₂ * (x₁ - x₂) ≥ 0 := by
      rw [ show x₁ = x₂ + ( x₁ - x₂ ) by ring, Real.exp_add ];
      nlinarith [ Real.add_one_le_exp x₂, Real.add_one_le_exp ( x₁ - x₂ ), Real.exp_pos x₂, Real.exp_pos ( x₁ - x₂ ) ]


theorem eml_itakura_saito_nonneg (y₁ y₂ : ℝ) (hy₁ : 0 < y₁) (hy₂ : 0 < y₂) :
    log (y₂ / y₁) + y₁ / y₂ - 1 ≥ 0 := by
      have h := reverse_kl_nonneg ( y₁ / y₂ ) ( by positivity );
      rw [ show y₂ / y₁ = ( y₁ / y₂ ) ⁻¹ by rw [ inv_div ], Real.log_inv ] ; linarith


end
