/-
# OISCC V9.1: New Mathematical Discoveries
-/

import Mathlib

noncomputable section

open Real Filter Topology Set

def EML_new (a b : ℝ) : ℝ := Real.exp a - Real.log b

theorem EML_conjugation (a b c : ℝ) :
    EML_new a (Real.exp (EML_new b c)) = Real.exp a - Real.exp b + Real.log c := by
  simp [EML_new, Real.log_exp]; ring

theorem EML_self_conjugation (a c : ℝ) :
    EML_new a (Real.exp (EML_new a c)) = Real.log c := by
  rw [EML_conjugation]; ring

theorem EML_diagonal_quadratic_bound (x : ℝ) (hx : 0 < x) :
    EML_new x x ≥ x ^ 2 / 2 + 2 := by
  unfold EML_new
  nlinarith [quadratic_le_exp_of_nonneg hx.le, Real.log_le_sub_one_of_pos hx]

/-
The diagonal map is strictly increasing on [1, ∞).
-/
theorem EML_diagonal_strictMono_ge_one :
    StrictMonoOn (fun x => EML_new x x) (Set.Ici 1) := by
  -- To prove strict monotonicity, we show that the derivative of $EML_new x x$ is positive for $x \geq 1$.
  have h_deriv_pos : ∀ x : ℝ, 1 ≤ x → deriv (fun x => Real.exp x - Real.log x) x > 0 := by
    intro x hx; norm_num [ Real.differentiableAt_exp, Real.differentiableAt_log, ne_of_gt ( zero_lt_one.trans_le hx ) ];
    nlinarith [ Real.add_one_le_exp x, mul_inv_cancel₀ ( ne_of_gt ( zero_lt_one.trans_le hx ) ) ];
  -- Apply the fact that if the derivative of a function is positive on an interval, then the function is strictly increasing on that interval.
  have h_strict_mono : StrictMonoOn (fun x => Real.exp x - Real.log x) (Set.Ici 1) := by
    have : ∀ x ∈ Set.Ici 1, deriv (fun x => Real.exp x - Real.log x) x > 0 := h_deriv_pos
    apply_rules [ strictMonoOn_of_deriv_pos ];
    · exact convex_Ici _;
    · exact continuousOn_of_forall_continuousAt fun x hx => ContinuousAt.sub ( Real.continuous_exp.continuousAt ) ( Real.continuousAt_log ( by linarith [ hx.out ] ) );
    · exact fun x hx => this x <| interior_subset hx;
  exact fun x hx y hy hxy => h_strict_mono hx hy hxy

def EML_divergence (x y : ℝ) : ℝ := EML_new x y + EML_new y x - 2

theorem EML_divergence_symm (x y : ℝ) : EML_divergence x y = EML_divergence y x := by
  simp [EML_divergence, EML_new]; ring

theorem EML_divergence_pos (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    EML_divergence x y > 0 := by
  simp only [EML_divergence, EML_new]
  nlinarith [quadratic_le_exp_of_nonneg hx.le, quadratic_le_exp_of_nonneg hy.le,
    Real.log_le_sub_one_of_pos hx, Real.log_le_sub_one_of_pos hy,
    sq_nonneg x, sq_nonneg y]

def symmetryDefect (a b : ℝ) : ℝ := EML_new a b - EML_new b a

theorem symmetryDefect_formula (a b : ℝ) :
    symmetryDefect a b = (Real.exp a - Real.exp b) + (Real.log a - Real.log b) := by
  simp [symmetryDefect, EML_new]; ring

theorem symmetryDefect_antisymm (a b : ℝ) :
    symmetryDefect a b = -symmetryDefect b a := by
  simp [symmetryDefect, EML_new]

theorem symmetryDefect_self (a : ℝ) : symmetryDefect a a = 0 := by
  simp [symmetryDefect]

theorem exp_minus_id_minus_log_pos (c : ℝ) (hc : 0 < c) :
    Real.exp c - c - Real.log c > 0 := by
  nlinarith [quadratic_le_exp_of_nonneg hc.le, Real.log_le_sub_one_of_pos hc, sq_nonneg c]

theorem EML_depth2_e_minus_1 : EML_new 1 (Real.exp 1) = Real.exp 1 - 1 := by
  simp [EML_new, Real.log_exp]

theorem EML_depth2_exp_e : EML_new (Real.exp 1) 1 = Real.exp (Real.exp 1) := by
  simp [EML_new, Real.log_one]

theorem EML_depth2_exp_e_minus_1 :
    EML_new (Real.exp 1) (Real.exp 1) = Real.exp (Real.exp 1) - 1 := by
  simp [EML_new, Real.log_exp]

theorem K_EML_2_gt_1 : EML_new 1 1 ≠ 2 := by
  simp [EML_new, Real.log_one]; intro h; linarith [Real.exp_one_gt_d9]

theorem e_minus_one_lt_two : Real.exp 1 - 1 < 2 := by linarith [Real.exp_one_lt_d9]
theorem e_gt_two : Real.exp 1 > 2 := by linarith [Real.exp_one_gt_d9]

/-- EML amplification for non-negative first argument:
    If a ≥ 0 and δ > 0, the change in EML exceeds δ.
    This is because exp(a) ≥ 1 when a ≥ 0. -/
theorem EML_amplification (a b δ : ℝ) (ha : 0 ≤ a) (hδ : 0 < δ) :
    EML_new (a + δ) b - EML_new a b > δ := by
  simp only [EML_new]
  -- Need: exp(a+δ) - exp(a) > δ
  -- = exp(a)(exp(δ) - 1) ≥ 1 * (exp(δ) - 1) ≥ 1 * (δ + δ²/2) > δ
  have h1 := Real.exp_add a δ
  have h2 := quadratic_le_exp_of_nonneg hδ.le
  have h3 : Real.exp a ≥ 1 := Real.one_le_exp ha
  nlinarith [sq_nonneg δ]

theorem EML_legendre_form (u v : ℝ) :
    EML_new u (Real.exp v) = Real.exp u - v := by
  simp [EML_new, Real.log_exp]

end