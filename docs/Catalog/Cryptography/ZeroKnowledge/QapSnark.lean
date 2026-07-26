import Mathlib
import Bridges.SumcheckSoundness

/-!
# A Simplified zk-SNARK Circuit and Its Soundness

This file formalizes the algebraic core of a Pinocchio/Groth16-style zk-SNARK: the
reduction of arithmetic-circuit satisfaction to a **Quadratic Arithmetic Program
(QAP)** divisibility test, together with completeness, soundness, and knowledge
soundness of the random-point check.

Over a field `F`, a QAP is summarised by a *target polynomial* `t` (whose roots
encode the circuit's gates) and a *witness polynomial* `p` built from the prover's
assignment. The assignment satisfies the circuit iff `t ∣ p`. The prover supplies
a quotient `h` and convinces the verifier by opening the identity at a single
random evaluation point `s`, checking `p.eval s = (h * t).eval s`.

## Main results

* `qapValid_iff_exists_quotient` — circuit satisfaction (`t ∣ p`) is equivalent to
  the existence of a quotient `h` with `p = h * t`.
* `qap_completeness` — an honest prover (with the true quotient) passes the check
  at *every* evaluation point.
* `qap_soundness_card` — a cheating prover (`p ≠ h * t`) passes the random-point
  check on at most `natDegree (p - h * t)` field elements (Schwartz–Zippel, reused
  from `Bridges.SumcheckSoundness`).
* `qap_soundness_prob` — hence the cheating success probability is at most
  `deg / |F|`.
* `qap_knowledge_soundness` — if the prover passes on strictly more than
  `natDegree (p - h * t)` points, then necessarily `p = h * t` (extractable
  identity / binding).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The whole soundness of a QAP-based SNARK is a *single*
application of Schwartz–Zippel to the discrepancy polynomial `p - h·t`; no extra
cryptographic assumption is needed for the *information-theoretic* check (the
crypto only hides `s`).

Experiment (Experimenter): Defined `qapCheck p h t s := p.eval s = (h*t).eval s`,
reused `SumcheckSoundness.card_eq_eval_le_natDegree_sub` for the agreement bound,
and `cheating_prob_le` for the probability form. Completeness is `eval_mul`.

Analysis (Analyst): Knowledge soundness here is the contrapositive of the counting
bound: passing on more points than the degree forces the polynomials to coincide.
The "needs a different definition" boundary: full *zero-knowledge* of the SNARK
(simulatability) requires a trusted-setup / pairing model not captured by the bare
polynomial identity, so we scope this file to soundness + completeness.

Critique (Critic): The soundness theorem is vacuous only if `p = h*t`; we guard it
with `hne : p ≠ h * t`. The degree bound is genuine (Schwartz–Zippel), not `decide`.
Reuses an existing catalog file (`Bridges/SumcheckSoundness.lean`).

Synthesis (PI): Completeness + soundness + knowledge soundness together certify the
simplified SNARK verifier.
-- !-- Lab Notes -- !--
-/

namespace ZK.QapSnark

open Polynomial Finset

variable {F : Type*} [Field F]

/-- The QAP witness is *valid* (the circuit is satisfied) when the target
polynomial divides the witness polynomial. -/
def QapValid (t p : Polynomial F) : Prop := t ∣ p

/-- The verifier's single-point check: the prover's claimed quotient `h` satisfies
the QAP identity at the evaluation point `s`. -/
def qapCheck (p h t : Polynomial F) (s : F) : Prop := p.eval s = (h * t).eval s

/-- Circuit satisfaction is equivalent to the existence of an honest quotient. -/
theorem qapValid_iff_exists_quotient (t p : Polynomial F) :
    QapValid t p ↔ ∃ h : Polynomial F, p = h * t := by
  unfold QapValid
  constructor
  · rintro ⟨h, rfl⟩
    exact ⟨h, by ring⟩
  · rintro ⟨h, rfl⟩
    exact ⟨h, by ring⟩

/-- **Completeness.** With the true quotient (`p = h * t`), the QAP check passes at
*every* evaluation point. -/
theorem qap_completeness (p h t : Polynomial F) (hp : p = h * t) (s : F) :
    qapCheck p h t s := by
  unfold qapCheck
  rw [hp]

/-! ## Soundness over a finite field -/

variable [Fintype F] [DecidableEq F]

/-- **Soundness (counting form).** A cheating prover whose claimed identity is
false (`p ≠ h * t`) passes the random-point check on at most
`natDegree (p - h * t)` field elements. This is the univariate Schwartz–Zippel
bound, reused from `Bridges/SumcheckSoundness.lean`. -/
theorem qap_soundness_card (p h t : Polynomial F) (hne : p ≠ h * t) :
    (univ.filter fun s : F => p.eval s = (h * t).eval s).card ≤ (p - h * t).natDegree :=
  SumcheckSoundness.card_eq_eval_le_natDegree_sub p (h * t) hne

/-- **Soundness (probability form).** The cheating success probability of the QAP
check is at most `natDegree (p - h * t) / |F|`. -/
theorem qap_soundness_prob (p h t : Polynomial F) (hne : p ≠ h * t) :
    ((univ.filter fun s : F => p.eval s = (h * t).eval s).card : ℚ) / Fintype.card F
      ≤ (p - h * t).natDegree / Fintype.card F :=
  SumcheckSoundness.cheating_prob_le p (h * t) hne

/-- **Knowledge soundness / binding.** If the prover passes the check on strictly
more than `natDegree (p - h * t)` evaluation points, then the claimed identity is
in fact exact: `p = h * t`. (Contrapositive of `qap_soundness_card`.) -/
theorem qap_knowledge_soundness (p h t : Polynomial F)
    (hpass : (p - h * t).natDegree <
      (univ.filter fun s : F => p.eval s = (h * t).eval s).card) :
    p = h * t := by
  by_contra hne
  exact absurd (qap_soundness_card p h t hne) (not_le.mpr hpass)

end ZK.QapSnark