import Mathlib
import Shared.GraphTheory.FractalTruthMetric
import MachineLearning.CantorCompactness
import MachineLearning.SubshiftLanguage
import MachineLearning.GoldenMeanEntropy

/-!
# An optimal online mistake bound for predicting the golden-mean subshift

Seventh cycle of the research thread.  The previous cycles established the *static* and
*dynamical* structure of the golden-mean subshift `GoldenMean ⊆ Cantor`: compactness,
Devaney chaos, Fibonacci covering numbers, entropy `log φ`, and the sharp density bound
`2 · #{trues} ≤ n + 1` on admissible words.

Here we turn that combinatorics into a **learning-theoretic minimax theorem** for online
sequence prediction, which is the machine-learning face of the same constraint "no `11`".

A *predictor* is a deterministic map `List Bool → Bool` sending the observed history to a
prediction of the next answer.  Running it against a stream `x` produces a mistake count
`mistakeCount p x n` over the first `n` rounds.  We prove:

* **Upper bound** (`mistakeCount_alwaysFalse_le`): the trivial predictor "always answer `false`"
  makes at most `(n + 1) / 2` mistakes against *every* golden-mean stream.  Its mistake count
  is exactly the number of `true`s in the window, which the density bound controls.
* **Lower bound** (`exists_adversary_stream`): for *every* predictor, however clever, there is
  a golden-mean stream forcing at least `n / 2` mistakes in `n` rounds.  The adversary is
  explicit: contradict the prediction whenever the subshift constraint leaves a choice, which
  it does at least every other round.

Together (`goldenMean_minimax_mistake_bound`) these pin the minimax mistake rate of the
golden-mean subshift at `1/2` per round, and show that no learner can exploit the structure
beyond the trivial predictor.  Note the contrast with the entropy `log φ / log 2 ≈ 0.694`
bits per symbol: the constraint lowers the minimax rate from `1` (the unconstrained shift,
where the adversary is never forced) to `1/2`, and `1/2` is *not* the entropy ratio.  The
reason is that the adversary regains a free choice immediately after every forced move, so
the rate is governed by the length of the forced runs and not by how many words the language
contains.

## Main results

* `mistakeCount_succ` — the mistake count is an incremental counter.
* `mistakeCount_alwaysFalse` — the trivial predictor's mistakes are the `true`s in the window.
* `mistakeCount_alwaysFalse_le` — upper bound `2 · mistakes ≤ n + 1`.
* `adv_mem_goldenMean`, `mistake_of_free`, `mistake_succ_of_not_mistake` — the adversary
  construction and its two key properties.
* `exists_adversary_stream` — lower bound `n ≤ 2 · mistakes` for every predictor.
* `goldenMean_minimax_mistake_bound` — the two bounds combined.
-/

namespace FractalTruthCompactness

open FractalTruthMetric

/-! ## Predictors and mistake counts -/

/-- A deterministic online predictor: it maps the history observed so far to a prediction of
the next answer. -/
abbrev Predictor := List Bool → Bool

/-- The number of mistakes a predictor makes on the first `n` answers of a stream. -/
def mistakeCount (p : Predictor) (x : Cantor) (n : ℕ) : ℕ :=
  ((List.range n).filter (fun k => p (prefixOf k x) != x k)).length

@[simp] theorem mistakeCount_zero (p : Predictor) (x : Cantor) : mistakeCount p x 0 = 0 := rfl

/-- The mistake count is an incremental counter over the rounds. -/
theorem mistakeCount_succ (p : Predictor) (x : Cantor) (n : ℕ) :
    mistakeCount p x (n + 1) =
      mistakeCount p x n + (if p (prefixOf n x) != x n then 1 else 0) := by
  unfold mistakeCount
  rw [List.range_succ, List.filter_append]
  by_cases h : p (prefixOf n x) != x n <;> simp [h]

