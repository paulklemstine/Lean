# Computational evidence for the NET-36 attention-cost formalisation

Small, directly relevant checks made before formalising.  Everything marked
**[Lean]** is reproduced as a machine-checked theorem in
`Catalog/Probability/`; everything marked *[scratch]* was computed in an ad-hoc
script and is reported only as motivation — it is **not** a verified result.

## 1. The grid predicted by `k* = d·ctx/32`

*[scratch]* arithmetic, matching the reported measurements:

| d | ctx | d·ctx/32 | measured k* | speedup ctx/k* | 32/d |
|---|-----|----------|-------------|----------------|------|
| 4 | 128 | 16 | 16 | 8.0 | 8.0 |
| 8 | 128 | 32 | 32 | 4.0 | 4.0 |
| 16 | 128 | 64 | 64 (NET-17 s0, NET-36 s1) | 2.0 | 2.0 |
| 4 | 512 | 64 | 64 (NET-35 s1, NET-36 s2) | 8.0 | 8.0 |

The speedup column is constant along each row of fixed `d`, which is the
context-invariance the round reports.  **[Lean]** `speedup_context_invariant`
proves `ctx / (d·ctx/32) = 32/d` for every cell with `32 ∣ d·ctx`, and
**[Lean]** `cost_law_unique` shows this invariance plus depth-linearity already
forces the bilinear form.

## 2. Mass knee versus accuracy knee (the sharpest finding)

Reported concentration for cell B (`d=4, ctx=512`): eff support `N_eff = 152.11`.
The Cauchy–Schwarz bound `topk mass ≤ sqrt(k/N_eff)` gives

| k | `sqrt(k/152.11)` = max possible retained **mass** | measured retained **accuracy** |
|---|---|---|
| 16 | 0.324 | 0.965 |
| 32 | 0.459 | 0.976 |
| 64 | **0.649** | **0.985** |
| 128 | 0.917 | 0.993 |
| 256 | 1.000 (bound vacuous) | 0.998 |

*[scratch]* numerics; **[Lean]** `retained_mass_at_knee_le` proves the `k = 64`
row (`≤ 0.65`), and **[Lean]** `mass_knee_gt_measured_knee` /
`accuracy_knee_not_mass_knee` prove that a `0.98`-mass budget needs
`k ≥ 0.98²·152.11 = 146.09 > 64`.

So at the measured knee the model keeps **≤ 65 % of the attention mass** and
still **98.5 % of the accuracy**.  This is the quantitative separation that
`AttentionTruncationOutput.lean` then explains via the logit margin.

Cross-check on the other cell: `N_eff = 52.73` at `d = 16, ctx = 128`, where
`sqrt(64/52.73) = 1.10 > 1` — the bound is vacuous there, so the separation is a
long-context phenomenon in the measured grid, not a universal one.  This is an
honest limitation and is stated as such.

## 3. Counterexample hunt: can `N_eff` alone predict the knee?

Spike family `p = (1/2, 1/(2(n+1)), …)` on `n+2` positions:

| n | `N_eff = 4(n+1)/(n+2)` | top-1 mass | top-`k` mass (`k` fixed, `n → ∞`) |
|---|---|---|---|
| 1 | 2.667 | 0.5 | → 0.5 |
| 10 | 3.667 | 0.5 | → 0.5 |
| 100 | 3.961 | 0.5 | → 0.5 |
| 1000 | 3.996 | 0.5 | → 0.5 |

*[scratch]* table; **[Lean]** `spike_effSupport`, `spike_topk_mass_le`,
`spike_effSupport_tendsto` and `effSupport_does_not_control_topk` verify all of
it.  The family also saturates the Cauchy–Schwarz bound at `k = 1`
(**[Lean]** `spike_saturates_cauchy_schwarz`), so the bound of §2 is sharp.

Conclusion of the hunt: **no lower bound on top-`k` mass in terms of `N_eff`
exists.**  Any derivation of `k* = d·ctx/32` from the reported concentration
statistic alone is therefore impossible, which is what motivated the
composition + scale-free-tail mechanism.

## 4. Knee-stability margins from the reported sweeps

| cell | swept `k` | retained | pass margin at `k*` | largest fail margin below `k*` | tolerated seed noise `η` |
|---|---|---|---|---|---|
| A (`d=16, ctx=128`, s1) | 8,16,32,64,96,128 | .858 .922 .970 .996 .999 1.000 | 0.996−0.98 = 0.016 | 0.98−0.970 = 0.010 | **0.005** |
| B (`d=4, ctx=512`, s2) | 16,32,64,128,256,384 | .965 .976 .985 .993 .998 1.000 | 0.985−0.98 = 0.005 | 0.98−0.976 = 0.004 | **0.003** |

