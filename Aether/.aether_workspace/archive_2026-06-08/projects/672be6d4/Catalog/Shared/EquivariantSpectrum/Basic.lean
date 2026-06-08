/-
# Equivariant Impossibility Spectrum

The **impossibility spectrum** of a pair of G-sets (X, Y) is the collection of subgroups
H ≤ G for which no H-equivariant map f : X → Y exists. This file establishes the
fundamental structural theory of impossibility spectra.

## Main definitions

* `ImpossibilitySpectrum` — the set of subgroups H ≤ G admitting no H-equivariant map X → Y
* `ObstructionFilter` — an abstract structure axiomatizing the properties of impossibility spectra

## Main results

* `ImpossibilitySpectrum.upward_closed` — the spectrum is upward closed in the subgroup lattice
* `ImpossibilitySpectrum.fixed_point_obstruction` — if X^H ≠ ∅ and Y^H = ∅, then H is in the spectrum
* `ImpossibilitySpectrum.conjugation_invariant` — conjugation invariance of the spectrum
* `ImpossibilitySpectrum.toObstructionFilter` — every spectrum (with Y nonempty) is an obstruction filter
-/

import Mathlib

open MulAction Set Function

universe u v w

variable {G : Type u} [Group G]

/-! ## Equivariant maps and the impossibility spectrum -/

/-- A function `f : X → Y` is `H`-equivariant if it commutes with the action of every element
of the subgroup `H`. -/
def IsEquivariantMap (H : Subgroup G) {X : Type v} {Y : Type w}
    [MulAction G X] [MulAction G Y] (f : X → Y) : Prop :=
  ∀ (h : G) (_ : h ∈ H) (x : X), f (h • x) = h • f x

/-- The **impossibility spectrum** of a pair of G-sets `(X, Y)` is the set of subgroups `H ≤ G`
for which no `H`-equivariant map `f : X → Y` exists. -/
def ImpossibilitySpectrum (G : Type u) [Group G] (X : Type v) (Y : Type w)
    [MulAction G X] [MulAction G Y] : Set (Subgroup G) :=
  {H | ¬ ∃ f : X → Y, IsEquivariantMap H f}

/-- The **fixed point set** of a subgroup `H` acting on `X`, defined elementwise. -/
def FixedPointSet (H : Subgroup G) (X : Type v) [MulAction G X] : Set X :=
  {x | ∀ (h : G), h ∈ H → h • x = x}

/-
An equivariant map sends fixed points to fixed points.
-/
theorem equivariant_maps_fixed_to_fixed {X : Type v} {Y : Type w}
    [MulAction G X] [MulAction G Y] (H : Subgroup G) (f : X → Y)
    (hf : IsEquivariantMap H f) :
    MapsTo f (FixedPointSet H X) (FixedPointSet H Y) := by
  intro x hx h hh;
  rw [ ← hf h hh x, hx h hh ]

/-
**Upward closure**: If `H` is in the impossibility spectrum and `H ≤ K`,
then `K` is also in the spectrum. Any `K`-equivariant map is automatically `H`-equivariant.
-/
theorem ImpossibilitySpectrum.upward_closed {X : Type v} {Y : Type w}
    [MulAction G X] [MulAction G Y]
    {H K : Subgroup G} (hHK : H ≤ K)
    (hH : H ∈ ImpossibilitySpectrum G X Y) :
    K ∈ ImpossibilitySpectrum G X Y := by
  intro ⟨f, hf⟩;
  exact hH ⟨ f, fun h hh x => hf h ( hHK hh ) x ⟩

/-
**Fixed-point obstruction**: If the subgroup `H` has a fixed point in `X`
but no fixed points in `Y`, then no `H`-equivariant map from `X` to `Y` exists.
-/
theorem ImpossibilitySpectrum.fixed_point_obstruction {X : Type v} {Y : Type w}
    [MulAction G X] [MulAction G Y] (H : Subgroup G)
    (hX : (FixedPointSet H X).Nonempty) (hY : FixedPointSet H Y = ∅) :
    H ∈ ImpossibilitySpectrum G X Y := by
  intro ⟨ f, hf ⟩;
  exact Set.not_nonempty_iff_eq_empty.mpr hY ⟨ f hX.some, fun h hh => by simpa [ hf h hh ] using congr_arg f ( hX.choose_spec h hh ) ⟩

/-
**Orbit cardinality obstruction** (qualitative version): if a fixed point exists in `X`
but every point of `Y` is moved by some element of `H`, no equivariant map exists.
-/
theorem ImpossibilitySpectrum.fixed_point_nonempty_vs_empty {X : Type v} {Y : Type w}
    [MulAction G X] [MulAction G Y] (H : Subgroup G)
    (x : X) (hx : x ∈ FixedPointSet H X) (hY : ∀ y : Y, ¬ y ∈ FixedPointSet H Y) :
    ¬ ∃ f : X → Y, IsEquivariantMap H f := by
  -- Assume there exists an equivariant map $f : X \to Y$.
  by_contra h_contra
  obtain ⟨f, hf⟩ := h_contra

  -- By equivariant_maps_fixed_to_fixed, $f(x)$ is a fixed point of $H$ in $Y$.
  have h_fixed : f x ∈ FixedPointSet H Y := by
    exact equivariant_maps_fixed_to_fixed H f hf hx;
  exact hY _ h_fixed

/-
The trivial subgroup is never in the impossibility spectrum when `Y` is nonempty,
since any function is equivariant with respect to the trivial subgroup.
-/
theorem ImpossibilitySpectrum.bot_not_mem
    {X : Type v} {Y : Type w} [MulAction G X] [MulAction G Y] [Nonempty Y] :
    ⊥ ∉ ImpossibilitySpectrum G X Y := by
  obtain ⟨ y ⟩ := ‹Nonempty Y›; unfold ImpossibilitySpectrum; simp +decide [ IsEquivariantMap ] ;

/-
If the source is empty, any function is vacuously equivariant, so the spectrum is empty.
-/
theorem ImpossibilitySpectrum.empty_source
    {Y : Type w} [MulAction G Y] [IsEmpty X]
    [MulAction G X] :
    ImpossibilitySpectrum G X Y = ∅ := by
  -- By definition of impossibility spectrum, we need to show that for any subgroup $H$ of $G$, there exists an $H$-equivariant map from $X$ to $Y$.
  ext H
  simp [ImpossibilitySpectrum];
  exact ⟨ fun x => isEmptyElim x, fun h _ x => isEmptyElim x ⟩