/-- A mistake at round `n` increments the counter. -/
theorem mistakeCount_succ_of_mistake {p : Predictor} {x : Cantor} {n : ℕ}
    (h : p (prefixOf n x) ≠ x n) :
    mistakeCount p x (n + 1) = mistakeCount p x n + 1 := by
  rw [mistakeCount_succ, if_pos (by simpa using h)]

/-- The counter never decreases. -/
theorem mistakeCount_le_succ (p : Predictor) (x : Cantor) (n : ℕ) :
    mistakeCount p x n ≤ mistakeCount p x (n + 1) := by
  rw [mistakeCount_succ]; omega

/-! ## The upper bound: the trivial predictor -/

/-- The predictor that always answers `false`. -/
def alwaysFalse : Predictor := fun _ => false

/-- On any stream, the trivial predictor's mistakes are exactly the `true` answers. -/
theorem mistakeCount_alwaysFalse : ∀ (x : Cantor) (n : ℕ),
    mistakeCount alwaysFalse x n = (prefixOf n x).count true
  | _, 0 => rfl
  | x, (n + 1) => by
      rw [mistakeCount_succ, mistakeCount_alwaysFalse x n, prefixOf_succ_eq_append,
        List.count_append]
      cases hx : x n <;> simp [alwaysFalse]

/-- **Upper bound.**  Against every golden-mean stream the trivial predictor makes at most
`(n + 1) / 2` mistakes in `n` rounds. -/
theorem mistakeCount_alwaysFalse_le {x : Cantor} (hx : x ∈ GoldenMean) (n : ℕ) :
    2 * mistakeCount alwaysFalse x n ≤ n + 1 := by
  rw [mistakeCount_alwaysFalse]
  exact goldenMean_prefix_count_true hx n

/-! ## The adversary -/

/-- The adversary's move given a history: play `false` if the constraint forces it (the last
answer was `true`), otherwise contradict the prediction. -/
def advMove (p : Predictor) (h : List Bool) : Bool :=
  if h.getLast? = some true then false else !(p h)

/-- The adversary's history after `k` rounds, built round by round. -/
def advHist (p : Predictor) : ℕ → List Bool
  | 0 => []
  | (k + 1) => advHist p k ++ [advMove p (advHist p k)]

/-- The adversary's stream. -/
def adv (p : Predictor) : Cantor := fun k => advMove p (advHist p k)

theorem advHist_succ (p : Predictor) (k : ℕ) :
    advHist p (k + 1) = advHist p k ++ [adv p k] := rfl

/-- The adversary's history is literally the prefix of the adversary's stream. -/
theorem prefixOf_adv : ∀ (p : Predictor) (k : ℕ), prefixOf k (adv p) = advHist p k
  | _, 0 => rfl
  | p, (k + 1) => by
      rw [prefixOf_succ_eq_append, prefixOf_adv p k, advHist_succ]

/-- The last letter of the adversary's history is its previous move. -/
theorem getLast?_advHist_succ (p : Predictor) (k : ℕ) :
    (advHist p (k + 1)).getLast? = some (adv p k) := by
  rw [advHist_succ]
  simp

/-- **The adversary stays inside the subshift**: after playing `true` it is forced to play
`false`. -/
theorem adv_mem_goldenMean (p : Predictor) : adv p ∈ GoldenMean := by
  intro k hk
  obtain ⟨h1, h2⟩ := hk
  have hlast : (advHist p (k + 1)).getLast? = some true := by
    rw [getLast?_advHist_succ, h1]
  have hfalse : adv p (k + 1) = false := by
    show advMove p (advHist p (k + 1)) = false
    rw [advMove, if_pos hlast]
  rw [hfalse] at h2
  exact Bool.false_ne_true h2

/-- At a **free** round — one where the constraint does not force the answer — the adversary
contradicts the prediction, so the predictor errs. -/
theorem mistake_of_free {p : Predictor} {k : ℕ} (hk : (advHist p k).getLast? ≠ some true) :
    p (prefixOf k (adv p)) ≠ adv p k := by
  rw [prefixOf_adv]
  show p (advHist p k) ≠ advMove p (advHist p k)
  rw [advMove, if_neg hk]
  cases h : p (advHist p k) <;> simp

