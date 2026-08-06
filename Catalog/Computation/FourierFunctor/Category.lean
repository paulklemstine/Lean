import Mathlib

/-!
# The category `FinAb` of finite abelian groups and the Pontryagin dual functor

This file sets up the categorical infrastructure needed to state and prove that
Fourier analysis is *functorial*:

* `FinAb` — the category of finite abelian groups (an induced category of
  `AddCommGrpCat`, so that morphisms are honest additive group homomorphisms and
  the concrete-category API applies);
* `dualHom` — the dual of an additive homomorphism, `ψ ↦ ψ ∘ f`;
* `dualFunctor : FinAbᵒᵖ ⥤ FinAb` — the **Pontryagin dual functor**
  `G ↦ Ĝ = AddChar G ℂ`, together with a proof that it is a genuine functor
  (`map_id`, `map_comp`).

Everything below `dualFunctor` is contravariant duality; the double dual and the
resulting equivalence of categories are in `Duality.lean`, the Fourier transform
as a natural transformation is in `Transform.lean`, and the uncertainty
principle is in `Uncertainty.lean`.

-- !-- Lab Notes -- !--

* Hypothesizer: the entire Pontryagin package for *finite* abelian groups should
  be expressible as an honest equivalence of categories `FinAb ≌ FinAbᵒᵖ`, with
  the Fourier transform an honest natural isomorphism of functors into `Mod_ℂ`.
* Experimenter: the first design (a bespoke `structure FinAb` with
  `Hom G H := G →+ H`) failed: `DFunLike` coercions could not see through the
  `Quiver.Hom` projection, so `f x` did not elaborate.  Using
  `InducedCategory _ FinAb.toAddCommGrp` (the pattern used by `FiniteGrp` in
  mathlib) fixes this and gives `ConcreteCategory FinAb (· →+ ·)` for free.
* Analyst: the "hard" content is not the category theory but the two
  orthogonality relations for characters; the category theory is exactly the
  bookkeeping that makes those relations *natural*.
* Critic: `FinAb` is deliberately restricted to `Type 0` groups; this keeps the
  double-dual construction size-correct (`AddChar G ℂ` for `G : Type 0` is again
  in `Type 0`).
-/

universe u

open CategoryTheory AddChar

namespace FourierFunctor

/-- The category of finite abelian groups: a bundled abelian group together with
a finiteness hypothesis.  Morphisms are the morphisms of `AddCommGrpCat`, i.e.
additive group homomorphisms. -/
structure FinAb where
  /-- the underlying bundled abelian group -/
  toAddCommGrp : AddCommGrpCat.{0}
  [isFinite : Finite toAddCommGrp]

attribute [instance] FinAb.isFinite

namespace FinAb

instance : CoeSort FinAb Type where coe G := G.toAddCommGrp

instance : Category FinAb :=
  inferInstanceAs (Category (InducedCategory _ FinAb.toAddCommGrp))

instance : ConcreteCategory FinAb (· →+ ·) :=
  InducedCategory.concreteCategory FinAb.toAddCommGrp

instance (G : FinAb) : AddCommGroup G := inferInstanceAs (AddCommGroup G.toAddCommGrp)

instance (G : FinAb) : Finite G := G.isFinite

noncomputable instance (G : FinAb) : Fintype G := Fintype.ofFinite _

/-- Build an object of `FinAb` from a finite abelian group. -/
def of (G : Type) [AddCommGroup G] [Finite G] : FinAb := ⟨AddCommGrpCat.of G⟩

@[simp] lemma coe_of (G : Type) [AddCommGroup G] [Finite G] : (of G : Type) = G := rfl

/-- The underlying type of an object of `FinAb`, as a plain abbreviation (useful
where the `(G : Type)` ascription would be parsed as a dependent function
type). -/
abbrev carrier (G : FinAb) : Type := G

/-- The additive homomorphism underlying a morphism of `FinAb`. -/
abbrev hom {G H : FinAb} (f : G ⟶ H) : (G : Type) →+ (H : Type) :=
  ConcreteCategory.hom (C := FinAb) f

/-- The morphism of `FinAb` attached to an additive homomorphism. -/
abbrev ofHom {G H : FinAb} (f : (G : Type) →+ (H : Type)) : G ⟶ H :=
  ConcreteCategory.ofHom (C := FinAb) f

@[simp] lemma hom_ofHom {G H : FinAb} (f : (G : Type) →+ (H : Type)) : hom (ofHom f) = f := rfl

@[simp] lemma hom_id (G : FinAb) : hom (𝟙 G) = AddMonoidHom.id (G : Type) := rfl

@[simp] lemma hom_comp {G H K : FinAb} (f : G ⟶ H) (g : H ⟶ K) :
    hom (f ≫ g) = (hom g).comp (hom f) := rfl

end FinAb

/-! ### The dual of a homomorphism -/

