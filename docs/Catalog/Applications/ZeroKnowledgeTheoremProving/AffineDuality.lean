import Mathlib

/-!
# Affine Duality: Translation Hides Witnesses, Subtraction Extracts Them

This file connects two apparently opposed ideas:

* **finite-group symmetry:** translation permutes a random-tape space without
  changing its uniform distribution;
* **cryptographic proof of knowledge:** two accepting answers to opposite
  challenges determine a witness by subtraction.

These are the two directions of one affine law. Translating a random tape by the
witness gives an exact simulator (privacy), while subtracting two translated
responses recovers the witness (knowledge soundness).

The main theorem `affine_privacy_extraction_duality` says simultaneously that
any two witnesses for the same public statement produce exactly the same
multiset of public transcripts, and that accepting responses to both Boolean
challenges at one commitment reveal a witness. Privacy and extraction coexist:
privacy concerns one randomized transcript, whereas extraction compares two
correlated transcripts having the same commitment.
-/

namespace ZeroKnowledgeTheoremProving.AffineDuality

variable {G H : Type*} [AddCommGroup G] [AddCommGroup H]

/-- A public additive homomorphism and target. -/
structure Statement where
  hom : G →+ H
  target : H

/-- A witness is a preimage of the public target. -/
def IsWitness (s : Statement (G := G) (H := H)) (w : G) : Prop :=
  s.hom w = s.target

/-- The public transcript of the three-move protocol. -/
structure Transcript (G H : Type*) where
  commitment : H
  challenge : Bool
  response : G
  deriving DecidableEq

/-- The witness contribution selected by the challenge bit. -/
def challengeTerm (c : Bool) (w : G) : G := if c then w else 0

/-- Honest transcript with witness `w` and random tape `r`. -/
def realTranscript (s : Statement (G := G) (H := H)) (w r : G) (c : Bool) :
    Transcript G H :=
  ⟨s.hom r, c, r + challengeTerm c w⟩

/-- Simulated transcript chosen from a freely selected response. -/
def simulatedTranscript (s : Statement (G := G) (H := H)) (z : G) (c : Bool) :
    Transcript G H :=
  ⟨s.hom z - challengeTerm c s.target, c, z⟩

/-- The verifier equation. -/
def Accepts (s : Statement (G := G) (H := H)) (t : Transcript G H) : Prop :=
  s.hom t.response = t.commitment + challengeTerm t.challenge s.target

/-- Every simulator output is a valid public conversation. -/
theorem simulator_support_is_valid
    (s : Statement (G := G) (H := H)) (z : G) (c : Bool) :
    Accepts s (simulatedTranscript s z c) := by
  cases c <;> simp [Accepts, simulatedTranscript, challengeTerm]

/-- Translation by the challenged witness is a permutation of random tapes. -/
def tapeEquiv (c : Bool) (w : G) : G ≃ G where
  toFun r := r + challengeTerm c w
  invFun z := z - challengeTerm c w
  left_inv r := by simp
  right_inv z := by simp

/-- A real transcript is pointwise equal to a simulator transcript after the
measure-preserving affine reindexing of random tapes. -/
theorem real_eq_simulated_reindexed
    (s : Statement (G := G) (H := H)) {w : G} (hw : IsWitness s w)
    (r : G) (c : Bool) :
    realTranscript s w r c = simulatedTranscript s (tapeEquiv c w r) c := by
  unfold tapeEquiv
  cases c <;> simp [realTranscript, simulatedTranscript, challengeTerm]
  rw [hw, add_sub_cancel_right]

/-- Exact perfect zero knowledge: the real and simulated transcript multisets
coincide under uniform finite random tapes. -/
theorem perfect_zero_knowledge [Fintype G]
    (s : Statement (G := G) (H := H)) {w : G} (hw : IsWitness s w) (c : Bool) :
    (Finset.univ.val.map (realTranscript s w · c)) =
      (Finset.univ.val.map (simulatedTranscript s · c)) := by
  have hbij : Multiset.map (fun x => tapeEquiv c w x) Finset.univ.val =
      Finset.univ.val := Multiset.map_univ_val_equiv (tapeEquiv c w)
  simp [real_eq_simulated_reindexed s hw]
  conv_rhs => rw [← hbij, Multiset.map_map]
  rfl

/-- Two accepting answers to opposite challenges at one commitment extract a
witness by subtraction. -/
theorem special_soundness (s : Statement (G := G) (H := H))
    (a : H) (zFalse zTrue : G)
    (hFalse : Accepts s ⟨a, false, zFalse⟩)
    (hTrue : Accepts s ⟨a, true, zTrue⟩) :
    IsWitness s (zTrue - zFalse) := by
  simp_all [Accepts, IsWitness, challengeTerm]

/-- Exact witness-independence of the verifier's view. Two different witnesses
for one statement induce the same transcript multiset. -/
theorem witness_indistinguishable [Fintype G]
    (s : Statement (G := G) (H := H)) {w₁ w₂ : G}
    (hw₁ : IsWitness s w₁) (hw₂ : IsWitness s w₂) (c : Bool) :
    (Finset.univ.val.map (realTranscript s w₁ · c)) =
      (Finset.univ.val.map (realTranscript s w₂ · c)) := by
  rw [perfect_zero_knowledge s hw₁, perfect_zero_knowledge s hw₂]

/-- Pointwise perfect zero knowledge: every transcript occurs with the same
multiplicity in the real execution and in the simulator. -/
theorem transcript_multiplicity_eq [Fintype G] [DecidableEq G] [DecidableEq H]
    (s : Statement (G := G) (H := H)) {w : G} (hw : IsWitness s w)
    (c : Bool) (t : Transcript G H) :
    ((Finset.univ.val.map (realTranscript s w · c)).count t) =
      ((Finset.univ.val.map (simulatedTranscript s · c)).count t) := by
  rw [perfect_zero_knowledge s hw]

/-- **Affine privacy/extraction duality.** Translation symmetry makes the view
independent of which witness is used, yet subtraction of two accepting responses
at the same commitment extracts a witness.

This is the cross-domain bridge: a finite-group measure-preserving symmetry
proves cryptographic noninterference, while the inverse affine operation proves
logical knowledge soundness. -/
theorem affine_privacy_extraction_duality [Fintype G]
    (s : Statement (G := G) (H := H)) {w₁ w₂ : G}
    (hw₁ : IsWitness s w₁) (hw₂ : IsWitness s w₂) (c : Bool)
    (a : H) (zFalse zTrue : G)
    (hFalse : Accepts s ⟨a, false, zFalse⟩)
    (hTrue : Accepts s ⟨a, true, zTrue⟩) :
    ((Finset.univ.val.map (realTranscript s w₁ · c)) =
        (Finset.univ.val.map (realTranscript s w₂ · c))) ∧
      IsWitness s (zTrue - zFalse) := by
  exact ⟨witness_indistinguishable s hw₁ hw₂ c,
    special_soundness s a zFalse zTrue hFalse hTrue⟩

end ZeroKnowledgeTheoremProving.AffineDuality