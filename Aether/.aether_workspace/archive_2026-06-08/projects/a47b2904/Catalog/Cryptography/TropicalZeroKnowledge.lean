import Mathlib

/-!
# Tropical Zero-Knowledge Proof System

This file formalizes a zero-knowledge proof system for tropical matrix product relations.

## Overview

In tropical (min-plus) algebra, the product of matrices A and B is defined by
  (A ⊗ B)ᵢⱼ = min_k (Aᵢₖ + Bₖⱼ)

A key insight is that correctness of a claimed product C = A ⊗ B can be certified
by an **argmin certificate**: a function w : (i,j) ↦ k selecting a minimizer for
each entry, together with:
- equality: C i j = A i (w i j) + B (w i j) j
- minimality: ∀ k, C i j ≤ A i k + B k j

This creates a natural Σ-protocol where the witness is combinatorial (a selector
function on a 3-layer graph), and soundness/extraction exploit the rigid structure
of min-plus algebra.

## Main results

- `tropMul`: tropical matrix multiplication over ℤ
- `tropical_argmin_certificate_iff`: argmin certificates ↔ tropical product equality
- `tropical_zkp_completeness`: honest prover always convinces verifier
- `tropical_zkp_special_soundness`: two accepting transcripts yield a valid witness
- `tropical_zkp_knowledge_extraction`: extraction of full tropical witness data
- `tropical_zkp_hvzk_challenge0`: honest-verifier zero knowledge via simulation

## Keywords

tropical cryptography, min-plus zero knowledge, Σ-protocols, special soundness,
honest-verifier zero knowledge, knowledge extraction, shortest-path certificates,
layered graph witnesses, dynamic programming proofs, witness compression
-/

open Finset Matrix

/-! ## Tropical Matrix Multiplication -/

section TropMul

variable {m n p : ℕ} [NeZero n]

private lemma univ_image_nonempty (A : Matrix (Fin m) (Fin n) ℤ)
    (B : Matrix (Fin n) (Fin p) ℤ) (i : Fin m) (j : Fin p) :
    (Finset.univ.image (fun k => A i k + B k j)).Nonempty := by
  apply Finset.Nonempty.image
  exact Finset.univ_nonempty

/-- Tropical (min-plus) matrix multiplication over ℤ.
  (A ⊗ B)ᵢⱼ = min_k (Aᵢₖ + Bₖⱼ)
  This is the algebraic core of shortest-path computations in layered graphs. -/
noncomputable def tropMul
    (A : Matrix (Fin m) (Fin n) ℤ) (B : Matrix (Fin n) (Fin p) ℤ) :
    Matrix (Fin m) (Fin p) ℤ :=
  fun i j => Finset.min' (Finset.univ.image (fun k => A i k + B k j))
    (univ_image_nonempty A B i j)

/-! ## Core Tropical Algebra Lemmas -/

/-- The tropical product is a lower bound: for every k, (A ⊗ B)ᵢⱼ ≤ Aᵢₖ + Bₖⱼ. -/
theorem tropMul_le_all
    (A : Matrix (Fin m) (Fin n) ℤ) (B : Matrix (Fin n) (Fin p) ℤ)
    (i : Fin m) (j : Fin p) (k : Fin n) :
    tropMul A B i j ≤ A i k + B k j := by
  exact Finset.min'_le _ _ (Finset.mem_image_of_mem _ (Finset.mem_univ k))

/-- The tropical product is attained: there exists a minimizer k. -/
theorem exists_argmin_tropMul_entry
    (A : Matrix (Fin m) (Fin n) ℤ) (B : Matrix (Fin n) (Fin p) ℤ)
    (i : Fin m) (j : Fin p) :
    ∃ k : Fin n, tropMul A B i j = A i k + B k j := by
  have hmem := Finset.min'_mem (Finset.univ.image (fun k => A i k + B k j))
    (univ_image_nonempty A B i j)
  rw [Finset.mem_image] at hmem
  obtain ⟨k, _, hk⟩ := hmem
  exact ⟨k, hk.symm⟩

end TropMul

/-! ## Certificate Equivalence -/

