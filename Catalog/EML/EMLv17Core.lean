import Mathlib

/-!
# EML Operator V17 — Core Foundations

New theorems about the EML operator eml(x, y) = exp(x) - ln(y).
-/

noncomputable section
open Real Set Filter Topology

/-! ## Definitions -/

def eml (x y : ℝ) : ℝ := exp x - log y
def emlDiag (z : ℝ) : ℝ := exp z - log z
def emlGmap (z : ℝ) : ℝ := exp 1 - log z
def sigmaEml (x : ℝ) : ℝ := exp x - log (1 + exp (-x))
def emlSymm (a b : ℝ) : ℝ := (a - log a) + (b - log b)

/-! ## Basic identities -/

theorem eml_def (x y : ℝ) : eml x y = exp x - log y := rfl
theorem emlDiag_def (z : ℝ) : emlDiag z = exp z - log z := rfl
theorem eml_eq_diag (z : ℝ) : eml z z = emlDiag z := rfl

theorem eml_at_one (x : ℝ) : eml x 1 = exp x := by simp [eml, log_one]
theorem eml_at_zero (y : ℝ) : eml 0 y = 1 - log y := by simp [eml]
theorem eml_at_exp (x y : ℝ) : eml x (exp y) = exp x - y := by simp [eml, log_exp]

/-! ## V17.1: No Critical Points -/

theorem eml_no_critical_points (x y : ℝ) (hy : 0 < y) :
    exp x ≠ 0 ∧ y⁻¹ ≠ 0 :=
  ⟨(exp_pos x).ne', (inv_pos.mpr hy).ne'⟩

/-! ## V17.2: Partial Derivatives -/

theorem eml_hasDerivAt_fst (x y : ℝ) :
    HasDerivAt (fun x' => eml x' y) (exp x) x := by
  unfold eml
  have h := (hasDerivAt_exp x).sub (hasDerivAt_const x (log y))
  simp only [sub_zero] at h; exact h

