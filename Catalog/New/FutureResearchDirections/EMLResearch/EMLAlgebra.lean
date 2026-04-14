import Mathlib

/-!
# EML Operator: Algebraic Structure and New Theorems

This file formalizes new algebraic and structural results about the EML operator
eml(x,y) = exp(x) - ln(y), the continuous analogue of the Sheffer stroke (NAND).

Based on: "All elementary functions from a single operator" by A. Odrzywolek (2025)
-/

noncomputable section

open Complex Real

namespace EMLAlgebra

/-! ## 1. Core Definitions -/

/-- The EML operator on ℂ. -/
def eml (x y : ℂ) : ℂ := Complex.exp x - Complex.log y

/-- The real EML operator. -/
def emlR (x y : ℝ) : ℝ := Real.exp x - Real.log y

/-- The EDL (Exp-Div-Log) operator on ℂ. -/
def edl (x y : ℂ) : ℂ := Complex.exp x / Complex.log y

/-- The anti-EML operator. -/
def antiEml (x y : ℂ) : ℂ := Complex.log x - Complex.exp y

/-! ## 2. Fundamental Recovery Identities -/

/-- exp(x) = eml(x, 1). -/
theorem eml_recovers_exp (x : ℂ) : eml x 1 = Complex.exp x := by
  simp [eml, Complex.log_one]

/-- e = eml(1, 1). -/
theorem eml_recovers_e : eml 1 1 = Complex.exp 1 := by
  simp [eml, Complex.log_one]

/-- Real exp(x) = emlR(x, 1). -/
theorem emlR_recovers_exp (x : ℝ) : emlR x 1 = Real.exp x := by
  simp [emlR, Real.log_one]

/-- Real e = emlR(1, 1). -/
theorem emlR_recovers_e : emlR 1 1 = Real.exp 1 := by
  simp [emlR, Real.log_one]

/-! ## 3. Subtraction Identity -/

/-- a - b = eml(ln(a), exp(b)) when a ≠ 0 and Im(b) ∈ (-π, π]. -/
theorem eml_subtraction (a b : ℂ) (ha : a ≠ 0)
    (hb1 : -Real.pi < b.im) (hb2 : b.im ≤ Real.pi) :
    eml (Complex.log a) (Complex.exp b) = a - b := by
  simp [eml, Complex.exp_log ha, Complex.log_exp hb1 hb2]

/-- Real subtraction: a - b = emlR(ln(a), exp(b)) for a > 0. -/
theorem emlR_subtraction (a b : ℝ) (ha : 0 < a) :
    emlR (Real.log a) (Real.exp b) = a - b := by
  simp [emlR, Real.exp_log ha, Real.log_exp]

/-! ## 4. Anti-EML Duality -/

/-- antiEml(x,y) = -eml(y,x). -/
theorem antiEml_eq_neg_eml (x y : ℂ) : antiEml x y = -eml y x := by
  unfold antiEml eml; ring

/-- eml(x,y) = -antiEml(y,x). -/
theorem eml_eq_neg_antiEml (x y : ℂ) : eml x y = -antiEml y x := by
  unfold antiEml eml; ring

/-! ## 5. Non-Commutativity and Non-Associativity -/

/-
EML is non-commutative.
-/
theorem eml_not_comm : ∃ x y : ℂ, eml x y ≠ eml y x := by
  use 0, 1; norm_num [eml];
  exact Ne.symm ( by norm_num [ Complex.ext_iff, Complex.exp_re, Complex.exp_im ] )

/-
emlR is non-commutative.
-/
theorem emlR_not_comm : ∃ x y : ℝ, emlR x y ≠ emlR y x := by
  -- Use x=0, y=1. emlR(0,1) = exp(0) - log(1) = 1. emlR(1,0) = exp(1) - log(0) = e - 0 = e. 1 ≠ e since e > 1.
  use 0, 1
  simp [emlR];
  exact Ne.symm <| by norm_num

/-
EML is non-associative.
-/
theorem eml_not_assoc : ∃ x y z : ℂ, eml (eml x y) z ≠ eml x (eml y z) := by
  refine' ⟨ 1, 1, 1, _ ⟩ ; norm_num [ eml ];
  rw [ Complex.log_exp ] <;> norm_num [ Complex.ext_iff, Complex.exp_re, Complex.exp_im ];
  · linarith [ Real.add_one_le_exp 1, Real.add_one_le_exp ( Real.exp 1 ) ];
  · positivity;
  · positivity

/-! ## 6. EML Expression Trees -/

/-- An EML expression tree. -/
inductive EMLExpr where
  | one : EMLExpr
  | var : ℕ → EMLExpr
  | app : EMLExpr → EMLExpr → EMLExpr
  deriving Repr, BEq, Inhabited