/-- Round `0` is free, hence always a mistake. -/
theorem mistake_zero (p : Predictor) : p (prefixOf 0 (adv p)) ≠ adv p 0 :=
  mistake_of_free (by simp [advHist])

/-- **No two consecutive correct rounds.**  If the predictor is right at round `k`, then round
`k` must have been a forced round, so the adversary played `false`; that frees round `k + 1`,
where the predictor is therefore wrong. -/
theorem mistake_succ_of_not_mistake {p : Predictor} {k : ℕ}
    (h : ¬ p (prefixOf k (adv p)) ≠ adv p k) :
    p (prefixOf (k + 1) (adv p)) ≠ adv p (k + 1) := by
  by_cases hfree : (advHist p k).getLast? = some true
  · -- round `k` was forced, so the adversary played `false`
    have hzero : adv p k = false := by
      show advMove p (advHist p k) = false
      rw [advMove, if_pos hfree]
    refine mistake_of_free ?_
    rw [getLast?_advHist_succ, hzero]
    simp
  · exact absurd (mistake_of_free hfree) h

/-- **Lower bound.**  Against *any* deterministic predictor there is a golden-mean stream on
which it errs in at least half of the first `n` rounds. -/
theorem exists_adversary_stream (p : Predictor) (n : ℕ) :
    ∃ x ∈ GoldenMean, n ≤ 2 * mistakeCount p x n := by
  refine ⟨adv p, adv_mem_goldenMean p, ?_⟩
  induction n using Nat.strong_induction_on with
  | _ n ih =>
      match n with
      | 0 => omega
      | 1 =>
          have h : mistakeCount p (adv p) 1 = mistakeCount p (adv p) 0 + 1 :=
            mistakeCount_succ_of_mistake (mistake_zero p)
          rw [h]
          omega
      | (m + 2) =>
          have hm := ih m (by omega)
          have hstep : mistakeCount p (adv p) m + 1 ≤ mistakeCount p (adv p) (m + 2) := by
            by_cases h : p (prefixOf m (adv p)) ≠ adv p m
            · have h1 : mistakeCount p (adv p) (m + 1) = mistakeCount p (adv p) m + 1 :=
                mistakeCount_succ_of_mistake h
              have h2 : mistakeCount p (adv p) (m + 1) ≤ mistakeCount p (adv p) (m + 2) :=
                mistakeCount_le_succ p (adv p) (m + 1)
              omega
            · have h1 := mistake_succ_of_not_mistake h
              have h2 : mistakeCount p (adv p) (m + 2) = mistakeCount p (adv p) (m + 1) + 1 :=
                mistakeCount_succ_of_mistake h1
              have h3 : mistakeCount p (adv p) m ≤ mistakeCount p (adv p) (m + 1) :=
                mistakeCount_le_succ p (adv p) m
              omega
          omega

/-- **Minimax mistake bound for the golden-mean subshift.**  The trivial predictor already
achieves the mistake rate `1/2`, and no predictor can beat it: the minimax number of mistakes
in `n` rounds is `n/2` up to one round.  So the two complexity measures of the constraint do
not agree: forbidding `11` cuts the *counting* complexity by the factor
`log φ / log 2 ≈ 0.694` (`goldenMean_entropy_lt_log_two`) but cuts the *online-prediction*
complexity by the factor `1/2`. -/
theorem goldenMean_minimax_mistake_bound (n : ℕ) :
    (∀ x ∈ GoldenMean, 2 * mistakeCount alwaysFalse x n ≤ n + 1) ∧
    (∀ p : Predictor, ∃ x ∈ GoldenMean, n ≤ 2 * mistakeCount p x n) :=
  ⟨fun _ hx => mistakeCount_alwaysFalse_le hx n, fun p => exists_adversary_stream p n⟩

end FractalTruthCompactness