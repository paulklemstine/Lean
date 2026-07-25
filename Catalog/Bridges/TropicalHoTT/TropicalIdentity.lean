/-
# Tropical Path-Indiscernibility as an Identity Shadow

This file establishes the tropical analogue of path-indiscernibility from
Homotopy Type Theory. In classical HoTT, identity of points is captured
by path types; here we replace paths with min-plus equidistance relations.

Two points in a finite weighted space are "tropically indiscernible" if they
have identical distance profiles to all other points. We prove this is an
equivalence relation, and that it coincides with equality under a separation
axiom — giving a concrete, decidable replacement for identity types.

## Main results

* `tropicallyIndiscernible_refl` — reflexivity
* `tropicallyIndiscernible_symm` — symmetry
* `tropicallyIndiscernible_trans` — transitivity
* `tropicallyIndiscernible_eq_of_separating` — coincides with equality under separation
* `tropicallyIndiscernible_equivalence` — bundled equivalence relation
* `tropicallyIndiscernible_decidable` — decidability on finite types
-/

import Mathlib

/-! ## Core Definitions -/

/-- The equidistance profile of a point `x` in a weighted space.
    This is the tropical shadow of a "loop space at x": the function recording
    how x interacts with every other point via distance. -/
def profile {α : Type*} (d : α → α → ℝ) (x : α) : α → ℝ := fun z => d x z

/-- Two points are tropically indiscernible if they have identical distance
    profiles — they interact identically with every other point in the space.
    This is the tropical analogue of path-connectedness / identity. -/
def TropicallyIndiscernible {α : Type*} (d : α → α → ℝ) (x y : α) : Prop :=
  ∀ z, d x z = d y z

/-- A distance function is separating if tropical indiscernibility implies equality.
    This is the tropical analogue of the identity of indiscernibles. -/
def IsSeparating {α : Type*} (d : α → α → ℝ) : Prop :=
  ∀ x y, (∀ z, d x z = d y z) → x = y

/-- A tropical pseudo-metric satisfies reflexivity, symmetry, and the
    tropical triangle inequality (min-plus version of the triangle inequality). -/
def IsTropicalPseudoMetric {α : Type*} (d : α → α → ℝ) : Prop :=
  (∀ x, d x x = 0) ∧
  (∀ x y, d x y = d y x) ∧
  (∀ x y z, d x z ≤ d x y + d y z)

/-! ## Equivalence Relation Theorems -/

/-
Tropical indiscernibility is reflexive: every point has the same distance
    profile as itself. This is the tropical analogue of `refl` for paths.
-/
theorem tropicallyIndiscernible_refl
    {α : Type*} (d : α → α → ℝ) (x : α) :
    TropicallyIndiscernible d x x := by
  exact fun _ => rfl

/-
Tropical indiscernibility is symmetric: if x is indiscernible from y,
    then y is indiscernible from x. Tropical analogue of path inversion.
-/
theorem tropicallyIndiscernible_symm
    {α : Type*} (d : α → α → ℝ) {x y : α} :
    TropicallyIndiscernible d x y → TropicallyIndiscernible d y x := by
  exact fun h z => h z ▸ rfl

/-
Tropical indiscernibility is transitive: if x ≈ y and y ≈ z then x ≈ z.
    Tropical analogue of path concatenation.
-/
theorem tropicallyIndiscernible_trans
    {α : Type*} (d : α → α → ℝ) {x y z : α} :
    TropicallyIndiscernible d x y →
    TropicallyIndiscernible d y z →
    TropicallyIndiscernible d x z := by
  exact fun h1 h2 w => h1 w ▸ h2 w ▸ rfl

/-
Under a separation axiom, tropical indiscernibility coincides with equality.
    This is the tropical identity of indiscernibles: the fundamental bridge between
    the tropical shadow and actual mathematical identity.
-/
theorem tropicallyIndiscernible_eq_of_separating
    {α : Type*} [Fintype α] (d : α → α → ℝ)
    (hsep : ∀ x y, (∀ z, d x z = d y z) → x = y) :
    ∀ x y, TropicallyIndiscernible d x y ↔ x = y := by
  exact fun x y => ⟨ fun h => hsep x y h, fun h => h ▸ fun z => rfl ⟩

/-
Tropical indiscernibility as a bundled equivalence relation.
-/
theorem tropicallyIndiscernible_equivalence
    {α : Type*} (d : α → α → ℝ) :
    Equivalence (TropicallyIndiscernible d) := by
  exact ⟨tropicallyIndiscernible_refl d,
    fun h => tropicallyIndiscernible_symm d h,
    fun h1 h2 => tropicallyIndiscernible_trans d h1 h2⟩

/-
Profile equality is equivalent to tropical indiscernibility.
-/
theorem profile_eq_iff_indiscernible
    {α : Type*} (d : α → α → ℝ) (x y : α) :
    profile d x = profile d y ↔ TropicallyIndiscernible d x y := by
  exact funext_iff

/-! ## Decidability -/

/-
Tropical indiscernibility is decidable on finite types with decidable
    distance equality. This is a key computational advantage of the tropical
    shadow over classical path types.
-/
instance tropicallyIndiscernible_decidable
    {α : Type*} [Fintype α] [DecidableEq α]
    (d : α → α → ℝ) [DecidableEq ℝ] (x y : α) :
    Decidable (TropicallyIndiscernible d x y) :=
  Fintype.decidableForallFintype

/-! ## Natural number version -/

/-- Tropical indiscernibility for ℕ-valued distance functions.
    This version is fully decidable without any additional instances. -/
def TropicallyIndiscernibleNat {α : Type*} (d : α → α → ℕ) (x y : α) : Prop :=
  ∀ z, d x z = d y z

theorem tropicallyIndiscernibleNat_refl
    {α : Type*} (d : α → α → ℕ) (x : α) :
    TropicallyIndiscernibleNat d x x := by
  exact fun _ => rfl

theorem tropicallyIndiscernibleNat_symm
    {α : Type*} (d : α → α → ℕ) {x y : α} :
    TropicallyIndiscernibleNat d x y → TropicallyIndiscernibleNat d y x := by
  exact fun h z => Eq.symm ( h z )

theorem tropicallyIndiscernibleNat_trans
    {α : Type*} (d : α → α → ℕ) {x y z : α} :
    TropicallyIndiscernibleNat d x y →
    TropicallyIndiscernibleNat d y z →
    TropicallyIndiscernibleNat d x z := by
  exact fun h1 h2 w => h1 w ▸ h2 w ▸ rfl

theorem tropicallyIndiscernibleNat_eq_of_separating
    {α : Type*} [Fintype α] (d : α → α → ℕ)
    (hsep : ∀ x y, (∀ z, d x z = d y z) → x = y) :
    ∀ x y, TropicallyIndiscernibleNat d x y ↔ x = y := by
  exact fun x y => ⟨ fun h => hsep x y h, fun h => h ▸ fun z => rfl ⟩

instance tropicallyIndiscernibleNat_decidable
    {α : Type*} [Fintype α] [DecidableEq α]
    (d : α → α → ℕ) (x y : α) :
    Decidable (TropicallyIndiscernibleNat d x y) :=
  Fintype.decidableForallFintype