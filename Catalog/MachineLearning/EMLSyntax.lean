import Speculative.DepthSeparation.Derivative
import Mathlib

/-!
# EML Expression Syntax, Semantics, and Tower Representations

This file establishes the syntactic side of depth separation:
the canonical tower expression `towerExpr k` has depth exactly `k`,
size `k + 1`, and evaluates to `iterExp k`.

## Main results

* `towerExpr_eval` — `(towerExpr k).eval = iterExp k`
* `towerExpr_depth` — `(towerExpr k).depth = k`
* `towerExpr_size` — `(towerExpr k).size = k + 1`
-/

noncomputable section

open Real Set

/-
The canonical tower expression evaluates to `iterExp k`.
-/
theorem towerExpr_eval (k : ℕ) (x : ℝ) :
    (towerExpr k).eval x = iterExp k x := by
  induction' k with k ih generalizing x;
  · rfl;
  · exact congrArg Real.exp ( ih x )

/-
The depth of the canonical tower expression is exactly `k`.
-/
theorem towerExpr_depth (k : ℕ) :
    (towerExpr k).depth = k := by
  induction' k with k ih;
  · rfl;
  · exact show 1 + ( towerExpr k |> EMLExpr.depth ) = k + 1 from by linarith;

/-
The size of the canonical tower expression is `k + 1`.
-/
theorem towerExpr_size (k : ℕ) :
    (towerExpr k).size = k + 1 := by
  induction' k with k ih;
  · rfl;
  · -- In the case of `towerExpr (k + 1)`, the expression is `exp(towerExpr k)`.
    -- Using the inductive hypothesis `ih`, we can expand the size as `size (exp e) = 1 + size e`.
    have h_size_succ : (towerExpr (k + 1)).size = 1 + (towerExpr k).size := by
      rfl;
    linarith

end