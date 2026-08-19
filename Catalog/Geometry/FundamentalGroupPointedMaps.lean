/-
# Pointed maps of homotopy 1-types: the classification is *strict*

`Catalog/Bridges/FundamentalGroupK1Classification.lean` classifies unpointed homotopy
classes of maps of connected 1-types,

  `[K(G,1), K(H,1)] ≃ Hom(G,H)/conjugation`   (`classificationEquiv`),

and `Catalog/Bridges/FundamentalGroupK1Deepening.lean` shows this bijection is compatible
with composition only *up to conjugation* (`inducedHom_comp_conj`): the comparison 2-cells
are the obstruction recorded as conjecture **N1** of `FUTURE_DIRECTIONS.md`.

This file proves that the ambiguity disappears once basepoints are remembered, which is the
first half of conjecture **N3**:

* `intertwinerNatIso` — the technical heart, a strengthening of `natIso_iff_conjugating_iso`:
  a homotopy between maps out of a connected 1-type can always be chosen with a *prescribed*
  value at the basepoint;
* `PtdMap` — a pointed map of 1-types (a functor plus a path from the image of the source
  basepoint to the target basepoint) and `PtdHomotopic`, the relation of pointed homotopy;
* `ptdHom` — the induced homomorphism of fundamental groups, with **no** choice involved;
* `ptdClassificationEquiv` — **the pointed classification**
  `[(K(G,1),*), (K(H,1),*)]_* ≃ Hom(G,H)`, an unquotiented bijection;
* `ptdHom_id`, `ptdHom_comp` — the pointed classification is a *strict* functor: the
  homomorphism induced by a composite is exactly (not merely up to conjugacy) the composite
  of the induced homomorphisms, and the identity induces the identity.

So the pointed homotopy category of connected 1-types is isomorphic, on hom-sets, to the
category of groups; all coherence data of N1 can be chosen trivially after basepoints are
fixed.
-/
import Mathlib
import Bridges.FundamentalGroupK1Deepening

open CategoryTheory
open FundamentalGroupCompleteInvariant (ConnectedAt)
open FundamentalGroupK1

namespace FundamentalGroupPointed

universe v u v' u' v'' u''

/-! ## Homotopies with a prescribed value at the basepoint -/

section Intertwiner

variable {C : Type u} [Groupoid.{v} C] {c : C} {D : Type u'} [Groupoid.{v'} D]

/-- **A homotopy with prescribed value at the basepoint.**  Given an isomorphism `h` at the
basepoint intertwining the two induced actions of the vertex group, there is a natural
isomorphism whose component at the basepoint is exactly `h`.  This refines
`natIso_iff_conjugating_iso`, which only produces *some* natural isomorphism. -/
noncomputable def intertwinerNatIso (hC : ConnectedAt C c) {F G : C ⥤ D}
    (h : F.obj c ≅ G.obj c)
    (hint : ∀ a : Aut c, F.map a.hom ≫ h.hom = h.hom ≫ G.map a.hom) : F ≅ G :=
  NatIso.ofComponents
    (fun X => (F.mapIso (basePath hC X)).symm ≪≫ h ≪≫ G.mapIso (basePath hC X))
    (by
      intro X Y f
      have ha := hint (loopOf hC f)
      rw [loopOf_hom] at ha
      simp only [Iso.trans_hom, Iso.symm_hom, Functor.mapIso_inv, Functor.mapIso_hom,
        Category.assoc]
      have h1 : F.map f ≫ F.map (basePath hC Y).inv
          = F.map (basePath hC X).inv ≫
              F.map ((basePath hC X).hom ≫ f ≫ (basePath hC Y).inv) := by
        rw [← F.map_comp, ← F.map_comp]
        congr 1
        simp
      have h2 : G.map ((basePath hC X).hom ≫ f ≫ (basePath hC Y).inv) ≫
            G.map (basePath hC Y).hom
          = G.map (basePath hC X).hom ≫ G.map f := by
        rw [← G.map_comp, ← G.map_comp]
        congr 1
        simp
      calc F.map f ≫ F.map (basePath hC Y).inv ≫ h.hom ≫ G.map (basePath hC Y).hom
          = (F.map f ≫ F.map (basePath hC Y).inv) ≫ h.hom ≫ G.map (basePath hC Y).hom := by
            simp
        _ = F.map (basePath hC X).inv ≫ (F.map ((basePath hC X).hom ≫ f ≫ (basePath hC Y).inv)
              ≫ h.hom) ≫ G.map (basePath hC Y).hom := by rw [h1]; simp
        _ = F.map (basePath hC X).inv ≫
              (h.hom ≫ G.map ((basePath hC X).hom ≫ f ≫ (basePath hC Y).inv))
              ≫ G.map (basePath hC Y).hom := by rw [ha]
        _ = F.map (basePath hC X).inv ≫ h.hom ≫ G.map (basePath hC X).hom ≫ G.map f := by
            rw [Category.assoc, h2])

