import Mathlib

/-!
# Ext as a universal (effaceable) cohomological δ-functor

This file develops the δ-functor formalism connecting homological algebra with the
`Ext` groups computed in the derived category, and proves the *uniqueness half* of
Grothendieck's universality theorem for `Ext`.

Main contents:

* `Catalog.Bridges.DeltaFunctor` : a cohomological δ-functor on an abelian category
  `C`, i.e. a family of additive functors `F n : C ⥤ AddCommGrpCat` together with
  connecting morphisms for short exact sequences and the long exact sequence axioms;
* `Catalog.Bridges.extDeltaFunctor X` : the δ-functor `Y ↦ Ext^n(X, Y)`;
* `Catalog.Bridges.extDeltaFunctor_effaceable` : `Ext^{n+1}(X, I) = 0` for injective `I`
  (effaceability);
* `Catalog.Bridges.DeltaFunctorHom.ext_of_app_zero` : **universality (uniqueness)** —
  two morphisms of δ-functors out of an effaceable δ-functor which agree in degree `0`
  agree in every degree.  Applied to `Ext`, this says that a natural transformation
  `Hom(X, -) ⟹ S⁰` admits *at most one* extension to a morphism of δ-functors
  `Ext^*(X, -) ⟹ S^*`.
-/

universe w v u

namespace Catalog.Bridges

open CategoryTheory Category Limits Abelian

variable (C : Type u) [Category.{v} C] [Abelian C]

/-- A cohomological δ-functor on an abelian category `C`, with values in abelian groups:
a family of additive functors `F n` together with connecting maps `δ` associated with
short exact sequences, satisfying the long exact sequence axioms. -/
structure DeltaFunctor where
  /-- the underlying family of functors -/
  F : ℕ → C ⥤ AddCommGrpCat.{w}
  /-- each functor is additive -/
  additive : ∀ n, (F n).Additive
  /-- the connecting morphism -/
  δ : ∀ {S : ShortComplex C}, S.ShortExact → ∀ n : ℕ, (F n).obj S.X₃ ⟶ (F (n + 1)).obj S.X₁
  /-- `F n (g) ≫ δ = 0` -/
  zero₃ : ∀ {S : ShortComplex C} (hS : S.ShortExact) (n : ℕ),
    (F n).map S.g ≫ δ hS n = 0
  /-- `δ ≫ F (n+1) (f) = 0` -/
  zero₁ : ∀ {S : ShortComplex C} (hS : S.ShortExact) (n : ℕ),
    δ hS n ≫ (F (n + 1)).map S.f = 0
  /-- exactness at `F n (X₂)` -/
  exact₂ : ∀ {S : ShortComplex C} (_ : S.ShortExact) (n : ℕ),
    (ShortComplex.mk ((F n).map S.f) ((F n).map S.g) (by
      rw [← Functor.map_comp, S.zero]
      have := additive n
      exact Functor.map_zero _ _ _)).Exact
  /-- exactness at `F n (X₃)` -/
  exact₃ : ∀ {S : ShortComplex C} (hS : S.ShortExact) (n : ℕ),
    (ShortComplex.mk ((F n).map S.g) (δ hS n) (zero₃ hS n)).Exact
  /-- exactness at `F (n+1) (X₁)` -/
  exact₁ : ∀ {S : ShortComplex C} (hS : S.ShortExact) (n : ℕ),
    (ShortComplex.mk (δ hS n) ((F (n + 1)).map S.f) (zero₁ hS n)).Exact

namespace DeltaFunctor

variable {C}

/-- A morphism of δ-functors: natural transformations in each degree commuting with the
connecting maps. -/
structure Hom (T S : DeltaFunctor.{w} C) where
  /-- the natural transformation in degree `n` -/
  app : ∀ n : ℕ, T.F n ⟶ S.F n
  /-- compatibility with the connecting morphisms -/
  comm : ∀ {W : ShortComplex C} (hW : W.ShortExact) (n : ℕ),
    T.δ hW n ≫ (app (n + 1)).app W.X₁ = (app n).app W.X₃ ≫ S.δ hW n

/-- The identity morphism of δ-functors. -/
@[simps]
def Hom.id (T : DeltaFunctor.{w} C) : T.Hom T where
  app n := 𝟙 _
  comm _ _ := by simp

/-- A δ-functor is *effaceable* if it vanishes in positive degrees on injective objects. -/
def Effaceable (T : DeltaFunctor.{w} C) : Prop :=
  ∀ (I : C) (_ : Injective I) (n : ℕ), IsZero ((T.F (n + 1)).obj I)

section

variable [EnoughInjectives C]

/-- The canonical short exact sequence `0 → Y → I → I/Y → 0` embedding `Y` into an
injective object. -/
noncomputable def injectiveEmbedding (Y : C) : ShortComplex C :=
  ShortComplex.mk (Injective.ι Y) (cokernel.π (Injective.ι Y)) (by simp)

lemma injectiveEmbedding_shortExact (Y : C) : (injectiveEmbedding Y).ShortExact where
  exact := ShortComplex.exact_of_g_is_cokernel _ (cokernelIsCokernel _)
  mono_f := by dsimp [injectiveEmbedding]; infer_instance
  epi_g := by dsimp [injectiveEmbedding]; infer_instance

