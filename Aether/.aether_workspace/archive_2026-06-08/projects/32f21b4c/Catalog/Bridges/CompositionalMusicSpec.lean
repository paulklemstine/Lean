import Mathlib

/-! # Compositional Musical Specifications: Refinement Semantics with Style Transport

This file formalizes a concrete order-enriched compositional framework for musical
specifications, bridging applied category theory (compositional open-system semantics),
formal methods (refinement and monotonicity), and machine learning for music (style
transport as monotone maps).

## Main definitions

* `MusicSpec α` — A musical specification over event type `α`, defined as `Set (List α)`.
* `refines S T` — Specification `S` refines `T`, meaning `S ⊆ T` (fewer allowed behaviors).
* `compose S T` — Concatenative composition of specifications (language concatenation).
* `mapSpec f S` — Style transport: pushforward of a specification along `f : α → β`.
* `emptyWordSpec` — The identity specification `{[]}` for composition.

## Main results

### Preorder structure
* `refines_refl` — Refinement is reflexive.
* `refines_trans` — Refinement is transitive.

### Compositional monotonicity
* `refines_compose_mono` — Composition is monotone in both arguments w.r.t. refinement.

### Style transport
* `refines_mapSpec` — Style transport preserves refinement (functorial on the preorder).
* `mapSpec_compose_eq` — Style transport distributes over composition (monoidal functor law).
* `mapSpec_id` — Identity style map is the identity on specifications.
* `mapSpec_comp` — Composition of style maps equals style map of composition (functoriality).

### Monoidal structure
* `compose_assoc` — Composition of specifications is associative.
* `compose_emptyWord_left` — `emptyWordSpec` is a left identity for composition.
* `compose_emptyWord_right` — `emptyWordSpec` is a right identity for composition.

### Iterated transport
* `iterate_mapSpec_refines_chain` — Iterated style transport preserves refinement.

### Galois-style abstraction
* `sound_abstraction` — Soundness of an abstraction/concretization pair.
* `refines_mapSpec_sound` — Refinement is preserved under sound abstraction.

## Interpretation

The triple `(MusicSpec α, refines, compose)` forms a monoidal preorder — the
certified semantic substrate for compositional open-system reasoning about music.
The functor `mapSpec f` is a monotone monoidal map — the certified interface for
style transfer that preserves specification safety.

Together, these results establish that:
1. Musical specifications compose associatively with a unit (monoid of behaviors).
2. Refinement is preserved under composition (substitution principle).
3. Style maps transport refinement faithfully (certified transfer learning).
4. Style maps commute with composition (compositional transfer).

This is the minimal verified backbone for constraint-preserving generative music systems
and categorical transfer learning.
-/

open Set List

/-! ## Definitions -/

/-- A musical specification over event type `α`: a set of allowed phrases (finite words). -/
abbrev MusicSpec (α : Type*) := Set (List α)

/-- Specification `S` refines `T` if every behavior allowed by `S` is also allowed by `T`.
    More refined = fewer allowed behaviors = stronger constraint. -/
def MusicSpec.refines {α : Type*} (S T : MusicSpec α) : Prop := S ⊆ T

/-- Concatenative composition of musical specifications:
    `compose S T` is the set of all phrases `u ++ v` with `u ∈ S` and `v ∈ T`. -/
def MusicSpec.compose {α : Type*} (S T : MusicSpec α) : MusicSpec α :=
  fun w => ∃ u v, S u ∧ T v ∧ u ++ v = w

/-- Style transport: pushforward of a specification along an event map `f : α → β`.
    Each phrase is relabeled pointwise by `f`. -/
def MusicSpec.mapSpec {α β : Type*} (f : α → β) (S : MusicSpec α) : MusicSpec β :=
  fun w => ∃ u, S u ∧ List.map f u = w

/-- The identity specification for composition: contains only the empty phrase. -/
def MusicSpec.emptyWordSpec {α : Type*} : MusicSpec α := fun w => w = []

/-! ## Preorder structure -/

/-
Refinement is reflexive.
-/
theorem MusicSpec.refines_refl {α : Type*} (S : MusicSpec α) : MusicSpec.refines S S := by
  exact Set.Subset.refl _

