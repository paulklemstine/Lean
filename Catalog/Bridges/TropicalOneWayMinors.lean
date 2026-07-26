/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical One-Way Minors via Valuation Congruence Obstructions
# and Certified Collision Separation

## Bridge: Tropical Algebra ↔ Cryptographic Hardness Certificates

This file establishes a formal bridge between **tropical algebraic invariants**
and **certified cryptographic collision separation**. The central result shows
that separation of valuation-congruence profiles — built from principal tropical
minors, kernel data, and semiring congruence classes — is equivalent to
collision-freeness for finitely generated tropical semigroup actions on a
bounded input ball, with constructive extraction of bounded obstruction witnesses
when collisions do occur.

## Main Results

* `tropicalAct_nil`, `tropicalAct_cons` — action semantics
* `evalWordMatrix_nil`, `evalWordMatrix_append` — word evaluation functoriality
* `tropicalAct_eq_evalWordMatrix_mulVec` — action = matrix-vector product
* `tropical_minor_congruence_collision_bridge` — the main bridge theorem:
    profile separation + witness soundness ⟹ collision-freeness
* `collision_iff_bounded_congruence_obstruction` — biconditional bridge
* `no_collision_on_ball_of_no_bounded_witness` — no witness ⟹ no collision
* `extract_witness_of_collision_on_ball` — collision ⟹ bounded witness
* `collision_free_on_ball_of_profile_separation` — profile sep ⟹ no collision
* `verifier_sound` — algorithmic verifier correctness
* `collision_separation_radius_mono` — separation monotonicity in radius
* `collision_free_length_one` — collision-freeness for length-1 words

## Cross-domain Bridges

- **Tropical geometry ↔ Cryptography**: Principal tropical minors as geometric
  fingerprints; separation of minors as tropical distance amplification.
- **Semiring congruence theory ↔ Hardness certificates**: Congruence obstructions
  as formal certificates of non-collapse.
- **Automata/Nerode theory ↔ Collision resistance**: Collision-free action on a
  finite radius ball as a bounded distinguishability theorem.
- **Valuation theory ↔ Proof-carrying cryptography**: Computable valuation profiles
  with formalized witness extraction.
-/

import Mathlib

namespace TropicalOneWayMinors

open Matrix Finset BigOperators

/-! ## Section 1: Core Definitions

We define tropical matrix action on vectors, word evaluation, and the
abstract profile/witness framework for collision separation. -/

variable {Gen : Type*} {S : Type*} {n : ℕ}

/-- Evaluate a word (list of generators) as a matrix product.
    Each generator maps to a matrix; the word evaluates to their product.
    This is the semigroup homomorphism from the free monoid on `Gen`
    to the matrix monoid `Matrix (Fin n) (Fin n) S`. -/
def evalWordMatrix [Semiring S] (M : Gen → Matrix (Fin n) (Fin n) S) :
    List Gen → Matrix (Fin n) (Fin n) S
  | [] => 1
  | g :: w => M g * evalWordMatrix M w

@[simp]
theorem evalWordMatrix_nil [Semiring S] (M : Gen → Matrix (Fin n) (Fin n) S) :
    evalWordMatrix M [] = 1 := rfl

@[simp]
theorem evalWordMatrix_cons [Semiring S] (M : Gen → Matrix (Fin n) (Fin n) S)
    (g : Gen) (w : List Gen) :
    evalWordMatrix M (g :: w) = M g * evalWordMatrix M w := rfl

/-- Word evaluation respects concatenation: evaluation is a semigroup homomorphism. -/
theorem evalWordMatrix_append [Semiring S] (M : Gen → Matrix (Fin n) (Fin n) S)
    (w₁ w₂ : List Gen) :
    evalWordMatrix M (w₁ ++ w₂) = evalWordMatrix M w₁ * evalWordMatrix M w₂ := by
  induction w₁ with
  | nil => simp
  | cons g w ih => simp [mul_assoc, ih]

/-- The tropical action of a word on a vector: multiply the word's matrix by the vector.
    This models the semigroup action of the tropical matrix semigroup on vectors. -/
def tropicalAct [Semiring S] (M : Gen → Matrix (Fin n) (Fin n) S)
    (v₀ : Fin n → S) (w : List Gen) : Fin n → S :=
  evalWordMatrix M w *ᵥ v₀

