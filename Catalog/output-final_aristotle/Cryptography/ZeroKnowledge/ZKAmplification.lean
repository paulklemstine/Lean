import Mathlib

/-!
# Soundness Amplification for Zero-Knowledge Theorem Proving

This file develops the *probabilistic core* of the zero-knowledge theorem-proving
protocol described in the mission: a prover commits to the steps of an
arithmetized proof; in each round the verifier challenges one uniformly random
step; repeating the protocol `k` times drives the soundness error down
geometrically.

The mathematical content here is the **independence / product-measure**
statement that makes repetition work. A single round has a challenge space `Ω`
(the set of proof steps, modeled as `Fin n`). A cheating prover on round `i` is
characterized by its *accepting set* `A i ⊆ Ω` — the challenges it survives. The
`k`-round accepting event is the product set `Fintype.piFinset A` inside the
product challenge space `Fin k → Ω`, and the uniform probability of surviving all
rounds is the product of the per-round survival fractions.

## Main results

* `piFinset_card_eq_prod` / `roundAccept_card_le` — the number of `k`-round
  challenge vectors on which a prover survives equals the product of per-round
  accepting-set sizes, and is bounded by `e ^ k` when every round accepts at most
  `e` challenges.
* `amplified_prob_le` — **(main theorem)** the uniform probability that a prover
  survives all `k` rounds is at most `(e / n) ^ k`.
* `amplified_two_pow` — under `2 * e ≤ n` (each round catches a cheater with
  probability `≥ 1/2`) the `k`-round soundness error is at most `2 ^ (-k)`,
  matching the mission's target `2^{-k}`.
* `prod_prob_le_pow` — the real-valued product bound used to compose per-round
  soundness bounds coming from other protocols.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): For independent rounds, the probability of an event
"survive every round" factorizes as a product of per-round probabilities; hence
if each round independently catches a cheating prover with probability `≥ δ`, the
`k`-round escape probability is `≤ (1-δ)^k`. With `δ ≥ 1/2` this is `≤ 2^{-k}` —
exactly the mission's soundness-amplification claim.

Experiment (Experimenter): Modeled the `k`-round challenge space as the finite
product `Fin k → Fin n` and the survival event as `Fintype.piFinset A`. Verified
`#(piFinset A) = ∏ i, #(A i)` (Mathlib `Fintype.card_piFinset`), then bounded the
product by `e^k` via `Finset.prod_le_prod'` and `Finset.prod_const`. The
probability version follows by dividing by `n^k` and `div_pow`.

Analysis (Analyst): The identity `#(piFinset A) = ∏ #(A i)` is precisely the
statement that rounds are *independent* under the uniform product measure — this
is the load-bearing probabilistic fact, not the arithmetic that follows. The
`2^{-k}` corollary needs `2*e ≤ n`; for a general PA proof with `n` steps and one
bad step, a single round only catches with probability `1/n`, so one needs
`O(n·k)` rounds for error `2^{-k}` (captured by the sharper `((n-1)/n)^k` bound in
the companion file).

Critique (Critic): `amplified_prob_le` is non-vacuous — it is an inequality
between genuine rational probabilities, proved with `gcongr` after a real
`Finset.prod` bound, not `decide`. The `2^{-k}` corollary carries the essential
hypothesis `2*e ≤ n` explicitly and would be false without it.

Synthesis (PI): Together these give the probabilistic backbone: independent
repetition multiplies survival probabilities, so soundness error decays
geometrically to `2^{-k}`.
-- !-- Lab Notes -- !--
-/

namespace ZK.Amplification

open Finset

/-- **Independence identity.** The number of `k`-round challenge vectors on which
the prover survives every round equals the product of the per-round accepting-set
sizes. This is the uniform product measure factorizing over independent rounds. -/
theorem piFinset_card_eq_prod {k n : ℕ} (A : Fin k → Finset (Fin n)) :
    (Fintype.piFinset A).card = ∏ i, (A i).card :=
  Fintype.card_piFinset A

/-- If every round accepts at most `e` challenges, the number of surviving
`k`-round challenge vectors is at most `e ^ k`. -/
theorem roundAccept_card_le {k n e : ℕ} (A : Fin k → Finset (Fin n))
    (h : ∀ i, (A i).card ≤ e) :
    (Fintype.piFinset A).card ≤ e ^ k := by
  rw [piFinset_card_eq_prod]
  calc ∏ i, (A i).card ≤ ∏ _i : Fin k, e := Finset.prod_le_prod' (fun i _ => h i)
    _ = e ^ k := by simp

/-- **Main theorem (soundness amplification).** If in each of `k` independent
rounds a cheating prover survives at most an `e/n` fraction of the `n` possible
challenges, then the uniform probability that it survives *all* `k` rounds is at
most `(e / n) ^ k`. -/
theorem amplified_prob_le {k n e : ℕ} (A : Fin k → Finset (Fin n))
    (h : ∀ i, (A i).card ≤ e) :
    ((Fintype.piFinset A).card : ℚ) / (n : ℚ) ^ k ≤ ((e : ℚ) / n) ^ k := by
  have hc : (Fintype.piFinset A).card ≤ e ^ k := roundAccept_card_le A h
  rw [div_pow]
  gcongr
  exact_mod_cast hc

/-- **Soundness error `2^{-k}`.** If each round catches a cheating prover with
probability at least `1/2` (i.e. it survives at most `e` of `n` challenges with
`2 * e ≤ n`), then the `k`-round survival probability is at most `2 ^ (-k)`,
matching the mission's target. -/
theorem amplified_two_pow {k n e : ℕ} (hn : 0 < n) (he : 2 * e ≤ n)
    (A : Fin k → Finset (Fin n)) (h : ∀ i, (A i).card ≤ e) :
    ((Fintype.piFinset A).card : ℚ) / (n : ℚ) ^ k ≤ (1 / 2) ^ k := by
  refine (amplified_prob_le A h).trans ?_
  have hnq : (0 : ℚ) < n := by exact_mod_cast hn
  have hbase : (e : ℚ) / n ≤ 1 / 2 := by
    rw [div_le_div_iff₀ hnq (by norm_num)]
    have : (2 : ℚ) * e ≤ n := by exact_mod_cast he
    linarith
  gcongr

/-- **Real product bound.** If in each round the prover survives with probability
`p i` and every round is caught with probability at least `1 - q` (so `p i ≤ q`),
then the joint survival probability `∏ p i` is at most `q ^ k`. This is the
composition tool used to import per-round soundness bounds from other protocols
(e.g. graph 3-colouring) into the `k`-round setting. -/
theorem prod_prob_le_pow {k : ℕ} (p : Fin k → ℚ) (q : ℚ)
    (h0 : ∀ i, 0 ≤ p i) (h : ∀ i, p i ≤ q) :
    ∏ i, p i ≤ q ^ k := by
  calc ∏ i, p i ≤ ∏ _i : Fin k, q :=
        Finset.prod_le_prod (fun i _ => h0 i) (fun i _ => h i)
    _ = q ^ k := by simp

end ZK.Amplification