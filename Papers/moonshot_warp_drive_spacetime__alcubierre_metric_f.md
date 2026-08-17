# Computational Evidence — Alcubierre warp-drive formalization

All numbers below were computed by hand from closed forms and, where marked **[Lean]**,
are backed by a machine-checked theorem in `Catalog/Physics/Spacetime/`.  Nothing here is
presented as verified unless it carries a **[Lean]** tag.

## 1. Pointwise energy density (small-case calculations)

From the ADM Hamiltonian constraint on the flat slices of the warp metric,

    ρ(v, ∇f) = -(v² ((∂_y f)² + (∂_z f)²)) / (32π).      **[Lean]** `energyDensity_eq`

Sample evaluations (units c = G = 1, π ≈ 3.14159):

| v_s | ∂_y f | ∂_z f | ρ                    | sign |
|-----|-------|-------|----------------------|------|
| 1   | 0     | 0     | 0                    | on-axis, no exotic matter |
| 1   | 1     | 0     | -1/(32π) ≈ -9.95e-3  | negative |
| 2   | 1     | 0     | -4/(32π) ≈ -3.98e-2  | 4× the v = 1 value (quadratic) |
| 2   | 1     | 1     | -8/(32π) ≈ -7.96e-2  | negative |
| 10  | 0.5   | 0     | -25/(32π) ≈ -0.249   | negative |

Observations that became theorems:
* the density is **never positive**, for any gradient and any speed
  (**[Lean]** `energyDensity_nonpos`);
* it vanishes **exactly** when the transverse gradient vanishes (the axis of motion) or
  when the warp speed is zero (**[Lean]** `energyDensity_neg_iff`,
  `exotic_support_is_toroidal`) — i.e. the exotic matter is a torus around the axis.

## 2. Total energy of a thin-wall bubble — table and scaling test

Closed form for the piecewise-linear wall of radius `R`, thickness `Δ`:

    E(v, R, Δ) = -v²R²/(12Δ) - v²Δ/144.        **[Lean]** `wall_energy_exact`

| v_s | R   | Δ   | E                    | E / E(v=1) |
|-----|-----|-----|----------------------|------------|
| 1   | 100 | 1   | -833.34              | 1          |
| 2   | 100 | 1   | -3333.36             | 4.000      |
| 3   | 100 | 1   | -7500.06             | 9.000      |
| 4   | 100 | 1   | -13333.4             | 16.000     |
| 2   | 100 | 0.1 | -33333.4             | thin wall  |
| 2   | 100 | 0.01| -333333.3            | thin wall  |

Two of these entries are machine-checked exactly:
**[Lean]** `wall_energy_numeric_speed_two` (`E = -120001/36` for `v=2, R=100, Δ=1`) and
**[Lean]** `wall_energy_numeric_speed_four` (quadrupling on doubling `v`).

**Counterexample hunt for the mission conjecture `E ~ M v_s c`.**  The ratio column above is
`1, 4, 9, 16` — squares, not the `1, 2, 3, 4` a linear law would give.  A single pair of
speeds already refutes any linear law, and the refutation is machine-checked in
**[Lean]** `linear_energy_scaling_false`; the asymptotic version is
**[Lean]** `energy_beats_linear`.  The conjecture is therefore **false** as stated; the true
law is quadratic in `v_s` and diverges like `1/Δ`.

## 3. Is the linear wall a bad profile?  (variational search)

Minimising `∫_a^b g² r² dr` subject to `∫_a^b g = -1` gives, by completion of squares, the
floor `ab/(b-a)` attained at `g ∝ -1/r²` (**[Lean]** `warp_energy_floor_is_sharp`).

| R   | Δ   | optimum `R²/Δ - Δ/4` | linear wall `R²/Δ + Δ/12` | excess |
|-----|-----|----------------------|---------------------------|--------|
| 100 | 1   | 9999.75              | 10000.083                 | 0.333  |
| 100 | 0.1 | 99999.975            | 100000.008                | 0.033  |
| 10  | 2   | 49.5                 | 50.167                    | 0.667  |

The excess is exactly `Δ/3` in every row — checked symbolically in
**[Lean]** `linear_wall_excess` (energy excess `v²Δ/36`).  So no profile engineering can
remove the `1/Δ` divergence (**[Lean]** `thin_wall_divergence_is_universal`).

## 4. Causality: the two-corridor loop

For effective speed `V` the loop-closing boost velocity is `β = 2V/(V²+1)`:

| V   | β = 2V/(V²+1) | βV   | closes loop? |
|-----|---------------|------|--------------|
| 1.5 | 0.923         | 1.38 | yes          |
| 2   | 0.8           | 1.6  | yes          |
| 5   | 0.385         | 1.92 | yes          |
| 1   | 1             | 1    | degenerate (β = 1, not admissible) |

Worked instance `V = 2`: the first leg runs from `(0,0)` to `(1,2)`; in the frame with
`β = 4/5` (γ = 5/3) that arrival event is `(-1, 2)`; a second leg of the same effective
speed, at rest in that frame, reaches `(0,0)` after `s = 1` — the departure event.  The
general statement is **[Lean]** `warp_pair_closes_loop`, and the fact that a *single* bubble
cannot do this is **[Lean]** `no_closed_causal_curve`.

## 5. OEIS

No integer sequence arises in this project — the objects are real-analytic (metric
components, energy integrals, boost velocities), so an OEIS search is not applicable.
