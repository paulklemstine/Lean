import Mathlib

/-! # Abstract incompleteness

An *abstract formal system* is a type of sentences equipped with a negation, a provability
predicate, and a semantic truth predicate that is sound for provability and classical for
negation.  A **Gödel sentence** is a sentence asserting its own unprovability.

The theorem below is the abstract core of Gödel's first incompleteness theorem, stripped of
arithmetisation: *if a sound system has a Gödel sentence, that sentence is true and neither
it nor its negation is provable.*  Nothing about arithmetic, coding, or the diagonal lemma
is assumed — those are what produce the Gödel sentence in a concrete system; here its
existence is the hypothesis, and the conclusion is genuine undecidability.
-/

namespace ProofSpace

/-- An abstract formal system: sentences, negation, provability, and a sound truth
predicate. -/
structure FormalSystem where
  /-- The sentences of the system. -/
  Sentence : Type
  /-- Negation of a sentence. -/
  neg : Sentence → Sentence
  /-- The provability predicate. -/
  Provable : Sentence → Prop
  /-- The (semantic) truth predicate. -/
  True : Sentence → Prop
  /-- Soundness: everything provable is true. -/
  sound : ∀ s, Provable s → True s
  /-- Truth is classical for negation. -/
  true_neg : ∀ s, True (neg s) ↔ ¬ True s

namespace FormalSystem

variable (F : FormalSystem)

/-- A Gödel sentence: one that is true exactly when it is unprovable. -/
def IsGodelSentence (g : F.Sentence) : Prop := F.True g ↔ ¬ F.Provable g

/-- A sentence is undecidable when neither it nor its negation is provable. -/
def Undecidable (s : F.Sentence) : Prop := ¬ F.Provable s ∧ ¬ F.Provable (F.neg s)

/-- **Abstract first incompleteness theorem.**  In a sound system a Gödel sentence is true,
unprovable, and irrefutable. -/
theorem godel_incompleteness {g : F.Sentence} (hg : F.IsGodelSentence g) :
    F.True g ∧ F.Undecidable g := by
  have hnp : ¬ F.Provable g := by
    intro hp
    exact (hg.mp (F.sound g hp)) hp
  have htrue : F.True g := hg.mpr hnp
  refine ⟨htrue, hnp, ?_⟩
  intro hpn
  have : F.True (F.neg g) := F.sound _ hpn
  exact ((F.true_neg g).mp this) htrue

/-- A sound system with a Gödel sentence is incomplete: some sentence is undecidable. -/
theorem exists_undecidable_of_godelSentence {g : F.Sentence} (hg : F.IsGodelSentence g) :
    ∃ s, F.Undecidable s :=
  ⟨g, (godel_incompleteness F hg).2⟩

/-- Consistency is a consequence of soundness: no sentence and its negation are both
provable. -/
theorem consistent (s : F.Sentence) : ¬ (F.Provable s ∧ F.Provable (F.neg s)) := by
  rintro ⟨h1, h2⟩
  exact ((F.true_neg s).mp (F.sound _ h2)) (F.sound _ h1)

end FormalSystem

end ProofSpace