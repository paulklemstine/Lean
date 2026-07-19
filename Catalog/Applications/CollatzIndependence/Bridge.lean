import Mathlib
import Applications.Collatz.Basic
import Logic.PhysicsConsistency.Incompleteness

/-!
# A rigorous conditional bridge from Collatz dynamics to incompleteness

This file deliberately does **not** assert that the Collatz conjecture is equivalent
(or even related in proof-theoretic strength) to `Con(PA)`: no such result is known.
Instead it isolates the exact hypotheses that the proposed connection would require
and proves their consequences.

There are two independent layers:

* the standard arithmetic Collatz predicate `CollatzConjecture`;
* an abstract GL proof system, used as a sound kernel-level version of the
  Gödel–Löb argument.

The main result `collatz_unprovable_of_internal_reduction` says that an internal
reduction from a sentence coding Collatz to the theory's own consistency sentence
already makes that Collatz sentence unprovable in any consistent GL theory.  The
result `counterexample_implies_inconsistency_of_semantic_equivalence` records what a
literal semantic equivalence with consistency would imply.  Its equivalence is an
explicit hypothesis, rather than an unsupported theorem about PA.
-/

namespace CollatzIndependence

open ProofSystemCollapse
open PhysicsConsistency PhysicsConsistency.Form

/-- The standard statement that the positive orbit of `n` reaches `1`. -/
def ReachesOne (n : ℕ) : Prop := ∃ k : ℕ, Collatz.T^[k] n = 1

/-- The usual Collatz conjecture on positive natural numbers. -/
def CollatzConjecture : Prop := ∀ n : ℕ, 0 < n → ReachesOne n

/-- A (semantic) Collatz counterexample is a positive orbit which never reaches `1`. -/
def Counterexample (n : ℕ) : Prop := 0 < n ∧ ∀ k : ℕ, Collatz.T^[k] n ≠ 1

/-- Negating the universal Collatz statement is exactly exhibiting a positive orbit
that never reaches `1`.  This is constructive in the forward direction and uses
classical quantifier negation in the reverse direction. -/
theorem not_collatz_iff_exists_counterexample :
    ¬ CollatzConjecture ↔ ∃ n : ℕ, Counterexample n := by
  simp only [CollatzConjecture, ReachesOne, Counterexample]
  push_neg
  rfl

/-- Any explicitly certified orbit avoiding `1` refutes the Collatz conjecture. -/
theorem counterexample_refutes_collatz {n : ℕ} (h : Counterexample n) :
    ¬ CollatzConjecture := by
  rw [not_collatz_iff_exists_counterexample]
  exact ⟨n, h⟩

/-- The formal core of the proposed Collatz–Gödel bridge.

Let `C` be a formula intended to encode Collatz in a theory `PA`, and suppose `PA`
can prove `C → Con(PA)`.  If `PA` is a consistent GL theory, then it cannot prove
`C`: otherwise modus ponens would give a proof of `Con(PA)`, contradicting Gödel's
second incompleteness theorem (`goedel_two`).

Notice that this needs only the forward internal reduction, not a full equivalence.
The difficult, currently unsupported research claim is precisely the construction of
such a faithful `C` and such a proof for actual first-order PA. -/
theorem collatz_unprovable_of_internal_reduction
    {p : ℕ} {PA : ProofSys PhysicsConsistency.Form}
    (hGL : IsGLTheory p PA) (hcons : Consistent PA)
    (collatzFormula : PhysicsConsistency.Form)
    (hreduces : Provable PA (imp collatzFormula (Con p))) :
    ¬ Provable PA collatzFormula := by
  intro hC
  exact goedel_two hGL hcons (hGL.mp hreduces hC)

