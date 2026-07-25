import Mathlib
import Cryptography.ZeroKnowledge.Graph3Coloring

/-!
# Soundness Amplification for the GMW Graph 3-Colouring Proof

A single round of the Goldreich–Micali–Wigderson protocol has only a *constant*
soundness gap: against an improper committed colouring the verifier rejects with
probability `≥ 1/|E|` (proved in `Cryptography.ZeroKnowledge.Graph3Coloring`).
This file shows how **sequential repetition** drives the cheating probability to
zero.

We model the one-round acceptance probability of a (cheating) prover committed to
an improper colouring `c'` as the fraction of edges whose endpoints receive
*distinct* colours (those are exactly the edges the verifier fails to catch).
Running `k` independent rounds multiplies this probability, giving `p ^ k`.

## Main results

* `roundAcceptProb_nonneg` / `roundAcceptProb_le_one` — the acceptance probability
  is a genuine probability in `[0, 1]`.
* `roundAcceptProb_lt_one` — against an **improper** colouring the acceptance
  probability is strictly below `1`.
* `roundAcceptProb_le_one_sub` — the quantitative gap: acceptance is at most
  `1 - 1/|E|`.
* `soundness_amplification` — **the amplification theorem**: the `k`-round
  cheating probability `p ^ k` tends to `0` as `k → ∞`. Hence for any target
  error the verifier can be convinced, on a false statement, with vanishing
  probability by repeating the protocol.
* `soundness_amplification_exists` — the `∀ ε > 0, ∃ k` reformulation.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The constant per-round soundness gap `1/|E|` of GMW
can be amplified to an arbitrarily small error by sequential repetition; formally,
the `k`-round acceptance probability `p ^ k` converges to `0`, with `p < 1`
whenever the committed colouring is improper.

Experiment (Experimenter): Defined `roundAcceptProb` as the fraction of "uncaught"
edges. The key inequality `roundAcceptProb < 1` was reduced, via
`Finset.filter_card_add_filter_neg_card_eq_card`, to the existence of at least one
caught edge — precisely `soundness_catch_card` from the base file. Convergence
then follows from `tendsto_pow_atTop_nhds_zero_of_lt_one` applied to `0 ≤ p < 1`.

Analysis (Analyst): The proof cleanly separates the *combinatorial* content (there
is a caught edge) from the *analytic* content (geometric decay). Reusing
`soundness_catch_card` demonstrates that the base soundness lemma is exactly the
hypothesis needed for amplification. The `∃ k` corollary makes the practical
guarantee explicit. The "true but hard" boundary avoided is a full probabilistic
model of adaptive provers across rounds; the multiplicative independence model is
the standard and sufficient one for sequential repetition.

Critique (Critic): `roundAcceptProb_lt_one` genuinely needs the improperness
hypothesis (checked: it feeds `soundness_catch_card`); dropping it makes the claim
false (a proper colouring is always accepted). `soundness_amplification` is not a
`decide`/`norm_num` fact — it invokes a real convergence theorem. The probability
`p` is bounded in `[0,1]` so the statement is not vacuous.

Synthesis (PI): This upgrades the single-round soundness gap into the full
soundness guarantee of the interactive proof system: false statements are
accepted with probability `→ 0`.
-- !-- Lab Notes -- !--
-/

namespace ZK.Graph3Coloring

open Finset