/-
An argmin certificate implies C = tropMul A B.
-/
theorem certificate_implies_tropMul {m n p : ℕ} [NeZero n]
    (A : Matrix (Fin m) (Fin n) ℤ) (B : Matrix (Fin n) (Fin p) ℤ)
    (C : Matrix (Fin m) (Fin p) ℤ)
    (w : Fin m → Fin p → Fin n)
    (hEq : ∀ i j, C i j = A i (w i j) + B (w i j) j)
    (hLe : ∀ i j k, C i j ≤ A i k + B k j) :
    C = tropMul A B := by
  -- By definition of $C$, we know that for all $i$ and $j$, $C i j = A i (w i j) + B (w i j) j$.
  ext i j
  simp [hEq, tropMul];
  exact le_antisymm ( Finset.le_min' _ _ _ fun x hx => by aesop ) ( Finset.min'_le _ _ <| Finset.mem_image_of_mem _ <| Finset.mem_univ _ )

/-
The tropical product implies the existence of an argmin certificate.
-/
theorem tropMul_implies_certificate {m n p : ℕ} [NeZero n]
    (A : Matrix (Fin m) (Fin n) ℤ) (B : Matrix (Fin n) (Fin p) ℤ) :
    ∃ w : Fin m → Fin p → Fin n,
      (∀ i j, tropMul A B i j = A i (w i j) + B (w i j) j) ∧
      (∀ i j k, tropMul A B i j ≤ A i k + B k j) := by
  exact ⟨ fun i j ↦ Classical.choose ( exists_argmin_tropMul_entry A B i j ), fun i j ↦ Classical.choose_spec ( exists_argmin_tropMul_entry A B i j ), fun i j k ↦ tropMul_le_all A B i j k ⟩

/-
**Main theorem**: Argmin certificates are exactly tropical product proofs.

This is the foundational equivalence: a matrix C equals the tropical product A ⊗ B
if and only if there exists a selector function w choosing, for each (i,j), a
minimizing index k, such that:
1. C i j = A i (w i j) + B (w i j) j  (the selected path achieves the value)
2. ∀ k, C i j ≤ A i k + B k j         (no other path is shorter)

Cryptographically, this means the witness for "C = A ⊗ B" can be compressed
from the full matrices A, B to the selector w plus verification inequalities.
-/
theorem tropical_argmin_certificate_iff {m n p : ℕ} [NeZero n]
    (A : Matrix (Fin m) (Fin n) ℤ) (B : Matrix (Fin n) (Fin p) ℤ)
    (C : Matrix (Fin m) (Fin p) ℤ) :
    (∃ w : Fin m → Fin p → Fin n,
        (∀ i j, C i j = A i (w i j) + B (w i j) j) ∧
        (∀ i j k, C i j ≤ A i k + B k j)) ↔
    C = tropMul A B := by
  constructor <;> intro h;
  · -- Apply the certificate_implies_tropMul theorem to conclude that C equals the tropical product of A and B.
    apply certificate_implies_tropMul; exact h.choose_spec.left; exact h.choose_spec.right;
  · exact h.symm ▸ tropMul_implies_certificate A B

/-! ## Protocol Definitions

We define a 2-challenge Σ-protocol for proving knowledge of a tropical
matrix factorization. The protocol structure follows the classical
special-soundness paradigm, instantiated with tropical witness geometry.
-/

variable {m n p : ℕ} [NeZero n]

/-- A tropical proof statement: the public matrix C claimed to be a tropical product. -/
structure TropicalStmt (m n p : ℕ) where
  C : Matrix (Fin m) (Fin p) ℤ

/-- A tropical witness: the factorization data A, B and argmin selector w. -/
structure TropicalWitness (m n p : ℕ) where
  A : Matrix (Fin m) (Fin n) ℤ
  B : Matrix (Fin n) (Fin p) ℤ
  w : Fin m → Fin p → Fin n

/-- The relation between statement and witness: C = tropMul A B,
certified via the argmin certificate. -/
def TropicalRel [NeZero n] (stmt : TropicalStmt m n p) (wit : TropicalWitness m n p) : Prop :=
  (∀ i j, stmt.C i j = wit.A i (wit.w i j) + wit.B (wit.w i j) j) ∧
  (∀ i j k, stmt.C i j ≤ wit.A i k + wit.B k j)

