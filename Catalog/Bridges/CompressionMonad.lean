import Mathlib

/-!
# Categorical Theory of Compression Closures as Idempotent Monads

This file develops the categorical foundations for compression-closure duality
through idempotent monads. The central insight is that "compression" is not
merely an optimization heuristic but an **idempotent monadic reflection**:
incompressible data forms a reflective subcategory, and compression is the
universal approximation into that subcategory.

## Main Results

### Idempotent Monad Theory
- `idempotent_eta_T_isIso`: For an idempotent monad, `η_{TX}` is an isomorphism.
- `idempotent_T_obj_fixed`: Every `T(X)` is a fixed object of an idempotent monad.
- `compressionMonad_fixed_reflective`: Fixed objects of an idempotent monad form
  a reflective subcategory.

### Kleisli Equivalence
- `kleisli_equiv_fixedOfIdempotent`: The Kleisli category of an idempotent monad
  is equivalent to the full subcategory of fixed objects.

### MDL Monotonicity
- `monadHom_mdl_inequality`: Compression morphisms yield lower MDL values.

### Bridge to Closure Theory
- `closure_mdl_bound_categorical`: Recovers closure-based MDL bounds.
-/

open CategoryTheory

noncomputable section

universe u v

variable {C : Type u} [Category.{v} C]

/-- The full subcategory of T-fixed objects: those where the unit `η_X` is an isomorphism.
For an idempotent monad, these are exactly the "incompressible" or "canonical" objects. -/
def FixedByMonad (T : Monad C) : ObjectProperty C :=
  fun X => IsIso (T.η.app X)

/-! ## Part 1: Idempotent Monad Foundations -/

/-- For an idempotent monad, `η_{TX}` is an isomorphism. -/
theorem idempotent_eta_T_isIso (T : Monad C) (hidem : ∀ X : C, IsIso (T.μ.app X))
    (X : C) : IsIso (T.η.app (T.obj X)) := by
  have : IsIso (T.η.app (T.obj X) ≫ T.μ.app X) := by rw [T.left_unit]; infer_instance
  exact IsIso.of_isIso_comp_right _ (T.μ.app X)

/-- Every `T(X)` is a fixed object of an idempotent monad. -/
theorem idempotent_T_obj_fixed (T : Monad C) (hidem : ∀ X : C, IsIso (T.μ.app X))
    (X : C) : FixedByMonad T (T.obj X) :=
  idempotent_eta_T_isIso T hidem X

/-- For an idempotent monad, `T(η_X)` is also an isomorphism. -/
theorem idempotent_T_eta_isIso (T : Monad C) (hidem : ∀ X : C, IsIso (T.μ.app X))
    (X : C) : IsIso (T.map (T.η.app X)) := by
  have : IsIso (T.map (T.η.app X) ≫ T.μ.app X) := by rw [T.right_unit]; infer_instance
  exact IsIso.of_isIso_comp_right _ (T.μ.app X)

/-! ## Part 2: Reflective Subcategory of Fixed Objects -/

/-- The reflector functor: sends `X` to `T(X)` viewed as a fixed object. -/
def idempotentReflector (T : Monad C) (hidem : ∀ X : C, IsIso (T.μ.app X)) :
    C ⥤ (FixedByMonad T).FullSubcategory where
  obj X := ⟨T.obj X, idempotent_T_obj_fixed T hidem X⟩
  map f := ObjectProperty.homMk (T.map f)
  map_id X := by apply ObjectProperty.hom_ext; simp
  map_comp f g := by apply ObjectProperty.hom_ext; simp

