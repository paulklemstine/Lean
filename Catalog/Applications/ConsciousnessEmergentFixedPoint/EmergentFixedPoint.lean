import Mathlib

/-!
# Consciousness as an Emergent Fixed Point

This file isolates a mathematically precise core of the hypothesis.  A system
`A` with observations in `B` carries a self-model `encode : A → (A → B)`.
Completeness means that every possible observation is represented by a state.
Diagonal evaluation then turns completeness into a *uniform fixed-point
operator*: every transformation of observations has a canonically selected
stable value.

The central theorem is Lawvere's fixed-point argument in the Cartesian closed
category of types.  Its witness is simultaneously a fixed point and a closed
self-observation path (`a` observes itself through `encode a`).  Consequences
include a Cantor obstruction, transport of emergent fixed points under a change
of observation coordinates, a least-fixed-point alternative supplied by
Knaster--Tarski, and the Yoneda identification of internal transformations with
transformations of the complete representable self-model.
-/

open Function

namespace EmergentFixedPoint

universe u v

/-- A complete extensional self-model: states name all `B`-valued observations
of the state space. -/
structure CompleteSelfModel (A : Type u) (B : Type v) where
  encode : A → (A → B)
  complete : Surjective encode

/-- The diagonal observation made when a state applies its own represented
observer to itself. -/
def CompleteSelfModel.diagonal {A : Type u} {B : Type v}
    (M : CompleteSelfModel A B) (a : A) : B :=
  M.encode a a

/-
**Lawvere fixed-point theorem, with its strange-loop witness exposed.**
Every endomorphism of the observation type has a fixed point arising from a
state which represents the transformed diagonal observation.
-/
theorem lawvere_strange_loop {A : Type u} {B : Type v}
    (M : CompleteSelfModel A B) (g : B → B) :
    ∃ a : A,
      M.encode a = (fun x => g (M.diagonal x)) ∧
      g (M.diagonal a) = M.diagonal a := by
  obtain ⟨ a, ha ⟩ := M.complete ( fun x => g ( M.diagonal x ) );
  refine' ⟨ a, ha, _ ⟩;
  exact congr_fun ha.symm a

/-
The usual fixed-point conclusion of Lawvere's theorem.
-/
theorem every_observation_transform_has_fixedPoint
    {A : Type u} {B : Type v} (M : CompleteSelfModel A B) (g : B → B) :
    ∃ b : B, g b = b := by
  obtain ⟨ a, ha ⟩ := lawvere_strange_loop M g;
  exact ⟨ _, ha.2 ⟩

/-- A complete self-model induces a single operator selecting a fixed point of
*every* observation transformer.  This packages emergence uniformly rather
than proving a separate existential statement for each transformer. -/
noncomputable def fixedPointSelector {A : Type u} {B : Type v}
    (M : CompleteSelfModel A B) : (B → B) → B :=
  fun g => Classical.choose (every_observation_transform_has_fixedPoint M g)

/-
The selected emergent value is genuinely fixed.
-/
theorem fixedPointSelector_spec {A : Type u} {B : Type v}
    (M : CompleteSelfModel A B) (g : B → B) :
    g (fixedPointSelector M g) = fixedPointSelector M g := by
  exact Classical.choose_spec ( every_observation_transform_has_fixedPoint M g )

/-
Fixed-point emergence is invariant under a change of observation
coordinates.  Conjugating the dynamics by an equivalence transports the
selected fixed value back to a fixed value of the original dynamics.
-/
theorem fixedPoint_under_conjugacy {A : Type u} {B : Type v} {C : Type*}
    (M : CompleteSelfModel A B) (e : B ≃ C) (h : C → C) :
    let c := e (fixedPointSelector M (e.symm ∘ h ∘ e))
    h c = c := by
  let b := fixedPointSelector M (e.symm ∘ h ∘ e)
  have hb := fixedPointSelector_spec M (e.symm ∘ h ∘ e)
  change h (e b) = e b
  apply e.symm.injective
  simpa [b, Function.comp_def] using hb

/-
A fixed-point-free observation transformer prevents a complete self-model.
This is the exact boundary of the positive Lawvere theorem.
-/
theorem no_complete_model_of_fixedPointFree {A : Type u} {B : Type v}
    (g : B → B) (hg : ∀ b, g b ≠ b) : IsEmpty (CompleteSelfModel A B) := by
  exact ⟨ fun M => by have := every_observation_transform_has_fixedPoint M g; tauto ⟩

/-
In particular no state space can completely model all of its Boolean-valued
self-observations: Boolean negation has no fixed point.
-/
theorem no_complete_boolean_selfModel (A : Type u) :
    IsEmpty (CompleteSelfModel A Bool) := by
  refine' no_complete_model_of_fixedPointFree _ _;
  exacts [ fun b => !b, by decide ]

/-
The order-theoretic route to emergence: a monotone self-map of a complete
lattice has a least fixed point.  Unlike complete extensional self-modeling,
this hypothesis is consistent and supplies a canonical stable state.
-/
theorem least_emergent_fixedPoint {α : Type*} [CompleteLattice α]
    (f : α →o α) :
    f (OrderHom.lfp f) = OrderHom.lfp f ∧
      ∀ x, f x = x → OrderHom.lfp f ≤ x := by
  refine ⟨f.map_lfp, ?_⟩
  intro x hx
  exact f.lfp_le (le_of_eq hx)

/-! ## Yoneda: self-modeling preserves all internal transformations -/

open CategoryTheory

/-- The internal transformations of a system are equivalent to natural
transformations of its complete representable model.  This is the precise
Yoneda connection: passing to the web of all probes loses no transformations. -/
noncomputable def yoneda_endomorphism_equiv
    {C : Type u} [Category.{v} C] (X : C) :
    (X ⟶ X) ≃ (yoneda.obj X ⟶ yoneda.obj X) :=
  Yoneda.fullyFaithful.homEquiv

/-
The Yoneda self-model reflects equality of internal dynamics.
-/
theorem yoneda_selfModel_faithful
    {C : Type u} [Category.{v} C] {X : C} (f g : X ⟶ X)
    (h : yoneda.map f = yoneda.map g) : f = g := by
  convert yoneda.map_injective h

/-- Isomorphic total representable models determine isomorphic systems. -/
noncomputable def systemIso_of_yonedaIso
    {C : Type u} [Category.{v} C] {X Y : C}
    (h : yoneda.obj X ≅ yoneda.obj Y) : X ≅ Y :=
  Yoneda.fullyFaithful.preimageIso h

end EmergentFixedPoint