/-- A provable internal equivalence between a Collatz code and `Con(PA)` supplies the
forward reduction needed by `collatz_unprovable_of_internal_reduction`. -/
theorem collatz_unprovable_of_internal_equivalence
    {p : ℕ} {PA : ProofSys PhysicsConsistency.Form}
    (hGL : IsGLTheory p PA) (hcons : Consistent PA)
    (collatzFormula : PhysicsConsistency.Form)
    (hforward : Provable PA (imp collatzFormula (Con p)))
    (_hbackward : Provable PA (imp (Con p) collatzFormula)) :
    ¬ Provable PA collatzFormula := by
  exact collatz_unprovable_of_internal_reduction hGL hcons collatzFormula hforward

/-- Under a provable internal equivalence and the standard consistency plus
Σ₁-soundness assumptions, independence of the consistency sentence transfers to the
formula coding Collatz.  The negative half uses classical contraposition inside the
object language: from `Con(PA) → C`, a proof of `¬C` would yield `¬Con(PA)`. -/
theorem collatz_independent_of_internal_equivalence
    {p : ℕ} {PA : ProofSys PhysicsConsistency.Form}
    (hGL : IsGLTheory p PA) (hcons : Consistent PA)
    (hsigma : ¬ Provable PA (box p bot))
    (collatzFormula : PhysicsConsistency.Form)
    (hforward : Provable PA (imp collatzFormula (Con p)))
    (hbackward : Provable PA (imp (Con p) collatzFormula)) :
    ¬ Provable PA collatzFormula ∧ ¬ Provable PA (neg collatzFormula) := by
  refine ⟨collatz_unprovable_of_internal_reduction hGL hcons collatzFormula hforward, ?_⟩
  intro hnotC
  have hcontra : Taut
      (imp (imp (Con p) collatzFormula) (imp (neg collatzFormula) (neg (Con p)))) := by
    intro v hbot himp
    simp only [neg, himp, hbot]
    cases v (Con p) <;> cases v collatzFormula <;> simp
  have hnotCon : Provable PA (neg (Con p)) :=
    hGL.mp (hGL.mp (hGL.taut hcontra) hbackward) hnotC
  exact (con_independent_self hGL hcons hsigma).2 hnotCon

/-- **Semantic consequence of the conjectured equivalence.**  If the actual Collatz
statement is equivalent to meta-level consistency of a proof system, then a Collatz
counterexample implies that the proof system is inconsistent.

The equivalence is intentionally an explicit assumption.  Thus this theorem proves
what the mission's proposed bridge *would imply*, without pretending to establish the
unknown equivalence for Peano Arithmetic. -/
theorem counterexample_implies_inconsistency_of_semantic_equivalence
    {PA : ProofSys PhysicsConsistency.Form}
    (hequiv : CollatzConjecture ↔ Consistent PA)
    {n : ℕ} (hn : Counterexample n) :
    ¬ Consistent PA := by
  intro hcons
  exact counterexample_refutes_collatz hn (hequiv.mpr hcons)

/-- Conversely, under the same proposed semantic equivalence, consistency implies the
standard Collatz conjecture.  This makes explicit that proving the equivalence would
already settle the truth of Collatz whenever consistency is available externally. -/
theorem collatz_of_consistency_of_semantic_equivalence
    {PA : ProofSys PhysicsConsistency.Form}
    (hequiv : CollatzConjecture ↔ Consistent PA)
    (hcons : Consistent PA) : CollatzConjecture := by
  exact hequiv.mpr hcons

/-- A useful obstruction test: any positive orbit with a supplied certificate that
all iterates avoid `1` is incompatible with consistency under the proposed bridge. -/
theorem orbit_avoidance_incompatible_with_consistency
    {PA : ProofSys PhysicsConsistency.Form}
    (hequiv : CollatzConjecture ↔ Consistent PA)
    {n : ℕ} (hn : 0 < n) (havoid : ∀ k : ℕ, Collatz.T^[k] n ≠ 1) :
    ¬ Consistent PA := by
  exact counterexample_implies_inconsistency_of_semantic_equivalence hequiv ⟨hn, havoid⟩

end CollatzIndependence