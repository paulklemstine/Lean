/-! # CatalogBuild.Algebra.CategoryTheoryExploration

Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 6
-/

import Mathlib

/-- [Section: # CatalogBuild.Algebra.CategoryTheoryExploration
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 6] -/
theorem functor_preserves_id {C D : Type*} [Category C] [Category D]
    (F : C ⥤ D) (X : C) : F.map (𝟙 X) = 𝟙 (F.obj X) := by simp




/-- [Section: # CatalogBuild.Algebra.CategoryTheoryExploration
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 6] -/
theorem functor_preserves_comp {C D : Type*} [Category C] [Category D]
    (F : C ⥤ D) {X Y Z : C} (f : X ⟶ Y) (g : Y ⟶ Z) :
    F.map (f ≫ g) = F.map f ≫ F.map g := by simp




theorem finset_product_card (α β : Type*) [Fintype α] [Fintype β] :
    Fintype.card (α × β) = Fintype.card α * Fintype.card β :=
  Fintype.card_prod α β




theorem finset_sum_card' (α β : Type*) [Fintype α] [Fintype β] :
    Fintype.card (α ⊕ β) = Fintype.card α + Fintype.card β :=
  @Fintype.card_sum α β _ _




theorem type_assoc_card (α β γ : Type*) [Fintype α] [Fintype β] [Fintype γ] :
    Fintype.card ((α × β) × γ) = Fintype.card (α × (β × γ)) := by
  simp [Fintype.card_prod]; ring




theorem exponential_card (a b c : ℕ) :
    c ^ (a * b) = (c ^ b) ^ a := by
  rw [← pow_mul, mul_comm]



