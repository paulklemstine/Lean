/-! # CatalogBuild.Bridges.PigeonholeInjectionBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 5
-/

import Mathlib

/-- **Injection bound**: If f : α → β is injective, then |α| ≤ |β|. -/
theorem card_le_of_injective {α β : Type*} [Fintype α] [Fintype β]
    (f : α → β) (hf : Function.Injective f) :
    Fintype.card α ≤ Fintype.card β :=
  Fintype.card_le_of_injective f hf


/-- **Surjection bound**: If f : α → β is surjective, then |β| ≤ |α|. -/
theorem card_le_of_surjective {α β : Type*} [Fintype α] [Fintype β]
    (f : α → β) (hf : Function.Surjective f) :
    Fintype.card β ≤ Fintype.card α :=
  Fintype.card_le_of_surjective f hf


/-- A bijective function implies equal cardinality. -/
theorem card_eq_of_bijective {α β : Type*} [Fintype α] [Fintype β]
    (f : α → β) (hf : Function.Bijective f) :
    Fintype.card α = Fintype.card β :=
  le_antisymm (card_le_of_injective f hf.1) (card_le_of_surjective f hf.2)


/-- No injection from a larger finite type to a smaller one. -/
theorem no_injection_of_card_lt {α β : Type*} [Fintype α] [Fintype β]
    (h : Fintype.card β < Fintype.card α) (f : α → β) :
    ¬Function.Injective f := by
  intro hf
  have := card_le_of_injective f hf
  omega


/-- No surjection from a smaller finite type to a larger one. -/
theorem no_surjection_of_card_lt {α β : Type*} [Fintype α] [Fintype β]
    (h : Fintype.card α < Fintype.card β) (f : α → β) :
    ¬Function.Surjective f := by
  intro hf
  have := card_le_of_surjective f hf
  omega

