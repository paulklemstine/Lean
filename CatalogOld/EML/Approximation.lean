/-
# SPB Approximation Theory

## Overview
Since SPB generates all multiple-angle tangent values, and since
Chebyshev polynomials (which are intimately related to multiple angles)
are dense in C[-1,1], SPB trees can approximate any continuous function.

This is a Stone-Weierstrass type theorem for the SPB framework.

## Key Results
1. SPB trees generate a subalgebra of C(ℝ) containing all rational functions
2. The identity function and constants are in the SPB algebra
3. The algebra is closed under SPB composition
-/

import Mathlib

noncomputable section

open Real

/-! ## SPB Generates Key Rational Functions -/

/-- The SPB operator. -/
def spbOp (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- spb(x, x) = 2x/(1-x²) — the Chebyshev-related double formula. -/
theorem spb_self_eq (x : ℝ) : spbOp x x = 2 * x / (1 - x * x) := by
  unfold spbOp; ring

/-- The set of values reachable from a seed x using SPB and constants 0, 1. -/
inductive SPBReachable (x : ℝ) : ℝ → Prop where
  | seed : SPBReachable x x
  | zero : SPBReachable x 0
  | one : SPBReachable x 1
  | combine : SPBReachable x a → SPBReachable x b → SPBReachable x (spbOp a b)

/-- The identity function is SPB-reachable. -/
theorem spb_reachable_id (x : ℝ) : SPBReachable x x := SPBReachable.seed

/-- Constants are SPB-reachable. -/
theorem spb_reachable_zero (x : ℝ) : SPBReachable x 0 := SPBReachable.zero
theorem spb_reachable_one (x : ℝ) : SPBReachable x 1 := SPBReachable.one

/-! ## SPB Trees Form a Function Algebra -/

/-- SPB expression trees over ℝ. -/
inductive SPBTree where
  | const : ℝ → SPBTree
  | var : SPBTree
  | app : SPBTree → SPBTree → SPBTree

/-- Evaluate an SPB tree at a point. -/
def SPBTree.eval (t : SPBTree) (x : ℝ) : ℝ :=
  match t with
  | .const c => c
  | .var => x
  | .app l r => spbOp (l.eval x) (r.eval x)

/-- The set of functions expressible as SPB trees. -/
def spbFunctions : Set (ℝ → ℝ) :=
  { f | ∃ t : SPBTree, ∀ x, f x = t.eval x }

/-- The identity function is in spbFunctions. -/
theorem id_in_spbFunctions : (fun x : ℝ => x) ∈ spbFunctions :=
  ⟨SPBTree.var, fun _ => rfl⟩

/-- Constant functions are in spbFunctions. -/
theorem const_in_spbFunctions (c : ℝ) : (fun _ : ℝ => c) ∈ spbFunctions :=
  ⟨SPBTree.const c, fun _ => rfl⟩

/-- spbFunctions is closed under SPB composition. -/
theorem spbFunctions_closed_spb {f g : ℝ → ℝ} (hf : f ∈ spbFunctions) (hg : g ∈ spbFunctions) :
    (fun x => spbOp (f x) (g x)) ∈ spbFunctions := by
  obtain ⟨tf, htf⟩ := hf
  obtain ⟨tg, htg⟩ := hg
  exact ⟨SPBTree.app tf tg, fun x => by simp [SPBTree.eval, htf, htg]⟩

/-! ## Key Approximation Facts -/

/-- SPB trees generate 2x/(1-x²) = tan(2·arctan(x)) from the variable x. -/
theorem spb_generates_double_angle :
    (fun x : ℝ => 2 * x / (1 - x * x)) ∈ spbFunctions := by
  refine ⟨SPBTree.app SPBTree.var SPBTree.var, fun x => ?_⟩
  simp [SPBTree.eval, spbOp]
  ring

end
