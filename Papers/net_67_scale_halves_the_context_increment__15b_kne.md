# Computational evidence — NET-67 attention-budget increment law

Scope: the numbers below guided the formalisation in `Catalog/Novelty/`.
Everything marked **[Lean]** is proved in a `sorry`-free Lean file; everything
marked *(exploratory)* comes from a scratch numerical computation and is **not**
machine-verified.

## 1. The measured grid and the two fitted laws

Contexts `512, 1024, 2048` correspond to `j = 0, 1, 2` doublings.

| j (ctx)      | 0 (512) | 1 (1024) | 2 (2048) | 3 (4096, predicted) |
|--------------|---------|----------|----------|---------------------|
| 0.5B measured| 16      | 20       | 24       | 28                  |
| `kneeSmall j = 16+4j` | 16 | 20 | 24 | 28 |
| 1.5B measured| 16      | 16       | 18       | 20 (slope-2 fit)    |
| `kneeLarge j = max 16 (14+2j)` | 16 | 16 | 18 | 20 |

**[Lean]** `kneeSmall_data`, `kneeLarge_data` reproduce the measured triples;
`kneeSmall_affine`, `kneeLarge_increment`, `kneeLarge_first_increment` give the
increments `4,4` and `0,2`.

Increment audit *(all **[Lean]**, `halving_is_terminal_not_average`)*:

| reading            | 0.5B | 1.5B | ratio |
|--------------------|------|------|-------|
| terminal increment | 4    | 2    | 2 (halving — the advertised verdict) |
| window average     | 4    | 1    | 4 (quartering) |

Deployment: `24 ≤ B` is necessary and sufficient at `ctx = 2048`
(**[Lean]** `least_budget_at_2048`); the informal "20 keys covers both models to
2048" is refuted (**[Lean]** `twenty_key_budget_does_not_cover_both`), since the
0.5B model needs 24 there.

Budget ratio `kneeSmall j / kneeLarge j` *(exploratory)*:
`j=2: 1.333, j=5: 1.500, j=10: 1.647, j=50: 1.895, j=200: 1.971` — consistent
with the **[Lean]** limit `ratio_tendsto_two`.

## 2. Counterexample hunt: can a *fixed* profile give an additive law?

Truncated geometric profile `p_i ∝ r^i` on `n` keys, threshold `τ = 0.95`,
knee computed by direct summation *(exploratory)*:

| r \ n | 512 | 1024 | 2048 | 4096 |
|-------|-----|------|------|------|
| 0.8   | 14  | 14   | 14   | 14   |
| 0.9   | 29  | 29   | 29   | 29   |

The knee is *completely flat in context* — the increment is `0`, never `+4`.
`⌈log(1-τ)/log r⌉` gives `⌈13.4⌉ = 14` and `⌈28.4⌉ = 29`, matching exactly.
This is the search that turned into the theorem
**[Lean]** `knee_geoW_bounded` / `no_fixed_geometric_profile_matches_kneeSmall`:
no fixed geometric profile can produce a persistent positive increment — and,
in the strengthened form **[Lean]** `knee_truncNorm_bounded` /
`no_fixed_profile_matches_kneeSmall`, no fixed *summable* profile of any shape.

## 3. Grid resolution (the NET-66 read of 20 vs the NET-67 read of 18)

With true knee `18` and a sweep restricted to `{16, 20, 24, …}` (spacing 4), the
first passing grid point is `20`: an over-read of `2 < 4`.
**[Lean]** `coarse_grid_reads_twenty`, and in general
**[Lean]** `kneeMul_bounds`: `knee ≤ knee_grid < knee + d`.

## 4. The scale exponent and the extrapolation

Calibration: peakedness `λ₀(0.5B) = 1`, `λ₀(1.5B) = 2` (from the increments 4
and 2 at tail budget `δ = e⁻⁴`, **[Lean]** `calibration_small`,
`calibration_large`).  A power law `λ₀(N) = (2N)^θ` then forces
`θ = log 2 / log 3 ≈ 0.63093` *(exploratory value; **[Lean]** `three_rpow_theta`
proves the defining identity `3^θ = 2`)*.

Predicted increment `incrAt N = 4 (2N)^(-θ)` *(exploratory values; the
thresholds are **[Lean]**)*:

| N (B)   | 0.5 | 1.5 | 3.0   | 4.5 | 7.0   | 13.5 | 70    |
|---------|-----|-----|-------|-----|-------|------|-------|
| incrAt  | 4.0 | 2.0 | 1.292 | 1.0 | 0.757 | 0.5  | 0.177 |

**[Lean]** `incrAt_threshold` (`incrAt 4.5 = 1` exactly),
`incrAt_half_threshold` (`incrAt 13.5 = 1/2` exactly),
`incrAt_lt_one_iff` (`incrAt N < 1 ↔ 4.5 < N`), and the bracket
`prediction_7B`: `1/2 < incrAt 7 < 1`.

## 5. OEIS

No integer sequence beyond the arithmetic progressions `16+4j` (A016861-type
affine progression) and the hinge `16,16,18,20,22,…` arises; no OEIS lookup was
informative, so none is claimed.
