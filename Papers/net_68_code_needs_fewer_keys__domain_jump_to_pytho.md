# Computational evidence — NET-68 (CODE-NEEDS-FEWER-KEYS)

All numbers below are from the round-21 lab notes plus small exact-arithmetic
calculations. Everything marked **[Lean]** has a machine-checked counterpart in
`Catalog/Applications/NET68DomainJumpBudgetLaw.lean` or
`Catalog/Applications/NET68DecayRescalingAlternative.lean`; everything marked
*(exploratory)* was computed in exact rational arithmetic outside Lean and is **not**
a verified claim on its own.

## 1. Knee readings from the measured sweeps

Bar = `0.98` of full accuracy, fine grid step `4`.

| ctx | budget → retained accuracy | first index clearing the bar | k\* |
|---|---|---|---|
| 512 | 4: 0.930, 8: 0.969, **12: 0.981**, 16: 0.987, 20: 0.988, 24: 0.989 | 3 | **12** |
| 1024 | 8: 0.960, 12: 0.976, **16: 0.981**, 20: 0.986, 24: 0.987 | 4 | **16** |

**[Lean]** `net68_code512_knee_concrete`, `net68_code1024_knee_concrete` (knee indices
`3`, `4`; budgets `12`, `16`), `net68_code512_subknee_fail`,
`net68_code1024_subknee_fail` (the ✗ rows really miss the bar).

The `k = 4` cell at ctx 1024 was not swept. It cannot matter: monotonicity puts it below
`0.960 < 0.98`. **[Lean]** the knee theorems are stated in bracket form
(`kneeIdx_eq_succ_of_bracket`), so only the last failing and first passing readings enter.

## 2. Fit of the parameterised law

`k*(domain, ctx) = base(domain) + inc · doublings(ctx)`.

| domain | ctx 512 (d=0) | ctx 1024 (d=1) | fitted base | fitted inc |
|---|---|---|---|---|
| prose | 16 | 20 | 16 | 4 |
| code  | 12 | 16 | 12 | 4 |

Shift = `4` keys = exactly one fine grid step, at both contexts.
**[Lean]** `net68_shift`, `net68_shift_is_one_fine_step`, `codeLaw_unique`,
`proseLaw_unique`, `net68_increment_shared`.

Grid aliasing check *(exploratory, then verified)*: `roundUp 8 12 = 16 = roundUp 8 16`,
so the effect vanishes on a step-8 grid. **[Lean]** `coarse_grid_hides_shift`,
`fine_grid_shows_shift`.

## 3. Counterexample hunt: does a *multiplicative* mechanism fit as well?

Model: geometric attention decay `cum k = 1 − r^k`, code decaying as `r_code = r_prose^a`.
Then the continuous knee `X = log ρ / log r` is divided by `a` **[Lean]**
(`geomKnee_eq_ceil`, `geomKnee_rpow_eq_ceil_div`), and a reading of `C` keys given prose
reading `P` requires `X ∈ (P−1, P]` and `X/a ∈ (C−1, C]`, i.e.

`(P−1)/C < a < P/(C−1)`.

Admissible exponent windows *(exploratory, exact fractions)*:

| ctx | prose k\* | code k\* | window for `a` | decimal |
|---|---|---|---|---|
| 512 | 16 | 12 | (5/4, 16/11) | (1.2500, 1.4545) |
| 1024 | 20 | 16 | (19/16, 4/3) | (1.1875, 1.3333) |
| 2048 (predicted) | 24 | 20 | (23/20, 24/19) | (1.1500, 1.2632) |
| 4096 (predicted) | 28 | 24 | (9/8, 28/23) | (1.1250, 1.2174) |

* Intersection over ctx 512, 1024, 2048: `(1.2500, 1.2632)` — **non-empty**.
* Intersection including ctx 4096: **empty** (`1.2500 > 1.2174`).

So the two measured cells do **not** refute the multiplicative mechanism — this is a real
identifiability gap in round 21, not a win for the additive law. A concrete witness inside
the surviving window is `a = 251/200 = 1.255` with continuous knees `15.05`, `20`, `24`:
`⌈15.05⌉ = 16, ⌈15.05/1.255⌉ = 12`; `⌈20⌉ = 20, ⌈20/1.255⌉ = 16`; `⌈24⌉ = 24,
⌈24/1.255⌉ = 20`. **[Lean]** `rescaling_model_matches`, `separation_is_sharp`,
`two_cells_do_not_identify_the_mechanism`, and `rescaling_model_realisable` (the witness is
realised by honest geometric profiles, via `exists_geom_profile_with_continuous_knee`).

At 4096 the same witness gives `⌈28/1.255⌉ = 23`, one key below the additive `24`.
**[Lean]** `rescaling_factor_gt_five_quarters` (the 512 cell forces `a > 5/4` for *every*
rescaling model), `rescaling_prediction_4096_le_23`, `no_rescaling_model_fits_512_and_4096`,
`net69_discriminating_experiment`.

## 4. Sanity checks on the structural claims

* Accuracy ⟂ knee: any (full accuracy, knee) pair is realisable — checked in Lean by
  construction rather than numerically. **[Lean]** `accuracy_knee_decoupled`,
  `no_accuracy_functional_law`, `easier_can_need_fewer_or_more_keys`.
* Mixed workload: `max(12+4d, 16+4d) = 16+4d` for all `d`. **[Lean]**
  `mixed_workload_law`, `sizing_by_code_underprovisions`, `eval_sup'`.
* The envelope rule is not free: for the incomparable pair `⟨16,2⟩`, `⟨12,6⟩` the
  pointwise maximum is not affine (values `16, 18, 20, 22, …` versus `12, 18, 24, 30, …`
  give the envelope `16, 18, 24, 30, …`, whose successive differences `2, 6, 6` are not
  constant). **[Lean]** `envelope_not_a_law`, `envelope_failure_realisable`.
* Domain axis: code and prose differ by the single torsor element `4`, and translating
  both bases leaves it unchanged. **[Lean]** `net68_domain_axis`,
  `only_base_differences_are_observable`.

## 5. OEIS

The knee ladders `12, 16, 20, 24, …` and `16, 20, 24, 28, …` are arithmetic progressions
with common difference 4; no non-trivial OEIS entry is implicated, and none is claimed.
