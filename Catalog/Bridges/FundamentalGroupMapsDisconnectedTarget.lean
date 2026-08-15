/-
# Maps from a `K(G,1)` into an arbitrary 1-type

`Catalog/Bridges/FundamentalGroupK1Classification.lean` classifies homotopy classes of maps
`[K(G,1), K(H,1)] ≃ Hom(G,H)/conj` for a **connected** target.  This file removes the
connectedness hypothesis on the target.

A map out of a connected 1-type lands in a single connected component of the target, so
`[K(G,1), D]` fibres over `π₀ D`; the main theorem computes each fibre:

  `fibreEquiv : {f ∈ [K(G,1), D] : f lands in the component of d₀} ≃ Hom(G, π₁(D,d₀))/conj`

(`fibreEquiv`).  In words: **a map from `K(G,1)` to an arbitrary 1-type is the same thing as
a choice of connected component of the target together with a conjugacy class of
homomorphisms into the fundamental group of that component.**

The technical heart is a version of the induced homomorphism `inducedHomOf` that depends on
a *chosen path* from the basepoint of the target to the image of the basepoint, rather than
on connectedness of the target; changing that path conjugates the homomorphism
(`inducedHomOf_conj_of_natIso`).
-/
import Mathlib
import Bridges.FundamentalGroupK1Classification
import Bridges.FundamentalGroupK1Deepening
open CategoryTheory
open FundamentalGroupCompleteInvariant (ConnectedAt)
open FundamentalGroupK1
open FundamentalGroupK1Deep (Components isoSetoid)

namespace FundamentalGroupMapsDisc

universe u v u' v'

variable {C : Type u} [Groupoid.{v} C] {c : C} {D : Type u'} [Groupoid.{v'} D] {d₀ : D}

/-! ## The component of the image of the basepoint -/

/-- The connected component of the target in which a map from a connected 1-type lands. -/
def toComponent (c : C) : Quotient (natIsoSetoid C D) → Components D :=
  Quotient.map' (fun F : C ⥤ D => F.obj c)
    (by
      rintro F G ⟨e⟩
      exact ⟨e.app c⟩)

@[simp] theorem toComponent_mk (F : C ⥤ D) :
    toComponent c (Quotient.mk (natIsoSetoid C D) F) =
      Quotient.mk (isoSetoid D) (F.obj c) := rfl

/-! ## Induced homomorphisms along a chosen path -/

/-- The homomorphism of fundamental groups induced by a map `F`, transported along a chosen
path `e : d₀ ≅ F.obj c` in the target.  No connectedness of the target is needed. -/
def inducedHomOf (F : C ⥤ D) (c : C) {d₀ : D} (e : d₀ ≅ F.obj c) : Aut c →* Aut d₀ :=
  (Aut.autMulEquivOfIso e.symm).toMonoidHom.comp (F.mapAut c)

theorem inducedHomOf_hom (F : C ⥤ D) (c : C) (e : d₀ ≅ F.obj c) (a : Aut c) :
    (inducedHomOf F c e a).hom = e.hom ≫ F.map a.hom ≫ e.inv := rfl

/-- The homomorphism induced by the canonical realization of `φ`, along the identity path,
is `φ` itself. -/
theorem inducedHomOf_realize (hC : ConnectedAt C c) (d₀ : D) (φ : Aut c →* Aut d₀) :
    inducedHomOf (realize hC d₀ φ) c (Iso.refl d₀) = φ := by
  ext a
  rw [inducedHomOf_hom]
  simpa using realize_map_aut hC d₀ φ a