/-
Refinement is transitive.
-/
theorem MusicSpec.refines_trans {α : Type*} {S T U : MusicSpec α}
    (h₁ : MusicSpec.refines S T) (h₂ : MusicSpec.refines T U) :
    MusicSpec.refines S U := by
  -- To prove that S.refines U, we take any element w in S. Since S is a subset of T, w must also be in T. Then, since T is a subset of U, w must be in U. Therefore, S is a subset of U, which means S.refines U.
  intros w hw
  apply h₂
  apply h₁
  exact hw

/-! ## Compositional monotonicity of refinement -/

/-
**Compositional Monotonicity**: If `S₁` refines `S₂` and `T₁` refines `T₂`,
    then `compose S₁ T₁` refines `compose S₂ T₂`.

    This is the substitution principle: replacing a component with a less constrained
    one preserves the refinement relationship at the system level.
-/
theorem MusicSpec.refines_compose_mono
    {α : Type*} {S₁ S₂ T₁ T₂ : MusicSpec α}
    (hS : MusicSpec.refines S₁ S₂) (hT : MusicSpec.refines T₁ T₂) :
    MusicSpec.refines (MusicSpec.compose S₁ T₁) (MusicSpec.compose S₂ T₂) := by
  exact fun w hw => by rcases hw with ⟨ u, v, hu, hv, rfl ⟩ ; exact ⟨ u, v, hS hu, hT hv, rfl ⟩ ;

/-! ## Style transport preserves refinement -/

/-
**Style Transport Monotonicity**: A style map `f` preserves refinement.
    If `S ⊆ T` then `f_*(S) ⊆ f_*(T)`.
-/
theorem MusicSpec.refines_mapSpec
    {α β : Type*} (f : α → β) {S T : MusicSpec α}
    (h : MusicSpec.refines S T) :
    MusicSpec.refines (MusicSpec.mapSpec f S) (MusicSpec.mapSpec f T) := by
  exact fun w hw => by obtain ⟨ u, hu, rfl ⟩ := hw; exact ⟨ u, h hu, rfl ⟩ ;

/-! ## Functoriality of style transport over composition -/

/-
**Monoidal Functor Law**: Style transport distributes over composition.
    `mapSpec f (compose S T) = compose (mapSpec f S) (mapSpec f T)`.

    In categorical language, `mapSpec f` is a strict monoidal functor from
    the monoid of specifications to itself. In ML language, transfer commutes
    with composition of motifs.
-/
theorem MusicSpec.mapSpec_compose_eq
    {α β : Type*} (f : α → β) (S T : MusicSpec α) :
    MusicSpec.mapSpec f (MusicSpec.compose S T) =
    MusicSpec.compose (MusicSpec.mapSpec f S) (MusicSpec.mapSpec f T) := by
  ext w;
  constructor;
  · rintro ⟨ u, ⟨ v, w, hv, hw, rfl ⟩, rfl ⟩ ; exact ⟨ _, _, ⟨ _, hv, rfl ⟩, ⟨ _, hw, rfl ⟩, by simp +decide ⟩ ;
  · rintro ⟨ u, v, ⟨ u', hu', rfl ⟩, ⟨ v', hv', rfl ⟩, rfl ⟩;
    exact ⟨ u' ++ v', ⟨ u', v', hu', hv', rfl ⟩, by simp +decide ⟩

/-! ## Monoidal structure -/

/-
Composition of specifications is associative.
-/
theorem MusicSpec.compose_assoc
    {α : Type*} (S T U : MusicSpec α) :
    MusicSpec.compose (MusicSpec.compose S T) U =
    MusicSpec.compose S (MusicSpec.compose T U) := by
  unfold MusicSpec.compose;
  ext w;
  grind

/-
The empty word specification is a left identity for composition.
-/
theorem MusicSpec.compose_emptyWord_left
    {α : Type*} (S : MusicSpec α) :
    MusicSpec.compose MusicSpec.emptyWordSpec S = S := by
  exact Set.ext fun x => ⟨ fun ⟨ u, v, hu, hv, hx ⟩ => hx ▸ by simpa using hu.symm ▸ hv, fun hx => ⟨ [ ], x, rfl, hx, rfl ⟩ ⟩

