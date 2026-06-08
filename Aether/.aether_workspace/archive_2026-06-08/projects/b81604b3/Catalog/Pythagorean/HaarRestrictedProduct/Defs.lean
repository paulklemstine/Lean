/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Haar Measure on Restricted Products: Definitions and Core Lemmas

This file introduces the key definitions for the measure theory of restricted products
of locally compact groups. The central concepts are:

* **Basic cylinders**: sets where finitely many coordinates are prescribed, and the rest
  lie in the distinguished compact open subsets.
* **Maximal compact**: the compact open subset `∏ K_i` inside the restricted product.
* **Level compatibility**: the property that a measure's values on cylinders factor as
  finite products of local measures.

## Mathematical Context

The restricted product `Πʳ i, [G i, K i]` consists of tuples `(x_i) ∈ ∏ G_i` with
`x_i ∈ K_i` for all but finitely many `i`. When each `G_i` is a locally compact group
and each `K_i` is a compact open subgroup, the restricted product is itself a locally
compact group admitting a Haar measure.

The Haar measure on this restricted product is **uniquely determined by
its values on basic cylinders**, which factor as finite products of local Haar measures.
-/

open scoped Filter Topology
open MeasureTheory MeasureTheory.Measure Set Filter Finset

noncomputable section

namespace RestrictedProduct

variable {ι : Type*} (G : ι → Type*) (K : (i : ι) → Set (G i))

/-- The measurable space on a restricted product, induced from the product σ-algebra
via the subtype embedding. -/
instance instMeasurableSpace [∀ i, MeasurableSpace (G i)] :
    MeasurableSpace (RestrictedProduct G K Filter.cofinite) :=
  Subtype.instMeasurableSpace

/-- The maximal compact: the set of all elements `x` in the restricted product
such that `x i ∈ K i` for every `i`.

When each `K_i` is a compact open subgroup, this is a compact open subgroup of
the restricted product — the natural normalization point `μ(maximalCompact) = 1`. -/
def maximalCompact : Set (RestrictedProduct G K Filter.cofinite) :=
  {x | ∀ i, x i ∈ K i}

@[simp]
theorem mem_maximalCompact {x : RestrictedProduct G K Filter.cofinite} :
    x ∈ maximalCompact G K ↔ ∀ i, x i ∈ K i :=
  Iff.rfl

section DecidableEq

variable [DecidableEq ι]

/-- A basic cylinder in the restricted product: on a finite set `s`, one prescribes
sets `A i ⊆ G i`, and outside `s` one stays in the distinguished subset `K i`.

This is the fundamental building block for measure theory on restricted products. -/
def basicCylinder (s : Finset ι) (A : ∀ i, Set (G i)) :
    Set (RestrictedProduct G K Filter.cofinite) :=
  {x | (∀ i ∈ s, x i ∈ A i) ∧ (∀ i ∉ s, x i ∈ K i)}

@[simp]
theorem mem_basicCylinder {s : Finset ι} {A : ∀ i, Set (G i)}
    {x : RestrictedProduct G K Filter.cofinite} :
    x ∈ basicCylinder G K s A ↔
      (∀ i ∈ s, x i ∈ A i) ∧ (∀ i ∉ s, x i ∈ K i) :=
  Iff.rfl

/-- The maximal compact equals the basic cylinder with empty support. -/
theorem maximalCompact_eq_basicCylinder :
    maximalCompact G K = basicCylinder G K ∅ (fun _ => Set.univ) := by
  ext x; simp [basicCylinder, maximalCompact]

/-- The maximal compact is contained in every basic cylinder whose sets contain `K`. -/
theorem maximalCompact_subset_basicCylinder {s : Finset ι} {A : ∀ i, Set (G i)}
    (h : ∀ i ∈ s, K i ⊆ A i) :
    maximalCompact G K ⊆ basicCylinder G K s A := by
  intro x hx
  simp only [mem_basicCylinder, mem_maximalCompact] at *
  exact ⟨fun i hi => h i hi (hx i), fun i _ => hx i⟩

/-- The basic cylinder is monotone in the sets on the support. -/
theorem basicCylinder_mono_sets {s : Finset ι} {A B : ∀ i, Set (G i)}
    (h : ∀ i ∈ s, A i ⊆ B i) :
    basicCylinder G K s A ⊆ basicCylinder G K s B := by
  intro x hx
  rw [mem_basicCylinder] at hx ⊢
  exact ⟨fun i hi => h i hi (hx.1 i hi), hx.2⟩

/-
**Support enlargement invariance**: enlarging the support set and using `K i` on the
new coordinates does not change the cylinder. This is the key compatibility property
for projective-limit arguments.
-/
theorem basicCylinder_eq_of_superset {s t : Finset ι} {A : ∀ i, Set (G i)}
    (hst : s ⊆ t) (hAK : ∀ i ∈ t, i ∉ s → A i = K i) :
    basicCylinder G K t A = basicCylinder G K s A := by
  ext x;
  constructor <;> intro hx <;> simp_all +decide [ basicCylinder ];
  · grind;
  · grind

/-
**Cylinder π-system**: the intersection of two basic cylinders with common support
is a basic cylinder with intersected sets.
This is essential for measure extension theorems.
-/
theorem basicCylinder_inter_same_support {s : Finset ι} {A B : ∀ i, Set (G i)} :
    basicCylinder G K s A ∩ basicCylinder G K s B =
    basicCylinder G K s (fun i => A i ∩ B i) := by
  unfold basicCylinder; ext; aesop;

/-- A measure on the restricted product is **level-compatible** with local measures `μ_i`
if its value on each basic cylinder equals the product of local measures.
This is the key characterization that makes Haar measure computable. -/
def IsLevelCompatible [∀ i, MeasurableSpace (G i)]
    (μ : Measure (RestrictedProduct G K Filter.cofinite))
    (μ_local : ∀ i, Measure (G i)) : Prop :=
  ∀ (s : Finset ι) (A : ∀ i, Set (G i)),
    (∀ i ∈ s, MeasurableSet (A i)) →
    (∀ i ∉ s, A i = K i) →
    μ (basicCylinder G K s A) = ∏ i ∈ s, μ_local i (A i)

end DecidableEq

end RestrictedProduct