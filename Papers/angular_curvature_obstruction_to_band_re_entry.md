# Computational evidence: the U108 ladder in the angle coordinate

The numbers below are floating-point values from ad-hoc exploration (double precision). They are
**not** themselves verified. The sign and threshold claims marked "(Lean)" are proved in
`Catalog/Novelty/TDialU108AngularCurvature.lean` using certified mean-value bounds for `arccos`.

## 1. Ladder, angle, second differences

| bitlen | ρ | θ = arccos ρ | Δ²ρ (window starting here) | Δ²θ (window starting here) |
|---|---|---|---|---|
| 96  | 0.5739  | 0.95954 | −0.0128 | +0.01400 |
| 100 | 0.5436  | 0.99608 | +0.0306 | −0.03616 |
| 104 | 0.5005  | 1.04662 | −0.0134 | +0.01506 |
| 108 | 0.4880  | 1.06100 | +0.0485 | −0.05509 |
| 112 | 0.4621  | 1.09043 | −0.07094 | +0.08013 |
| 116 | 0.4847  | 1.06478 | — | — |
| 120 | 0.43636 | 1.11925 | — | — |

* Δ²ρ signs `−,+,−,+,−` (Lean: `measured_rho_curvature_alternates`).
* Δ²θ signs `+,−,+,−,+` (Lean: `measured_angle_curvature_alternates`).
* The window based at 108 (108/112/116) is angularly concave, which is the local compatibility
  the mission statement refers to. The next window (112/116/120) is angularly convex with excess
  ≈ 0.0801 > 0.079 (Lean: `measured_convexity_excess_at_112`).

## 2. Counterexample hunt for the "angular concavity" model

* Angular concavity from an index `N`, together with the bound θ ≥ 0, forces θ to be nondecreasing
  from `N` on (Lean: `concave_bddBelow_monotone`). Since arccos is strictly decreasing, this means
  ρ is nonincreasing from `N` on (Lean: `angular_concave_imp_antitone`).
* The 116 rebound (0.4621 → 0.4847) is therefore a counterexample for every `N ≤ 4`
  (Lean: `no_concave_angle_model`). The 120 drop (0.4847 → 0.43636) rules out angular convexity
  for every `N ≤ 5` (Lean: `no_convex_angle_model`).

## 3. Concave continuation of the rebound (rebound bound)

If the angle is continued concavely from the 112/116 rungs, the steepest admissible path is
θ₁₁₆₊₄ₖ ≤ θ₁₁₆ − k·D, where D = θ₁₁₂ − θ₁₁₆ ≈ 0.025658. The table gives the correlation cos of
that chord bound, i.e. the smallest value of ρ the concave model allows:

| bitlen | chord bound on θ | minimum allowed ρ |
|---|---|---|
| 120 | 1.03912 | 0.5070 (measured 0.43636: violates) |
| 124 | 1.01346 | 0.5289 |
| 128 | 0.98780 | 0.5505 (just inside the cap) |
| 132 | 0.96214 | 0.5718 |
| 136 | 0.93648 | 0.5926 |

Lean proves the robust form: ρ₁₃₂ > 0.55 (`concave_rebound_forces_reentry`). The 128 case is too
close to the threshold (0.5505 vs 0.55) to certify with the mean-value bounds used, so it is left
as numerical evidence only. Over 62 windows the chord bound would take the angle below 0, so
concavity cannot last that long (`concave_rebound_lifetime`).

## 4. Angular plateau window (U108 instance)

For angles that are nondecreasing with deceleration ratio ≤ 1/2 from 108 on, the limit lies in
[arccos 0.488, arccos 0.488 + 0.0595] ≈ [1.0610, 1.1205] (Lean: `u108_angle_plateau_window`).
In correlation terms (numerical only) this is ρ∞ ∈ [≈0.4352, 0.488]. Measured 120 rung:
θ = 1.1192, which lies inside this window numerically; this inclusion is not proved in Lean.

## 5. OEIS

Not applicable: the data are real-valued measurements, not an integer sequence.

## 6. Parity sub-ladders

Even rungs θ: 0.95954, 1.04662, 1.09043, 1.11925 (increments 0.08708, 0.04381, 0.02882: concave).
Odd rungs θ: 0.99608, 1.06100, 1.06478 (increments 0.06492, 0.00378: concave).
Both classes are strictly decreasing in ρ (Lean: `parity_subladders_monotone_concave`).
