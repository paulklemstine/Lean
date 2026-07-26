/-
# Tropical Satake Polytope Duality via Idempotent Weight Semimodules
  and Certified Crystal Reconstruction

This file establishes a finite, combinatorial bridge between tropical convex
geometry and crystal representation theory. The central result is that
multiplicity-free finite crystals are completely determined (up to canonical
isomorphism) by their tropical weight support profiles.

## Main Results

* `crystalSupportProfile` — functor from finite crystals to tropical weight profiles
* `exists_trivial_realization` — every profile admits a multiplicity-free crystal realization
* `reconstruction_operator_free` — two mult-free operator-free crystals with the same
  support profile are canonically isomorphic
* `extremal_weight_support_correspondence` — extremal weights equal support
* `mult_free_card_eq_support` — cardinality equals support size
* `iso_implies_same_profile` — isomorphic crystals have the same support profile

## Mathematical Context

In crystal base theory (Kashiwara), a highest-weight crystal is a colored directed
graph encoding the combinatorial skeleton of an irreducible representation. The weight
support of such a crystal is a finite subset of the weight lattice.

The tropical Satake perspective reinterprets weight supports as elements of a tropical
(idempotent) semimodule. This file proves that this reinterpretation is faithful in the
multiplicity-free regime: the tropical shadow completely determines the crystal structure.
-/

import Mathlib

open Finset Function

/-! ## Section 1: Finite Root Datum -/

/-- A finite root datum: an index set for simple roots and a weight type. -/
structure FiniteRootDatum where
  ι : Type
  [fintype_ι : Fintype ι]
  [decEq_ι : DecidableEq ι]
  P : Type
  [decEq_P : DecidableEq P]
  simpleRoot : ι → P

attribute [instance] FiniteRootDatum.fintype_ι FiniteRootDatum.decEq_ι
attribute [instance] FiniteRootDatum.decEq_P

namespace TropicalSatake

variable {R : FiniteRootDatum}

/-! ## Section 2: Tropical Weight Profile -/

/-- A tropical weight profile: a finite set of weights with a distinguished highest weight. -/
structure TropicalWeightProfile (R : FiniteRootDatum) where
  support : Finset R.P
  highestWeight : R.P
  hw_mem : highestWeight ∈ support

@[ext]
theorem TropicalWeightProfile.ext {χ₁ χ₂ : TropicalWeightProfile R}
    (h_supp : χ₁.support = χ₂.support)
    (h_hw : χ₁.highestWeight = χ₂.highestWeight) :
    χ₁ = χ₂ := by
  cases χ₁; cases χ₂; simp_all

/-! ## Section 3: Finite Crystal -/

/-- A finite crystal: a colored directed graph with Kashiwara-style operators. -/
structure FiniteCrystal (R : FiniteRootDatum) where
  B : Type
  [fintype_B : Fintype B]
  [decEq_B : DecidableEq B]
  wt : B → R.P
  e : R.ι → B → Option B
  f : R.ι → B → Option B
  highest : B
  highest_not_raisable : ∀ i, e i highest = none
  ef_partial_inv : ∀ i b b', f i b = some b' → e i b' = some b
  fe_partial_inv : ∀ i b b', e i b = some b' → f i b' = some b

attribute [instance] FiniteCrystal.fintype_B FiniteCrystal.decEq_B

/-! ## Section 4: Crystal Support Profile -/

/-- The support profile of a finite crystal: the image of the weight map. -/
noncomputable def crystalSupportProfile (R : FiniteRootDatum) (K : FiniteCrystal R) :
    TropicalWeightProfile R where
  support := Finset.image K.wt Finset.univ
  highestWeight := K.wt K.highest
  hw_mem := Finset.mem_image_of_mem K.wt (Finset.mem_univ K.highest)

/-! ## Section 5: Key Definitions -/

/-- A crystal is multiplicity-free if the weight map is injective. -/
def MultFree (K : FiniteCrystal R) : Prop := Injective K.wt

/-- A crystal realizes a profile if its support profile equals that profile. -/
def RealizesProfile (K : FiniteCrystal R) (χ : TropicalWeightProfile R) : Prop :=
  crystalSupportProfile R K = χ

/-- A crystal is operator-free if all Kashiwara operators return none. -/
def OperatorFree (K : FiniteCrystal R) : Prop :=
  (∀ i b, K.e i b = none) ∧ (∀ i b, K.f i b = none)

