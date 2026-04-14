/-
# EML Open Problems: Formalized Results

## Overview
This file formalizes results related to the open problems identified in the
OISCC research agenda. We prove new theorems about:

1. Complex EML and trigonometry (Problem 7)
2. EML depth hierarchy separation (Problem 5)
3. Condition numbers and error propagation (Problem 4)
4. EML algebraic structure (Problem 6)
5. Tropical EML (Problem 9)
6. Sigmoid via EML
7. EML functional equations
8. EML power tower and information content
-/

import Mathlib

noncomputable section

open Real Complex Set Filter Topology

/-! ## Section 1: The Real EML Operator (local definition) -/

/-- The real EML operator. -/
def emlOP (x y : ℝ) : ℝ := Real.exp x - Real.log y

/-- The complex EML operator. -/
def ceml (x y : ℂ) : ℂ := Complex.exp x - Complex.log y

/-! ## Section 2: Complex EML and Trigonometry (Problem 7) -/

/-- Complex EML at (ix, 1) gives Euler's formula. -/
theorem ceml_euler (x : ℝ) :
    ceml (↑x * Complex.I) 1 = Complex.exp (↑x * Complex.I) := by
  simp [ceml, Complex.log_one]

/-- ceml(0, 1) = 1 (complex version). -/
theorem ceml_one : ceml 0 1 = 1 := by
  simp [ceml, Complex.log_one, Complex.exp_zero]

/-- ceml(1, 1) = e (complex version). -/
theorem ceml_e_val : ceml 1 1 = Complex.exp 1 := by
  simp [ceml, Complex.log_one]

/-! ## Section 3: EML Depth Hierarchy (Problem 5) -/

/-- exp is not a constant function, separating depth 0 from depth 1. -/
theorem exp_not_constant_fn : ∃ x y : ℝ, Real.exp x ≠ Real.exp y :=
  ⟨0, 1, by simp; linarith [Real.exp_one_gt_d9]⟩

/-
The function exp(exp(x)) cannot equal any affine function exp(ax+b).
    This shows depth-2 functions are strictly richer than depth-1.
-/
theorem double_exp_not_affine_exp :
    ∀ a b : ℝ, (fun x => Real.exp (a * x + b)) ≠ (fun x => Real.exp (Real.exp x)) := by
  intro a b h; have := congr_fun h 0; have := congr_fun h 1; have := congr_fun h ( -1 ) ; norm_num at *;
  exact absurd ( congr_arg ( fun f => deriv ( deriv f ) 0 ) h ) ( by norm_num [ Real.differentiableAt_exp, mul_comm a ] ; nlinarith [ Real.add_one_le_exp 1, Real.exp_pos ( -1 ) ] )

/-! ## Section 4: Condition Numbers (Problem 4) -/

/-- The condition number of EML w.r.t. the first argument. -/
def emlCondX (x y : ℝ) : ℝ := |x * Real.exp x / emlOP x y|

/-- At x = 0, the first-argument condition number vanishes. -/
theorem emlCondX_at_zero (y : ℝ) :
    emlCondX 0 y = 0 := by
  simp [emlCondX, Real.exp_zero]

/-- When y = 1, the condition number in x simplifies to |x|. -/
theorem emlCondX_at_y_one (x : ℝ) :
    emlCondX x 1 = |x| := by
  simp only [emlCondX, emlOP, Real.log_one, sub_zero]
  rw [abs_div, abs_mul, abs_of_pos (Real.exp_pos x)]
  field_simp

/-! ## Section 5: EML Algebraic Structure (Problem 6) -/

/-- EML has no right identity element. -/
theorem eml_no_right_identity :
    ¬ ∃ e : ℝ, ∀ x, emlOP x e = x := by
  intro ⟨e_id, h⟩
  have h0 := h 0
  have h1 := h 1
  simp only [emlOP, Real.exp_zero] at h0
  simp only [emlOP] at h1
  linarith [Real.exp_one_gt_d9]

/-
EML has no left identity element.
-/
theorem eml_no_left_identity :
    ¬ ∃ e : ℝ, ∀ x, emlOP e x = x := by
  unfold emlOP;
  rintro ⟨ e, he ⟩;
  have := he ( -1 ) ; have := he 1 ; have := he ( Real.exp 0 ) ; have := he ( Real.exp 1 ) ; norm_num at * ; linarith [ Real.add_one_le_exp e ] ;

/-- EML has no two-sided identity element. -/
theorem eml_no_identity :
    ¬ ∃ e : ℝ, (∀ x, emlOP e x = x) ∧ (∀ x, emlOP x e = x) := by
  intro ⟨_, _, hr⟩
  exact eml_no_right_identity ⟨_, hr⟩

/-! ## Section 6: Tropical EML (Problem 9) -/

/-- The tropical EML operator: tropical EML(a,b) = a - b. -/
def tropicalEML (a b : ℝ) : ℝ := a - b

/-- Tropical EML has right identity 0. -/
theorem tropicalEML_right_identity (a : ℝ) : tropicalEML a 0 = a := by
  simp [tropicalEML]

/-- Tropical EML is anti-commutative. -/
theorem tropicalEML_anticommutative (a b : ℝ) :
    tropicalEML a b = -tropicalEML b a := by
  unfold tropicalEML; ring

/-- Tropical EML is NOT associative in general:
    (1-1)-1 = -1 but 1-(1-1) = 1. -/
