import Mathlib

/-! # CatalogBuild.EML.V16Research

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 46
-/

noncomputable section

/-- The EML operator: eml(x, y) = exp(x) − ln(y). -/
def eml16 (x y : ℝ) : ℝ := Real.exp x - Real.log y

/-- The diagonal map: d(z) = exp(z) − ln(z). -/
def diag16 (z : ℝ) : ℝ := Real.exp z - Real.log z

/-- The off-diagonal g-map: g(z) = e − ln(z). -/
def gmap16 (z : ℝ) : ℝ := Real.exp 1 - Real.log z

/-- The σ-EML activation function: σ_eml(x) = exp(x) - ln(1 + exp(-x)). -/
def sigma_eml16 (x : ℝ) : ℝ := Real.exp x - Real.log (1 + Real.exp (-x))

/-- [Section: ========================================================================
Part I: Joint Convexity
========================================================================] -/
theorem eml16_jointly_convex (x₁ x₂ y₁ y₂ t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1)
    (hy₁ : 0 < y₁) (hy₂ : 0 < y₂) :
    eml16 (t * x₁ + (1 - t) * x₂) (t * y₁ + (1 - t) * y₂) ≤
      t * eml16 x₁ y₁ + (1 - t) * eml16 x₂ y₂ := by
        unfold eml16;
        -- By convexity of exp and concavity of log, we have:
        have h_exp : Real.exp (t * x₁ + (1 - t) * x₂) ≤ t * Real.exp x₁ + (1 - t) * Real.exp x₂ := by
          -- The exponential function is convex, so we can apply Jensen's inequality.
          have h_exp_convex : ConvexOn ℝ (Set.univ : Set ℝ) Real.exp := by
            exact convexOn_exp;
          exact h_exp_convex.2 trivial trivial ht0 ( by linarith ) ( by linarith )
        have h_log : Real.log (t * y₁ + (1 - t) * y₂) ≥ t * Real.log y₁ + (1 - t) * Real.log y₂ := by
          have h_concave : ConcaveOn ℝ (Set.Ioi 0) Real.log := by
            exact ( StrictConcaveOn.concaveOn <| strictConcaveOn_log_Ioi );
          exact h_concave.2 hy₁ hy₂ ( by linarith ) ( by linarith ) ( by linarith );
        linarith

/-- [Section: ========================================================================
Part II: Fixed Point Existence and Uniqueness
========================================================================] -/
theorem gmap16_sub_id_continuousOn : ContinuousOn (fun z => gmap16 z - z) (Set.Ioi 0) := by
  exact ContinuousOn.sub ( continuousOn_const.sub ( Real.continuousOn_log.mono fun x hx => ne_of_gt hx ) ) continuousOn_id

theorem gmap16_at_two_gt : gmap16 2 > 2 := by
  exact lt_tsub_iff_left.mpr <| by have := Real.exp_one_gt_d9.le; have := Real.log_two_lt_d9.le; norm_num1 at *; linarith;

theorem gmap16_at_e_lt : gmap16 (Real.exp 1) < Real.exp 1 := by
  unfold gmap16; norm_num [ Real.exp_pos ] ;

