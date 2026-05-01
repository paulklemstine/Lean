import Mathlib

/-! # CatalogBuild.EML.EMLFutureResearch

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 15
-/

noncomputable section

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

/-- [Section: # CatalogBuild.EML.EMLFutureResearch
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 15] -/
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

theorem emlHessian_pos_def (x y : ℝ) (hy : 0 < y) :
    0 < emlHessXX x ∧ 0 < emlHessYY y := by
  exact ⟨ Real.exp_pos x, sq_pos_of_pos <| inv_pos.mpr hy ⟩

theorem emlETower_strictMono : StrictMono emlETower := by
  refine' strictMono_nat_of_lt_succ _;
  exact fun n => Nat.recOn n ( by norm_num [ Real.exp_pos, emlETower ] ) fun n ih => by exact Real.exp_lt_exp.mpr ih;

theorem emlETower_superexp (n : ℕ) : emlETower (n + 2) ≥ Real.exp (2 ^ n) := by
  induction n <;> norm_num [ Real.exp_pos, pow_succ, emlETower ] at *;
  rename_i n hn;
  refine' le_trans ( mul_le_mul_of_nonneg_right hn zero_le_two ) _;
  rw [ ← Real.log_le_log_iff ( by positivity ) ( by positivity ), Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp, Real.log_exp ];
  linarith [ Real.log_le_sub_one_of_pos zero_lt_two, Real.add_one_le_exp ( emlETower n ) ]

theorem emlTrop_idempotent_nonneg (x : ℝ) (hx : 0 ≤ x) :
    emlTrop x (-x) = x := by
  exact max_eq_left ( by linarith )

theorem emlTrop_not_comm : ∃ x y : ℝ, emlTrop x y ≠ emlTrop y x := by
  exact ⟨ 1, 2, by unfold emlTrop; norm_num ⟩

theorem emlTrop_avg_bound (x y : ℝ) :
    emlTrop x y ≥ (x - y) / 2 := by
  unfold emlTrop; cases max_cases x ( -y ) <;> linarith;

theorem emlETower_eml (n : ℕ) : emlETower (n + 1) = eml (emlETower n) 1 := by
  unfold eml; aesop;

end