@[simp] theorem intertwinerNatIso_app (hC : ConnectedAt C c) {F G : C ⥤ D}
    (h : F.obj c ≅ G.obj c)
    (hint : ∀ a : Aut c, F.map a.hom ≫ h.hom = h.hom ≫ G.map a.hom) :
    (intertwinerNatIso hC h hint).hom.app c = h.hom := by
  simp [intertwinerNatIso]

end Intertwiner

/-! ## Pointed maps of 1-types -/

/-- A **pointed map** of 1-types: a functor together with a chosen path (isomorphism) from
the image of the source basepoint to the target basepoint. -/
structure PtdMap (C : Type u) [Groupoid.{v} C] (c : C)
    (D : Type u') [Groupoid.{v'} D] (d : D) where
  /-- The underlying map of 1-types. -/
  functor : C ⥤ D
  /-- The chosen path identifying the image of the basepoint with the basepoint. -/
  path : functor.obj c ≅ d

namespace PtdMap

variable {C : Type u} [Groupoid.{v} C] {c : C} {D : Type u'} [Groupoid.{v'} D] {d : D}

/-- The homomorphism of fundamental groups induced by a pointed map.  Unlike the unpointed
`inducedHom`, no choice of path is involved. -/
def ptdHom (P : PtdMap C c D d) : Aut c →* Aut d :=
  (Aut.autMulEquivOfIso P.path).toMonoidHom.comp (P.functor.mapAut c)

theorem ptdHom_hom (P : PtdMap C c D d) (a : Aut c) :
    (P.ptdHom a).hom = P.path.inv ≫ P.functor.map a.hom ≫ P.path.hom := rfl

/-- **Pointed homotopy**: a natural isomorphism compatible with the chosen paths. -/
def PtdHomotopic (P Q : PtdMap C c D d) : Prop :=
  ∃ α : P.functor ≅ Q.functor, α.hom.app c ≫ Q.path.hom = P.path.hom

theorem PtdHomotopic.refl (P : PtdMap C c D d) : PtdHomotopic P P :=
  ⟨Iso.refl _, by simp⟩

theorem PtdHomotopic.symm {P Q : PtdMap C c D d} (h : PtdHomotopic P Q) : PtdHomotopic Q P := by
  obtain ⟨α, hα⟩ := h
  refine ⟨α.symm, ?_⟩
  rw [← hα]
  simp

theorem PtdHomotopic.trans {P Q R : PtdMap C c D d} (h : PtdHomotopic P Q)
    (h' : PtdHomotopic Q R) : PtdHomotopic P R := by
  obtain ⟨α, hα⟩ := h
  obtain ⟨β, hβ⟩ := h'
  refine ⟨α ≪≫ β, ?_⟩
  rw [← hα, ← hβ]
  simp

/-- Pointed homotopy is an equivalence relation; the quotient is the set of pointed homotopy
classes of maps `(C,c) → (D,d)`. -/
def ptdSetoid (C : Type u) [Groupoid.{v} C] (c : C)
    (D : Type u') [Groupoid.{v'} D] (d : D) : Setoid (PtdMap C c D d) where
  r := PtdHomotopic
  iseqv := ⟨PtdHomotopic.refl, PtdHomotopic.symm, PtdHomotopic.trans⟩

