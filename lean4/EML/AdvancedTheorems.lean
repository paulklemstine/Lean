/-
# Advanced EML Theorems

New formalized results extending the EML operator theory:
- Zero generation at level 3 (Theorem 4.3)
- EML joint continuity (Theorem 5.1)
- e-Tower properties (Theorem 6.1)
- Non-associativity
- Fixed point existence and uniqueness (Theorem 4.1)
- EML closure properties
- Pure tree combinatorics
-/

import Mathlib

noncomputable section

open Real Filter Topology Set

/-! ## Core Definitions -/

/-- The real EML operator: eml(x, y) = exp(x) - ln(y). -/
def emlA (x y : ℝ) : ℝ := Real.exp x - Real.log y

/-! ## Section 1: Zero Generation (Theorem 4.3)

The first appearance of 0 in the EML number tower occurs at level 3:
  eml(1, eml(eml(1,1), 1)) = 0
-/

/-- eml(1, 1) = e (Euler's number). -/
theorem emlA_one_one : emlA 1 1 = Real.exp 1 := by
  simp [emlA, Real.log_one]

/-- eml(e, 1) = e^e. -/
theorem emlA_e_one : emlA (Real.exp 1) 1 = Real.exp (Real.exp 1) := by
  simp [emlA, Real.log_one]

/-- Theorem 4.3: eml(1, e^e) = 0. The first zero in the EML tower. -/
theorem emlA_zero_generation : emlA 1 (Real.exp (Real.exp 1)) = 0 := by
  simp [emlA, Real.log_exp]

/-- The full level-3 zero: eml(1, eml(eml(1,1), 1)) = 0. -/
theorem emlA_tower_zero :
    emlA 1 (emlA (emlA 1 1) 1) = 0 := by
  simp [emlA, Real.log_one, Real.log_exp]

/-! ## Section 2: EML Non-Associativity -/

/-- EML is not associative: eml(eml(1,1), 1) ≠ eml(1, eml(1,1)). -/
theorem emlA_not_assoc :
    emlA (emlA 1 1) 1 ≠ emlA 1 (emlA 1 1) := by
  simp [emlA, Real.log_one, Real.log_exp]
  intro h
  have h1 : (1 : ℝ) < Real.exp 1 := Real.one_lt_exp_iff.mpr one_pos
  have h2 : Real.exp 1 < Real.exp (Real.exp 1) := Real.exp_strictMono h1
  linarith

/-! ## Section 3: Fixed Point of the Logarithmic Iteration (Theorem 4.1) -/

/-- The logarithmic iteration map: g(z) = e - ln(z). -/
def logIteration (z : ℝ) : ℝ := Real.exp 1 - Real.log z

/-- The function h(z) = ln(z) + z - e, whose unique positive root is the fixed point. -/
def fixedPointFn (z : ℝ) : ℝ := Real.log z + z - Real.exp 1

/-- h is strictly monotone on (0, ∞). -/
theorem fixedPointFn_strictMono : StrictMonoOn fixedPointFn (Ioi 0) := by
  intro a ha b hb hab
  simp only [fixedPointFn]
  have hlog : Real.log a < Real.log b := Real.log_lt_log (mem_Ioi.mp ha) hab
  linarith

/-- h(1) < 0. -/
theorem fixedPointFn_at_one_neg : fixedPointFn 1 < 0 := by
  simp [fixedPointFn, Real.log_one]

/-- h(e) > 0, since h(e) = ln(e) + e - e = 1 > 0. -/
theorem fixedPointFn_at_e_pos : fixedPointFn (Real.exp 1) > 0 := by
  simp [fixedPointFn, Real.log_exp]

/-
Existence of a fixed point: there exists z* ∈ (1, e) with g(z*) = z*.
-/
theorem logIteration_fixedPoint_exists :
    ∃ z : ℝ, 1 < z ∧ z < Real.exp 1 ∧ logIteration z = z := by
  -- By the Intermediate Value Theorem, since $h(1) < 0$ and $h(e) > 0$, there exists $z \in (1, e)$ such that $h(z) = 0$.
  have h_ivt : ∃ z ∈ Set.Ioo 1 (Real.exp 1), Real.log z + z - Real.exp 1 = 0 := by
    apply_rules [ intermediate_value_Ioo ] <;> norm_num;
    exact ContinuousOn.sub ( ContinuousOn.add ( Real.continuousOn_log.mono <| by norm_num ) continuousOn_id ) continuousOn_const;
  exact h_ivt.imp fun x hx => ⟨ hx.1.1, hx.1.2, by unfold logIteration; linarith ⟩

/-- Uniqueness: the fixed point is unique on (0, ∞). -/
theorem logIteration_fixedPoint_unique :
    ∀ z₁ z₂ : ℝ, 0 < z₁ → 0 < z₂ →
    logIteration z₁ = z₁ → logIteration z₂ = z₂ → z₁ = z₂ := by
  intro z₁ z₂ hz₁ hz₂ hfp₁ hfp₂
  have h₁ : fixedPointFn z₁ = 0 := by
    simp [fixedPointFn, logIteration] at hfp₁ ⊢; linarith
  have h₂ : fixedPointFn z₂ = 0 := by
    simp [fixedPointFn, logIteration] at hfp₂ ⊢; linarith
  by_contra hne
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · have := fixedPointFn_strictMono (mem_Ioi.mpr hz₁) (mem_Ioi.mpr hz₂) hlt
    linarith
  · have := fixedPointFn_strictMono (mem_Ioi.mpr hz₂) (mem_Ioi.mpr hz₁) hgt
    linarith

/-! ## Section 4: EML Joint Continuity (Theorem 5.1) -/

/-- EML is continuous in its first argument. -/
theorem emlA_continuous_fst (y : ℝ) : Continuous (fun x => emlA x y) :=
  Real.continuous_exp.sub continuous_const

/-- EML is continuous at any point with y ≠ 0. -/
theorem emlA_continuousAt_snd (x y : ℝ) (hy : y ≠ 0) :
    ContinuousAt (fun y' => emlA x y') y :=
  continuous_const.continuousAt.sub (Real.continuousAt_log hy)

/-- The EML operator is jointly continuous on ℝ × (ℝ \ {0}). -/
theorem emlA_continuousOn : ContinuousOn (fun p : ℝ × ℝ => emlA p.1 p.2) (Set.univ ×ˢ {0}ᶜ) := by
  apply ContinuousOn.sub
  · exact (Real.continuous_exp.comp continuous_fst).continuousOn
  · exact Real.continuousOn_log.comp continuousOn_snd (fun p hp => hp.2)

/-! ## Section 5: EML Derivative Structure -/

/-- ∂eml/∂x = exp(x). -/
theorem emlA_deriv_fst (x y : ℝ) :
    HasDerivAt (fun x' => emlA x' y) (Real.exp x) x :=
  (Real.hasDerivAt_exp x).sub_const _

/-- ∂eml/∂y = -1/y for y ≠ 0. -/
theorem emlA_deriv_snd (x y : ℝ) (hy : y ≠ 0) :
    HasDerivAt (fun y' => emlA x y') (-1 / y) y := by
  unfold emlA
  have h1 : HasDerivAt (fun _ : ℝ => Real.exp x) 0 y := hasDerivAt_const _ _
  have h2 : HasDerivAt Real.log y⁻¹ y := Real.hasDerivAt_log hy
  convert h1.sub h2 using 1
  ring

/-! ## Section 6: The e-Tower (Theorem 6.1) -/

/-- The e-tower: iterated exponentiation starting from 1. -/
def eTower : ℕ → ℝ
  | 0 => 1
  | n + 1 => Real.exp (eTower n)

/-- The e-tower is generated by eml(·, 1). -/
theorem eTower_eml (n : ℕ) : eTower (n + 1) = emlA (eTower n) 1 := by
  simp [eTower, emlA, Real.log_one]

/-- Every element of the e-tower is positive. -/
theorem eTower_pos (n : ℕ) : 0 < eTower n := by
  induction n with
  | zero => simp [eTower]
  | succ n _ => simp [eTower]; positivity

/-- Every element of the e-tower is ≥ 1. -/
theorem eTower_ge_one (n : ℕ) : 1 ≤ eTower n := by
  cases n with
  | zero => simp [eTower]
  | succ n =>
    simp only [eTower]
    exact Real.one_le_exp (le_of_lt (eTower_pos n))

/-- The e-tower is strictly increasing. -/
theorem eTower_strictMono : StrictMono eTower := by
  apply strictMono_nat_of_lt_succ
  intro n
  simp only [eTower]
  calc eTower n
      < eTower n + 1 := by linarith
    _ ≤ Real.exp (eTower n) := Real.add_one_le_exp (eTower n)

/-! ## Section 7: EML Closure Properties -/

/-- The set of real numbers generated from 1 by EML. -/
inductive EMLGenerated : ℝ → Prop where
  | one : EMLGenerated 1
  | apply : EMLGenerated x → EMLGenerated y → EMLGenerated (emlA x y)

/-- e is EML-generated. -/
theorem e_generated : EMLGenerated (Real.exp 1) := by
  have h := EMLGenerated.apply EMLGenerated.one EMLGenerated.one
  simp [emlA, Real.log_one] at h
  exact h

/-- e^e is EML-generated. -/
theorem exp_e_generated : EMLGenerated (Real.exp (Real.exp 1)) := by
  have h := EMLGenerated.apply e_generated EMLGenerated.one
  simp [emlA, Real.log_one] at h
  exact h

/-- 0 is EML-generated. -/
theorem zero_generated : EMLGenerated 0 := by
  have h := EMLGenerated.apply EMLGenerated.one exp_e_generated
  simp [emlA, Real.log_exp] at h
  exact h

/-- e - 1 is EML-generated. -/
theorem e_minus_one_generated : EMLGenerated (Real.exp 1 - 1) := by
  have h := EMLGenerated.apply EMLGenerated.one e_generated
  simp [emlA, Real.log_exp] at h
  exact h

/-- Every level of the e-tower is EML-generated. -/
theorem eTower_generated (n : ℕ) : EMLGenerated (eTower n) := by
  induction n with
  | zero => exact EMLGenerated.one
  | succ n ih =>
    have h := EMLGenerated.apply ih EMLGenerated.one
    simp [emlA, Real.log_one] at h
    simp [eTower]
    exact h

/-! ## Section 8: EML Identities -/

/-- eml(0, 1) = 1. -/
theorem emlA_zero_one : emlA 0 1 = 1 := by
  simp [emlA, Real.log_one, Real.exp_zero]

/-- eml(x, exp(x)) = exp(x) - x. -/
theorem emlA_x_expx (x : ℝ) : emlA x (Real.exp x) = Real.exp x - x := by
  simp [emlA, Real.log_exp]

/-- eml(ln(y), 1) = y for y > 0. -/
theorem emlA_log_one (y : ℝ) (hy : 0 < y) : emlA (Real.log y) 1 = y := by
  simp [emlA, Real.log_one, Real.exp_log hy]

/-- Double EML: eml(eml(x,1), 1) = exp(exp(x)). -/
theorem emlA_double_exp (x : ℝ) : emlA (emlA x 1) 1 = Real.exp (Real.exp x) := by
  simp [emlA, Real.log_one]

/-- eml(0, y) = 1 - ln(y). -/
theorem emlA_zero_y (y : ℝ) : emlA 0 y = 1 - Real.log y := by
  simp [emlA, Real.exp_zero]

/-! ## Section 9: Pure EML Tree Combinatorics -/

/-- Pure EML trees (only constant 1 at leaves). -/
inductive PureEMLTree where
  | leaf : PureEMLTree
  | node : PureEMLTree → PureEMLTree → PureEMLTree
  deriving Repr, DecidableEq

/-- Leaf count of a pure tree. -/
def PureEMLTree.leafCount : PureEMLTree → ℕ
  | .leaf => 1
  | .node l r => l.leafCount + r.leafCount

/-- Node count of a pure tree. -/
def PureEMLTree.nodeCount : PureEMLTree → ℕ
  | .leaf => 0
  | .node l r => 1 + l.nodeCount + r.nodeCount

/-- Depth of a pure tree. -/
def PureEMLTree.depth : PureEMLTree → ℕ
  | .leaf => 0
  | .node l r => 1 + max l.depth r.depth

/-- Leaves = nodes + 1 for pure trees. -/
theorem PureEMLTree.leafCount_eq_nodeCount_succ (t : PureEMLTree) :
    t.leafCount = t.nodeCount + 1 := by
  induction t with
  | leaf => rfl
  | node l r ihl ihr =>
    simp [PureEMLTree.leafCount, PureEMLTree.nodeCount, ihl, ihr]
    omega

/-- Leaves ≤ 2^depth for pure trees. -/
theorem PureEMLTree.leafCount_le_pow_depth (t : PureEMLTree) :
    t.leafCount ≤ 2 ^ t.depth := by
  induction t with
  | leaf => simp [leafCount, depth]
  | node l r ihl ihr =>
    simp only [leafCount, depth]
    have h1 : 2 ^ l.depth ≤ 2 ^ max l.depth r.depth :=
      Nat.pow_le_pow_right (by omega) (le_max_left _ _)
    have h2 : 2 ^ r.depth ≤ 2 ^ max l.depth r.depth :=
      Nat.pow_le_pow_right (by omega) (le_max_right _ _)
    calc l.leafCount + r.leafCount
        ≤ 2 ^ l.depth + 2 ^ r.depth := Nat.add_le_add ihl ihr
      _ ≤ 2 ^ max l.depth r.depth + 2 ^ max l.depth r.depth :=
          Nat.add_le_add h1 h2
      _ = 2 * 2 ^ max l.depth r.depth := by ring
      _ = 2 ^ (max l.depth r.depth + 1) := by ring
      _ = 2 ^ (1 + max l.depth r.depth) := by ring_nf

/-! ## Section 10: Pure Tree Evaluation -/

/-- Evaluate a pure EML tree (all leaves = 1). -/
noncomputable def PureEMLTree.evalReal : PureEMLTree → ℝ
  | .leaf => 1
  | .node l r => emlA l.evalReal r.evalReal

/-- The simplest non-trivial tree eml(1,1) evaluates to e. -/
theorem PureEMLTree.eval_e :
    (PureEMLTree.node .leaf .leaf).evalReal = Real.exp 1 := by
  simp [PureEMLTree.evalReal, emlA, Real.log_one]

/-- The tree eml(eml(1,1), 1) evaluates to e^e. -/
theorem PureEMLTree.eval_ee :
    (PureEMLTree.node (.node .leaf .leaf) .leaf).evalReal = Real.exp (Real.exp 1) := by
  simp [PureEMLTree.evalReal, emlA, Real.log_one]

/-- The tree eml(1, eml(eml(1,1), 1)) evaluates to 0 (Theorem 4.3). -/
theorem PureEMLTree.eval_zero :
    (PureEMLTree.node .leaf (.node (.node .leaf .leaf) .leaf)).evalReal = 0 := by
  simp [PureEMLTree.evalReal, emlA, Real.log_one, Real.log_exp]

/-- The tree eml(1, eml(1,1)) evaluates to e - 1. -/
theorem PureEMLTree.eval_e_minus_one :
    (PureEMLTree.node .leaf (.node .leaf .leaf)).evalReal = Real.exp 1 - 1 := by
  simp [PureEMLTree.evalReal, emlA, Real.log_one, Real.log_exp]

/-! ## Section 11: EML Differentiability -/

/-- EML is differentiable in x everywhere. -/
theorem emlA_differentiable_x (y : ℝ) : Differentiable ℝ (fun x => emlA x y) :=
  Real.differentiable_exp.sub (differentiable_const _)

/-- The EML operator eml(x,1) = exp(x) is C^∞. -/
theorem emlA_contDiff_fst (y : ℝ) : ContDiff ℝ ⊤ (fun x => emlA x y) :=
  Real.contDiff_exp.sub contDiff_const

end