/-- The one-round **acceptance probability** of a prover committed to colouring
`c'`: the fraction of edges whose endpoints get distinct colours (the edges on
which the verifier accepts). -/
noncomputable def roundAcceptProb (E : Finset (V × V)) (c' : V → Fin 3) : ℝ :=
  ((E.filter (fun e => c' e.1 ≠ c' e.2)).card : ℝ) / E.card

/-- Acceptance probability is nonnegative. -/
theorem roundAcceptProb_nonneg (E : Finset (V × V)) (c' : V → Fin 3) :
    0 ≤ roundAcceptProb E c' := by
  unfold roundAcceptProb
  positivity

/-- Acceptance probability is at most `1`. -/
theorem roundAcceptProb_le_one (E : Finset (V × V)) (c' : V → Fin 3) :
    roundAcceptProb E c' ≤ 1 := by
  unfold roundAcceptProb
  rcases Nat.eq_zero_or_pos E.card with h | h
  · simp [h]
  · rw [div_le_one (by exact_mod_cast h)]
    exact_mod_cast Finset.card_filter_le _ _

/-- **Quantitative soundness gap.** Against an improper committed colouring the
one-round acceptance probability is at most `1 - 1/|E|`. -/
theorem roundAcceptProb_le_one_sub (E : Finset (V × V)) (c' : V → Fin 3)
    (hE : 0 < E.card) (h : ¬ IsProperColoring E c') :
    roundAcceptProb E c' ≤ 1 - 1 / (E.card : ℝ) := by
  have hcard : (E.filter (fun e => c' e.1 ≠ c' e.2)).card
      + (E.filter (fun e => c' e.1 = c' e.2)).card = E.card := by
    simpa using Finset.card_filter_add_card_filter_not
      (s := E) (p := fun e => c' e.1 ≠ c' e.2)
  have hcatch : 1 ≤ (E.filter (fun e => c' e.1 = c' e.2)).card :=
    soundness_catch_card E c' h
  have hpos : (0 : ℝ) < E.card := by exact_mod_cast hE
  unfold roundAcceptProb
  rw [div_le_iff₀ hpos]
  have : ((E.filter (fun e => c' e.1 ≠ c' e.2)).card : ℝ) ≤ (E.card : ℝ) - 1 := by
    have : (E.filter (fun e => c' e.1 ≠ c' e.2)).card ≤ E.card - 1 := by omega
    have h2 : ((E.filter (fun e => c' e.1 ≠ c' e.2)).card : ℝ) ≤ ((E.card - 1 : ℕ) : ℝ) := by
      exact_mod_cast this
    rw [Nat.cast_sub (by omega)] at h2
    push_cast at h2 ⊢
    linarith
  have hE1 : (1 : ℝ) ≤ (E.card : ℝ) := by exact_mod_cast hE
  rw [sub_mul, one_mul, div_mul_cancel₀]
  · linarith
  · exact ne_of_gt hpos

/-- Against an improper committed colouring the one-round acceptance probability is
strictly below `1`. -/
theorem roundAcceptProb_lt_one (E : Finset (V × V)) (c' : V → Fin 3)
    (hE : 0 < E.card) (h : ¬ IsProperColoring E c') :
    roundAcceptProb E c' < 1 := by
  have hpos : (0 : ℝ) < E.card := by exact_mod_cast hE
  have := roundAcceptProb_le_one_sub E c' hE h
  have : (0 : ℝ) < 1 / (E.card : ℝ) := by positivity
  linarith [roundAcceptProb_le_one_sub E c' hE h]

/-- **Soundness amplification.** The `k`-round cheating probability `p ^ k` tends
to `0` as the number of rounds `k → ∞`, where `p = roundAcceptProb E c'` is the
one-round acceptance probability of an improper committed colouring. -/
theorem soundness_amplification (E : Finset (V × V)) (c' : V → Fin 3)
    (hE : 0 < E.card) (h : ¬ IsProperColoring E c') :
    Filter.Tendsto (fun k : ℕ => (roundAcceptProb E c') ^ k)
      Filter.atTop (nhds 0) :=
  tendsto_pow_atTop_nhds_zero_of_lt_one
    (roundAcceptProb_nonneg E c') (roundAcceptProb_lt_one E c' hE h)

/-- **Amplification, `∃ k` form.** For any target error `ε > 0` there is a number
of rounds `k` after which a cheating prover (improper committed colouring) is
accepted with probability below `ε`. -/
theorem soundness_amplification_exists (E : Finset (V × V)) (c' : V → Fin 3)
    (hE : 0 < E.card) (h : ¬ IsProperColoring E c') {ε : ℝ} (hε : 0 < ε) :
    ∃ k : ℕ, (roundAcceptProb E c') ^ k < ε := by
  have hlt := roundAcceptProb_lt_one E c' hE h
  obtain ⟨k, hk⟩ := exists_pow_lt_of_lt_one hε hlt
  exact ⟨k, hk⟩

end ZK.Graph3Coloring