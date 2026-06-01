/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Equivariant Impossibility Theory

We develop a formal algebraic framework for impossibility theorems viewed through
the lens of equivariant maps on group actions. The central concept is the
**impossibility spectrum** of a pair of G-sets: the collection of subgroups H ≤ G
for which no H-equivariant map exists.

## Main Definitions

* `IsEquivariantMap` — A function f : X → Y is G-equivariant if f(g • x) = g • f(x).
* `HasEquivariantMap` — There exists a G-equivariant map X → Y.
* `ImpossibilitySpectrum` — The set of subgroups H ≤ G witnessing impossibility.
* `IsFreeAction` — The group action has no non-trivial stabilizers.

## Main Results

* `spectrum_upward_closed` — The impossibility spectrum is upward closed.
* `equivariant_map_preserves_fixedPoints` — Equivariant maps send fixed points
  to fixed points.
* `no_equivariant_map_of_fixed_point_obstruction` — Fixed point obstruction.
* `equivariant_map_orbit_image` — Equivariant maps send orbits onto orbits.
* `free_action_stabilizer_trivial` — Free actions have trivial stabilizers.
* `free_action_orbit_card` — Free orbits have cardinality |G|.
* `transfer_impossibility` — Impossibility transfers through equivariant bijections.
* `spectrum_isUpperSet` — The spectrum is an upper set in the subgroup lattice.
-/

open MulAction Subgroup

noncomputable section

universe u v w

/-! ### Core Definitions -/

/-- A function `f : X → Y` is G-equivariant if it commutes with the group action:
    `f(g • x) = g • f(x)` for all `g : G` and `x : X`. -/
def IsEquivariantMap (G : Type u) {X : Type v} {Y : Type w}
    [Group G] [MulAction G X] [MulAction G Y] (f : X → Y) : Prop :=
  ∀ (g : G) (x : X), f (g • x) = g • f x

/-- There exists a G-equivariant map from X to Y. -/
def HasEquivariantMap (G : Type u) (X : Type v) (Y : Type w)
    [Group G] [MulAction G X] [MulAction G Y] : Prop :=
  ∃ f : X → Y, IsEquivariantMap G f

/-- The **impossibility spectrum** of a pair (X, Y) of G-sets is the set of subgroups
    H ≤ G such that no H-equivariant map X → Y exists. This is a novel invariant
    that measures which symmetry constraints create impossibility.

    The spectrum is always upward closed (see `spectrum_isUpperSet`), making it
    a filter-like object in the subgroup lattice. The "spectral gap" — the minimal
    subgroups in the spectrum — characterizes the threshold of symmetry at which
    impossibility emerges. -/
def ImpossibilitySpectrum (G : Type u) (X : Type v) (Y : Type w)
    [Group G] [MulAction G X] [MulAction G Y] : Set (Subgroup G) :=
  {H : Subgroup G | ¬ HasEquivariantMap H X Y}

/-- A group action is free if no non-identity element fixes any point:
    `g • x = x → g = 1`. -/
def IsFreeAction (G : Type u) (X : Type v) [Group G] [MulAction G X] : Prop :=
  ∀ (g : G) (x : X), g • x = x → g = 1

/-! ### Basic Properties of Equivariant Maps -/

/-
The identity map is always equivariant.
-/
theorem isEquivariantMap_id (G : Type u) (X : Type v) [Group G] [MulAction G X] :
    IsEquivariantMap G (id : X → X) := by
  exact fun g x => rfl

/-
The composition of equivariant maps is equivariant.
-/
theorem isEquivariantMap_comp {G : Type u} {X : Type v} {Y : Type w} {Z : Type*}
    [Group G] [MulAction G X] [MulAction G Y] [MulAction G Z]
    {f : X → Y} {g : Y → Z} (hf : IsEquivariantMap G f) (hg : IsEquivariantMap G g) :
    IsEquivariantMap G (g ∘ f) := by
  intro g x; have := hg g ( f x ) ; simp_all +decide [ IsEquivariantMap ] ;

/-! ### The Spectrum is Upward Closed -/

/-
If `f` is equivariant with respect to a subgroup `K`, then it is equivariant
    with respect to any subgroup `H ≤ K`. This is the key monotonicity property:
    equivariance with respect to more symmetries implies equivariance with respect
    to fewer symmetries.
-/
theorem equivariant_restrict_subgroup {G : Type u} {X : Type v} {Y : Type w}
    [Group G] [MulAction G X] [MulAction G Y]
    {H K : Subgroup G} (hHK : H ≤ K) {f : X → Y}
    (hf : IsEquivariantMap K f) : IsEquivariantMap H f := by
  intro h x;
  convert hf ⟨ h, hHK h.2 ⟩ x using 1

