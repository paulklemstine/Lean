/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The star functional `f(d) = d²(1 − d)` and the realizability gap for `S_{2,1}`

The asymptotic semi-induced `S_{2,1}` density of a graph is the average over vertices of the
*star functional* `f(d) = d² (1 − d)`, where `d` is a vertex's local neighbour-density, while
the edge density is the average of `d`.  This file proves the shape of `f` and exposes the
*realizability gap* that makes the extremal problem nontrivial.

Two facts together explain why the true minimum profile is hard:

* `starFunctional_nonneg` / `starFunctional_le` : `f` is a bump, `0 ≤ f(d) ≤ 4/27` on `[0,1]`,
  with the maximum `4/27` at `d = 2/3`.
* `relaxed_infimum_zero` : if degrees were an *unconstrained* probability law with mean `β`,
  the average of `f` could be pushed to `0` for **every** `β ∈ [0,1]` (put mass `β` at `d = 1`
  and mass `1 − β` at `d = 0`).  Thus the mean constraint alone never forces a positive
  minimum — the genuine positivity comes solely from *graph realizability* (a degree law
  concentrated at `{0,1}` is not graphical at intermediate density).

The construction profile `minProfile t = t²(1 − t)` is exactly `f` evaluated at the parameter
`t` (`minProfile_eq_starFunctional`), and on the construction's honest range its value stays
below the bump maximum (`construction_profile_le_max`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The semi-induced minimum is forced to be positive at intermediate
  density by the *mean* edge-density constraint alone.
Experiment (Experimenter): Disproved the mean-only hypothesis: the two-point law at `{0,1}`
  with mass `β` at `1` has mean `β` and `f`-average `0` for every `β` (`relaxed_infimum_zero`).
  Proved `starFunctional_nonneg`, `starFunctional_le` (bump `≤ 4/27`), `starFunctional_max`.
Analysis (Analyst): The positivity of the genuine graph minimum is therefore *purely* a
  realizability phenomenon: at edge density `1/2` no graph can have almost every vertex of
  neighbour-density `0` or `1` (universal vertices force everyone's degree up), so the
  `f`-average stays bounded away from `0`.  This is exactly why `minProfile 1 = 0` at
  `β = 1/2` is unattainable and the headline profile breaks at the top of its range.
Critique (Critic): `relaxed_infimum_zero` must be a genuine identity, not vacuous — verified it
  produces mean `β` and average `0` simultaneously via `ring`.  `starFunctional_le` is an
  `nlinarith` certificate on `(3d − 2)²`, not a `norm_num` evaluation, so the bump bound is
  load-bearing.
Synthesis (PI): The clean separation — `f` bounded, mean-relaxation zero — pinpoints the open
  difficulty as a realizability lower bound, recorded in `FUTURE_DIRECTIONS.md`.
-/
import Mathlib
import Novelty.RedBlueStarS21Profile

namespace RedBlueStarS21

open Set

/-- The per-vertex *star functional* `f(d) = d²(1 − d)`, whose vertex-average is the
asymptotic semi-induced `S_{2,1}` density. -/
noncomputable def starFunctional (d : ℝ) : ℝ := d ^ 2 * (1 - d)

/-- The construction profile is the star functional evaluated at the parameter. -/
theorem minProfile_eq_starFunctional (t : ℝ) : minProfile t = starFunctional t := rfl

/-- `f` is nonnegative on `[0,1]`. -/
theorem starFunctional_nonneg {d : ℝ} (hd : d ∈ Icc (0 : ℝ) 1) :
    0 ≤ starFunctional d := by
  obtain ⟨h0, h1⟩ := hd
  unfold starFunctional
  have : 0 ≤ 1 - d := by linarith
  positivity

/-- **The bump bound.** On `[0,1]`, `f(d) = d²(1 − d) ≤ 4/27`; the certificate is the square
`(3d − 2)²`.  This is the maximum semi-induced contribution a single neighbour-density can
make. -/
theorem starFunctional_le {d : ℝ} (hd : d ∈ Icc (0 : ℝ) 1) :
    starFunctional d ≤ 4 / 27 := by
  obtain ⟨h0, h1⟩ := hd
  unfold starFunctional
  nlinarith [sq_nonneg (3 * d - 2), sq_nonneg d, mul_nonneg h0 h0]

/-- The bump maximum `4/27` is attained at `d = 2/3`. -/
theorem starFunctional_max : starFunctional (2 / 3) = 4 / 27 := by
  unfold starFunctional; norm_num

/-- On the construction's honest parameter range `[0,1]`, the profile value never exceeds the
bump maximum `4/27`. -/
theorem construction_profile_le_max {t : ℝ} (ht : t ∈ Icc (0 : ℝ) 1) :
    minProfile t ≤ 4 / 27 := by
  rw [minProfile_eq_starFunctional]
  exact starFunctional_le ht

/-- **The mean constraint never forces a positive minimum.** For every target edge density
`β ∈ [0,1]`, the two-point degree law placing mass `β` at neighbour-density `1` and mass
`1 − β` at neighbour-density `0` has mean exactly `β` yet star-functional average exactly `0`.

Formally: the mean `β·1 + (1−β)·0 = β`, and the `f`-average
`β·f(1) + (1−β)·f(0) = 0`.  Hence the genuine positivity of the semi-induced minimum is a
*graph-realizability* phenomenon, not a consequence of the edge-density (mean) constraint. -/
theorem relaxed_infimum_zero (β : ℝ) :
    (β * 1 + (1 - β) * 0 = β) ∧
    (β * starFunctional 1 + (1 - β) * starFunctional 0 = 0) := by
  refine ⟨by ring, ?_⟩
  unfold starFunctional
  ring

/-- The bump is *strictly* positive at every interior neighbour-density, quantifying the
realizability gap pointwise: any vertex of density `d ∈ (0,1)` contributes a positive amount
of semi-induced `S_{2,1}`. -/
theorem starFunctional_pos {d : ℝ} (h0 : 0 < d) (h1 : d < 1) : 0 < starFunctional d := by
  unfold starFunctional
  have : 0 < 1 - d := by linarith
  positivity

end RedBlueStarS21