import Mathlib.Logic.Function.Basic

/-!
# Strange Loops and Abstract Gödel Independence

A compact, self-contained diagonal argument.  The structure records exactly the
semantic hypotheses used: an external truth predicate, sound provability, a
truth-functional object-language negation, and a diagonal operator.  The theorem
chain starts with the self-referential sentence, proves its unprovability and
truth, upgrades this to independence, and rules out proof-producing completeness.

This is an abstract fixed-point form of the first incompleteness argument.  It
does not claim that a particular arithmetic theory satisfies the structure;
that further step requires arithmetizing syntax and proving a diagonal lemma.
-/

noncomputable section

/-- A sound formal system equipped with semantic negation and diagonalization. -/
structure DiagonalSystem where
  Sentence : Type
  Provable : Sentence → Prop
  True_ : Sentence → Prop
  sound : ∀ s, Provable s → True_ s
  neg : Sentence → Sentence
  true_neg : ∀ s, True_ (neg s) ↔ ¬ True_ s
  diag : (Sentence → Prop) → Sentence
  diag_spec : ∀ P : Sentence → Prop, True_ (diag P) ↔ P (diag P)

namespace DiagonalSystem

/-- The diagonal sentence asserting its own unprovability. -/
def goedelSentence (S : DiagonalSystem) : S.Sentence :=
  S.diag (fun s => ¬ S.Provable s)

/-
First link: the Gödel sentence is a fixed point of the operation “this
sentence is not provable,” interpreted through the truth predicate.
-/
theorem goedel_fixed_point (S : DiagonalSystem) :
    S.True_ S.goedelSentence ↔ ¬ S.Provable S.goedelSentence := by
  exact S.diag_spec _

/-- Second link: soundness turns the fixed-point equation into unprovability. -/
theorem goedel_unprovable (S : DiagonalSystem) :
    ¬ S.Provable S.goedelSentence := by
  intro hprov
  exact (S.goedel_fixed_point.mp (S.sound _ hprov)) hprov

/-- Third link: its unprovability, fed through the fixed point, makes it true. -/
theorem goedel_true (S : DiagonalSystem) :
    S.True_ S.goedelSentence := by
  exact S.goedel_fixed_point.mpr S.goedel_unprovable

/-- Fourth link: its formal negation cannot be proved either. -/
theorem neg_goedel_unprovable (S : DiagonalSystem) :
    ¬ S.Provable (S.neg S.goedelSentence) := by
  intro hprov
  have hnegtrue := S.sound _ hprov
  exact (S.true_neg S.goedelSentence).mp hnegtrue (goedel_true S)

/-- Fifth link: the Gödel sentence is independent of the proof system. -/
theorem goedel_independent (S : DiagonalSystem) :
    ¬ S.Provable S.goedelSentence ∧
      ¬ S.Provable (S.neg S.goedelSentence) := by
  exact ⟨ S.goedel_unprovable, S.neg_goedel_unprovable ⟩

/-- Syntactic completeness decides every sentence by a proof on one side. -/
def SyntacticallyComplete (S : DiagonalSystem) : Prop :=
  ∀ s, S.Provable s ∨ S.Provable (S.neg s)

/-- Sixth link: sound diagonal systems are not syntactically complete. -/
theorem not_syntactically_complete (S : DiagonalSystem) :
    ¬ S.SyntacticallyComplete := by
  exact fun h => S.goedel_independent.1 <| h _ |> Or.resolve_right <| S.goedel_independent.2

/-- A global proof-producing decision certificate. -/
def ProofDecisionCertificate (S : DiagonalSystem) :=
  (s : S.Sentence) → S.Provable s ∨ S.Provable (S.neg s)

/-- Seventh link: no global proof-producing decision certificate exists. -/
theorem no_proof_decision_certificate (S : DiagonalSystem) :
    ¬ Nonempty S.ProofDecisionCertificate := by
  rintro ⟨certificate⟩
  exact S.not_syntactically_complete certificate

/-- A sentence bundled with proofs that neither it nor its negation is provable. -/
structure IndependenceWitness (S : DiagonalSystem) where
  sentence : S.Sentence
  unprovable : ¬ S.Provable sentence
  neg_unprovable : ¬ S.Provable (S.neg sentence)

/-- Eighth link: the Gödel sentence supplies a canonical independence witness. -/
theorem canonical_independence_witness (S : DiagonalSystem) :
    Nonempty (IndependenceWitness S) := by
  exact ⟨ ⟨ S.goedelSentence, DiagonalSystem.goedel_unprovable S, DiagonalSystem.neg_goedel_unprovable S ⟩ ⟩

#print axioms goedel_fixed_point
#print axioms goedel_unprovable
#print axioms goedel_true
#print axioms neg_goedel_unprovable
#print axioms goedel_independent
#print axioms not_syntactically_complete
#print axioms no_proof_decision_certificate
#print axioms canonical_independence_witness

end DiagonalSystem

end