/-
# EML V11 — Composition Theory and Functional Equations

Iterated EML composition, functional identities,
orbit structure, and algebraic relations.
-/

import Mathlib

noncomputable section

open Real Filter Topology Set

/-! ## Definitions -/

def eml (x y : ℝ) : ℝ := Real.exp x - Real.log y
def emlSelfPair (x : ℝ) : ℝ := Real.exp x - x
def emlDiag (z : ℝ) : ℝ := Real.exp z - Real.log z

def emlDiagIter : ℕ → ℝ → ℝ
  | 0, z => z
  | n + 1, z => emlDiag (emlDiagIter n z)

/-- The e-tower: e, eᵉ, eᵉᵉ, ... -/
def eTower : ℕ → ℝ
  | 0 => 1
  | n + 1 => Real.exp (eTower n)

/-! ## Section 1: Composition Identities -/

/-- eml(x, exp(y)) = exp(x) - y (Legendre bridge). -/
theorem eml_legendre (x y : ℝ) : eml x (Real.exp y) = Real.exp x - y := by
  simp [eml, Real.log_exp]

/-- eml(ln(x), y) = x - ln(y) for x > 0. -/
theorem eml_log_first (x y : ℝ) (hx : 0 < x) :
    eml (Real.log x) y = x - Real.log y := by
  simp [eml, Real.exp_log hx]

/-- eml(0, exp(y)) = 1 - y. -/
theorem eml_zero_exp (y : ℝ) : eml 0 (Real.exp y) = 1 - y := by
  simp [eml, Real.log_exp]

/-- eml(x, 1) = exp(x). -/
theorem eml_one (x : ℝ) : eml x 1 = Real.exp x := by
  simp [eml, Real.log_one]

/-- eml(0, y) = 1 - ln(y). -/
theorem eml_zero (y : ℝ) : eml 0 y = 1 - Real.log y := by
  simp [eml]

/-- Double composition: eml(eml(x,1), 1) = exp(exp(x)). -/
theorem eml_double_exp (x : ℝ) : eml (eml x 1) 1 = Real.exp (Real.exp x) := by
  simp [eml, Real.log_one]

/-- Triple composition generates the e-tower. -/
theorem eml_triple_exp (x : ℝ) :
    eml (eml (eml x 1) 1) 1 = Real.exp (Real.exp (Real.exp x)) := by
  simp [eml, Real.log_one]

/-! ## Section 2: E-Tower Properties -/

/-- eTower 0 = 1. -/
theorem eTower_zero : eTower 0 = 1 := rfl

/-- eTower 1 = e. -/
theorem eTower_one : eTower 1 = Real.exp 1 := by simp [eTower]

/-- eTower 2 = eᵉ. -/
theorem eTower_two : eTower 2 = Real.exp (Real.exp 1) := by simp [eTower]

/-- eTower n > 0 for all n. -/
theorem eTower_pos (n : ℕ) : eTower n > 0 := by
  induction n with
  | zero => simp [eTower]
  | succ n _ => simp [eTower]; exact Real.exp_pos _

/-- eTower n ≥ 1 for all n. -/
theorem eTower_ge_one (n : ℕ) : eTower n ≥ 1 := by
  induction n with
  | zero => simp [eTower]
  | succ n ih => simp [eTower]; linarith [Real.add_one_le_exp (eTower n)]

/-
eTower is strictly increasing.
-/
theorem eTower_strictMono : StrictMono eTower := by
  refine' strictMono_nat_of_lt_succ _;
  intro n;
  exact Real.add_one_le_exp _ |> lt_of_lt_of_le ( by linarith )

/-- eml(eTower n, 1) = eTower (n+1). -/
theorem eml_eTower (n : ℕ) : eml (eTower n) 1 = eTower (n + 1) := by
  simp [eml, Real.log_one, eTower]

/-! ## Section 3: Orbit Theory -/

/-- Iterated diagonal: d⁰(z) = z. -/
theorem emlDiagIter_zero (z : ℝ) : emlDiagIter 0 z = z := rfl

/-- Iterated diagonal: dⁿ⁺¹(z) = d(dⁿ(z)). -/
theorem emlDiagIter_succ (n : ℕ) (z : ℝ) :
    emlDiagIter (n + 1) z = emlDiag (emlDiagIter n z) := rfl

