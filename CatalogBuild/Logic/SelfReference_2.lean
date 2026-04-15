/-! # CatalogBuild.Logic.SelfReference_2

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 6
-/

import Mathlib

noncomputable section

noncomputable def iterate_from_bot {α : Type*} [CompleteLattice α]
    (f : α → α) : ℕ → α
  | 0 => ⊥
  | n + 1 => f (iterate_from_bot f n)

/-
PROBLEM
The iteration sequence is monotonically increasing when f is monotone.

PROVIDED SOLUTION
Show by induction on n that iterate_from_bot f n ≤ iterate_from_bot f (n+1). Base: bot_le. Step: apply hf to the IH. Then for m ≤ n, use transitivity through the chain.
-/

theorem iterate_from_bot_mono {α : Type*} [CompleteLattice α]
    (f : α → α) (hf : Monotone f) : Monotone (iterate_from_bot f) := by
  refine' monotone_nat_of_le_succ _;
  exact fun n => Nat.recOn n bot_le fun n ih => hf ih

/-! ## III. Quines — Programs That Output Themselves

A quine is a program whose output is its own source code.
The existence of quines follows from a fixed point theorem
(Kleene's recursion theorem). We formalize the existence of
"semantic quines" — functions that are fixed points. -/

/-
PROBLEM
**Existence of Fixed Points (Rogers' Theorem)**:
For any total function `f : α → α` on a type with enough structure,
there exists a "semantic quine" — an element that maps to itself
under any composition with f, given a surjection.

This is the abstract version of Kleene's recursion theorem.

PROVIDED SOLUTION
Since e is surjective, there exists m with e m = fun x => e (f x) x. Wait, e : α → (α → α). We need e (f n) n = e n n. Let's define g : α → α by g(x) = e (f x) x... actually we need to be more careful. Since e is surjective, for the function h : α → α defined by h(x) = e (f x) x, there exists m with e m = h, i.e., e m x = e (f x) x for all x. Set x = m: e m m = e (f m) m. So n = m works.
-/

theorem semantic_quine {α : Type*} (e : α → (α → α)) (he : Function.Surjective e)
    (f : α → α) : ∃ n : α, e (f n) n = e n n := by
  obtain ⟨ m, hm ⟩ := he ( fun n => e ( f n ) n );
  exact ⟨ m, congr_fun hm m ▸ rfl ⟩

/-! ## IV. The Y Combinator — Self-Reference in Lambda Calculus

In untyped lambda calculus, the Y combinator `Y = λf. (λx. f(x x))(λx. f(x x))`
provides a fixed point for every function. In typed settings, we can capture
this through recursive types. -/

/-
PROBLEM
In any system with a fixed-point combinator, every function has a fixed point.
This is trivially true when stated this way — the content is in the *existence*
of such combinators, which requires recursive types.

PROVIDED SOLUTION
Given fix and hfix, for any f, use x = fix f. Then f (fix f) = fix f by hfix, so fix f is a fixed point.
-/

theorem y_combinator_principle {α : Type*}
    (fix : (α → α) → α)
    (hfix : ∀ f : α → α, f (fix f) = fix f) :
    ∀ f : α → α, ∃ x, f x = x := by
  exact fun f => ⟨ _, hfix f ⟩

/-! ## V. Curry's Paradox — Self-Reference Breaks Everything

Curry's paradox shows that unrestricted self-reference plus modus ponens
leads to inconsistency. This is why type theory restricts self-reference. -/

/-
PROBLEM
**Curry's Paradox (Abstract)**:
If a system allows constructing a sentence `C` such that `C ↔ (C → P)`,
then `P` is derivable for any proposition `P`.

This shows why type theory must restrict self-reference.

PROVIDED SOLUTION
From h : C ↔ (C → P). First derive C: have step1 : C → P from fun hc => (h.mp hc) hc. Then have hc : C from h.mpr step1. Then P from step1 hc.
-/

theorem curry_paradox (C P : Prop) (h : C ↔ (C → P)) : P := by
  grind +qlia

/-! ## VI. The Liar Paradox Cannot Be Formalized

The liar sentence "This sentence is false" cannot exist in a consistent
system. We prove this directly. -/

/-
PROBLEM
**No Liar Sentence**: There is no proposition that is equivalent to
its own negation.

PROVIDED SOLUTION
Same as russell_paradox. Suppose P ↔ ¬P. Derive contradiction from P → ¬P and ¬P → P.
-/

theorem no_liar_sentence : ¬ ∃ (P : Prop), P ↔ ¬P := by
  grind

end FormalizingTheUnformalizable

end