/-- **Changing the map by a homotopy, or changing the chosen path, conjugates the induced
homomorphism.** -/
theorem inducedHomOf_conj_of_natIso {F G : C ⥤ D} (α : F ≅ G) (e : d₀ ≅ F.obj c)
    (e' : d₀ ≅ G.obj c) :
    ∃ u : Aut d₀, ∀ a : Aut c, inducedHomOf G c e' a = u * inducedHomOf F c e a * u⁻¹ := by
  refine ⟨e ≪≫ α.app c ≪≫ e'.symm, fun a => ?_⟩
  ext
  have naturality := α.hom.naturality a.hom
  simp only [Aut.Aut_mul_def, Aut.Aut_inv_def, Iso.trans_hom, Iso.symm_hom, Iso.trans_inv,
    Iso.symm_inv, Category.assoc, inducedHomOf_hom]
  simp only [← Category.assoc]
  simp only [Category.assoc, Iso.inv_hom_id, Category.comp_id]
  have h2 : (α.app c).hom ≫ G.map a.hom = F.map a.hom ≫ (α.app c).hom := naturality.symm
  rw [← reassoc_of% h2]
  simp

/-- Every map out of a connected 1-type is homotopic to the canonical realization of its
induced homomorphism. -/
theorem natIso_realize_inducedHomOf (hC : ConnectedAt C c) (F : C ⥤ D) (e : d₀ ≅ F.obj c) :
    Nonempty (F ≅ realize hC d₀ (inducedHomOf F c e)) := by
  rw [natIso_iff_conjugating_iso hC F (realize hC d₀ (inducedHomOf F c e))]
  refine ⟨e.symm, fun a => ?_⟩
  show F.map a.hom ≫ e.inv = e.inv ≫ (realize hC d₀ (inducedHomOf F c e)).map a.hom
  rw [realize_map_aut hC d₀ (inducedHomOf F c e) a, inducedHomOf_hom]
  simp

/-! ## The fibres of `[K(G,1), D] → π₀ D` -/

/-- Choice of a path from `d₀` to the image of the basepoint, available whenever the map
lands in the component of `d₀`. -/
noncomputable def chosenPath {F : C ⥤ D} {d₀ : D}
    (h : Quotient.mk (isoSetoid D) (F.obj c) = Quotient.mk (isoSetoid D) d₀) : d₀ ≅ F.obj c :=
  (Quotient.exact h).some.symm

/-- The induced homomorphism computed from the canonical representative of a homotopy
class agrees, up to conjugacy, with the one computed from any representative and any
chosen path. -/
theorem inducedHomOf_out_eq (F : C ⥤ D) (e : d₀ ≅ F.obj c)
    (h : Quotient.mk (isoSetoid D)
        ((Quotient.out (Quotient.mk (natIsoSetoid C D) F)).obj c) =
      Quotient.mk (isoSetoid D) d₀) :
    Quotient.mk (conjSetoid (Aut c) (Aut d₀))
        (inducedHomOf (Quotient.out (Quotient.mk (natIsoSetoid C D) F)) c (chosenPath h))
      = Quotient.mk (conjSetoid (Aut c) (Aut d₀)) (inducedHomOf F c e) := by
  have hrel : (natIsoSetoid C D).r (Quotient.out (Quotient.mk (natIsoSetoid C D) F)) F :=
    Quotient.exact (Quotient.out_eq (Quotient.mk (natIsoSetoid C D) F))
  obtain ⟨α⟩ := hrel
  exact Quotient.sound (inducedHomOf_conj_of_natIso α _ e)

/-- **Classification of maps from a `K(G,1)` into an arbitrary 1-type.**  The homotopy
classes of maps landing in the connected component of `d₀` are exactly the conjugacy classes
of homomorphisms `π₁(C,c) → π₁(D,d₀)`. -/
noncomputable def fibreEquiv (hC : ConnectedAt C c) (d₀ : D) :
    {q : Quotient (natIsoSetoid C D) // toComponent c q = Quotient.mk (isoSetoid D) d₀} ≃
      Quotient (conjSetoid (Aut c) (Aut d₀)) where
  toFun q :=
    Quotient.mk (conjSetoid (Aut c) (Aut d₀))
      (inducedHomOf (Quotient.out q.1) c
        (chosenPath (c := c) (by
          have h := q.2
          rw [← Quotient.out_eq q.1] at h
          exact h)))
  invFun cls :=
    ⟨Quotient.map' (fun φ => realize hC d₀ φ)
        (by
          rintro φ ψ h
          exact (realize_natIso_iff_conj hC d₀ φ ψ).2 h) cls,
      by induction cls using Quotient.ind; rfl⟩
  left_inv q := by
    apply Subtype.ext
    have hout : Quotient.mk (natIsoSetoid C D) (Quotient.out q.1) = q.1 := Quotient.out_eq q.1
    rw [← hout]
    exact Quotient.sound ((natIso_realize_inducedHomOf hC _ _).map Iso.symm)
  right_inv cls := by
    induction cls using Quotient.ind with
    | _ φ =>
      show Quotient.mk (conjSetoid (Aut c) (Aut d₀))
          (inducedHomOf (Quotient.out (Quotient.mk (natIsoSetoid C D) (realize hC d₀ φ))) c
            (chosenPath _)) = _
      rw [inducedHomOf_out_eq (realize hC d₀ φ) (Iso.refl d₀), inducedHomOf_realize]

/-- **Maps out of a connected 1-type see only one component.**  Two homotopic maps land in
the same component, and the component together with the conjugacy class of the induced
homomorphism is a complete invariant of the homotopy class. -/
theorem natIso_iff_component_and_conj (hC : ConnectedAt C c) (F G : C ⥤ D)
    (eF : d₀ ≅ F.obj c) (eG : d₀ ≅ G.obj c) :
    Nonempty (F ≅ G) ↔
      Quotient.mk (conjSetoid (Aut c) (Aut d₀)) (inducedHomOf F c eF) =
        Quotient.mk (conjSetoid (Aut c) (Aut d₀)) (inducedHomOf G c eG) := by
  constructor
  · rintro ⟨α⟩
    exact Quotient.sound (inducedHomOf_conj_of_natIso α eF eG)
  · intro h
    obtain ⟨FF⟩ := natIso_realize_inducedHomOf hC F eF
    obtain ⟨GG⟩ := natIso_realize_inducedHomOf hC G eG
    obtain ⟨w⟩ := (realize_natIso_iff_conj hC d₀ (inducedHomOf F c eF)
      (inducedHomOf G c eG)).2 (Quotient.exact h)
    exact ⟨FF.trans (w.trans GG.symm)⟩

end FundamentalGroupMapsDisc