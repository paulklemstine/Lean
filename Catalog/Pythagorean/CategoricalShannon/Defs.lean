/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic Research
-/
import Mathlib

/-!
# Categorical Shannon Theory — Definitions

This file develops the **Categorical Shannon Theory** of representable covers.
The central insight is that morphisms in a category act as "channels" that allow
generators at one object to cover elements at other objects, providing compression
analogous to Shannon coding.

## Main Definitions

* `PresheafModel` — a finite presheaf on a finite set of objects with restriction maps.
* `Generator` — a pair `(Y, z)` where `Y` is an object and `z ∈ F(Y)`.
* `Covers` — when a generator `(Y, z)` covers an element `(X, w)`.
* `IsCoveringSet` — a set of generators that covers all elements.
* `minCoverSize` — the minimum size of a covering set.
* `GenGraph` — the generator graph: vertices are generators, edges encode covering.
* `IsDominatingSet` — graph-theoretic domination in the generator graph.

## The Key Idea

In a **discrete category** (no non-identity morphisms), each generator covers only
itself, so `minCoverSize = ∑ Y, |F(Y)|`. When morphisms exist, a single generator
`(Y, z)` can cover multiple elements at different objects via restriction maps,
achieving compression. The **Shannon lower bound** limits how much compression is
possible based on the morphism structure.
-/

open Finset Fintype

noncomputable section

universe u v

/-! ### Presheaf Model

We model presheaves on finite categories concretely: objects form a finite type,
fibers are finite types, and restriction maps encode the functorial action of
morphisms. This avoids the overhead of full categorical machinery while capturing
the essential compression phenomenon.
-/

/-- A **presheaf model** consists of:
- A finite type of objects `Ob`
- A family of finite types `F : Ob → Type` (the fibers/stalks)
- Restriction maps `r : ∀ (src tgt : Ob), F src → F tgt` encoding morphism action

The restriction maps model `F(f)` for morphisms `f : tgt → src` in the category.
We do NOT require functoriality in this generality — specific theorems assume
additional properties (identity, composition) as needed. -/
structure PresheafModel where
  Ob : Type
  instFintypeOb : Fintype Ob
  instDecEqOb : DecidableEq Ob
  F : Ob → Type
  instFintypeF : ∀ Y, Fintype (F Y)
  instDecEqF : ∀ Y, DecidableEq (F Y)
  /-- `hasRestriction X Y` indicates whether there is a morphism from X to Y
      (i.e., whether generators at Y can cover elements at X). -/
  hasRestriction : Ob → Ob → Prop
  instDecRestriction : DecidablePred (Function.uncurry hasRestriction)
  /-- The restriction map: if there's a morphism X → Y, then F(Y) → F(X).
      When `¬ hasRestriction X Y`, this map is arbitrary (not used). -/
  restrict : ∀ (X Y : Ob), F Y → F X

attribute [instance] PresheafModel.instFintypeOb PresheafModel.instDecEqOb
  PresheafModel.instFintypeF PresheafModel.instDecEqF

/-! ### Generators and Covering -/

/-- A **generator** is a pair `(Y, z)` where `Y` is an object and `z ∈ F(Y)`.
    This is an element that can potentially cover other elements via restriction. -/
def Generator (M : PresheafModel) : Type :=
  Σ Y : M.Ob, M.F Y

instance (M : PresheafModel) : Fintype (Generator M) :=
  inferInstanceAs (Fintype (Σ Y : M.Ob, M.F Y))

instance (M : PresheafModel) : DecidableEq (Generator M) :=
  inferInstanceAs (DecidableEq (Σ Y : M.Ob, M.F Y))

/-- A generator `(Y, z)` **covers** an element `(X, w)` if there is a restriction
    from Y to X and applying it to z yields w. In categorical language: there exists
    a morphism `f : X → Y` such that `F(f)(z) = w`. -/
def Covers (M : PresheafModel) (gen : Generator M) (X : M.Ob) (w : M.F X) : Prop :=
  M.hasRestriction X gen.1 ∧ M.restrict X gen.1 gen.2 = w

/-- An **element** of the presheaf is a pair `(X, w)` with `X` an object and `w ∈ F(X)`. -/
def Element (M : PresheafModel) : Type :=
  Σ X : M.Ob, M.F X

instance (M : PresheafModel) : Fintype (Element M) :=
  inferInstanceAs (Fintype (Σ X : M.Ob, M.F X))

instance (M : PresheafModel) : DecidableEq (Element M) :=
  inferInstanceAs (DecidableEq (Σ X : M.Ob, M.F X))

/-- The total number of elements across all fibers. -/
def totalElements (M : PresheafModel) : ℕ :=
  Fintype.card (Element M)

theorem totalElements_eq_sum (M : PresheafModel) :
    totalElements M = ∑ Y : M.Ob, Fintype.card (M.F Y) := by
  simp [totalElements, Element, Fintype.card_sigma]

/-! ### Covering Sets -/

/-- A set of generators **covers** the presheaf if every element `(X, w)` is
    covered by at least one generator in the set. -/
def IsCoveringSet (M : PresheafModel) (S : Finset (Generator M)) : Prop :=
  ∀ (X : M.Ob) (w : M.F X), ∃ g ∈ S, Covers M g X w

/-- In a **self-covering** model, every element covers itself: the identity
    restriction exists and acts as identity. This holds when the category has
    identity morphisms (which all categories do). -/
def IsSelfCovering (M : PresheafModel) : Prop :=
  ∀ (X : M.Ob) (w : M.F X), M.hasRestriction X X ∧ M.restrict X X w = w

