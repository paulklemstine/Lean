import Mathlib

/-!
# Tree complexity measures and the associated termination principle

`Shared/PosetTheory/ProofRefinement.lean` measures a proof tree by the triple
(`length`, `depth`, `lemmaCount`) and combines the three numbers into a single natural
number, then uses the well-order on `ℕ` to conclude that any rewriting relation which
strictly decreases the measure terminates.  This module supplies that small interface.

* `Learning.TreeComplexity.combined` — the additive combination `l + d + c`.
* `Learning.TreeComplexity.terminates` — a relation whose steps strictly decrease a
  `ℕ`-valued measure has a well-founded reverse, i.e. no infinite forward chain.

The termination principle is the pullback of the well-founded order `<` on `ℕ` along the
measure, obtained from `InvImage.wf` and `Nat.lt_wfRel`.
-/

namespace Learning.TreeComplexity

/-- The combined complexity measure of a tree with `l` nodes, height `d` and `c`
named-lemma references. -/
def combined (l d c : ℕ) : ℕ := l + d + c

@[simp] theorem combined_zero : combined 0 0 0 = 0 := rfl

/-- `combined` is monotone in each argument. -/
theorem combined_le_combined {l d c l' d' c' : ℕ}
    (hl : l ≤ l') (hd : d ≤ d') (hc : c ≤ c') :
    combined l d c ≤ combined l' d' c' := by
  unfold combined; omega

/-- `combined` is strictly monotone in its first argument. -/
theorem combined_lt_combined_left {l d c l' : ℕ} (h : l < l') :
    combined l d c < combined l' d c := by
  unfold combined; omega

/--
**Termination from a strictly decreasing measure.**

If every `R`-step strictly decreases the `ℕ`-valued measure `mu`, then the reverse of `R`
is well founded; equivalently there is no infinite chain `p₀ R p₁ R p₂ R …`.
-/
theorem terminates {α : Type*} (mu : α → ℕ) (R : α → α → Prop)
    (hR : ∀ p q, R p q → mu q < mu p) :
    WellFounded (fun q p : α => R p q) := by
  have hsub : Subrelation (fun q p : α => R p q) (InvImage (· < ·) mu) := by
    intro q p h
    exact hR p q h
  exact hsub.wf (InvImage.wf mu Nat.lt_wfRel.wf)

/-- The measure of any element bounds the length of every `R`-chain starting from it:
concretely, there is no element that reduces to itself. -/
theorem not_reduces_self {α : Type*} (mu : α → ℕ) (R : α → α → Prop)
    (hR : ∀ p q, R p q → mu q < mu p) (p : α) : ¬ R p p := fun h =>
  absurd (hR p p h) (lt_irrefl _)

end Learning.TreeComplexity