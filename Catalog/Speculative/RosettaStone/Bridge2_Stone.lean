/-! # CatalogBuild.Speculative.RosettaStone.Bridge2_Stone

Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 14
-/

import Mathlib

/-- Every element is idempotent under ∧. -/
theorem boolean_inf_idempotent (a : α) : a ⊓ a = a := inf_idem a




/-- Every element is idempotent under ∨. -/
theorem boolean_sup_idempotent (a : α) : a ⊔ a = a := sup_idem a




/-- Double complement. -/
theorem boolean_compl_compl (a : α) : aᶜᶜ = a := compl_compl a




/-- De Morgan (inf). -/
theorem boolean_de_morgan_inf (a b : α) : (a ⊓ b)ᶜ = aᶜ ⊔ bᶜ := compl_inf




/-- De Morgan (sup). -/
theorem boolean_de_morgan_sup (a b : α) : (a ⊔ b)ᶜ = aᶜ ⊓ bᶜ := compl_sup




/-- a ∨ ¬a = ⊤. -/
theorem boolean_sup_compl_top (a : α) : a ⊔ aᶜ = ⊤ := sup_compl_eq_top




/-- a ∧ ¬a = ⊥. -/
theorem boolean_inf_compl_bot (a : α) : a ⊓ aᶜ = ⊥ := inf_compl_eq_bot




/-- Distributivity. -/
theorem boolean_inf_sup_distrib (a b c : α) : a ⊓ (b ⊔ c) = (a ⊓ b) ⊔ (a ⊓ c) :=
  inf_sup_left a b c




/-- [Section: # CatalogBuild.Speculative.RosettaStone.Bridge2_Stone
Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 14] -/
theorem prop_and_idempotent (P : Prop) : P ∧ P ↔ P :=
  ⟨fun ⟨h, _⟩ => h, fun h => ⟨h, h⟩⟩




/-- [Section: # CatalogBuild.Speculative.RosettaStone.Bridge2_Stone
Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 14] -/
theorem prop_or_idempotent (P : Prop) : P ∨ P ↔ P :=
  ⟨fun h => h.elim id id, fun h => Or.inl h⟩




theorem prop_em (P : Prop) : P ∨ ¬P := Classical.em P




theorem bool_and_idem : ∀ b : Bool, (b && b) = b := by
  intro b; cases b <;> rfl




theorem finset_inter_idem {β : Type*} [DecidableEq β] (s : Finset β) :
    s ∩ s = s := Finset.inter_self s




theorem finset_union_idem {β : Type*} [DecidableEq β] (s : Finset β) :
    s ∪ s = s := Finset.union_self s



