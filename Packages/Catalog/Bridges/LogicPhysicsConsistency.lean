import Logic.PhysicsConsistency.Provability
import Bridges.QuantumSystems.LogicPhysicsBridge

/-!
# Consistency of physical theories as a proof-theoretic question

This file combines two existing catalog interfaces:

* `PhysicsConsistency` supplies indexed consistency sentences `Con i` and GL-style
  provability predicates.
* `LogicPhysics` supplies physical consistency (existence of a model), mathematical
  consistency (non-derivability of falsum), and semantic soundness.

The unqualified assertion “if `T` is consistent, then `Con(T)` is independent of PA”
is not valid.  Independence from PA additionally needs (i) Gödel's derivability
conditions for PA, (ii) consistency of PA, (iii) a PA-formalized reflection from
`Con(T)` to `Con(PA)`, and (iv) enough soundness to prevent PA from proving that `T`
proves falsum.  These assumptions are collected in `PAIndependenceConditions`.
The theorem `physical_consistency_implies_Con_independent_of_PA` states the corrected
logic–physics bridge, while `consistency_alone_does_not_force_independence` formally
records why the omitted soundness assumptions matter.
-/

namespace PhysicsConsistency

open ProofSystemCollapse
open Form

/-- A sentence is independent of a proof system when neither it nor its negation is
provable. -/
def Independent (S : ProofSys Form) (a : Form) : Prop :=
  ¬ Provable S a ∧ ¬ Provable S (neg a)

/-- Gödel's second incompleteness argument internal to the catalog's GL interface.
If a GL theory were to prove its consistency sentence `□⊥ → ⊥`, necessitation and
Löb's axiom would make it prove `□⊥`, and modus ponens would then make it prove `⊥`. -/
theorem goedel_second_incompleteness {i : ℕ} {S : ProofSys Form}
    (hGL : IsGLTheory i S) (hcon : Consistent S) : ¬ Provable S (Con i) := by
  intro hCon
  have hboxedCon : Provable S (box i (imp (box i bot) bot)) := hGL.nec hCon
  have hboxedBot : Provable S (box i bot) := hGL.mp (hGL.loeb bot) hboxedCon
  exact hcon (hGL.mp hCon hboxedBot)

/-- The assumptions connecting a physical theory tagged `theory` to arithmetic
(tagged `pa`) that are actually needed for independence of `Con theory` from `PA`.
`reflection` says PA proves that consistency of the physical theory entails its own
consistency.  `sigmaSound` prevents PA from falsely proving that the physical theory
proves a contradiction. -/
structure PAIndependenceConditions (pa theory : ℕ) (PA : ProofSys Form) : Prop where
  gl : IsGLTheory pa PA
  consistent : Consistent PA
  reflection : Provable PA (imp (Con theory) (Con pa))
  sigmaSound : ¬ Provable PA (box theory bot)

/-- Under the precise arithmetic reflection and soundness assumptions,
`Con(theory)` is independent of PA.  The positive half reduces a hypothetical PA
proof of `Con(theory)` to a forbidden PA proof of `Con(PA)`.  The negative half uses
classical double-negation elimination to turn a proof of `¬Con(theory)` into a proof
of `□_theory ⊥`, contradicting `sigmaSound`. -/
theorem consistency_sentence_independent_of_PA {pa theory : ℕ} {PA : ProofSys Form}
    (h : PAIndependenceConditions pa theory PA) : Independent PA (Con theory) := by
  constructor
  · intro hTheory
    have hPACon : Provable PA (Con pa) := h.gl.mp h.reflection hTheory
    exact goedel_second_incompleteness h.gl h.consistent hPACon
  · intro hNotTheory
    have hdne : Provable PA (imp (neg (neg (box theory bot))) (box theory bot)) :=
      h.gl.taut (taut_dne (box theory bot))
    have hboxedBot : Provable PA (box theory bot) := by
      apply h.gl.mp hdne
      exact hNotTheory
    exact h.sigmaSound hboxedBot

/-- Physical realizability first gives mathematical consistency through semantic
soundness; with the independent proof-theoretic PA conditions, it simultaneously
gives the desired independence statement for the encoded consistency sentence. -/
theorem physical_consistency_implies_Con_independent_of_PA
    {Sentence : Type} {P : LogicPhysics.ProofSystem Sentence}
    (M : LogicPhysics.Semantics P) (hsound : LogicPhysics.Sound M)
    {T : Set Sentence} (hphysical : LogicPhysics.PhysicallyConsistent M T)
    {pa theory : ℕ} {PA : ProofSys Form}
    (hPA : PAIndependenceConditions pa theory PA) :
    LogicPhysics.Consistent P T ∧ Independent PA (Con theory) := by
  constructor
  · exact LogicPhysics.physical_implies_mathematical M hsound hphysical
  · exact consistency_sentence_independent_of_PA hPA

/-- Consistency by itself does **not** imply independence.  The catalog's box-true
GL model is meta-consistent, but it proves the negation of every indexed consistency
sentence.  Thus a soundness/reflection bridge cannot be omitted. -/
theorem consistency_alone_does_not_force_independence (i : ℕ) :
    Consistent trueSys ∧ ¬ Independent trueSys (Con i) := by
  constructor
  · exact consistent_trueSys
  · intro hind
    apply hind.2
    rw [provable_trueSys]
    simp [Con, neg, eval]

end PhysicsConsistency

namespace LogicPhysics

/-- The converse logic–physics implication fails even for a sound semantics: there
is a mathematically consistent theory with no physical realization.  This exposes
an existential gap that proof-theoretic consistency alone cannot close. -/
theorem mathematical_consistency_does_not_imply_physical_consistency :
    ∃ (P : ProofSystem ℕ) (M : Semantics P) (T : Set ℕ),
      Sound M ∧ Consistent P T ∧ ¬ PhysicallyConsistent M T := by
  exact math_consistency_not_sufficient

end LogicPhysics