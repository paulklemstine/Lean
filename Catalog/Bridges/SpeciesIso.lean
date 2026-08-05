/-
# Isomorphism of species

Species are functors; the right notion of sameness is a *natural isomorphism*.  This
file defines isomorphism of species, shows that it induces a natural isomorphism of the
associated functors on the core groupoid of `Type`, and proves that all the invariants
built so far (labelled counts, exponential generating series, unlabelled counts) only
depend on the isomorphism class.

We then exhibit the basic isomorphisms making species into a commutative semiring up to
isomorphism: commutativity of the sum and of the product, the unit law `F · 1 ≅ F`, and
distributivity `F · (G + H) ≅ F·G + F·H`.
-/
import Bridges.SpeciesUnlabelled

noncomputable section

namespace SpeciesEGF

open scoped BigOperators
open PowerSeries CategoryTheory

namespace Species

/-- An isomorphism of species: a bijection of structure sets, natural in the
underlying set. -/
structure Iso (F G : Species) where
  /-- The underlying bijection on structure sets. -/
  hom : ∀ A : Type, F.obj A ≃ G.obj A
  naturality : ∀ {A B : Type} (e : A ≃ B) (x : F.obj A),
      hom B (F.map e x) = G.map e (hom A x)

@[inherit_doc] infixr:25 " ≃ₛ " => Iso

namespace Iso

variable {F G H : Species}

/-- The identity isomorphism. -/
def refl (F : Species) : F ≃ₛ F where
  hom _ := Equiv.refl _
  naturality _ _ := rfl

/-- The inverse of an isomorphism of species. -/
def symm (φ : F ≃ₛ G) : G ≃ₛ F where
  hom A := (φ.hom A).symm
  naturality {A B} e x := by
    apply (φ.hom B).injective
    rw [Equiv.apply_symm_apply, φ.naturality, Equiv.apply_symm_apply]

/-- Composition of isomorphisms of species. -/
def trans (φ : F ≃ₛ G) (ψ : G ≃ₛ H) : F ≃ₛ H where
  hom A := (φ.hom A).trans (ψ.hom A)
  naturality e x := by
    simp only [Equiv.trans_apply]
    rw [φ.naturality, ψ.naturality]

/-- Isomorphic species have the same number of structures on each finite set. -/
theorem card_eq (φ : F ≃ₛ G) (n : ℕ) : F.card n = G.card n :=
  Nat.card_congr (φ.hom (Fin n))

/-- Isomorphic species have the same exponential generating series. -/
theorem egf_eq (φ : F ≃ₛ G) : F.egf = G.egf :=
  (egf_eq_iff F G).2 φ.card_eq

/-- An isomorphism of species is equivariant for the transport actions of `Sym(n)`. -/
theorem smul_hom (φ : F ≃ₛ G) {n : ℕ} (σ : Equiv.Perm (Fin n)) (x : F.obj (Fin n)) :
    φ.hom (Fin n) (σ • x) = σ • φ.hom (Fin n) x := φ.naturality σ x

/-- Isomorphic species have the same number of unlabelled structures. -/
theorem unlabelled_eq (φ : F ≃ₛ G) (n : ℕ) : F.unlabelled n = G.unlabelled n := by
  refine Nat.card_congr (Quotient.congr (φ.hom (Fin n)) ?_)
  intro x y
  constructor
  · rintro ⟨σ, hσ⟩
    refine ⟨σ, ?_⟩
    show σ • φ.hom (Fin n) y = φ.hom (Fin n) x
    rw [← φ.smul_hom]
    exact congrArg _ hσ
  · rintro ⟨σ, hσ⟩
    refine ⟨σ, (φ.hom (Fin n)).injective ?_⟩
    rw [φ.smul_hom]
    exact hσ

/-- An isomorphism of species is precisely a natural isomorphism of the corresponding
functors on the core groupoid of `Type`. -/
def toNatIso (φ : F ≃ₛ G) : F.toFunctor ≅ G.toFunctor :=
  NatIso.ofComponents (fun A => Equiv.toIso (φ.hom A.of))
    (fun {A B} f => by
      funext x
      exact φ.naturality f.iso.toEquiv x)

/-- Conversely, a natural isomorphism of the associated functors is an isomorphism of
species. -/
def ofNatIso {F G : Species} (α : F.toFunctor ≅ G.toFunctor) : F ≃ₛ G where
  hom A := (α.app (Core.mk A)).toEquiv
  naturality {A B} e x := by
    have h := congrFun (α.hom.naturality (X := Core.mk A) (Y := Core.mk B)
      (CoreHom.mk (Equiv.toIso e))) x
    exact h

end Iso

/-! ## The semiring structure of species, up to isomorphism -/

/-- The sum of species is commutative up to isomorphism. -/
def addComm (F G : Species) : (F.add G) ≃ₛ (G.add F) where
  hom _ := Equiv.sumComm _ _
  naturality e x := by cases x <;> rfl

/-- Distributivity of the product over the sum, up to isomorphism. -/
def mulAdd (F G H : Species) : (F.mul (G.add H)) ≃ₛ ((F.mul G).add (F.mul H)) where
  hom A :=
    (Equiv.sigmaCongr (Equiv.refl (A → Bool))
      (fun _ => Equiv.prodSumDistrib _ _ _)).trans
      (Equiv.sigmaSumDistrib _ _)
  naturality := by
    rintro A B e ⟨p, u, w | w⟩ <;> rfl


/-- Associativity of the sum of species. -/
def addAssoc (F G H : Species) : ((F.add G).add H) ≃ₛ (F.add (G.add H)) where
  hom _ := Equiv.sumAssoc _ _ _
  naturality := by rintro A B e (( x | x ) | x) <;> rfl

/-- The empty species is a unit for the sum. -/
def addZero (F : Species) : (F.add zero) ≃ₛ F where
  hom A :=
    { toFun := fun x =>
        match (show F.obj A ⊕ Empty from x) with
        | Sum.inl y => y
        | Sum.inr y => Empty.elim y
      invFun := Sum.inl
      left_inv := by
        rintro (x | x)
        · rfl
        · exact Empty.elim (show Empty from x)
      right_inv := fun _ => rfl }
  naturality := by
    rintro A B e (x | x)
    · rfl
    · exact Empty.elim (show Empty from x)

/-- The empty species absorbs products. -/
def mulZero (F : Species) : (F.mul zero) ≃ₛ zero where
  hom _ :=
    { toFun := fun x => Empty.elim (show Empty from x.2.2)
      invFun := fun x => Empty.elim (show Empty from x)
      left_inv := fun x => Empty.elim (show Empty from x.2.2)
      right_inv := fun x => Empty.elim (show Empty from x) }
  naturality := by
    rintro A B e ⟨p, u, v⟩
    exact Empty.elim (show Empty from v)

/-- The derivative is additive. -/
def derivAdd (F G : Species) : ((F.add G).deriv) ≃ₛ (F.deriv.add G.deriv) where
  hom _ := Equiv.refl _
  naturality := by rintro A B e (x | x) <;> rfl

end Species

end SpeciesEGF