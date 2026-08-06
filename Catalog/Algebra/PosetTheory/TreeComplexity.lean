/-
  Tree Complexity Measures and Well-Founded Termination

  Generic infrastructure for complexity measures on syntactic trees, used by the
  proof-refinement system.  A complexity measure lands in `ℕ`, whose strict order
  is a well-order; hence any rewriting relation that *strictly decreases* a
  `ℕ`-valued measure is terminating (its reverse is well-founded, so there are no
  infinite rewrite sequences).

  * `combined`                : the combined measure `length + depth + lemmas`.
  * `nat_lt_wf`               : `(· < ·)` on `ℕ` is well-founded.
  * `combined_isWellOrder`    : `(· < ·)` on `ℕ` is a well-order.
  * `measure_wf`              : the pullback of `<` along any `μ : α → ℕ` is WF.
  * `terminates`              : a step relation that strictly decreases a measure
                                has a well-founded reverse relation (termination).
-/
import Mathlib

namespace Learning.TreeComplexity

/-- The combined tree-complexity measure: `length + depth + lemma count`. -/
def combined (length depth lemmas : ℕ) : ℕ := length + depth + lemmas

/-- Strict order on `ℕ` is well-founded. -/
theorem nat_lt_wf : WellFounded (· < · : ℕ → ℕ → Prop) := Nat.lt_wfRel.wf

/-- Complexity values form a well-order: `<` on `ℕ` is a well-order. -/
theorem combined_isWellOrder : IsWellOrder ℕ (· < ·) := inferInstance

/-- The pullback of the well-order `<` along a measure `μ : α → ℕ` is
well-founded. -/
theorem measure_wf {α : Type*} (μ : α → ℕ) :
    WellFounded (InvImage (· < ·) μ) :=
  InvImage.wf μ nat_lt_wf

/--
**Termination from a strictly decreasing measure.**

If every `Step a b` strictly decreases the measure `μ`, then the *reverse*
relation `fun b a => Step a b` is well-founded.  Equivalently, there is no
infinite sequence `a₀, a₁, a₂, …` with `Step aₙ aₙ₊₁`; the rewriting process
terminates.
-/
theorem terminates {α : Type*} (μ : α → ℕ) (Step : α → α → Prop)
    (hdec : ∀ a b, Step a b → μ b < μ a) :
    WellFounded (fun b a => Step a b) := by
  apply Subrelation.wf (r := InvImage (· < ·) μ) _ (measure_wf μ)
  intro b a hab
  exact hdec a b hab

end Learning.TreeComplexity