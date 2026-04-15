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


theorem iterate_from_bot_mono {α : Type*} [CompleteLattice α]
    (f : α → α) (hf : Monotone f) : Monotone (iterate_from_bot f) := by
  refine' monotone_nat_of_le_succ _;
  exact fun n => Nat.recOn n bot_le fun n ih => hf ih


theorem semantic_quine {α : Type*} (e : α → (α → α)) (he : Function.Surjective e)
    (f : α → α) : ∃ n : α, e (f n) n = e n n := by
  obtain ⟨ m, hm ⟩ := he ( fun n => e ( f n ) n );
  exact ⟨ m, congr_fun hm m ▸ rfl ⟩


theorem y_combinator_principle {α : Type*}
    (fix : (α → α) → α)
    (hfix : ∀ f : α → α, f (fix f) = fix f) :
    ∀ f : α → α, ∃ x, f x = x := by
  exact fun f => ⟨ _, hfix f ⟩


theorem curry_paradox (C P : Prop) (h : C ↔ (C → P)) : P := by
  grind +qlia


theorem no_liar_sentence : ¬ ∃ (P : Prop), P ↔ ¬P := by
  grind


end
