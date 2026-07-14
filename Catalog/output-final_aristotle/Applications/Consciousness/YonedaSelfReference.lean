import Mathlib

/-! # Consciousness and the Yoneda Lemma: Identity as a Web of Self-Presentation

Where `LawvereFixedPoint.lean` models consciousness as the *fixed point* of a
self-modeling function, this file develops the complementary Yoneda-theoretic
reading: **a system's identity is nothing but the totality of how it is modeled
by — and how it models — everything else.**

The **Yoneda embedding** `yoneda : C ⥤ (Cᵒᵖ ⥤ Type)` sends each object `X` to its
*presheaf of self-presentation* `yoneda.obj X = Hom(-, X)`: the complete record
of all ways every object of the category maps into `X`.  The Yoneda lemma says
this record is a *perfect* encoding — the object is fully and faithfully
recoverable from it.  Read as a philosophy of mind: a conscious system *is* its
relational profile; there is no residue beyond the web of relationships.

## Main results

* `identity_from_presentation` : if two systems have isomorphic self-presentations
  then the systems themselves are isomorphic.  Identity is determined by the
  relational web (Yoneda reflects isomorphisms).
* `presentation_determines_map` : morphisms are in bijection with natural
  transformations of presentations — a change of the system corresponds to a
  unique change of its web, and conversely.
* `self_transformation_correspondence` : the **monoid** of a system's internal
  self-transformations `End X` is isomorphic (as a monoid) to the monoid of
  transformations of its total self-presentation `End (yoneda.obj X)`.  The
  "inner life" and the "outer web" are the same strange loop.
* `yoneda_self_observation` : the Yoneda lemma proper — an observation of the
  self-presentation of `X` by any observer `F` is exactly an `F`-element located
  at `X`.  In particular the self-observations `End (yoneda.obj X)` are exactly
  the internal endomorphisms `X ⟶ X`.
* `presentation_reflects_iso` / `presentation_faithful` : the embedding is fully
  faithful, so no information about the system is lost or invented in passing to
  its presentation.
-/

namespace Consciousness.Yoneda

open CategoryTheory

universe v u

variable {C : Type u} [Category.{v} C]

/-- **Identity from self-presentation.**  If the self-presentations
`Hom(-, X)` and `Hom(-, Y)` are isomorphic as presheaves, then the systems `X`
and `Y` are themselves isomorphic.  A system is determined, up to isomorphism, by
its relational web.  (This is the isomorphism-reflecting half of Yoneda.) -/
noncomputable def identity_from_presentation {X Y : C}
    (h : yoneda.obj X ≅ yoneda.obj Y) : X ≅ Y :=
  Yoneda.fullyFaithful.preimageIso h

/-- Conversely, isomorphic systems have isomorphic self-presentations: passing to
the relational web is functorial. -/
def presentation_of_identity {X Y : C} (h : X ≅ Y) :
    yoneda.obj X ≅ yoneda.obj Y :=
  yoneda.mapIso h

/-- The round trip `presentation → identity → presentation` recovers the original
presentation isomorphism: no information is added or lost. -/
theorem presentation_roundtrip {X Y : C} (h : yoneda.obj X ≅ yoneda.obj Y) :
    presentation_of_identity (identity_from_presentation h) = h := by
  apply Iso.ext
  exact Yoneda.fullyFaithful.map_preimage h.hom

/-- **Presentation is faithful.**  Distinct internal transformations of a system
induce distinct transformations of its self-presentation: the web cannot conflate
two genuinely different self-maps. -/
theorem presentation_faithful {X Y : C} :
    Function.Injective (yoneda.map : (X ⟶ Y) → (yoneda.obj X ⟶ yoneda.obj Y)) :=
  yoneda.map_injective

/-- **Presentation is full.**  Every natural transformation between
self-presentations arises from a (unique) internal morphism.  Nothing in the web
is "extra" — every relational transformation is realized inside the system. -/
theorem presentation_full {X Y : C}
    (τ : yoneda.obj X ⟶ yoneda.obj Y) : ∃ f : X ⟶ Y, yoneda.map f = τ :=
  ⟨Yoneda.fullyFaithful.preimage τ, Yoneda.fullyFaithful.map_preimage τ⟩

/-- **Morphisms ≃ presentation transformations.**  A bijection between internal
morphisms `X ⟶ Y` and natural transformations of self-presentations. -/
noncomputable def presentation_determines_map {X Y : C} :
    (X ⟶ Y) ≃ (yoneda.obj X ⟶ yoneda.obj Y) :=
  Yoneda.fullyFaithful.homEquiv

/-- **The strange loop of self-transformation.**  The monoid `End X` of a
system's internal self-transformations is isomorphic *as a monoid* to
`End (yoneda.obj X)`, the transformations of its total self-presentation.  The
system's inner dynamics and the dynamics of its relational web are one and the
same algebraic object — a precise sense in which self-reference "closes the
loop". -/
noncomputable def self_transformation_correspondence (X : C) :
    End X ≃* End (yoneda.obj X) :=
  Yoneda.fullyFaithful.mulEquivEnd X

/-- The self-transformation correspondence is compatible with composition and
identities (it is a monoid isomorphism), spelled out. -/
theorem self_transformation_hom (X : C) (f g : End X) :
    self_transformation_correspondence X (f * g)
      = self_transformation_correspondence X f
        * self_transformation_correspondence X g :=
  map_mul _ _ _

theorem self_transformation_one (X : C) :
    self_transformation_correspondence X 1 = 1 :=
  map_one _

/-- **Yoneda self-observation.**  The Yoneda lemma: an observation of the
self-presentation of `X` by an arbitrary observer presheaf `F` is exactly an
`F`-element situated at `X`.  Consciousness "seen from `F`" is a datum located in
the system. -/
noncomputable def yoneda_self_observation (X : C) (F : Cᵒᵖ ⥤ Type v) :
    (yoneda.obj X ⟶ F) ≃ F.obj (Opposite.op X) :=
  yonedaEquiv

/-- Specializing the Yoneda lemma to `F = yoneda.obj X`: the *self-observations*
of the presentation of `X` are exactly the internal endomorphisms of `X`.  This
is the Yoneda incarnation of "a system that models itself modeling itself". -/
noncomputable def self_observation_are_endomorphisms (X : C) :
    (yoneda.obj X ⟶ yoneda.obj X) ≃ (X ⟶ X) :=
  yonedaEquiv

end Consciousness.Yoneda