theorem gmap16_fixed_point_exists :
    ∃ z : ℝ, 2 < z ∧ z < Real.exp 1 ∧ gmap16 z = z := by
      -- Since $g(2) > 2$ and $g(e) < e$, by the intermediate value theorem, there exists $z \in (2, e)$ such that $g(z) = z$.
      have h_ivt : ∃ z ∈ Set.Ioo 2 (Real.exp 1), (gmap16 z - z) = 0 := by
        apply_rules [ intermediate_value_Ioo' ] <;> norm_num;
        · linarith [ Real.add_one_le_exp 1 ];
        · exact ContinuousOn.sub ( continuousOn_const.sub ( Real.continuousOn_log.mono <| by norm_num ) ) continuousOn_id;
        · exact ⟨ gmap16_at_e_lt, gmap16_at_two_gt ⟩
      obtain ⟨z, hz1, hz2⟩ := h_ivt
      use z
      exact ⟨hz1.left, hz1.right, sub_eq_zero.mp hz2⟩

theorem gmap16_strictAnti : StrictAntiOn gmap16 (Set.Ioi 0) := by
  exact fun x hx y hy hxy => sub_lt_sub_left ( Real.log_lt_log hx hxy ) _

theorem gmap16_fixed_point_unique (z₁ z₂ : ℝ) (hz₁ : 0 < z₁) (hz₂ : 0 < z₂)
    (hfp₁ : gmap16 z₁ = z₁) (hfp₂ : gmap16 z₂ = z₂) : z₁ = z₂ := by
      exact le_antisymm ( le_of_not_gt fun h => by linarith [ gmap16_strictAnti ( show ( 0:ℝ ) < z₂ by linarith ) ( show ( 0:ℝ ) < z₁ by linarith ) h ] ) ( le_of_not_gt fun h => by linarith [ gmap16_strictAnti ( show ( 0:ℝ ) < z₁ by linarith ) ( show ( 0:ℝ ) < z₂ by linarith ) h ] )

theorem gmap16_fixed_point_unique_exists :
    ∃ z : ℝ, 2 < z ∧ z < Real.exp 1 ∧ gmap16 z = z ∧
      ∀ w : ℝ, 0 < w → gmap16 w = w → w = z := by
        obtain ⟨ z, hz₁, hz₂, hz₃ ⟩ := gmap16_fixed_point_exists;
        exact ⟨ z, hz₁, hz₂, hz₃, fun w hw hw' => gmap16_fixed_point_unique w z hw ( by linarith ) hw' hz₃ ⟩

theorem symmetrized_eml_eq_two_iff (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    (a - Real.log a) + (b - Real.log b) = 2 ↔ a = 1 ∧ b = 1 := by
      constructor <;> intro H;
      · by_contra! h;
        have := Real.log_lt_sub_one_of_pos ( show 0 < a by positivity );
        by_cases ha1 : a = 1 <;> simp_all +decide;
        · exact h ( by linarith [ Real.log_lt_sub_one_of_pos hb ( by aesop ) ] );
        · linarith [ sub_log_ge_one b hb ];
      · norm_num [ H ]

/-- [Section: ========================================================================
Part IV: Diagonal Analysis
========================================================================] -/
theorem diag16_ge_two (z : ℝ) (hz : 0 < z) : diag16 z ≥ 2 := by
  exact le_tsub_of_add_le_left ( by have := Real.add_one_le_exp z; have := Real.log_le_sub_one_of_pos hz; linarith )

theorem diag16_tendsto_top : Filter.Tendsto diag16 Filter.atTop Filter.atTop := by
  -- We'll use the fact that $e^z$ grows much faster than $\ln z$.
  have h_exp_ln : Filter.Tendsto (fun z => Real.exp z - Real.log z) Filter.atTop Filter.atTop := by
    refine' Filter.tendsto_atTop_atTop.mpr _;
    -- Since $\exp(a)$ grows exponentially and $\log(a)$ grows logarithmically, for sufficiently large $a$, $\exp(a) - \log(a)$ will be greater than any given $b$.
    intros b
    obtain ⟨i, hi⟩ : ∃ i, ∀ a ≥ i, Real.exp a > b + a := by
      have h_exp_growth : Filter.Tendsto (fun a => Real.exp a / a) Filter.atTop Filter.atTop := by
        simpa using Real.tendsto_exp_div_pow_atTop 1;
      exact Filter.eventually_atTop.mp ( h_exp_growth.eventually_gt_atTop ( |b| + 1 ) ) |> fun ⟨ i, hi ⟩ ↦ ⟨ Max.max i 1, fun a ha ↦ by cases abs_cases b <;> nlinarith [ hi a ( le_trans ( le_max_left _ _ ) ha ), le_max_right i 1, Real.add_one_le_exp a, mul_div_cancel₀ ( Real.exp a ) ( show a ≠ 0 by linarith [ le_max_right i 1 ] ) ] ⟩;
    exact ⟨ Max.max i 1, fun a ha => by linarith [ hi a ( le_trans ( le_max_left _ _ ) ha ), Real.log_le_sub_one_of_pos ( by linarith [ le_max_right i 1 ] : 0 < a ) ] ⟩;
  exact h_exp_ln

theorem diag16_at_one : diag16 1 = Real.exp 1 := by
  unfold diag16; norm_num

theorem diag16_at_e : diag16 (Real.exp 1) = Real.exp (Real.exp 1) - 1 := by
  unfold diag16; norm_num

theorem diag16_ge_exp_sub (z : ℝ) (hz : 1 ≤ z) : diag16 z ≥ Real.exp z - z := by
  exact sub_le_sub_left ( le_trans ( Real.log_le_sub_one_of_pos ( by linarith ) ) ( by linarith ) ) _

/-- [Section: ========================================================================
Part V: Composition and Iteration
========================================================================] -/
theorem eml16_at_zero_exp (t : ℝ) : eml16 0 (Real.exp t) = 1 - t := by
  unfold eml16; aesop;

theorem eml16_at_one_one : eml16 1 1 = Real.exp 1 := by
  exact sub_eq_self.mpr ( by norm_num )

theorem eml16_at_zero_one : eml16 0 1 = 1 := by
  unfold eml16; aesop;

theorem eml16_at_ln2_2 : eml16 (Real.log 2) 2 = 2 - Real.log 2 := by
  unfold eml16; norm_num [ Real.exp_log ] ;

theorem diag16_iterated_ge (z : ℝ) (hz : 0 < z) :
    diag16 (diag16 z) ≥ diag16 z := by
      have h_exp_ge_log : ∀ w : ℝ, 2 ≤ w → Real.exp w - Real.log w ≥ w := by
        intro w hw;
        have := Real.log_le_sub_one_of_pos ( by positivity : 0 < w / 2 );
        rw [ Real.log_div ] at this <;> try linarith;
        have := Real.exp_one_gt_d9.le ; norm_num1 at * ; rw [ show Real.exp w = Real.exp 1 * Real.exp ( w - 1 ) by rw [ ← Real.exp_add ] ; ring ] ; nlinarith [ Real.add_one_le_exp ( w - 1 ), Real.log_le_sub_one_of_pos zero_lt_two ];
      exact h_exp_ge_log _ ( diag16_ge_two _ hz )

/-- [Section: ========================================================================
Part VI: EML and Classical Inequalities
========================================================================] -/
theorem eml16_amgm_connection (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    (a - Real.log a) + (b - Real.log b) ≥ 2 := by
      linarith [ sub_log_ge_one a ha, sub_log_ge_one b hb ]

theorem eml16_young_diagonal (a : ℝ) (ha : 0 < a) :
    Real.exp a ≥ 1 + a := by
      linarith [ Real.add_one_le_exp a ]

theorem eml16_lower_bound (x y : ℝ) :
    eml16 x y ≥ 1 + x - Real.log y := by
      exact sub_le_sub_right ( by linarith [ Real.add_one_le_exp x ] ) _

/-- [Section: ========================================================================
Part VII: Asymptotics and Limits
========================================================================] -/
theorem eml16_zero_tendsto_top :
    Filter.Tendsto (fun y => eml16 0 y) (nhdsWithin 0 (Set.Ioi 0)) Filter.atTop := by
      exact Filter.Tendsto.add_atTop tendsto_const_nhds ( Filter.tendsto_neg_atBot_atTop.comp <| Real.tendsto_log_nhdsGT_zero )

theorem eml16_one_tendsto_top :
    Filter.Tendsto (fun x => eml16 x 1) Filter.atTop Filter.atTop := by
      unfold eml16;
      simpa using Real.tendsto_exp_atTop

theorem eml16_one_tendsto_zero :
    Filter.Tendsto (fun x => eml16 x 1) Filter.atBot (nhds 0) := by
      convert Real.tendsto_exp_atBot using 2 ; unfold eml16 ; aesop

/-- [Section: ========================================================================
Part VIII: g-Map Contraction
========================================================================] -/
theorem gmap16_contraction_constant (z : ℝ) (hz : 2 ≤ z) :
    (1 : ℝ) / z ≤ 1 / 2 := by
      gcongr

theorem gmap16_lipschitz (x y : ℝ) (hx : 2 ≤ x) (hy : 2 ≤ y) :
    |gmap16 x - gmap16 y| ≤ (1 / 2) * |x - y| := by
      rw [ abs_le ];
      cases abs_cases ( x - y ) <;> simp +decide [ * ];
      · unfold gmap16;
        by_cases hxy : x = y;
        · aesop;
        · have := exists_deriv_eq_slope ( Real.log ) ( show x > y by exact lt_of_le_of_ne ( by linarith ) ( Ne.symm hxy ) ) ; norm_num at *;
          exact this ( continuousOn_of_forall_continuousAt fun z hz => Real.continuousAt_log ( by linarith [ hz.1 ] ) ) ( fun z hz => DifferentiableAt.differentiableWithinAt ( Real.differentiableAt_log ( by linarith [ hz.1 ] ) ) ) |> fun ⟨ c, hc₁, hc₂ ⟩ => ⟨ by rw [ inv_eq_one_div, div_eq_div_iff ] at hc₂ <;> nlinarith [ Real.add_one_le_exp 1, mul_div_cancel₀ ( log x - log y ) ( sub_ne_zero_of_ne hxy ) ], by rw [ inv_eq_one_div, div_eq_div_iff ] at hc₂ <;> nlinarith [ Real.add_one_le_exp 1, mul_div_cancel₀ ( log x - log y ) ( sub_ne_zero_of_ne hxy ) ] ⟩;
      · -- By the Mean Value Theorem, there exists some $c \in (x, y)$ such that $g'(c) = (g(y) - g(x)) / (y - x)$.
        obtain ⟨c, hc⟩ : ∃ c ∈ Set.Ioo x y, deriv gmap16 c = (gmap16 y - gmap16 x) / (y - x) := by
          apply_rules [ exists_deriv_eq_slope ];
          · linarith;
          · exact continuousOn_of_forall_continuousAt fun z hz => by exact ContinuousAt.sub continuousAt_const ( Real.continuousAt_log ( by linarith [ hz.1 ] ) ) ;
          · exact DifferentiableOn.sub ( differentiableOn_const _ ) ( DifferentiableOn.log differentiableOn_id fun z hz => by linarith [ hz.1 ] );
        -- By definition of $gmap16$, we know that its derivative is $-1/z$.
        have h_deriv : ∀ z : ℝ, 0 < z → deriv gmap16 z = -1 / z := by
          unfold gmap16; intro z hz; norm_num [ div_eq_mul_inv, Real.differentiableAt_exp, Real.differentiableAt_log, hz.ne' ] ;
        rw [ h_deriv c ( by linarith [ hc.1.1 ] ) ] at hc;
        rw [ div_eq_div_iff ] at hc <;> norm_num at * <;> try linarith [ hc.1.1, hc.1.2 ];
        constructor <;> nlinarith [ mul_div_cancel₀ 1 ( by linarith : ( 2 : ℝ ) ≠ 0 ) ]

/-- [Section: ========================================================================
Part IX: EML Functional Equations
========================================================================] -/
theorem eml16_log_shift (x y c : ℝ) (hy : 0 < y) :
    eml16 x (Real.exp c * y) = eml16 x y - c := by
      unfold eml16;
      rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ] ; ring

theorem eml16_exp_shift (x y c : ℝ) :
    eml16 (x + c) y = Real.exp c * Real.exp x - Real.log y := by
      simp +decide [ eml16, Real.exp_add ] ; ring

theorem eml16_prod_snd (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    eml16 x (y * z) = eml16 x y + eml16 x z - Real.exp x := by
      unfold eml16; rw [ Real.log_mul hy.ne' hz.ne' ] ; ring;

theorem eml16_reciprocal (x y : ℝ) (hy : 0 < y) :
    eml16 x (1 / y) = eml16 x y + 2 * Real.log y := by
      unfold eml16;
      simpa using by ring

/-- [Section: ========================================================================
Part X: σ-EML Properties
========================================================================] -/
theorem sigma_eml16_at_zero : sigma_eml16 0 = 1 - Real.log 2 := by
  unfold sigma_eml16; norm_num;

theorem sigma_eml16_strictMono : StrictMono sigma_eml16 := by
  refine' fun x y hxy => sub_lt_sub _ _;
  · exact Real.exp_lt_exp.2 hxy;
  · gcongr

theorem sigma_eml16_tendsto_top :
    Filter.Tendsto sigma_eml16 Filter.atTop Filter.atTop := by
      exact Filter.Tendsto.atTop_add ( Real.tendsto_exp_atTop ) ( Filter.Tendsto.neg ( Filter.Tendsto.log ( tendsto_const_nhds.add ( Real.tendsto_exp_atBot.comp Filter.tendsto_neg_atTop_atBot ) ) ( by norm_num ) ) )

theorem sigma_eml16_large_x (x : ℝ) (hx : 0 ≤ x) :
    sigma_eml16 x ≥ Real.exp x - Real.log 2 := by
      exact sub_le_sub_left ( Real.log_le_log ( by positivity ) ( by linarith [ Real.exp_le_one_iff.mpr ( neg_nonpos.mpr hx ) ] ) ) _

theorem sigma_eml16_pos_of_ge_one (x : ℝ) (hx : 1 ≤ x) :
    sigma_eml16 x > 0 := by
      -- Since $\sigma_eml^16(x)$ is increasing and $\sigma_eml^16(1) > 0$, for any $x \ge 1$, $\sigma_eml^16(x) \ge \sigma_eml^16(1) > 0$.
      have h_sigma_eml16_ge_one : sigma_eml16 1 > 0 := by
        exact sub_pos_of_lt ( lt_of_le_of_lt ( Real.log_le_sub_one_of_pos ( by positivity ) ) ( by linarith [ Real.add_one_le_exp 1, Real.exp_pos ( -1 ), Real.exp_lt_one_iff.mpr ( show -1 < 0 by norm_num ) ] ) );
      exact h_sigma_eml16_ge_one.trans_le ( sigma_eml16_strictMono.monotone hx )

/-- [Section: ========================================================================
Part XI: EML Neutral Curve and Level Sets
========================================================================] -/
theorem eml16_neutral : eml16 0 (Real.exp 1) = 0 := by
  unfold eml16; norm_num

theorem eml16_zero_curve (x : ℝ) :
    eml16 x (Real.exp (Real.exp x)) = 0 := by
      unfold eml16; norm_num;

theorem eml16_pos_below_curve (x y : ℝ) (hy : 0 < y) (hlt : y < Real.exp (Real.exp x)) :
    eml16 x y > 0 := by
      -- Using the definition of eml16, we have eml16 x y = exp(x) - log(y).
      simp [eml16];
      simpa using Real.log_lt_log hy hlt

theorem eml16_neg_above_curve (x y : ℝ) (hgt : y > Real.exp (Real.exp x)) :
    eml16 x y < 0 := by
      exact sub_neg_of_lt ( by simpa using Real.log_lt_log ( by positivity ) hgt )

theorem eml16_sum (x y z : ℝ) :
    eml16 x y + eml16 x z = 2 * Real.exp x - Real.log y - Real.log z := by
      unfold eml16; ring;

theorem eml16_neg_fst (x y : ℝ) :
    eml16 (-x) y = 1 / Real.exp x - Real.log y := by
      rw [ one_div, ← Real.exp_neg, eml16 ]

end