/-- **Pointed homotopies do not change the induced homomorphism** — not even up to
conjugation. -/
theorem ptdHom_congr {P Q : PtdMap C c D d} (h : PtdHomotopic P Q) : P.ptdHom = Q.ptdHom := by
  obtain ⟨α, hα⟩ := h
  have hinv : P.path.inv = Q.path.inv ≫ α.inv.app c := by
    apply Iso.inv_ext
    rw [← hα]
    simp
  ext a
  rw [ptdHom_hom, ptdHom_hom, hinv, ← hα]
  have hnat : P.functor.map a.hom ≫ α.hom.app c = α.hom.app c ≫ Q.functor.map a.hom :=
    α.hom.naturality a.hom
  simp only [Category.assoc]
  rw [← Category.assoc (P.functor.map a.hom), hnat]
  simp

/-- **Conversely, the induced homomorphism is a complete invariant of the pointed homotopy
class** (for a connected source). -/
theorem ptdHomotopic_of_ptdHom_eq (hC : ConnectedAt C c) {P Q : PtdMap C c D d}
    (h : P.ptdHom = Q.ptdHom) : PtdHomotopic P Q := by
  have key : ∀ a : Aut c,
      P.functor.map a.hom ≫ (P.path ≪≫ Q.path.symm).hom
        = (P.path ≪≫ Q.path.symm).hom ≫ Q.functor.map a.hom := by
    intro a
    have ha : P.path.inv ≫ P.functor.map a.hom ≫ P.path.hom
        = Q.path.inv ≫ Q.functor.map a.hom ≫ Q.path.hom := by
      rw [← ptdHom_hom, ← ptdHom_hom, h]
    have ha' : P.functor.map a.hom ≫ P.path.hom
        = P.path.hom ≫ Q.path.inv ≫ Q.functor.map a.hom ≫ Q.path.hom := by
      rw [← ha]
      simp
    simp only [Iso.trans_hom, Iso.symm_hom]
    rw [← Category.assoc, ha']
    simp
  refine ⟨intertwinerNatIso hC (P.path ≪≫ Q.path.symm) key, ?_⟩
  rw [intertwinerNatIso_app]
  simp

end PtdMap

/-! ## The pointed classification -/

section Classification

open PtdMap

variable {C : Type u} [Groupoid.{v} C] {c : C} {D : Type u'} [Groupoid.{v'} D]

/-- The canonical pointed realization of a homomorphism of fundamental groups. -/
noncomputable def ptdRealize (hC : ConnectedAt C c) (d : D) (φ : Aut c →* Aut d) :
    PtdMap C c D d :=
  ⟨realize hC d φ, Iso.refl d⟩

@[simp] theorem ptdHom_ptdRealize (hC : ConnectedAt C c) (d : D) (φ : Aut c →* Aut d) :
    (ptdRealize hC d φ).ptdHom = φ := by
  ext a
  rw [ptdHom_hom]
  show 𝟙 d ≫ (realize hC d φ).map a.hom ≫ 𝟙 d = (φ a).hom
  rw [realize_map_aut]
  simp

/-- **The pointed classification of maps of 1-types.**  Pointed homotopy classes of pointed
maps `(K(G,1),*) → (K(H,1),*)` are in bijection with `Hom(G,H)` itself — no quotient by
conjugation.  Compare `classificationEquiv`, where the unpointed classes are only in
bijection with `Hom(G,H)/conj`. -/
noncomputable def ptdClassificationEquiv (hC : ConnectedAt C c) (d : D) :
    Quotient (ptdSetoid C c D d) ≃ (Aut c →* Aut d) where
  toFun := Quotient.lift PtdMap.ptdHom fun _ _ h => ptdHom_congr h
  invFun φ := Quotient.mk _ (ptdRealize hC d φ)
  left_inv x := by
    induction x using Quotient.ind with
    | _ P =>
      refine Quotient.sound (ptdHomotopic_of_ptdHom_eq hC ?_).symm
      exact (ptdHom_ptdRealize hC d P.ptdHom).symm
  right_inv φ := ptdHom_ptdRealize hC d φ

@[simp] theorem ptdClassificationEquiv_mk (hC : ConnectedAt C c) (d : D)
    (P : PtdMap C c D d) :
    ptdClassificationEquiv hC d (Quotient.mk _ P) = P.ptdHom := rfl

end Classification

/-! ## Strict functoriality of the pointed classification -/

namespace PtdMap

variable {C : Type u} [Groupoid.{v} C] {c : C} {D : Type u'} [Groupoid.{v'} D] {d : D}
  {E : Type u''} [Groupoid.{v''} E] {e : E}

