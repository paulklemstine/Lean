/-! # CatalogBuild.CategoryTheory.CategoryTheory

Auto-generated from theorem catalog database.
Domain: CategoryTheory
Declarations: 4
-/

import Mathlib

theorem functor_preserves_iso {C D : Type*} [Category C] [Category D]
    (F : C ⥤ D) {X Y : C} (f : X ≅ Y) :
    IsIso (F.map f.hom) := by
      have h_iso : IsIso (F.map f.hom) := by
        have h_iso : IsIso (F.map f.hom) := by
          exact ⟨F.map f.inv, by
            rw [ ← F.map_comp, f.hom_inv_id, F.map_id ], by
            rw [ ← F.map_comp, f.inv_hom_id, F.map_id ]⟩
        exact h_iso
      exact h_iso

/-
PROBLEM
The identity functor acts as identity on morphisms.

PROVIDED SOLUTION
By definition, the identity functor maps f to f. Use rfl or Functor.id_map.
-/

theorem id_functor_map {C : Type*} [Category C] {X Y : C} (f : X ⟶ Y) :
    (Functor.id C).map f = f := by
      grind

/-! ## Section 2: Composition Laws -/

/-
PROBLEM
Functor composition is associative.

PROVIDED SOLUTION
Use Functor.assoc or rfl - functor composition is definitionally associative.
-/

theorem functor_comp_assoc {A B C D : Type*}
    [Category A] [Category B] [Category C] [Category D]
    (F : A ⥤ B) (G : B ⥤ C) (H : C ⥤ D) :
    (F ⋙ G) ⋙ H = F ⋙ (G ⋙ H) := by
      aesop

/-
PROBLEM
Composing with the identity functor gives the same functor.

PROVIDED SOLUTION
Use Functor.comp_id or rfl.
-/

theorem functor_comp_id {C D : Type*} [Category C] [Category D] (F : C ⥤ D) :
    F ⋙ Functor.id D = F := by
      bound
