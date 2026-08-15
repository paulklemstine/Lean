/-
# Eilenberg–MacLane 1-types: realization, Whitehead, and sharpness

This file deepens `Catalog/Bridges/FundamentalGroupCompleteInvariant.lean`, which
showed that a connected groupoid (the algebraic model of a `K(G,1)`) is determined
up to equivalence by the automorphism group of a basepoint.

Here we upgrade that *object-level* classification to a classification of **maps**,
and we prove the sharpness of the hypotheses:

* `realize` : every homomorphism of vertex groups is induced by an actual functor
  (i.e. `[K(G,1), K(H,1)] → Hom(G,H)` is surjective);
* `natIso_iff_conjugating_iso` and `realize_natIso_iff_conj` : two such maps are
  homotopic (naturally isomorphic) exactly when the induced homomorphisms are
  conjugate — the groupoid form of `[X, K(H,1)] ≃ Hom(π₁X, H)/conj`;
* `isEquivalence_of_bijective_mapAut` : the **Whitehead theorem for 1-types** — a
  map inducing an isomorphism on fundamental groups of connected groupoids is an
  equivalence, together with its converse;
* `connectedness_necessary` : connectedness cannot be dropped;
* `homotopyGroup_subsingleton_of_totallyDisconnected` and
  `allHomotopyGroups_equiv_not_homotopyEquiv` : a counterexample where **all**
  homotopy groups agree yet the spaces are not homotopy equivalent, strictly
  strengthening the `π₁`-only counterexample of the previous cycle.
-/
import Mathlib
import Bridges.FundamentalGroupCompleteInvariant
open CategoryTheory
open scoped ContinuousMap
open FundamentalGroupCompleteInvariant (ConnectedAt)

namespace FundamentalGroupK1

universe u v u' v'

/-! ## Automorphisms versus endomorphisms in a groupoid -/

/-- In a groupoid every endomorphism is invertible, so the endomorphism monoid of
an object is (isomorphic to) its automorphism group. -/
def autMulEquivEnd {C : Type u} [Groupoid.{v} C] (X : C) : Aut X ≃* End X where
  toFun f := f.hom
  invFun g := ⟨g, Groupoid.inv g, by simp, by simp⟩
  left_inv a := Iso.ext rfl
  right_inv g := rfl
  map_mul' _ _ := rfl

/-! ## Chosen paths in a connected groupoid -/

section BasePaths

variable {C : Type u} [Groupoid.{v} C] {c : C}

/-- A chosen isomorphism from the basepoint to each object of a connected
groupoid, normalised so that the basepoint receives the identity. -/
noncomputable def basePath (hC : ConnectedAt C c) (d : C) : c ≅ d :=
  open Classical in
  if h : c = d then eqToIso h else (hC d).some

@[simp] theorem basePath_self (hC : ConnectedAt C c) : basePath hC c = Iso.refl c := by
  simp [basePath]

/-- The loop at the basepoint determined by an arbitrary morphism, obtained by
conjugating with the chosen paths. -/
noncomputable def loopOf (hC : ConnectedAt C c) {X Y : C} (g : X ⟶ Y) : Aut c :=
  basePath hC X ≪≫ (Groupoid.isoEquivHom X Y).symm g ≪≫ (basePath hC Y).symm

@[simp] theorem loopOf_hom (hC : ConnectedAt C c) {X Y : C} (g : X ⟶ Y) :
    (loopOf hC g).hom = (basePath hC X).hom ≫ g ≫ (basePath hC Y).inv := rfl

@[simp] theorem loopOf_aut (hC : ConnectedAt C c) (a : Aut c) : loopOf hC a.hom = a := by
  simp only [loopOf, basePath_self]
  simpa using Equiv.symm_apply_apply (Groupoid.isoEquivHom c c) a

theorem loopOf_comp (hC : ConnectedAt C c) {X Y Z : C} (f : X ⟶ Y) (g : Y ⟶ Z) :
    loopOf hC (f ≫ g) = loopOf hC g * loopOf hC f := by
  simp only [loopOf]
  show _ = Iso.trans _ _
  simp [Groupoid.isoEquivHom, Iso.trans]

theorem loopOf_id (hC : ConnectedAt C c) (X : C) : loopOf hC (𝟙 X) = 1 := by
  simp only [loopOf]
  have h : (Groupoid.isoEquivHom X X).symm (𝟙 X) = Iso.refl X := Equiv.symm_apply_apply (Groupoid.isoEquivHom X X) (Iso.refl X)
  simp [h]
  rfl

end BasePaths

/-! ## Realizing group homomorphisms by maps of 1-types -/

section Realize

variable {C : Type u} [Groupoid.{v} C] {c : C} {D : Type u'} [Groupoid.{v'} D]

/-- The functor realizing a homomorphism `φ` of vertex groups: it collapses all
objects to `d₀` and sends a morphism to `φ` of its associated loop. -/
noncomputable def realize (hC : ConnectedAt C c) (d₀ : D) (φ : Aut c →* Aut d₀) : C ⥤ D where
  obj _ := d₀
  map g := (φ (loopOf hC g)).hom
  map_id X := by rw [loopOf_id, map_one]; rfl
  map_comp f g := by rw [loopOf_comp, map_mul]; rfl

@[simp] theorem realize_obj (hC : ConnectedAt C c) (d₀ : D) (φ : Aut c →* Aut d₀) (X : C) :
    (realize hC d₀ φ).obj X = d₀ := rfl

theorem realize_map_aut (hC : ConnectedAt C c) (d₀ : D) (φ : Aut c →* Aut d₀) (a : Aut c) :
    (realize hC d₀ φ).map a.hom = (φ a).hom := by
  unfold realize
  simp [loopOf_aut]