`η` is `min(pass margin, largest fail margin)/2`, the perturbation radius under
which the knee provably cannot move.  Reported seed-to-seed spread is `±0.002`,
strictly inside both.  **[Lean]** `netA_knee_seed_stable`,
`netB_knee_seed_stable`, `grid_completion`.

## 5. OEIS

No integer sequence arises here beyond `16, 32, 64` (the measured knees) and the
divisor table of `d·ctx/32`; an OEIS lookup is not informative and was not
performed.

## 6. Second cycle: depth rigidity, long context, random-`k` control

### 6a. The geometric factor of an expansive stack

`∑_{i<d} Λ^i` with `Λ = 1 + x`, compared with the nonexpansive value `d`:

| d | `Λ = 1 + 1/d` | `Λ = 1.05` (fixed) | `d` (nonexpansive) | `d·e` (certified ceiling) |
|---|---|---|---|---|
| 4 | 5.8 | 4.3 | 4 | 10.9 |
| 8 | 12.5 | 9.5 | 8 | 21.7 |
| 16 | 26.2 | 23.7 | 16 | 43.5 |
| 32 | 53.7 | 75.3 | 32 | 87.0 |
| 64 | 108.6 | 434.1 | 64 | 174.0 |

*[scratch]* arithmetic.  The `1 + 1/d` column stays within a factor `e` of `d`
(**[Lean]** `geom_sum_le_of_near_isometry`, `depth_leg_linear_of_near_isometry`),
while the fixed-`Λ` column leaves every multiple of `d` behind
(**[Lean]** `geom_sum_ge_quadratic`, `expansive_depth_leg_superlinear`,
`expansive_knee_not_linear`).  The fixed-`Λ` column crosses the `1 + 1/d`
column between `d = 16` and `d = 32` and is `4×` larger by `d = 64`, so the
`d = 32` run of the open list already discriminates the branches.

### 6b. Mass ceiling at the law's own budget

`sqrt(k/N_eff)` at `k = d·ctx/32`, `d = 4`, under two hypotheses for `N_eff`:

| ctx | k* | `N_eff = ctx` (linear) | `N_eff ≈ 0.75·ctx^0.85` (measured fit) |
|---|---|---|---|
| 128 | 16 | 0.354 | 0.586 (`N_eff = 46.6` measured) |
| 512 | 64 | 0.354 | 0.649 (`N_eff = 152.11` measured) |
| 1024 | 128 | 0.354 | ≈ 0.68 (`N_eff ≈ 275` predicted) |

*[scratch]* numerics; **[Lean]** `mass_at_law_budget_le` proves the linear column
(`sqrt(d/(32α))`, context-independent) and **[Lean]**
`ctx1024_mass_prediction` proves the `ctx = 1024` entry of that column
(`≤ 0.36`), with **[Lean]** `uniform_row_realises_ctx1024_hypotheses` certifying
that its hypotheses are satisfiable.  The measured column is the sub-linear
regime conjectured as D3 in `FUTURE_DIRECTIONS.md`.

### 6c. Random-`k` control, exactly

For `s` of size `ctx` the mean retained mass over all `k`-subsets is `k/ctx`
exactly — e.g. `64/512 = 0.125` at cell B — while the selected top-`k` mass is at
most `sqrt(64/152.11) = 0.649`.  Ratio `≤ 0.649/0.125 = 5.19`.

*[scratch]* numerics; **[Lean]** `random_mass_average` proves the mean
(via the double count `sum_powersetCard_mass` and
`card_filter_mem_powersetCard`), **[Lean]** `selection_gain_le` proves the
general ceiling `ctx/sqrt(k·N_eff)` and **[Lean]** `netB_selection_gain_le`
proves the numeric ceiling `5.2` at the measured cell.  So the reported control
gaps (`+7.6/+5.2` accuracy points) cannot be attributed to an unbounded mass
advantage: the mass advantage is capped at a factor `5.2`.

## 7. Third cycle: the margin law, and the amplitude that the concentration allows

### 7a. The deficit at the margin knee is `Θ(m/(L·B))`

For a scale-free tail of amplitude `A` over `ctx` positions, the margin channel
selects `k* = ⌈4·L·B·A·ctx/m⌉` and the deficit there is `A·ctx/k*`:

| `4·L·B·A·ctx/m` (real budget) | `k*` | deficit `A·ctx/k*` | `m/(4LB)` | `m/(8LB)` |
|---|---|---|---|---|
| 1.0 | 1 | `A·ctx` | `A·ctx` | `A·ctx/2` |
| 12.5 | 13 | `0.0769·A·ctx` | `0.08·A·ctx` | `0.04·A·ctx` |
| 63.4 | 64 | `0.0156·A·ctx` | `0.01577·A·ctx` | `0.00789·A·ctx` |
| 200.3 | 201 | `0.00498·A·ctx` | `0.00499·A·ctx` | `0.0025·A·ctx` |

