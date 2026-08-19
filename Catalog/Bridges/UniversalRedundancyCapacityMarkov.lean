/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality X: average-case rates for subfamilies, and Markov sources

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A, Question 1.

The capacity theory needs a *finite* parameter set, while the catalog's natural
classes (memoryless, Markov) are indexed by continua of parameters.  The bridge
is the **subfamily**: pick any finite set of parameters out of an infinite class.
Its Shtarkov sum can only be smaller (`shtarkovSum_subfamily_le`), so every
worst-case bound already proved in the catalog for the infinite class becomes an
*average-case* bound for all of its finite subfamilies at once
(`capacity_subfamily_le_logb_shtarkovSum`).

Applied to the catalog's Markov bound `Cₛ ≤ #A · (n+1)^{#A²}` this gives the
average-case Rissanen rate for sources **with memory**:

  `C ≤ log₂ #A + #A² · log₂ (n+1)`  (`capacity_markovSubfamily_le`),

logarithmic in the message length with the class complexity `#A²` — the number
of free parameters — as the multiplier.  This is exactly the shape the research
plan asks for: redundancy as a function of message length and class complexity.

## Main results

* `subfamily` — a finite subfamily of an arbitrary source class
* `shtarkovSum_subfamily_le` — restricting parameters cannot raise the Shtarkov sum
* `capacity_subfamily_le_logb_shtarkovSum` — worst-case bounds for the big class
  become average-case bounds for every finite subfamily
* `capacity_markovSubfamily_le` — `C ≤ log₂ #A + #A² log₂ (n+1)` for Markov sources

## Application keywords

universal compression, minimax redundancy, capacity, Markov sources, transition
counts, Rissanen rate, class complexity
-/

import Bridges.UniversalRedundancyCapacitySufficiency
import MachineLearning.UniversalRedundancy.Markov

open Finset Real

namespace UniversalRedundancy

namespace SourceClass

variable {X : Type*} [Fintype X] {Ψ : Type*} {Θ : Type*} [Fintype Θ]

/-- A **finite subfamily** of a source class: keep only the parameters in the
image of `q`. -/
noncomputable def subfamily (S : SourceClass X Ψ) (q : Θ → Ψ) : SourceClass X Θ where
  prob θ := S.prob (q θ)
  nonneg θ := S.nonneg (q θ)
  sum_one θ := S.sum_one (q θ)

omit [Fintype Θ] in
lemma subfamily_prob (S : SourceClass X Ψ) (q : Θ → Ψ) (θ : Θ) :
    (S.subfamily q).prob θ = S.prob (q θ) := rfl

omit [Fintype Θ] in
/-- Restricting to a subfamily cannot raise the Shtarkov sum. -/
theorem shtarkovSum_subfamily_le [Nonempty Θ] (S : SourceClass X Ψ) (q : Θ → Ψ) :
    (S.subfamily q).shtarkovSum ≤ S.shtarkovSum :=
  Finset.sum_le_sum fun x _ =>
    (S.subfamily q).maxLik_le (fun θ => S.le_maxLik (q θ) x)

/-- **Worst-case bounds transfer to the average case.**  Every finite subfamily
of a class has average-case price of universality at most the worst-case price
`log₂ Cₛ` of the whole class. -/
theorem capacity_subfamily_le_logb_shtarkovSum [Nonempty Θ] (S : SourceClass X Ψ)
    (q : Θ → Ψ) (hpos : ∀ θ x, 0 < (S.subfamily q).prob θ x) :
    (S.subfamily q).capacity ≤ logb 2 S.shtarkovSum :=
  le_trans ((S.subfamily q).capacity_le_logb_shtarkovSum hpos)
    (Real.logb_le_logb_of_le (by norm_num) (S.subfamily q).shtarkovSum_pos
      (S.shtarkovSum_subfamily_le q))

end SourceClass

/-! ## Markov sources -/

variable {A : Type*} [Fintype A] [DecidableEq A]

/-- **The average-case Rissanen rate for Markov sources.**  For every finite
family of first-order Markov chains on `n+1` symbols the average-case price of
universality is at most `log₂ #A + #A² · log₂ (n+1)` bits: logarithmic in the
message length, with the number `#A²` of free parameters as the multiplier. -/
theorem capacity_markovSubfamily_le [Nonempty A] {Θ : Type*} [Fintype Θ] [Nonempty Θ]
    (n : ℕ) (q : Θ → MarkovParam A)
    (hpos : ∀ θ x, 0 < (markovClass A n).prob (q θ) x) :
    ((markovClass A n).subfamily q).capacity
      ≤ logb 2 (Fintype.card A)
        + (Fintype.card A * Fintype.card A : ℕ) * logb 2 ((n : ℝ) + 1) := by
  have hcardpos : (0 : ℝ) < (Fintype.card A : ℝ) := by
    have : 0 < Fintype.card A := Fintype.card_pos
    exact_mod_cast this
  have hn1 : (0 : ℝ) < (n : ℝ) + 1 := by positivity
  have hbound := shtarkovSum_markovClass_le (A := A) n
  have hcast : (((n + 1 : ℕ) : ℝ)) = (n : ℝ) + 1 := by push_cast; ring
  rw [hcast] at hbound
  have hle := SourceClass.capacity_subfamily_le_logb_shtarkovSum (markovClass A n) q hpos
  refine le_trans hle ?_
  have hstep : logb 2 ((markovClass A n).shtarkovSum)
      ≤ logb 2 ((Fintype.card A : ℝ) * ((n : ℝ) + 1) ^ (Fintype.card A * Fintype.card A)) :=
    Real.logb_le_logb_of_le (by norm_num) (markovClass A n).shtarkovSum_pos hbound
  refine le_trans hstep (le_of_eq ?_)
  rw [Real.logb_mul (ne_of_gt hcardpos) (by positivity), Real.logb_pow]

end UniversalRedundancy