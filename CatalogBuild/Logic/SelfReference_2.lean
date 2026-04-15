/-! # CatalogBuild.Logic.SelfReference_2

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 6
-/

import Mathlib

noncomputable section

/-- The iteration sequence: f⁰(⊥), f¹(⊥), f²(⊥), ... -/
noncomputable def iterate_from_bot {α : Type*} [CompleteLattice α]
    (f : α → α) : ℕ → α
  | 0 => ⊥
  | n + 1 => f (iterate_from_bot f n)


/-- [Section: ## II. Kleene's Fixed Point Theorem
The least fixed point of a Scott-continuous function on a complete lattice
can be obtained as the supremum of its iterates from bottom.] -/
theorem iterate_from_bot_mono {α : Type*} [CompleteLattice α]
    (f : α → α) (hf : Monotone f) : Monotone (iterate_from_bot f) := by
  refine' monotone_nat_of_le_succ _;
  exact fun n => Nat.recOn n bot_le fun n ih => hf ih


/-- [Section: ## III. Quines — Programs That Output Themselves
A quine is a program whose output is its own source code.
The existence of quines follows from a fixed point theorem
(Kleene's recursion theorem). We formalize the existence of
"semantic quines" — functions that are fixed points.] -/
theorem semantic_quine {α : Type*} (e : α → (α → α)) (he : Function.Surjective e)
    (f : α → α) : ∃ n : α, e (f n) n = e n n := by
  obtain ⟨ m, hm ⟩ := he ( fun n => e ( f n ) n );
  exact ⟨ m, congr_fun hm m ▸ rfl ⟩


/-- [Section: ## IV. The Y Combinator — Self-Reference in Lambda Calculus
In untyped lambda calculus, the Y combinator `Y = λf. (λx. f(x x))(λx. f(x x))`
provides a fixed point for every function. In typed settings, we can capture
this through recursive types.] -/
theorem y_combinator_principle {α : Type*}
    (fix : (α → α) → α)
    (hfix : ∀ f : α → α, f (fix f) = fix f) :
    ∀ f : α → α, ∃ x, f x = x := by
  exact fun f => ⟨ _, hfix f ⟩


/-- [Section: ## V. Curry's Paradox — Self-Reference Breaks Everything
Curry's paradox shows that unrestricted self-reference plus modus ponens
leads to inconsistency. This is why type theory restricts self-reference.] -/
theorem curry_paradox (C P : Prop) (h : C ↔ (C → P)) : P := by
  grind +qlia


/-- [Section: ## VI. The Liar Paradox Cannot Be Formalized
The liar sentence "This sentence is false" cannot exist in a consistent
system. We prove this directly.] -/
theorem no_liar_sentence : ¬ ∃ (P : Prop), P ↔ ¬P := by
  grind


end
