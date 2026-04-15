/-! # CatalogBuild.Computation.Oracles.IdempotentCategory

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 10
-/

import Mathlib

noncomputable section

/-- An idempotent morphism in a category. -/
def IsIdem {C : Type*} [Category C] {X : C} (e : X ⟶ X) : Prop :=
  e ≫ e = e


/-- Identity is idempotent. -/
theorem isIdem_id {C : Type*} [Category C] (X : C) :
    IsIdem (𝟙 X) := by simp [IsIdem]


/-- A retraction pair (section-retraction) in a category. -/
structure RetrPair {C : Type*} [Category C] (X Y : C) where
  /-- Section: Y → X (inclusion) -/
  sect : Y ⟶ X
  /-- Retraction: X → Y (projection) -/
  retr : X ⟶ Y
  /-- The retraction-section identity: sect ≫ retr = 𝟙 Y -/
  is_retract : sect ≫ retr = 𝟙 Y


/-- Every retraction pair induces an idempotent on X via retr ≫ sect. -/
def RetrPair.toIdem {C : Type*} [Category C] {X Y : C}
    (r : RetrPair X Y) : X ⟶ X :=
  r.retr ≫ r.sect


theorem retrPair_idempotent {C : Type*} [Category C] {X Y : C}
    (r : RetrPair X Y) :
    IsIdem r.toIdem := by
      obtain ⟨sect, retr, h⟩ := r;
      dsimp [IsIdem];
      simp +decide [ RetrPair.toIdem ];
      grind +revert


theorem functor_preserves_idem {C D : Type*} [Category C] [Category D]
    (F : C ⥤ D) {X : C} {e : X ⟶ X} (he : IsIdem e) :
    IsIdem (F.map e) := by
      grind +locals


/-- The refinement ordering on idempotents. -/
def IdemRefines {C : Type*} [Category C] {X : C} (e f : X ⟶ X) : Prop :=
  e ≫ f = e ∧ f ≫ e = e


/-- Idempotent refinement is reflexive for idempotents. -/
theorem idemRefines_refl {C : Type*} [Category C] {X : C}
    (e : X ⟶ X) (he : IsIdem e) :
    IdemRefines e e := ⟨he, he⟩


/-- The identity idempotent is the top element. -/
theorem idemRefines_id {C : Type*} [Category C] {X : C}
    (e : X ⟶ X) (he : IsIdem e) :
    IdemRefines e (𝟙 X) :=
  ⟨Category.comp_id e, Category.id_comp e⟩


theorem idemRefines_trans {C : Type*} [Category C] {X : C}
    (e f g : X ⟶ X) (hef : IdemRefines e f) (hfg : IdemRefines f g) :
    IdemRefines e g := by
      constructor;
      · -- By definition of IdemRefines, we have e ≫ f = e and f ≫ e = e.
        obtain ⟨hef1, hef2⟩ := hef
        obtain ⟨hfg1, hfg2⟩ := hfg;
        grind;
      · convert congr_arg ( fun x => x ≫ e ) hfg.2 using 1;
        · rw [ Category.assoc, hef.2 ];
        · exact hef.2.symm


end