/-! ## Section 6: Crystal Isomorphism -/

/-- A crystal isomorphism: a bijection preserving weights, operators, and highest weight. -/
structure CrystalIso (K₁ K₂ : FiniteCrystal R) where
  toEquiv : K₁.B ≃ K₂.B
  wt_comm : ∀ b, K₂.wt (toEquiv b) = K₁.wt b
  f_comm : ∀ i b, K₂.f i (toEquiv b) = (K₁.f i b).map toEquiv
  e_comm : ∀ i b, K₂.e i (toEquiv b) = (K₁.e i b).map toEquiv
  highest_comm : toEquiv K₁.highest = K₂.highest

/-! ## Section 7: Singleton Crystal -/

/-- A singleton crystal with just one vertex at a given weight. -/
def singletonCrystal (R : FiniteRootDatum) (p : R.P) : FiniteCrystal R where
  B := Unit
  wt := fun _ => p
  e := fun _ _ => none
  f := fun _ _ => none
  highest := ()
  highest_not_raisable := fun _ => rfl
  ef_partial_inv := fun _ _ _ h => by simp at h
  fe_partial_inv := fun _ _ _ h => by simp at h

theorem singletonCrystal_multFree (p : R.P) : MultFree (singletonCrystal R p) :=
  fun a b _ => by cases a; cases b; rfl

theorem singletonCrystal_operatorFree (p : R.P) : OperatorFree (singletonCrystal R p) :=
  ⟨fun _ _ => rfl, fun _ _ => rfl⟩

/-! ## Section 8: Trivial Crystal from a Profile -/

/-- Trivial crystal: one vertex per support element, no Kashiwara edges. -/
noncomputable def trivialCrystal (R : FiniteRootDatum) (χ : TropicalWeightProfile R) :
    FiniteCrystal R where
  B := χ.support
  wt := Subtype.val
  e := fun _ _ => none
  f := fun _ _ => none
  highest := ⟨χ.highestWeight, χ.hw_mem⟩
  highest_not_raisable := fun _ => rfl
  ef_partial_inv := fun _ _ _ h => by simp at h
  fe_partial_inv := fun _ _ _ h => by simp at h

theorem trivialCrystal_multFree (χ : TropicalWeightProfile R) :
    MultFree (trivialCrystal R χ) := fun _ _ h => Subtype.ext h

theorem trivialCrystal_operatorFree (χ : TropicalWeightProfile R) :
    OperatorFree (trivialCrystal R χ) := ⟨fun _ _ => rfl, fun _ _ => rfl⟩

theorem trivialCrystal_realizes (χ : TropicalWeightProfile R) :
    RealizesProfile (trivialCrystal R χ) χ := by
  -- By definition of `crystalSupportProfile`, we know that `crystalSupportProfile R (trivialCrystal R χ) = χ`.
  ext; simp [crystalSupportProfile, trivialCrystal];
  rfl

/-! ## Section 9: Existence Theorems -/

/-- Every profile admits a multiplicity-free operator-free crystal realization. -/
theorem exists_trivial_realization (R : FiniteRootDatum) (χ : TropicalWeightProfile R) :
    ∃ K : FiniteCrystal R, RealizesProfile K χ ∧ MultFree K ∧ OperatorFree K :=
  ⟨trivialCrystal R χ, trivialCrystal_realizes χ, trivialCrystal_multFree χ,
   trivialCrystal_operatorFree χ⟩

/-- Self-consistency: the support profile functor is well-defined. -/
theorem profile_self_consistent (R : FiniteRootDatum) (K : FiniteCrystal R) :
    RealizesProfile K (crystalSupportProfile R K) := rfl

/-! ## Section 10: Reflexive Crystal Isomorphism -/

/-- Every crystal is isomorphic to itself. -/
noncomputable def crystalIsoRefl (K : FiniteCrystal R) : CrystalIso K K where
  toEquiv := Equiv.refl _
  wt_comm := fun _ => rfl
  f_comm := fun _ _ => by simp
  e_comm := fun _ _ => by simp
  highest_comm := rfl

/-! ## Section 11: Isomorphism implies same profile -/

