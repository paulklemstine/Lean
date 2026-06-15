import Mathlib

/-! # Pigeonhole Injection Bridge

Proves fundamental results about finite cardinalities and injectivity:
1. Pigeonhole principle: more pigeons than holes → collision
2. Injection bound: |α| ≤ |β| if α injects into β
3. Surjection bound: |β| ≤ |α| if f : α ↠ β
4. Bijection = same cardinality
5. No injection from larger to smaller
-/

namespace PigeonholeInjectionBridge

/-! ## Section 1: Pigeonhole Principle -/

/-- **Pigeonhole principle**: If |α| > |β|, then f : α → β has a collision. -/
theorem pigeonhole {α β : Type*} [Fintype α] [Fintype β]
    (f : α → β) (h : Fintype.card β < Fintype.card α) :
    ∃ x y, x ≠ y ∧ f x = f y :=
  Fintype.exists_ne_map_eq_of_card_lt f h

/-! ## Section 2: Injection Bounds -/

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

/-! ## Section 3: Bijection = Same Cardinality -/

/-- A bijective function implies equal cardinality. -/
theorem card_eq_of_bijective {α β : Type*} [Fintype α] [Fintype β]
    (f : α → β) (hf : Function.Bijective f) :
    Fintype.card α = Fintype.card β :=
  le_antisymm (card_le_of_injective f hf.1) (card_le_of_surjective f hf.2)

/-! ## Section 4: No injection from larger to smaller -/

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

end PigeonholeInjectionBridge