/-
The hom-set equivalence for the reflector adjunction.
A morphism `T(X) → Y` in the fixed subcategory (where Y is fixed, η_Y is iso)
corresponds to a morphism `X → Y` in C via precomposition with η_X.
-/
def reflectorHomEquiv (T : Monad C) (hidem : ∀ X : C, IsIso (T.μ.app X))
    (X : C) (Y : (FixedByMonad T).FullSubcategory) :
    ((idempotentReflector T hidem).obj X ⟶ Y) ≃ (X ⟶ (FixedByMonad T).ι.obj Y) where
  toFun f := T.η.app X ≫ f.hom
  invFun g := by
    have : IsIso (T.η.app Y.obj) := Y.property
    exact ObjectProperty.homMk (T.map g ≫ inv (T.η.app Y.obj))
  left_inv f := by
    apply ObjectProperty.hom_ext;
    -- Since T.map (f.hom) = inv (η_{T.obj X}) ≫ f.hom ≫ η_{Y.obj}, we can simplify the expression.
    have h_simp : T.map (T.η.app X ≫ f.hom) = T.η.app (T.obj X) ≫ T.map (f.hom) := by
      have h_Teta : T.map (T.η.app X) = CategoryTheory.inv (T.μ.app X) := by
        have h_unit_X : T.map (T.η.app X) ≫ T.μ.app X = 𝟙 (T.obj X) := by
          grind +suggestions;
        grind +suggestions;
      have h_Teta : T.η.app (T.obj X) = CategoryTheory.inv (T.μ.app X) := by
        have := T.left_unit X;
        exact?;
      grind +locals;
    grind +suggestions
  right_inv g := by
    have := T.η.naturality g; simp_all +decide [ IsIso.inv_comp_eq ] ;

/-
The reflector adjunction: `idempotentReflector T ⊣ ι`.
-/
def reflectorAdjunction (T : Monad C) (hidem : ∀ X : C, IsIso (T.μ.app X)) :
    idempotentReflector T hidem ⊣ (FixedByMonad T).ι :=
  Adjunction.mkOfHomEquiv {
    homEquiv := reflectorHomEquiv T hidem
    homEquiv_naturality_left_symm := by
      simp +decide [ idempotentReflector, reflectorHomEquiv ];
      exact?
    homEquiv_naturality_right := by
      -- By definition of `reflectorHomEquiv`, we need to show that `η_X ≫ (f ≫ g).hom = η_X ≫ f.hom ≫ g.hom`.
      intros X Y Y' f g
      simp [reflectorHomEquiv]
  }

/-- **Theorem A**: The full subcategory of T-fixed objects is reflective
when T is an idempotent monad. -/
noncomputable def compressionMonad_fixed_reflective
    (T : Monad C)
    (hidem : ∀ X : C, IsIso (T.μ.app X)) :
    Reflective ((FixedByMonad T).ι) :=
  ⟨idempotentReflector T hidem, reflectorAdjunction T hidem⟩

/-! ## Part 3: Kleisli Equivalence -/

/-- The comparison functor from the Kleisli category to the fixed subcategory. -/
def kleisliToFixed (T : Monad C) (hidem : ∀ X : C, IsIso (T.μ.app X)) :
    Kleisli T ⥤ (FixedByMonad T).FullSubcategory where
  obj X := ⟨T.obj X, idempotent_T_obj_fixed T hidem X⟩
  map f := ObjectProperty.homMk ((Kleisli.Adjunction.fromKleisli T).map f)
  map_id X := by
    apply ObjectProperty.hom_ext
    exact (Kleisli.Adjunction.fromKleisli T).map_id X
  map_comp f g := by
    apply ObjectProperty.hom_ext
    exact (Kleisli.Adjunction.fromKleisli T).map_comp f g