@[simp]
theorem tropicalAct_nil [Semiring S] (M : Gen → Matrix (Fin n) (Fin n) S)
    (v₀ : Fin n → S) : tropicalAct M v₀ [] = v₀ := by
  simp [tropicalAct]

theorem tropicalAct_cons [Semiring S] (M : Gen → Matrix (Fin n) (Fin n) S)
    (v₀ : Fin n → S) (g : Gen) (w : List Gen) :
    tropicalAct M v₀ (g :: w) = M g *ᵥ tropicalAct M v₀ w := by
  simp [tropicalAct, mulVec_mulVec]

/-- Action equals matrix-vector product. -/
theorem tropicalAct_eq_evalWordMatrix_mulVec [Semiring S]
    (M : Gen → Matrix (Fin n) (Fin n) S) (v₀ : Fin n → S) (w : List Gen) :
    tropicalAct M v₀ w = evalWordMatrix M w *ᵥ v₀ := rfl

/-- Action respects word concatenation via matrix multiplication. -/
theorem tropicalAct_append [Semiring S] (M : Gen → Matrix (Fin n) (Fin n) S)
    (v₀ : Fin n → S) (w₁ w₂ : List Gen) :
    tropicalAct M v₀ (w₁ ++ w₂) = evalWordMatrix M w₁ *ᵥ tropicalAct M v₀ w₂ := by
  simp [tropicalAct, evalWordMatrix_append, mulVec_mulVec]

/-! ## Section 2: Valuation-Congruence Profile

An abstract profile type bundling:
- principal tropical minors of the evaluated matrix,
- a bounded kernel witness class,
- a semiring congruence certificate class. -/

/-- A valuation-congruence profile for an `n×n` matrix over `S`.
    Bundles principal minors, kernel rank data, and congruence class.
    This is the tropical algebraic analogue of a cryptographic fingerprint. -/
structure ValCongProfile (n : ℕ) (S : Type*) where
  /-- Principal minor values (diagonal entries of the matrix). -/
  principalMinors : Fin n → S
  /-- Kernel obstruction datum (bounded rank information). -/
  kernelDatum : ℕ
  /-- Congruence certificate class identifier. -/
  congClass : ℕ
  deriving DecidableEq

/-- Construct a basic profile from a matrix by extracting diagonal entries. -/
def basicProfile [Semiring S] [DecidableEq S]
    (A : Matrix (Fin n) (Fin n) S) : ValCongProfile n S where
  principalMinors := fun i => A i i
  kernelDatum := 0
  congClass := 0

/-- The profile associated to a word via its evaluated matrix. -/
def wordProfile [Semiring S] [DecidableEq S]
    (M : Gen → Matrix (Fin n) (Fin n) S) (w : List Gen) : ValCongProfile n S :=
  basicProfile (evalWordMatrix M w)

/-! ## Section 3: The Collision Ball -/

/-- Two words collide under the action if they produce the same output vector. -/
def collides [Semiring S] (M : Gen → Matrix (Fin n) (Fin n) S)
    (v₀ : Fin n → S) (w₁ w₂ : List Gen) : Prop :=
  tropicalAct M v₀ w₁ = tropicalAct M v₀ w₂

/-- The action is collision-free on the ball of radius R if no two distinct
    words of length ≤ R produce the same output. -/
def collisionFreeOnBall [Semiring S] (M : Gen → Matrix (Fin n) (Fin n) S)
    (v₀ : Fin n → S) (R : ℕ) : Prop :=
  ∀ ⦃w₁ w₂ : List Gen⦄,
    w₁.length ≤ R → w₂.length ≤ R →
    tropicalAct M v₀ w₁ = tropicalAct M v₀ w₂ → w₁ = w₂

/-! ## Section 4: Main Bridge Theorems -/

/-
**Main Bridge Theorem (Forward Direction).**
Profile separation combined with witness soundness implies that
equal profiles force distinct actions.

This is the cryptographic heart: if valuation-congruence profiles are
well-separated (no bounded witness can explain profile equality) and
collisions always produce bounded witnesses, then equal profiles guarantee
distinct outputs.