/-- The full set of all generators is covering when the model is self-covering. -/
theorem fullSet_isCovering (M : PresheafModel) (hsc : IsSelfCovering M) :
    IsCoveringSet M Finset.univ := by
  intro X w
  exact ⟨⟨X, w⟩, Finset.mem_univ _, hsc X w⟩

/-! ### Generator Graph

The **generator graph** is a directed graph on generators where there is an edge
from `(Y, z)` to `(X, w)` iff `(Y, z)` covers `(X, w)`. A covering set is
exactly a **dominating set** in this graph (every vertex is either in the set
or adjacent to a vertex in the set).

This bridges presheaf theory to combinatorial optimization on graphs. -/

/-- The **generator graph** of a presheaf model. Vertices are generators,
    edges represent the covering relation. -/
structure GenGraph (M : PresheafModel) where
  /-- There is an edge from generator g₁ to generator g₂ when g₁ covers
      the element represented by g₂. -/
  adj : Generator M → Generator M → Prop := fun g₁ g₂ =>
    M.hasRestriction g₂.1 g₁.1 ∧ M.restrict g₂.1 g₁.1 g₁.2 = g₂.2

/-- The standard generator graph with the default adjacency. -/
def stdGenGraph (M : PresheafModel) : GenGraph M where
  adj g₁ g₂ := M.hasRestriction g₂.1 g₁.1 ∧ M.restrict g₂.1 g₁.1 g₁.2 = g₂.2

/-- A set of vertices is **dominating** if every vertex is either in the set
    or adjacent to some vertex in the set. -/
def IsDominatingSet (M : PresheafModel) (G : GenGraph M) (S : Finset (Generator M)) : Prop :=
  ∀ v : Generator M, v ∈ S ∨ ∃ u ∈ S, G.adj u v

/-- A covering set is a dominating set in the standard generator graph
    (when the model is self-covering). -/
theorem covering_iff_dominating (M : PresheafModel) (hsc : IsSelfCovering M)
    (S : Finset (Generator M)) :
    IsCoveringSet M S ↔ IsDominatingSet M (stdGenGraph M) S := by
  constructor
  · intro hcov v
    obtain ⟨g, hg_mem, hg_cov⟩ := hcov v.1 v.2
    by_cases heq : g = v
    · left; rw [← heq]; exact hg_mem
    · right; exact ⟨g, hg_mem, hg_cov⟩
  · intro hdom X w
    have hv := hdom ⟨X, w⟩
    rcases hv with h | ⟨u, hu_mem, hu_adj⟩
    · exact ⟨⟨X, w⟩, h, hsc X w⟩
    · exact ⟨u, hu_mem, hu_adj⟩

/-! ### Minimum Cover Size -/

/-- The set of cardinalities of covering sets. -/
def coveringSizes (M : PresheafModel) : Set ℕ :=
  {k : ℕ | ∃ S : Finset (Generator M), S.card = k ∧ IsCoveringSet M S}

/-- If the model is self-covering, there exists at least one covering set. -/
theorem coveringSizes_nonempty (M : PresheafModel) (hsc : IsSelfCovering M) :
    (coveringSizes M).Nonempty :=
  ⟨_, _, rfl, fullSet_isCovering M hsc⟩

/-- The **minimum cover size**: the smallest cardinality of a covering set.
    This is the key quantity in Categorical Shannon Theory. -/
def minCoverSize (M : PresheafModel) : ℕ :=
  sInf (coveringSizes M)

/-- The minimum cover size is at most the cardinality of any covering set. -/
theorem minCoverSize_le_of_covering (M : PresheafModel)
    (S : Finset (Generator M)) (hS : IsCoveringSet M S) :
    minCoverSize M ≤ S.card :=
  Nat.sInf_le ⟨S, rfl, hS⟩

/-- The minimum cover size is at most the total number of elements. -/
theorem minCoverSize_le_totalElements (M : PresheafModel) (hsc : IsSelfCovering M) :
    minCoverSize M ≤ totalElements M := by
  calc minCoverSize M ≤ Finset.univ.card :=
        minCoverSize_le_of_covering M _ (fullSet_isCovering M hsc)
    _ = Fintype.card (Generator M) := Finset.card_univ
    _ = totalElements M := by simp [totalElements, Element, Generator]

/-! ### Discrete Model

A **discrete model** has restrictions only from objects to themselves (identity
morphisms only). This is the categorical analogue of a discrete category.
In this model, no compression is possible. -/

/-- A model is **discrete** if the only restrictions are self-restrictions
    (identity morphisms). -/
def IsDiscreteModel (M : PresheafModel) : Prop :=
  ∀ X Y : M.Ob, M.hasRestriction X Y → X = Y

/-! ### Terminal Source Model

A model with a **terminal source** has a distinguished object `T` such that
every other object has a restriction from `T`. When the restriction maps from
`T` are surjective, generators at `T` alone suffice. -/

/-- A model has a **terminal source** `T` if every object admits a restriction
    from `T`. -/
def IsTerminalSource (M : PresheafModel) (T : M.Ob) : Prop :=
  ∀ X : M.Ob, M.hasRestriction X T

/-- The restrictions from a terminal source `T` are **surjective** if every
    element at any object is in the image of the restriction from `T`. -/
def TerminalSurjective (M : PresheafModel) (T : M.Ob) : Prop :=
  ∀ (X : M.Ob) (w : M.F X), ∃ z : M.F T, M.restrict X T z = w

end