theorem eml_hasDerivAt_snd (x y : ℝ) (hy : 0 < y) :
    HasDerivAt (fun y' => eml x y') (-y⁻¹) y := by
  unfold eml
  have h := (hasDerivAt_const y (exp x)).sub (hasDerivAt_log hy.ne')
  simp only [zero_sub] at h; exact h

theorem eml_second_deriv_pos (x : ℝ) : exp x > 0 := exp_pos x

theorem eml_second_deriv_snd_pos (y : ℝ) (hy : 0 < y) : y⁻¹ ^ 2 > 0 := by positivity

/-! ## V17.3: Monotonicity -/

theorem eml_strictMono_fst (y : ℝ) : StrictMono (fun x => eml x y) := by
  intro a b hab; simp only [eml]; linarith [exp_lt_exp.mpr hab]

theorem eml_strictAnti_snd (x : ℝ) : StrictAntiOn (fun y => eml x y) (Ioi 0) := by
  intro a ha b _ hab; simp only [eml]; linarith [log_lt_log (mem_Ioi.mp ha) hab]

/-! ## V17.4: Convexity in x -/

theorem eml_convexOn_fst (y : ℝ) : ConvexOn ℝ univ (fun x => eml x y) := by
  have : ConvexOn ℝ univ (fun x => exp x + (-log y)) := convexOn_exp.add (convexOn_const _ convex_univ)
  exact this.congr (fun x _ => by simp [eml, sub_eq_add_neg])

/-! ## V17.5: Diagonal bounds -/

theorem emlDiag_ge_two (z : ℝ) (hz : 0 < z) : emlDiag z ≥ 2 := by
  unfold emlDiag; linarith [add_one_le_exp z, log_le_sub_one_of_pos hz]

theorem emlDiag_gt_z (z : ℝ) (hz : 0 < z) : emlDiag z > z := by
  unfold emlDiag;
  have := Real.exp_one_gt_d9.le;
  rw [ show z = 1 + ( z - 1 ) by ring, Real.exp_add ];
  nlinarith [ Real.add_one_le_exp ( z - 1 ), Real.log_le_sub_one_of_pos ( by linarith : 0 < 1 + ( z - 1 ) ) ]

/-! ## V17.6: Algebraic identities -/

theorem eml_trace (x y : ℝ) :
    eml x y + eml y x = exp x + exp y - log x - log y := by unfold eml; ring

theorem eml_diff (x y : ℝ) :
    eml x y - eml y x = (exp x - exp y) + (log x - log y) := by unfold eml; ring

theorem eml_self_exp (x : ℝ) : eml x (exp x) = exp x - x := by simp [eml, log_exp]

theorem eml_legendre (x y : ℝ) : eml x (exp y) = exp x - y := by simp [eml, log_exp]

theorem eml_log_split (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    eml x (y * z) = eml x y - log z := by unfold eml; rw [log_mul hy.ne' hz.ne']; ring

theorem eml_neg_fst (x y : ℝ) : eml (-x) y = exp (-x) - log y := rfl

theorem eml_double_exp (x : ℝ) : eml (eml x 1) 1 = exp (exp x) := by simp [eml, log_one]

theorem eml_power (x : ℝ) (n : ℕ) : eml (↑n * x) 1 = (exp x) ^ n := by
  simp [eml, log_one, exp_nat_mul]

/-! ## V17.7: Bounds -/

theorem eml_lower_bound (x y : ℝ) : eml x y ≥ 1 + x - log y := by
  unfold eml; linarith [add_one_le_exp x]

theorem eml_pos_of_nonneg_le_one (x y : ℝ) (hx : 0 ≤ x) (hy : 0 < y) (hy1 : y ≤ 1) :
    eml x y > 0 := by
  unfold eml
  have h1 : exp x ≥ 1 := one_le_exp hx
  have h2 : log y ≤ 0 := log_nonpos hy.le hy1
  linarith

/-! ## V17.8: Asymptotics -/

theorem eml_tendsto_top_x : Tendsto (fun x => eml x 1) atTop atTop := by
  simp only [eml_at_one]; exact tendsto_exp_atTop

/-! ## V17.9: Symmetrized EML -/

theorem sub_log_ge_one (x : ℝ) (hx : 0 < x) : x - log x ≥ 1 := by
  linarith [log_le_sub_one_of_pos hx]

theorem sub_log_eq_one_iff (x : ℝ) (hx : 0 < x) : x - log x = 1 ↔ x = 1 := by
  exact ⟨ fun h => le_antisymm ( le_of_not_gt fun h' => by linarith [ Real.log_lt_sub_one_of_pos hx h'.ne' ] ) ( le_of_not_gt fun h' => by linarith [ Real.log_lt_sub_one_of_pos hx ( by linarith ) ] ), fun h => by norm_num [ h ] ⟩

theorem emlSymm_ge_two (a b : ℝ) (ha : 0 < a) (hb : 0 < b) : emlSymm a b ≥ 2 := by
  unfold emlSymm; linarith [sub_log_ge_one a ha, sub_log_ge_one b hb]

theorem emlSymm_eq_two_iff (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    emlSymm a b = 2 ↔ a = 1 ∧ b = 1 := by
  constructor
  · intro h; unfold emlSymm at h
    have ha1 := sub_log_ge_one a ha; have hb1 := sub_log_ge_one b hb
    exact ⟨(sub_log_eq_one_iff a ha).mp (by linarith), (sub_log_eq_one_iff b hb).mp (by linarith)⟩
  · intro ⟨ha1, hb1⟩; rw [ha1, hb1]; simp [emlSymm, log_one]; norm_num

/-! ## V17.10: Neutral Curve -/

theorem eml_zero_curve (x : ℝ) : eml x (exp (exp x)) = 0 := by simp [eml, log_exp]
theorem eml_neutral_point : eml 0 (exp 1) = 0 := by simp [eml, log_exp]

theorem eml_pos_below_curve (x y : ℝ) (hy : 0 < y) (hlt : y < exp (exp x)) :
    eml x y > 0 := by
  unfold eml; have h : log y < exp x := by
    calc log y < log (exp (exp x)) := log_lt_log hy hlt
    _ = exp x := log_exp _
  linarith

theorem eml_neg_above_curve (x y : ℝ) (hlt : exp (exp x) < y) : eml x y < 0 := by
  unfold eml
  have hy : 0 < y := lt_trans (exp_pos _) hlt
  have h : exp x < log y := by
    calc exp x = log (exp (exp x)) := (log_exp _).symm
    _ < log y := log_lt_log (exp_pos _) hlt
  linarith

/-! ## V17.11: g-Map -/

theorem emlGmap_strictAnti : StrictAntiOn emlGmap (Ioi 0) := by
  intro a ha b _ hab; simp only [emlGmap]; linarith [log_lt_log (mem_Ioi.mp ha) hab]

theorem emlGmap_sub_id_continuousOn :
    ContinuousOn (fun z => emlGmap z - z) (Ioi 0) := by
  apply ContinuousOn.sub
  · exact (continuousOn_const.sub (continuousOn_log.mono (fun x hx => (mem_Ioi.mp hx).ne')))
  · exact continuousOn_id

theorem emlGmap_at_one : emlGmap 1 = exp 1 := by simp [emlGmap, log_one]
theorem emlGmap_at_e : emlGmap (exp 1) = exp 1 - 1 := by simp [emlGmap, log_exp]

/-! ## V17.12: Contraction -/

theorem inv_le_half_of_ge_two (z : ℝ) (hz : 2 ≤ z) : z⁻¹ ≤ 1/2 := by
  rw [inv_le_comm₀ (by linarith : (0:ℝ) < z) (by norm_num : (0:ℝ) < 1/2)]
  linarith

/-! ## V17.13: Lambert W -/

theorem lambert_connection (z : ℝ) (hz : 0 < z) :
    z + log z = exp 1 ↔ z * exp z = exp (exp 1) := by
  constructor
  · intro h
    have : exp (z + log z) = exp (exp 1) := by rw [h]
    rwa [exp_add, exp_log hz, mul_comm] at this
  · intro h
    have h1 : log (z * exp z) = log (exp (exp 1)) := by rw [h]
    rw [log_mul hz.ne' (exp_pos z).ne', log_exp, log_exp] at h1; linarith

/-! ## V17.14: σ-EML -/

theorem sigmaEml_at_zero : sigmaEml 0 = 1 - log 2 := by
  simp [sigmaEml]; congr 1; norm_num

/-! ## V17.15: Composition / Tower -/

theorem eml_tower_two (x : ℝ) : eml (eml x 1) 1 = exp (exp x) := by simp [eml, log_one]
theorem eml_tower_three (x : ℝ) :
    eml (eml (eml x 1) 1) 1 = exp (exp (exp x)) := by simp [eml, log_one]

theorem eml_log_exp (a b : ℝ) (ha : 0 < a) : eml (log a) (exp b) = a - b := by
  simp [eml, exp_log ha, log_exp]

/-! ## V17.16: Iterated Diagonal -/

theorem emlDiag_iterated_ge (z : ℝ) (hz : 0 < z) :
    emlDiag (emlDiag z) ≥ emlDiag z := by
      -- By emlDiag_ge_two, we have d(z) ≥ 2 > 0.
      have d_pos : 0 < emlDiag z := by
        exact lt_of_lt_of_le ( by positivity ) ( emlDiag_ge_two z hz );
      -- By emlDiag_gt_z, we have d(w) > w for any w > 0.
      have d_gt_w (w : ℝ) (hw : 0 < w) : emlDiag w > w := by
        exact?;
      linarith [ d_gt_w _ d_pos ]

/-! ## V17.17: Reciprocal -/

theorem eml_reciprocal (x y : ℝ) (hy : 0 < y) :
    eml x (y⁻¹) = exp x + log y := by unfold eml; rw [log_inv]; ring

theorem eml_add_reciprocal (x y : ℝ) (hy : 0 < y) :
    eml x y + eml x (y⁻¹) = 2 * exp x := by unfold eml; rw [log_inv]; ring

/-! ## V17.18: Functional Equations -/

theorem eml_log_shift (x y c : ℝ) (hy : 0 < y) :
    eml x (exp c * y) = eml x y - c := by unfold eml; rw [log_mul (exp_pos c).ne' hy.ne', log_exp]; ring

theorem eml_exp_shift (x y c : ℝ) :
    eml (x + c) y = exp c * exp x - log y := by unfold eml; rw [exp_add]; ring

/-! ## V17.19: Sums -/

theorem eml_sum (x y z : ℝ) :
    eml x y + eml x z = 2 * exp x - log y - log z := by unfold eml; ring

theorem eml_prod (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    eml x (y * z) = eml x y + eml x z - exp x := by unfold eml; rw [log_mul hy.ne' hz.ne']; ring

/-! ## V17.20: Evaluation Table -/

theorem eml_eval_0_1 : eml 0 1 = 1 := by simp [eml, log_one]
theorem eml_eval_1_1 : eml 1 1 = exp 1 := by simp [eml, log_one]
theorem eml_eval_0_e : eml 0 (exp 1) = 0 := by simp [eml, log_exp]
theorem eml_eval_1_e : eml 1 (exp 1) = exp 1 - 1 := by simp [eml, log_exp]

/-! ## V17.21: Continuity and Differentiability -/

theorem eml_continuous_fst (y : ℝ) : Continuous (fun x => eml x y) := by
  unfold eml; exact continuous_exp.sub continuous_const

theorem eml_continuousOn_snd (x : ℝ) : ContinuousOn (fun y => eml x y) (Ioi 0) := by
  apply ContinuousOn.sub continuousOn_const
  exact continuousOn_log.mono (fun y hy => (mem_Ioi.mp hy).ne')

theorem eml_differentiable_fst (y : ℝ) : Differentiable ℝ (fun x => eml x y) :=
  fun x => (eml_hasDerivAt_fst x y).differentiableAt

/-! ## V17.22: Joint Convexity -/

/-
EML is jointly convex: for t ∈ [0,1], y₁, y₂ > 0,
  eml(t*x₁ + (1-t)*x₂, t*y₁ + (1-t)*y₂) ≤ t*eml(x₁,y₁) + (1-t)*eml(x₂,y₂).
-/
theorem eml_jointly_convex :
    ConvexOn ℝ (univ ×ˢ Ioi 0) (fun p : ℝ × ℝ => eml p.1 p.2) := by
      apply_rules [ ConvexOn.sub, convexOn_const ];
      · have h_exp_convex : ConvexOn ℝ Set.univ (fun x => Real.exp x) := by
          exact convexOn_exp;
        simp_all +decide [ ConvexOn ];
        exact convex_univ.prod ( convex_Ioi 0 );
      · -- The function $\log(y)$ is concave on $(0, \infty)$.
        have h_log_concave : ConcaveOn ℝ (Set.Ioi 0) Real.log := by
          exact ( StrictConcaveOn.concaveOn <| strictConcaveOn_log_Ioi );
        simp_all +decide [ ConcaveOn ];
        exact convex_univ.prod h_log_concave.1

/-! ## V17.23: Fixed Point Existence -/

theorem emlGmap_at_two_gt : emlGmap 2 > 2 := by
  norm_num [ emlGmap ];
  have := Real.exp_one_gt_d9.le; have := Real.log_two_lt_d9; norm_num1 at *; linarith;

theorem emlGmap_at_e_lt : emlGmap (exp 1) < exp 1 := by
  exact sub_lt_self _ ( Real.log_pos <| Real.exp_one_gt_d9.trans_le' <| by norm_num )

theorem emlGmap_fixed_point_exists :
    ∃ z, z ∈ Ioo 2 (exp 1) ∧ emlGmap z = z := by
      -- Apply the intermediate value theorem to the continuous function $f(z) = g(z) - z$ on the interval $[2, e]$.
      have h_ivt : ∃ z ∈ Set.Ioo 2 (Real.exp 1), emlGmap z - z = 0 := by
        apply_rules [ intermediate_value_Ioo' ] <;> norm_num;
        · linarith [ Real.add_one_le_exp 1 ];
        · exact ContinuousOn.sub ( ContinuousOn.sub continuousOn_const ( Real.continuousOn_log.mono <| by norm_num ) ) continuousOn_id;
        · exact ⟨ emlGmap_at_e_lt, emlGmap_at_two_gt ⟩;
      simpa only [ sub_eq_zero ] using h_ivt

/-! ## V17.24: Bregman connection -/

theorem eml_bregman_identity (p : ℝ) :
    (p - log p) - 1 = (p - 1) - log p := by ring

/-! ## V17.25: Double negation -/

theorem eml_double_neg (x : ℝ) : eml 0 (exp (eml 0 (exp x))) = x := by
  unfold eml; simp [log_exp]

end