/-
The empty word specification is a right identity for composition.
-/
theorem MusicSpec.compose_emptyWord_right
    {α : Type*} (S : MusicSpec α) :
    MusicSpec.compose S MusicSpec.emptyWordSpec = S := by
  ext w.compose;
  constructor;
  · rintro ⟨ u, v, hu, hv, rfl ⟩;
    cases hv ; aesop;
  · exact fun h => ⟨ w.compose, [ ], h, rfl, by simp +decide ⟩

/-! ## Functoriality of style transport -/

/-
The identity style map acts as the identity on specifications.
-/
theorem MusicSpec.mapSpec_id
    {α : Type*} (S : MusicSpec α) :
    MusicSpec.mapSpec id S = S := by
  exact Set.ext fun x => ⟨ fun ⟨ u, hu, hu' ⟩ => by aesop, fun hx => ⟨ x, by aesop ⟩ ⟩

/-
Composition of style maps equals style map of composition: full functoriality.
-/
theorem MusicSpec.mapSpec_comp
    {α β γ : Type*} (f : α → β) (g : β → γ) (S : MusicSpec α) :
    MusicSpec.mapSpec g (MusicSpec.mapSpec f S) = MusicSpec.mapSpec (g ∘ f) S := by
  -- By definition of mapSpec, we can rewrite the goal using the definition.
  unfold mapSpec;
  aesop

/-! ## Iterated style transport -/

/-
Iterated application of a style endomorphism preserves refinement at every step.
-/
theorem MusicSpec.iterate_mapSpec_refines_chain
    {α : Type*} (f : α → α) {S T : MusicSpec α}
    (h : MusicSpec.refines S T) :
    ∀ n : ℕ, MusicSpec.refines
      ((MusicSpec.mapSpec f)^[n] S)
      ((MusicSpec.mapSpec f)^[n] T) := by
  intro n;
  induction' n with n ih;
  · grind +revert;
  · simpa only [ Function.iterate_succ_apply' ] using MusicSpec.refines_mapSpec f ih

/-! ## Galois-style abstraction -/

/-- An abstraction map `abs` and concretization map `γ` form a sound pair if every
    concrete event is in the concretization of its abstraction. -/
def MusicSpec.sound_abstraction {α β : Type*}
    (abs : α → β) (γ : β → Set α) : Prop :=
  ∀ a, a ∈ γ (abs a)

/-
Refinement is preserved under sound abstraction: if `S ⊆ T` and the abstraction
    is sound, then `abs_*(S) ⊆ abs_*(T)`.
-/
theorem MusicSpec.refines_mapSpec_sound
    {α β : Type*} (abs : α → β) (γ : β → Set α)
    (_hsg : MusicSpec.sound_abstraction abs γ)
    {S T : MusicSpec α}
    (h : MusicSpec.refines S T) :
    MusicSpec.refines (MusicSpec.mapSpec abs S) (MusicSpec.mapSpec abs T) := by
  -- By definition of refinement, if S ⊆ T, then for any element x in S, x is also in T.
  apply MusicSpec.refines_mapSpec; assumption

/-! ## Style transport preserves the identity specification -/

/-
Style transport maps the identity specification to the identity specification.
-/
theorem MusicSpec.mapSpec_emptyWordSpec
    {α β : Type*} (f : α → β) :
    MusicSpec.mapSpec f MusicSpec.emptyWordSpec = MusicSpec.emptyWordSpec := by
  -- By definition of mapSpec, we need to show that for any list w, w is in the image of the empty word under f if and only if w is the empty list.
  funext w
  simp [MusicSpec.mapSpec, MusicSpec.emptyWordSpec]

#print axioms MusicSpec.refines_refl
#print axioms MusicSpec.refines_trans
#print axioms MusicSpec.refines_compose_mono
#print axioms MusicSpec.refines_mapSpec
#print axioms MusicSpec.mapSpec_compose_eq
#print axioms MusicSpec.compose_assoc
#print axioms MusicSpec.compose_emptyWord_left
#print axioms MusicSpec.compose_emptyWord_right
#print axioms MusicSpec.mapSpec_id
#print axioms MusicSpec.mapSpec_comp
#print axioms MusicSpec.iterate_mapSpec_refines_chain
#print axioms MusicSpec.refines_mapSpec_sound
#print axioms MusicSpec.mapSpec_emptyWordSpec