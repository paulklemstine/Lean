/-! # CatalogBuild.Bridges.TropicalNeuralBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 9
-/

import Mathlib

noncomputable section

theorem max_as_relu (a b : ℝ) : max a b = b + relu (a - b) := by
  cases max_cases a b <;> cases max_cases 0 ( a - b ) <;> linarith!


theorem composition_lipschitz_bridge {f g : ℝ → ℝ} {L₁ L₂ : ℝ}
    (hf : ∀ x y, |f x - f y| ≤ L₁ * |x - y|)
    (hg : ∀ x y, |g x - g y| ≤ L₂ * |x - y|)
    (hL₁ : 0 ≤ L₁) :
    ∀ x y, |f (g x) - f (g y)| ≤ L₁ * L₂ * |x - y| := by
  exact fun x y => le_trans ( hf _ _ ) ( by rw [ mul_assoc ] ; exact mul_le_mul_of_nonneg_left ( hg _ _ ) hL₁ )


/-- The softplus function: softplus(x) = ln(1 + e^x). -/
def softplus (x : ℝ) : ℝ := Real.log (1 + Real.exp x)


theorem softplus_pos (x : ℝ) : 0 < softplus x := by
  exact Real.log_pos ( by linarith [ Real.exp_pos x ] )


theorem softplus_ge_relu (x : ℝ) : relu x ≤ softplus x := by
  unfold relu softplus;
  cases max_cases ( 0 : ℝ ) x <;> simp +decide [ * ];
  · exact Real.log_nonneg ( by linarith [ Real.exp_pos x ] );
  · rw [ Real.le_log_iff_exp_le ] <;> linarith [ Real.exp_pos x ]


theorem softplus_le_relu_add_log2 (x : ℝ) :
    softplus x ≤ relu x + Real.log 2 := by
  unfold softplus relu;
  rw [ Real.log_le_iff_le_exp ];
  · cases max_cases ( 0 : ℝ ) x <;> simp +decide [ *, Real.exp_add, Real.exp_log ];
    · linarith [ Real.exp_le_one_iff.2 ( by linarith : x ≤ 0 ) ];
    · linarith [ Real.add_one_le_exp x ];
  · positivity


theorem trop_mul_dist (a b c : ℝ) :
    a + max b c = max (a + b) (a + c) := by
  cases max_cases b c <;> cases max_cases ( a + b ) ( a + c ) <;> linarith


theorem lse_le_max_log2 (a b : ℝ) : logSumExp a b ≤ max a b + Real.log 2 := by
  rw [ logSumExp, ← Real.log_exp ( max a b ) ];
  rw [ ← Real.log_mul ( by positivity ) ( by positivity ) ] ; gcongr;
  cases max_cases a b <;> linarith [ Real.exp_le_exp.2 ( le_max_left a b ), Real.exp_le_exp.2 ( le_max_right a b ) ]


/-- LogSumExp is commutative. -/
theorem lse_comm (a b : ℝ) : logSumExp a b = logSumExp b a := by
  unfold logSumExp; ring_nf


end