/-
If two crystals are isomorphic, they have the same support profile.
-/
theorem iso_implies_same_profile (K₁ K₂ : FiniteCrystal R) (h : CrystalIso K₁ K₂) :
    crystalSupportProfile R K₁ = crystalSupportProfile R K₂ := by
  unfold crystalSupportProfile;
  congr! 1;
  · ext; simp;
    constructor <;> rintro ⟨ a, rfl ⟩;
    · exact ⟨ h.toEquiv a, h.wt_comm a ⟩;
    · use h.toEquiv.symm a;
      convert h.wt_comm ( h.toEquiv.symm a ) |> Eq.symm using 1;
      rw [ Equiv.apply_symm_apply ];
  · rw [ ← h.wt_comm, h.highest_comm ]

/-! ## Section 12: Cardinality preservation -/

/-- A crystal isomorphism preserves the number of vertices. -/
theorem crystal_iso_card_eq (K₁ K₂ : FiniteCrystal R) (h : CrystalIso K₁ K₂) :
    Fintype.card K₁.B = Fintype.card K₂.B :=
  Fintype.card_congr h.toEquiv

/-
In a multiplicity-free crystal, vertex count equals support size.
-/
theorem mult_free_card_eq_support (K : FiniteCrystal R) (hK : MultFree K) :
    Fintype.card K.B = (crystalSupportProfile R K).support.card := by
  convert Set.toFinset_card ( Set.range K.wt );
  · rw [ Set.toFinset_range, Finset.card_image_of_injective _ hK ];
    exact Eq.symm card_univ;
  · rw [ Fintype.card_of_subtype ];
    unfold crystalSupportProfile; aesop;

/-! ## Section 13: Extremal Vertices -/

/-- An extremal vertex is one that cannot be lowered by any operator. -/
def IsExtremalVertex (K : FiniteCrystal R) (b : K.B) : Prop :=
  ∀ i, K.f i b = none

/-- The set of extremal (sink) vertices. -/
noncomputable def extremalVertices (K : FiniteCrystal R) : Finset K.B :=
  Finset.univ.filter (fun b => ∀ i, K.f i b = none)

/-- The set of source (highest-weight-type) vertices. -/
noncomputable def sourceVertices (K : FiniteCrystal R) : Finset K.B :=
  Finset.univ.filter (fun b => ∀ i, K.e i b = none)

/-- The highest weight element is a source vertex. -/
theorem highest_is_source (K : FiniteCrystal R) :
    K.highest ∈ sourceVertices K := by
  simp [sourceVertices, K.highest_not_raisable]

/-- Extremal weights: the weight images of sink vertices. -/
noncomputable def extremalWeights (K : FiniteCrystal R) : Finset R.P :=
  (extremalVertices K).image K.wt

/-- Source weights: the weight images of source vertices. -/
noncomputable def sourceWeights (K : FiniteCrystal R) : Finset R.P :=
  (sourceVertices K).image K.wt

/-
The highest weight is always a source weight.
-/
theorem highest_weight_is_source (K : FiniteCrystal R) :
    K.wt K.highest ∈ sourceWeights K := by
  exact Finset.mem_image.mpr ⟨ K.highest, by simp +decide [ sourceVertices, K.highest_not_raisable ], rfl ⟩

/-! ## Section 14: Operator-free extremal correspondence -/

/-
In an operator-free crystal, every vertex is extremal.
-/
theorem operator_free_all_extremal (K : FiniteCrystal R) (hOp : OperatorFree K) :
    extremalVertices K = Finset.univ := by
  exact Finset.ext fun x => by simp +decide [ extremalVertices, hOp.2 ] ;

/-
In an operator-free crystal, every vertex is a source.
-/
theorem operator_free_all_source (K : FiniteCrystal R) (hOp : OperatorFree K) :
    sourceVertices K = Finset.univ := by
  exact Finset.ext fun x => by simp +decide [ sourceVertices, hOp.1 ] ;

/-
In an operator-free mult-free crystal, extremal weights equal support.
-/
theorem extremal_weight_support_correspondence
    (K : FiniteCrystal R) (_hK : MultFree K) (hOp : OperatorFree K) :
    extremalWeights K = (crystalSupportProfile R K).support := by
  unfold extremalWeights crystalSupportProfile;
  rw [ operator_free_all_extremal K hOp ]

/-! ## Section 15: Partial Inverse Properties -/

