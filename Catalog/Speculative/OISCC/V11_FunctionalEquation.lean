/-! # CatalogBuild.Speculative.OISCC.V11_FunctionalEquation

Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 17
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Speculative.OISCC.V11_FunctionalEquation
Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 17] -/
def EML_fe (a b : ℝ) : ℝ := Real.exp a - Real.log b



/-- The "shadow" operator: S(x) = exp(x) - x. -/
def shadow (x : ℝ) : ℝ := Real.exp x - x



theorem shadow_pos (x : ℝ) : shadow x > 0 := by
  unfold shadow; linarith [Real.add_one_le_exp x]



theorem shadow_ge_one (x : ℝ) : shadow x ≥ 1 := by
  unfold shadow; linarith [Real.add_one_le_exp x]



theorem shadow_convex : ConvexOn ℝ Set.univ shadow := by
  exact convexOn_exp.sub (concaveOn_id (convex_univ))



theorem shadow_min_at_zero : shadow 0 = 1 := by simp [shadow]



theorem shadow_deriv_zero : HasDerivAt shadow 0 0 := by
  have h := (Real.hasDerivAt_exp (0 : ℝ)).sub (hasDerivAt_id (0 : ℝ))
  simp at h; exact h



theorem shadow_strictMono_pos : StrictMonoOn shadow (Ici 0) := by
  -- The derivative of $shadow(x) = e^x - x$ is $e^x - 1$, which is positive for $x > 0$.
  have h_deriv_pos : ∀ x > 0, deriv shadow x > 0 := by
    exact fun x pos => by rw [ show shadow = fun x => Real.exp x - x from funext fun _ => rfl ] ; norm_num [ Real.differentiableAt_exp ] ; linarith [ Real.add_one_le_exp x ] ;
  -- If the derivative of a function is positive on an interval, then the function is strictly increasing on that interval.
  intro x hx y hy hxy
  have h_deriv_pos_interval : ∀ z ∈ Set.Ioo x y, deriv shadow z > 0 := by
    exact fun z hz => h_deriv_pos z <| lt_of_le_of_lt hx.out hz.1;
  -- By the Mean Value Theorem, there exists some $c \in (x, y)$ such that $f'(c) = (f(y) - f(x)) / (y - x)$.
  obtain ⟨c, hc⟩ : ∃ c ∈ Set.Ioo x y, deriv shadow c = (shadow y - shadow x) / (y - x) := by
    apply_rules [ exists_deriv_eq_slope ];
    · exact Continuous.continuousOn ( by exact Continuous.sub ( Real.continuous_exp ) continuous_id' );
    · exact fun z hz => DifferentiableAt.differentiableWithinAt ( by exact differentiableAt_of_deriv_ne_zero ( ne_of_gt ( h_deriv_pos_interval z hz ) ) );
  have := h_deriv_pos_interval c hc.1; rw [ hc.2, gt_iff_lt ] at this; rw [ lt_div_iff₀ ] at this <;> linarith;



theorem depth_1_e : EML_fe 1 1 = Real.exp 1 := by
  simp [EML_fe, Real.log_one]



theorem depth_2_e_minus_1 : EML_fe 1 (Real.exp 1) = Real.exp 1 - 1 := by
  simp [EML_fe, Real.log_exp]



theorem depth_2_exp_e : EML_fe (Real.exp 1) 1 = Real.exp (Real.exp 1) := by
  simp [EML_fe, Real.log_one]



theorem depth_2_exp_e_minus_1 :
    EML_fe (Real.exp 1) (Real.exp 1) = Real.exp (Real.exp 1) - 1 := by
  simp [EML_fe, Real.log_exp]



theorem depth_2_all_positive :
    0 < Real.exp 1 - 1 ∧ 0 < Real.exp (Real.exp 1) ∧ 0 < Real.exp (Real.exp 1) - 1 := by
  refine ⟨by linarith [Real.exp_one_gt_d9], Real.exp_pos _, ?_⟩
  have : Real.exp (Real.exp 1) > 1 := by
    calc Real.exp (Real.exp 1) > Real.exp 1 :=
          Real.exp_lt_exp.mpr (by linarith [Real.exp_one_gt_d9])
      _ > 1 := by linarith [Real.exp_one_gt_d9]
  linarith



theorem two_not_depth_1 : EML_fe 1 1 ≠ 2 := by
  simp [EML_fe, Real.log_one]; linarith [Real.exp_one_gt_d9]



theorem two_not_depth_2 :
    Real.exp 1 - 1 ≠ 2 ∧ Real.exp (Real.exp 1) ≠ 2 ∧ (Real.exp (Real.exp 1) - 1) ≠ 2 := by
  constructor;
  · exact ne_of_lt ( by have := Real.exp_one_lt_d9.le; norm_num1 at *; linarith );
  · constructor <;> intro h <;> have := congr_arg Real.log h <;> norm_num at this;
    · exact absurd this ( by have := Real.exp_one_gt_d9.le; have := Real.log_two_lt_d9.le; norm_num1 at *; linarith );
    · exact absurd h ( by have := Real.exp_one_gt_d9.le; norm_num1 at *; linarith [ Real.add_one_le_exp ( Real.exp 1 ) ] )



/-- The EML entropy of a finite sequence. -/
def EML_entropy {n : ℕ} (x : Fin n → ℝ) : ℝ :=
  -(Finset.univ.sum (fun i => Real.exp (x i) - Real.log (x i) - 1))



theorem EML_entropy_nonpos {n : ℕ} (x : Fin n → ℝ) (hx : ∀ i, 0 < x i) :
    EML_entropy x ≤ 0 := by
  refine' neg_nonpos.mpr ( Finset.sum_nonneg fun i _ => _ );
  linarith [ hx i, Real.add_one_le_exp ( x i ), Real.log_le_sub_one_of_pos ( hx i ) ]



end