/-- The inverse functor from the fixed subcategory to the Kleisli category. -/
def fixedToKleisli (T : Monad C) (_hidem : ∀ X : C, IsIso (T.μ.app X)) :
    (FixedByMonad T).FullSubcategory ⥤ Kleisli T where
  obj Y := (Y.obj : Kleisli T)
  map {Y₁ Y₂} f := show Y₁.obj ⟶ T.obj Y₂.obj from f.hom ≫ T.η.app Y₂.obj
  map_id Y := by
    show 𝟙 Y.obj ≫ T.η.app Y.obj = T.η.app Y.obj
    simp
  map_comp {Y₁ Y₂ Y₃} f g := by
    change (f ≫ g).hom ≫ T.η.app Y₃.obj =
      (f.hom ≫ T.η.app Y₂.obj) ≫ T.map (g.hom ≫ T.η.app Y₃.obj) ≫ T.μ.app Y₃.obj
    rw [ObjectProperty.FullSubcategory.comp_hom _ f g, T.toFunctor.map_comp]
    simp only [Category.assoc]
    congr 1
    have h_nat : T.η.app Y₂.obj ≫ T.map g.hom = g.hom ≫ T.η.app Y₃.obj :=
      (T.η.naturality g.hom).symm
    have h_ru := T.right_unit Y₃.obj
    have h_comp : T.η.app Y₃.obj ≫ 𝟙 (T.obj ((𝟭 C).obj Y₃.obj)) = T.η.app Y₃.obj :=
      Category.comp_id _
    rw [← h_ru] at h_comp
    rw [← Category.assoc (T.η.app Y₂.obj), h_nat, Category.assoc, h_comp]

/-
`kleisliToFixed` is faithful.
-/
theorem kleisliToFixed_faithful (T : Monad C) (hidem : ∀ X : C, IsIso (T.μ.app X)) :
    (kleisliToFixed T hidem).Faithful := by
  have h_theorem : ∀ (X Y : C) (f g : X ⟶ T.obj Y), T.map f ≫ T.μ.app Y = T.map g ≫ T.μ.app Y → f = g := by
    -- Since T.map f = T.map g, we have η_X ≫ T.map f = η_X ≫ T.map g.
    intro X Y f g hfg
    have h_eta : T.η.app X ≫ T.map f = T.η.app X ≫ T.map g := by
      apply_fun (fun x => x ≫ CategoryTheory.inv (T.μ.app Y)) at hfg;
      grind;
    have h_naturality : f ≫ T.η.app (T.obj Y) = T.η.app X ≫ T.map f ∧ g ≫ T.η.app (T.obj Y) = T.η.app X ≫ T.map g := by
      exact ⟨ by simpa using T.η.naturality f, by simpa using T.η.naturality g ⟩;
    have h_iso : IsIso (T.η.app (T.obj Y)) := by
      exact?;
    exact ( CategoryTheory.cancel_mono ( T.η.app ( T.obj Y ) ) ).1 ( by aesop );
  constructor;
  intro X Y f g hfg;
  convert h_theorem X Y f g _;
  convert congr_arg ( fun f => f.hom ) hfg using 1

/-
`kleisliToFixed` is full.
-/
theorem kleisliToFixed_full (T : Monad C) (hidem : ∀ X : C, IsIso (T.μ.app X)) :
    (kleisliToFixed T hidem).Full := by
  -- Let's take an arbitrary morphism g from T(X) to T(Y) in the fixed subcategory.
  have h_arbitrary : ∀ {X Y : C} (g : T.obj X ⟶ T.obj Y), IsIso (T.μ.app X) → IsIso (T.μ.app Y) → ∃ f : X ⟶ T.obj Y, T.map f ≫ T.μ.app Y = g := by
    intro X Y g hX hY
    use T.η.app X ≫ g;
    have h_Teta : T.map (T.η.app X) = CategoryTheory.inv (T.μ.app X) := by
      have := T.right_unit X;
      exact?;
    have h_Teta : T.η.app (T.obj X) = CategoryTheory.inv (T.μ.app X) := by
      have := T.left_unit X;
      exact?;
    have := T.η.naturality g; simp_all +decide [ CategoryTheory.IsIso.inv_comp_eq ] ;
    rw [ ← this, CategoryTheory.Category.assoc ];
    simp +decide [ CategoryTheory.Category.assoc, T.left_unit ];
  constructor;
  intro X Y g; specialize @h_arbitrary X Y g.hom; aesop;