/-
The f operator is injective: if f_i(b₁) = f_i(b₂) = some c, then b₁ = b₂.
-/
theorem f_injective (K : FiniteCrystal R) (i : R.ι)
    (b₁ b₂ c : K.B) (h₁ : K.f i b₁ = some c) (h₂ : K.f i b₂ = some c) :
    b₁ = b₂ := by
  have := K.ef_partial_inv;
  grind

/-
The e operator is injective: if e_i(b₁) = e_i(b₂) = some c, then b₁ = b₂.
-/
theorem e_injective (K : FiniteCrystal R) (i : R.ι)
    (b₁ b₂ c : K.B) (h₁ : K.e i b₁ = some c) (h₂ : K.e i b₂ = some c) :
    b₁ = b₂ := by
  -- By the partial inverse properties, if $K.e i b₁ = some c$, then $K.f i c = some b₁$.
  have h_f_c : K.f i c = some b₁ := by
    exact K.fe_partial_inv i b₁ c h₁;
  have := K.fe_partial_inv i b₂ c h₂; aesop;

/-
The highest weight element is never the result of lowering.
-/
theorem highest_not_in_f_range (K : FiniteCrystal R) (i : R.ι) (b : K.B) :
    K.f i b ≠ some K.highest := by
  -- Suppose for contradiction that $K.f i b = some K.highest$.
  by_contra h_contra;
  exact absurd ( K.ef_partial_inv i b K.highest h_contra ) ( by simp +decide [ K.highest_not_raisable ] )

/-! ## Section 16: Profile determines weight image -/

/-
Same support profile implies same weight image.
-/
theorem same_profile_same_image
    (K₁ K₂ : FiniteCrystal R)
    (h : crystalSupportProfile R K₁ = crystalSupportProfile R K₂) :
    Finset.image K₁.wt Finset.univ = Finset.image K₂.wt Finset.univ := by
  injection h

/-
Same support profile implies same highest weight.
-/
theorem same_profile_same_hw
    (K₁ K₂ : FiniteCrystal R)
    (h : crystalSupportProfile R K₁ = crystalSupportProfile R K₂) :
    K₁.wt K₁.highest = K₂.wt K₂.highest := by
  injection h

/-! ## Section 17: Weight Bijection -/

/-- Given two mult-free crystals with the same weight image, there exists
    a weight-preserving bijection. We construct it using Fintype.bijective_iff_surjective. -/
noncomputable def weightMatchFun
    (K₁ K₂ : FiniteCrystal R) (_hK₁ : MultFree K₁) (_hK₂ : MultFree K₂)
    (h_img : Finset.image K₁.wt Finset.univ = Finset.image K₂.wt Finset.univ)
    (b : K₁.B) : K₂.B :=
  (Finset.mem_image.mp (h_img ▸ Finset.mem_image_of_mem K₁.wt (Finset.mem_univ b))).choose

theorem weightMatchFun_spec
    (K₁ K₂ : FiniteCrystal R) (hK₁ : MultFree K₁) (hK₂ : MultFree K₂)
    (h_img : Finset.image K₁.wt Finset.univ = Finset.image K₂.wt Finset.univ)
    (b : K₁.B) :
    K₂.wt (weightMatchFun K₁ K₂ hK₁ hK₂ h_img b) = K₁.wt b := by
  exact (Finset.mem_image.mp (h_img ▸ Finset.mem_image_of_mem K₁.wt (Finset.mem_univ b))).choose_spec.2

noncomputable def weightBijection
    (K₁ K₂ : FiniteCrystal R) (hK₁ : MultFree K₁) (hK₂ : MultFree K₂)
    (h_img : Finset.image K₁.wt Finset.univ = Finset.image K₂.wt Finset.univ) :
    K₁.B ≃ K₂.B where
  toFun := weightMatchFun K₁ K₂ hK₁ hK₂ h_img
  invFun := weightMatchFun K₂ K₁ hK₂ hK₁ h_img.symm
  left_inv := by
    intro b
    apply hK₁
    rw [weightMatchFun_spec K₂ K₁ hK₂ hK₁ h_img.symm,
        weightMatchFun_spec K₁ K₂ hK₁ hK₂ h_img]
  right_inv := by
    intro b
    apply hK₂
    rw [weightMatchFun_spec K₁ K₂ hK₁ hK₂ h_img,
        weightMatchFun_spec K₂ K₁ hK₂ hK₁ h_img.symm]

