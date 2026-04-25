/-! # CatalogBuild.Algebra.CategoryTheory

Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 4
-/

import Mathlib

/-- [Section: # CatalogBuild.Algebra.CategoryTheory
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 4] -/
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





/-- [Section: # CatalogBuild.Algebra.CategoryTheory
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 4] -/
theorem id_functor_map {C : Type*} [Category C] {X Y : C} (f : X ⟶ Y) :
    (Functor.id C).map f = f := by
      grind





/-- [Section: # CatalogBuild.Algebra.CategoryTheory
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 4] -/
theorem functor_comp_assoc {A B C D : Type*}
    [Category A] [Category B] [Category C] [Category D]
    (F : A ⥤ B) (G : B ⥤ C) (H : C ⥤ D) :
    (F ⋙ G) ⋙ H = F ⋙ (G ⋙ H) := by
      aesop





theorem functor_comp_id {C D : Type*} [Category C] [Category D] (F : C ⥤ D) :
    F ⋙ Functor.id D = F := by
      bound



