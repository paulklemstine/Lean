/-! # CatalogBuild.EML.NewTheorems

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 16
-/

import Mathlib

noncomputable section

/-- The EML operator. -/
def emlN (x y : ℂ) : ℂ := Complex.exp x - Complex.log y

/-- The real EML operator. -/

def emlNR (x y : ℝ) : ℝ := Real.exp x - Real.log y

/-! ## EML Derivative Structure -/

/-
The real EML: ∂emlNR/∂x = exp(x).
-/

theorem emlNR_partial_x (x y : ℝ) (hy : 0 < y) :
    HasDerivAt (fun x' => emlNR x' y) (Real.exp x) x := by
  convert HasDerivAt.sub ( Real.hasDerivAt_exp x ) ( hasDerivAt_const _ _ ) using 1;
  ring

/-
The real EML: ∂emlNR/∂y = -1/y for y > 0.
-/

theorem emlNR_partial_y (x : ℝ) (y : ℝ) (hy : 0 < y) :
    HasDerivAt (fun y' => emlNR x y') (-1/y) y := by
  simpa [ div_eq_inv_mul ] using HasDerivAt.sub ( hasDerivAt_const _ _ ) ( Real.hasDerivAt_log hy.ne' )

/-! ## EML Tree Combinatorics -/

/-- EML expression trees. -/

def EMLTree.leaves : EMLTree → ℕ
  | .leaf => 1
  | .node l r => l.leaves + r.leaves

/-- Internal node count. -/

def EMLTree.nodes : EMLTree → ℕ
  | .leaf => 0
  | .node l r => 1 + l.nodes + r.nodes

/-- Depth of an EML tree. -/

def EMLTree.depth : EMLTree → ℕ
  | .leaf => 0
  | .node l r => 1 + max l.depth r.depth

/-
Fundamental: leaves = nodes + 1 for all EML trees.
-/

theorem EMLTree.leaves_eq_nodes_succ (t : EMLTree) :
    t.leaves = t.nodes + 1 := by
  -- We will prove this by induction on EML trees.
  have h_ind : ∀ t : EMLTree, t.leaves = t.nodes + 1 := by
    intro t; induction t; aesop;
    erw [ EMLTree.leaves, EMLTree.nodes ] ; linarith!;
  exact h_ind t

/-
Depth lower bound: leaves ≤ 2^depth.
-/

theorem EMLTree.leaves_le_pow_depth (t : EMLTree) :
    t.leaves ≤ 2^t.depth := by
  induction' t with l r ihl ihr;
  · decide +revert;
  · -- The depth of the node is 1 plus the maximum of the depths of its children.
    have h_depth_node : l.node r = .node l r := by
      rfl
    simp_all +arith +decide [ EMLTree.leaves, EMLTree.depth ];
    rw [ pow_succ' ] ; linarith [ pow_le_pow_right₀ ( by decide : 1 ≤ 2 ) ( le_max_left l.depth r.depth ), pow_le_pow_right₀ ( by decide : 1 ≤ 2 ) ( le_max_right l.depth r.depth ) ] ;

/-! ## EML and the anti-EML -/

/-
antiEml(x,y) = log(x) - exp(y) = -(exp(y) - log(x)) = -eml(y,x).
-/

theorem antiEml_eq_neg_swap (x y : ℂ) :
    (Complex.log x - Complex.exp y) = -(emlN y x) := by
  unfold emlN; ring;

/-! ## EML Continuity -/

/-- exp is continuous. -/

theorem emlN_exp_continuous : Continuous (fun p : ℂ × ℂ => Complex.exp p.1) :=
  Complex.continuous_exp.comp continuous_fst

/-! ## Master Formula Parameter Count -/

/-- Master formula parameter count. -/

def emlMasterParams (n : ℕ) : ℕ := 5 * 2^n - 6

/-- Level 1: 4 parameters. -/

theorem emlMasterParams_one : emlMasterParams 1 = 4 := by native_decide

/-- Level 2: 14 parameters. -/

theorem emlMasterParams_two : emlMasterParams 2 = 14 := by native_decide

/-- Level 3: 34 parameters. -/

theorem emlMasterParams_three : emlMasterParams 3 = 34 := by native_decide

/-- Level 4: 74 parameters. -/

theorem emlMasterParams_four : emlMasterParams 4 = 74 := by native_decide

end

end
