/-
# New Results: Extended Sheffer Algebra Theory

This file contains new theorems discovered through systematic exploration.
-/
import Mathlib
import ShefferAI.Basic
import ShefferAI.OrbitDynamics

open Real Filter Topology

noncomputable section

/-! ## Convexity -/

/-
softplus is convex.
-/
theorem softplus_convex : ConvexOn ℝ Set.univ softplus := by
  apply_rules [ convexOn_of_deriv2_nonneg, convex_univ ];
  · exact Continuous.continuousOn ( by exact Continuous.log ( by continuity ) fun x => by positivity );
  · exact Differentiable.differentiableOn ( by exact differentiable_id.exp.const_add 1 |> Differentiable.log <| by intro x; positivity );
  · unfold softplus;
    exact Differentiable.differentiableOn ( by rw [ show deriv ( fun x => log ( 1 + Real.exp x ) ) = fun x => Real.exp x / ( 1 + Real.exp x ) from funext fun x => by simp +decide [ Real.differentiableAt_exp, ne_of_gt ( add_pos zero_lt_one ( Real.exp_pos x ) ) ] ] ; exact Differentiable.div ( Real.differentiable_exp ) ( by norm_num [ Real.differentiable_exp ] ) fun x => by positivity );
  · unfold softplus; norm_num [ Real.differentiableAt_exp, mul_comm ];
    exact fun x => by rw [ show deriv ( fun x => log ( 1 + Real.exp x ) ) = fun x => Real.exp x / ( 1 + Real.exp x ) from funext fun x => by simp +decide [ Real.differentiableAt_exp, ne_of_gt ( add_pos zero_lt_one ( Real.exp_pos x ) ) ] ] ; norm_num [ Real.differentiableAt_exp, ne_of_gt ( add_pos zero_lt_one ( Real.exp_pos x ) ) ] ; ring_nf; positivity;

/-! ## Surjectivity -/

/-
softplus maps ℝ onto (0, ∞).
-/
theorem softplus_surjOn_Ioi : Set.SurjOn softplus Set.univ (Set.Ioi 0) := by
  -- Suppose $y > 0$, we need to find $x \in ℝ$ such that $\log(1 + e^x) = y$.
  intro y hy
  use Real.log (Real.exp y - 1);
  simp +zetaDelta at *;
  unfold softplus;
  rw [ Real.exp_log ( by linarith [ Real.add_one_le_exp y ] ), add_sub_cancel, Real.log_exp ]

/-! ## The orbit is strictly increasing -/

/-
The orbit σⁿ(x) is strictly increasing in n for each fixed x.
-/
theorem softplus_orbit_strictMono (x : ℝ) : StrictMono (fun n => softplus_iter n x) := by
  -- We can prove this by induction on $n$.
  have h_ind : ∀ n : ℕ, softplus_iter n x < softplus_iter (n + 1) x := by
    exact fun n => by rw [ show softplus_iter ( n + 1 ) x = softplus ( softplus_iter n x ) from rfl ] ; exact softplus_gt_id _;
  exact strictMono_nat_of_lt_succ h_ind

/-! ## Softplus Bounds -/

/-
softplus(x) ≤ x + log 2 for x ≥ 0.
-/
theorem softplus_le_add_log2 (x : ℝ) (hx : 0 ≤ x) :
    softplus x ≤ x + Real.log 2 := by
  unfold softplus;
  rw [ Real.log_le_iff_le_exp ( by positivity ) ];
  rw [ Real.exp_add, Real.exp_log ] <;> linarith [ Real.add_one_le_exp x ]

/-- softplus(x) ≥ x for all x (weaker than softplus_gt_id). -/
theorem softplus_ge_id (x : ℝ) : softplus x ≥ x :=
  le_of_lt (softplus_gt_id x)

/-! ## The Depth Hierarchy -/

/-- Depth of a Sheffer expression. -/
def ShefferExpr.depth : ShefferExpr → ℕ
  | .base => 1
  | .affinePrecomp _ _ e => e.depth
  | .affineComb _ _ _ e₁ e₂ => max e₁.depth e₂.depth

/-- Width of a Sheffer expression: total number of softplus leaves. -/
def ShefferExpr.width : ShefferExpr → ℕ
  | .base => 1
  | .affinePrecomp _ _ e => e.width
  | .affineComb _ _ _ e₁ e₂ => e₁.width + e₂.width

@[simp] theorem ShefferExpr.depth_base : ShefferExpr.base.depth = 1 := rfl
@[simp] theorem ShefferExpr.width_base : ShefferExpr.base.width = 1 := rfl

/-- Every Sheffer expression has positive depth. -/
theorem ShefferExpr.depth_pos (e : ShefferExpr) : 0 < e.depth := by
  induction e with
  | base => simp
  | affinePrecomp _ _ _ ih => exact ih
  | affineComb _ _ _ _ _ ih1 ih2 => simp [depth]; omega

/-- Every Sheffer expression has positive width. -/
theorem ShefferExpr.width_pos (e : ShefferExpr) : 0 < e.width := by
  induction e with
  | base => simp
  | affinePrecomp _ _ _ ih => exact ih
  | affineComb _ _ _ _ _ ih1 ih2 => simp [width]; omega

end