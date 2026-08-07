import Mathlib

/-! # CatalogBuild.Shared.Eml

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 17
-/

noncomputable section

/-- [Section: # CatalogBuild.Shared.Eml
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 21] -/
theorem eml_generates_neg_one : eml 0 (Real.exp 2) = -1 := by
  unfold eml; norm_num;

theorem eml_compose_left (x y z : ℝ) :
    eml (eml x y) z = Real.exp (Real.exp x - Real.log y) - Real.log z := by
  rfl

theorem eml_generates_e : eml 1 1 = Real.exp 1 := by
  unfold eml; norm_num;

theorem eml_produces_constants (c : ℝ) (hc : -1 < c) :
    eml (Real.log (c + 1)) 1 = c + 1 := by
  unfold eml; norm_num [ Real.exp_log ( by linarith : 0 < c + 1 ) ] ;

theorem eml_left_division (a b : ℝ) (ha : 0 < a) (hba : 0 < b + Real.log a) :
    eml (Real.log (b + Real.log a)) a = b := by
  unfold eml; rw [ Real.exp_log hba ] ; ring;

theorem eml_geodesic_x_verify (a b t : ℝ) (h : 0 < a * t + b) :
    let x := 2 * Real.log (a * t + b)
    let x' := 2 * a / (a * t + b)
    let x'' := -(2 * a ^ 2) / (a * t + b) ^ 2
    x'' + (1/2) * x' ^ 2 = 0 := by
  grind

theorem eml_generates_zero : eml 0 (Real.exp 1) = 0 := by
  simp [eml]

theorem eml_right_division_unique (a b x : ℝ) (hx : 0 < x) (h : eml a x = b) :
    x = Real.exp (Real.exp a - b) := by
  exact h ▸ by simp +decide [ ← h, Real.exp_log hx, eml ] ;

theorem eml_iter_ee : eml (eml 1 1) 1 = Real.exp (Real.exp 1) := by
  unfold eml; norm_num;

/-- [Section: # CatalogBuild.EML.EMLFutureResearch
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 40] -/
theorem eml_right_division (a b : ℝ) :
    eml a (Real.exp (Real.exp a - b)) = b := by
  unfold eml; aesop;

theorem eml_negation (x : ℝ) :
    eml 0 (Real.exp x) = 1 - x := by
  unfold eml; norm_num;

theorem eml_left_division_domain (a b x : ℝ) (ha : 0 < a) (h : eml x a = b) :
    0 < b + Real.log a := by
  exact h.symm ▸ by unfold eml; linarith [ Real.exp_pos x, Real.log_le_sub_one_of_pos ha ] ;

theorem eml_complexity_exp : eml x 1 = Real.exp x := by
  unfold eml; norm_num;

theorem eml_subtraction (a b : ℝ) (ha : 0 < a) :
    eml (Real.log a) (Real.exp b) = a - b := by
  unfold eml; rw [ Real.exp_log ha ] ; norm_num;

theorem eml_curvature_negative (x y : ℝ) (hy : 0 < y) :
    -(Real.exp x) / (4 * y ^ 2) < 0 := by
  exact div_neg_of_neg_of_pos ( neg_neg_of_pos ( Real.exp_pos x ) ) ( by positivity )

theorem eml_complexity_oneminus :
    ∀ x : ℝ, eml 0 (Real.exp x) = 1 - x := by
  exact fun x => by unfold eml; norm_num;

theorem eml_geodesic_y_verify (C k t : ℝ) (hC : 0 < C) :
    let y := C * Real.exp (k * t)
    let y' := C * k * Real.exp (k * t)
    let y'' := C * k ^ 2 * Real.exp (k * t)
    y'' - y' ^ 2 / y = 0 := by
  grind

end