/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# From KL control to *event-wise* control: the sharp Pinsker bridge

Two catalog threads meet here.

* `MachineLearning.PACBayes.KLProperties` proves **Pinsker's inequality**
  `d_TV(Q, P)² ≤ KL(Q ‖ P)/2` for the factor-`1/2` total variation distance.
* `MachineLearning.TotalVariation.EventSup` proves that this same `d_TV` is the
  *attained supremum* of the distinguishing gap `Q(A) − P(A)` over events.

Composing them turns a divergence bound — an opaque analytic quantity — into a
statement a learner can actually use: **no event, no Boolean test, and no
randomized test separates two hypotheses by more than `√(KL/2)`**, and
conversely a single well-separating event *certifies* a KL lower bound
`KL ≥ 2·gap²`.

The factor `1/2` is what makes the bridge non-vacuous.  Under the `ℓ¹`
normalization Pinsker would read `‖Q − P‖₁² ≤ 2·KL`, and the resulting event
bound `√(2 KL)` is worse by a factor `2` — enough to make the derived Bayes-error
bound `(1 − √(2KL))/2` vacuous exactly in the interesting regime
`KL ∈ [1/8, 1/2]`.

## Main results

* `tvDist_eq_pacbayes` — the two catalog definitions of `d_TV` agree;
* `tvDist_le_sqrt_half_kl` — Pinsker in distance form;
* `eventGap_le_sqrt_half_kl`, `abs_boolAdvantage_le_sqrt_half_kl` — event and
  Boolean-test form;
* `kl_ge_two_mul_sq_eventGap` — the converse certificate: a distinguishing event
  forces KL to be large;
* `bayesError_ge_of_kl` — KL-driven Le Cam bound on the optimal test error;
* `bayesError_powLaw_ge_of_kl` — the `n`-sample version via the hybrid argument;
* `exists_coupling_disagree_le_sqrt_half_kl` — KL control yields a *coupling*
  that agrees with probability `1 − √(KL/2)`.

## Application keywords

Pinsker inequality, KL divergence, distinguishing advantage, PAC-Bayes,
hypothesis testing, sample complexity, coupling
-/

import MachineLearning.TotalVariation.Coupling
import MachineLearning.TotalVariation.Testing
import MachineLearning.PACBayes.KLProperties

open Finset

namespace UniversalRedundancy

open PACBayes

variable {α : Type*} [Fintype α]

/-- The total variation distance of `UniversalRedundancy` and the one of
`PACBayes` are the same function: both carry the sharp `1/2` normalization. -/
lemma tvDist_eq_pacbayes (Q P : FinDist α) :
    tvDist Q.prob P.prob = PACBayes.tvDist Q P := rfl

/-- **Pinsker in distance form.** -/
theorem tvDist_le_sqrt_half_kl (Q P : FinDist α)
    (hac : ∀ a, P.prob a = 0 → Q.prob a = 0) :
    tvDist Q.prob P.prob ≤ Real.sqrt (klFinDist Q P / 2) := by
  have hpin := pinsker_inequality Q P hac
  rw [tvDist_eq_pacbayes]
  have hnn : 0 ≤ PACBayes.tvDist Q P := by
    have := tvDist_nonneg Q.prob P.prob
    rwa [tvDist_eq_pacbayes] at this
  have hkl : 0 ≤ klFinDist Q P / 2 := by
    have := klFinDist_nonneg Q P hac
    linarith
  exact (Real.le_sqrt hnn hkl).mpr hpin

/-- **Event form of Pinsker.**  KL control is control of *every* event
simultaneously — with the sharp constant `√(KL/2)`. -/
theorem eventGap_le_sqrt_half_kl (Q P : FinDist α)
    (hac : ∀ a, P.prob a = 0 → Q.prob a = 0) (A : Finset α) :
    |eventGap Q.prob P.prob A| ≤ Real.sqrt (klFinDist Q P / 2) :=
  le_trans (abs_eventGap_le_tvDist Q.prob_sum_one P.prob_sum_one A)
    (tvDist_le_sqrt_half_kl Q P hac)

/-- Boolean-distinguisher form: every test has advantage at most `√(KL/2)`. -/
theorem abs_boolAdvantage_le_sqrt_half_kl (Q P : FinDist α)
    (hac : ∀ a, P.prob a = 0 → Q.prob a = 0) (f : α → Bool) :
    |boolAdvantage Q.prob P.prob f| ≤ Real.sqrt (klFinDist Q P / 2) := by
  classical
  rw [boolAdvantage]
  exact eventGap_le_sqrt_half_kl Q P hac _