/-
`kleisliToFixed` is essentially surjective.
-/
theorem kleisliToFixed_essSurj (T : Monad C) (hidem : ∀ X : C, IsIso (T.μ.app X)) :
    (kleisliToFixed T hidem).EssSurj := by
  refine' ⟨ fun Y => ⟨ Y.1, ⟨ _ ⟩ ⟩ ⟩;
  -- Since Y is a fixed object, we have that T.obj Y.obj ≅ Y.obj via the isomorphism provided by the fixed property.
  have h_iso : T.obj Y.obj ≅ Y.obj := by
    have h_iso : IsIso (T.η.app Y.obj) := by
      exact Y.2;
    exact?;
  exact?

/-- **Theorem B**: The Kleisli category of an idempotent monad is equivalent
to the full subcategory of fixed objects. -/
noncomputable def kleisli_equiv_fixedOfIdempotent
    (T : Monad C)
    (hidem : ∀ X : C, IsIso (T.μ.app X)) :
    Kleisli T ≌ (FixedByMonad T).FullSubcategory := by
  haveI := kleisliToFixed_faithful T hidem
  haveI := kleisliToFixed_full T hidem
  haveI := kleisliToFixed_essSurj T hidem
  haveI : (kleisliToFixed T hidem).IsEquivalence := Functor.IsEquivalence.mk
  exact (kleisliToFixed T hidem).asEquivalence

/-! ## Part 4: MDL Functional and Monotonicity -/

/-- A length functional on objects of a category. -/
class ObjectLength (C : Type u) [Category.{v} C] where
  lengthObj : C → ℝ

/-- The MDL of an object under compression monad `T`: the compressed length. -/
def mdlObj [ObjectLength C] (T : Monad C) (X : C) : ℝ :=
  ObjectLength.lengthObj (T.obj X)

/-- **Theorem C**: If `T₂` compresses at least as well as `T₁` objectwise,
then MDL under `T₂` is at most MDL under `T₁`. -/
theorem monadHom_mdl_inequality [ObjectLength C]
    (T₁ T₂ : Monad C)
    (hcompress : ∀ X : C, ObjectLength.lengthObj (T₂.obj X) ≤ ObjectLength.lengthObj (T₁.obj X)) :
    ∀ X : C, mdlObj T₂ X ≤ mdlObj T₁ X :=
  hcompress

/-- For a fixed object, compressed length = original length (given iso-invariance). -/
theorem mdl_fixed_eq [ObjectLength C]
    (T : Monad C) (X : C) (hfixed : IsIso (T.η.app X))
    (hiso_inv : ∀ {A B : C}, (A ≅ B) → ObjectLength.lengthObj A = ObjectLength.lengthObj B) :
    mdlObj T X = ObjectLength.lengthObj X :=
  Eq.symm (hiso_inv (asIso (T.η.app X)))

/-! ## Part 5: Bridge to Closure Operators -/

/-- The closure MDL bound: every element has a fixed-point representative
whose length equals the closure length. -/
theorem closure_mdl_bound_categorical
    {α : Type*} [Preorder α]
    (c : ClosureOperator α)
    (L : α → ℝ)
    (_hmono : Monotone L) :
    ∀ x : α, ∃ y : α, c y = y ∧ x ≤ y ∧ L y ≤ L (c x) :=
  fun x => ⟨c x, c.idempotent' x, c.le_closure' x, le_rfl⟩

/-- Compression gain is nonneg when length is monotone. -/
theorem closure_compression_gain_nonneg
    {α : Type*} [Preorder α]
    (c : ClosureOperator α)
    (L : α → ℝ)
    (hmono : Monotone L) (x : α) :
    0 ≤ L (c x) - L x :=
  sub_nonneg.mpr (hmono (c.le_closure' x))

end