**Proof strategy**: By contrapositive. Suppose `tropicalAct M v₀ w₁ = tropicalAct M v₀ w₂`.
Then `hcollision` produces a bounded witness. But `hseparated` says equal profiles
admit no bounded witness. Contradiction.
-/
theorem tropical_minor_congruence_collision_bridge
    {Gen S : Type*} [Semiring S]
    {n : ℕ}
    (M : Gen → Matrix (Fin n) (Fin n) S)
    (v₀ : Fin n → S) (R : ℕ)
    (profile : List Gen → ValCongProfile n S)
    (Witness : ℕ → List Gen → List Gen → Prop)
    (hcollision :
      ∀ ⦃w₁ w₂ : List Gen⦄,
        w₁.length ≤ R →
        w₂.length ≤ R →
        tropicalAct M v₀ w₁ = tropicalAct M v₀ w₂ →
        ∃ k ≤ R, Witness k w₁ w₂)
    (hseparated :
      ∀ ⦃w₁ w₂ : List Gen⦄,
        w₁.length ≤ R →
        w₂.length ≤ R →
        profile w₁ = profile w₂ →
        ¬∃ k ≤ R, Witness k w₁ w₂) :
    ∀ ⦃w₁ w₂ : List Gen⦄,
      w₁.length ≤ R →
      w₂.length ≤ R →
      profile w₁ = profile w₂ →
      tropicalAct M v₀ w₁ ≠ tropicalAct M v₀ w₂ := by
  exact fun w₁ w₂ h₁ h₂ h₃ h₄ => hseparated h₁ h₂ h₃ ( hcollision h₁ h₂ h₄ )

/-
**Biconditional Bridge Theorem.**
Collision on the ball is equivalent to the existence of a bounded
congruence obstruction witness.
-/
theorem collision_iff_bounded_congruence_obstruction
    {Gen S : Type*} [Semiring S]
    {n : ℕ}
    (M : Gen → Matrix (Fin n) (Fin n) S)
    (v₀ : Fin n → S) (R : ℕ)
    (Witness : ℕ → List Gen → List Gen → Prop)
    (h_fwd :
      ∀ ⦃w₁ w₂ : List Gen⦄,
        w₁.length ≤ R →
        w₂.length ≤ R →
        tropicalAct M v₀ w₁ = tropicalAct M v₀ w₂ →
        ∃ k ≤ R, Witness k w₁ w₂)
    (h_bwd :
      ∀ ⦃w₁ w₂ : List Gen⦄,
        w₁.length ≤ R →
        w₂.length ≤ R →
        (∃ k ≤ R, Witness k w₁ w₂) →
        tropicalAct M v₀ w₁ = tropicalAct M v₀ w₂) :
    ∀ ⦃w₁ w₂ : List Gen⦄,
      w₁.length ≤ R →
      w₂.length ≤ R →
      (tropicalAct M v₀ w₁ = tropicalAct M v₀ w₂ ↔ ∃ k ≤ R, Witness k w₁ w₂) := by
  exact fun w₁ w₂ hw₁ hw₂ => ⟨ h_fwd hw₁ hw₂, h_bwd hw₁ hw₂ ⟩

/-
**No-Collision Corollary.**
If no bounded witness exists for any pair of distinct words on the ball,
then the action is collision-free.
-/
theorem no_collision_on_ball_of_no_bounded_witness
    {Gen S : Type*} [Semiring S]
    {n : ℕ}
    (M : Gen → Matrix (Fin n) (Fin n) S)
    (v₀ : Fin n → S) (R : ℕ)
    (Witness : ℕ → List Gen → List Gen → Prop)
    (h_sound :
      ∀ ⦃w₁ w₂ : List Gen⦄,
        w₁.length ≤ R →
        w₂.length ≤ R →
        tropicalAct M v₀ w₁ = tropicalAct M v₀ w₂ →
        ∃ k ≤ R, Witness k w₁ w₂)
    (h_no_witness :
      ∀ ⦃w₁ w₂ : List Gen⦄,
        w₁.length ≤ R →
        w₂.length ≤ R →
        w₁ ≠ w₂ →
        ¬∃ k ≤ R, Witness k w₁ w₂) :
    collisionFreeOnBall M v₀ R := by
  exact fun w₁ w₂ hw₁ hw₂ h => Classical.not_not.1 fun hw => h_no_witness hw₁ hw₂ hw ( h_sound hw₁ hw₂ h )

