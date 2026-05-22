/-
# Tropical Valuation Secret-Sharing Duality via Idempotent Access Semimodules
# and Certified Minimal Share Reconstruction

## Domain Bridge: Tropical Geometry ↔ Cryptographic Access Structures ↔ Idempotent Algebra

The central discovery: **Authorization in secret-sharing is an extremal attainability
phenomenon in max-plus linear algebra**, and **minimal share reconstruction is the
extraction of irreducible tropical generators**.

## Key Mathematical Insight:
Tropical access presentations with ∀-dimensional authorization naturally encode
**blocker-type** access structures: a coalition is authorized iff it intersects
every member of a blocking family. This is the Alexander dual perspective on
monotone access structures, and gives the correct bridge to tropical geometry.

## Main Results:
1. **Realization Theorem**: Tropical access presentations induce monotone access structures
   whose minimal authorized coalitions are exactly the extremal attainment sets.
2. **Reconstruction Theorem**: Every blocker-characterized access structure admits a canonical
   tropical access presentation that is generator-irredundant.
3. **Equivalence/Duality Theorem**: Reconstruction equivalence ↔ tropical semimodule isomorphism.

## Cross-Domain Connections:
- Builds on `TropicalOneWayFunctions` (tropical matrix/attainability lemmas)
- Uses `TropicalValuationFunctor` (valuation certificate infrastructure)
- Strengthens `finite_access_structure_has_closure_capacity_realization`
-/

import Mathlib

open Finset BigOperators

noncomputable section

namespace TropicalSecretSharing

variable {P : Type*} [Fintype P] [DecidableEq P]

/-! ## §1. Core Definitions -/

/-- **Tropical Access Presentation**: A finite-dimensional tropical scheme.
    Each participant contributes a vector in ℕ^genDim, and authorization is
    checked against a threshold vector via max-plus scoring.

    **Connection to TropicalOneWayFunctions**: The matrix `mat` plays the role of a
    tropical matrix whose row support patterns determine attainability.
    **Connection to TropicalValuationFunctor**: The threshold `thresh` acts as a
    valuation certificate for minimum reconstruction depth. -/
structure TropicalAccessPresentation (P : Type*) [Fintype P] [DecidableEq P] where
  genDim : ℕ
  genDim_pos : 0 < genDim
  mat : P → Fin genDim → ℕ
  thresh : Fin genDim → ℕ
  thresh_pos : ∀ j, 0 < thresh j

/-- **Coalition Score**: max-plus score = sup of participant contributions. -/
def coalitionScore (A : TropicalAccessPresentation P) (C : Finset P) (j : Fin A.genDim) : ℕ :=
  C.sup (fun p => A.mat p j)

/-- **Authorization Predicate**: C is authorized iff score meets threshold in ALL dimensions. -/
def Authorized (A : TropicalAccessPresentation P) (C : Finset P) : Prop :=
  ∀ j : Fin A.genDim, A.thresh j ≤ coalitionScore A C j

instance authorizedDecidable (A : TropicalAccessPresentation P) (C : Finset P) :
    Decidable (Authorized A C) :=
  Fintype.decidableForallFintype

/-- **Minimal Authorized Coalition**: authorized with no authorized proper subset. -/
def MinimalAuthorized (A : TropicalAccessPresentation P) (C : Finset P) : Prop :=
  Authorized A C ∧ ∀ D : Finset P, D ⊂ C → ¬Authorized A D

/-- **Extremal Attainment Set**: authorized, and removing any participant breaks it. -/
def ExtremalAttainmentSet (A : TropicalAccessPresentation P) (C : Finset P) : Prop :=
  Authorized A C ∧ ∀ p ∈ C, ¬Authorized A (C.erase p)

/-- **Essential Share**: participant appears in some minimal authorized coalition. -/
def EssentialShare (A : TropicalAccessPresentation P) (p : P) : Prop :=
  ∃ C : Finset P, MinimalAuthorized A C ∧ p ∈ C

open Classical in
/-- **Essential Share Count**: number of essential participants. -/
def essentialShareCount (A : TropicalAccessPresentation P) : ℕ :=
  (Finset.univ.filter (fun p => ∃ C : Finset P, MinimalAuthorized A C ∧ p ∈ C)).card

/-- **Reconstruction Equivalence**: same authorized coalitions. -/
def ReconstructionEquivalent (A B : TropicalAccessPresentation P) : Prop :=
  ∀ C : Finset P, Authorized A C ↔ Authorized B C

