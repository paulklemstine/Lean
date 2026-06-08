/-
  # Idempotent Causal Holography via Closure Lightcone Semimodules

  This file formalizes a finite reconstruction theorem for causal closure systems.
  Given a finite poset C (the causal order) and a boundary subset B, we show that
  the bulk causal order can be canonically recovered from boundary past/future
  profile data.

  ## Main results

  * `order_embedding_of_separating_profiles` — Under separation and order reflection
    hypotheses, the profile map is an order embedding into compatible profile pairs.
  * `reconstructs_bulk_from_boundary_profiles` — Under interval generation, we get
    a full order isomorphism: the bulk IS the boundary profile poset.
  * `cover_reconstruction` — Cover relations are preserved and reflected.
  * `interval_reconstruction` — Alexandrov intervals are faithfully reconstructed.
-/

import Mathlib

open Finset

/-! ## Core definitions -/

/-- A boundary antichain: no two distinct elements of B are comparable. -/
def isBoundaryAntichain {α : Type*} [PartialOrder α] (B : Finset α) : Prop :=
  ∀ ⦃x y⦄, x ∈ B → y ∈ B → x ≤ y → x = y

section Profiles

variable {α : Type*} [PartialOrder α] [DecidableEq α] [DecidableRel (α := α) (· ≤ ·)]

/-- Past profile: boundary elements below x. -/
def pastProfile (B : Finset α) (x : α) : Finset α :=
  B.filter (fun b => b ≤ x)

/-- Future profile: boundary elements above x. -/
def futureProfile (B : Finset α) (x : α) : Finset α :=
  B.filter (fun b => x ≤ b)

/-- The bi-profile map. -/
def profilePair (B : Finset α) (x : α) :
    Finset α × Finset α :=
  (pastProfile B x, futureProfile B x)

end Profiles

/-- Separation: profilePair is injective. -/
def separates_bulk {α : Type*} [PartialOrder α] [DecidableEq α]
    [DecidableRel (α := α) (· ≤ ·)] (B : Finset α) : Prop :=
  Function.Injective (profilePair B)

/-- The profile order: covariant in past, contravariant in future. -/
def profileLE {α : Type*} :
    (Finset α × Finset α) → (Finset α × Finset α) → Prop
  | (p₁, f₁), (p₂, f₂) => p₁ ⊆ p₂ ∧ f₂ ⊆ f₁

/-- A profile pair is compatible if every past boundary element
    is below every future boundary element. -/
def profile_compatible {α : Type*} [PartialOrder α]
    (B : Finset α) (q : Finset α × Finset α) : Prop :=
  ∀ ⦃bp bf⦄, bp ∈ q.1 → bf ∈ q.2 → bp ≤ bf

/-- Interval generation: every compatible profile pair with components in B is realized. -/
def interval_generated {α : Type*} [PartialOrder α] [DecidableEq α]
    [DecidableRel (α := α) (· ≤ ·)] (B : Finset α) : Prop :=
  ∀ q, profile_compatible B q → q.1 ⊆ B → q.2 ⊆ B → ∃ x, profilePair B x = q