/-- Evaluate an EML expression tree. -/
def EMLExpr.eval (e : EMLExpr) (vars : ℕ → ℂ) : ℂ :=
  match e with
  | .one => 1
  | .var n => vars n
  | .app l r => eml (l.eval vars) (r.eval vars)

/-- Depth of an EML expression tree. -/
def EMLExpr.depth : EMLExpr → ℕ
  | .one => 0
  | .var _ => 0
  | .app l r => 1 + max l.depth r.depth

/-- Leaf count. -/
def EMLExpr.leafCount : EMLExpr → ℕ
  | .one => 1
  | .var _ => 1
  | .app l r => l.leafCount + r.leafCount

/-- Internal node count. -/
def EMLExpr.nodeCount : EMLExpr → ℕ
  | .one => 0
  | .var _ => 0
  | .app l r => 1 + l.nodeCount + r.nodeCount

/-! ### Tree Combinatorics -/

/-- Leaves = internal nodes + 1. -/
theorem EMLExpr.leafCount_eq_nodeCount_succ (e : EMLExpr) :
    e.leafCount = e.nodeCount + 1 := by
  induction e with
  | one => rfl
  | var _ => rfl
  | app l r ihl ihr => simp [leafCount, nodeCount, ihl, ihr]; omega

/-- Leaf count is always positive. -/
theorem EMLExpr.leafCount_pos (e : EMLExpr) : 0 < e.leafCount := by
  have := e.leafCount_eq_nodeCount_succ; omega

/-
Leaves ≤ 2^depth.
-/
theorem EMLExpr.leafCount_le_pow_depth (e : EMLExpr) :
    e.leafCount ≤ 2 ^ e.depth := by
  induction' e with l r ihl ihr;
  · decide +revert;
  · exact Nat.le_of_ble_eq_true rfl;
  · -- By definition of leaf count and depth, we have:
    have h_leaf_count : (r.app ihl).leafCount = r.leafCount + ihl.leafCount := by
      rfl
    have h_depth : (r.app ihl).depth = 1 + max r.depth ihl.depth := by
      rfl;
    cases max_cases r.depth ihl.depth <;> simp_all +decide [ pow_add ];
    · linarith [ pow_le_pow_right₀ ( by decide : 1 ≤ 2 ) ‹_› ];
    · linarith [ pow_le_pow_right₀ ( by norm_num : ( 1 : ℕ ) ≤ 2 ) ( by linarith : r.depth ≤ ihl.depth ) ]

/-! ## 7. Master Formula Parameters -/

/-- Parameter count for depth-n EML master formula. -/
def masterParams (n : ℕ) : ℕ := 5 * 2 ^ n - 6

theorem masterParams_1 : masterParams 1 = 4 := by native_decide
theorem masterParams_2 : masterParams 2 = 14 := by native_decide
theorem masterParams_3 : masterParams 3 = 34 := by native_decide
theorem masterParams_4 : masterParams 4 = 74 := by native_decide

/-
Parameter count grows with depth.
-/
theorem masterParams_growth (n : ℕ) (hn : 2 ≤ n) :
    masterParams n < masterParams (n + 1) := by
  unfold masterParams; zify; norm_num; ring_nf;
  grind

/-! ## 8. Classification of EML-Family Operators -/

/-- The EML family: a·exp(x) + b·log(y) + c. -/
def emlFamily (a b c : ℂ) (x y : ℂ) : ℂ :=
  a * Complex.exp x + b * Complex.log y + c

/-- Standard EML is emlFamily(1, -1, 0). -/
theorem eml_in_family (x y : ℂ) :
    emlFamily 1 (-1) 0 x y = eml x y := by
  simp [emlFamily, eml]; ring

/-- Anti-EML is emlFamily(-1, 1, 0) with swapped arguments. -/
theorem antiEml_in_family (x y : ℂ) :
    emlFamily (-1) 1 0 y x = antiEml x y := by
  simp [emlFamily, antiEml]; ring

/-! ## 9. Differentiability -/

/-- EML is differentiable in x. -/
theorem eml_differentiable_fst (y : ℂ) :
    Differentiable ℂ (fun x => eml x y) :=
  Complex.differentiable_exp.sub (differentiable_const _)

/-- ∂eml/∂x = exp(x). -/
theorem eml_deriv_fst (x y : ℂ) :
    HasDerivAt (fun x' => eml x' y) (Complex.exp x) x := by
  show HasDerivAt (fun x' => Complex.exp x' - Complex.log y) (Complex.exp x) x
  have : HasDerivAt (fun x' => Complex.exp x' - Complex.log y) (Complex.exp x - 0) x :=
    (Complex.hasDerivAt_exp x).sub (hasDerivAt_const _ _)
  simpa using this

/-- Real ∂emlR/∂x = exp(x). -/
theorem emlR_deriv_fst (x y : ℝ) :
    HasDerivAt (fun x' => emlR x' y) (Real.exp x) x := by
  show HasDerivAt (fun x' => Real.exp x' - Real.log y) (Real.exp x) x
  have : HasDerivAt (fun x' => Real.exp x' - Real.log y) (Real.exp x - 0) x :=
    (Real.hasDerivAt_exp x).sub (hasDerivAt_const _ _)
  simpa using this

