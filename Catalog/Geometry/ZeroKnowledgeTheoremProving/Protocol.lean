import Mathlib

/-!
# A Perfect Honest-Verifier Zero-Knowledge Identification Protocol

This file gives an information-theoretic model of a three-move identification
protocol for a public homomorphism `φ : G →+ H`.  A witness `w` for the public
statement `y` satisfies `φ w = y`.  The prover commits with `φ r`, answers a
Boolean challenge with either `r` or `r + w`, and the verifier checks the
corresponding homomorphism equation.

Rather than appealing informally to "seeing one random proof step", perfect
honest-verifier zero knowledge is expressed by an explicit bijection of random
tapes: translating `r` by the challenged witness turns every real transcript
into the simulator's transcript.  The same development proves completeness and
special soundness (two answers to opposite challenges extract a witness).
-/

namespace ZeroKnowledgeIdentification

variable {G H : Type*} [AddCommGroup G] [AddCommGroup H]

/-- Public parameters and public statement for the protocol. -/
structure Statement where
  hom : G →+ H
  target : H

/-- A witness is a preimage of the public target. -/
def IsWitness (s : Statement (G := G) (H := H)) (w : G) : Prop :=
  s.hom w = s.target

/-- The public transcript of one protocol execution. -/
structure Transcript (G H : Type*) where
  commitment : H
  challenge : Bool
  response : G
  deriving DecidableEq

/-- The witness contribution to an answer for a Boolean challenge. -/
def challengeTerm (c : Bool) (w : G) : G := if c then w else 0

/-- Transcript produced by an honest prover with witness `w` and random tape `r`. -/
def realTranscript (s : Statement (G := G) (H := H)) (w r : G) (c : Bool) :
    Transcript G H :=
  ⟨s.hom r, c, r + challengeTerm c w⟩

/-- Transcript produced by the simulator from a freely selected response `z`. -/
def simulatedTranscript (s : Statement (G := G) (H := H)) (z : G) (c : Bool) :
    Transcript G H :=
  ⟨s.hom z - challengeTerm c s.target, c, z⟩

/-- The verifier's acceptance predicate. -/
def Accepts (s : Statement (G := G) (H := H)) (t : Transcript G H) : Prop :=
  s.hom t.response = t.commitment + challengeTerm t.challenge s.target

/-- Every honest execution with a valid witness is accepted (perfect completeness). -/
theorem perfect_completeness (s : Statement (G := G) (H := H)) {w : G}
    (hw : IsWitness s w) (r : G) (c : Bool) :
    Accepts s (realTranscript s w r c) := by
  cases c <;> simp +decide [Accepts, realTranscript]
  · simp +decide [challengeTerm]
  · exact hw

/-- Every simulated transcript is accepted, without access to a witness. -/
theorem simulator_accepts (s : Statement (G := G) (H := H)) (z : G) (c : Bool) :
    Accepts s (simulatedTranscript s z c) := by
  cases c <;> simp +decide [Accepts, simulatedTranscript]

/-- Translation by the challenge-dependent witness term is a bijection of random
    tapes.  This is the measure-preserving reindexing behind perfect zero knowledge. -/
def tapeEquiv (c : Bool) (w : G) : G ≃ G where
  toFun r := r + challengeTerm c w
  invFun z := z - challengeTerm c w
  left_inv r := by simp
  right_inv z := by simp

/-- Pointwise transcript identity under the random-tape bijection. Consequently,
for finite `G`, the real and simulated transcript multisets (and hence their exact
uniform distributions) are identical. -/
theorem real_eq_simulated_reindexed (s : Statement (G := G) (H := H)) {w : G}
    (hw : IsWitness s w) (r : G) (c : Bool) :
    realTranscript s w r c = simulatedTranscript s (tapeEquiv c w r) c := by
  unfold tapeEquiv;
  cases c <;> simp +decide [*, realTranscript, simulatedTranscript, challengeTerm];
  rw [hw, add_sub_cancel_right]

/-- Exact perfect honest-verifier zero knowledge for finite random tapes, stated as
equality of transcript multisets rather than an asymptotic approximation. -/
theorem perfect_zero_knowledge [Fintype G] (s : Statement (G := G) (H := H))
    {w : G} (hw : IsWitness s w) (c : Bool) :
    (Finset.univ.val.map (realTranscript s w · c)) =
      (Finset.univ.val.map (simulatedTranscript s · c)) := by
  have h_bij : Multiset.map (fun x => tapeEquiv c w x) Finset.univ.val = Finset.univ.val := by
    exact Multiset.map_univ_val_equiv (tapeEquiv c w)
  simp +decide [ real_eq_simulated_reindexed s hw]
  conv_rhs => rw [ ← h_bij, Multiset.map_map]
  rfl

/-- Two accepting answers to the same commitment under opposite challenges reveal
a witness. This is the protocol's special-soundness extraction theorem. -/
theorem special_soundness (s : Statement (G := G) (H := H))
    (a : H) (zFalse zTrue : G)
    (hFalse : Accepts s ⟨a, false, zFalse⟩)
    (hTrue : Accepts s ⟨a, true, zTrue⟩) :
    IsWitness s (zTrue - zFalse) := by
  simp_all +decide [Accepts, IsWitness]
  simp +decide [challengeTerm]

/-- A prover that can answer both Boolean challenges for one commitment necessarily
certifies that the public statement has a witness. -/
theorem two_challenge_knowledge (s : Statement (G := G) (H := H)) (a : H)
    (answer : Bool → G)
    (haccept : ∀ c, Accepts s ⟨a, c, answer c⟩) :
    ∃ w, IsWitness s w := by
  obtain ⟨w, hw⟩ : ∃ w : G, IsWitness s w := by
    have h_true := haccept true
    have h_false := haccept false
    exact ⟨_, special_soundness s a _ _ h_false h_true ⟩;
  use w

/-- If the public statement has no witness, no commitment admits accepting answers
for both challenges. Thus a prover preparing one response before a uniformly random
Boolean challenge can cover at most one of the two possibilities. -/
theorem no_witness_challenge_exclusivity (s : Statement (G := G) (H := H))
    (hnowitness : ¬∃ w, IsWitness s w) (a : H) (zFalse zTrue : G) :
    ¬(Accepts s ⟨a, false, zFalse⟩ ∧ Accepts s ⟨a, true, zTrue⟩) := by
  exact fun h => hnowitness <| ⟨ _, special_soundness s a zFalse zTrue h.1 h.2 ⟩

end ZeroKnowledgeIdentification