import Applications.QuantumProofsClassicalTheorems.Core

/-!
# Bounded-error verification and classical witness lifting

This file adds the semantic component of a QMA-style proof system: a verifier assigns
an acceptance probability to each input and finite-dimensional witness.  Completeness
and soundness are separated by explicit thresholds.  A classical verifier lifts to the
quantum witness model by inspecting the conclusion field; basis encoding then preserves
acceptance exactly.  This proves the unconditional containment of classical witness
verification in the abstract quantum model without asserting a converse complexity
collapse.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Any classical verifier can be viewed as a quantum verifier
whose acceptance behavior on computational-basis encodings is unchanged. A stronger
hypothesis—that every bounded-error quantum verifier admits polynomial classical
witness extraction—was isolated but not assumed.

Experiment (Experimenter): Acceptance was parameterized by rational thresholds rather
than hard-coding two-thirds and one-third. The lifted verifier ignores amplitudes and
reads the embedded classical conclusion, making completeness transfer exact.

Analysis (Analyst): Classical containment needs no measurement theorem: basis witnesses
form a distinguished subfamily of quantum witnesses. Soundness transfers when the
classical no-instance condition excludes every claimed conclusion accepted by the
classical verifier.

Critique (Critic): This semantic model does not impose circuit uniformity, witness
normalization, or polynomial-time execution. Accordingly it establishes a verifier
embedding, not the unresolved equality of classical and quantum complexity classes.

Synthesis (Principal Investigator): The verifier layer and proof-size layer agree on the
same basis encoding, while the missing reverse direction is cleanly exposed as an
extractor requirement.
-- !-- Lab Notes -- !--
-/

namespace QuantumProofsClassicalTheorems

/-- A bounded-error quantum verifier assigns a rational acceptance probability to an
input and a finite-dimensional witness. -/
structure QuantumVerifier (Input Formula : Type*) where
  /-- Acceptance probability. -/
  accept : Input → QuantumWitness Formula → ℚ
  /-- Probabilities are nonnegative. -/
  accept_nonneg : ∀ x q, 0 ≤ accept x q
  /-- Probabilities are at most one. -/
  accept_le_one : ∀ x q, accept x q ≤ 1

/-- Completeness at threshold `c`: every yes-instance has some accepted witness. -/
def CompleteAt {Input Formula : Type*} (V : QuantumVerifier Input Formula)
    (yes : Input → Prop) (c : ℚ) : Prop :=
  ∀ x, yes x → ∃ q, c ≤ V.accept x q

/-- Soundness at threshold `s`: no witness makes a no-instance accept above `s`. -/
def SoundAt {Input Formula : Type*} (V : QuantumVerifier Input Formula)
    (yes : Input → Prop) (s : ℚ) : Prop :=
  ∀ x, ¬ yes x → ∀ q, V.accept x q ≤ s

/-- A QMA-style bounded-error specification with an explicit completeness–soundness
gap. The standard choice is `c = 2/3` and `s = 1/3`. -/
structure QMASpec {Input Formula : Type*} (V : QuantumVerifier Input Formula)
    (yes : Input → Prop) (c s : ℚ) : Prop where
  /-- Completeness exceeds soundness. -/
  gap : s < c
  /-- Yes-instances admit witnesses. -/
  complete : CompleteAt V yes c
  /-- No-instances reject every witness. -/
  sound : SoundAt V yes s

/-- A classical verifier whose proof object is simply a claimed formula. -/
structure ClassicalVerifier (Input Formula : Type*) where
  /-- Classical acceptance probability. -/
  accept : Input → Formula → ℚ
  /-- Probabilities are nonnegative. -/
  accept_nonneg : ∀ x f, 0 ≤ accept x f
  /-- Probabilities are at most one. -/
  accept_le_one : ∀ x f, accept x f ≤ 1

/-- Lift a classical verifier to quantum witnesses by evaluating its classical
conclusion field. -/
def liftClassicalVerifier {Input Formula : Type*}
    (V : ClassicalVerifier Input Formula) : QuantumVerifier Input Formula where
  accept := fun x q => V.accept x q.conclusion
  accept_nonneg := fun x q => V.accept_nonneg x q.conclusion
  accept_le_one := fun x q => V.accept_le_one x q.conclusion

/-- Basis encoding preserves verifier acceptance exactly. -/
theorem basis_acceptance_preserved {Input Formula : Type*}
    (V : ClassicalVerifier Input Formula) (C : ProofSystemCollapse.ProofSys Formula)
    (x : Input) (p : C.Proof) :
    (liftClassicalVerifier V).accept x (basisEncode C p) = V.accept x (C.concl p) := by
  rfl

/-- Classical completeness transfers to quantum completeness through basis witnesses. -/
theorem classical_completeness_lifts {Input Formula : Type*}
    (V : ClassicalVerifier Input Formula) (C : ProofSystemCollapse.ProofSys Formula)
    (yes : Input → Prop) (c : ℚ)
    (hcomplete : ∀ x, yes x → ∃ p : C.Proof, c ≤ V.accept x (C.concl p)) :
    CompleteAt (liftClassicalVerifier V) yes c := by
  intro x hx
  obtain ⟨p, hp⟩ := hcomplete x hx
  refine ⟨basisEncode C p, ?_⟩
  rw [basis_acceptance_preserved]
  exact hp

/-- If every classical claim is sound on no-instances, then every quantum witness is
sound for the lifted verifier, because the lift depends only on that claim. -/
theorem classical_soundness_lifts {Input Formula : Type*}
    (V : ClassicalVerifier Input Formula) (yes : Input → Prop) (s : ℚ)
    (hsound : ∀ x, ¬ yes x → ∀ f, V.accept x f ≤ s) :
    SoundAt (liftClassicalVerifier V) yes s := by
  intro x hx q
  exact hsound x hx q.conclusion

/-- A bounded-error classical protocol therefore yields a QMA-style protocol with the
same completeness and soundness thresholds. -/
theorem classical_protocol_is_quantum_protocol {Input Formula : Type*}
    (V : ClassicalVerifier Input Formula) (C : ProofSystemCollapse.ProofSys Formula)
    (yes : Input → Prop) (c s : ℚ) (hgap : s < c)
    (hcomplete : ∀ x, yes x → ∃ p : C.Proof, c ≤ V.accept x (C.concl p))
    (hsound : ∀ x, ¬ yes x → ∀ f, V.accept x f ≤ s) :
    QMASpec (liftClassicalVerifier V) yes c s := by
  refine ⟨hgap, ?_, ?_⟩
  · exact classical_completeness_lifts V C yes c hcomplete
  · exact classical_soundness_lifts V yes s hsound

end QuantumProofsClassicalTheorems