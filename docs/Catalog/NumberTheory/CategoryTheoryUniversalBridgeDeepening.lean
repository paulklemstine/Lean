import Catalog.Shared.CategoryTheoryUniversalBridge

/-! # Density, reconstruction, and uniqueness consequences of Yoneda

This file deepens `CategoryTheoryUniversalBridge` without introducing replacement
notions.  It records the density/extensionality consequence of Yoneda, detects
isomorphisms pointwise, characterizes the essential image of the Yoneda embedding,
and proves uniqueness of representing objects.  Parallel statements for sheaves
show that these conclusions survive passage from presheaves to local objects.
-/

open CategoryTheory Opposite

namespace CategoryTheoryUniversalBridge

universe v u

section PresheafDensity

variable {C : Type u} [Category.{v} C]

/-- **Yoneda density theorem.** Every presheaf is canonically a colimit of
representable presheaves, indexed by the costructured-arrow category of maps from
representables into it. -/
noncomputable def presheafDensityWitness (P : Cᵒᵖ ⥤ Type v) :
    CategoryTheory.Limits.IsColimit (CategoryTheory.Presheaf.tautologicalCocone P) :=
  CategoryTheory.Presheaf.isColimitTautologicalCocone P

/-- **Yoneda density as an extensionality principle.** A map out of an arbitrary
presheaf is completely determined by all of its restrictions along maps from
representable presheaves. -/
theorem presheaf_hom_ext_of_representables {P Q : Cᵒᵖ ⥤ Type v} {α β : P ⟶ Q}
    (h : ∀ (X : C) (p : yoneda.obj X ⟶ P), p ≫ α = p ≫ β) : α = β :=
  hom_ext_yoneda h

/-- A natural transformation of type-valued presheaves is an isomorphism whenever
it is a bijection at every object. -/
theorem presheaf_isIso_of_pointwise_bijective {P Q : Cᵒᵖ ⥤ Type v} (α : P ⟶ Q)
    (h : ∀ X, Function.Bijective (α.app X)) : IsIso α := by
  haveI (X : Cᵒᵖ) : IsIso (α.app X) :=
    (isIso_iff_bijective (α.app X)).2 (h X)
  exact NatIso.isIso_of_isIso_app α

/-- Yoneda reflects isomorphism classes of objects: two objects are isomorphic
exactly when their representable presheaves are isomorphic. -/
theorem yoneda_reflects_object_isomorphism {X Y : C} :
    Nonempty (X ≅ Y) ↔ Nonempty (yoneda.obj X ≅ yoneda.obj Y) := by
  constructor
  · rintro ⟨e⟩
    exact ⟨yoneda.mapIso e⟩
  · rintro ⟨e⟩
    exact ⟨Yoneda.fullyFaithful.preimageIso e⟩

/-- The essential image of Yoneda consists exactly of the representable
presheaves. -/
theorem isRepresentable_iff_in_yoneda_essential_image {F : Cᵒᵖ ⥤ Type v} :
    F.IsRepresentable ↔ ∃ X : C, Nonempty (yoneda.obj X ≅ F) := by
  constructor
  · intro h
    letI := h
    exact ⟨F.reprX, ⟨F.reprW⟩⟩
  · rintro ⟨X, ⟨e⟩⟩
    exact Functor.IsRepresentable.mk' e

/-- **Uniqueness of representing objects.** Any two objects representing the same
presheaf are isomorphic. -/
theorem representing_objects_unique_up_to_iso {F : Cᵒᵖ ⥤ Type v} {X Y : C}
    (eX : F.RepresentableBy X) (eY : F.RepresentableBy Y) : Nonempty (X ≅ Y) := by
  exact ⟨Yoneda.fullyFaithful.preimageIso (eX.toIso ≪≫ eY.toIso.symm)⟩

/-- A morphism is invertible if it induces bijections on every represented
hom-set.  This is the isomorphism-detection form of the Yoneda principle. -/
theorem isIso_of_representable_maps_bijective {X Y : C} (f : X ⟶ Y)
    (h : ∀ T : C, Function.Bijective ((yoneda.map f).app (op T))) : IsIso f := by
  exact isIso_of_yoneda_map_bijective f h

end PresheafDensity

section CovariantYoneda

variable {C : Type u} [Category.{v} C]

/-- The dual Yoneda embedding is fully faithful as well, so covariant represented
functors retain every morphism in the opposite category. -/
theorem coyoneda_embedding_fully_faithful (X Y : Cᵒᵖ) :
    Function.Bijective (fun f : X ⟶ Y => coyoneda.map f) :=
  Coyoneda.fullyFaithful.map_bijective X Y

/-- The dual Yoneda embedding also reflects isomorphism classes. -/
theorem coyoneda_reflects_object_isomorphism {X Y : Cᵒᵖ} :
    Nonempty (X ≅ Y) ↔ Nonempty (coyoneda.obj X ≅ coyoneda.obj Y) := by
  constructor
  · rintro ⟨e⟩
    exact ⟨coyoneda.mapIso e⟩
  · rintro ⟨e⟩
    exact ⟨Coyoneda.fullyFaithful.preimageIso e⟩

end CovariantYoneda

section SheafConsequences

variable {C : Type u} [Category.{v} C]
variable (J : GrothendieckTopology C)

/-- A morphism of type-valued sheaves is an isomorphism if it is bijective on
sections over every object of the site. -/
theorem sheaf_isIso_of_pointwise_bijective {F G : Sheaf J (Type v)} (α : F ⟶ G)
    (h : ∀ X, Function.Bijective (α.val.app X)) : IsIso α := by
  haveI (X : Cᵒᵖ) : IsIso (α.val.app X) :=
    (isIso_iff_bijective (α.val.app X)).2 (h X)
  have hα : IsIso α.val := NatIso.isIso_of_isIso_app α.val
  haveI : IsIso ((sheafToPresheaf J (Type v)).map α) := by
    change IsIso α.val
    exact hα
  exact isIso_of_reflects_iso α (sheafToPresheaf J (Type v))

variable [J.Subcanonical]

/-- On a subcanonical site, represented sheaves remember object isomorphism
classes exactly. -/
theorem sheaf_yoneda_reflects_object_isomorphism {X Y : C} :
    Nonempty (X ≅ Y) ↔ Nonempty (J.yoneda.obj X ≅ J.yoneda.obj Y) := by
  constructor
  · rintro ⟨e⟩
    exact ⟨J.yoneda.mapIso e⟩
  · rintro ⟨e⟩
    exact ⟨J.yonedaFullyFaithful.preimageIso e⟩

end SheafConsequences

end CategoryTheoryUniversalBridge