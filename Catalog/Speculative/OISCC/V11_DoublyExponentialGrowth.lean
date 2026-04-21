/-! # CatalogBuild.Speculative.OISCC.V11_DoublyExponentialGrowth

Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 21
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Speculative.OISCC.V11_DoublyExponentialGrowth
Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 21] -/
def EML_de (a b : ℝ) : ℝ := Real.exp a - Real.log b


def d_de (x : ℝ) : ℝ := Real.exp x - Real.log x



theorem d_de_lower1 (x : ℝ) (hx : 0 < x) : d_de x ≥ Real.exp x - x + 1 := by
  unfold d_de; linarith [Real.log_le_sub_one_of_pos hx]



theorem d_de_half_exp (x : ℝ) (hx : 2 ≤ x) : d_de x ≥ Real.exp x / 2 := by
  -- We'll use that $e^x \geq 1 + x + \frac{x^2}{2}$ for $x \geq 0$.
  have h_exp_bound : ∀ x : ℝ, 0 ≤ x → Real.exp x ≥ 1 + x + x^2 / 2 := by
    exact?;
  exact le_trans ( by nlinarith [ h_exp_bound x ( by linarith ) ] ) ( d_de_lower1 x ( by linarith ) )



theorem d_de_gt_id (x : ℝ) (hx : 0 < x) : d_de x > x := by
  unfold d_de
  nlinarith [quadratic_le_exp_of_nonneg hx.le, Real.log_le_sub_one_of_pos hx, sq_nonneg x]



theorem d_de_ge_two (x : ℝ) (hx : 0 < x) : d_de x ≥ 2 := by
  unfold d_de; linarith [Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hx]



def d_iter : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => d_de (d_iter n x)



theorem d_iter_pos (n : ℕ) (x : ℝ) (hx : 0 < x) : 0 < d_iter n x := by
  induction n with
  | zero => exact hx
  | succ n ih => exact lt_of_lt_of_le (by norm_num) (d_de_ge_two _ ih)



theorem d_iter_ge_two (n : ℕ) (x : ℝ) (hx : 0 < x) (hn : 1 ≤ n) :
    d_iter n x ≥ 2 := by
  cases n with
  | zero => omega
  | succ n => exact d_de_ge_two _ (d_iter_pos n x hx)



theorem d_iter_strictMono (n : ℕ) (x : ℝ) (hx : 0 < x) :
    d_iter n x < d_iter (n + 1) x :=
  d_de_gt_id _ (d_iter_pos n x hx)



theorem d_iter_linear_lower (n : ℕ) (x : ℝ) (hx : 0 < x) :
    d_iter n x ≥ x + n := by
  induction' n with n ih <;> norm_num [ * ] at *;
  · rfl;
  · -- By definition of $d_iter$, we have $d_iter (n + 1) x = d_de (d_iter n x)$.
    have h_def : d_iter (n + 1) x = Real.exp (d_iter n x) - Real.log (d_iter n x) := by
      exact?;
    have := Real.add_one_le_exp ( d_iter n x - 1 );
    rw [ Real.exp_sub ] at this;
    rw [ le_div_iff₀ ] at this <;> nlinarith [ Real.add_one_le_exp 1, Real.log_le_sub_one_of_pos ( show 0 < d_iter n x from by linarith ) ]



theorem d_iter_tendsto_atTop (x : ℝ) (hx : 0 < x) :
    Filter.Tendsto (fun n => d_iter n x) atTop atTop := by
  apply Filter.tendsto_atTop_atTop.mpr
  intro b; use ⌈b⌉₊; intro n hn
  have := d_iter_linear_lower n x hx
  have h1 : (n : ℝ) ≥ ⌈b⌉₊ := by exact_mod_cast hn
  linarith [Nat.le_ceil b]



def Phi_de (p : ℝ × ℝ) : ℝ × ℝ := (EML_de p.1 p.2, EML_de p.2 p.1)


def S_de (p : ℝ × ℝ) : ℝ := p.1 + p.2



