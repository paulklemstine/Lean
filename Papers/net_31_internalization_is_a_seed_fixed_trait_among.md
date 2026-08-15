# Computational evidence — NET-31 boundary-block internalization

All numbers below were computed inside Lean (`#eval` on exact `ℚ` / `ℕ`
arithmetic) before the theorems were stated; the qualitative facts they support
are the ones that were subsequently proved in
`Catalog/NumberTheory/BoundaryBlockInternalization.lean` and
`Catalog/NumberTheory/BoundaryBlockCollectiveCRT.lean`.

## 1. The recorded `zeroN` retentions

Control-normalised accuracy after zeroing the whole boundary block, as reported
by the round, entered as exact rationals (`ret2`, `ret3` in the `LabNotes`
section of the Lean file):

| seed | `k = 2` | `k = 3` | drop `k=2 → k=3` |
|------|---------|---------|------------------|
| 13   | 0.7544  | 0.7041  | 0.0503           |
| 14   | 0.9141  | 0.9014  | 0.0127           |
| 15   | 0.8037  | 0.7104  | 0.0933           |
| 17   | 0.9067  | 0.7437  | 0.1630           |

All other surveyed seeds (`8–12, 16, 18, 19`) read as no-ops at both widths.

Facts checked by decision procedure in Lean (`dependent_set_same_at_two_and_three`,
`dependent_set_eq`, `selfSufficient_count`, `dependence_grows_with_width`):

* with the dependence cut at retention `≤ 0.95`, the dependent set is the **same
  set at `k = 2` and at `k = 3`**, namely `{13, 14, 15, 17}`;
* `8` of the `12` surveyed seeds read as no-ops (the round quotes `7/12` after
  additionally excluding one marginal arm);
* the retention **strictly decreases** from `k = 2` to `k = 3` on all four
  dependent seeds.

## 2. Small-case calculation of the model's retention profile

For a seed with internal drive `base = 1` and per-dimension gain `gain = 1` the
model's retention profile `base / (base + k·gain)` is

```
k        : 0    1    2    3    4    5
retention: 1   1/2  1/3  1/4  1/5  1/6
```

i.e. exactly the harmonic sequence — this is the computational origin of the
`retention_asymptotic` (`k · retention k → base/gain`) and
`not_summable_retention` theorems. The sequence `1, 1/2, 1/3, …` is the harmonic
sequence (OEIS A000027 in the denominators); no more exotic sequence appears.

## 3. Counterexample hunt: does the harmonic model predict `k = 3` from `k = 2`?

The model is *rigid*: a single positive-width read determines the whole profile
(`retention_profile_determined`). Fitting `gain/base` to each measured `k = 2`
retention and predicting `k = 3`:

| seed | measured `k=2` | predicted `k=3` | measured `k=3` | error |
|------|----------------|-----------------|----------------|-------|
| 13   | 0.7544         | 0.6719          | 0.7041         | +0.032 |
| 14   | 0.9141         | 0.8765          | 0.9014         | +0.025 |
| 15   | 0.8037         | 0.7319          | 0.7104         | −0.022 |
| 17   | 0.9067         | 0.8663          | 0.7437         | **−0.123** |

**Reported honestly: the one-parameter harmonic law is a good first-order fit on
three of the four dependent seeds and clearly fails on `s = 17`.** So the
prediction `retention_profile_determined` is *falsifiable and partially
falsified* by the round's own numbers; `s = 17` needs a width-dependent gain
(or a second boundary channel switching on at `k = 3`). This is recorded as
Conjecture C3 of `FUTURE_DIRECTIONS.md`. No claim in the Lean files depends on
the fit being good: the Lean theorems state what the model *implies*, and the
table above is the experimental test of that implication.

## 4. Capacity computations for the arithmetic (CRT) layer

Fermat numbers `F i = 2^(2^i) + 1` (OEIS **A000215**), the pairwise coprime
family used to realise a `k`-dimensional exclusive block at every width:

```
F 0..4          : 3, 5, 17, 257, 65537
capacity (k = 3): 3 · 5 · 17    = 255      ≥ 2^3 = 8
capacity (k = 4): 3 · 5 · 17 · 257 = 65535 ≥ 2^4 = 16
```

Single-drop capacities at `k = 3` are `3·5 = 15`, `3·17 = 51`, `5·17 = 85`, all
`≥ 2^2 = 4`, matching `two_pow_card_sub_one_le_prod_erase`.

**Counterexample found (and kept):** the bound `A ≤ 2^(k-1)` in
`single_drop_resolves` cannot be dropped. With the block `(2, 3, 5)` and range
`A = 30 = 2·3·5` the intact block resolves, but after dropping the modulus `5`
the answers `0` and `6` become indistinguishable. This is theorem
`single_drop_can_break_without_margin`, and it is the formal counterpart of the
round's per-instance verification caveat: "≥ 3 exclusive dims" buys single-drop
redundancy only relative to the answer range.

## 5. Pattern search over the ablation battery

For a uniform block of width `k` and coordinate size `a > 0` the four survival
thresholds are

```
ctl : thr ≤ k·a     zero1 : thr ≤ (k-1)·a     flip1 : thr ≤ (k-2)·a     zeroN : thr ≤ 0
```

Enumerating `k = 1, 2, 3, 4` shows the flip threshold coincides with the `zeroN`
threshold **exactly when `k = 2`**, which is the computational discovery behind
`flip_iff_selfSufficient_at_width_two` (flip is an exact dependence marker at
`k = 2`) and `flip1_noop_of_width_three` (flip is uninformative at `k = 3`).
The thresholds are decreasing in severity for every `k ≥ 2`, which is
`ablation_severity_chain`.