*[scratch]* arithmetic.  Every deficit column entry lies in the window
`[m/(8LB), m/(4LB)]`, and the window is tight: the lower constant `1/8` is
approached exactly when the real budget is close to `1`, where the ceiling
rounds up by nearly a full unit.  **[Lean]** `margin_law_upper`,
`margin_law_lower`, `margin_law_theta`.  **[Lean]** `marginKnee_antitone` proves
the knee is antitone in the margin and `marginKnee_inverse_scaling` proves the
exact `1/m` scaling before rounding.

### 7b. What the margin has to be at the measured long-context cell

`retained_mass_at_knee_le` certifies `ρ ≤ 0.65` at `k = 64`, `N_eff = 152.11`.
The retention threshold `ρ > 1 − m/(4LB)` then needs `m/(4LB) > 0.35`:

| certified mass ceiling `ρ` | implied bound on the margin |
|---|---|
| 0.65 (`k = 64`, cell B) | `m > 1.4·L·B` |
| 0.46 (`k = 32`) | `m > 2.2·L·B` |
| 0.32 (`k = 16`) | `m > 2.7·L·B` |

*[scratch]* arithmetic for rows two and three; **[Lean]**
`netB_margin_channel_lower_bound` proves row one.  This is the falsifiable half
of C1: a logged median margin below `1.4·L·B` would refute the margin-channel
explanation of the knee at this cell.

### 7c. The amplitude the measured concentration forces

`N_eff ≤ 8·A·ctx + 4` (**[Lean]** `effSupport_le_eight_amplitude`), i.e.
`A ≥ (N_eff − 4)/(8·ctx)`; with the fitted calibration `A = δ/32` this reads
`δ ≥ 4·(N_eff − 4)/ctx`:

| cell | ctx | measured `N_eff` | implied `A ≥` | implied `δ ≥` |
|---|---|---|---|---|
| d=4 @128 | 128 | 46.6 | 0.0416 | 1.33 |
| d=8 @128 | 128 | 50.2 | 0.0451 | 1.44 |
| d=16 @128 | 128 | 52.73 | 0.0476 | **1.52** |
| d=4 @512 | 512 | 152.11 | 0.0362 | 1.16 |

*[scratch]* arithmetic; **[Lean]** `amplitude_ge_of_effSupport` proves the third
column in general and **[Lean]** `netA_budget_lower_bound` proves the boxed
entry (`δ ≥ 1.52` from `N_eff ≥ 52.73` at `ctx = 128`).

### 7d. Why the depth drift of `N_eff` is not amplitude drift

The depth-linear knee pins `A(d) = δ/32` at every depth (**[Lean]**
`amplitude_forced_by_depth_linear_knee`), so `A(d)·d = d·δ/32` quadruples
between `d = 4` and `d = 16` instead of staying constant (**[Lean]**
`amplitude_times_depth_not_constant`) — conjecture C2's form is refuted.  What
survives is a single depth-independent ceiling `N_eff ≤ δ·ctx/4 + 4` (**[Lean]**
`effSupport_ceiling_depth_independent`); the measured `46.6 → 50.2 → 52.7`
(a `+13 %` drift over a `4×` depth range) sits under it, whereas an amplitude
drift proportional to `N_eff` would have moved the knee by the same `+13 %`,
i.e. from `64` to `≈ 72`.

### 7e. The dimensionless knee window, and the margin the mechanism forces

Writing `x = 4·L·B·A·ctx/m` for the real budget the margin channel asks for, the
integer knee obeys `x ≤ k* ≤ 2x`, i.e. `k*·m/(4·L·B·A·ctx) ∈ [1, 2]`:

| `x` | `k* = ⌈x⌉` | `k*/x` |
|---|---|---|
| 1.0 | 1 | 1.00 |
| 12.5 | 13 | 1.04 |
| 15.2 | 16 | 1.05 |
| 63.4 | 64 | 1.01 |
| 200.3 | 201 | 1.003 |

*[scratch]* arithmetic; **[Lean]** `knee_margin_window` proves the window in
general.  The observed values cluster at the lower end (`≈ 1`), the upper end
`2` being attained only near `x = 1`.

Equating that budget with the measured `k* = d·ctx/32` at any depth forces
`m = 128·L·B·A` — no `d` appears — so within the mechanism the margin is
depth-independent: **[Lean]** `margin_forced_by_depth_linear_knee`,
`margin_depth_independent` (which also rules out the naive `m(16) = m(4)/4`).
Together with §7c this leaves one dimensionless prediction for the harness:
`m/(L·B) = 128·A ≈ 128·0.048 ≈ 6.1` at `ctx = 128` — comfortably above the
`1.4` floor of §7b, and directly measurable from a single held-out pass.
