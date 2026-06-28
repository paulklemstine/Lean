import Logic.PhysicsConsistency.Provability

/-!
# Logic–Physics Bridge II: Löb's Theorem and Gödel's Second Incompleteness Theorem

Building on the abstract GL theories of `Logic.PhysicsConsistency.Provability`, this
file proves, for *any* GL theory (and hence for the proof-theoretic core of any
recursively axiomatized physical theory):

* `loeb_rule` — **Löb's theorem** as a derived rule: if a theory proves `□a → a`, it
  proves `a`.  The proof uses only modus ponens, necessitation and the Löb axiom.
* `goedel_two` — **Gödel's second incompleteness theorem** (abstract form): a
  consistent GL theory does not prove its own consistency sentence `Con i`.  It is the
  instance `a := ⊥` of Löb's theorem, since `Con i = (□⊥ → ⊥)`.
* `con_independent_self` — for a consistent *and* Σ₁-sound GL theory, the consistency
  sentence `Con i` is **independent**: the theory proves neither `Con i` nor `¬ Con i`.
* `stdSys_con_independent` — the standard Kripke model `stdSys` is an explicit witness
  that the independence theorem is non-vacuous.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the entire incompleteness phenomenon for a consistent theory
  collapses to Löb's theorem at `a := ⊥`.
Experiment (Stage 2): `loeb_rule` follows from `nec`, the `loeb` axiom and two modus
  ponens steps; `goedel_two` is one application; the negation half of independence
  reduces a `¬¬(□⊥)` theorem to `□⊥` via `taut_dne`, contradicting Σ₁-soundness.
Analysis (Stage 3): consistency alone gives `theory ⊬ Con`; the *other* direction
  `theory ⊬ ¬Con` genuinely needs Σ₁-soundness — exactly why the box-true model
  `trueSys` (consistent but not Σ₁-sound) fails to witness full independence while the
  standard Kripke model `stdSys` succeeds.
Critique (Stage 4): `goedel_two` is not vacuous — `consistent_stdSys` supplies a
  consistent GL theory, and `stdSys_con_independent` discharges both halves concretely.
Synthesis (Stage 5): Gödel II is the precise sense in which a consistent physical
  theory cannot certify its own consistency; the next file lifts this to the
  PA-vs-physical-theory bridge.
-/

namespace PhysicsConsistency

open ProofSystemCollapse Form

/-- **Löb's theorem (derived rule).**  In any GL theory, if `□a → a` is provable then
`a` is provable.  Hilbert–Bernays–Löb conditions only: necessitation turns `□a → a`
into `□(□a → a)`; the Löb axiom and modus ponens give `□a`; one more modus ponens
gives `a`. -/
theorem loeb_rule {i : ℕ} {S : ProofSys Form} (h : IsGLTheory i S) {a : Form}
    (ha : Provable S (imp (box i a) a)) : Provable S a := by
  have h1 : Provable S (box i (imp (box i a) a)) := h.nec ha
  have h2 : Provable S (box i a) := h.mp (h.loeb a) h1
  exact h.mp ha h2

/-- **Gödel's second incompleteness theorem (abstract form).**  A consistent GL theory
does not prove its own consistency sentence `Con i = (□⊥ → ⊥)`.  Indeed, by Löb's
theorem applied to `a := ⊥`, proving `Con i` would yield a proof of `⊥`. -/
theorem goedel_two {i : ℕ} {S : ProofSys Form} (h : IsGLTheory i S)
    (hc : Consistent S) : ¬ Provable S (Con i) := by
  intro hp
  exact hc (loeb_rule h hp)

/-- **Independence of the consistency sentence.**  For a consistent and Σ₁-sound GL
theory (one that proves neither `⊥` nor `□⊥`), the consistency sentence `Con i` is
independent: the theory proves neither `Con i` nor its negation `¬ Con i`.

The first half is Gödel II.  For the second, `¬ Con i = ¬¬(□⊥)`; double-negation
elimination (`taut_dne`) would turn a proof of it into a proof of `□⊥`, contradicting
Σ₁-soundness. -/
theorem con_independent_self {i : ℕ} {S : ProofSys Form} (h : IsGLTheory i S)
    (hc : Consistent S) (hsigma : ¬ Provable S (box i bot)) :
    ¬ Provable S (Con i) ∧ ¬ Provable S (neg (Con i)) := by
  refine ⟨goedel_two h hc, ?_⟩
  intro hp
  have hdne : Provable S (imp (neg (neg (box i bot))) (box i bot)) :=
    h.taut (taut_dne (box i bot))
  -- `Con i = neg (box i bot)`, so `neg (Con i) = neg (neg (box i bot))`.
  exact hsigma (h.mp hdne hp)

/-- **Non-vacuity witness.**  The standard Kripke model `stdSys` is a consistent,
Σ₁-sound GL theory, so its consistency sentence is genuinely independent: `stdSys`
proves neither `Con i` nor `¬ Con i`. -/
theorem stdSys_con_independent (i : ℕ) :
    ¬ Provable stdSys (Con i) ∧ ¬ Provable stdSys (neg (Con i)) :=
  con_independent_self (isGL_stdSys i) consistent_stdSys (stdSys_sigma_sound i)

end PhysicsConsistency