/-- Real ∂emlR/∂y = -1/y for y ≠ 0. -/
theorem emlR_deriv_snd (x y : ℝ) (hy : y ≠ 0) :
    HasDerivAt (fun y' => emlR x y') (-y⁻¹) y := by
  show HasDerivAt (fun y' => Real.exp x - Real.log y') (-y⁻¹) y
  have h : HasDerivAt (fun y' => Real.exp x - Real.log y') (0 - y⁻¹) y :=
    (hasDerivAt_const y (Real.exp x)).sub (Real.hasDerivAt_log hy)
  simpa using h

/-! ## 10. The EML Closure -/

/-- The EML closure: smallest set containing 1 and closed under eml. -/
inductive EMLClosure : ℂ → Prop where
  | const_one : EMLClosure 1
  | apply : EMLClosure x → EMLClosure y → EMLClosure (eml x y)

/-- e ∈ EML closure. -/
theorem e_in_closure : EMLClosure (Complex.exp 1) := by
  have h := EMLClosure.apply EMLClosure.const_one EMLClosure.const_one
  rwa [eml_recovers_exp] at h

/-- exp(e) ∈ EML closure. -/
theorem exp_e_in_closure : EMLClosure (Complex.exp (Complex.exp 1)) := by
  have h := EMLClosure.apply e_in_closure EMLClosure.const_one
  rwa [eml_recovers_exp] at h

/-- EML closure with a variable. -/
inductive EMLClosureVar (x : ℂ) : ℂ → Prop where
  | const_one : EMLClosureVar x 1
  | var : EMLClosureVar x x
  | apply : EMLClosureVar x a → EMLClosureVar x b → EMLClosureVar x (eml a b)

/-- exp(x) ∈ EML closure(x). -/
theorem exp_in_closure_var (x : ℂ) :
    EMLClosureVar x (Complex.exp x) := by
  have h := EMLClosureVar.apply (EMLClosureVar.var (x := x)) (EMLClosureVar.const_one (x := x))
  rwa [eml_recovers_exp] at h

/-! ## 11. Catalan Numbers and Tree Enumeration -/

/-- Catalan numbers (closed form). -/
def catalanNum (n : ℕ) : ℕ := Nat.choose (2 * n) n / (n + 1)

theorem catalanNum_one : catalanNum 1 = 1 := by native_decide
theorem catalanNum_two : catalanNum 2 = 2 := by native_decide
theorem catalanNum_three : catalanNum 3 = 5 := by native_decide
theorem catalanNum_four : catalanNum 4 = 14 := by native_decide

/-- Labeled EML trees: C(n) · k^(n+1) trees with n nodes over k terminals. -/
def labeledEMLTrees (n k : ℕ) : ℕ := catalanNum n * k ^ (n + 1)

theorem labeled_trees_1_2 : labeledEMLTrees 1 2 = 4 := by native_decide
theorem labeled_trees_2_2 : labeledEMLTrees 2 2 = 16 := by native_decide
theorem labeled_trees_3_2 : labeledEMLTrees 3 2 = 80 := by native_decide

/-! ## 12. Real-Only Periodicity Obstruction -/

/-
Compositions of exp cannot produce periodic functions on ℝ.
    This is a structural obstruction to real-only Sheffer operators generating sin/cos.
-/
theorem exp_exp_not_periodic :
    ¬ ∃ (p : ℝ), 0 < p ∧ ∀ x : ℝ, Real.exp (Real.exp x) = Real.exp (Real.exp (x + p)) := by
  norm_num +zetaDelta at *

/-! ## 13. EDL-EML Relationship -/

/-- edl(x,y) = eml(x,y)/log(y) + 1 when log(y) ≠ 0. -/
theorem edl_eml_relation (x y : ℂ) (hy : Complex.log y ≠ 0) :
    edl x y = eml x y / Complex.log y + 1 := by
  simp [edl, eml]; field_simp; ring

/-! ## 14. EML Complexity Measure -/

/-- EML complexity: minimum leaf count over all trees computing f. -/
def emlComplexity (f : ℂ → ℂ) : ℕ :=
  sInf { n : ℕ | ∃ e : EMLExpr, e.leafCount = n ∧
    ∀ x : ℂ, e.eval (fun _ => x) = f x }

/-- exp has EML complexity ≤ 2. -/
theorem emlComplexity_exp_le : emlComplexity Complex.exp ≤ 2 := by
  apply Nat.sInf_le
  exact ⟨EMLExpr.app (.var 0) .one, by simp [EMLExpr.leafCount],
    fun x => by simp [EMLExpr.eval, eml_recovers_exp]⟩

end EMLAlgebra

end