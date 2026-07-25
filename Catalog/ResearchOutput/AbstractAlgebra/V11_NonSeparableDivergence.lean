import Mathlib

/-! # CatalogBuild.Speculative.OISCC.V11_NonSeparableDivergence

Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 18
-/

noncomputable section

/-- [Section: # CatalogBuild.Speculative.OISCC.V11_NonSeparableDivergence
Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 18] -/
def EML_ns (a b : ℝ) : ℝ := Real.exp a - Real.log b

def f_ns (x : ℝ) : ℝ := Real.exp x - Real.log x - 1

def D1 (x y : ℝ) : ℝ := f_ns x + f_ns y

theorem D1_symm (x y : ℝ) : D1 x y = D1 y x := by simp [D1]; ring

def D2 (x y : ℝ) : ℝ := f_ns (EML_ns x y) + f_ns (EML_ns y x)

theorem D2_symm (x y : ℝ) : D2 x y = D2 y x := by simp [D2, EML_ns, f_ns]; ring

theorem D2_diag (x : ℝ) :
    D2 x x = 2 * f_ns (Real.exp x - Real.log x) := by
  unfold D2 EML_ns f_ns; ring

theorem D2_formula (x y : ℝ) :
    D2 x y = Real.exp (Real.exp x - Real.log y)
           + Real.exp (Real.exp y - Real.log x)
           - Real.log (Real.exp x - Real.log y)
           - Real.log (Real.exp y - Real.log x)
           - 2 := by
  simp [D2, f_ns, EML_ns]; ring

def MI_D2 (x y : ℝ) : ℝ := D2 x y - (D2 x x + D2 y y) / 2

theorem MI_D2_symm (x y : ℝ) : MI_D2 x y = MI_D2 y x := by
  unfold MI_D2; rw [D2_symm x y, add_comm (D2 y y)]

theorem MI_D2_self (x : ℝ) : MI_D2 x x = 0 := by
  unfold MI_D2; ring

theorem D2_pos (x y : ℝ) (hx : 0 < x) (hy : 0 < y) : D2 x y > 0 := by
  -- Since $f_ns(t) \geq t$ for all $t$, we have $f_ns(EML_ns x y) \geq EML_ns x y$ and $f_ns(EML_ns y x) \geq EML_ns y x$.
  have h_f_ns_ge : ∀ t : ℝ, f_ns t ≥ t := by
    intro t;
    by_cases ht : 0 < t;
    · have := Real.add_one_le_exp ( t - 1 );
      unfold f_ns;
      rw [ show t = ( t - 1 ) + 1 by ring, Real.exp_add ];
      nlinarith [ Real.add_one_le_exp 1, Real.log_le_sub_one_of_pos ( by linarith : 0 < t - 1 + 1 ) ];
    · unfold f_ns;
      by_cases ht : t = 0 <;> simp_all +decide [ Real.log_le_iff_le_exp ];
      by_contra h_contra;
      exact ht <| by nlinarith [ Real.log_le_sub_one_of_pos <| neg_pos.mpr <| lt_of_le_of_ne ‹_› ht, Real.log_neg_eq_log t, Real.exp_pos t, Real.exp_neg t, mul_inv_cancel₀ <| ne_of_gt <| Real.exp_pos t, Real.add_one_le_exp <| -t ] ;
  -- Applying the inequality $f_ns(t) \geq t$ to both terms in $D2$, we get $D2 x y \geq (EML_ns x y + EML_ns y x)$.
  have h_D2_ge_sum : D2 x y ≥ (EML_ns x y + EML_ns y x) := by
    exact add_le_add ( h_f_ns_ge _ ) ( h_f_ns_ge _ );
  unfold EML_ns at *; linarith [ Real.add_one_le_exp x, Real.add_one_le_exp y, Real.log_le_sub_one_of_pos hx, Real.log_le_sub_one_of_pos hy ] ;

def Phi_ns (p : ℝ × ℝ) : ℝ × ℝ := (EML_ns p.1 p.2, EML_ns p.2 p.1)

def D_iter_ns : ℕ → ℝ → ℝ → ℝ
  | 0, x, y => D1 x y
  | n + 1, x, y => let p := Phi_ns (x, y); D_iter_ns n p.1 p.2

theorem D_iter_ns_symm (n : ℕ) (x y : ℝ) :
    D_iter_ns n x y = D_iter_ns n y x := by
  induction n generalizing x y with
  | zero => exact D1_symm x y
  | succ n ih => simp [D_iter_ns, Phi_ns]; exact ih (EML_ns x y) (EML_ns y x)

def amp_ratio (x y : ℝ) : ℝ := D2 x y / D1 x y

theorem amp_ratio_symm (x y : ℝ) : amp_ratio x y = amp_ratio y x := by
  simp [amp_ratio, D2_symm, D1_symm]

theorem amp_ratio_diag (x : ℝ) (hx : 0 < x) :
    amp_ratio x x = f_ns (Real.exp x - Real.log x) / f_ns x := by
  unfold amp_ratio D2 D1;
  ring!

end