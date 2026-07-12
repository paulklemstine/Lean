/-!
# Paradoxes as Theorems — A Concrete Six-Element Paraconsistent Witness Model

This file exhibits a *single explicit finite model* in which three distinct paradox
sentences are simultaneously **provable** and **glut-valued** (`BelnapVal.B`), yet the
theory is neither trivial nor explosive.  It is a fully computational certificate for
the abstract results of `Logic.ParadoxSelfSoundness`.

## The model

The sentence type is `Fin 6`.  The data are:

* `paradoxTruth = ![B, B, B, T, F, N]` — truth-value assignment;
* `paradoxNeg   = ![0, 1, 2, 4, 3, 5]` — syntactic negation;
* `paradoxProvable = {0, 1, 2, 3}` — the asserted/provable sentences.

Reading of the six sentences:

* `0`, `1`, `2` — the three named paradox witnesses (Liar / Russell / Berry style).
  Each is a *glut* (`B`) and a syntactic negation fixed point (`paradoxNeg i = i` for
  `i ∈ {0,1,2}`), so each sentence and its own negation are both asserted.
* `3` — a genuine classical truth (`T`), provable and designated.
* `4` — a genuine falsehood (`F`), *not* provable: a non-explosion witness.
* `5` — a truth-value gap (`N`), witnessing paracompleteness / nontriviality.

Note that the syntactic negation faithfully realizes Belnap negation:
`paradoxTruth (paradoxNeg i) = (paradoxTruth i).neg` for every `i`.

## What is and is not claimed

We do **not** encode full natural-language Liar/Russell/Berry semantics.  We claim only
the precise finite facts below: three distinct provable gluts coexist, every provable
sentence is designated (self-soundness), explosion is rejected by an explicit
counterexample, and the inconsistency degree (number of gluts) is exactly three.
-/

open BelnapVal

namespace ParadoxesAsTheorems

/-- Truth-value assignment of the model: three gluts, one truth, one falsehood, one gap. -/
def paradoxTruth : Fin 6 → BelnapVal := ![B, B, B, T, F, N]

/-- Syntactic negation of the model. The three gluts `0,1,2` are fixed points; `3`/`4`
swap (true/false); the gap `5` is fixed. -/
def paradoxNeg : Fin 6 → Fin 6 := ![0, 1, 2, 4, 3, 5]

/-- The six-element paraconsistent witness theory. -/
def paradoxModel : ParaconsistentTheory (Fin 6) where
  truth := paradoxTruth
  sentNeg := paradoxNeg

/-- The asserted / provable sentences: the three paradox gluts together with the genuine
truth `3`. -/
def paradoxProvable : Set (Fin 6) := {0, 1, 2, 3}

/-- The syntactic negation faithfully realizes Belnap negation on truth values. -/
theorem paradoxModel_neg_coherent (i : Fin 6) :
    paradoxModel.truth (paradoxModel.sentNeg i) = (paradoxModel.truth i).neg := by
  fin_cases i <;> rfl

/-- **Three distinct gluts.** Sentences `0`, `1`, `2` are pairwise distinct and each is
glut-valued (`B`). -/
theorem paradoxModel_three_distinct_gluts :
    (0 : Fin 6) ≠ 1 ∧ (0 : Fin 6) ≠ 2 ∧ (1 : Fin 6) ≠ 2 ∧
      paradoxModel.truth 0 = BelnapVal.B ∧
      paradoxModel.truth 1 = BelnapVal.B ∧
      paradoxModel.truth 2 = BelnapVal.B := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> decide

/-- **Paradoxes as theorems.** The three paradox constants are provable, designated
(at-least-true), and glut-valued. -/
theorem paradoxes_as_theorems :
    (0 : Fin 6) ∈ paradoxProvable ∧
      (1 : Fin 6) ∈ paradoxProvable ∧
      (2 : Fin 6) ∈ paradoxProvable ∧
      (paradoxModel.truth 0).isTrue = true ∧
      (paradoxModel.truth 1).isTrue = true ∧
      (paradoxModel.truth 2).isTrue = true ∧
      paradoxModel.truth 0 = BelnapVal.B ∧
      paradoxModel.truth 1 = BelnapVal.B ∧
      paradoxModel.truth 2 = BelnapVal.B := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · simp [paradoxProvable]
  · simp [paradoxProvable]
  · simp [paradoxProvable]
  all_goals decide

/-- **Self-soundness.** Every provable sentence of the model is designated
(at-least-true). The proof reduces to the four cases `0, 1, 2, 3`. -/
theorem paradoxModel_self_sound : paradoxModel.isSound paradoxProvable := by
  intro s hs
  simp only [paradoxProvable, Set.mem_insert_iff, Set.mem_singleton_iff] at hs
  rcases hs with h | h | h | h <;> subst h <;> decide

/-- **Explosion would collapse the model.** If the truth-assignment satisfied the
explosive rule (everything follows from the glut `0`), then *every* sentence of `Fin 6`
would be designated. This is the precise finite instance of `HasExplosion`. -/
theorem explosion_collapses_paradoxModel
    (hExpl : HasExplosion (Fin 6) paradoxModel) :
    ∀ q : Fin 6, (paradoxModel.truth q).isTrue = true :=
  fun q => hExpl 0 q (by decide)

/-- **Non-explosion.** The model rejects explosion: the glut `0` (which is its own
syntactic negation, since `paradoxNeg 0 = 0`) does not make the falsehood `4` designated.
Hence `HasExplosion` fails. -/
theorem paradoxModel_rejects_explosion : ¬ HasExplosion (Fin 6) paradoxModel := by
  intro h
  exact absurd (h 0 4 (by decide)) (by decide)

/-- **Inconsistency degree is exactly three.** Exactly three sentences of the model are
glut-valued. -/
theorem paradoxModel_inconsistency_degree : inconsistencyDegree paradoxModel = 3 := by
  decide

/-- The inconsistency degree is at least three. -/
theorem paradoxModel_degree_ge_three : 3 ≤ inconsistencyDegree paradoxModel := by
  decide

end ParadoxesAsTheorems