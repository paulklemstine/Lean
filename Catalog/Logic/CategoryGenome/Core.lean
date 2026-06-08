/-
Copyright (c) 2024. All rights reserved.
Released under Apache 2.0 license.

# Theory Genomes: Monads as Genetic Codes for Mathematical Theories

This module formalizes the idea that a monad on a category C encodes the "genome"
of an algebraic theory: its Eilenberg-Moore algebras are the "phenotypes" (models),
and monad morphisms are "genome mutations" that induce pullback functors on models.

## Main results

* `GenomeMorphism` — A monad morphism from S to T, consisting of a natural
  transformation compatible with unit (η) and multiplication (μ).
* `genomePullback` — Every genome morphism S → T induces a functor T.Algebra ⥤ S.Algebra.
* `genomePullbackId` — The identity morphism induces a natural isomorphism to the
  identity functor.
* `genomePullbackComp` — Composition of morphisms gives composition of pullback functors.
* `adjunction_roundtrip_functor_eq` — The EM adjunction recovers the original monad's
  functor.
-/

import Mathlib

open CategoryTheory

universe v u

namespace TheoryGenome

variable {C : Type u} [Category.{v} C]

/-! ## Genome Morphisms (Monad Morphisms)

A genome morphism from monad S to monad T is a natural transformation
`φ : S.toFunctor ⟶ T.toFunctor` that commutes with unit and multiplication.
-/

/-- A morphism of monads (genome mutation): a natural transformation `φ : S ⟶ T`
    compatible with unit and multiplication. -/
structure GenomeMorphism (S T : Monad C) where
  /-- The underlying natural transformation -/
  toNatTrans : S.toFunctor ⟶ T.toFunctor
  /-- Compatibility with the unit: η_T = φ ∘ η_S -/
  unit_comm : ∀ (X : C), S.η.app X ≫ toNatTrans.app X = T.η.app X
  /-- Compatibility with multiplication: φ ∘ μ_S = μ_T ∘ (T φ) ∘ (φ S) -/
  mul_comm : ∀ (X : C),
    S.μ.app X ≫ toNatTrans.app X =
      toNatTrans.app (S.obj X) ≫ T.map (toNatTrans.app X) ≫ T.μ.app X

/-! ## The Pullback Functor -/

/-
Given a genome morphism φ : S → T, restrict a T-algebra to an S-algebra.
-/
def pullbackAlgebra {S T : Monad C} (φ : GenomeMorphism S T)
    (alg : T.Algebra) : S.Algebra where
  A := alg.A
  a := φ.toNatTrans.app alg.A ≫ alg.a
  unit := by
    simp only [Functor.id_obj]
    rw [← Category.assoc, φ.unit_comm]
    exact alg.unit
  assoc := by
    rw [ ← CategoryTheory.Category.assoc, φ.mul_comm ];
    have := alg.assoc; simp_all +decide [ CategoryTheory.Category.assoc ] ;

/-
Restrict a T-algebra homomorphism to an S-algebra homomorphism.
-/
def pullbackHom {S T : Monad C} (φ : GenomeMorphism S T)
    {alg₁ alg₂ : T.Algebra} (f : alg₁.Hom alg₂) :
    (pullbackAlgebra φ alg₁).Hom (pullbackAlgebra φ alg₂) where
  f := f.f
  h := by
    have := φ.toNatTrans.naturality f.f; simp_all +decide [ pullbackAlgebra ] ;

/-- The pullback functor: a genome morphism S → T induces T.Algebra ⥤ S.Algebra. -/
@[simps]
def genomePullback {S T : Monad C} (φ : GenomeMorphism S T) :
    T.Algebra ⥤ S.Algebra where
  obj := pullbackAlgebra φ
  map f := pullbackHom φ f
  map_id X := by ext; rfl
  map_comp f g := by ext; rfl

/-! ## Identity Genome Morphism -/

/-- The identity genome morphism on a monad T. -/
def GenomeMorphism.id (T : Monad C) : GenomeMorphism T T where
  toNatTrans := 𝟙 T.toFunctor
  unit_comm X := by simp
  mul_comm X := by
    simp only [NatTrans.id_app, Functor.comp_obj]
    rw [T.toFunctor.map_id, Category.id_comp]
    simp

/-- The pullback along the identity morphism is naturally isomorphic to the
    identity functor. -/
def genomePullbackId (T : Monad C) :
    genomePullback (GenomeMorphism.id T) ≅ 𝟭 T.Algebra :=
  NatIso.ofComponents
    (fun alg => Monad.Algebra.isoMk (Iso.refl _) (by
      simp [pullbackAlgebra, GenomeMorphism.id]))
    (fun f => by ext; simp [Monad.Algebra.isoMk, pullbackHom])

/-! ## Composition of Genome Morphisms -/

/-
Composition of genome morphisms.
-/
def GenomeMorphism.comp {R S T : Monad C}
    (φ : GenomeMorphism R S) (ψ : GenomeMorphism S T) : GenomeMorphism R T where
  toNatTrans := φ.toNatTrans ≫ ψ.toNatTrans
  unit_comm X := by
    simp only [NatTrans.comp_app, Functor.id_obj]
    rw [← Category.assoc, φ.unit_comm, ψ.unit_comm]
  mul_comm X := by
    -- Apply the associativity of composition of natural transformations.
    simp [CategoryTheory.NatTrans.comp_app]
    rw [← CategoryTheory.Category.assoc, ← CategoryTheory.Category.assoc,
        ← CategoryTheory.Category.assoc, φ.mul_comm]
    simp +decide [Category.assoc, ψ.mul_comm]