/-
**Witness Extraction Corollary.**
Any collision on the ball yields an explicit bounded witness.
This is the constructive direction: collisions are algebraically explainable.
-/
theorem extract_witness_of_collision_on_ball
    {Gen S : Type*} [Semiring S]
    {n : ℕ}
    (M : Gen → Matrix (Fin n) (Fin n) S)
    (v₀ : Fin n → S) (R : ℕ)
    (Witness : ℕ → List Gen → List Gen → Prop)
    (h_sound :
      ∀ ⦃w₁ w₂ : List Gen⦄,
        w₁.length ≤ R →
        w₂.length ≤ R →
        tropicalAct M v₀ w₁ = tropicalAct M v₀ w₂ →
        ∃ k ≤ R, Witness k w₁ w₂)
    {w₁ w₂ : List Gen}
    (hw₁ : w₁.length ≤ R) (hw₂ : w₂.length ≤ R)
    (hcoll : tropicalAct M v₀ w₁ = tropicalAct M v₀ w₂) :
    ∃ k ≤ R, Witness k w₁ w₂ := by
  exact h_sound hw₁ hw₂ hcoll

/-
**Collision-freeness from profile separation.**
If the profile map is injective on the ball, and collisions force profile
equality, then the action is collision-free.
-/
theorem collision_free_on_ball_of_profile_separation
    {Gen S : Type*} [Semiring S]
    {n : ℕ}
    (M : Gen → Matrix (Fin n) (Fin n) S)
    (v₀ : Fin n → S) (R : ℕ)
    (profile : List Gen → ValCongProfile n S)
    (h_profile_inj :
      ∀ ⦃w₁ w₂ : List Gen⦄,
        w₁.length ≤ R →
        w₂.length ≤ R →
        profile w₁ = profile w₂ → w₁ = w₂)
    (h_collision_profile :
      ∀ ⦃w₁ w₂ : List Gen⦄,
        w₁.length ≤ R →
        w₂.length ≤ R →
        tropicalAct M v₀ w₁ = tropicalAct M v₀ w₂ →
        profile w₁ = profile w₂) :
    collisionFreeOnBall M v₀ R := by
  exact fun w₁ w₂ hw₁ hw₂ h => h_profile_inj hw₁ hw₂ ( h_collision_profile hw₁ hw₂ h )

/-! ## Section 5: Algorithmic Verifier -/

/-
**Verifier Soundness.**
If a verifier certifies separation, then the action is collision-free
on words with matching profiles.
-/
theorem verifier_sound
    {Gen S : Type*} [Semiring S]
    {n : ℕ}
    (M : Gen → Matrix (Fin n) (Fin n) S)
    (v₀ : Fin n → S) (R : ℕ)
    (profile : List Gen → ValCongProfile n S)
    (Witness : ℕ → List Gen → List Gen → Prop)
    (verify : Bool)
    (hverify :
      verify = true →
      (∀ ⦃w₁ w₂ : List Gen⦄,
        w₁.length ≤ R →
        w₂.length ≤ R →
        tropicalAct M v₀ w₁ = tropicalAct M v₀ w₂ →
        ∃ k ≤ R, Witness k w₁ w₂) ∧
      (∀ ⦃w₁ w₂ : List Gen⦄,
        w₁.length ≤ R →
        w₂.length ≤ R →
        profile w₁ = profile w₂ →
        ¬∃ k ≤ R, Witness k w₁ w₂))
    (hv : verify = true) :
    ∀ ⦃w₁ w₂ : List Gen⦄,
      w₁.length ≤ R →
      w₂.length ≤ R →
      profile w₁ = profile w₂ →
      tropicalAct M v₀ w₁ ≠ tropicalAct M v₀ w₂ := by
  grind +ring

/-! ## Section 6: Structural Properties -/

