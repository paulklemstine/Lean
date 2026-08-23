# Computational evidence — NET-71 (round 24, German prose leg)

All numbers below were produced by `#eval` against the Lean definitions that the
theorems in `Catalog/Logic/NET71*.lean` are stated about, using the same rational
arithmetic (ℚ, exact — no floating point).  Every claim marked **proved** is additionally
discharged by a `sorry`-free theorem in the listed file; the evaluations are a
sanity-check on the *formalisation of the data*, not a substitute for the proofs.

## 1. The measured sweeps and their knees

Bar: `0.98` of full accuracy.  Grid: index `j` means `4j` keys.

German @ 512 (`german512`):

| keys | 0 | 4 | 8 | 12 | 16 | 20 | 24 |
|---|---|---|---|---|---|---|---|
| retained | — | 0.883 | 0.953 | 0.969 | 0.976 | **0.983** | 0.988 |
| clears bar | ✗ | ✗ | ✗ | ✗ | ✗ | **✓** | ✓ |

German @ 1024 (`german1024`):

| keys | 8 | 12 | 16 | 20 | 24 |
|---|---|---|---|---|---|
| retained | 0.926 | 0.956 | 0.968 | 0.975 | **0.982** |
| clears bar | ✗ | ✗ | ✗ | ✗ | **✓** |

First-passing index computed by exhaustive search over the grid:

```
firstPass german512  bar98 = 5  →  20 keys
firstPass german1024 bar98 = 6  →  24 keys
firstPass code512    bar98 = 3  →  12 keys   (NET-68, for comparison)
firstPass code1024   bar98 = 4  →  16 keys
```

**Proved** (`Catalog/Logic/NET71GermanKneeShift.lean`): `net71_de512_knee_concrete`,
`net71_de1024_knee_concrete`, plus `net71_de512_subknee_fail`,
`net71_de1024_subknee_fail` for the ✗ column.

## 2. Margins and the noise question

* @512: below-margin `0.980 − 0.976 = 0.004`, above-margin `0.983 − 0.980 = 0.003`.
* @1024: below-margin `0.980 − 0.975 = 0.005`, above-margin `0.982 − 0.980 = 0.002`.

So the stability radius is `0.003` at 512 and `0.002` at 1024.  With the reported
"≈1.5 SE" at the 16-key point of the 512 sweep (SE ≈ `0.0027`), the 512 knee is stable to
about `1.1` SE and the 1024 knee to about `0.7` SE.

**Proved**: `de512_knee_stable`, `de1024_knee_stable`,
`de512_knee_unstable_at_four_thousandths`, `de1024_knee_unstable_at_five_thousandths`
(sharpness), and the general form `kneeIdx_stable_of_margins` /
`exists_perturbation_lowering_knee` in `NET71DiagonalRigidity.lean`.

## 3. The four-domain table, evaluated at four contexts

`(domainLaw D).eval d` for `d = 0,1,2,3` (i.e. ctx `512, 1024, 2048, 4096`):

```
code     : [12, 16, 20, 24]
prose EN : [16, 20, 24, 28]
math     : [16, 20, 24, 28]
prose DE : [20, 24, 28, 32]
```

Rank sums `rank D + d` for the same cells:

```
code     : [0, 1, 2, 3]
prose EN : [1, 2, 3, 4]
math     : [1, 2, 3, 4]
prose DE : [2, 3, 4, 5]
```

The two tables are related by `budget = 12 + 4 · ranksum` in all sixteen cells — the
iso-budget diagonals are visible as the anti-diagonals of the first table.

**Proved**: `net71_table`, `eval_eq_rank_add`, `iso_budget_iff_rank_sum_eq`,
`net71_prediction_4096` (`NET71FourDomainDeployment.lean`), and — from the two structural
axioms rather than from the numbers — `net71_table_is_diagonal`
(`NET71DiagonalRigidity.lean`).

## 4. Grid resolution

`roundUp g k` for `g ∈ {2,4,8,16}` applied to the three measured bases `12, 16, 20`:

```
g = 2  : [12, 16, 20]     faithful
g = 4  : [12, 16, 20]     faithful (coarsest such)
g = 8  : [16, 16, 24]     code/EN gap erased, EN/DE gap doubled
g = 16 : [16, 16, 32]     both gaps destroyed
```

**Proved**: `net71_grid_faithful_iff_dvd_four`,
`coarse_grid_hides_code_gap_and_doubles_german_gap` (`NET71TokenizerTax.lean`).

## 5. The tokenizer-tax density model

`predBase ρ = 4·⌈4ρ⌉`, calibrated so that English (`ρ = 1`) reads `16`:

| ρ | 1/8 | 1/4 | 3/8 | 1/2 | 5/8 | 3/4 | 7/8 | 1 | 9/8 | 5/4 | 11/8 | 3/2 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| predBase | 4 | 4 | 8 | 8 | 12 | 12 | 16 | 16 | 20 | 20 | 24 | 24 |

Reading the table backwards: base `12` ⇔ `ρ ∈ (1/2, 3/4]`, base `16` ⇔ `ρ ∈ (3/4, 1]`,
base `20` ⇔ `ρ ∈ (1, 5/4]`.  The three intervals are disjoint, so the measured `−4 / 0 /
+4` shifts pin a strict density ladder `code < English < German` — a prediction about
token counts alone, testable on the corpora without training a model.

**Proved**: `predBase_calibrated`, `predBase_mono`, `predBase_eq_iff`,
`net71_density_intervals`, `net71_density_intervals_disjoint`,
`high_density_forces_seven_steps`.

## 6. Counterexample hunt (the adversarial column)

Two scenarios were searched for by hand and then verified exactly: unquantised knees
`(κ_EN, κ_DE) = (16, 16.5)` and `(12.25, 20)` both reproduce the measured grid indices
`4` and `5` at ctx 512, yet have true taxes `0.5` and `7.75`.  Hence the "+4" is a
statement about the *reported* budgets; what survives about the underlying knees is only
`0 < κ_DE − κ_EN < 8`.

**Proved**: `net71_true_shift_not_identifiable`, `net71_true_shift_pos`,
`net71_true_shift_lt_two_steps`.

## 7. Workload coverage (cycle 3)

Rank sums of the eight cells of the round-24 workload (four domains at ctx 512 and 1024):
`0, 1, 1, 1, 2, 2, 2, 3`.  Coverage as a function of the cache rung:

| rung r | 0 | 1 | 2 | 3 |
|---|---|---|---|---|
| keys `12+4r` | 12 | 16 | 20 | 24 |
| cells served (of 8) | 1 | 4 | 7 | 8 |

So the last cell — German prose at ctx 1024 — costs a whole fine step on its own.

**Proved**: `net71Workload_served`, `net71_seven_of_eight_saves_one_step`,
`net71_hardest_cell_unique` (`NET71WorkloadQuota.lean`).

No OEIS lookup applies: the sequences here are the finite measured tables `12,16,16,20`
and `12+4n`, whose only arithmetic content (an arithmetic progression of common
difference 4) is exactly what §3 formalises.