/-- The identity pointed map. -/
def id (C : Type u) [Groupoid.{v} C] (c : C) : PtdMap C c C c := ⟨𝟭 C, Iso.refl c⟩

/-- Composition of pointed maps. -/
def comp (P : PtdMap C c D d) (Q : PtdMap D d E e) : PtdMap C c E e :=
  ⟨P.functor ⋙ Q.functor, Q.functor.mapIso P.path ≪≫ Q.path⟩

/-- **The identity map induces the identity homomorphism.**  Compare `inducedHom_id`. -/
@[simp] theorem ptdHom_id : (PtdMap.id C c).ptdHom = MonoidHom.id (Aut c) := by
  ext a
  rw [ptdHom_hom]
  show 𝟙 c ≫ a.hom ≫ 𝟙 c = a.hom
  simp

/-- **The pointed classification is strictly functorial**: the homomorphism induced by a
composite of pointed maps is *equal* to the composite of the induced homomorphisms.  This is
the pointed refinement of `inducedHom_comp_conj`, where the corresponding statement holds
only up to conjugation. -/
theorem ptdHom_comp (P : PtdMap C c D d) (Q : PtdMap D d E e) :
    (P.comp Q).ptdHom = Q.ptdHom.comp P.ptdHom := by
  ext a
  rw [ptdHom_hom]
  show (Q.functor.mapIso P.path ≪≫ Q.path).inv ≫ Q.functor.map (P.functor.map a.hom) ≫
      (Q.functor.mapIso P.path ≪≫ Q.path).hom = _
  rw [MonoidHom.comp_apply, ptdHom_hom, ptdHom_hom]
  simp only [Iso.trans_hom, Iso.trans_inv, Functor.mapIso_hom, Functor.mapIso_inv,
    Q.functor.map_comp, Category.assoc]

/-- Composition of pointed maps is compatible with pointed homotopy, so it descends to
pointed homotopy classes. -/
theorem PtdHomotopic.comp {P P' : PtdMap C c D d} {Q Q' : PtdMap D d E e}
    (h : PtdHomotopic P P') (h' : PtdHomotopic Q Q') :
    PtdHomotopic (P.comp Q) (P'.comp Q') := by
  obtain ⟨α, hα⟩ := h
  obtain ⟨β, hβ⟩ := h'
  refine ⟨Functor.isoWhiskerRight α Q.functor ≪≫ Functor.isoWhiskerLeft P'.functor β, ?_⟩
  show (Q.functor.map (α.hom.app c) ≫ β.hom.app (P'.functor.obj c)) ≫
      (Q'.functor.mapIso P'.path ≪≫ Q'.path).hom = (Q.functor.mapIso P.path ≪≫ Q.path).hom
  have hnat : β.hom.app (P'.functor.obj c) ≫ Q'.functor.map P'.path.hom
      = Q.functor.map P'.path.hom ≫ β.hom.app d := (β.hom.naturality P'.path.hom).symm
  simp only [Iso.trans_hom, Functor.mapIso_hom, Category.assoc]
  rw [← Category.assoc (β.hom.app (P'.functor.obj c)), hnat, Category.assoc, hβ,
    ← Category.assoc, ← Q.functor.map_comp, hα]

/-- Composition of pointed homotopy classes. -/
def compClasses : Quotient (ptdSetoid C c D d) → Quotient (ptdSetoid D d E e) →
    Quotient (ptdSetoid C c E e) :=
  Quotient.map₂ PtdMap.comp fun _ _ h _ _ h' => PtdHomotopic.comp h h'

/-- **Functoriality of the pointed classification bijection.**  Under
`ptdClassificationEquiv`, composition of pointed homotopy classes corresponds exactly to
composition of homomorphisms. -/
theorem ptdClassificationEquiv_compClasses (hC : ConnectedAt C c) (hD : ConnectedAt D d)
    (x : Quotient (ptdSetoid C c D d)) (y : Quotient (ptdSetoid D d E e)) :
    ptdClassificationEquiv hC e (compClasses x y)
      = (ptdClassificationEquiv hD e y).comp (ptdClassificationEquiv hC d x) := by
  induction x using Quotient.ind with
  | _ P =>
    induction y using Quotient.ind with
    | _ Q => exact ptdHom_comp P Q

end PtdMap

end FundamentalGroupPointed