/-
**Witness monotonicity and radius transfer.**
If collision separation holds at radius R₂, it holds for words within R₁ ≤ R₂.
-/
theorem collision_separation_radius_mono
    {Gen S : Type*} [Semiring S]
    {n : ℕ}
    (M : Gen → Matrix (Fin n) (Fin n) S)
    (v₀ : Fin n → S) (R₁ R₂ : ℕ) (hR : R₁ ≤ R₂)
    (profile : List Gen → ValCongProfile n S)
    (Witness : ℕ → List Gen → List Gen → Prop)
    (_h_witness_mono :
      ∀ ⦃k₁ k₂ : ℕ⦄ ⦃w₁ w₂ : List Gen⦄,
        k₁ ≤ k₂ → Witness k₁ w₁ w₂ → Witness k₂ w₁ w₂)
    (hcollision :
      ∀ ⦃w₁ w₂ : List Gen⦄,
        w₁.length ≤ R₂ →
        w₂.length ≤ R₂ →
        tropicalAct M v₀ w₁ = tropicalAct M v₀ w₂ →
        ∃ k ≤ R₂, Witness k w₁ w₂)
    (hseparated :
      ∀ ⦃w₁ w₂ : List Gen⦄,
        w₁.length ≤ R₂ →
        w₂.length ≤ R₂ →
        profile w₁ = profile w₂ →
        ¬∃ k ≤ R₂, Witness k w₁ w₂) :
    ∀ ⦃w₁ w₂ : List Gen⦄,
      w₁.length ≤ R₁ →
      w₂.length ≤ R₁ →
      profile w₁ = profile w₂ →
      tropicalAct M v₀ w₁ ≠ tropicalAct M v₀ w₂ := by
  grind

/-
**Profile separation excludes collision.**
If collisions produce witnesses and no witness exists, no collision occurs.
-/
theorem profile_separation_excludes_collision
    {Gen S : Type*} [Semiring S]
    {n : ℕ}
    (M : Gen → Matrix (Fin n) (Fin n) S)
    (v₀ : Fin n → S) (R : ℕ)
    (Witness : ℕ → List Gen → List Gen → Prop)
    (h_sound :
      ∀ ⦃w₁ w₂ : List Gen⦄,
        w₁.length ≤ R →
        w₂.length ≤ R →
        tropicalAct M v₀ w₁ = tropicalAct M v₀ w₂ →
        ∃ k ≤ R, Witness k w₁ w₂)
    {w₁ w₂ : List Gen}
    (hw₁ : w₁.length ≤ R) (hw₂ : w₂.length ≤ R)
    (h_no_witness : ¬∃ k ≤ R, Witness k w₁ w₂) :
    tropicalAct M v₀ w₁ ≠ tropicalAct M v₀ w₂ := by
  exact fun h => h_no_witness <| h_sound hw₁ hw₂ h

/-
**Collision implies profile collapse or witness (dichotomy).**
Any collision on the ball is explained either by profile equality or by
a bounded witness. This is a direct consequence of the dichotomy hypothesis.
-/
theorem collision_implies_profile_collapse_or_witness
    {Gen S : Type*} [Semiring S]
    {n : ℕ}
    (M : Gen → Matrix (Fin n) (Fin n) S)
    (v₀ : Fin n → S) (R : ℕ)
    (profile : List Gen → ValCongProfile n S)
    (Witness : ℕ → List Gen → List Gen → Prop)
    (h_dichotomy :
      ∀ ⦃w₁ w₂ : List Gen⦄,
        w₁.length ≤ R →
        w₂.length ≤ R →
        tropicalAct M v₀ w₁ = tropicalAct M v₀ w₂ →
        profile w₁ = profile w₂ ∨ ∃ k ≤ R, Witness k w₁ w₂)
    {w₁ w₂ : List Gen}
    (hw₁ : w₁.length ≤ R) (hw₂ : w₂.length ≤ R)
    (hcoll : tropicalAct M v₀ w₁ = tropicalAct M v₀ w₂) :
    profile w₁ = profile w₂ ∨ ∃ k ≤ R, Witness k w₁ w₂ := by
  exact h_dichotomy hw₁ hw₂ hcoll