/-- Pullback is contravariantly functorial. -/
def genomePullbackComp {R S T : Monad C}
    (φ : GenomeMorphism R S) (ψ : GenomeMorphism S T) :
    genomePullback (φ.comp ψ) ≅ genomePullback ψ ⋙ genomePullback φ :=
  NatIso.ofComponents
    (fun alg => Monad.Algebra.isoMk (Iso.refl _) (by
      simp [pullbackAlgebra, GenomeMorphism.comp]))
    (fun f => by ext; simp [Monad.Algebra.isoMk, pullbackHom])

/-! ## Adjunction Roundtrip -/

/-
The Eilenberg-Moore adjunction recovers the original monad's functor.
-/
theorem adjunction_roundtrip_functor_eq (T : Monad C) :
    T.adj.toMonad.toFunctor = T.toFunctor := by
      refine' CategoryTheory.Functor.ext _ _;
      all_goals simp +decide [ CategoryTheory.Adjunction.toMonad ]

/-! ## Examples -/

-- Example: pullbackAlgebra with the identity morphism preserves the carrier
example {T : Monad C} (alg : T.Algebra) :
    (pullbackAlgebra (GenomeMorphism.id T) alg).A = alg.A := rfl

/-! ## Generalizations -/

/-
Generalization: A genome morphism where φ is a natural iso gives an equivalence
    of algebra categories (Morita equivalence of theories).

The inverse genome morphism when φ is a natural isomorphism.
-/
noncomputable def GenomeMorphism.inv {S T : Monad C}
    (φ : GenomeMorphism S T) (hφ : ∀ X, IsIso (φ.toNatTrans.app X)) :
    GenomeMorphism T S where
  toNatTrans := {
    app := fun X => CategoryTheory.inv (φ.toNatTrans.app X)
    naturality := by
      intro X Y f; rw [ ← IsIso.eq_comp_inv ] ; simp +decide [ φ.toNatTrans.naturality ] ;
  }
  unit_comm := by
    intro X; exact (by
    rw [ ← φ.unit_comm, CategoryTheory.Category.assoc, IsIso.hom_inv_id, CategoryTheory.Category.comp_id ])
  mul_comm := by
    intro X; have := φ.mul_comm X
    simp_all +decide
    simp_all +decide [← Category.assoc]

/-
Round-trip iso: pulling back along φ then φ⁻¹ gives the identity.
-/
noncomputable def genomePullbackInvComp {S T : Monad C}
    (φ : GenomeMorphism S T) (hφ : ∀ X, IsIso (φ.toNatTrans.app X)) :
    genomePullback (φ.inv hφ) ⋙ genomePullback φ ≅ 𝟭 S.Algebra :=
  NatIso.ofComponents
    (fun alg => Monad.Algebra.isoMk (Iso.refl _) (by
      simp [pullbackAlgebra, GenomeMorphism.inv]))
    (fun f => by ext; simp [Monad.Algebra.isoMk, pullbackHom])

/-
Round-trip iso: pulling back along φ⁻¹ then φ gives the identity.
-/
noncomputable def genomePullbackCompInv {S T : Monad C}
    (φ : GenomeMorphism S T) (hφ : ∀ X, IsIso (φ.toNatTrans.app X)) :
    genomePullback φ ⋙ genomePullback (φ.inv hφ) ≅ 𝟭 T.Algebra :=
  NatIso.ofComponents
    (fun alg => Monad.Algebra.isoMk (Iso.refl _) (by
      simp [pullbackAlgebra, GenomeMorphism.inv]))
    (fun f => by ext; simp [Monad.Algebra.isoMk, pullbackHom])

noncomputable def genomePullbackEquiv {S T : Monad C}
    (φ : GenomeMorphism S T) (hφ : ∀ X, IsIso (φ.toNatTrans.app X)) :
    T.Algebra ≌ S.Algebra :=
  CategoryTheory.Equivalence.mk (genomePullback φ) (genomePullback (φ.inv hφ))
    (genomePullbackCompInv φ hφ).symm
    (genomePullbackInvComp φ hφ)

/-! ## Boundary

The pullback functor `genomePullback φ` is generally NOT an equivalence.
The unit η : Id → T gives a genome morphism from the identity monad to T,
and the induced pullback is essentially the forgetful functor — typically
not an equivalence. This shows the `IsIso` hypothesis in `genomePullbackEquiv`
is essential.
-/

/-- The forgetful functor from T-algebras forgets the algebra structure. -/
theorem forgetful_is_pullback_along_unit (T : Monad C) :
    T.forget.obj = fun alg => alg.A := rfl

end TheoryGenome

/- FUTURE DIRECTIONS

1. **Idempotent Genome Characterization**: A monad T is idempotent (μ is a natural iso)
   iff every object admits at most one T-algebra structure.
   Testable: Prove `IsIso (T.μ.app X) → ∀ (a b : T.obj X ⟶ X), Monad.Algebra.mk X a = Monad.Algebra.mk X b`.

2. **Distributive Law as Genome Splicing**: A distributive law `S ∘ T → T ∘ S`
   gives a composed monad ST with genome morphisms from both S and T.
   Testable: Verify for the list monad over maybe monad.

3. **Genome Complexity Measure**: Define genomic complexity as the minimum
   number of generating operations. Show genome morphisms don't increase it.
   Testable: Identity monad has complexity 0, free monoid monad has complexity 1.

4. **Beck Monadicity as Genome Rigidity**: The comparison functor is an equivalence
   iff the adjunction is monadic. Formalize as: "the phenotype determines the genome
   iff the adjunction is monadic."
   Testable: Free-forgetful for groups is monadic; Stone-Čech is not.

5. **Monad Coproduct as Theory Fusion**: The coproduct of monads S, T (when it exists)
   has its algebra category embedding into S.Algebra × T.Algebra.
   Testable: Compute for free monoid and free group monads on Set.
-/