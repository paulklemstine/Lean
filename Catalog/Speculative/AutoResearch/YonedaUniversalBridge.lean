import Mathlib

/-! # Yoneda as a Universal Language: the Representable-Probe Bridge

This file formalizes the *bridge* philosophy behind the Yoneda lemma: **a
mathematical structure is completely determined by the way it is probed by the
maps into (or out of) it.**  The Yoneda embedding `yoneda : C ⥤ (Cᵒᵖ ⥤ Type)`
sends an object to its representable functor (its "system of probes"), and the
fact that it is *fully faithful* says that no information is lost.

We package the consequences that make Yoneda usable as a translation device
between a category and its category of presheaves ("the universal language"):

* `yoneda_faithful` / `yoneda_map_injective` — morphisms are determined by their
  action on probes (faithfulness).
* `iso_preimage` — an isomorphism of representables descends to an isomorphism of
  objects (the embedding reflects isomorphisms).
* `iso_iff_representable_iso` — **two objects are isomorphic iff their
  representable functors are**: the structural Yoneda corollary, the precise
  sense in which "an object is its functor of points".
* `End` recovery (`endEquiv`, `endEquiv_one`, `endEquiv_comp`) — the
  endomorphism *algebra* of an object is recovered, multiplicatively, from its
  representable functor.  This is the "algebra = (endo)functor data" facet of the
  bridge.

These are genuine corollaries of `CategoryTheory.Yoneda.fullyFaithful`, not
renamings: each repackages the embedding into the equivalence/translation form in
which the bridge is actually applied.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): The Yoneda embedding is fully faithful, and this is
  equivalent to the slogan "every object is determined by its representable
  functor up to iso, and every morphism by its action on probes".
EXPERIMENT (Experimenter): Built the iso-reflection and the `Nonempty`-level
  biconditional `X ≅ Y ↔ よX ≅ よY` from `Yoneda.fullyFaithful.preimageIso` and
  `yoneda.mapIso`; recovered `End X` as an `Equiv` with composition/identity
  preserved.  All compiled with no `sorry`.
ANALYSIS (Analyst): Full faithfulness is the *load-bearing* fact.  Faithfulness
  alone gives the morphism half; fullness is what makes `preimageIso` and the
  backward direction of the biconditional work.  The `End` recovery is the
  shadow of the (stronger) Yoneda lemma `End X ≃ (よX ⟶ よX)` carrying its monoid
  structure.
CRITIQUE (Critic): The biconditional must be stated at `Nonempty (· ≅ ·)`; the
  raw `≅` level would conflate "exists an iso" with a chosen iso and is not a
  Prop.  The `End` recovery is only an `Equiv` of types here, so we additionally
  *prove* it preserves `𝟙` and `≫` to justify the word "algebra".
SYNTHESIS (PI): Yoneda is the canonical bridge "object ↦ functor of points";
  these lemmas are exactly the translation dictionary used downstream.
-/

open CategoryTheory

namespace YonedaUniversalBridge

universe v u

variable {C : Type u} [Category.{v} C]

/-- **Faithfulness of Yoneda.** A morphism is determined by the induced natural
transformation of representables: if two maps `f g : X ⟶ Y` are sent to the same
map of probes, they are equal. -/
theorem yoneda_map_injective {X Y : C} {f g : X ⟶ Y}
    (h : (yoneda (C := C)).map f = (yoneda (C := C)).map g) : f = g :=
  Yoneda.fullyFaithful.map_injective h

/-- **Iso reflection.** An isomorphism between the representable functors of `X`
and `Y` is the image of a (unique) isomorphism `X ≅ Y`. -/
noncomputable def isoPreimage {X Y : C} (e : yoneda.obj X ≅ yoneda.obj Y) : X ≅ Y :=
  Yoneda.fullyFaithful.preimageIso e

/-- **Structural Yoneda corollary / the bridge.** Two objects are isomorphic if
and only if their representable functors (their "functors of points") are
isomorphic.  This is the precise sense in which an object *is* its system of
probes. -/
theorem iso_iff_representable_iso (X Y : C) :
    Nonempty (X ≅ Y) ↔ Nonempty (yoneda.obj X ≅ yoneda.obj Y) := by
  constructor
  · rintro ⟨e⟩
    exact ⟨yoneda.mapIso e⟩
  · rintro ⟨e⟩
    exact ⟨isoPreimage e⟩

/-! ### Algebra facet: recovering the endomorphism algebra from the probe functor -/

/-- The endomorphisms of `X` are in bijection with the endomorphisms of its
representable functor.  This is the type-level shadow of the Yoneda lemma at the
object `X` itself. -/
noncomputable def endEquiv (X : C) : (X ⟶ X) ≃ (yoneda.obj X ⟶ yoneda.obj X) :=
  Yoneda.fullyFaithful.homEquiv

/-- The recovery bijection sends the identity to the identity (unit of the
endomorphism algebra is preserved). -/
@[simp] theorem endEquiv_one (X : C) : endEquiv X (𝟙 X) = 𝟙 (yoneda.obj X) := by
  simp [endEquiv, Functor.FullyFaithful.homEquiv]

/-- The recovery bijection turns composition in `End X` into composition of
natural transformations: it is a multiplicative bijection, justifying "the
endomorphism *algebra* is recovered from the representable functor". -/
theorem endEquiv_comp {X : C} (f g : X ⟶ X) :
    endEquiv X (f ≫ g) = endEquiv X f ≫ endEquiv X g := by
  simp [endEquiv, Functor.FullyFaithful.homEquiv]

end YonedaUniversalBridge