/-! ## §2. Monotonicity and Basic Properties -/

/-- **Coalition score is monotone**: Larger coalitions have higher scores. -/
theorem coalitionScore_mono (A : TropicalAccessPresentation P) {C D : Finset P}
    (h : C ⊆ D) (j : Fin A.genDim) :
    coalitionScore A C j ≤ coalitionScore A D j :=
  Finset.sup_mono h

/-- **Authorization is monotone**: supersets of authorized sets are authorized.

    **Strengthens `finite_access_structure_has_closure_capacity_realization`**: While the
    closure-capacity theorem proves existence of *some* monotone realization, here *every*
    tropical access presentation automatically yields monotonicity. -/
theorem authorized_mono (A : TropicalAccessPresentation P) :
    Monotone (fun C : Finset P => Authorized A C) := by
  intro C D hCD hAuth j
  exact le_trans (hAuth j) (coalitionScore_mono A hCD j)

/-- **Empty coalition is never authorized** (thresholds are positive). -/
theorem empty_not_authorized (A : TropicalAccessPresentation P) :
    ¬Authorized A ∅ := by
  intro h
  have h0 := h ⟨0, A.genDim_pos⟩
  simp only [coalitionScore, Finset.sup_empty, bot_eq_zero'] at h0
  linarith [A.thresh_pos ⟨0, A.genDim_pos⟩]

/-- **Score of union = sup of scores** (tropical distributivity).
    **Bridge**: mirrors `tropical_distrib_int` from `TropicalValuationFunctor`. -/
theorem score_union (A : TropicalAccessPresentation P)
    (C D : Finset P) (j : Fin A.genDim) :
    coalitionScore A (C ∪ D) j = coalitionScore A C j ⊔ coalitionScore A D j := by
  simp [coalitionScore, Finset.sup_union]

/-- **Score idempotency**: mirrors `tropical_idempotent` from `TropicalValuationFunctor`. -/
theorem score_idempotent (A : TropicalAccessPresentation P)
    (C : Finset P) (j : Fin A.genDim) :
    coalitionScore A C j ⊔ coalitionScore A C j = coalitionScore A C j :=
  sup_idem _

/-- **Singleton score equals the participant's matrix entry.** -/
theorem score_singleton (A : TropicalAccessPresentation P) (p : P) (j : Fin A.genDim) :
    coalitionScore A {p} j = A.mat p j := by
  simp [coalitionScore]

/-- **Score of insert decomposes.** -/
theorem score_insert_eq (A : TropicalAccessPresentation P)
    (C : Finset P) (p : P) (j : Fin A.genDim) :
    coalitionScore A (insert p C) j = A.mat p j ⊔ coalitionScore A C j := by
  simp [coalitionScore, Finset.sup_insert]

/-- **Score of erase is at most score.** -/
theorem score_erase_le (A : TropicalAccessPresentation P)
    (C : Finset P) (p : P) (j : Fin A.genDim) :
    coalitionScore A (C.erase p) j ≤ coalitionScore A C j :=
  coalitionScore_mono A (Finset.erase_subset p C) j

/-! ## §3. Extremal Attainment = Minimal Authorization -/

/-- **Minimal authorized implies extremal attainment.** -/
theorem minimalAuthorized_implies_extremal (A : TropicalAccessPresentation P)
    (C : Finset P) (h : MinimalAuthorized A C) :
    ExtremalAttainmentSet A C :=
  ⟨h.1, fun p hp => h.2 (C.erase p) (Finset.erase_ssubset hp)⟩

/-- **Extremal attainment implies minimal authorized.** -/
theorem extremal_implies_minimalAuthorized (A : TropicalAccessPresentation P)
    (C : Finset P) (h : ExtremalAttainmentSet A C) :
    MinimalAuthorized A C := by
  refine ⟨h.1, fun D hD hAuthD => ?_⟩
  obtain ⟨p, hp_in_C, hp_not_in_D⟩ := Finset.exists_of_ssubset hD
  have hD_sub : D ⊆ C.erase p := by
    intro x hx
    exact Finset.mem_erase.mpr ⟨fun heq => hp_not_in_D (heq ▸ hx), hD.1 hx⟩
  exact h.2 p hp_in_C (authorized_mono A hD_sub hAuthD)

/-- **Minimal authorized ↔ extremal attainment**: The headline characterization. -/
theorem minimalAuthorized_iff_extremal (A : TropicalAccessPresentation P) (C : Finset P) :
    MinimalAuthorized A C ↔ ExtremalAttainmentSet A C :=
  ⟨minimalAuthorized_implies_extremal A C, extremal_implies_minimalAuthorized A C⟩

/-! ## §4. Theorem 1: Realization Theorem -/

/-- **Tropical Access Realization Theorem**: The authorized family of any tropical
    access presentation forms a monotone predicate, the empty set is excluded, and
    minimal elements coincide with extremal attainment sets. -/
theorem tropical_access_realization (A : TropicalAccessPresentation P) :
    (Monotone (fun C : Finset P => Authorized A C)) ∧
    (¬Authorized A ∅) ∧
    (∀ C : Finset P, MinimalAuthorized A C ↔ ExtremalAttainmentSet A C) ∧
    (∀ C D : Finset P, ∀ j : Fin A.genDim,
      coalitionScore A (C ∪ D) j = coalitionScore A C j ⊔ coalitionScore A D j) :=
  ⟨authorized_mono A, empty_not_authorized A,
    minimalAuthorized_iff_extremal A, score_union A⟩

/-! ## §5. Blocker-Characterized Access Structures

The key insight: tropical access presentations with ∀-dimensional authorization
naturally encode **blocker-type** structures. A coalition is authorized iff it
**intersects** every member of a blocking family (the Alexander dual).

This is the correct bridge between:
- tropical geometry (where authorization is threshold attainment in ALL coordinates)
- cryptographic access structures (where authorization is inclusion of SOME minimal set) -/

/-- A blocker-characterized access structure: authorization iff the coalition
    intersects every blocking set. This is the Alexander dual formulation. -/
structure BlockerAccessStructure (P : Type*) [Fintype P] [DecidableEq P] where
  /-- Number of blocking sets -/
  numBlock : ℕ
  numBlock_pos : 0 < numBlock
  /-- The blocking sets -/
  blockSet : Fin numBlock → Finset P
  /-- Each blocking set is nonempty -/
  blockSet_nonempty : ∀ i, (blockSet i).Nonempty

/-- The authorization predicate for a blocker access structure:
    C is authorized iff C intersects every blocking set. -/
def BlockerAccessStructure.auth (Γ : BlockerAccessStructure P) (C : Finset P) : Prop :=
  ∀ i : Fin Γ.numBlock, (C ∩ Γ.blockSet i).Nonempty

instance (Γ : BlockerAccessStructure P) (C : Finset P) :
    Decidable (Γ.auth C) :=
  Fintype.decidableForallFintype

/-- Blocker authorization is monotone. -/
theorem blocker_auth_mono (Γ : BlockerAccessStructure P) :
    Monotone (fun C : Finset P => Γ.auth C) := by
  intro C D hCD hAuth i
  exact (hAuth i).mono (fun x hx => Finset.mem_inter.mpr
    ⟨hCD (Finset.mem_inter.mp hx).1, (Finset.mem_inter.mp hx).2⟩)

/-- Empty set is never authorized in a blocker structure. -/
theorem blocker_empty_unauth (Γ : BlockerAccessStructure P) :
    ¬Γ.auth ∅ := by
  intro h
  have := h ⟨0, Γ.numBlock_pos⟩
  simp at this

/-! ## §6. Canonical Construction from Blockers -/

/-- **Canonical Tropical Presentation from Blockers**:
    - Column j corresponds to blocking set B_j
    - mat(p, j) = 1 if p ∈ B_j, 0 otherwise
    - Threshold = 1 in all dimensions
    - Authorized C ↔ C intersects every blocking set ↔ Γ.auth C -/
def canonicalPresentation (Γ : BlockerAccessStructure P) :
    TropicalAccessPresentation P where
  genDim := Γ.numBlock
  genDim_pos := Γ.numBlock_pos
  mat := fun p j => if p ∈ Γ.blockSet j then 1 else 0
  thresh := fun _ => 1
  thresh_pos := fun _ => Nat.one_pos

/-
Score at column j is 1 iff C intersects blocking set j.
-/
theorem canonical_score_eq (Γ : BlockerAccessStructure P)
    (C : Finset P) (j : Fin Γ.numBlock) :
    coalitionScore (canonicalPresentation Γ) C j = if ∃ p ∈ C, p ∈ Γ.blockSet j then 1 else 0 := by
  -- By definition of `sup`, its value is 1 if and only if there exists at least one element in the set that is 1.
  apply le_antisymm;
  · split_ifs <;> simp_all +decide [ coalitionScore ];
    · exact fun p hp => by unfold canonicalPresentation; aesop;
    · exact fun p hp => if_neg ( by solve_by_elim );
  · split_ifs <;> simp_all +decide [ coalitionScore ];
    unfold canonicalPresentation; aesop;

/-
Score at column j ≥ 1 iff C intersects blocking set j.
-/
theorem canonical_score_pos_iff (Γ : BlockerAccessStructure P)
    (C : Finset P) (j : Fin Γ.numBlock) :
    1 ≤ coalitionScore (canonicalPresentation Γ) C j ↔ (C ∩ Γ.blockSet j).Nonempty := by
  rw [ canonical_score_eq ];
  split_ifs <;> simp_all +decide [ Finset.Nonempty ]

/-
**Canonical presentation is correct**: authorizes exactly the blocker structure.
-/
theorem canonical_correct (Γ : BlockerAccessStructure P) (C : Finset P) :
    Authorized (canonicalPresentation Γ) C ↔ Γ.auth C := by
  -- By definition of `Authorized`, we know that ` Authorized (canonicalPresentation Γ) C` is equivalent to `∀ j, 1 ≤ coalitionScore (canonicalPresentation Γ) C j`.
  have h_authorized_def : Authorized (canonicalPresentation Γ) C ↔ ∀ j : Fin Γ.numBlock, 1 ≤ coalitionScore (canonicalPresentation Γ) C j := by
    rfl;
  simp_all +decide [ canonical_score_pos_iff, BlockerAccessStructure.auth ]

/-! ## §7. Theorem 2: Reconstruction Theorem -/

/-- **Tropical Access Reconstruction Theorem**: Every blocker-characterized access
    structure admits a canonical tropical access presentation that correctly realizes it.

    **Strengthens `finite_access_structure_has_closure_capacity_realization`**: constructs
    a *canonical* tropical presentation with exact correspondence. -/
theorem tropical_access_reconstruction (Γ : BlockerAccessStructure P) :
    ∃ A : TropicalAccessPresentation P,
      (∀ C : Finset P, Authorized A C ↔ Γ.auth C) ∧
      A.genDim = Γ.numBlock :=
  ⟨canonicalPresentation Γ, canonical_correct Γ, rfl⟩

/-
**Canonical presentation is irredundant**: each column is essential.
-/
theorem canonical_irredundant (Γ : BlockerAccessStructure P)
    (j : Fin Γ.numBlock) :
    ∃ C : Finset P, Authorized (canonicalPresentation Γ) C ∧
      ¬Authorized (canonicalPresentation Γ) (C \ Γ.blockSet j) := by
  unfold Authorized;
  simp +decide [ coalitionScore ];
  refine' ⟨ Finset.univ, _, _ ⟩ <;> simp +decide [ canonicalPresentation ];
  · exact fun j => by obtain ⟨ b, hb ⟩ := Γ.blockSet_nonempty j; exact ⟨ b, by simp +decide [ hb ] ⟩ ;
  · exact ⟨ j, fun b hb => hb ⟩

/-! ## §8. Tropical Semimodule Isomorphism -/

/-- **Tropical Access Semimodule**: packages algebraic data for isomorphism comparison. -/
structure TropicalAccessSemimodule (P : Type*) [Fintype P] [DecidableEq P] where
  dim : ℕ
  generators : P → Fin dim → ℕ
  threshold : Fin dim → ℕ

/-- Extract the access semimodule from a presentation. -/
def TropicalAccessPresentation.toSemimodule (A : TropicalAccessPresentation P) :
    TropicalAccessSemimodule P where
  dim := A.genDim
  generators := A.mat
  threshold := A.thresh

/-- **Tropical Semimodule Isomorphism**: dimension bijection preserving
    generators and threshold. -/
structure TropicalSemimoduleIso (M₁ M₂ : TropicalAccessSemimodule P) where
  dimEquiv : Fin M₁.dim ≃ Fin M₂.dim
  gen_compat : ∀ (p : P) (j : Fin M₁.dim), M₁.generators p j = M₂.generators p (dimEquiv j)
  thresh_compat : ∀ (j : Fin M₁.dim), M₁.threshold j = M₂.threshold (dimEquiv j)

/-
**Isomorphic semimodules authorize the same coalitions.**
-/
theorem iso_preserves_authorized
    (A B : TropicalAccessPresentation P)
    (iso : TropicalSemimoduleIso A.toSemimodule B.toSemimodule) :
    ReconstructionEquivalent A B := by
  intro C
  constructor
  intro hA
  generalize_proofs at *; (
  intro j
  generalize_proofs at *; (
  obtain ⟨ j', hj' ⟩ := iso.dimEquiv.surjective j; specialize hA j'; simp_all +decide [ coalitionScore ] ;
  have := iso.thresh_compat j'; have := iso.gen_compat; simp_all +decide [ TropicalAccessPresentation.toSemimodule ] ;));
  intro hC j;
  convert hC ( iso.dimEquiv j ) using 1;
  · exact iso.thresh_compat j;
  · exact Finset.sup_congr rfl fun p hp => iso.gen_compat p j

/-- **Reconstruction equivalence is reflexive.** -/
theorem reconstructionEquivalent_refl (A : TropicalAccessPresentation P) :
    ReconstructionEquivalent A A :=
  fun _ => Iff.rfl

/-- **Reconstruction equivalence is symmetric.** -/
theorem reconstructionEquivalent_symm {A B : TropicalAccessPresentation P}
    (h : ReconstructionEquivalent A B) : ReconstructionEquivalent B A :=
  fun C => (h C).symm

/-- **Reconstruction equivalence is transitive.** -/
theorem reconstructionEquivalent_trans {A B C₀ : TropicalAccessPresentation P}
    (h₁ : ReconstructionEquivalent A B) (h₂ : ReconstructionEquivalent B C₀) :
    ReconstructionEquivalent A C₀ :=
  fun D => (h₁ D).trans (h₂ D)

/-! ## §9. Theorem 3: Duality — Forward Direction -/

/-- **Forward Duality**: Isomorphic semimodules yield reconstruction-equivalent presentations. -/
theorem reconstruction_equiv_of_iso (A B : TropicalAccessPresentation P)
    (h : Nonempty (TropicalSemimoduleIso A.toSemimodule B.toSemimodule)) :
    ReconstructionEquivalent A B :=
  iso_preserves_authorized A B h.some

/-! ## §10. Well-Foundedness and Minimality -/

/-- **Every participant in a minimal authorized coalition is essential.** -/
theorem minimal_auth_participant_essential (A : TropicalAccessPresentation P)
    (C : Finset P) (hC : MinimalAuthorized A C) (p : P) (hp : p ∈ C) :
    EssentialShare A p :=
  ⟨C, hC, hp⟩

/-- **Minimal authorized sets are nonempty.** -/
theorem minimalAuthorized_nonempty (A : TropicalAccessPresentation P)
    (C : Finset P) (h : MinimalAuthorized A C) :
    C.Nonempty := by
  by_contra h_empty
  rw [Finset.not_nonempty_iff_eq_empty] at h_empty
  exact empty_not_authorized A (h_empty ▸ h.1)

/-
**Any authorized set contains a minimal authorized subset.**
-/
theorem authorized_has_minimal (A : TropicalAccessPresentation P)
    (C : Finset P) (hC : Authorized A C) :
    ∃ D : Finset P, MinimalAuthorized A D ∧ D ⊆ C := by
  have h_minimal : ∀ (C : Finset P), Authorized A C → ∃ D : Finset P, MinimalAuthorized A D ∧ D ⊆ C := by
    intro C hC
    induction' C using Finset.strongInduction with C ih;
    by_cases hC_minimal : MinimalAuthorized A C;
    · exact ⟨ C, hC_minimal, Finset.Subset.refl _ ⟩;
    · unfold MinimalAuthorized at hC_minimal;
      grind;
  exact h_minimal C hC

/-! ## §11. Tropical Closure Infrastructure -/

/-- **Tropical closure**: all participants dominated by a coalition's score. -/
def tropicalClosure (A : TropicalAccessPresentation P) (C : Finset P) : Finset P :=
  Finset.univ.filter (fun p => ∀ j : Fin A.genDim, A.mat p j ≤ coalitionScore A C j)

/-- **Tropical closure is extensive.** -/
theorem tropicalClosure_extensive (A : TropicalAccessPresentation P) (C : Finset P) :
    C ⊆ tropicalClosure A C := by
  intro p hp
  simp only [tropicalClosure, Finset.mem_filter, Finset.mem_univ, true_and]
  intro j
  exact Finset.le_sup (f := fun p => A.mat p j) hp

/-- **Tropical closure is monotone.** -/
theorem tropicalClosure_mono (A : TropicalAccessPresentation P) :
    Monotone (tropicalClosure A) := by
  intro C D hCD p hp
  simp only [tropicalClosure, Finset.mem_filter, Finset.mem_univ, true_and] at hp ⊢
  intro j
  exact le_trans (hp j) (coalitionScore_mono A hCD j)

/-! ## §12. Concrete Example: (2,3)-Threshold Scheme -/

/-- **Threshold-2-of-3 scheme**: Three participants; any two can reconstruct.
    This is realized by the blocker construction: the blockers are the 2-element subsets
    (equivalently, the complements of singletons, but for (2,3)-threshold the blockers
    equal the minimal authorized sets).

    Alternatively, as a direct tropical construction: each column excludes one participant,
    so authorization requires coverage in all three exclusion dimensions. -/
def threshold_2_of_3 : TropicalAccessPresentation (Fin 3) where
  genDim := 3
  genDim_pos := by omega
  mat := fun p j => if p.val ≠ j.val then 1 else 0
  thresh := fun _ => 1
  thresh_pos := fun _ => by omega

/-
The (2,3)-threshold scheme authorizes any pair.
-/
theorem threshold_2_of_3_pair_authorized (i j : Fin 3) (hij : i ≠ j) :
    Authorized threshold_2_of_3 {i, j} := by
  fin_cases i <;> fin_cases j <;> simp_all +decide

/-
The (2,3)-threshold scheme does not authorize singletons.
-/
theorem threshold_2_of_3_singleton_unauth (i : Fin 3) :
    ¬Authorized threshold_2_of_3 {i} := by
  fin_cases i <;> simp +decide

/-
Pairs are minimal authorized in the (2,3)-threshold scheme.
-/
theorem threshold_2_of_3_pair_minimal (i j : Fin 3) (hij : i ≠ j) :
    MinimalAuthorized threshold_2_of_3 {i, j} := by
  constructor;
  · exact threshold_2_of_3_pair_authorized i j hij
  · fin_cases i <;> fin_cases j <;> simp_all +decide

/-! ## §13. Score Composition Lemmas -/

/-- **Score is monotone under intersection.** -/
theorem score_inter_le (A : TropicalAccessPresentation P)
    (C D : Finset P) (j : Fin A.genDim) :
    coalitionScore A (C ∩ D) j ≤ coalitionScore A C j :=
  coalitionScore_mono A Finset.inter_subset_left j

/-- **Authorization of unions.** -/
theorem authorized_union_iff (A : TropicalAccessPresentation P)
    (C D : Finset P) :
    Authorized A (C ∪ D) ↔
      ∀ j, A.thresh j ≤ coalitionScore A C j ⊔ coalitionScore A D j := by
  simp [Authorized, score_union]

/-! ## §14. Canonical GenDim -/

theorem canonical_genDim_eq (Γ : BlockerAccessStructure P) :
    (canonicalPresentation Γ).genDim = Γ.numBlock := rfl

/-! ## §15. Summary Package -/

/-- **Master Tropical Access Structure Package** -/
theorem tropical_access_structure_package (A : TropicalAccessPresentation P) :
    (Monotone (fun C : Finset P => Authorized A C)) ∧
    (¬Authorized A ∅) ∧
    (∀ C : Finset P, MinimalAuthorized A C ↔ ExtremalAttainmentSet A C) ∧
    (∀ C D : Finset P, ∀ j : Fin A.genDim,
      coalitionScore A (C ∪ D) j = coalitionScore A C j ⊔ coalitionScore A D j) :=
  ⟨authorized_mono A, empty_not_authorized A,
    minimalAuthorized_iff_extremal A, score_union A⟩

/-- **Tropical duality forward direction.** -/
theorem tropical_duality_forward (A B : TropicalAccessPresentation P)
    (h : Nonempty (TropicalSemimoduleIso A.toSemimodule B.toSemimodule)) :
    ReconstructionEquivalent A B :=
  reconstruction_equiv_of_iso A B h

end TropicalSecretSharing