/-
**Spectrum Upward Closure**: The impossibility spectrum is upward closed in the
    subgroup lattice. If a subgroup H witnesses impossibility (no H-equivariant map
    exists), then any larger subgroup K ≥ H also witnesses impossibility.

    This captures the fundamental monotonicity: more symmetry constraints make
    equivariant solutions harder, not easier.
-/
theorem spectrum_upward_closed {G : Type u} {X : Type v} {Y : Type w}
    [Group G] [MulAction G X] [MulAction G Y]
    {H K : Subgroup G} (hHK : H ≤ K)
    (hH : H ∈ ImpossibilitySpectrum G X Y) : K ∈ ImpossibilitySpectrum G X Y := by
  exact fun ⟨ f, hf ⟩ => hH ⟨ f, equivariant_restrict_subgroup hHK hf ⟩

/-! ### Fixed Point Preservation -/

/-
**Equivariant Fixed Point Theorem**: An equivariant map sends fixed points of
    the group action to fixed points. If `x` is fixed by all of `G` and `f` is
    G-equivariant, then `f(x)` is also fixed by all of `G`.
-/
theorem equivariant_map_preserves_fixedPoints {G : Type u} {X : Type v} {Y : Type w}
    [Group G] [MulAction G X] [MulAction G Y]
    {f : X → Y} (hf : IsEquivariantMap G f)
    {x : X} (hx : ∀ g : G, g • x = x) : ∀ g : G, g • (f x) = f x := by
  exact fun g => by rw [ ← hf g x, hx g ] ;

/-
**Fixed Point Obstruction**: If the source has a G-fixed point but the target
    has no G-fixed points, then no G-equivariant map can exist.

    This is one of the most fundamental obstruction principles. It says:
    equivariant maps cannot "create symmetry breaking" — if a point is invariant
    under the group, its image must also be invariant. When the target has no
    invariant points, the map simply cannot exist.
-/
theorem no_equivariant_map_of_fixed_point_obstruction {G : Type u} {X : Type v} {Y : Type w}
    [Group G] [MulAction G X] [MulAction G Y]
    (hX : ∃ x : X, ∀ g : G, g • x = x)
    (hY : ∀ y : Y, ∃ g : G, g • y ≠ y) :
    ¬ HasEquivariantMap G X Y := by
  obtain ⟨ x, hx ⟩ := hX;
  rintro ⟨ f, hf ⟩;
  exact hY ( f x ) |> fun ⟨ g, hg ⟩ => hg ( hf g x ▸ by simp +decide [ hx ] )

/-! ### Orbit Structure -/

/-
**Orbit Inclusion**: An equivariant map sends the orbit of any point `x` into
    the orbit of `f(x)`. Orbits are the fundamental units that equivariant maps
    must respect.
-/
theorem equivariant_map_orbit_inclusion {G : Type u} {X : Type v} {Y : Type w}
    [Group G] [MulAction G X] [MulAction G Y]
    {f : X → Y} (hf : IsEquivariantMap G f)
    (x : X) : f '' (orbit G x) ⊆ orbit G (f x) := by
  rintro _ ⟨ y, ⟨ g, rfl ⟩, rfl ⟩;
  exact ⟨ g, by rw [ hf ] ⟩

/-
**Orbit Surjection**: An equivariant map maps the orbit of `x` surjectively
    onto the orbit of `f(x)`.
-/
theorem equivariant_map_orbit_surjection {G : Type u} {X : Type v} {Y : Type w}
    [Group G] [MulAction G X] [MulAction G Y]
    {f : X → Y} (hf : IsEquivariantMap G f)
    (x : X) : orbit G (f x) ⊆ f '' (orbit G x) := by
  intro y hy; obtain ⟨ g, rfl ⟩ := hy; use g • x; aesop;

/-- **Orbit Image Equality**: An equivariant map maps the orbit of `x` exactly
    onto the orbit of `f(x)`. This is a central structural theorem: equivariant
    maps establish a perfect correspondence between orbits. -/
theorem equivariant_map_orbit_image {G : Type u} {X : Type v} {Y : Type w}
    [Group G] [MulAction G X] [MulAction G Y]
    {f : X → Y} (hf : IsEquivariantMap G f)
    (x : X) : f '' (orbit G x) = orbit G (f x) :=
  Set.Subset.antisymm (equivariant_map_orbit_inclusion hf x)
    (equivariant_map_orbit_surjection hf x)

/-! ### Free Action Theory -/