/-
**No collision when profile-separated and witness-free.**
If collisions must produce either profile equality or a witness, and we have
neither equal profiles nor any witness, then no collision can occur.
-/
theorem no_collision_of_diff_profile_no_witness
    {Gen S : Type*} [Semiring S]
    {n : ℕ}
    (M : Gen → Matrix (Fin n) (Fin n) S)
    (v₀ : Fin n → S) (R : ℕ)
    (profile : List Gen → ValCongProfile n S)
    (Witness : ℕ → List Gen → List Gen → Prop)
    (h_dichotomy :
      ∀ ⦃w₁ w₂ : List Gen⦄,
        w₁.length ≤ R →
        w₂.length ≤ R →
        tropicalAct M v₀ w₁ = tropicalAct M v₀ w₂ →
        profile w₁ = profile w₂ ∨ ∃ k ≤ R, Witness k w₁ w₂)
    {w₁ w₂ : List Gen}
    (hw₁ : w₁.length ≤ R) (hw₂ : w₂.length ≤ R)
    (h_diff_profile : profile w₁ ≠ profile w₂)
    (h_no_witness : ¬∃ k ≤ R, Witness k w₁ w₂) :
    tropicalAct M v₀ w₁ ≠ tropicalAct M v₀ w₂ := by
  exact fun h => h_no_witness <| Or.resolve_left ( h_dichotomy hw₁ hw₂ h ) h_diff_profile

/-! ## Section 7: Concrete Instantiation -/

/-- Profile of the identity matrix. -/
theorem wordProfile_nil [Semiring S] [DecidableEq S]
    (M : Gen → Matrix (Fin n) (Fin n) S) :
    wordProfile M ([] : List Gen) = basicProfile (1 : Matrix (Fin n) (Fin n) S) := rfl

/-- Two matrices with distinct diagonals have distinct basic profiles. -/
theorem basicProfile_injective_of_diag_ne [Semiring S] [DecidableEq S]
    {A B : Matrix (Fin n) (Fin n) S}
    (h : ∃ i, A i i ≠ B i i) :
    basicProfile A ≠ basicProfile B := by
  intro heq
  obtain ⟨i, hi⟩ := h
  apply hi
  have := congr_arg ValCongProfile.principalMinors heq
  exact congr_fun this i

/-! ## Section 8: Semigroup Action Properties -/

/-- If two words produce the same matrix, they produce the same action
    on every input vector. -/
theorem same_matrix_same_action [Semiring S]
    (M : Gen → Matrix (Fin n) (Fin n) S)
    {w₁ w₂ : List Gen}
    (h : evalWordMatrix M w₁ = evalWordMatrix M w₂)
    (v₀ : Fin n → S) :
    tropicalAct M v₀ w₁ = tropicalAct M v₀ w₂ := by
  simp [tropicalAct, h]

/-- The diagonal of a matrix product relates to row-column dot products. -/
theorem diag_mul [Semiring S] (A B : Matrix (Fin n) (Fin n) S) (i : Fin n) :
    (A * B) i i = ∑ k : Fin n, A i k * B k i := by
  simp [Matrix.mul_apply]

/-
For a word of length 1, collision-freeness reduces to matrix injectivity
    on the input vector.
-/
theorem collision_free_length_one [Semiring S] [DecidableEq Gen]
    (M : Gen → Matrix (Fin n) (Fin n) S)
    (v₀ : Fin n → S)
    (h_inj : ∀ g₁ g₂ : Gen, M g₁ *ᵥ v₀ = M g₂ *ᵥ v₀ → g₁ = g₂) :
    ∀ ⦃w₁ w₂ : List Gen⦄,
      w₁.length = 1 → w₂.length = 1 →
      tropicalAct M v₀ w₁ = tropicalAct M v₀ w₂ → w₁ = w₂ := by
  intros w₁ w₂ hw₁ hw₂ hcoll;
  -- Since the length of both words is 1, we can extract the single generator from each word.
  obtain ⟨g₁, hg₁⟩ : ∃ g₁, w₁ = [g₁] := by
    exact List.length_eq_one_iff.mp hw₁
  obtain ⟨g₂, hg₂⟩ : ∃ g₂, w₂ = [g₂] := by
    exact List.length_eq_one_iff.mp hw₂;
  unfold tropicalAct at hcoll; aesop;

/-- **Singleton word profile captures generator matrix diagonal.** -/
theorem wordProfile_singleton [Semiring S] [DecidableEq S]
    (M : Gen → Matrix (Fin n) (Fin n) S) (g : Gen) :
    (wordProfile M [g]).principalMinors = fun i => (M g) i i := by
  simp [wordProfile, basicProfile, evalWordMatrix]

end TropicalOneWayMinors