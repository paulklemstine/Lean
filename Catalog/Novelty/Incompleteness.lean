import Mathlib

/-!
# Proof Space V: The Gödel threshold — abstract incompleteness

The critical point of proof space is the *Gödel threshold*: the length at which
self-reference first becomes expressible and provability parts ways with truth.
This file isolates the abstract logical core of Gödel's first incompleteness
theorem and a Cantor-style upper bound on what any proof system can capture.

`FormalSystem` packages a type of sentences with a provability predicate, a truth
predicate, a negation, soundness, and consistency.  Given a *Gödel sentence* — a
fixed point `G` with `True_ G ↔ ¬ Provable G` — we derive, in
`FormalSystem.godel_incompleteness`, that `G` is true, unprovable, and
irrefutable: proof space is genuinely incomplete at its critical point.
`exists_godel_system` witnesses that the hypotheses are satisfiable (non-vacuity).

`cantor_incompleteness` records the structural obstruction: the semantic
properties of statements cannot be enumerated by statements, so no proof system
can name every property of proof space.
-/

namespace ProofSpace

/-- An abstract formal system: sentences, provability, negation, truth, together
with soundness and consistency. -/
structure FormalSystem where
  /-- The type of sentences. -/
  Sentence : Type
  /-- Provability predicate. -/
  Provable : Sentence → Prop
  /-- Negation of a sentence. -/
  neg : Sentence → Sentence
  /-- The (external) truth predicate. -/
  True_ : Sentence → Prop
  /-- Soundness: everything provable is true. -/
  sound : ∀ s, Provable s → True_ s
  /-- Truth respects negation. -/
  neg_true : ∀ s, True_ (neg s) ↔ ¬ True_ s
  /-- Consistency: no sentence and its negation are both provable. -/
  consistent : ∀ s, ¬ (Provable s ∧ Provable (neg s))

/-- **Abstract Gödel incompleteness.**  If a sound, consistent formal system has
a Gödel sentence `G` — a fixed point satisfying `True_ G ↔ ¬ Provable G` — then
`G` is true, but neither `G` nor its negation is provable.  The system is
therefore incomplete: truth outruns provability. -/
theorem FormalSystem.godel_incompleteness (F : FormalSystem)
    (G : F.Sentence) (hG : F.True_ G ↔ ¬ F.Provable G) :
    F.True_ G ∧ ¬ F.Provable G ∧ ¬ F.Provable (F.neg G) := by
  -- `G` is unprovable: otherwise soundness makes it true, but truth of `G`
  -- means `G` is unprovable.
  have hnp : ¬ F.Provable G := fun h => hG.mp (F.sound _ h) h
  -- Hence `G` is true, by the fixed-point equivalence.
  have hTrue : F.True_ G := hG.mpr hnp
  -- And `¬G` is unprovable: otherwise soundness makes `¬G` true, hence `G`
  -- false, contradicting `hTrue`.
  refine ⟨hTrue, hnp, fun h => ?_⟩
  exact (F.neg_true G).mp (F.sound _ h) hTrue

/-- **Non-vacuity.**  The hypotheses of `godel_incompleteness` are satisfiable:
there is a formal system together with a genuine Gödel sentence.  Take sentences
to be `Bool` (each sentence *is* its truth value), nothing provable, and negation
`not`; then `G = true` is a Gödel sentence. -/
theorem exists_godel_system :
    ∃ (F : FormalSystem) (G : F.Sentence), (F.True_ G ↔ ¬ F.Provable G) :=
  ⟨⟨Bool, fun _ => False, Bool.not, fun b => b = true, by tauto, by decide, by tauto⟩,
    true, by decide⟩

/-- **Cantor obstruction to completeness.**  The semantic properties of the
statements of a proof space (`Sentence → Prop`) cannot be enumerated by the
statements themselves: no map `Sentence → (Sentence → Prop)` is surjective.
Hence no proof system can internally name every property of its statements. -/
theorem cantor_incompleteness (Sentence : Type) :
    ¬ ∃ f : Sentence → (Sentence → Prop), Function.Surjective f := by
  rintro ⟨f, hf⟩
  exact Function.cantor_surjective f hf

end ProofSpace