/-- The **dual homomorphism** `Ĥ →+ Ĝ` of `f : G →+ H`: a character of `H` is
pulled back to a character of `G`. -/
def dualHom {G H : Type} [AddCommGroup G] [AddCommGroup H] (f : G →+ H) :
    AddChar H ℂ →+ AddChar G ℂ where
  toFun ψ := ψ.compAddMonoidHom f
  map_zero' := by ext x; simp [AddChar.compAddMonoidHom]
  map_add' ψ χ := by ext x; simp [AddChar.compAddMonoidHom]

@[simp] lemma dualHom_apply {G H : Type} [AddCommGroup G] [AddCommGroup H] (f : G →+ H)
    (ψ : AddChar H ℂ) (x : G) : dualHom f ψ x = ψ (f x) := rfl

lemma dualHom_id (G : Type) [AddCommGroup G] :
    dualHom (AddMonoidHom.id G) = AddMonoidHom.id (AddChar G ℂ) :=
  AddMonoidHom.ext fun _ => AddChar.ext _ _ fun _ => rfl

lemma dualHom_comp {G H K : Type} [AddCommGroup G] [AddCommGroup H] [AddCommGroup K]
    (f : G →+ H) (g : H →+ K) :
    dualHom (g.comp f) = (dualHom f).comp (dualHom g) :=
  AddMonoidHom.ext fun _ => AddChar.ext _ _ fun _ => rfl

/-- Characters separate points: this is the injectivity half of Pontryagin
duality, imported from mathlib's `AddChar.doubleDualEmb_injective`. -/
lemma dualHom_injective_of_surjective {G H : Type} [AddCommGroup G] [AddCommGroup H]
    (f : G →+ H) (hf : Function.Surjective f) :
    Function.Injective (dualHom f) := by
  intro ψ χ h
  refine AddChar.ext _ _ fun y => ?_
  obtain ⟨x, rfl⟩ := hf y
  exact congrArg (fun (θ : AddChar G ℂ) => θ x) h

/-! ### The Pontryagin dual functor -/

/-- The **Pontryagin dual functor** `FinAbᵒᵖ ⥤ FinAb`, `G ↦ Ĝ = AddChar G ℂ`. -/
noncomputable def dualFunctor : FinAbᵒᵖ ⥤ FinAb where
  obj X := FinAb.of (AddChar (X.unop : Type) ℂ)
  map {X Y} f := FinAb.ofHom (dualHom (FinAb.hom f.unop))
  map_id X := by
    ext ψ
    simp only [ConcreteCategory.hom_ofHom]
    exact AddChar.ext _ _ fun x => rfl
  map_comp f g := by
    ext ψ
    simp only [ConcreteCategory.hom_ofHom]
    exact AddChar.ext _ _ fun x => rfl

@[simp] lemma dualFunctor_obj (X : FinAbᵒᵖ) :
    (dualFunctor.obj X : Type) = AddChar (X.unop : Type) ℂ := rfl

@[simp] lemma dualFunctor_map_apply {X Y : FinAbᵒᵖ} (f : X ⟶ Y)
    (ψ : AddChar (X.unop : Type) ℂ) (x : (Y.unop : Type)) :
    (show AddChar (Y.unop : Type) ℂ from FinAb.hom (dualFunctor.map f) ψ) x
      = ψ (FinAb.hom f.unop x) := rfl

/-- A character of a finite group never vanishes (its values are unit complex
numbers). -/
lemma addChar_apply_ne_zero {G : Type} [AddCommGroup G] [Finite G] (ψ : AddChar G ℂ) (x : G) :
    ψ x ≠ 0 := by
  intro h0
  have h1 : ‖ψ x‖ = 1 := ψ.norm_apply x
  rw [h0] at h1
  simp at h1

/-- The dual functor is **faithful**: two homomorphisms inducing the same map on
characters are equal.  This is the separation-of-points half of Pontryagin
duality. -/
theorem dualFunctor_map_injective {X Y : FinAbᵒᵖ} :
    Function.Injective (dualFunctor.map (X := X) (Y := Y)) := by
  intro f g h
  have key : ∀ x : (Y.unop : Type), FinAb.hom f.unop x = FinAb.hom g.unop x := by
    intro x
    have hforall : ∀ ψ : AddChar (X.unop : Type) ℂ,
        ψ (FinAb.hom f.unop x - FinAb.hom g.unop x) = 1 := by
      intro ψ
      have h2 : ψ (FinAb.hom f.unop x) = ψ (FinAb.hom g.unop x) := by
        have := congrArg (fun (u : dualFunctor.obj X ⟶ dualFunctor.obj Y) =>
          (show AddChar (Y.unop : Type) ℂ from FinAb.hom u ψ) x) h
        simpa using this
      rw [AddChar.map_sub_eq_div, h2, div_self (addChar_apply_ne_zero ψ _)]
    exact sub_eq_zero.1 (AddChar.forall_apply_eq_zero.1 hforall)
  have hfg : f.unop = g.unop := by
    ext x
    exact key x
  exact Quiver.Hom.unop_inj hfg

instance : dualFunctor.Faithful where
  map_injective h := dualFunctor_map_injective h

end FourierFunctor