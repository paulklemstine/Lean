import Mathlib

/-! # Category theory as a universal language

This file packages four existing parts of Mathlib's categorical API into one bridge:

* the Yoneda equivalence and the full faithfulness of the Yoneda embedding;
* the additive Yoneda embedding of a preadditive category into additive presheaves;
* the Yoneda lemma inside sheaves on a subcanonical site;
* the representation of subobjects by a subobject classifier.

No new replacement notions are introduced.  In particular, the topology statement uses
Mathlib's `Sheaf` and `GrothendieckTopology`, while the logic statement uses Mathlib's
`Classifier` and `Subobject.presheaf`.
-/

open CategoryTheory Opposite

namespace CategoryTheoryUniversalBridge

universe v u u₁ v₁

section Yoneda

variable {C : Type u} [Category.{v} C]

/-- **Yoneda lemma.** Natural transformations from the presheaf represented by `X`
are in canonical bijection with elements of `F` at `X`. -/
theorem yoneda_lemma_bijective {X : C} {F : Cᵒᵖ ⥤ Type v} :
    Function.Bijective (CategoryTheory.yonedaEquiv :
      (yoneda.obj X ⟶ F) → F.obj (op X)) :=
  CategoryTheory.yonedaEquiv.bijective

/-- A natural transformation out of a representable presheaf is reconstructed from
its value on the identity morphism.  This is the computational content of Yoneda. -/
theorem yoneda_reconstruction {X : C} {F : Cᵒᵖ ⥤ Type v}
    (α : yoneda.obj X ⟶ F) (Y : Cᵒᵖ) (f : Y.unop ⟶ X) :
    α.app Y f = F.map f.op (α.app (op X) (𝟙 X)) := by
  rw [← yonedaEquiv_apply α]
  exact map_yonedaEquiv α f |>.symm

/-- **The Yoneda embedding is fully faithful**, expressed as bijectivity on every
hom-set. -/
theorem yoneda_embedding_fully_faithful (X Y : C) :
    Function.Bijective (fun f : X ⟶ Y => yoneda.map f) :=
  Yoneda.fullyFaithful.map_bijective X Y

/-- Equivalently, every natural transformation between representables comes from a
unique morphism of the represented objects. -/
theorem yoneda_natural_transformation_unique {X Y : C}
    (α : yoneda.obj X ⟶ yoneda.obj Y) :
    ∃! f : X ⟶ Y, yoneda.map f = α := by
  obtain ⟨f, hf⟩ := Yoneda.fullyFaithful.map_surjective α
  refine ⟨f, hf, ?_⟩
  intro g hg
  exact Yoneda.fullyFaithful.map_injective (hg.trans hf.symm)

end Yoneda

section Algebra

variable {C : Type u} [Category.{v} C] [Preadditive C]
variable {D : Type u₁} [Category.{v₁} D] [Preadditive D]

/-- In the algebraic bridge, a represented object determines a module-valued
presheaf and that presheaf is additive. -/
theorem representable_module_presheaf_is_additive (X : C) :
    Functor.Additive (preadditiveYonedaObj X) :=
  inferInstance

/-- The additive Yoneda embedding is also fully faithful, stated hom-set by
hom-set.  Thus passing to additive functors loses no algebraic morphisms. -/
theorem additive_yoneda_embedding_fully_faithful (X Y : C) :
    Function.Bijective (fun f : X ⟶ Y => preadditiveYoneda.map f) := by
  let h : (preadditiveYoneda : C ⥤ Cᵒᵖ ⥤ AddCommGrpCat).FullyFaithful :=
    Functor.FullyFaithful.ofFullyFaithful _
  exact h.map_bijective X Y

/-- Every functor carrying the additive structure is canonically an object of
Mathlib's category of additive functors.  This is the precise categorical form of
the slogan that algebraic objects are studied through additive functors. -/
theorem additive_functor_packaging (F : C ⥤ D) [F.Additive] :
    ∃ G : C ⥤+ D, G.1 = F :=
  ⟨AdditiveFunctor.of F, AdditiveFunctor.of_fst F⟩

end Algebra

section Topology

variable {C : Type u} [Category.{v} C]
variable (J : GrothendieckTopology C) [J.Subcanonical]

/-- **Yoneda lemma for sheaves.** On a subcanonical site, maps from a represented
sheaf are exactly local sections over the representing object. -/
theorem sheaf_yoneda_lemma_bijective {X : C} {F : Sheaf J (Type v)} :
    Function.Bijective (J.yonedaEquiv :
      (J.yoneda.obj X ⟶ F) → F.val.obj (op X)) :=
  J.yonedaEquiv.bijective

/-- A map from a represented sheaf is determined on every restriction by its
section over the identity. -/
theorem sheaf_yoneda_reconstruction {X : C} {F : Sheaf J (Type v)}
    (α : J.yoneda.obj X ⟶ F) (Y : Cᵒᵖ) (f : Y.unop ⟶ X) :
    α.val.app Y f = F.val.map f.op (α.val.app (op X) (𝟙 X)) := by
  rw [← J.yonedaEquiv_apply α]
  exact J.map_yonedaEquiv' α f.op |>.symm

/-- The Yoneda embedding into sheaves on a subcanonical site is fully faithful. -/
theorem sheaf_yoneda_embedding_fully_faithful (X Y : C) :
    Function.Bijective (fun f : X ⟶ Y => J.yoneda.map f) :=
  J.yonedaFullyFaithful.map_bijective X Y

omit [J.Subcanonical] in
/-- Forgetting the sheaf condition loses no morphisms: the inclusion of sheaves
into presheaves is fully faithful. -/
theorem sheaves_are_full_subcategory (F G : Sheaf J (Type v)) :
    Function.Bijective
      (fun α : F ⟶ G => (sheafToPresheaf J (Type v)).map α) :=
  (fullyFaithfulSheafToPresheaf J (Type v)).map_bijective F G

end Topology

section Logic

open CategoryTheory.Limits

variable {C : Type u} [Category.{v} C] [HasPullbacks C]

/-- A subobject classifier represents the presheaf of subobjects.  Its
characteristic maps therefore satisfy a universal bijection. -/
theorem classifier_characteristic_maps_bijective (K : Classifier C) (X : C) :
    Function.Bijective (K.representableBy.homEquiv (X := X)) :=
  K.representableBy.homEquiv.bijective

variable [HasTerminal C]

/-- **Categorical semantics of predicates.** A category with pullbacks and a
terminal object has a subobject classifier exactly when its subobject presheaf is
representable. -/
theorem classifier_iff_subobject_presheaf_representable :
    HasClassifier C ↔ (Subobject.presheaf C).IsRepresentable :=
  CategoryTheory.isRepresentable_hasClassifier_iff

end Logic

end CategoryTheoryUniversalBridge