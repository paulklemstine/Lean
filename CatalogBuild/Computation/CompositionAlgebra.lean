/-! # CatalogBuild.Computation.CompositionAlgebra

Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 21
-/

import Mathlib

noncomputable section

def EML_comp (a b : ℝ) : ℝ := Real.exp a - Real.log b


def T_op (c : ℝ) (x : ℝ) : ℝ := EML_comp x c


theorem T_op_one (x : ℝ) : T_op 1 x = Real.exp x := by
  simp [T_op, EML_comp, Real.log_one]


theorem T_op_exp (k : ℝ) (x : ℝ) : T_op (Real.exp k) x = Real.exp x - k := by
  simp [T_op, EML_comp, Real.log_exp]


theorem T_op_strictMono (c : ℝ) : StrictMono (T_op c) :=
  fun _ _ h => sub_lt_sub_right (Real.exp_lt_exp.mpr h) _


theorem T_op_injective (c : ℝ) : Function.Injective (T_op c) :=
  (T_op_strictMono c).injective


theorem T_op_comp (c₁ c₂ : ℝ) (x : ℝ) :
    T_op c₁ (T_op c₂ x) = Real.exp (Real.exp x - Real.log c₂) - Real.log c₁ := by
  simp [T_op, EML_comp]


theorem T_op_noncomm : ∃ c₁ c₂ x : ℝ,
    T_op c₁ (T_op c₂ x) ≠ T_op c₂ (T_op c₁ x) := by
  use 1, Real.exp 1, 0
  simp [T_op, EML_comp, Real.log_one, Real.log_exp]
  intro h; linarith [Real.exp_one_gt_d9]


def L_op (a : ℝ) (y : ℝ) : ℝ := EML_comp a y


theorem L_op_strictAnti (a : ℝ) : StrictAntiOn (L_op a) (Set.Ioi 0) :=
  fun _ hy _ _ hyz => sub_lt_sub_left (Real.log_lt_log hy hyz) _


theorem L_op_zero (y : ℝ) : L_op 0 y = 1 - Real.log y := by
  simp [L_op, EML_comp]


/-- The remarkable involution: L_a ∘ exp ∘ L_a = ln, for ALL a. -/
theorem L_op_involution (a y : ℝ) :
    L_op a (Real.exp (L_op a y)) = Real.log y := by
  simp [L_op, EML_comp, Real.log_exp]


theorem L_op_exp_L_op_eq_log (a : ℝ) :
    (fun y => L_op a (Real.exp (L_op a y))) = Real.log := by
  ext y; exact L_op_involution a y


theorem T_one_triple (x : ℝ) :
    T_op 1 (T_op 1 (T_op 1 x)) = Real.exp (Real.exp (Real.exp x)) := by
  simp [T_op, EML_comp, Real.log_one]


def T_one_iter : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => T_op 1 (T_one_iter n x)


theorem T_one_iter_eq_iterExp (n : ℕ) (x : ℝ) :
    T_one_iter n x = Nat.iterate Real.exp n x := by
  induction n with
  | zero => rfl
  | succ n ih =>
    simp only [T_one_iter, T_op, EML_comp, Real.log_one, sub_zero, ih]
    rw [Function.iterate_succ']
    rfl


theorem dual_conj (a y : ℝ) :
    Real.exp (L_op a (Real.exp y)) = Real.exp (Real.exp a - y) := by
  simp [L_op, EML_comp, Real.log_exp]


theorem T_op_as_shifted_exp (c x : ℝ) :
    T_op c x = Real.exp x + (-Real.log c) := by
  simp [T_op, EML_comp]; ring


theorem T_one_orbit_zero : T_op 1 0 = 1 := by
  simp [T_op, EML_comp, Real.log_one]


theorem T_one_orbit_one : T_op 1 1 = Real.exp 1 := by
  simp [T_op, EML_comp, Real.log_one]


theorem T_one_orbit_increasing (n : ℕ) :
    T_one_iter n 0 < T_one_iter (n + 1) 0 := by
  induction n with
  | zero =>
    simp [T_one_iter, T_op, EML_comp, Real.log_one]
  | succ n ih =>
    simp only [T_one_iter]
    exact T_op_strictMono 1 ih


end
