# Computational evidence — NET-30 exclusive-channel saturation

All numbers below are derived from the published NET-30 tables in the mission
brief (Part A, k = 2, E = 22, seeds 8–13; Part B, k = 1, E = 21, seeds 8–13).
No new network was trained here; the arithmetic below is what the Lean
theorems in `Catalog/NumberTheory/ExclusiveChannel*.lean` are stated about.

## 1. The redundancy defect of every Part A arm

For a one-dimensional read-out along the block ray, write

* block drop `D = ctl − zeroAll`,
* single drops `d₀ = ctl − zero1@0`, `d₁ = ctl − zero1@1`,
* **redundancy defect** `R = (d₀ + d₁) − D`.

An affine read-out has `R = 0` exactly (`dropZeroAll_eq_sum_dropZeroAt`), a
convex one has `R ≥ 0` (`redundancyDefect_nonneg_of_convex`), a concave
(saturating) one has `R ≤ 0` (`redundancyDefect_nonpos_of_concave`).

| seed | ctl | zeroAll | D | d₀ | d₁ | d₀+d₁ | **R** | flip drop | 2·d₀ |
|---|---|---|---|---|---|---|---|---|---|
| 8  | 1.0000 | 1.0000 | +0.0000 | +0.0000 | +0.0000 | +0.0000 | **+0.0000** | +0.0000 | +0.0000 |
| 9  | 0.9888 | 0.9902 | −0.0014 | +0.0025 | −0.0014 | +0.0011 | **+0.0025** | −0.0014 | +0.0050 |
| 10 | 0.9399 | 0.9453 | −0.0054 | −0.0103 | +0.0009 | −0.0094 | **−0.0040** | −0.0088 | −0.0206 |
| 11 | 1.0000 | 1.0000 | +0.0000 | +0.0000 | +0.0000 | +0.0000 | **+0.0000** | +0.0000 | +0.0000 |
| 12 | 1.0000 | 0.9995 | +0.0005 | +0.0000 | +0.0000 | +0.0000 | **−0.0005** | +0.0015 | +0.0000 |
| 13 | 0.9980 | 0.7544 | **+0.2436** | +0.0019 | −0.0010 | +0.0009 | **−0.2427** | +0.2475 | +0.0038 |

Reading: five of six arms have `|R| ≤ 0.004`, i.e. are *affine-compatible* at
the reported noise scale.  The s = 13 arm has `R = −0.2427`, roughly 60× the
largest other magnitude, and is therefore a **strict-concavity certificate**:
no convex — a fortiori no affine — read-out can produce it.  This is the
content of `s13_readout_defect_negative` / `s13_readout_not_convex` and, in
crude bound form, of `s13_k2_no_affine_readout` (an affine read-out with single
drops `≤ 0.002` caps the block drop at `2 × 0.002 = 0.004`, i.e. would need
`0.2436 / 0.002 = 122` exclusive dimensions rather than 2).

The affine **flip law** `flip drop = 2 · d₀` also fails only at s = 13
(`+0.2475` observed against `+0.0038` predicted); everywhere else the two
columns agree to `≤ 0.012`.

## 2. Part B: the k = 1 rows, in SE units

Taking the reported "~2 SE" annotations at face value fixes the effective
evaluation draw size at `n ≈ 2048` (`SE = √(p(1−p)/n)`), which reproduces the
brief's own marginal calls:

| seed | ctl | zero1 | Δ | SE | Δ/SE | brief's verdict |
|---|---|---|---|---|---|---|
| 8  | 1.0000 | 1.0000 | +0.0000 | — | — | self-sufficient cure |
| 9  | 0.7622 | 0.7432 | +0.0190 | 0.0094 | **2.02** | marginal |
| 10 | 0.1606 | 0.1592 | +0.0014 | 0.0081 | 0.17 | no-op |
| 11 | 0.8892 | 0.8901 | −0.0009 | 0.0069 | −0.13 | no-op |
| 12 | 1.0000 | 1.0000 | +0.0000 | — | — | self-sufficient cure |
| 13 | 0.2734 | 0.2510 | +0.0224 | 0.0098 | **2.27** | marginal fail |

Both "marginal" flags are single ~2 SE excursions out of twelve comparisons,
i.e. exactly what one expects by chance; nothing in this table discriminates
between models.  `k1_profile_unconstrained` proves the corresponding formal
statement: **every** pair `0 ≤ β ≤ α ≤ 1` of (ctl, zero1) accuracies is
realised inside the saturating-gate class, so no k = 1 row can support or
refute a law about internalisation.

## 3. The population model fitted to s = 13

Four difficulty groups with masses `(0.7544, 0.1523, 0.0913, 0.0020)` at gate
thresholds `(0, 0.2, 0.5, 2)` give accuracies

```
acc(0)   = 0.7544      (zeroAll, flip — gate rectified to 0)
acc(0.2) = 0.9067      (scale 0.1 — gate = 0.2)
acc(1)   = 0.9980      (ctl and both single ablations — gate saturated at 1)
```

against the published `0.7544 / 0.7505 / 0.9067 / 0.9980 / 0.9961 / 0.9990`:
four exact matches, worst residual `0.0039` (flip), all inside the reported
`0.005` no-op scale.  These three accuracy identities are *kernel-checked* in
Lean (`s13pop_acc_zero`, `s13pop_acc_fifth`, `s13pop_acc_one`), and the
six-arm comparison is `s13_k2_saturating_realization`.

## 4. The unit-gain ladder (prediction check)

For the canonical saturating channel with `k` unit-gain exclusive coordinates
and clip level 1, the surviving block gains are `k`, `k−1`, `k−2`, `0` for
`ctl`, `zero1`, `flip`, `zeroAll`.  Predicted no-op pattern:

| k | zero1 no-op? | flip no-op? | zeroAll no-op? | observed |
|---|---|---|---|---|
| 1 | no (= zeroAll) | — | no | Part B: ablation = block ablation |
| 2 | **yes** | **no** | no | s = 13: zero1 no-ops, flip −0.2475 |
| 3 | yes | **yes** | no | NET-29 k = 3: flip a no-op |

This is `saturation_ladder_k_one_two_three`, with the general iff-forms
`design_rule_two_exclusive_dims` and `design_rule_three_for_sign_robustness`.

## 5. Counterexample hunt

* Hunted for an affine/convex fit to the s = 13 row: none exists — proved
  impossible rather than merely not found (`s13_k2_no_convex_readout`).
* Hunted for a k ≤ 1 realisation of "1-redundant but block-dependent": none
  exists for *any* statistic (`two_le_of_redundant_and_block_dependent`).
* Hunted for a counterexample to the model's own prediction that larger
  exclusive coordinates are *more* self-sufficient: the measured s = 13 arms
  are exactly that counterexample at fixed clip level, which is why
  `self_sufficiency_monotone_in_gain` is stated as a conditional prediction and
  the clip-co-scaling test is promoted to a next-cycle conjecture.
* No OEIS-type integer sequence arises here; the objects are real-valued
  accuracy profiles, so an OEIS search is not applicable.
