/-! # CatalogBuild.EML.NewResults

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 6
-/

import Mathlib
import EML.Basic
import EML.OrbitDynamics

noncomputable section

/-- [Section: ## Surjectivity] -/
theorem softplus_surjOn_Ioi : Set.SurjOn softplus Set.univ (Set.Ioi 0) := by
  -- Suppose $y > 0$, we need to find $x \in ℝ$ such that $\log(1 + e^x) = y$.
  intro y hy
  use Real.log (Real.exp y - 1);
  simp +zetaDelta at *;
  unfold softplus;
  rw [ Real.exp_log ( by linarith [ Real.add_one_le_exp y ] ), add_sub_cancel, Real.log_exp ]


/-- [Section: ## The orbit is strictly increasing] -/
theorem softplus_orbit_strictMono (x : ℝ) : StrictMono (fun n => softplus_iter n x) := by
  -- We can prove this by induction on $n$.
  have h_ind : ∀ n : ℕ, softplus_iter n x < softplus_iter (n + 1) x := by
    exact fun n => by rw [ show softplus_iter ( n + 1 ) x = softplus ( softplus_iter n x ) from rfl ] ; exact softplus_gt_id _;
  exact strictMono_nat_of_lt_succ h_ind


/-- [Section: ## Softplus Bounds] -/
theorem softplus_le_add_log2 (x : ℝ) (hx : 0 ≤ x) :
    softplus x ≤ x + Real.log 2 := by
  unfold softplus;
  rw [ Real.log_le_iff_le_exp ( by positivity ) ];
  rw [ Real.exp_add, Real.exp_log ] <;> linarith [ Real.add_one_le_exp x ]


/-- softplus(x) ≥ x for all x (weaker than softplus_gt_id). -/
theorem softplus_ge_id (x : ℝ) : softplus x ≥ x :=
  le_of_lt (softplus_gt_id x)


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