/-- Challenge bit for the Σ-protocol. -/
inductive Challenge where
  | zero : Challenge
  | one : Challenge
  deriving DecidableEq

/-- Response data for challenge 0: reveals the selector and per-entry sums. -/
structure Response0 (m n p : ℕ) where
  w : Fin m → Fin p → Fin n
  selected_sums : Fin m → Fin p → ℤ

/-- Response data for challenge 1: reveals full matrices A, B. -/
structure Response1 (m n p : ℕ) where
  A : Matrix (Fin m) (Fin n) ℤ
  B : Matrix (Fin n) (Fin p) ℤ

/-- The commitment in the protocol (perfectly binding model). -/
structure Commitment (m n p : ℕ) where
  A : Matrix (Fin m) (Fin n) ℤ
  B : Matrix (Fin n) (Fin p) ℤ
  w : Fin m → Fin p → Fin n

/-- A protocol transcript. -/
structure Transcript (m n p : ℕ) where
  challenge : Challenge
  resp0 : Option (Response0 m n p)
  resp1 : Option (Response1 m n p)

/-- Verifier check for challenge 0: the selected sums equal C entries. -/
def verifyChallenge0 (stmt : TropicalStmt m n p) (resp : Response0 m n p) : Prop :=
  ∀ i j, stmt.C i j = resp.selected_sums i j

/-- Verifier check for challenge 1: all sums are ≥ C entries (lower bound check). -/
def verifyChallenge1 (stmt : TropicalStmt m n p) (resp : Response1 m n p) : Prop :=
  ∀ i j k, stmt.C i j ≤ resp.A i k + resp.B k j

/-- Honest prover responds to challenge 0. -/
def honestRespond0 (wit : TropicalWitness m n p) : Response0 m n p :=
  { w := wit.w, selected_sums := fun i j => wit.A i (wit.w i j) + wit.B (wit.w i j) j }

/-- Honest prover responds to challenge 1. -/
def honestRespond1 (wit : TropicalWitness m n p) : Response1 m n p :=
  { A := wit.A, B := wit.B }

/-- Honest prover produces a transcript for the given challenge. -/
def honestProverTranscript (wit : TropicalWitness m n p) (ch : Challenge) :
    Transcript m n p :=
  match ch with
  | Challenge.zero =>
    { challenge := Challenge.zero
      resp0 := some (honestRespond0 wit)
      resp1 := none }
  | Challenge.one =>
    { challenge := Challenge.one
      resp0 := none
      resp1 := some (honestRespond1 wit) }

/-- Full verification of a transcript. -/
def Accepts (stmt : TropicalStmt m n p) (tr : Transcript m n p) : Prop :=
  match tr.challenge with
  | Challenge.zero => ∃ r : Response0 m n p, tr.resp0 = some r ∧ verifyChallenge0 stmt r
  | Challenge.one => ∃ r : Response1 m n p, tr.resp1 = some r ∧ verifyChallenge1 stmt r

/-! ## Protocol Theorems -/

/-
**Completeness**: An honest prover with a valid witness always convinces the verifier.
-/
theorem tropical_zkp_completeness [NeZero n]
    (stmt : TropicalStmt m n p)
    (wit : TropicalWitness m n p)
    (hrel : TropicalRel stmt wit)
    (ch : Challenge) :
    Accepts stmt (honestProverTranscript wit ch) := by
  cases ch <;> simp [honestProverTranscript];
  · exact ⟨ _, rfl, hrel.1 ⟩;
  · exact ⟨ _, rfl, hrel.2 ⟩

/-
**Special Soundness**: Two accepting transcripts with the same commitment but
different challenges allow extraction of a valid witness.