/-- For an effaceable δ-functor, the connecting map out of the cokernel of an injective
embedding is surjective. -/
lemma surjective_delta_injectiveEmbedding {T : DeltaFunctor.{w} C} (hT : T.Effaceable)
    (Y : C) (n : ℕ) :
    Function.Surjective
      (T.δ (injectiveEmbedding_shortExact Y) n).hom := by
  intro x
  have hex := T.exact₁ (injectiveEmbedding_shortExact Y) n
  rw [ShortComplex.ab_exact_iff] at hex
  refine hex x ?_
  have hz : ((T.F (n + 1)).map (injectiveEmbedding Y).f) = 0 :=
    (hT (Injective.under Y) inferInstance n).eq_of_tgt _ 0
  simp [hz]

/-- **Universality of effaceable δ-functors (uniqueness).**  Two morphisms of δ-functors
out of an effaceable δ-functor which agree in degree `0` agree in all degrees. -/
theorem Hom.ext_of_app_zero {T S : DeltaFunctor.{w} C} (hT : T.Effaceable)
    (φ ψ : T.Hom S) (h0 : φ.app 0 = ψ.app 0) : ∀ n, φ.app n = ψ.app n := by
  intro n
  induction n with
  | zero => exact h0
  | succ n ih =>
    ext Y x
    obtain ⟨y, hy⟩ := surjective_delta_injectiveEmbedding hT Y n x
    have hφ := φ.comm (injectiveEmbedding_shortExact Y) n
    have hψ := ψ.comm (injectiveEmbedding_shortExact Y) n
    have hφ' := ConcreteCategory.congr_hom hφ y
    have hψ' := ConcreteCategory.congr_hom hψ y
    simp only [ConcreteCategory.comp_apply] at hφ' hψ'
    subst hy
    exact hφ'.trans (by rw [ih]; exact hψ'.symm)

end

end DeltaFunctor

section Ext

variable {C} [HasExt.{w} C]

/-- The δ-functor `Y ↦ Ext^n(X, Y)` associated with an object `X` of an abelian
category. -/
noncomputable def extDeltaFunctor (X : C) : DeltaFunctor.{w} C where
  F n := extFunctorObj X n
  additive n := inferInstance
  δ hS n := AddCommGrpCat.ofHom (hS.extClass.postcomp X rfl)
  zero₃ := fun {S} hS n => by
    ext x
    show (Ext.comp (Ext.comp x (Ext.mk₀ S.g) (add_zero n)) hS.extClass rfl) = 0
    rw [Ext.comp_assoc_of_second_deg_zero, hS.comp_extClass, Ext.comp_zero]
  zero₁ := fun {S} hS n => by
    ext x
    show (Ext.comp (Ext.comp x hS.extClass rfl) (Ext.mk₀ S.f) (add_zero (n + 1))) = 0
    rw [Ext.comp_assoc_of_third_deg_zero, hS.extClass_comp, Ext.comp_zero]
  exact₂ hS n := Ext.covariant_sequence_exact₂' X hS n
  exact₃ hS n := Ext.covariant_sequence_exact₃' X hS n (n + 1) rfl
  exact₁ hS n := Ext.covariant_sequence_exact₁' X hS n (n + 1) rfl

/-- **Effaceability of `Ext`.**  `Ext^{n+1}(X, I)` vanishes for `I` injective. -/
lemma extDeltaFunctor_effaceable (X : C) : (extDeltaFunctor.{w} X).Effaceable := by
  intro I _ n
  have h : Subsingleton (Ext.{w} X I (n + 1)) := Ext.subsingleton_of_injective X I n
  exact @AddCommGrpCat.isZero_of_subsingleton (((extDeltaFunctor X).F (n + 1)).obj I) h

/-- **`Ext` is a universal δ-functor (uniqueness part).**  Any two morphisms of
δ-functors from `Ext^*(X, -)` to a δ-functor `S` which agree in degree `0` are equal. -/
theorem extDeltaFunctor_universal [EnoughInjectives C] (X : C) {S : DeltaFunctor.{w} C}
    (φ ψ : (extDeltaFunctor.{w} X).Hom S) (h0 : φ.app 0 = ψ.app 0) :
    ∀ n, φ.app n = ψ.app n :=
  DeltaFunctor.Hom.ext_of_app_zero (extDeltaFunctor_effaceable X) φ ψ h0

/-- **Rigidity of `Ext`.**  An endomorphism of the δ-functor `Ext^*(X, -)` which is the
identity in degree `0` is the identity in every degree. -/
theorem extDeltaFunctor_endo_eq_id [EnoughInjectives C] (X : C)
    (φ : (extDeltaFunctor.{w} X).Hom (extDeltaFunctor.{w} X))
    (h0 : φ.app 0 = 𝟙 _) (n : ℕ) : φ.app n = 𝟙 _ :=
  extDeltaFunctor_universal X φ (DeltaFunctor.Hom.id _) h0 n

end Ext

end Catalog.Bridges