import Logic.PhysicsConsistency.Incompleteness

/-!
# Logic–Physics Bridge III: Physical vs. Mathematical Consistency

This file assembles the proof-theoretic core results into the three claims of the
mission, where a **physical theory** `T` is a proof system that *extends* the
mathematical base `PA` (recorded by the catalog relation `ProofSystemCollapse.Simulates
T PA`: `T` proves everything `PA` proves).

* `physical_implies_math` — **physical consistency implies mathematical consistency**:
  if `T ⊇ PA` and `T` is consistent, then `PA` is consistent.
* `consistency_transfers_tower` — the same, transported along a tower of extensions
  using the catalog lemma `ProofSystemCollapse.simulates_trans`.
* `math_not_implies_physical` — **but not vice versa**: an explicit pair `(PA, T)` with
  `PA` a consistent GL theory, `T ⊇ PA`, yet `T` inconsistent.
* `con_T_independent_of_PA` — **if `T` is consistent then `Con(T)` is independent of
  `PA`**: under the (PA-verifiable) interpretation hypothesis `PA ⊢ Con(T) → Con(PA)`
  and the Σ₁-soundness hypothesis that `PA` is sound about `T`'s consistency, `PA`
  proves neither `Con(T)` nor `¬ Con(T)`.
* `con_T_independent_of_PA_witness` — a concrete instance (with `stdSys`) showing the
  independence theorem is non-vacuous.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): consistency flows *downward* along theory extension (more axioms
  ⇒ harder to be consistent) but not upward; and the physical theory's consistency,
  being strictly stronger than `Con(PA)`, escapes `PA`'s proving power entirely.
Experiment (Stage 2): `physical_implies_math` is a one-line contrapositive of
  `Simulates`; the converse is refuted by `(trueSys, trivialSys)`; the independence
  theorem combines `goedel_two` (for the positive half) with a Σ₁-soundness hypothesis
  (for the negative half), then is instantiated on `stdSys`.
Analysis (Stage 3): the asymmetry is genuine — downward transfer needs nothing but the
  extension relation, while the upward direction is *false*, witnessed concretely.
  Independence of `Con(T)` over `PA` needs the interpretation to be `PA`-verifiable
  (`hbridge`) and `PA` to be Σ₁-sound about `T` (`hsound`); both hold of real `PA`.
Critique (Stage 4): the cross-theory `box` indices (`p ≠ t` informally) prevent
  `Con(T)` and `Con(PA)` from being the same syntactic formula, so the theorem is not a
  disguised self-reference; the witness `con_T_independent_of_PA_witness` discharges all
  hypotheses with the standard Kripke model.
Synthesis (Stage 5): "consistency of a physical theory" is downward-transferable to
  mathematics, strictly stronger than mathematical consistency, and — exactly because
  of Gödel II — provably invisible to `PA`.
-/

namespace PhysicsConsistency

open ProofSystemCollapse Form

/-- **Physical consistency implies mathematical consistency.**  If a physical theory
`T` extends the mathematical base `PA` (`Simulates T PA`) and `T` is consistent, then
`PA` is consistent.  Contrapositive: an inconsistency of `PA` is inherited by `T`. -/
theorem physical_implies_math {T PA : ProofSys Form} (hsim : Simulates T PA)
    (hT : Consistent T) : Consistent PA := by
  intro hbot
  exact hT (hsim bot hbot)

/-- **Consistency transfers down a tower of extensions.**  If `T ⊇ M ⊇ PA` and `T` is
consistent then `PA` is consistent.  Uses the catalog transitivity lemma
`ProofSystemCollapse.simulates_trans`. -/
theorem consistency_transfers_tower {T M PA : ProofSys Form}
    (h1 : Simulates T M) (h2 : Simulates M PA) (hT : Consistent T) : Consistent PA :=
  physical_implies_math (ProofSystemCollapse.simulates_trans h1 h2) hT

/-- **Mathematical consistency does NOT imply physical consistency.**  There is a
consistent GL theory `PA` and a theory `T` extending it (`Simulates T PA`) that is
nonetheless inconsistent.  Witnesses: `PA := trueSys` (consistent), `T := trivialSys`
(proves everything, hence extends `PA` and is inconsistent). -/
theorem math_not_implies_physical :
    ∃ PA T : ProofSys.{0,0} Form,
      IsGLTheory 0 PA ∧ Consistent PA ∧ Simulates T PA ∧ ¬ Consistent T := by
  refine ⟨trueSys, trivialSys, isGL_trueSys 0, consistent_trueSys, ?_, ?_⟩
  · intro f _; exact provable_trivialSys f
  · exact inconsistent_trivialSys

/-- **If `T` is consistent then `Con(T)` is independent of `PA`.**

Let `PA` (tag `p`) be a consistent GL theory and `T` a consistent theory (tag `t`).
Assume:
* `hbridge` — `PA` verifies the interpretation, i.e. `PA ⊢ Con(T) → Con(PA)` (true when
  `T` extends `PA` and the extension is `PA`-formalizable);
* `hsound` — `PA` is Σ₁-sound about `T`'s consistency: if `PA ⊢ ¬ Con(T)` then `T` is
  actually inconsistent.

Then `PA` proves neither `Con(T)` nor `¬ Con(T)`.  The positive half is Gödel II for
`PA` (a `PA`-proof of `Con(T)` would yield a `PA`-proof of its own consistency
`Con(PA)`); the negative half is Σ₁-soundness against the assumed consistency of `T`. -/
theorem con_T_independent_of_PA {p t : ℕ} {PA T : ProofSys Form}
    (hPA : IsGLTheory p PA) (hPAc : Consistent PA) (hTc : Consistent T)
    (hbridge : Provable PA (imp (Con t) (Con p)))
    (hsound : Provable PA (neg (Con t)) → ¬ Consistent T) :
    ¬ Provable PA (Con t) ∧ ¬ Provable PA (neg (Con t)) := by
  refine ⟨?_, ?_⟩
  · intro hp
    exact goedel_two hPA hPAc (hPA.mp hbridge hp)
  · intro hp
    exact hsound hp hTc

/-- **The cross-theory independence theorem is non-vacuous.**  Taking both `PA` and `T`
to be the standard Kripke model `stdSys`, all hypotheses of `con_T_independent_of_PA`
are met, and we conclude `stdSys` proves neither `Con t` nor `¬ Con t`. -/
theorem con_T_independent_of_PA_witness (p t : ℕ) :
    ¬ Provable stdSys (Con t) ∧ ¬ Provable stdSys (neg (Con t)) := by
  have hbridge : Provable stdSys (imp (Con t) (Con p)) := by
    rw [provable_stdSys]; intro m; rw [sat_imp]; exact id
  have hnp : ¬ Provable stdSys (neg (Con t)) := (stdSys_con_independent t).2
  exact con_T_independent_of_PA (p := p) (t := t)
    (isGL_stdSys p) consistent_stdSys consistent_stdSys hbridge
    (fun hp => absurd hp hnp)

end PhysicsConsistency