/-- The set of reconstructed points: compatible profile pairs with components in B. -/
def reconstructedPoints {α : Type*} [PartialOrder α] [DecidableEq α] (B : Finset α) :=
  {q : Finset α × Finset α // profile_compatible B q ∧ q.1 ⊆ B ∧ q.2 ⊆ B}

/-- Cover relation: x < y with nothing strictly between. -/
def isCoverRel {α : Type*} [PartialOrder α] (x y : α) : Prop :=
  x < y ∧ ¬∃ z, x < z ∧ z < y

/-- Alexandrov interval. -/
def alexandrovInterval {α : Type*} [PartialOrder α] (x y : α) : Set α :=
  {z | x ≤ z ∧ z ≤ y}

/-! ## Helper lemmas -/

variable {α : Type*} [PartialOrder α] [DecidableEq α] [DecidableRel (α := α) (· ≤ ·)]

/-- Past profiles are monotone. -/
theorem pastProfile_mono
    (B : Finset α) {x y : α} (hxy : x ≤ y) :
    pastProfile B x ⊆ pastProfile B y := by
  exact fun z hz =>
    Finset.mem_filter.mpr ⟨(Finset.mem_filter.mp hz).1,
      le_trans (Finset.mem_filter.mp hz).2 hxy⟩

/-- Future profiles are antitone. -/
theorem futureProfile_anti
    (B : Finset α) {x y : α} (hxy : x ≤ y) :
    futureProfile B y ⊆ futureProfile B x := by
  exact fun z hz =>
    Finset.mem_filter.mpr ⟨(Finset.mem_filter.mp hz).1,
      le_trans hxy (Finset.mem_filter.mp hz).2⟩

/-- profilePair preserves the order in the profileLE sense. -/
theorem profilePair_mono
    (B : Finset α) {x y : α} (hxy : x ≤ y) :
    profileLE (profilePair B x) (profilePair B y) :=
  ⟨pastProfile_mono B hxy, futureProfile_anti B hxy⟩

/-- Every point's profile pair is compatible. -/
theorem profile_compatible_of_point
    (B : Finset α) (x : α) :
    profile_compatible B (profilePair B x) :=
  fun _ _ hbp hbf =>
    (Finset.mem_filter.mp hbp).2.trans (Finset.mem_filter.mp hbf).2

/-- Past profile is a subset of B. -/
theorem pastProfile_subset
    (B : Finset α) (x : α) :
    pastProfile B x ⊆ B :=
  Finset.filter_subset _ _

/-- Future profile is a subset of B. -/
theorem futureProfile_subset
    (B : Finset α) (x : α) :
    futureProfile B x ⊆ B :=
  Finset.filter_subset _ _

/-- The profile data for a point satisfies all conditions for reconstructedPoints. -/
theorem profilePair_mem_reconstructed
    (B : Finset α) (x : α) :
    profile_compatible B (profilePair B x) ∧
    (profilePair B x).1 ⊆ B ∧ (profilePair B x).2 ⊆ B :=
  ⟨profile_compatible_of_point B x, pastProfile_subset B x, futureProfile_subset B x⟩

/-! ## Partial order instance on reconstructedPoints -/

set_option linter.unusedSectionVars false in
@[ext]
theorem reconstructedPoints_ext {B : Finset α} {a b : reconstructedPoints B}
    (h : a.1 = b.1) : a = b :=
  Subtype.ext h

instance reconstructedPoints_partialOrder
    (B : Finset α) : PartialOrder (reconstructedPoints B) where
  le := fun a b => profileLE a.1 b.1
  le_refl := fun a => ⟨Finset.Subset.refl _, Finset.Subset.refl _⟩
  le_trans := fun a b c hab hbc =>
    ⟨Finset.Subset.trans hab.1 hbc.1, Finset.Subset.trans hbc.2 hab.2⟩
  le_antisymm := fun a b hab hba => by
    apply reconstructedPoints_ext
    exact Prod.ext (Finset.Subset.antisymm hab.1 hba.1) (Finset.Subset.antisymm hba.2 hab.2)

/-- Helper to construct a reconstructed point from a bulk point. -/
def toReconstructed (B : Finset α) (x : α) : reconstructedPoints B :=
  ⟨profilePair B x, profilePair_mem_reconstructed B x⟩

/-
The profile map preserves order.
-/
theorem toReconstructed_le_iff
    (B : Finset α)
    (hreflect :
      ∀ x y : α,
        x ≤ y ↔
          pastProfile B x ⊆ pastProfile B y ∧
          futureProfile B y ⊆ futureProfile B x)
    (x y : α) :
    toReconstructed B x ≤ toReconstructed B y ↔ x ≤ y := by
  exact iff_comm.mp (hreflect x y)

/-
The profile map is injective under the separation hypothesis.
-/
theorem toReconstructed_injective
    (B : Finset α) (hsep : separates_bulk B) :
    Function.Injective (toReconstructed B) := by
  intro x y hxy;
  exact hsep ( Subtype.ext_iff.mp hxy )

/-
The profile map strictly preserves order.
-/
theorem toReconstructed_lt_iff
    (B : Finset α)
    (_hsep : separates_bulk B)
    (hreflect :
      ∀ x y : α,
        x ≤ y ↔
          pastProfile B x ⊆ pastProfile B y ∧
          futureProfile B y ⊆ futureProfile B x)
    (x y : α) :
    toReconstructed B x < toReconstructed B y ↔ x < y := by
  rw [ lt_iff_le_not_ge, lt_iff_le_not_ge ];
  -- Apply the toReconstructed_le_iff theorem to both parts of the conjunction.
  simp [toReconstructed_le_iff B hreflect]

/-
The profile map is surjective under interval generation.
-/
theorem toReconstructed_surjective
    (B : Finset α) (hgen : interval_generated B) :
    Function.Surjective (toReconstructed B) := by
  intro q
  obtain ⟨x, hx⟩ := hgen q.1 q.2.1 q.2.2.1 q.2.2.2
  use x
  simp [hx, toReconstructed]

/-! ## Main theorems -/

/-
**Theorem 1**: Under separation and order reflection, profilePair is an order embedding
    into compatible profile pairs.
-/
theorem order_embedding_of_separating_profiles
    (B : Finset α)
    (_hB : isBoundaryAntichain B)
    (hsep : separates_bulk B)
    (hreflect :
      ∀ x y : α,
        x ≤ y ↔
          pastProfile B x ⊆ pastProfile B y ∧
          futureProfile B y ⊆ futureProfile B x) :
    ∃ f : α ↪o reconstructedPoints B,
      ∀ x, (f x).1 = profilePair B x := by
  refine' ⟨ _, _ ⟩;
  refine' { .. };
  exact fun x => ⟨ profilePair B x, profilePair_mem_reconstructed B x ⟩;
  any_goals intros; rfl;
  exact fun x y hxy => hsep <| by injection hxy;
  exact fun { a b } => toReconstructed_le_iff B hreflect a b

/-
**Theorem 2**: Under interval generation, the profile map is an order isomorphism.
    The bulk IS the boundary profile poset.
-/
theorem reconstructs_bulk_from_boundary_profiles
    [Finite α]
    (B : Finset α)
    (_hB : isBoundaryAntichain B)
    (hsep : separates_bulk B)
    (hgen : interval_generated B)
    (hreflect :
      ∀ x y : α,
        x ≤ y ↔
          pastProfile B x ⊆ pastProfile B y ∧
          futureProfile B y ⊆ futureProfile B x) :
    Nonempty (α ≃o reconstructedPoints B) := by
  refine' ⟨ Equiv.ofBijective _ ⟨ _, _ ⟩, _ ⟩;
  use toReconstructed B;
  exact toReconstructed_injective B hsep;
  exact toReconstructed_surjective B hgen;
  exact fun {a b} => iff_comm.mp (hreflect a b)

/-
**Theorem 3**: Cover relations in α correspond exactly to cover relations in the
    image of the profile map. The backward direction (cover in reconstructedPoints →
    cover in α) holds without interval generation; the full ↔ requires it.
-/
theorem cover_reconstruction
    [Finite α]
    (B : Finset α)
    (hsep : separates_bulk B)
    (hgen : interval_generated B)
    (hreflect :
      ∀ x y : α,
        x ≤ y ↔
          pastProfile B x ⊆ pastProfile B y ∧
          futureProfile B y ⊆ futureProfile B x) :
    ∀ x y : α,
      isCoverRel x y ↔
        isCoverRel (toReconstructed B x) (toReconstructed B y) := by
  intro x y;
  constructor;
  · rintro ⟨ hxy, h ⟩;
    refine' ⟨ _, _ ⟩;
    · exact toReconstructed_lt_iff B hsep hreflect x y |>.2 hxy;
    · contrapose! h;
      obtain ⟨ z, hz₁, hz₂ ⟩ := h;
      obtain ⟨ w, hw ⟩ := toReconstructed_surjective B hgen z;
      exact ⟨ w, by simpa [ hw ] using toReconstructed_lt_iff B hsep hreflect x w |>.1 ( by simpa [ hw ] using hz₁ ), by simpa [ hw ] using toReconstructed_lt_iff B hsep hreflect w y |>.1 ( by simpa [ hw ] using hz₂ ) ⟩;
  · intro h;
    constructor;
    · exact toReconstructed_lt_iff B hsep hreflect x y |>.1 h.1;
    · rintro ⟨ z, hxz, hzy ⟩;
      have hz : toReconstructed B x < toReconstructed B z ∧ toReconstructed B z < toReconstructed B y := by
        exact ⟨ toReconstructed_lt_iff B hsep hreflect x z |>.2 hxz, toReconstructed_lt_iff B hsep hreflect z y |>.2 hzy ⟩;
      exact h.2 ⟨ toReconstructed B z, hz.1, hz.2 ⟩

/-
**Theorem 4**: Alexandrov intervals are faithfully reconstructed under the
    full reconstruction hypotheses.
-/
theorem interval_reconstruction
    [Finite α]
    (B : Finset α)
    (_hsep : separates_bulk B)
    (hgen : interval_generated B)
    (hreflect :
      ∀ x y : α,
        x ≤ y ↔
          pastProfile B x ⊆ pastProfile B y ∧
          futureProfile B y ⊆ futureProfile B x)
    (x y : α) :
    (toReconstructed B) '' alexandrovInterval x y =
    alexandrovInterval (toReconstructed B x) (toReconstructed B y) := by
  apply Set.ext
  intro q
  simp [alexandrovInterval];
  constructor;
  · rintro ⟨ z, ⟨ hxz, hzy ⟩, rfl ⟩;
    exact ⟨ toReconstructed_le_iff B hreflect x z |>.2 hxz, toReconstructed_le_iff B hreflect z y |>.2 hzy ⟩;
  · intro hq;
    obtain ⟨ z, hz ⟩ := toReconstructed_surjective B hgen q;
    exact ⟨ z, ⟨ by simpa [ hz ] using toReconstructed_le_iff B hreflect x z |>.1 ( hz ▸ hq.1 ), by simpa [ hz ] using toReconstructed_le_iff B hreflect z y |>.1 ( hz ▸ hq.2 ) ⟩, hz ⟩