/-- **Realization theorem.**  Every homomorphism between the fundamental groups of
connected homotopy 1-types is induced by an actual map of 1-types.  Together with
`natIso_iff_conjugating_iso` this says that `[K(G,1), K(H,1)] ≃ Hom(G,H)/conj`. -/
theorem exists_functor_inducing (hC : ConnectedAt C c) (d₀ : D) (φ : Aut c →* Aut d₀) :
    ∃ (F : C ⥤ D) (e : F.obj c ≅ d₀), ∀ a : Aut c,
      Aut.autMulEquivOfIso e (F.mapAut c a) = φ a := by
  refine ⟨realize hC d₀ φ, Iso.refl d₀, fun a => ?_⟩
  ext
  simp [Aut.autMulEquivOfIso, Functor.mapAut]
  rw [realize_map_aut]

end Realize

/-! ## Homotopies of maps of 1-types are conjugations -/

section Homotopies

variable {C : Type u} [Groupoid.{v} C] {c : C} {D : Type u'} [Category.{v'} D]

/-- **Maps of connected 1-types are homotopic iff they are conjugate.**  A natural
isomorphism between two functors out of a connected groupoid is precisely an
isomorphism at the basepoint intertwining the two induced actions of the vertex
group. -/
theorem natIso_iff_conjugating_iso (hC : ConnectedAt C c) (F G : C ⥤ D) :
    Nonempty (F ≅ G) ↔
      ∃ h : F.obj c ≅ G.obj c, ∀ a : Aut c, F.map a.hom ≫ h.hom = h.hom ≫ G.map a.hom := by
  constructor
  · -- Forward direction: F ≅ G implies existence of conjugating isomorphism at basepoint
    rintro ⟨α⟩
    refine ⟨α.app c, ?_⟩
    intro a
    simp [CategoryTheory.NatTrans.naturality]
  · -- Backward direction: conjugating isomorphism gives natural isomorphism
    rintro ⟨h, h_prop⟩
    -- Choose paths from c to each object using connectedness
    let path : ∀ X : C, c ≅ X := fun X => (hC X).some
    -- Define the natural transformation component at X
    let α_app : ∀ X : C, F.obj X ⟶ G.obj X := fun X => F.map (path X).inv ≫ h.hom ≫ G.map (path X).hom
    -- Show this is well-defined (independent of path choice)
    have α_app_well_defined : ∀ X : C, ∀ p : c ≅ X, F.map p.inv ≫ h.hom ≫ G.map p.hom = α_app X := by
      intro X p
      let a : Aut c := p ≪≫ (path X).symm
      have hp : p = a ≪≫ path X := by simp [a]
      have hp_inv : p.inv = (path X).inv ≫ a.inv := by simp [a]
      have hp_hom : p.hom = a.hom ≫ (path X).hom := by simp [a]
      rw [hp_inv, hp_hom]
      rw [F.map_comp, G.map_comp]
      have ha : F.map a.hom ≫ h.hom = h.hom ≫ G.map a.hom := h_prop a
      have ha' : F.map a.inv ≫ h.hom = h.hom ≫ G.map a.inv := by
        have := h_prop a.symm
        simp at this
        exact this
      -- Goal: F.map (path X).inv ≫ F.map a.inv ≫ h.hom ≫ G.map a.hom ≫ G.map (path X).hom = α_app X
      -- Use ha' : F.map a.inv ≫ h.hom = h.hom ≫ G.map a.inv
      -- But the goal has F.map a.inv ≫ h.hom ≫ G.map a.hom
      simp_all only [α_app]
      have eq1 : (F.map (path X).inv ≫ F.map a.inv) ≫ h.hom ≫ G.map a.hom ≫ G.map (path X).hom =
                 F.map (path X).inv ≫ (F.map a.inv ≫ h.hom) ≫ G.map a.hom ≫ G.map (path X).hom := by simp [Category.assoc]
      rw [eq1, ha']
      simp [Category.assoc]
    -- Define the natural transformation
    let α : F ⟶ G := {
      app := α_app
      naturality := by
        intro X Y f
        simp only [α_app]
        -- Naturality: F.map f ≫ α_app Y = α_app X ≫ G.map f
        -- LHS: F.map f ≫ F.map (path Y).inv ≫ h.hom ≫ G.map (path Y).hom
        -- RHS: F.map (path X).inv ≫ h.hom ≫ G.map (path X).hom ≫ G.map f
        let a : Aut c := (path X) ≪≫ asIso f ≪≫ (path Y).symm
        -- Key equalities:
        -- f ≫ (path Y).inv = (path X).inv ≫ a.hom
        -- (path X).hom ≫ f = a.hom ≫ (path Y).hom
        have hf_inv : f ≫ (path Y).inv = (path X).inv ≫ a.hom := by simp [a]
        have hp_hom_f : (path X).hom ≫ f = a.hom ≫ (path Y).hom := by simp [a]
        -- Transform LHS
        calc F.map f ≫ F.map (path Y).inv ≫ h.hom ≫ G.map (path Y).hom
            = F.map (f ≫ (path Y).inv) ≫ h.hom ≫ G.map (path Y).hom := by simp [Category.assoc]
          _ = F.map ((path X).inv ≫ a.hom) ≫ h.hom ≫ G.map (path Y).hom := by rw [hf_inv]
          _ = F.map (path X).inv ≫ F.map a.hom ≫ h.hom ≫ G.map (path Y).hom := by simp [Category.assoc]
          _ = F.map (path X).inv ≫ (F.map a.hom ≫ h.hom) ≫ G.map (path Y).hom := by simp [Category.assoc]
          _ = F.map (path X).inv ≫ (h.hom ≫ G.map a.hom) ≫ G.map (path Y).hom := by rw [h_prop a]
          _ = F.map (path X).inv ≫ h.hom ≫ G.map a.hom ≫ G.map (path Y).hom := by simp [Category.assoc]
          _ = F.map (path X).inv ≫ h.hom ≫ G.map (a.hom ≫ (path Y).hom) := by rw [← G.map_comp]
          _ = F.map (path X).inv ≫ h.hom ≫ G.map ((path X).hom ≫ f) := by rw [hp_hom_f]
          _ = F.map (path X).inv ≫ h.hom ≫ G.map (path X).hom ≫ G.map f := by rw [G.map_comp]
          _ = α_app X ≫ G.map f := by simp [α_app]
    }
    let α_inv : ∀ X : C, G.obj X ⟶ F.obj X := fun X => G.map (path X).inv ≫ h.inv ≫ F.map (path X).hom
    let α_iso : F ≅ G := {
      hom := α
      inv := {
        app := α_inv
        naturality := by
          intro X Y f
          simp only [α_inv]
          -- Naturality: G.map f ≫ α_inv Y = α_inv X ≫ F.map f
          -- This follows from the same calculation as for α, using a.symm
          let a : Aut c := (path X) ≪≫ asIso f ≪≫ (path Y).symm
          have hf_inv : f ≫ (path Y).inv = (path X).inv ≫ a.hom := by simp [a]
          have hp_hom_f : (path X).hom ≫ f = a.hom ≫ (path Y).hom := by simp [a]
          -- Use h_prop on a.symm to get: F.map a.inv ≫ h.hom = h.hom ≫ G.map a.inv
          have h_symm := h_prop a.symm
          simp at h_symm
          -- h_symm : F.map a.inv ≫ h.hom = h.hom ≫ G.map a.inv
          -- We need: G.map f ≫ G.map (path Y).inv ≫ h.inv ≫ F.map (path Y).hom =
          --          G.map (path X).inv ≫ h.inv ≫ F.map (path X).hom ≫ F.map f
          -- Get the symmetric property for h.inv
          have h_symm' : G.map a.hom ≫ h.inv = h.inv ≫ F.map a.hom := by
            rw [← Category.id_comp (G.map a.hom ≫ h.inv)]
            rw [← h.inv_hom_id]
            rw [Category.assoc h.inv h.hom (G.map a.hom ≫ h.inv)]
            rw [← Category.assoc h.hom (G.map a.hom) h.inv, ← h_prop, Category.assoc, h.hom_inv_id, Category.comp_id]
          calc G.map f ≫ G.map (path Y).inv ≫ h.inv ≫ F.map (path Y).hom
              = G.map (f ≫ (path Y).inv) ≫ h.inv ≫ F.map (path Y).hom := by simp [Category.assoc]
            _ = G.map ((path X).inv ≫ a.hom) ≫ h.inv ≫ F.map (path Y).hom := by rw [hf_inv]
            _ = G.map (path X).inv ≫ G.map a.hom ≫ h.inv ≫ F.map (path Y).hom := by simp [Category.assoc]
            _ = G.map (path X).inv ≫ (G.map a.hom ≫ h.inv) ≫ F.map (path Y).hom := by simp [Category.assoc]
            _ = G.map (path X).inv ≫ (h.inv ≫ F.map a.hom) ≫ F.map (path Y).hom := by rw [h_symm']
            _ = G.map (path X).inv ≫ h.inv ≫ F.map a.hom ≫ F.map (path Y).hom := by simp [Category.assoc]
            _ = G.map (path X).inv ≫ h.inv ≫ F.map (a.hom ≫ (path Y).hom) := by rw [← F.map_comp]
            _ = G.map (path X).inv ≫ h.inv ≫ F.map ((path X).hom ≫ f) := by rw [hp_hom_f]
            _ = G.map (path X).inv ≫ h.inv ≫ F.map (path X).hom ≫ F.map f := by rw [F.map_comp]
            _ = (G.map (path X).inv ≫ h.inv ≫ F.map (path X).hom) ≫ F.map f := by simp [Category.assoc]
      }
      hom_inv_id := by
        ext X
        simp [NatTrans.comp_app, NatTrans.id_app]
        dsimp [α, α_inv, α_app]
        simp [Category.assoc]
      inv_hom_id := by
        ext X
        simp [NatTrans.comp_app, NatTrans.id_app]
        dsimp [α, α_inv, α_app]
        simp [Category.assoc]
    }
    exact ⟨α_iso⟩

end Homotopies

section Conjugacy

variable {C : Type u} [Groupoid.{v} C] {c : C} {D : Type u'} [Groupoid.{v'} D]

/-- Intertwining two automorphisms by a third is the same as conjugating them. -/
theorem aut_hom_comp_eq_iff {E : Type u'} [Category.{v'} E] {e₀ : E} (p q u : Aut e₀) :
    p.hom ≫ u.hom = u.hom ≫ q.hom ↔ q = u * p * u⁻¹ := by
  constructor
  · intro h
    have h2 : u * p = q * u := Iso.ext h
    have h3 := congrArg (fun z => z * u⁻¹) h2
    simpa [mul_assoc] using h3.symm
  · intro h
    subst h
    have h4 : u * p = u * p * u⁻¹ * u := by group
    exact congrArg Iso.hom h4

