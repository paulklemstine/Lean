/-! # CatalogBuild.EML.EMLv8Advanced

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 30
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.EML.EMLv8Advanced
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 30] -/
def eml8a (x y : ℝ) : ℝ := Real.exp x - Real.log y



/-- [Section: # CatalogBuild.EML.EMLv8Advanced
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 30] -/
def diag8a (z : ℝ) : ℝ := Real.exp z - Real.log z



def gmap8a (z : ℝ) : ℝ := Real.exp 1 - Real.log z




def eTow8a : ℕ → ℝ
  | 0 => 1
  | n + 1 => Real.exp (eTow8a n)




def diagIter8a : ℕ → ℝ → ℝ
  | 0, z => z
  | n + 1, z => diag8a (diagIter8a n z)




def trop8a (x y : ℝ) : ℝ := max x (-y)




theorem eTow8a_pos (n : ℕ) : 0 < eTow8a n := by
  induction n with
  | zero => simp [eTow8a]
  | succ n _ => exact Real.exp_pos _




theorem eTow8a_strict_mono : StrictMono eTow8a := by
  apply strictMono_nat_of_lt_succ
  intro n; simp only [eTow8a]
  linarith [Real.add_one_le_exp (eTow8a n)]




theorem diag8a_gt (z : ℝ) : diag8a z > z := by
  cases' lt_trichotomy z 0 with hz hz;
  · unfold diag8a;
    linarith [ Real.exp_pos z, Real.log_le_sub_one_of_pos ( neg_pos.mpr hz ), Real.log_neg_eq_log z ];
  · -- If $z > 0$, we use the inequality $\exp(z) > z + 1$ and $\ln(z) \leq z - 1$.
    by_cases hz_pos : 0 < z;
    · unfold diag8a;
      have := Real.add_one_le_exp ( z - 1 );
      rw [ show Real.exp z = Real.exp ( z - 1 ) * Real.exp 1 by rw [ ← Real.exp_add ] ; ring ] ; nlinarith [ Real.add_one_le_exp 1, Real.log_le_sub_one_of_pos hz_pos ];
    · cases hz <;> simp_all +decide [ diag8a ]




theorem diag8a_orbit_increasing (z : ℝ) (n : ℕ) :
    diagIter8a n z < diagIter8a (n + 1) z := by
  simp only [diagIter8a]; exact diag8a_gt _




theorem diag8a_orbit_diverge (z : ℝ) (n : ℕ) :
    diagIter8a n z ≥ z + n := by
  induction' n with n ih generalizing z <;> simp_all +decide [ add_assoc ];
  · rfl;
  · -- By definition of $diag8a$, we have $diag8a w = \exp(w) - \log(w)$.
    have h_diag8a_def : ∀ w : ℝ, diag8a w ≥ w + 1 := by
      unfold diag8a;
      intro w; by_cases hw : w > 0 <;> simp_all +decide [ Real.exp_pos ];
      · have := Real.add_one_le_exp ( w - 1 );
        rw [ show w = 1 + ( w - 1 ) by ring, Real.exp_add ];
        nlinarith [ Real.add_one_le_exp 1, Real.log_le_sub_one_of_pos ( by linarith : 0 < 1 + ( w - 1 ) ) ];
      · by_cases hw : w < 0;
        · nlinarith [ Real.exp_pos w, Real.exp_neg w, mul_inv_cancel₀ ( ne_of_gt ( Real.exp_pos w ) ), Real.add_one_le_exp w, Real.add_one_le_exp ( -w ), Real.log_le_sub_one_of_pos ( neg_pos.mpr hw ), Real.log_neg_eq_log w ];
        · norm_num [ show w = 0 by linarith ];
    linarith! [ ih z, h_diag8a_def ( diagIter8a n z ) ]




theorem gmap8a_strictAnti : StrictAntiOn gmap8a (Ioi 0) := by
  intro a ha b _ hab
  simp only [gmap8a]
  linarith [Real.log_lt_log (mem_Ioi.mp ha) hab]




theorem gmap8a_one : gmap8a 1 = Real.exp 1 := by
  simp [gmap8a, Real.log_one]




theorem gmap8a_e : gmap8a (Real.exp 1) = Real.exp 1 - 1 := by
  simp [gmap8a, Real.log_exp]