theorem tropicalEML_not_assoc :
    ∃ a b c : ℝ, tropicalEML (tropicalEML a b) c ≠ tropicalEML a (tropicalEML b c) := by
  exact ⟨1, 1, 1, by norm_num [tropicalEML]⟩

/-! ## Section 7: Sigmoid via EML -/

/-- The sigmoid function for OISCC. -/
def oiscc_sigmoid (x : ℝ) : ℝ := 1 / (1 + Real.exp (-x))

/-- sigmoid(0) = 1/2. -/
theorem oiscc_sigmoid_zero : oiscc_sigmoid 0 = 1 / 2 := by
  unfold oiscc_sigmoid; simp [Real.exp_zero]; ring

/-- Sigmoid is always positive. -/
theorem oiscc_sigmoid_pos (x : ℝ) : 0 < oiscc_sigmoid x := by
  unfold oiscc_sigmoid; positivity

/-- Sigmoid is always less than 1. -/
theorem oiscc_sigmoid_lt_one (x : ℝ) : oiscc_sigmoid x < 1 := by
  unfold oiscc_sigmoid
  rw [div_lt_one (by positivity : (0:ℝ) < 1 + Real.exp (-x))]
  linarith [Real.exp_pos (-x)]

/-! ## Section 8: EML Functional Equations -/

/-- EML scaling in second argument: eml(x, y·z) = eml(x, y) - ln(z) for y, z > 0. -/
theorem eml_log_split (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    emlOP x (y * z) = emlOP x y - Real.log z := by
  simp only [emlOP]
  rw [Real.log_mul (ne_of_gt hy) (ne_of_gt hz)]
  ring

/-
EML chain rule for composed functions.
-/
theorem eml_chain_rule (g h : ℝ → ℝ) (x : ℝ) (g' h' : ℝ)
    (hg : HasDerivAt g g' x) (hh : HasDerivAt h h' x)
    (hh_ne : h x ≠ 0) :
    HasDerivAt (fun t => emlOP (g t) (h t))
      (g' * Real.exp (g x) - h' / (h x)) x := by
  unfold emlOP; convert HasDerivAt.sub ( HasDerivAt.comp x ( Real.hasDerivAt_exp ( g x ) ) hg ) ( HasDerivAt.log hh hh_ne ) using 1 ; ring;

/-! ## Section 9: EML Power Tower -/

/-- The n-fold EML power tower starting from constant 1. -/
def emlTower' : ℕ → ℝ
  | 0 => 1
  | n + 1 => emlOP (emlTower' n) 1

/-- The EML tower simplifies to iterated exp. -/
theorem emlTower'_succ (n : ℕ) : emlTower' (n + 1) = Real.exp (emlTower' n) := by
  simp [emlTower', emlOP, Real.log_one]

/-- Each EML tower value is positive. -/
theorem emlTower'_pos : ∀ n, 0 < emlTower' n := by
  intro n; induction n with
  | zero => simp [emlTower']
  | succ n _ => rw [emlTower'_succ]; exact Real.exp_pos _

/-- The EML tower is strictly increasing. -/
theorem emlTower'_strict_mono : StrictMono emlTower' := by
  apply strictMono_nat_of_lt_succ
  intro n
  rw [emlTower'_succ]
  linarith [Real.add_one_le_exp (emlTower' n), emlTower'_pos n]

/-! ## Section 10: Catalan Numbers and EML Tree Counting -/

/-- Catalan numbers (counting distinct EML tree shapes with n nodes). -/
def emlCatalan : ℕ → ℕ
  | 0 => 1
  | n + 1 =>
    (Finset.range (n + 1)).attach.sum fun ⟨k, hk⟩ =>
      have : k < n + 1 := Finset.mem_range.mp hk
      have : n - k < n + 1 := Nat.sub_lt_succ n k
      emlCatalan k * emlCatalan (n - k)
termination_by n => n

theorem emlCatalan_one : emlCatalan 1 = 1 := by native_decide
theorem emlCatalan_two : emlCatalan 2 = 2 := by native_decide
theorem emlCatalan_three : emlCatalan 3 = 5 := by native_decide
theorem emlCatalan_four : emlCatalan 4 = 14 := by native_decide

/-! ## Section 11: EML Approximation Theory -/

/-- Taylor approximation: eml(x, 1) = exp(x) ≥ 1 + x. -/
theorem eml_taylor_first_order (x : ℝ) :
    1 + x ≤ emlOP x 1 := by
  simp [emlOP, Real.log_one]
  linarith [Real.add_one_le_exp x]

/-- eml(0, y) ≥ 2 - y for y ≥ 1. -/
theorem eml_zero_upper_bound (y : ℝ) (hy : 1 ≤ y) :
    2 - y ≤ emlOP 0 y := by
  simp only [emlOP, Real.exp_zero]
  linarith [Real.log_le_sub_one_of_pos (by linarith : (0:ℝ) < y)]

/-! ## Section 12: EML Preserves Positivity -/

/-- 1 - ln(x) > 0 for x ∈ (0, e). -/
theorem oneMinusLog_preserves_pos' (x : ℝ) (hx : 0 < x) (hxe : x < Real.exp 1) :
    0 < 1 - Real.log x := by
  have : Real.log x < 1 := by
    calc Real.log x < Real.log (Real.exp 1) := Real.log_lt_log hx hxe
    _ = 1 := Real.log_exp 1
  linarith

end