/-- Randomized-test form. -/
theorem abs_softAdvantage_le_sqrt_half_kl (Q P : FinDist α)
    (hac : ∀ a, P.prob a = 0 → Q.prob a = 0) {g : α → ℝ}
    (hg0 : ∀ a, 0 ≤ g a) (hg1 : ∀ a, g a ≤ 1) :
    |∑ a, (Q.prob a - P.prob a) * g a| ≤ Real.sqrt (klFinDist Q P / 2) :=
  le_trans (abs_softAdvantage_le_tvDist Q.prob_sum_one P.prob_sum_one hg0 hg1)
    (tvDist_le_sqrt_half_kl Q P hac)

/-- **Converse certificate.**  A single event that separates the two hypotheses
by `ε` proves `KL ≥ 2ε²`.  Distinguishability is therefore a *witnessable*
lower bound on divergence, not merely an upper bound consequence. -/
theorem kl_ge_two_mul_sq_eventGap (Q P : FinDist α)
    (hac : ∀ a, P.prob a = 0 → Q.prob a = 0) (A : Finset α) :
    2 * eventGap Q.prob P.prob A ^ 2 ≤ klFinDist Q P := by
  have hpin := pinsker_inequality Q P hac
  rw [← tvDist_eq_pacbayes] at hpin
  have habs := abs_eventGap_le_tvDist Q.prob_sum_one P.prob_sum_one A
  have hsq : eventGap Q.prob P.prob A ^ 2 ≤ tvDist Q.prob P.prob ^ 2 := by
    have h0 : (0:ℝ) ≤ |eventGap Q.prob P.prob A| := abs_nonneg _
    nlinarith [sq_abs (eventGap Q.prob P.prob A), tvDist_nonneg Q.prob P.prob]
  linarith

/-- **KL-driven Le Cam bound.**  If two hypotheses are close in KL then *every*
test confuses them: the optimal average error is at least
`(1 − √(KL/2))/2`.  In particular `KL < 1/2` already forces a positive error
floor. -/
theorem bayesError_ge_of_kl (Q P : FinDist α)
    (hac : ∀ a, P.prob a = 0 → Q.prob a = 0) (f : α → Bool) :
    (1 - Real.sqrt (klFinDist Q P / 2)) / 2 ≤ bayesError Q.prob P.prob f := by
  have h1 := bayesError_ge_half_one_sub_tvDist Q.prob_sum_one P.prob_sum_one f
  have h2 := tvDist_le_sqrt_half_kl Q P hac
  linarith

/-- **`n`-sample KL bound (hybrid argument).**  After `n` i.i.d. draws the Bayes
error of any test is still at least `(1 − n·√(KL/2))/2`. -/
theorem bayesError_powLaw_ge_of_kl (Q P : FinDist α)
    (hac : ∀ a, P.prob a = 0 → Q.prob a = 0) (n : ℕ) (f : (Fin n → α) → Bool) :
    (1 - n * Real.sqrt (klFinDist Q P / 2)) / 2
      ≤ bayesError (powLaw Q.prob n) (powLaw P.prob n) f := by
  have h1 := bayesError_powLaw_ge Q.prob_nonneg Q.prob_sum_one P.prob_nonneg
    P.prob_sum_one n f
  have h2 := tvDist_le_sqrt_half_kl Q P hac
  have h3 : (n : ℝ) * tvDist Q.prob P.prob ≤ n * Real.sqrt (klFinDist Q P / 2) :=
    mul_le_mul_of_nonneg_left h2 (Nat.cast_nonneg n)
  linarith

/-- **Coupling form.**  Small KL divergence produces an explicit coupling of the
two hypotheses that agrees with probability at least `1 − √(KL/2)`; this is the
transport-theoretic reading of PAC-Bayes-style divergence control. -/
theorem exists_coupling_disagree_le_sqrt_half_kl [DecidableEq α] (Q P : FinDist α)
    (hac : ∀ a, P.prob a = 0 → Q.prob a = 0) :
    ∃ c : α → α → ℝ, IsCoupling Q.prob P.prob c ∧
      disagreeProb c ≤ Real.sqrt (klFinDist Q P / 2) := by
  refine ⟨maxCoupling Q.prob P.prob,
    isCoupling_maxCoupling Q.prob_sum_one P.prob_sum_one Q.prob_nonneg P.prob_nonneg, ?_⟩
  rw [disagreeProb_maxCoupling Q.prob_sum_one P.prob_sum_one Q.prob_nonneg P.prob_nonneg]
  exact tvDist_le_sqrt_half_kl Q P hac

end UniversalRedundancy