/-
Linear orbit bound: dⁿ(z) ≥ z + n.
-/
theorem emlDiagIter_linear_bound (n : ℕ) (z : ℝ) :
    emlDiagIter n z ≥ z + n := by
  -- By induction on $n$, we can show that $d^n(z) \ge z + n$.
  have h_ind (n : ℕ) (z : ℝ) : emlDiagIter (n + 1) z ≥ emlDiagIter n z + 1 := by
    -- By definition of $d$, we have $d(w) = e^w - \ln w$.
    have h_d (w : ℝ) : emlDiag w ≥ w + 1 := by
      by_cases hw : 0 < w;
      · unfold emlDiag;
        have := Real.add_one_le_exp ( w - 1 );
        rw [ show w = ( w - 1 ) + 1 by ring, Real.exp_add ];
        nlinarith [ Real.add_one_le_exp 1, Real.log_le_sub_one_of_pos ( by linarith : 0 < w - 1 + 1 ) ];
      · unfold emlDiag;
        by_cases hw : w < 0;
        · have := Real.log_le_sub_one_of_pos ( neg_pos.mpr hw );
          norm_num at * ; linarith [ Real.exp_pos w, Real.exp_neg w, mul_inv_cancel₀ ( ne_of_gt ( Real.exp_pos w ) ) ];
        · norm_num [ show w = 0 by linarith ];
    exact h_d _;
  exact Nat.recOn n ( by norm_num [ emlDiagIter_zero ] ) fun n ihn => by have := h_ind n z; norm_num [ emlDiagIter ] at *; linarith;

/-! ## Section 4: Self-Pairing Composition -/

/-- σ(σ(x)) = exp(exp(x) - x) - (exp(x) - x). -/
theorem emlSelfPair_compose (x : ℝ) :
    emlSelfPair (emlSelfPair x) = Real.exp (Real.exp x - x) - (Real.exp x - x) := by
  simp [emlSelfPair]

/-- σ(0) = 1. -/
theorem emlSelfPair_zero : emlSelfPair 0 = 1 := by
  unfold emlSelfPair; simp

/-- σ(1) = e − 1. -/
theorem emlSelfPair_one : emlSelfPair 1 = Real.exp 1 - 1 := by
  simp [emlSelfPair]

/-! ## Section 5: EML Functional Equation Failures -/

/-
eml does NOT satisfy the exponential law: eml(x+y, z) ≠ eml(x,z) · eml(y,z).
-/
theorem eml_not_exponential_law :
    ∃ x y z : ℝ, eml (x + y) z ≠ eml x z * eml y z := by
  unfold eml; use 0, 0, Real.exp 2; norm_num;

/-- The LOG part satisfies: eml(x, y·z) = eml(x, y) - ln(z) for y,z > 0. -/
theorem eml_log_additivity' (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    eml x (y * z) = eml x y - Real.log z := by
  unfold eml
  rw [Real.log_mul (ne_of_gt hy) (ne_of_gt hz)]
  ring

/-! ## Section 6: EML Commutator -/

/-- The EML commutator: eml(x,y) − eml(y,x) = exp(x) − exp(y) + log(x) − log(y). -/
theorem eml_commutator (x y : ℝ) :
    eml x y - eml y x = Real.exp x - Real.exp y + Real.log x - Real.log y := by
  unfold eml; ring

/-- The commutator vanishes iff exp(x) − exp(y) = log(y) − log(x). -/
theorem eml_commutator_zero_iff (x y : ℝ) :
    eml x y = eml y x ↔ Real.exp x - Real.exp y = Real.log y - Real.log x := by
  unfold eml; constructor <;> intro h <;> linarith

/-- eml(0,1) = 1. -/
theorem eml_comm_01 : eml 0 1 = 1 := by simp [eml, Real.log_one]

/-- eml(1,0) = e (since log 0 = 0 in Lean/Mathlib). -/
theorem eml_comm_10 : eml 1 0 = Real.exp 1 := by
  simp [eml, Real.log_zero]

/-- eml(0,1) ≠ eml(1,0). -/
theorem eml_not_comm_01 : eml 0 1 ≠ eml 1 0 := by
  rw [eml_comm_01, eml_comm_10]
  intro h; linarith [Real.exp_one_gt_d9]

/-! ## Section 7: EML and Exp/Log Interplay -/

/-- exp(eml(x,y)) = exp(exp(x)) / y for y > 0. -/
theorem exp_eml (x y : ℝ) (hy : 0 < y) :
    Real.exp (eml x y) = Real.exp (Real.exp x) / y := by
  unfold eml; rw [Real.exp_sub, Real.exp_log hy]

/-! ## Section 8: EML Scaling Laws -/

/-- Scaling: eml(x + c, y) = eml(x, y) + (exp(x+c) − exp(x)). -/
theorem eml_shift_x (x c y : ℝ) :
    eml (x + c) y = eml x y + (Real.exp (x + c) - Real.exp x) := by
  unfold eml; ring

/-- Scaling in y: eml(x, c·y) = eml(x, y) − ln(c) for c, y > 0. -/
theorem eml_scale_y (x c y : ℝ) (hc : 0 < c) (hy : 0 < y) :
    eml x (c * y) = eml x y - Real.log c := by
  unfold eml
  rw [Real.log_mul (ne_of_gt hc) (ne_of_gt hy)]; ring

end