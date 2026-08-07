/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Non-vacuity witnesses for the structural theorems

The structural results of `Novelty.MaxPlusRateStructure` (uniqueness of the optimal
mixture at an exposed velocity, unimodality of the rate, affine equivariance) are only
worth as much as their non-vacuity.  This file instantiates each of them on the
idempotent Bernoulli law of `Novelty.MaxPlusBernoulliExample`, where the rate is known in
closed form (`bern_rate : rate x = 1 - x` on `[0,1]`), so every conclusion can be checked
against an explicit computation.
-/

import Novelty.MaxPlusRateStructure
import Novelty.MaxPlusBernoulliExample

open scoped BigOperators
open Finset

namespace IdempotentProbability

/-- The zero tilt exposes the Bernoulli velocity `1`, with a *unique* maximizer. -/
theorem bern_exposed_one (b : Bool) (hb : b ≠ true) :
    bern.weight b + (0 : ℝ) * bern.value b
      < bern.weight true + (0 : ℝ) * bern.value true := by
  cases b
  · norm_num
  · exact absurd rfl hb

/-- **Uniqueness of the optimal mixture, concretely.**  At the exposed Bernoulli velocity
`1` the only mixture achieving the optimal score `-rate 1 = 0` is the Dirac mass at the
increment `true`. -/
theorem bern_unique_optimal_mixture {lam : Bool → ℝ}
    (hmix : bern.IsMixture 1 lam)
    (hopt : ∑ b, lam b * bern.weight b = -bern.rate 1) :
    ∀ b, lam b = if b = true then 1 else 0 :=
  bern.unique_optimal_mixture_of_exposed (θ := 0) (i := true) bern_exposed_one hmix hopt

/-- The Bernoulli rate is nonincreasing on its whole effective domain `[0,1]`: the
unimodality theorem degenerates here to monotonicity, matching `rate x = 1 - x`. -/
theorem bern_rate_antitoneOn : AntitoneOn bern.rate (Set.Icc (0 : ℝ) 1) := by
  have h := bern.rate_antitoneOn_left (i₀ := true) bern_weight_true
  rwa [bern_vmin, bern_value_true] at h

/-- **Affine equivariance, concretely.**  Rescaling the Bernoulli increments by `2` and
shifting by `3` transports the rate along the same map: the pushed law has rate `1 - x`
at the pushed velocity `2x + 3`. -/
theorem bern_affinePush_rate {x : ℝ} (hx : x ∈ Set.Icc (0 : ℝ) 1) :
    (bern.affinePush 2 3).rate (2 * x + 3) = 1 - x := by
  rw [bern.rate_affinePush (by norm_num) 3 x, bern_rate hx]

/-- The pushed Bernoulli law has effective domain `[3, 5]`, and the contraction principle
identifies its rate there with the original rate at the preimage velocity. -/
theorem bern_affinePush_contraction (z : ℝ) :
    IsLeast {r : ℝ | ∃ y : ℝ, 2 * y + 3 = z ∧ r = bern.rate y}
      ((bern.affinePush 2 3).rate z) :=
  bern.isLeast_contraction_affine (by norm_num) 3 z

/-- A sanity check on the contraction principle: at `z = 4` the fibre is `{1/2}` and the
pushed rate equals the original Bernoulli rate `1/2`. -/
theorem bern_affinePush_rate_at_four : (bern.affinePush 2 3).rate 4 = 1 / 2 := by
  have h : (2 : ℝ) * (1 / 2) + 3 = 4 := by norm_num
  have := bern_affinePush_rate (x := 1 / 2) (by norm_num)
  rw [h] at this
  rw [this]; norm_num

end IdempotentProbability