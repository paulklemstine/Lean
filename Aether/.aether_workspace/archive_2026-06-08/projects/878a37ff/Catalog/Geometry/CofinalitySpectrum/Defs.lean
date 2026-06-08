/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Cofinality Spectrum: Definitions

This file defines the cofinality spectrum for linearly ordered topological spaces.
The cofinality spectrum partitions points into "tame" (countable cofinality from
both sides) and "wild" (uncountable cofinality from at least one side), providing
a complete characterization of the local topological complexity at each point.

## Main Definitions

* `CofinalitySpectrum.IsCofinalBelow` - cofinality of a set below a point
* `CofinalitySpectrum.IsCoinitialAbove` - coinitiality of a set above a point
* `CofinalitySpectrum.HasCountableLeftCof` - countable left cofinality
* `CofinalitySpectrum.HasCountableRightCof` - countable right cofinality
* `CofinalitySpectrum.IsTame` - tame point (countable cofinality from both sides)
* `CofinalitySpectrum.IsWild` - wild point (uncountable from at least one side)
* `CofinalitySpectrum.HasPFilterProperty` - P-filter property at a point
* `CofinalitySpectrum.CofinalityType` - four-way classification of points
-/

namespace CofinalitySpectrum

open Set Filter Topology

variable {α : Type*} [LinearOrder α]

/-! ### Core Cofinality Definitions -/

/-- A set `s` is cofinal below `x` if `s ⊆ {y | y < x}` and every element
below `x` is bounded above by some element of `s`. -/
def IsCofinalBelow (s : Set α) (x : α) : Prop :=
  s ⊆ Iio x ∧ ∀ y, y < x → ∃ z ∈ s, y ≤ z

/-- A set `s` is coinitial above `x` if `s ⊆ {y | y > x}` and every element
above `x` is bounded below by some element of `s`. -/
def IsCoinitialAbove (s : Set α) (x : α) : Prop :=
  s ⊆ Ioi x ∧ ∀ y, x < y → ∃ z ∈ s, z ≤ y

/-- A point `x` has countable left cofinality if either `x` is a minimum element
(nothing below it), or there exists a countable set cofinal below `x`. -/
def HasCountableLeftCof (x : α) : Prop :=
  IsBot x ∨ ∃ s : Set α, s.Countable ∧ IsCofinalBelow s x

/-- A point `x` has countable right cofinality if either `x` is a maximum element
(nothing above it), or there exists a countable set coinitial above `x`. -/
def HasCountableRightCof (x : α) : Prop :=
  IsTop x ∨ ∃ s : Set α, s.Countable ∧ IsCoinitialAbove s x

/-- A point is **tame** if it has countable cofinality from both sides. -/
def IsTame (x : α) : Prop :=
  HasCountableLeftCof x ∧ HasCountableRightCof x

/-- A point is **wild** if it is not tame. -/
def IsWild (x : α) : Prop := ¬IsTame x

/-- The **tame locus**: the set of all tame points in an ordered space. -/
def tameLocus (α : Type*) [LinearOrder α] : Set α :=
  {x | IsTame x}

/-- The **wild locus**: the set of all wild points. -/
def wildLocus (α : Type*) [LinearOrder α] : Set α :=
  {x | IsWild x}

/-- The tame and wild loci partition the space. -/
theorem tameLocus_union_wildLocus : tameLocus α ∪ wildLocus α = univ := by
  ext x; simp [tameLocus, wildLocus, IsTame, IsWild]; tauto

/-- The tame and wild loci are disjoint. -/
theorem tameLocus_inter_wildLocus : tameLocus α ∩ wildLocus α = ∅ := by
  ext x; simp [tameLocus, wildLocus, IsTame, IsWild]

variable [TopologicalSpace α] [OrderTopology α]

/-- The **P-filter property**: countable intersections of neighborhoods are
neighborhoods. -/
def HasPFilterProperty (x : α) : Prop :=
  ∀ (f : ℕ → Set α), (∀ n, f n ∈ 𝓝 x) → (⋂ n, f n) ∈ 𝓝 x

/-! ### Cofinality Profile: Novel Four-Way Classification -/

/-- The four cofinality types, forming a complete classification. -/
inductive CofinalityType where
  | tame       : CofinalityType
  | leftWild   : CofinalityType
  | rightWild  : CofinalityType
  | fullyWild  : CofinalityType
  deriving DecidableEq, Repr

open Classical in
/-- Classify a point by its cofinality type. -/
noncomputable def cofinalityTypeOf (x : α) : CofinalityType :=
  if HasCountableLeftCof x then
    if HasCountableRightCof x then CofinalityType.tame
    else CofinalityType.rightWild
  else
    if HasCountableRightCof x then CofinalityType.leftWild
    else CofinalityType.fullyWild

end CofinalitySpectrum