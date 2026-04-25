/-! # CatalogBuild.Speculative.OpenProblems.EMLSPBUnification

Auto-generated from theorem catalog database.
Domain: Speculative/OpenProblems
Declarations: 9
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Speculative.OpenProblems.EMLSPBUnification
Auto-generated from theorem catalog database.
Domain: Speculative/OpenProblems
Declarations: 9] -/
def spbU (x y : ℝ) : ℝ := (x + y) / (1 - x * y)


/-- Multiplication is exp-conjugate to addition. -/
theorem mul_is_exp_conjugate (a b : ℝ) :
    exp a * exp b = exp (a + b) := by rw [← exp_add]


/-- [Section: # CatalogBuild.Speculative.OpenProblems.EMLSPBUnification
Auto-generated from theorem catalog database.
Domain: Speculative/OpenProblems
Declarations: 9] -/
theorem spb_is_tan_conjugate (x y : ℝ) (h : 0 < 1 - x * y) :
    arctan (spbU x y) = arctan x + arctan y := by
  rw [ spbU, Real.arctan_eq_of_tan_eq ];
  · rw [ Real.tan_add, Real.tan_arctan, Real.tan_arctan ];
    exact Or.inl ⟨ fun k => by cases k <;> norm_num <;> rw [ eq_div_iff ] <;> nlinarith [ Real.neg_pi_div_two_lt_arctan x, Real.arctan_lt_pi_div_two x ], fun k => by cases k <;> norm_num <;> rw [ eq_div_iff ] <;> nlinarith [ Real.neg_pi_div_two_lt_arctan y, Real.arctan_lt_pi_div_two y ] ⟩;
  · constructor <;> contrapose! h;
    · -- If $\arctan x + \arctan y \leq -\frac{\pi}{2}$, then $\tan(\arctan x + \arctan y) \geq 0$.
      have h_tan_nonneg : Real.tan (arctan x + arctan y) ≥ 0 := by
        rw [ ← Real.tan_periodic ] ; exact Real.tan_nonneg_of_nonneg_of_le_pi_div_two ( by linarith [ Real.neg_pi_div_two_lt_arctan x, Real.arctan_lt_pi_div_two x, Real.neg_pi_div_two_lt_arctan y, Real.arctan_lt_pi_div_two y ] ) ( by linarith [ Real.neg_pi_div_two_lt_arctan x, Real.arctan_lt_pi_div_two x, Real.neg_pi_div_two_lt_arctan y, Real.arctan_lt_pi_div_two y ] ) ;
      rw [ Real.tan_add ] at h_tan_nonneg;
      · contrapose! h_tan_nonneg;
        rw [ div_lt_iff₀ ] <;> norm_num;
        · contrapose! h;
          by_cases hx : x < 0;
          · linarith [ Real.arctan_lt_zero.2 hx, Real.arctan_nonneg.2 ( by linarith : 0 ≤ y ), Real.neg_pi_div_two_lt_arctan x, Real.arctan_lt_pi_div_two x, Real.neg_pi_div_two_lt_arctan y, Real.arctan_lt_pi_div_two y ];
          · linarith [ Real.pi_pos, Real.arctan_nonneg.2 ( le_of_not_gt hx ), Real.neg_pi_div_two_lt_arctan y ];
        · linarith;
      · exact Or.inl ⟨ fun k => by cases k <;> norm_num <;> rw [ eq_div_iff ] <;> nlinarith [ Real.neg_pi_div_two_lt_arctan x, Real.arctan_lt_pi_div_two x ], fun k => by cases k <;> norm_num <;> rw [ eq_div_iff ] <;> nlinarith [ Real.neg_pi_div_two_lt_arctan y, Real.arctan_lt_pi_div_two y ] ⟩;
    · -- Since $\arctan x + \arctan y \geq \frac{\pi}{2}$, we have $\tan(\arctan x + \arctan y) \leq 0$.
      have h_tan_nonpos : Real.tan (arctan x + arctan y) ≤ 0 := by
        rw [ Real.tan_eq_sin_div_cos ];
        exact div_nonpos_of_nonneg_of_nonpos ( Real.sin_nonneg_of_nonneg_of_le_pi ( by linarith [ Real.neg_pi_div_two_lt_arctan x, Real.arctan_lt_pi_div_two x, Real.neg_pi_div_two_lt_arctan y, Real.arctan_lt_pi_div_two y ] ) ( by linarith [ Real.neg_pi_div_two_lt_arctan x, Real.arctan_lt_pi_div_two x, Real.neg_pi_div_two_lt_arctan y, Real.arctan_lt_pi_div_two y ] ) ) ( Real.cos_nonpos_of_pi_div_two_le_of_le h ( by linarith [ Real.neg_pi_div_two_lt_arctan x, Real.arctan_lt_pi_div_two x, Real.neg_pi_div_two_lt_arctan y, Real.arctan_lt_pi_div_two y ] ) );
      rw [ Real.tan_add ] at h_tan_nonpos;
      · contrapose! h_tan_nonpos;
        rw [ lt_div_iff₀ ] <;> norm_num <;> nlinarith [ Real.arctan_lt_pi_div_two x, Real.arctan_lt_pi_div_two y, show x > 0 from not_le.mp fun hx => by linarith [ Real.arctan_le_zero.2 hx, Real.arctan_lt_pi_div_two y ], show y > 0 from not_le.mp fun hy => by linarith [ Real.arctan_le_zero.2 hy, Real.arctan_lt_pi_div_two x ] ];
      · exact Or.inl ⟨ fun k => by cases k <;> norm_num <;> rw [ eq_div_iff ] <;> nlinarith [ Real.neg_pi_div_two_lt_arctan x, Real.arctan_lt_pi_div_two x ], fun k => by cases k <;> norm_num <;> rw [ eq_div_iff ] <;> nlinarith [ Real.neg_pi_div_two_lt_arctan y, Real.arctan_lt_pi_div_two y ] ⟩


/-- Weierstrass Pythagorean identity. -/
theorem weierstrass_pythagoras (t : ℝ) (h : 1 + t ^ 2 ≠ 0) :
    ((1 - t ^ 2) / (1 + t ^ 2)) ^ 2 + (2 * t / (1 + t ^ 2)) ^ 2 = 1 := by
  field_simp; ring


/-- EML with exp is multiplication. -/
theorem eml_exp_is_mul (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    exp (log a + log b) = a * b := by
  rw [exp_add, exp_log ha, exp_log hb]


/-- [Section: # CatalogBuild.Speculative.OpenProblems.EMLSPBUnification
Auto-generated from theorem catalog database.
Domain: Speculative/OpenProblems
Declarations: 9] -/
theorem eml_identity_exp : exp (0 : ℝ) = 1 := exp_zero


theorem eml_identity_spb : spbU 0 0 = 0 := by simp [spbU]


/-- Double angle formula as SPB self-application. -/
theorem double_angle_is_spb_self (t : ℝ) (h : 1 - t * t ≠ 0) :
    spbU t t = 2 * t / (1 - t ^ 2) := by
  unfold spbU; field_simp; ring


theorem triple_angle_spb (t : ℝ) (h1 : 1 - t * t ≠ 0)
    (h2 : 1 - t * spbU t t ≠ 0) :
    spbU t (spbU t t) = (3 * t - t ^ 3) / (1 - 3 * t ^ 2) := by
  unfold spbU;
  grind


end
