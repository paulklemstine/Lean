/-
# The Price of Universality X: the verdict

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A, Question 1.

This file records the two theorems that answer the research question, in the
sharpest form the development supports.

1. **Universality is asymptotically free per symbol, for any finite-state
   class.**  `fsm_price_rate_tendsto_zero`: the minimax redundancy of the
   finite-state class over messages of length `n`, divided by `n`, tends to `0`.
   The automaton may be arbitrarily large; only the constant changes.  So
   specialising the decompressor to a *parametric* class of sources cannot move
   more than `o(n)` bits out of a length-`n` message.

2. **Universality is expensive when parameters are not shared.**
   `Logic.PriceOfUniversality.Tensor.sharing_gap_linear`: for `k` independently
   parameterised blocks the price grows linearly in `k`, so a specialised
   decompressor really can absorb `Θ(k)` bits.

Together: *specialisation is worth pursuing exactly to the extent that the data
class has many independent parameters relative to its length* — the bits move
from message to decompressor at the rate of the parameter count, not the message
length.

## Main results

* `fsm_price_rate_tendsto_zero` — vanishing per-symbol price for finite-state
  classes
* `fsm_price_nonneg` — the price is never negative (universality never helps)

## Application keywords

universal coding, minimax redundancy, finite-state sources, asymptotic rate
-/

import Logic.PriceOfUniversality.FiniteState
import MachineLearning.UniversalRedundancy.Types

open Finset Real

namespace UniversalRedundancy

variable {A S : Type*} [Fintype A] [DecidableEq A] [Fintype S] [DecidableEq S]

omit [DecidableEq A] [Fintype S] [DecidableEq S] in
/-- The price of universality of a finite-state class is never negative: a
shared decompressor is never *better* than the best specialised one. -/
theorem fsm_price_nonneg [Nonempty A] (δ : S → A → S) (s₀ : S) (n : ℕ) :
    0 ≤ logb 2 (fsmClass δ s₀ n).shtarkovSum :=
  Real.logb_nonneg (by norm_num) (fsmClass δ s₀ n).one_le_shtarkovSum

/-- **The per-symbol price of universality vanishes for every finite-state
class.**  Whatever the automaton, the minimax redundancy is `O(log n)` while the
message is `n` symbols long, so a decompressor specialised to the class saves an
asymptotically vanishing fraction of the message. -/
theorem fsm_price_rate_tendsto_zero [Nonempty A] (δ : S → A → S) (s₀ : S) :
    Filter.Tendsto
      (fun n : ℕ => logb 2 (fsmClass δ s₀ n).shtarkovSum / (n : ℝ))
      Filter.atTop (nhds 0) := by
  set c : ℝ := (Fintype.card S : ℝ) * (Fintype.card A : ℝ) with hc
  have hcnn : 0 ≤ c := by positivity
  refine squeeze_zero (fun n => ?_) (fun n => ?_)
    (redundancy_rate_tendsto_zero c)
  · exact div_nonneg (fsm_price_nonneg δ s₀ n) (by positivity)
  · rcases Nat.eq_zero_or_pos n with rfl | hn
    · simp
    · have hnR : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
      have hbound := fsm_price_le_bits δ s₀ n
      rw [div_le_div_iff_of_pos_right hnR]
      rw [hc]
      linarith

end UniversalRedundancy