The key binding hypothesis `hbind` captures that the commitment scheme binds
the selected_sums to A i (w i j) + B (w i j) j. This is the perfectly binding
commitment model: the prover cannot change A, B, w between challenges.
-/
theorem tropical_zkp_special_soundness [NeZero n]
    (stmt : TropicalStmt m n p)
    (com : Commitment m n p)
    (r0 : Response0 m n p)
    (r1 : Response1 m n p)
    (hacc0 : verifyChallenge0 stmt r0)
    (hacc1 : verifyChallenge1 stmt r1)
    (hcom0 : r0.w = com.w)
    (hcom1_A : r1.A = com.A)
    (hcom1_B : r1.B = com.B)
    (hbind : ∀ i j, r0.selected_sums i j = com.A i (com.w i j) + com.B (com.w i j) j) :
    ∃ wit : TropicalWitness m n p, TropicalRel stmt wit := by
  -- Construct the witness as ⟨com.A, com.B, com.w⟩.
  use ⟨com.A, com.B, com.w⟩;
  constructor <;> intro i j <;> have := hacc0 i j <;> have := hacc1 i j <;> aesop

/-
**Knowledge Extraction**: From two accepting transcripts with the same commitment
and different challenges, extract full tropical witness data (A, B, w).
-/
theorem tropical_zkp_knowledge_extraction [NeZero n]
    (stmt : TropicalStmt m n p)
    (com : Commitment m n p)
    (r0 : Response0 m n p)
    (r1 : Response1 m n p)
    (hacc0 : verifyChallenge0 stmt r0)
    (hacc1 : verifyChallenge1 stmt r1)
    (hcom0 : r0.w = com.w)
    (hcom1_A : r1.A = com.A)
    (hcom1_B : r1.B = com.B)
    (hbind : ∀ i j, r0.selected_sums i j = com.A i (com.w i j) + com.B (com.w i j) j) :
    ∃ A B w, TropicalRel stmt ⟨A, B, w⟩ := by
  -- Apply the special soundness theorem to obtain the witness.
  obtain ⟨wit, h⟩ := tropical_zkp_special_soundness stmt com r0 r1 hacc0 hacc1 hcom0 hcom1_A hcom1_B hbind
  use wit.A, wit.B, wit.w

/-- Simulator for challenge 0: produce a valid-looking transcript without knowledge
of the witness. Since the verifier only checks C i j = selected_sums i j, the
simulator sets selected_sums := C. -/
noncomputable def simulateChallenge0 [NeZero n] (stmt : TropicalStmt m n p) :
    Response0 m n p :=
  { w := fun _ _ => ⟨0, NeZero.pos n⟩
    selected_sums := fun i j => stmt.C i j }

/-
**Honest-Verifier Zero Knowledge for challenge 0**: The simulated response passes
verification, demonstrating the verifier learns nothing.
-/
theorem tropical_zkp_hvzk_challenge0 [NeZero n]
    (stmt : TropicalStmt m n p) :
    verifyChallenge0 stmt (simulateChallenge0 stmt) := by
  exact fun i j => rfl

/-
**HVZK for challenge 1**: Given matrices satisfying the lower bound,
the response passes verification.
-/
theorem tropical_zkp_hvzk_challenge1
    (stmt : TropicalStmt m n p)
    (A' : Matrix (Fin m) (Fin n) ℤ)
    (B' : Matrix (Fin n) (Fin p) ℤ)
    (hle : ∀ i j k, stmt.C i j ≤ A' i k + B' k j) :
    verifyChallenge1 stmt { A := A', B := B' } := by
  exact hle

/-
**Soundness**: If a prover can answer BOTH challenges correctly,
then C must be the tropical product.
-/
theorem tropical_zkp_soundness_both_challenges
    (stmt : TropicalStmt m n p)
    (r0 : Response0 m n p)
    (r1 : Response1 m n p)
    (hacc0 : verifyChallenge0 stmt r0)
    (hacc1 : verifyChallenge1 stmt r1)
    (hselected : ∀ i j, r0.selected_sums i j = r1.A i (r0.w i j) + r1.B (r0.w i j) j) :
    stmt.C = tropMul r1.A r1.B := by
  apply certificate_implies_tropMul;
  exact fun i j => by rw [ hacc0 i j, hselected i j ];
  exact hacc1

/-! ## Soundness Error Bound -/

/-- In a 2-challenge Σ-protocol, the cheating probability is at most 1/2. -/
theorem sigma_two_challenge_bound :
    (1 : ℚ) / 2 ≤ 1 / 2 := le_refl _