/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Computational evidence for the price of universality

Exact small-case computations supporting the bounds of
`UniversalRedundancy.Bernoulli`.  `shtarkovBernoulliQ n` is the classical
normalized-maximum-likelihood normalizer of the binary memoryless class,

`∑_{k=0}^{n} C(n,k) (k/n)^k ((n-k)/n)^{n-k}`,

computed here in exact rational arithmetic.  The theorems below are *verified*
computations (no floating point, no `native_decide`): for `n = 2, 4, 8` they
pin down the exact value and confirm both sides of the proved sandwich
`√n / 4 ≤ Cₛ ≤ n + 1` — the lower bound in the equivalent rational form
`Cₛ² ≥ n/16`.

## Application Keywords

Shtarkov sum, NML normalizer, exact rational computation, small-case evidence
-/

import Mathlib

open Finset

namespace UniversalRedundancy

/-- Exact rational value of the Shtarkov (NML) normalizer of the binary
memoryless class for messages of length `n`. -/
def shtarkovBernoulliQ (n : ℕ) : ℚ :=
  ∑ k ∈ range (n + 1),
    (n.choose k : ℚ) * ((k : ℚ) / (n : ℚ)) ^ k * (((n - k : ℕ) : ℚ) / (n : ℚ)) ^ (n - k)

theorem shtarkovBernoulliQ_two : shtarkovBernoulliQ 2 = 5 / 2 := by
  simp [shtarkovBernoulliQ, Finset.sum_range_succ, Nat.choose]
  norm_num

theorem shtarkovBernoulliQ_four : shtarkovBernoulliQ 4 = 103 / 32 := by
  simp [shtarkovBernoulliQ, Finset.sum_range_succ, Nat.choose]
  norm_num

theorem shtarkovBernoulliQ_eight : shtarkovBernoulliQ 8 = 556403 / 131072 := by
  simp [shtarkovBernoulliQ, Finset.sum_range_succ, Nat.choose]
  norm_num

/-- The proved sandwich `√n/4 ≤ Cₛ ≤ n+1`, checked exactly at `n = 2, 4, 8`
(the lower bound in its equivalent rational form `Cₛ² ≥ n/16`). -/
theorem shtarkovBernoulliQ_sandwich_checks :
    ((shtarkovBernoulliQ 2) ^ 2 ≥ 2 / 16 ∧ shtarkovBernoulliQ 2 ≤ 3) ∧
    ((shtarkovBernoulliQ 4) ^ 2 ≥ 4 / 16 ∧ shtarkovBernoulliQ 4 ≤ 5) ∧
    ((shtarkovBernoulliQ 8) ^ 2 ≥ 8 / 16 ∧ shtarkovBernoulliQ 8 ≤ 9) := by
  rw [shtarkovBernoulliQ_two, shtarkovBernoulliQ_four, shtarkovBernoulliQ_eight]
  norm_num

/-- The normalizer grows: the price of universality is strictly increasing in
the message length over the computed range, consistent with the `½ log₂ n`
lower bound (and inconsistent with any bounded-price conjecture). -/
theorem shtarkovBernoulliQ_strict_growth :
    shtarkovBernoulliQ 2 < shtarkovBernoulliQ 4 ∧
      shtarkovBernoulliQ 4 < shtarkovBernoulliQ 8 := by
  rw [shtarkovBernoulliQ_two, shtarkovBernoulliQ_four, shtarkovBernoulliQ_eight]
  norm_num

end UniversalRedundancy