/-- **Classification of maps of 1-types up to homotopy.**  Two realizations of
homomorphisms `φ, ψ : π₁(C,c) → π₁(D,d₀)` are naturally isomorphic exactly when
`φ` and `ψ` are conjugate.  This is the groupoid model of
`[X, K(H,1)] ≃ Hom(π₁ X, H)/conjugation`. -/
theorem realize_natIso_iff_conj (hC : ConnectedAt C c) (d₀ : D) (φ ψ : Aut c →* Aut d₀) :
    Nonempty (realize hC d₀ φ ≅ realize hC d₀ ψ) ↔
      ∃ u : Aut d₀, ∀ a : Aut c, ψ a = u * φ a * u⁻¹ := by
  constructor
  · rintro ⟨α⟩
    refine ⟨α.app c, fun a => ?_⟩
    have naturality := α.hom.naturality a.hom
    simp only [realize_map_aut, realize_obj] at naturality
    have key := aut_hom_comp_eq_iff (φ a) (ψ a) (α.app c)
    have h : (φ a).hom ≫ (α.app c).hom = (α.app c).hom ≫ (ψ a).hom := by simpa using naturality
    exact key.mp h
  · rintro ⟨u, hu⟩
    rw [natIso_iff_conjugating_iso hC]
    refine ⟨u, fun a => ?_⟩
    dsimp [realize]
    rw [loopOf_aut hC]
    have hψ := hu a
    exact aut_hom_comp_eq_iff (φ a) (ψ a) u |>.mpr hψ

end Conjugacy