/-
In a free action, the stabilizer of every point is trivial.
-/
theorem free_action_stabilizer_trivial {G : Type u} {X : Type v}
    [Group G] [MulAction G X] (hfree : IsFreeAction G X) (x : X) :
    stabilizer G x = ⊥ := by
  -- By definition of stabilizer, we need to show that for any g in G, g • x = x implies g = 1.
  ext g
  simp [stabilizer]
  exact ⟨ fun hg => hfree g x hg, fun hg => hg.symm ▸ one_smul _ _ ⟩

/-
**Free Action Orbit Cardinality**: In a free action of a finite group,
    every orbit has cardinality equal to |G|. This follows from the
    orbit-stabilizer theorem: |orbit(x)| * |stab(x)| = |G|, and freeness
    gives |stab(x)| = 1.
-/
theorem free_action_orbit_card {G : Type u} {X : Type v}
    [Group G] [Fintype G] [MulAction G X] [Fintype X]
    (hfree : IsFreeAction G X) (x : X) :
    Nat.card (orbit G x) = Fintype.card G := by
  -- In a free action, we can apply `MulAction.card_orbit_mul_card_stabilizer_eq_card_group`.
  have h_orbit_stabilizer : Nat.card (orbit G x) * Nat.card (stabilizer G x) = Fintype.card G := by
    rw [ ← Nat.card_eq_fintype_card ];
    convert Nat.card_congr ( MulAction.orbitProdStabilizerEquivGroup G x );
    simp +decide;
  rw [ ← h_orbit_stabilizer, show Nat.card ( stabilizer G x ) = 1 from ?_ ] ; simp +decide;
  rw [ show stabilizer G x = ⊥ from free_action_stabilizer_trivial hfree x, Nat.card_eq_fintype_card, Fintype.card_eq_one_iff.mpr ] ; aesop

/-! ### Transfer Principle -/

/-
**Transfer Principle**: Impossibility is invariant under equivariant bijections.
    If there is a G-equivariant bijection between X₁ and X₂, then equivariant maps
    X₁ → Y exist if and only if equivariant maps X₂ → Y exist.

    This allows impossibility results to be transported between isomorphic G-sets,
    which is the algebraic analogue of the topological transfer principle in
    equivariant homotopy theory.
-/
theorem transfer_impossibility {G : Type u} {X₁ X₂ : Type v} {Y : Type w}
    [Group G] [MulAction G X₁] [MulAction G X₂] [MulAction G Y]
    (φ : X₁ → X₂) (ψ : X₂ → X₁)
    (hφ : IsEquivariantMap G φ) (hψ : IsEquivariantMap G ψ)
    (_hφψ : ∀ x, φ (ψ x) = x) (_hψφ : ∀ x, ψ (φ x) = x) :
    HasEquivariantMap G X₁ Y ↔ HasEquivariantMap G X₂ Y := by
  constructor;
  · rintro ⟨ f, hf ⟩;
    exact ⟨ f ∘ ψ, isEquivariantMap_comp hψ hf ⟩;
  · rintro ⟨ f, hf ⟩;
    exact ⟨ f ∘ φ, isEquivariantMap_comp hφ hf ⟩

/-! ### Spectral Characterization -/

/-
The full group G is in the impossibility spectrum if and only if
    no G-equivariant map exists (for the top subgroup action).
-/
theorem mem_spectrum_top {G : Type u} {X : Type v} {Y : Type w}
    [Group G] [MulAction G X] [MulAction G Y] :
    (⊤ : Subgroup G) ∈ ImpossibilitySpectrum G X Y ↔
    ¬ HasEquivariantMap (⊤ : Subgroup G) X Y := by
  convert Iff.rfl

/-
The trivial subgroup is never in the impossibility spectrum when
    the target is nonempty, since any function is {1}-equivariant
    (the only element of ⊥ acts as the identity).
-/
theorem bot_not_mem_spectrum_of_nonempty {G : Type u} {X : Type v} {Y : Type w}
    [Group G] [MulAction G X] [MulAction G Y]
    [Nonempty X] [Nonempty Y] :
    (⊥ : Subgroup G) ∉ ImpossibilitySpectrum G X Y := by
  simp +decide [ ImpossibilitySpectrum ];
  obtain ⟨ x ⟩ := ‹Nonempty X›; obtain ⟨ y ⟩ := ‹Nonempty Y›; use fun _ => y; simp +decide [ IsEquivariantMap ] ;

/-
**Spectrum is an Upper Set**: The impossibility spectrum forms an upper set
    (upset / upward-closed set) in the subgroup lattice. This packages the
    upward closure theorem in the language of order theory.
-/
theorem spectrum_isUpperSet {G : Type u} {X : Type v} {Y : Type w}
    [Group G] [MulAction G X] [MulAction G Y] :
    IsUpperSet (ImpossibilitySpectrum G X Y) := by
  intro H K hHK hH;
  apply spectrum_upward_closed hHK hH

end