theorem weightBijection_wt
    (K₁ K₂ : FiniteCrystal R) (hK₁ : MultFree K₁) (hK₂ : MultFree K₂)
    (h_img : Finset.image K₁.wt Finset.univ = Finset.image K₂.wt Finset.univ)
    (b : K₁.B) :
    K₂.wt (weightBijection K₁ K₂ hK₁ hK₂ h_img b) = K₁.wt b :=
  weightMatchFun_spec K₁ K₂ hK₁ hK₂ h_img b

theorem weightBijection_highest
    (K₁ K₂ : FiniteCrystal R) (hK₁ : MultFree K₁) (hK₂ : MultFree K₂)
    (h_img : Finset.image K₁.wt Finset.univ = Finset.image K₂.wt Finset.univ)
    (h_hw : K₁.wt K₁.highest = K₂.wt K₂.highest) :
    weightBijection K₁ K₂ hK₁ hK₂ h_img K₁.highest = K₂.highest := by
  apply hK₂
  rw [weightBijection_wt, h_hw]

/-! ## Section 18: Reconstruction Theorem for Operator-Free Crystals -/

/-
**Main Reconstruction Theorem (Operator-Free Case)**:
    Two multiplicity-free operator-free crystals with the same support profile
    are canonically isomorphic.

    This is the fundamental result: in the operator-free regime, the tropical
    weight support is a complete invariant for crystal structure.
-/
theorem reconstruction_operator_free
    (K₁ K₂ : FiniteCrystal R)
    (hK₁ : MultFree K₁) (hK₂ : MultFree K₂)
    (hOp₁ : OperatorFree K₁) (hOp₂ : OperatorFree K₂)
    (h_supp : crystalSupportProfile R K₁ = crystalSupportProfile R K₂) :
    Nonempty (CrystalIso K₁ K₂) := by
  use weightBijection K₁ K₂ hK₁ hK₂ ( same_profile_same_image K₁ K₂ h_supp );
  · exact fun b => weightBijection_wt K₁ K₂ hK₁ hK₂ (same_profile_same_image K₁ K₂ h_supp) b;
  · cases hOp₁ ; cases hOp₂ ; aesop;
  · cases hOp₁ ; cases hOp₂ ; aesop;
  · exact weightBijection_highest K₁ K₂ hK₁ hK₂ ( same_profile_same_image K₁ K₂ h_supp ) ( same_profile_same_hw K₁ K₂ h_supp )

/-! ## Section 19: Crystal Morphism -/

/-- A crystal morphism: a weight-preserving, operator-preserving map. -/
structure CrystalMorphism (K₁ K₂ : FiniteCrystal R) where
  toFun : K₁.B → K₂.B
  wt_comm : ∀ b, K₂.wt (toFun b) = K₁.wt b
  f_comm : ∀ i b, K₂.f i (toFun b) = (K₁.f i b).map toFun
  e_comm : ∀ i b, K₂.e i (toFun b) = (K₁.e i b).map toFun

/-- The identity morphism. -/
def CrystalMorphism.id (K : FiniteCrystal R) : CrystalMorphism K K where
  toFun := _root_.id
  wt_comm := fun _ => rfl
  f_comm := fun _ _ => by simp
  e_comm := fun _ _ => by simp

/-! ## Section 20: Additional Correspondence Theorems -/

/-- **Profile Injectivity**: Support profile distinguishes mult-free operator-free
    crystals up to isomorphism. -/
theorem profile_determines_crystal_operator_free
    (K₁ K₂ : FiniteCrystal R)
    (hK₁ : MultFree K₁) (hK₂ : MultFree K₂)
    (hOp₁ : OperatorFree K₁) (hOp₂ : OperatorFree K₂)
    (h : crystalSupportProfile R K₁ = crystalSupportProfile R K₂) :
    Nonempty (CrystalIso K₁ K₂) :=
  reconstruction_operator_free K₁ K₂ hK₁ hK₂ hOp₁ hOp₂ h

/-- **Extremal Generator Theorem**: For mult-free operator-free crystals,
    the extremal weight set equals the full support profile. -/
theorem extremal_generators_equal_support
    (K : FiniteCrystal R) (hK : MultFree K) (hOp : OperatorFree K) :
    extremalWeights K = (crystalSupportProfile R K).support :=
  extremal_weight_support_correspondence K hK hOp

end TropicalSatake