theorem gmap8a_deriv (z : ℝ) (hz : 0 < z) :
    HasDerivAt gmap8a (-z⁻¹) z := by
  unfold gmap8a
  have h := (hasDerivAt_const z (Real.exp 1)).sub (Real.hasDerivAt_log hz.ne')
  simp only [zero_sub] at h; exact h




theorem eml8a_not_medial :
    ∃ a b c d : ℝ, eml8a (eml8a a b) (eml8a c d) ≠ eml8a (eml8a a c) (eml8a b d) := by
  unfold eml8a;
  use 0;
  use Real.exp 1;
  refine' ⟨ 0, 1, _ ⟩ ; norm_num




theorem eml8a_not_flexible :
    ∃ a b : ℝ, eml8a (eml8a a b) a ≠ eml8a a (eml8a b a) := by
  unfold eml8a;
  refine' ⟨ 1, 0, _ ⟩ ; norm_num




theorem eml8a_not_left_alt :
    ∃ a b : ℝ, eml8a (eml8a a a) b ≠ eml8a a (eml8a a b) := by
  unfold eml8a;
  use 0; norm_num;
  use 1; norm_num




theorem eml8a_not_right_alt :
    ∃ a b : ℝ, eml8a (eml8a a b) b ≠ eml8a a (eml8a b b) := by
  unfold eml8a; use 0, 1; norm_num;




theorem eml8a_negation (x : ℝ) : eml8a 0 (Real.exp x) = 1 - x := by
  simp [eml8a, Real.log_exp]




theorem eml8a_double_neg (x : ℝ) :
    eml8a 0 (Real.exp (eml8a 0 (Real.exp x))) = x := by
  simp [eml8a, Real.log_exp]




theorem trop8a_diag (x : ℝ) : trop8a x x = |x| := by
  simp only [trop8a, abs_eq_max_neg]




theorem trop8a_noncomm : ∃ x y : ℝ, trop8a x y ≠ trop8a y x := by
  exact ⟨ 0, 1, by unfold trop8a; norm_num ⟩




theorem eml8a_ee : eml8a (eml8a 1 1) 1 = Real.exp (Real.exp 1) := by
  simp [eml8a, Real.log_one]




theorem eml8a_eee : eml8a (eml8a (eml8a 1 1) 1) 1 = Real.exp (Real.exp (Real.exp 1)) := by
  simp [eml8a, Real.log_one]




theorem eml8a_diag_compose (x : ℝ) :
    eml8a (diag8a x) (diag8a x) = diag8a (diag8a x) := by
  unfold eml8a diag8a; ring




theorem eml8a_subtraction (a b : ℝ) (ha : 0 < a) :
    eml8a (Real.log a) (Real.exp b) = a - b := by
  unfold eml8a; rw [Real.exp_log ha, Real.log_exp]




theorem eml8a_addition (a b : ℝ) (ha : 0 < a) :
    eml8a (Real.log a) (Real.exp (-b)) = a + b := by
  unfold eml8a; rw [Real.exp_log ha, Real.log_exp]; ring




/-- The trace is always ≥ 2 for positive arguments. -/
theorem eml8a_trace_ge_two (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    eml8a (Real.log a) b + eml8a (Real.log b) a ≥ 2 := by
  simp only [eml8a, Real.exp_log ha, Real.exp_log hb]
  linarith [Real.log_le_sub_one_of_pos ha, Real.log_le_sub_one_of_pos hb]




theorem eml8a_exp_exp_gt4 : Real.exp (Real.exp 1) > 4 := by
  -- Since $\exp(1) > 2$, we have $\exp(\exp(1)) > \exp(2)$.
  have h_exp_exp1_gt_exp2 : Real.exp (Real.exp 1) > Real.exp 2 := by
    exact Real.exp_lt_exp.mpr ( Real.exp_one_gt_d9.trans_le' <| by norm_num );
  exact h_exp_exp1_gt_exp2.trans_le' ( by have := Real.exp_one_gt_d9.le; norm_num1 at *; rw [ show ( 2 : ℝ ) = 1 + 1 by norm_num, Real.exp_add ] ; nlinarith )




end
