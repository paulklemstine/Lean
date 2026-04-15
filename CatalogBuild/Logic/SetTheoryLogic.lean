/-! # CatalogBuild.Logic.SetTheoryLogic

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 13
-/

import Mathlib

theorem set_distrib_left {α : Type*} (A B C : Set α) :
    A ∩ (B ∪ C) = (A ∩ B) ∪ (A ∩ C) := by
  rw [ Set.inter_union_distrib_left ]

/-
PROBLEM
Distributive law: A ∪ (B ∩ C) = (A ∪ B) ∩ (A ∪ C)

PROVIDED SOLUTION
Use Set.union_inter_distrib_left
-/

theorem set_distrib_right {α : Type*} (A B C : Set α) :
    A ∪ (B ∩ C) = (A ∪ B) ∩ (A ∪ C) := by
  grind

/-
Complement involution
-/

theorem compl_compl' {α : Type*} (A : Set α) : Aᶜᶜ = A := by
  aesop

/-
Absorption law
-/

theorem absorption_union {α : Type*} (A B : Set α) :
    A ∪ (A ∩ B) = A := by
  exact Set.union_eq_left.mpr ( Set.inter_subset_left )

/-
Absorption law
-/

theorem absorption_inter {α : Type*} (A B : Set α) :
    A ∩ (A ∪ B) = A := by
  aesop_cat


theorem rat_countable : Countable ℚ := by
  infer_instance

/-
ℝ is uncountable (Cantor)
-/

theorem finite_is_countable {α : Type*} [Fintype α] : Countable α := by
  infer_instance

/-
|Fin n| = n
-/

theorem card_fin' (n : ℕ) : Fintype.card (Fin n) = n := by
  exact Fintype.card_fin n

/-
|Bool| = 2
-/

theorem card_bool : Fintype.card Bool = 2 := by
  rfl

/-
|Fin n → Bool| = 2^n
-/

theorem card_fin_to_bool (n : ℕ) : Fintype.card (Fin n → Bool) = 2 ^ n := by
  simp +decide [ Fintype.card_pi ]

end Cardinality

section WellOrdering

/-
ℕ is well-ordered: every nonempty subset has a minimum
-/

theorem injective_comp' {α β γ : Type*} (f : β → γ) (g : α → β)
    (hf : Function.Injective f) (hg : Function.Injective g) :
    Function.Injective (f ∘ g) := by
  exact hf.comp hg

/-
Composition of surjections is surjective
-/

theorem surjective_comp' {α β γ : Type*} (f : β → γ) (g : α → β)
    (hf : Function.Surjective f) (hg : Function.Surjective g) :
    Function.Surjective (f ∘ g) := by
  exact hf.comp hg

/-
A bijection has an inverse
-/

theorem bijective_has_inverse {α β : Type*} (f : α → β) (hf : Function.Bijective f) :
    ∃ g : β → α, Function.LeftInverse g f ∧ Function.RightInverse g f := by
  exact Function.bijective_iff_has_inverse.mp hf