/-! ## The Whitehead theorem for 1-types -/

section Whitehead

variable {C : Type u} [Groupoid.{v} C] {c : C} {D : Type u'} [Groupoid.{v'} D]

theorem faithful_of_injective_mapAut (F : C ⥤ D) (hC : ConnectedAt C c)
    (hinj : Function.Injective (F.mapAut c)) : F.Faithful := by
  refine ⟨?_⟩
  intro X Y f g hfg
  have h_loops_eq : loopOf hC f = loopOf hC g := by
    apply hinj
    unfold Functor.mapAut
    apply Iso.ext
    simp [loopOf_hom, hfg]
  have h := congrArg (fun a : Aut c => (basePath hC X).inv ≫ a.hom ≫ (basePath hC Y).hom)
    h_loops_eq
  simp [loopOf_hom] at h
  exact h

theorem full_of_surjective_mapAut (F : C ⥤ D) (hC : ConnectedAt C c)
    (hsurj : Function.Surjective (F.mapAut c)) : F.Full := by
  constructor
  intro X Y f
  -- Construct the conjugated morphism at the basepoint
  let g : F.obj c ⟶ F.obj c := F.map (basePath hC X).hom ≫ f ≫ F.map (basePath hC Y).inv
  -- By surjectivity, get a preimage automorphism
  obtain ⟨b, hb⟩ := hsurj ⟨g, Groupoid.inv g, by simp [g], by simp [g]⟩
  -- Construct the preimage
  use (basePath hC X).inv ≫ b.hom ≫ (basePath hC Y).hom
  -- Verify: hb says F.mapAut c b = the automorphism with hom = g
  have hb' : F.map b.hom = g := by simpa using congr_arg (·.hom) hb
  have eq1 : (basePath hC X).inv ≫ (basePath hC X).hom = 𝟙 X := Iso.inv_hom_id (basePath hC X)
  have eq2 : (basePath hC Y).inv ≫ (basePath hC Y).hom = 𝟙 Y := Iso.inv_hom_id (basePath hC Y)
  rw [F.map_comp, F.map_comp, hb']
  unfold g
  simp

/-- **Whitehead theorem for homotopy 1-types.**  A map between connected homotopy
1-types which induces an isomorphism on fundamental groups is a homotopy
equivalence (an equivalence of groupoids). -/
theorem isEquivalence_of_bijective_mapAut (F : C ⥤ D) (hC : ConnectedAt C c)
    (hD : ConnectedAt D (F.obj c)) (hbij : Function.Bijective (F.mapAut c)) :
    F.IsEquivalence := by
  haveI : F.Faithful := faithful_of_injective_mapAut F hC hbij.injective
  haveI : F.Full := full_of_surjective_mapAut F hC hbij.surjective
  haveI : F.EssSurj := by
    refine ⟨ fun d => ?_ ⟩
    obtain ⟨iso⟩ := hD d
    exact ⟨c, ⟨iso⟩⟩
  exact ⟨inferInstance, inferInstance, inferInstance⟩

/-- Converse of the Whitehead theorem: an equivalence of groupoids induces an
isomorphism of vertex groups. -/
theorem bijective_mapAut_of_isEquivalence (F : C ⥤ D) [F.IsEquivalence] (c : C) :
    Function.Bijective (F.mapAut c) := by
  refine ⟨?_, ?_⟩
  · intro a b hab
    rw [Iso.ext_iff] at hab ⊢
    apply F.map_injective
    exact hab
  · intro b
    let equiv := F.asEquivalence
    haveI : equiv.functor.FullyFaithful := equiv.fullyFaithfulFunctor
    use equiv.fullyFaithfulFunctor.preimageIso (asIso b.hom)
    apply Iso.ext
    simp [Functor.mapAut]

end Whitehead

/-! ## Sharpness: connectedness cannot be dropped -/

section Sharpness

/-- Automorphism groups in a discrete groupoid are trivial. -/
theorem discrete_aut_subsingleton {α : Type} (X : Discrete α) : Subsingleton (Aut X) := by
  refine ⟨fun a b => ?_⟩
  exact Iso.ext (by cases a; cases b; exact Subsingleton.elim _ _)

/-- **Connectedness is necessary.**  The one-object groupoid `Discrete Unit` and
the two-object discrete groupoid `Discrete Bool` have isomorphic (trivial) vertex
groups at every basepoint, yet they are not equivalent: the second one is not
connected.  This is the algebraic shadow of the `Unit` versus `Bool`
counterexample for spaces. -/
theorem connectedness_necessary :
    Nonempty (Aut (⟨()⟩ : Discrete Unit) ≃* Aut (⟨false⟩ : Discrete Bool)) ∧
      ConnectedAt (Discrete Unit) ⟨()⟩ ∧
      ¬ ConnectedAt (Discrete Bool) ⟨false⟩ ∧
      ¬ Nonempty (Discrete Unit ≌ Discrete Bool) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · haveI : Subsingleton (Aut (⟨()⟩ : Discrete Unit)) := discrete_aut_subsingleton _
    haveI : Subsingleton (Aut (⟨false⟩ : Discrete Bool)) := discrete_aut_subsingleton _
    let f : Aut (⟨()⟩ : Discrete Unit) → Aut (⟨false⟩ : Discrete Bool) := fun _ => Iso.refl _
    let g : Aut (⟨false⟩ : Discrete Bool) → Aut (⟨()⟩ : Discrete Unit) := fun _ => Iso.refl _
    refine ⟨{ toFun := f, invFun := g, left_inv := fun x => Subsingleton.elim _ _, right_inv := fun x => Subsingleton.elim _ _, map_mul' := fun x y => Subsingleton.elim _ _ }⟩
  · intro d
    have heq : d.1 = () := by trivial
    exact ⟨eqToIso (Discrete.ext heq)⟩
  · intro h
    have := h ⟨true⟩
    obtain ⟨iso⟩ := this
    have heq : (⟨false⟩ : Discrete Bool) = ⟨true⟩ := Discrete.ext (Discrete.eq_of_hom iso.hom)
    exact Bool.noConfusion (Discrete.ext_iff.mp heq)
  · intro ⟨equiv⟩
    haveI : equiv.functor.IsEquivalence := equiv.isEquivalence_functor
    let F := equiv.functor
    let G := equiv.inverse
    -- F.obj ⟨()⟩ must be isomorphic to both ⟨true⟩ and ⟨false⟩
    -- In discrete category, this means ⟨true⟩ = ⟨false⟩
    have h := this.essSurj
    have ε := equiv.counitIso
    have η := equiv.unitIso
    -- η.app ⟨()⟩ : ⟨()⟩ ≅ F.obj (G.obj ⟨()⟩)
    -- G.obj ⟨()⟩ is some element of Bool, say b
    -- Then F.obj ⟨b⟩ ≅ ⟨()⟩
    -- Also ε.app ⟨¬b⟩ : G.obj (F.obj ⟨¬b⟩) ≅ ⟨¬b⟩
    -- But F.obj ⟨¬b⟩ = F.obj ⟨()⟩ (since () is the only element), so G.obj F.obj ⟨()⟩ ≅ ⟨¬b⟩
    -- Combined with F.obj (G.obj ⟨()⟩) ≅ ⟨()⟩, we get contradictions
    let X : Discrete Unit := ⟨()⟩
    let hb := F.obj X
    -- G.obj hb = X since Discrete Unit has only one object
    have hGhb : G.obj hb = X := Discrete.ext (by trivial)
    -- Let hb' be the other Bool element (negation of hb.1)
    let hb' : Discrete Bool := ⟨¬hb.1⟩
    -- G.obj hb' = X as well
    have hGhb' : G.obj hb' = X := Discrete.ext (by trivial)
    -- ε.app hb' : F.obj (G.obj hb') ≅ hb'
    have εhb' := ε.app hb'
    -- Need to rewrite G.obj hb' = X in εhb'
    have heq : equiv.functor.obj (equiv.inverse.obj hb') ≅ hb' := εhb'
    rw [hGhb'] at heq
    -- So F.obj X ≅ hb', i.e., hb ≅ hb'
    -- hb and hb' are different in Bool
    have heq'' : hb ≅ hb' := by exact heq
    have heq' : hb = hb' := Discrete.ext_iff.mpr (Discrete.eq_of_hom heq''.hom)
    -- hb' = ⟨¬hb.1⟩, so hb.1 = ¬hb.1, contradiction
    have h1 : hb.1 = (hb' : Discrete Bool).1 := by rw [heq']
    simp [hb'] at h1

end Sharpness

/-! ## Topological consequences -/

section Topology

variable {X Y : Type} [TopologicalSpace X] [TopologicalSpace Y]

/-- A path-connected space has a connected fundamental groupoid. -/
theorem fundamentalGroupoid_connectedAt [PathConnectedSpace X] (x : X) :
    ConnectedAt (FundamentalGroupoid X) ⟨x⟩ := by
  intro d
  cases d with
  | mk y =>
    haveI : ConnectedSpace X := PathConnectedSpace.connectedSpace
    let ps : PathConnectedSpace X := inferInstance
    have p := ps.2 x y
    show Nonempty (FundamentalGroupoid.mk x ≅ FundamentalGroupoid.mk y)
    refine ⟨Iso.mk (Quotient.mk _ p.some) (Quotient.mk _ p.some.symm) ?_ ?_⟩
    · -- goal: ⟦p.some⟧ ≫ ⟦p.some.symm⟧ = 𝟙 x
      apply Quotient.sound
      show Path.Homotopic ((p.some).trans p.some.symm) (Path.refl _)
      exact Path.Homotopic.trans_symm (X := X) _
    · apply Quotient.sound
      show Path.Homotopic ((p.some).symm.trans p.some) (Path.refl _)
      exact Path.Homotopic.symm_trans (X := X) _

/-- **Every homomorphism of fundamental groups of path-connected spaces is induced
by a map of the corresponding homotopy 1-types.** -/
theorem exists_fundamentalGroupoid_functor_inducing
    [PathConnectedSpace X] [PathConnectedSpace Y] (x : X) (y : Y)
    (φ : FundamentalGroup X x →* FundamentalGroup Y y) :
    ∃ (F : FundamentalGroupoid X ⥤ FundamentalGroupoid Y)
      (e : F.obj ⟨x⟩ ≅ (⟨y⟩ : FundamentalGroupoid Y)),
      ∀ a : FundamentalGroup X x,
        (autMulEquivEnd _) (Aut.autMulEquivOfIso e (F.mapAut ⟨x⟩ ((autMulEquivEnd _).symm a)))
          = φ a := by
  haveI hCx : ConnectedAt (FundamentalGroupoid X) ⟨x⟩ := fundamentalGroupoid_connectedAt x
  haveI hCy : ConnectedAt (FundamentalGroupoid Y) ⟨y⟩ := fundamentalGroupoid_connectedAt y
  -- FundamentalGroup is End, not Aut. Need to convert.
  let aeX := autMulEquivEnd (⟨x⟩ : FundamentalGroupoid X)
  let aeY := autMulEquivEnd (⟨y⟩ : FundamentalGroupoid Y)
  -- Convert φ to act on Aut instead of FundamentalGroup
  -- We need: Aut ⟨x⟩ →* Aut ⟨y⟩ = aeY.symm ∘ φ ∘ aeX
  let xObj : FundamentalGroupoid X := ⟨x⟩
  let yObj : FundamentalGroupoid Y := ⟨y⟩
  let φ' : Aut xObj →* Aut yObj := aeY.symm.toMonoidHom.comp (φ.comp aeX.toMonoidHom)
  obtain ⟨F, e, hF⟩ := exists_functor_inducing (C := FundamentalGroupoid X) (c := xObj) hCx (d₀ := yObj) (φ := φ')
  refine ⟨F, e, ?_⟩
  intro a
  -- aeX = autMulEquivEnd xObj and aeY = autMulEquivEnd yObj by definition
  -- φ' = aeY.symm ∘ φ ∘ aeX
  -- hF says: autMulEquivOfIso e (F.mapAut a') = φ' a' for all a' : Aut xObj
  -- We need: autMulEquivEnd yObj (autMulEquivOfIso e (F.mapAut (autMulEquivEnd xObj).symm a)) = φ a
  specialize hF ((autMulEquivEnd xObj).symm a)
  rw [hF]
  -- Now goal is: autMulEquivEnd yObj (φ' ((autMulEquivEnd xObj).symm a)) = φ a
  -- φ' = aeY.symm.toMonoidHom.comp (φ.comp aeX.toMonoidHom)
  -- So φ' ((autMulEquivEnd xObj).symm a) = aeY.symm (φ (aeX ((autMulEquivEnd xObj).symm a)))
  -- Since aeX = autMulEquivEnd xObj, aeX ((autMulEquivEnd xObj).symm a) = a
  -- So φ' ((autMulEquivEnd xObj).symm a) = aeY.symm (φ a)
  -- And autMulEquivEnd yObj (aeY.symm (φ a)) = φ a since aeY = autMulEquivEnd yObj
  rfl

/-- Path-connected spaces with isomorphic fundamental groups have equivalent
fundamental groupoids. -/
theorem fundamentalGroupoid_equivalence_of_mulEquiv
    [PathConnectedSpace X] [PathConnectedSpace Y] (x : X) (y : Y)
    (e : FundamentalGroup X x ≃* FundamentalGroup Y y) :
    Nonempty (FundamentalGroupoid X ≌ FundamentalGroupoid Y) := by
  -- Use the homomorphism e.toMonoidHom to get a functor
  have ⟨F, ι, hF⟩ := exists_fundamentalGroupoid_functor_inducing x y e.toMonoidHom
  -- Show F.mapAut is bijective
  have hbij : Function.Bijective (F.mapAut (FundamentalGroupoid.mk x)) := by
    -- From hF: α_y (ψ (φ (α_x.symm a))) = e a
    -- This means φ = ψ.symm ∘ α_y.symm ∘ e ∘ α_x, a composition of bijections
    let α_x := autMulEquivEnd (FundamentalGroupoid.mk x)
    let α_y := autMulEquivEnd (FundamentalGroupoid.mk y)
    let ψ := Aut.autMulEquivOfIso ι
    have h_eq : ∀ a : Aut (FundamentalGroupoid.mk x), ψ (F.mapAut (FundamentalGroupoid.mk x) a) = α_y.symm (e (α_x a)) := by
      intro a
      have := hF (α_x a)
      simp [α_x] at this
      rw [← this]
      simp [α_y, ψ]
    -- F.mapAut = ψ.symm ∘ α_y.symm ∘ e ∘ α_x
    have h_mapAut_eq : ∀ a : Aut (FundamentalGroupoid.mk x), F.mapAut (FundamentalGroupoid.mk x) a = ψ.symm (α_y.symm (e (α_x a))) := by
      intro a
      rw [← h_eq a]
      simp [ψ]
    rw [show F.mapAut (FundamentalGroupoid.mk x) = ψ.symm ∘ α_y.symm ∘ e ∘ α_x from funext h_mapAut_eq]
    exact Function.Bijective.comp (ψ.symm.bijective) (Function.Bijective.comp (α_y.symm.bijective) (Function.Bijective.comp e.bijective α_x.bijective))
  -- Now apply isEquivalence_of_bijective_mapAut
  have hC : ConnectedAt (FundamentalGroupoid X) (FundamentalGroupoid.mk x) := fundamentalGroupoid_connectedAt x
  have hD : ConnectedAt (FundamentalGroupoid Y) (F.obj (FundamentalGroupoid.mk x)) := by
    have hiso : F.obj (FundamentalGroupoid.mk x) ≅ FundamentalGroupoid.mk y := ι
    have hconn : ConnectedAt (FundamentalGroupoid Y) (FundamentalGroupoid.mk y) := fundamentalGroupoid_connectedAt y
    intro d
    exact ⟨hiso.trans (hconn d).some⟩
  letI := isEquivalence_of_bijective_mapAut F hC hD hbij
  exact ⟨F.asEquivalence⟩

/-! ### A counterexample where *all* homotopy groups agree -/

/-- All homotopy groups of a totally disconnected space are trivial: every
continuous map from the (connected) cube is constant. -/
theorem homotopyGroup_subsingleton_of_totallyDisconnected (N : Type) [Nonempty N]
    (Z : Type) [TopologicalSpace Z] [TotallyDisconnectedSpace Z] (z : Z) :
    Subsingleton (HomotopyGroup N Z z) := by
  -- Key fact: continuous maps from connected spaces to totally disconnected spaces are constant
  unfold HomotopyGroup
  -- Elements are quotients of GenLoop by Homotopic
  rw [Quotient.subsingleton_iff]
  -- Need to show: GenLoop.Homotopic.setoid N z = ⊤
  unfold GenLoop.Homotopic.setoid
  -- Goal: { r := GenLoop.Homotopic, iseqv := ⋯ } = ⊤
  -- Need to show the relation is top (all pairs related)
  rw [Setoid.ext_iff]
  intro a b
  simp
  unfold GenLoop.Homotopic
  -- Goal: (↑a).HomotopicRel (↑b) (Cube.boundary N)
  -- In a totally disconnected space, any continuous map from a connected space is constant.
  -- Since a and b are based at z, they must be constantly z.
  -- So a = b, and reflexivity gives the homotopy.
  have h : (↑a : (N → ↑unitInterval) → Z) = (↑b : (N → ↑unitInterval) → Z) := by
    -- Both are continuous maps from a connected space to a totally disconnected space
    -- So they're both constant, and agree at the basepoint, hence equal
    ext x
    -- Use the fact that connected subsets of totally disconnected spaces are singletons
    -- The image of the connected space (N → UnitInterval) under a continuous map is connected
    -- Hence it's a singleton, so a(x) = a(basepoint) = z = b(basepoint) = b(x)
    -- Need to show a x = a basepoint
    -- The image of a connected set under a continuous map to a totally disconnected space is a singleton
    -- a.property tells us a ∈ GenLoop N Z z
    -- This should give us continuity
    -- GenLoop is a set of ContinuousMap, so a coerced to ContinuousMap
    -- and we can get continuity from that
    have ha_cont : Continuous (a : (N → ↑unitInterval) → Z) := map_continuous a
    -- The lemma is likely: `IsPreconnected.subsingleton` for totally disconnected spaces
    have h_preconn : IsPreconnected (Set.range ((a : (N → ↑unitInterval) → Z))) := isPreconnected_range ha_cont
    have h_sub : (Set.range ((a : (N → ↑unitInterval) → Z))).Subsingleton := h_preconn.subsingleton
    -- a x and a basepoint are both in range, so equal
    have hx : a x ∈ Set.range (a : (N → ↑unitInterval) → Z) := Set.mem_range_self x
    -- Decompose a to see its structure
    cases a with
    | mk f hf =>
      cases b with
      | mk g hg =>
        -- Need to show f x = g x
        -- Both f and g are GenLoops based at z, so they're constantly z
        -- hf : f ∈ GenLoop N Z z
        -- hg : g ∈ GenLoop N Z z
        -- We have hf : ∀ y ∈ Cube.boundary N, f y = z
        -- We need a point in Cube.boundary N
        -- Construct a point in the boundary: all zeros
        let y0 : N → ↑unitInterval := fun _ => 0
        -- y0 = (fun _ => 0) is in the boundary because it's not in the interior
        -- Cube.interior = (fun _ => (0, 1)) in product topology
        have hy0 : y0 ∈ Cube.boundary N := by simp [Cube.boundary]; exact ⟨Classical.arbitrary N, Or.inl rfl⟩
        have hfy0 : f y0 = z := hf y0 hy0
        have hgy0 : g y0 = z := hg y0 hy0
        -- Both f x and g x equal z
        have hg_cont : Continuous g := map_continuous g
        have hg_preconn : IsPreconnected (Set.range g) := isPreconnected_range hg_cont
        have hg_sub : (Set.range g).Subsingleton := hg_preconn.subsingleton
        -- f x = f y0 = z and g x = g y0 = z
        have hfx : f x = f y0 := h_sub hx (Set.mem_range_self y0)
        have hgx : g x = g y0 := hg_sub (Set.mem_range_self x) (Set.mem_range_self y0)
        -- Therefore f x = z = g x
        simp [hfx, hfy0, hgx, hgy0]
  -- Now we have h : ⇑a = ⇑b, so they're trivially homotopic
  -- Use the constant homotopy at a
  -- The homotopy H(t, y) = a(y) for all t
  -- Need to construct a ContinuousMap.Homotopy a b
  -- The homotopy H(t, y) = a(y) for all t (constant in t)
  -- First, construct the underlying ContinuousMap
  let H : C(↑unitInterval × (N → ↑unitInterval), Z) := ContinuousMap.mk (fun p => a p.2) (map_continuous a |>.comp continuous_snd)
  -- Construct the homotopy
  let hom : ContinuousMap.Homotopy a b := ⟨H, fun x => rfl, fun x => h.symm ▸ rfl⟩
  -- Need to convert Homotopy to HomotopicRel
  -- HomotopicRel requires a homotopy that is fixed on the boundary
  -- But since a = b, any homotopy between them works
  refine ⟨hom, ?_⟩
  intro t x hx
  show hom.toFun (t, x) = a x
  -- hom.toFun = H, and H.toFun (t, x) = a x.2 = a x
  simp [hom, H]

/-- **A sharper counterexample.**  `Unit` and the discrete two-point space have
isomorphic homotopy groups in *every* degree, yet they are not homotopy
equivalent.  So no family of homotopy groups — not merely `π₁` — can be a
complete invariant without a connectivity hypothesis. -/
theorem allHomotopyGroups_equiv_not_homotopyEquiv :
    (∀ (N : Type) [Nonempty N],
        Nonempty (HomotopyGroup N Unit () ≃ HomotopyGroup N Bool false)) ∧
      ¬ Nonempty (Unit ≃ₕ Bool) := by
  constructor
  · -- All homotopy groups are trivial (subsingleton) for totally disconnected spaces
    intro N _
    have hUnit : Subsingleton (HomotopyGroup N Unit ()) :=
      homotopyGroup_subsingleton_of_totallyDisconnected N Unit ()
    have hBool : Subsingleton (HomotopyGroup N Bool false) :=
      homotopyGroup_subsingleton_of_totallyDisconnected N Bool false
    exact ⟨Equiv.mk (fun _ => default) (fun _ => default)
      (fun x => by simp [hUnit.elim x (default : HomotopyGroup N Unit ())])
      (fun x => by simp [hBool.elim x (default : HomotopyGroup N Bool false)])⟩
  · -- Unit and Bool are not homotopy equivalent (different num connected components)
    rintro ⟨e⟩
    have hb := FundamentalGroupCompleteInvariant.homotopyEquiv_bijective_of_totallyDisconnected e
    rcases Bool.eq_false_or_eq_true (e ()) with htrue | hfalse
    · obtain ⟨u, hu⟩ := hb.2 false
      simp [htrue] at hu
    · obtain ⟨u, hu⟩ := hb.2 true
      simp [hfalse] at hu

end Topology

/-! ## The classification bijection `[K(G,1), K(H,1)] ≃ Hom(G,H)/conj` -/

section Classification

variable {C : Type u} [Groupoid.{v} C] {c : C} {D : Type u'} [Groupoid.{v'} D] {d₀ : D}

/-- Conjugacy of homomorphisms is an equivalence relation. -/
theorem conj_equivalence (G : Type*) [Group G] (H : Type*) [Group H] :
    Equivalence (fun φ ψ : G →* H => ∃ u : H, ∀ a, ψ a = u * φ a * u⁻¹) := by
  refine ⟨?refl, ?symm, ?trans⟩
  · intro φ
    exact ⟨1, fun a => by simp⟩
  · intro φ ψ h
    obtain ⟨u, hu⟩ := h
    exact ⟨u⁻¹, fun a => by rw [hu a]; group⟩
  · intro φ ψ χ h1 h2
    obtain ⟨u, hu⟩ := h1
    obtain ⟨v, hv⟩ := h2
    refine ⟨v * u, fun a => ?_⟩
    rw [hv a, hu a]
    group

/-- Conjugacy of group homomorphisms, as a setoid. -/
def conjSetoid (G : Type*) [Group G] (H : Type*) [Group H] : Setoid (G →* H) where
  r φ ψ := ∃ u : H, ∀ a, ψ a = u * φ a * u⁻¹
  iseqv := conj_equivalence G H

/-- Natural isomorphism of functors, as a setoid.  Its quotient is the set of
homotopy classes of maps of 1-types. -/
def natIsoSetoid (C : Type u) [Category.{v} C] (D : Type u') [Category.{v'} D] :
    Setoid (C ⥤ D) where
  r F G := Nonempty (F ≅ G)
  iseqv := ⟨fun _ => ⟨Iso.refl _⟩, fun ⟨e⟩ => ⟨e.symm⟩, fun ⟨e⟩ ⟨f⟩ => ⟨e.trans f⟩⟩

/-- The homomorphism of vertex groups induced by a functor, transported along the
chosen path from `d₀` to the image of the basepoint. -/
noncomputable def inducedHom (hD : ConnectedAt D d₀) (F : C ⥤ D) (c : C) : Aut c →* Aut d₀ :=
  (Aut.autMulEquivOfIso (basePath hD (F.obj c)).symm).toMonoidHom.comp (F.mapAut c)

theorem inducedHom_realize (hC : ConnectedAt C c) (hD : ConnectedAt D d₀)
    (φ : Aut c →* Aut d₀) : inducedHom hD (realize hC d₀ φ) c = φ := by
  ext a
  simp [inducedHom, Aut.autMulEquivOfIso, Functor.mapAut, Functor.mapIso]
  rw [realize_map_aut]

theorem inducedHom_conj_of_natIso (hD : ConnectedAt D d₀) {F G : C ⥤ D} (e : F ≅ G) :
    ∃ u : Aut d₀, ∀ a : Aut c, inducedHom hD G c a = u * inducedHom hD F c a * u⁻¹ := by
  refine ⟨basePath hD (F.obj c) ≪≫ e.app c ≪≫ (basePath hD (G.obj c)).symm, ?_⟩
  intro a
  simp [inducedHom, Aut.autMulEquivOfIso, Functor.mapAut]
  ext : 1
  have naturality := e.hom.naturality a.hom
  conv_rhs => 
    rw [show (_ * _) = Iso.trans _ _ by rfl]
    rw [show (_ * _) = Iso.trans _ _ by rfl]
  have hinv : ∀ (x : Aut d₀), (x⁻¹).hom = x.inv := fun x => rfl
  simp [hinv]

theorem natIso_realize_inducedHom (hC : ConnectedAt C c) (hD : ConnectedAt D d₀) (F : C ⥤ D) :
    Nonempty (F ≅ realize hC d₀ (inducedHom hD F c)) := by
  rw [natIso_iff_conjugating_iso hC F (realize hC d₀ (inducedHom hD F c))]
  use (basePath hD (F.obj c)).symm
  intro a
  simp [inducedHom, realize, Aut.autMulEquivOfIso, Functor.mapAut]

/-- Passing from a homotopy class of maps to a conjugacy class of homomorphisms. -/
noncomputable def toConjClass (hD : ConnectedAt D d₀) (c : C) :
    Quotient (natIsoSetoid C D) → Quotient (conjSetoid (Aut c) (Aut d₀)) :=
  Quotient.map' (fun F => inducedHom hD F c)
    (by
      rintro F G ⟨e⟩
      exact inducedHom_conj_of_natIso hD e)

/-- Passing from a conjugacy class of homomorphisms to a homotopy class of maps. -/
noncomputable def ofConjClass (hC : ConnectedAt C c) (d₀ : D) :
    Quotient (conjSetoid (Aut c) (Aut d₀)) → Quotient (natIsoSetoid C D) :=
  Quotient.map' (fun φ => realize hC d₀ φ)
    (by
      rintro φ ψ h
      exact (realize_natIso_iff_conj hC d₀ φ ψ).2 h)

theorem ofConjClass_toConjClass (hC : ConnectedAt C c) (hD : ConnectedAt D d₀)
    (q : Quotient (natIsoSetoid C D)) : ofConjClass hC d₀ (toConjClass hD c q) = q := by
  induction q using Quotient.ind
  simp [ofConjClass, toConjClass]
  refine Quotient.sound ?_
  exact (natIso_realize_inducedHom hC hD ‹_›).map Iso.symm

theorem toConjClass_ofConjClass (hC : ConnectedAt C c) (hD : ConnectedAt D d₀)
    (q : Quotient (conjSetoid (Aut c) (Aut d₀))) : toConjClass hD c (ofConjClass hC d₀ q) = q := by
  rw [ofConjClass, toConjClass]
  -- Need to show: Quotient.map' (inducedHom hD · c) _ (Quotient.map' (realize hC d₀) _ q) = q
  -- The composition of maps is φ ↦ inducedHom hD (realize hC d₀ φ) c = φ
  induction q using Quotient.inductionOn with
  | _ φ =>
    simp [inducedHom_realize hC hD]

/-- **The classification bijection.**  For connected groupoids (models of `K(G,1)`
and `K(H,1)`), homotopy classes of maps correspond exactly to conjugacy classes of
homomorphisms of the fundamental groups:
`[K(G,1), K(H,1)] ≃ Hom(G,H)/conjugation`. -/
noncomputable def classificationEquiv (hC : ConnectedAt C c) (hD : ConnectedAt D d₀) :
    Quotient (natIsoSetoid C D) ≃ Quotient (conjSetoid (Aut c) (Aut d₀)) where
  toFun := toConjClass hD c
  invFun := ofConjClass hC d₀
  left_inv := ofConjClass_toConjClass hC hD
  right_inv := toConjClass_ofConjClass hC hD

end Classification

end FundamentalGroupK1