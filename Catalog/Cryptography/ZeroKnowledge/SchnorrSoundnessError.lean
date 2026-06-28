import Mathlib
import Cryptography.SchnorrIdentification

/-!
# The exact soundness error of the Schnorr Σ-protocol is `1/p`

A cheating prover that does not know the discrete logarithm must commit to a value `t`
*before* seeing the challenge `c`, and can only send a single pre-chosen response `s`. We
prove that, for any nonzero public key `Y`, such a pre-committed pair `(t, s)` is accepted
for **exactly one** challenge `c` out of the `p` possible challenges. Hence the soundness
error — the maximal cheating probability of a witness-free prover over a uniform
challenge — is exactly `1/p`.

## Main results

* `accepts_iff_response` — for fixed `t, c, Y`, the accepting response is unique:
  `accepts P Y (t, c, s) ↔ s = (t + c * Y) * P.g⁻¹`.
* `winning_challenges_card` — for `Y ≠ 0` and fixed `(t, s)`, exactly one challenge is
  accepting: the filtered `Finset` over `ZMod p` has cardinality `1`.
* `challenge_space_card` — the challenge space `ZMod p` has cardinality `p`.
* `soundness_error` — the cheating probability `card winning / card all = 1 / p`.

-- !-- Lab Notes -- !--
Hypothesis (SE1): rewriting acceptance `s • g = t + c • Y` as a linear equation in the
challenge `c` (with `Y` invertible) yields a unique solution `c = (s • g - t) • Y⁻¹`, so the
winning-challenge set is a singleton.
Experiment: define `winningChallenge` explicitly, prove the membership iff over a prime
field, then compute the filtered `Finset.card` via `Finset.card_eq_one`. Outcome:
confirmed; the only structural inputs are that `ZMod p` is a field (`p` prime) and `Y ≠ 0`.
Analysis: this is the *quantitative* counterpart of special soundness — two winning
challenges would contradict the singleton, forcing extraction. Critique: the bound is tight
(`= 1/p`, not merely `≤`), and degenerates correctly: if `Y = 0` the prover either always
or never wins, so the `Y ≠ 0` hypothesis is essential and stated. Synthesis: combined with
`SchnorrKnowledgeSoundness`, the protocol is a proof of knowledge with knowledge error `1/p`.
-/

namespace SchnorrSE

open scoped Classical

variable (P : SchnorrParams)

/-- The unique accepting response for commitment `t`, challenge `c`, public key `Y`. -/
def responseFor (Y t c : ZMod P.p) : ZMod P.p := (t + c * Y) * P.g⁻¹

/-- The unique winning challenge for a pre-committed pair `(t, s)` against `Y ≠ 0`. -/
def winningChallenge (Y t s : ZMod P.p) : ZMod P.p := (s * P.g - t) * Y⁻¹

/-
**Uniqueness of the response.** For fixed `t, c, Y` the verifier accepts exactly one
response.
-/
theorem accepts_iff_response (Y t c s : ZMod P.p) :
    accepts P Y (t, c, s) ↔ s = responseFor P Y t c := by
  constructor;
  · intro h
    unfold responseFor at *;
    haveI := Fact.mk P.hp.1; rw [ ← h, mul_assoc, mul_inv_cancel₀ ( P.hg ), mul_one ] ;
  · intro hs
    rw [hs];
    unfold responseFor; simp +decide [ accepts, P.hg ] ;

/-
**Uniqueness of the winning challenge.** For `Y ≠ 0` and a pre-committed `(t, s)`,
acceptance holds for exactly the challenge `winningChallenge`.
-/
theorem accepts_iff_winningChallenge (Y t s c : ZMod P.p) (hY : Y ≠ 0) :
    accepts P Y (t, c, s) ↔ c = winningChallenge P Y t s := by
  constructor;
  · haveI := Fact.mk P.hp.1; simp_all +decide [ accepts, winningChallenge ] ;
  · intro hc
    rw [accepts]
    rw [hc]
    simp [winningChallenge];
    rw [ mul_assoc, inv_mul_cancel₀ hY, mul_one, add_sub_cancel ]

/-
**Exactly one winning challenge.** For `Y ≠ 0` and fixed `(t, s)`, the set of accepting
challenges in `ZMod p` has cardinality `1`.
-/
theorem winning_challenges_card (Y t s : ZMod P.p) (hY : Y ≠ 0) :
    (Finset.univ.filter (fun c : ZMod P.p => accepts P Y (t, c, s))).card = 1 := by
  convert Set.ncard_eq_one.mpr _ using 1;
  any_goals exact { c : ZMod P.p | accepts P Y ( t, c, s ) };
  · rw [ ← Set.ncard_coe_finset ] ; congr ; aesop;
  · exact ⟨ winningChallenge P Y t s, Set.eq_singleton_iff_unique_mem.mpr ⟨ by simpa using accepts_iff_winningChallenge P Y t s _ hY |>.2 rfl, fun c hc => by simpa using accepts_iff_winningChallenge P Y t s c hY |>.1 hc ⟩ ⟩

/-
The challenge space `ZMod p` has cardinality `p`.
-/
theorem challenge_space_card : (Finset.univ : Finset (ZMod P.p)).card = P.p := by
  convert ZMod.card P.p

/-
**Soundness error `= 1/p`.** The fraction of challenges on which a witness-free,
pre-committed prover `(t, s)` succeeds equals `1 / p`.
-/
theorem soundness_error (Y t s : ZMod P.p) (hY : Y ≠ 0) :
    ((Finset.univ.filter (fun c : ZMod P.p => accepts P Y (t, c, s))).card : ℚ)
        / (Finset.univ : Finset (ZMod P.p)).card
      = 1 / P.p := by
  erw [ winning_challenges_card P Y t s hY, challenge_space_card P, Nat.cast_one ]

end SchnorrSE