/-
# Concrete Finite Models: Prompt Optimization

This module provides concrete instantiations of the abstract prompt optimization theory.

## Model 1: Product Order on `ℕ × ℕ`
- Prompts: `ℕ × ℕ` with product order (specificity, depth)
- Quality: `ℕ` with natural order
- `eval (s, d) = max s d` — quality is the maximum of both dimensions
- `back q = (q, q)` — to achieve quality `q`, both dimensions must be at least `q`

## Model 2: Bool Lattice
- A tiny 2-element model demonstrating convergence
-/

import Mathlib
import Speculative.PromptOptimization.Core

open Function

/-! ## Model 1: Product Order on `ℕ × ℕ` -/

section NatModel

/-- Evaluation: prompt quality requirement is the maximum of two features. -/
def natEval : ℕ × ℕ → ℕ := fun p => max p.1 p.2

/-- Back-projection: to achieve quality `q`, set both features to `q`. -/
def natBack : ℕ → ℕ × ℕ := fun q => (q, q)

/-- The pair `(natEval, natBack)` forms a Galois connection:
`max a b ≤ q ↔ a ≤ q ∧ b ≤ q`. -/
theorem nat_galoisConnection : GaloisConnection natEval natBack := by
  unfold natEval natBack;
  intro p q; aesop

/-- In this model, optimal (closed) prompts are exactly balanced prompts `(n, n)`. -/
theorem nat_closed_iff (p : ℕ × ℕ) :
    PromptClosed natEval natBack p ↔ p.1 = p.2 := by
  unfold PromptClosed natEval natBack;
  grind

/-- The closure of any prompt `(a, b)` is `(max a b, max a b)`. -/
theorem nat_closure_eq (a b : ℕ) :
    promptClosure natEval natBack (a, b) = (max a b, max a b) := by
  rfl

/-- Concrete convergence: the alternating process stabilizes in exactly 1 step
because the closure is already idempotent. -/
theorem nat_converges_in_one_step (a b : ℕ) :
    promptClosure natEval natBack (promptClosure natEval natBack (a, b)) =
    promptClosure natEval natBack (a, b) := by
  simp [promptClosure, natEval, natBack]

/-- Concrete demonstration: starting from the unbalanced prompt (5, 3),
the optimal prompt is (5, 5). -/
example : promptClosure natEval natBack (5, 3) = (5, 5) := by native_decide

/-- Concrete demonstration: balanced prompts are already optimal. -/
example : PromptClosed natEval natBack (4, 4) := by
  show natBack (natEval (4, 4)) = (4, 4)
  native_decide

/-- The abstract theorems instantiate to give concrete results. -/
example : ∀ p : ℕ × ℕ, p ≤ promptClosure natEval natBack p :=
  promptClosure_inflationary nat_galoisConnection

example : ∀ p : ℕ × ℕ,
    promptClosure natEval natBack (promptClosure natEval natBack p) =
    promptClosure natEval natBack p :=
  promptClosure_idempotent nat_galoisConnection

/-- For quality threshold 7, the canonical prompt is (7, 7). -/
example : natBack 7 = (7, 7) := rfl

/-- The canonical prompt for quality 7 is optimal. -/
example : PromptClosed natEval natBack (natBack 7) :=
  quality_threshold_optimal nat_galoisConnection 7

end NatModel

/-! ## Model 2: Three-dimensional prompt space -/

section ThreeDimModel

/-- Three-dimensional prompt space representing (specificity, depth, breadth). -/
def eval3 : ℕ × ℕ × ℕ → ℕ := fun p => max (max p.1 p.2.1) p.2.2

/-- Back-projection to balanced 3D prompt. -/
def back3 : ℕ → ℕ × ℕ × ℕ := fun q => (q, q, q)

/-
The 3D model also forms a Galois connection.
-/
theorem galoisConnection3 : GaloisConnection eval3 back3 := by
  -- By definition of Galois connection, we need to show that for all p and q, p ≤ back3 q ↔ eval3 p ≤ q.
  intro p q
  simp [eval3, back3];
  exact ⟨ fun h => ⟨ h.1, h.2.1, h.2.2 ⟩, fun h => ⟨ h.1, h.2.1, h.2.2 ⟩ ⟩

/-- Closure of a 3D prompt is the balanced prompt at the maximum dimension. -/
theorem closure3_eq (a b c : ℕ) :
    promptClosure eval3 back3 (a, b, c) = (max (max a b) c, max (max a b) c, max (max a b) c) := by
  rfl

/-
3D optimal prompts are perfectly balanced.
-/
theorem closed3_iff (p : ℕ × ℕ × ℕ) :
    PromptClosed eval3 back3 p ↔ p.1 = p.2.1 ∧ p.1 = p.2.2 := by
  -- Unfold the definitions of `PromptClosed`, `eval3`, and `back3`.
  unfold PromptClosed eval3 back3
  simp;
  grind

end ThreeDimModel

/-! ## Model 3: Bool Lattice (Smallest Nontrivial Example) -/

section BoolModel

/-- On `Bool` with the natural order (false ≤ true), the identity forms
a Galois connection with itself. -/
theorem bool_galoisConnection : GaloisConnection (id : Bool → Bool) (id : Bool → Bool) := by
  intro a b
  exact Iff.rfl

/-- In the identity Galois connection, every element is already closed. -/
theorem bool_all_closed (b : Bool) : PromptClosed (id : Bool → Bool) id b := by
  rfl

/-- For finite Bool, convergence is immediate (0 steps). -/
theorem bool_converges_zero (b : Bool) :
    (promptClosure (id : Bool → Bool) id)^[0] b =
    (promptClosure (id : Bool → Bool) id)^[1] b := by
  simp [promptClosure]

end BoolModel