theorem S_grows_by_two (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    S_de (Phi_de (x, y)) ≥ S_de (x, y) + 2 := by
  unfold S_de Phi_de EML_de;
  have := Real.add_one_le_exp ( x - 1 );
  have := Real.add_one_le_exp ( y - 1 );
  norm_num [ Real.exp_sub ] at *;
  rw [ le_div_iff₀ ( Real.exp_pos _ ) ] at *;
  nlinarith [ Real.add_one_le_exp 1, Real.log_le_sub_one_of_pos hx, Real.log_le_sub_one_of_pos hy ]



def V_de (p : ℝ × ℝ) : ℝ := Real.exp p.1 + Real.exp p.2



/-- V is always positive. -/
theorem V_de_pos (p : ℝ × ℝ) : V_de p > 0 := by
  unfold V_de; positivity



/-- V ≥ 2 when both coordinates are non-negative. -/
theorem V_de_ge_two (p : ℝ × ℝ) (h1 : 0 ≤ p.1) (h2 : 0 ≤ p.2) : V_de p ≥ 2 := by
  unfold V_de; linarith [Real.add_one_le_exp p.1, Real.add_one_le_exp p.2]



theorem V_after_Phi (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    V_de (Phi_de (x, y)) = Real.exp (Real.exp x) / y + Real.exp (Real.exp y) / x := by
  simp [V_de, Phi_de, EML_de, Real.exp_sub, Real.exp_log hx, Real.exp_log hy]



theorem V_superexp_lower (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    V_de (Phi_de (x, y)) ≥ Real.exp (Real.exp x) / y := by
  rw [V_after_Phi x y hx hy]
  linarith [div_pos (Real.exp_pos (Real.exp y)) hx]



theorem max_coord_superlinear (x y : ℝ) (hx : 2 ≤ x) (hy : 2 ≤ y) :
    max (Phi_de (x, y)).1 (Phi_de (x, y)).2 > max x y := by
  -- By definition of $EML$, we know that $EML(x, y) = \exp(x) - \log(y)$ and $EML(y, x) = \exp(y) - \log(x)$.
  simp [Phi_de, EML_de];
  by_cases hxy : x ≤ y;
  · refine Or.inr ⟨ ?_, ?_ ⟩;
    · rw [ lt_sub_comm, Real.log_lt_iff_lt_exp ];
      · rw [ ← Real.log_lt_iff_lt_exp ( by positivity ) ];
        have := Real.log_le_sub_one_of_pos ( by positivity : 0 < x / 2 );
        rw [ Real.log_div ] at this <;> try linarith;
        have := Real.exp_one_gt_d9.le;
        rw [ show Real.exp y = Real.exp 1 * Real.exp ( y - 1 ) by rw [ ← Real.exp_add, add_sub_cancel ] ];
        nlinarith [ Real.add_one_le_exp ( y - 1 ), Real.log_le_sub_one_of_pos zero_lt_two ];
      · linarith;
    · rw [ show Real.exp y = Real.exp ( y - 1 ) * Real.exp 1 by rw [ ← Real.exp_add, sub_add_cancel ] ];
      nlinarith [ Real.add_one_le_exp ( y - 1 ), Real.add_one_le_exp 1, Real.log_le_sub_one_of_pos ( by linarith : 0 < x ) ];
  · refine' Or.inl ⟨ _, _ ⟩;
    · have := Real.exp_one_gt_d9.le;
      rw [ show x = 1 + ( x - 1 ) by ring, Real.exp_add ];
      nlinarith [ Real.add_one_le_exp ( x - 1 ), Real.log_le_sub_one_of_pos ( by linarith : 0 < y ) ];
    · have := Real.log_le_sub_one_of_pos ( by linarith : 0 < y );
      rw [ show x = 2 + ( x - 2 ) by ring, Real.exp_add ];
      nlinarith [ Real.add_one_le_exp 2, Real.add_one_le_exp ( x - 2 ) ]



end
