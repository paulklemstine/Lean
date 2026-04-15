/-! # CatalogBuild.EML.EMLFutureResearch

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 40
-/

import Mathlib

noncomputable section

/-- The EML operator: eml(x, y) = exp(x) − ln(y). -/
def eml (x y : ℝ) : ℝ := Real.exp x - Real.log y


/-- The diagonal map: d(z) = exp(z) − ln(z). -/
def emlDiag (z : ℝ) : ℝ := Real.exp z - Real.log z


/-- The off-diagonal reflection map: g(z) = e − ln(z). -/
def emlGmap (z : ℝ) : ℝ := Real.exp 1 - Real.log z


/-- The e-tower: e↑↑n (iterated exponential). -/
def emlETower : ℕ → ℝ
  | 0 => 1
  | n + 1 => Real.exp (emlETower n)


/-- Tropical EML: trop(x, y) = max(x, −y). -/
def emlTrop (x y : ℝ) : ℝ := max x (-y)


/-- The EML Hessian metric coefficient in the x-direction: exp(x). -/
def emlHessXX (x : ℝ) : ℝ := Real.exp x


/-- The EML Hessian metric coefficient in the y-direction: 1/y². -/
def emlHessYY (y : ℝ) : ℝ := y⁻¹ ^ 2


/-- [Section: ## Part 1: Quasi-Division (Quasigroup Structure)] -/
theorem eml_right_division (a b : ℝ) :
    eml a (Real.exp (Real.exp a - b)) = b := by
  unfold eml; aesop;


theorem eml_right_division_unique (a b x : ℝ) (hx : 0 < x) (h : eml a x = b) :
    x = Real.exp (Real.exp a - b) := by
  exact h ▸ by simp +decide [ ← h, Real.exp_log hx, eml ] ;


theorem eml_left_division (a b : ℝ) (ha : 0 < a) (hba : 0 < b + Real.log a) :
    eml (Real.log (b + Real.log a)) a = b := by
  unfold eml; rw [ Real.exp_log hba ] ; ring;


theorem eml_left_division_domain (a b x : ℝ) (ha : 0 < a) (h : eml x a = b) :
    0 < b + Real.log a := by
  exact h.symm ▸ by unfold eml; linarith [ Real.exp_pos x, Real.log_le_sub_one_of_pos ha ] ;


/-- [Section: ## Part 2: Basin of Attraction for the g-Map] -/
theorem emlGmap_pos (z : ℝ) (hz : 0 < z) (hz2 : z < Real.exp (Real.exp 1)) :
    0 < emlGmap z := by
  exact sub_pos_of_lt ( Real.log_lt_iff_lt_exp hz |>.2 hz2 )


theorem emlGmap_fixedpoint_equation :
    ∃ z : ℝ, 0 < z ∧ emlGmap z = z := by
  -- We'll use the intermediate value theorem to show there is a fixed point.
  have h_ivt : ∃ z ∈ Set.Ioo 1 (Real.exp 1), emlGmap z = z := by
    -- By the intermediate value theorem, since $h(1) > 0$ and $h(e) < 0$, there exists $z \in (1, e)$ such that $h(z) = 0$.
    have h_ivt : ∃ z ∈ Set.Ioo 1 (Real.exp 1), Real.exp 1 - Real.log z - z = 0 := by
      apply_rules [ intermediate_value_Ioo' ] <;> norm_num;
      exact ContinuousOn.sub ( continuousOn_const.sub ( Real.continuousOn_log.mono <| by norm_num ) ) continuousOn_id;
    exact h_ivt.imp fun x hx => ⟨ hx.1, by unfold emlGmap; linarith ⟩;
  exact h_ivt.imp fun x hx => ⟨ lt_trans zero_lt_one hx.1.1, hx.2 ⟩


theorem emlGmap_contraction (z : ℝ) (hz : 1 < z) :
    |(-z⁻¹ : ℝ)| < 1 := by
  rw [ abs_of_neg ] <;> nlinarith [ inv_mul_cancel₀ ( by linarith : z ≠ 0 ) ]


/-- [Section: ## Part 3: Convexity of the Diagonal Map] -/
theorem emlDiag_strictly_convex :
    StrictConvexOn ℝ (Ioi 0) (fun z => emlDiag z) := by
  apply strictConvexOn_of_deriv2_pos ( convex_Ioi 0 );
  · exact continuousOn_of_forall_continuousAt fun x hx => ContinuousAt.sub ( Real.continuous_exp.continuousAt ) ( Real.continuousAt_log hx.out.ne' );
  · -- Let's calculate the second derivative of $d(z) = \exp(z) - \log(z)$.
    have h_second_deriv : ∀ z > 0, deriv^[2] (fun z => Real.exp z - Real.log z) z = Real.exp z + 1 / z^2 := by
      have h_second_deriv : ∀ z > 0, deriv^[2] (fun z => Real.exp z - Real.log z) z = deriv (fun z => Real.exp z - 1 / z) z := by
        exact fun z hz => Filter.EventuallyEq.deriv_eq ( by filter_upwards [ lt_mem_nhds hz ] with x hx using by norm_num [ Real.differentiableAt_exp, Real.differentiableAt_log, hx.ne' ] );
      exact fun z hz => h_second_deriv z hz ▸ by norm_num [ Real.differentiableAt_exp, differentiableAt_inv, hz.ne' ] ;
    exact fun x hx => h_second_deriv x ( interior_subset hx ) ▸ add_pos_of_pos_of_nonneg ( Real.exp_pos x ) ( by positivity )


theorem emlDiag_has_minimum :
    ∃ z₀ ∈ Ioi (0 : ℝ), ∀ z ∈ Ioi (0 : ℝ), emlDiag z₀ ≤ emlDiag z := by
  -- To find the critical points, we solve $d'(z) = 0$, which gives $z e^z = 1$.
  have h_critical : ∃ z₀ ∈ Set.Ioi 0, z₀ * Real.exp z₀ = 1 := by
    -- Apply the intermediate value theorem to the continuous function $f(z) = z e^z$ on the interval $(0, 1)$.
    have h_ivt : ∃ c ∈ Set.Ioo 0 1, c * Real.exp c = 1 := by
      apply_rules [ intermediate_value_Ioo ] <;> norm_num;
      exact continuousOn_id.mul Real.continuousOn_exp;
    exact ⟨ h_ivt.choose, h_ivt.choose_spec.1.1, h_ivt.choose_spec.2 ⟩;
  cases' h_critical with z₀ hz₀;
  refine' ⟨ z₀, hz₀.1, fun z hz => _ ⟩ ; unfold emlDiag;
  have := Real.log_le_sub_one_of_pos ( div_pos ( Real.exp_pos z ) ( Real.exp_pos z₀ ) );
  norm_num [ Real.log_div ( ne_of_gt ( Real.exp_pos z ) ) ( ne_of_gt ( Real.exp_pos z₀ ) ) ] at *;
  have := Real.log_le_sub_one_of_pos ( div_pos hz hz₀.1 );
  rw [ Real.log_div ] at this <;> nlinarith [ Real.exp_pos z, Real.exp_pos z₀, mul_div_cancel₀ ( Real.exp z ) ( ne_of_gt ( Real.exp_pos z₀ ) ), mul_div_cancel₀ ( z ) ( ne_of_gt hz₀.1 ) ]


theorem emlDiag_gt (z : ℝ) : emlDiag z > z := by
  by_cases hz : z ≤ 0;
  · unfold emlDiag;
    by_cases h : z < 0;
    · linarith [ Real.exp_pos z, Real.log_le_sub_one_of_pos ( neg_pos.mpr h ), Real.log_neg_eq_log z ];
    · norm_num [ show z = 0 by linarith ];
  · unfold emlDiag;
    have := Real.add_one_le_exp ( z - 1 );
    rw [ show z = 1 + ( z - 1 ) by ring, Real.exp_add ];
    nlinarith [ Real.add_one_le_exp 1, Real.log_le_sub_one_of_pos ( by linarith : 0 < 1 + ( z - 1 ) ) ]


/-- [Section: ## Part 4: EML Hessian Metric] -/
theorem emlHessian_pos_def (x y : ℝ) (hy : 0 < y) :
    0 < emlHessXX x ∧ 0 < emlHessYY y := by
  exact ⟨ Real.exp_pos x, sq_pos_of_pos <| inv_pos.mpr hy ⟩


theorem eml_curvature_negative (x y : ℝ) (hy : 0 < y) :
    -(Real.exp x) / (4 * y ^ 2) < 0 := by
  exact div_neg_of_neg_of_pos ( neg_neg_of_pos ( Real.exp_pos x ) ) ( by positivity )


/-- [Section: ## Part 5: Geodesic Equation Solutions] -/
theorem eml_geodesic_x_verify (a b t : ℝ) (h : 0 < a * t + b) :
    let x := 2 * Real.log (a * t + b)
    let x' := 2 * a / (a * t + b)
    let x'' := -(2 * a ^ 2) / (a * t + b) ^ 2
    x'' + (1/2) * x' ^ 2 = 0 := by
  grind


theorem eml_geodesic_y_verify (C k t : ℝ) (hC : 0 < C) :
    let y := C * Real.exp (k * t)
    let y' := C * k * Real.exp (k * t)
    let y'' := C * k ^ 2 * Real.exp (k * t)
    y'' - y' ^ 2 / y = 0 := by
  grind


/-- [Section: ## Part 6: Approximation Theory] -/
theorem eml_produces_constants (c : ℝ) (hc : -1 < c) :
    eml (Real.log (c + 1)) 1 = c + 1 := by
  unfold eml; norm_num [ Real.exp_log ( by linarith : 0 < c + 1 ) ] ;


theorem eml_negation (x : ℝ) :
    eml 0 (Real.exp x) = 1 - x := by
  unfold eml; norm_num;


theorem eml_subtraction (a b : ℝ) (ha : 0 < a) :
    eml (Real.log a) (Real.exp b) = a - b := by
  unfold eml; rw [ Real.exp_log ha ] ; norm_num;


theorem emlETower_strictMono : StrictMono emlETower := by
  refine' strictMono_nat_of_lt_succ _;
  exact fun n => Nat.recOn n ( by norm_num [ Real.exp_pos, emlETower ] ) fun n ih => by exact Real.exp_lt_exp.mpr ih;


theorem emlETower_superexp (n : ℕ) : emlETower (n + 2) ≥ Real.exp (2 ^ n) := by
  induction n <;> norm_num [ Real.exp_pos, pow_succ, emlETower ] at *;
  rename_i n hn;
  refine' le_trans ( mul_le_mul_of_nonneg_right hn zero_le_two ) _;
  rw [ ← Real.log_le_log_iff ( by positivity ) ( by positivity ), Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp, Real.log_exp ];
  linarith [ Real.log_le_sub_one_of_pos zero_lt_two, Real.add_one_le_exp ( emlETower n ) ]


/-- [Section: ## Part 7: Tropical EML Properties] -/
theorem emlTrop_idempotent_nonneg (x : ℝ) (hx : 0 ≤ x) :
    emlTrop x (-x) = x := by
  exact max_eq_left ( by linarith )


theorem emlTrop_not_comm : ∃ x y : ℝ, emlTrop x y ≠ emlTrop y x := by
  exact ⟨ 1, 2, by unfold emlTrop; norm_num ⟩


theorem emlTrop_avg_bound (x y : ℝ) :
    emlTrop x y ≥ (x - y) / 2 := by
  unfold emlTrop; cases max_cases x ( -y ) <;> linarith;


/-- [Section: ## Part 8: Composition and Iteration] -/
theorem eml_compose_left (x y z : ℝ) :
    eml (eml x y) z = Real.exp (Real.exp x - Real.log y) - Real.log z := by
  rfl


theorem emlETower_eml (n : ℕ) : emlETower (n + 1) = eml (emlETower n) 1 := by
  unfold eml; aesop;


theorem eml_iter_ee : eml (eml 1 1) 1 = Real.exp (Real.exp 1) := by
  unfold eml; norm_num;


/-- [Section: ## Part 9: Fundamental Inequalities] -/
theorem eml_lower_bound (x y : ℝ) :
    eml x y ≥ 1 + x - Real.log y := by
  unfold eml;
  linarith [ Real.add_one_le_exp x ]


theorem eml_strictMono_fst (y : ℝ) : StrictMono (fun x => eml x y) := by
  exact fun x y hxy => sub_lt_sub_right ( Real.exp_lt_exp.2 hxy ) _


theorem eml_strictAnti_snd (x : ℝ) : StrictAntiOn (fun y => eml x y) (Ioi 0) := by
  exact fun y hy z hz hyz => sub_lt_sub_left ( Real.log_lt_log hy hyz ) _


/-- [Section: ## Part 10: EML Complexity Lower Bounds] -/
theorem eml_complexity_exp : eml x 1 = Real.exp x := by
  unfold eml; norm_num;


theorem eml_complexity_oneminus :
    ∀ x : ℝ, eml 0 (Real.exp x) = 1 - x := by
  exact fun x => by unfold eml; norm_num;


theorem eml_generates_e : eml 1 1 = Real.exp 1 := by
  unfold eml; norm_num;


theorem eml_generates_zero : eml 0 (Real.exp 1) = 0 := by
  simp [eml]


theorem eml_generates_neg_one : eml 0 (Real.exp 2) = -1 := by
  unfold eml; norm_num;


end
