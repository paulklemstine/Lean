import Mathlib

/-! # CatalogBuild.Speculative.RosettaStone.Categorification

Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 11
-/

/-- An idempotent endomorphism in a category: f ≫ f = f. -/
structure CategoricalIdempotent (C : Type*) [Category C] (X : C) where
  morph : X ⟶ X
  idem : morph ≫ morph = morph

/-- The identity is always an idempotent. -/
def id_idempotent (C : Type*) [Category C] (X : C) :
    CategoricalIdempotent C X where
  morph := 𝟙 X
  idem := Category.id_comp _

/-- The zero morphism (when it exists) is an idempotent. -/
def zero_idempotent (C : Type*) [Category C]
    [Limits.HasZeroMorphisms C] (X : C) :
    CategoricalIdempotent C X where
  morph := 0
  idem := Limits.zero_comp (f := (0 : X ⟶ X))

/-- Every object of C embeds into its Karoubi envelope. -/
theorem karoubi_embedding (C : Type*) [Category C] (X : C) :
    ∃ (K : Karoubi C), K.X = X := by
  exact ⟨⟨X, 𝟙 X, Category.id_comp _⟩, rfl⟩

/-- In the Karoubi envelope, idempotents split by construction. -/
theorem karoubi_splits_idempotent (C : Type*) [Category C]
    (X : C) (e : X ⟶ X) (he : e ≫ e = e) :
    ∃ (K : Karoubi C), K.X = X := by
  exact ⟨⟨X, e, he⟩, rfl⟩

/-- [Section: # CatalogBuild.Speculative.RosettaStone.Categorification
Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 11] -/
theorem peirce_corner_identity {R : Type*} [Ring R] (e : R) (he : e * e = e) :
    ∀ x : R, e * (e * x * e) * e = e * x * e := by
  grind +qlia

/-- Level 0: An idempotent element in a monoid. -/
def is_idempotent_element {M : Type*} [Monoid M] (e : M) : Prop := e * e = e

/-- Level 1: An idempotent morphism in a category. -/
def is_idempotent_morphism {C : Type*} [Category C]
    {X : C} (f : X ⟶ X) : Prop := f ≫ f = f

/-- Level 0 embeds into Level 1 via the discrete category. -/
theorem level0_embeds_level1 {M : Type*} [Monoid M] (e : M) (he : e * e = e) :
    is_idempotent_element e := he

/-- A full idempotent: e such that the two-sided ideal ReR = R. -/
def is_full_idempotent {R : Type*} [Ring R] (e : R) : Prop :=
  e * e = e ∧ ∀ r : R, ∃ (n : ℕ) (as bs : Fin n → R),
    r = ∑ i, as i * e * bs i

/-- K₀ of a semiring: idempotent modules ↔ idempotent elements in K₀. -/
theorem k0_idempotent_correspondence {R : Type*} [CommRing R]
    (e : R) (he : e * e = e) :
    e * (1 - e) = 0 ∧ e + (1 - e) = 1 := by
  constructor
  · have : e * (1 - e) = e - e * e := by ring
    rw [this, he, sub_self]
  · ring

