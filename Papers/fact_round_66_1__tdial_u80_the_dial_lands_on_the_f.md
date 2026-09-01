# Computational evidence — TDIAL-U80 (round-66 #1, exp 534)

All numbers below were used to *design* the theorems.  Each row is marked

* **[Lean]** — the claim is discharged by a `sorry`-free theorem in
  `Catalog/Applications/TDialU80FloorResolution.lean` or
  `Catalog/Applications/TDialU80RapidityCanonicity.lean`;
* **[expl]** — exploratory decimal arithmetic only, *not* machine-verified; it is reported
  here for transparency and is never used as a premise of a theorem.

## 1. The record

```
seed      20261180  20261181  20261182   pooled     CI              band
rho_T     0.562     0.551     0.582      0.565      [0.542,0.587]   [0.55,0.85]
margin    +0.012    +0.001    +0.032     +0.015
```
H2 count parity: pooled advantage `+0.053`, CI `[0.030, 0.083]`, so the popcount baseline
reads `0.512`.

**[Lean]** `u80_inside_band`, `u80_pooled_is_seed_mean` (pooled equals the seed mean to
`10⁻⁴`: mean `= 1.695/3 = 0.565`).

## 2. Is the reported interval rapidity-symmetric?

For a rapidity half-width parameter `t` the two arms about `r` are

```
upper arm  U(r,t) = t(1-r²)/(1+rt)      lower arm  L(r,t) = t(1-r²)/(1-rt)
```

Scan at `r = 0.565` (all **[expl]**):

| `t`   | `U`      | `L`      | lower endpoint | upper endpoint |
|-------|----------|----------|----------------|----------------|
| 0.030 | 0.020072 | 0.020760 | 0.544240       | 0.585072       |
| 0.032 | 0.021398 | 0.022179 | 0.542821       | 0.586398       |
| 0.033 | 0.022054 | 0.022893 | 0.542107       | 0.587054       |
| 0.034 | 0.022707 | 0.023598 | 0.541402       | 0.587707       |

`t = 0.033` reproduces the reported `[0.542, 0.587]` exactly after rounding to three
decimals; the arms differ (`L/U = 1.038`), matching the reported asymmetry
`0.023 / 0.022 = 1.045`.

**[Lean]** `u80_ci_is_rapidity_symmetric` (both endpoints within `6·10⁻⁴`),
`u80_ci_arms_unequal`, `u80_ci_dips_below_floor`, and the general laws `ci_width_eq`,
`arm_gap_eq`, `lower_arm_longer`.

## 3. Effective sample size and resolution cost

With `z = 1.96` and `n = 3 + (z/artanh t)²`:

| quantity                                | rapidity margin | `n` (decimal) | **[Lean]** bound |
|-----------------------------------------|-----------------|---------------|------------------|
| budget implied by `t = 0.033`            | `0.03247–0.03356` | `3413–3646` | `3400 ≤ n ≤ 3650` |
| pooled `0.565` over floor `0.55`         | `≈ 0.02176`     | `≈ 7937`      | `≥ 7900`         |
| seed `0.562` over floor                  | `≈ 0.01752`     | `≈ 12514`     | `≥ 12500`        |
| seed `0.551` over floor                  | `≈ 0.0014358`   | `≈ 1.864·10⁶` | `≥ 1.8·10⁶`      |
| seed `0.582` over floor                  | `≈ 0.04823`     | `≈ 1655`      | `≥ 1650`         |
| crossing test at predicted `0.545`       | `≈ 0.00717`     | `≈ 74817`     | `≥ 74000`        |
| crossing test at predicted `0.543`       | `≈ 0.00999`     | `≈ 38480`     | `≥ 38000`        |

The per-seed budget is `≤ 1216`, below every per-seed requirement.

**[Lean]** `u80_effective_sample_size`, `u80_pooled_requires_7900`,
`u80_pooled_undersampled`, `u80_seed_181_resolution_cost`, `u80_no_seed_certifies_floor`,
`u84_crossing_test_cost`, `u84_test_infeasible_at_current_budget`.

## 4. The rapidity ladder and the crossing

```
bitlen b :  44      72      80      | floor
rho      :  0.78    0.605   0.565   | 0.55
artanh   :  1.0454  0.7011  0.6402  | 0.6184
```
Linear fit through `(72, 0.7011)` and `(80, 0.6402)`: slope `−0.007613` per bitlen.

* crossing of `0.6184`: `b* = 82.86` **[expl]**, certified as `b* ∈ (82,83)` **[Lean]**
  (`u80_crossing_before_84`), which is exactly `(2889/2449)^4 > (27927/24727)^5` and
  `(2889/2449)^8 < (27927/24727)^11`;
* predicted bitlen-84 rapidity `0.6095`, i.e. `rho ≈ 0.5436` **[expl]**, certified as
  `rho(84) ∈ (0.543, 0.545)` **[Lean]** (`u80_model_84_window`), which is exactly
  `(1543/457)²·(321/79) < (313/87)³ < (309/91)²·(321/79)`.

## 5. Count parity in rapidity

`artanh 0.565 − artanh 0.512 ≈ 0.0745…0.0776` versus the raw `0.053`, an inflation of
`≈ 41%`; at bitlen 44 the same quantity is `artanh 0.78 − artanh 0.71 ≈ 0.1582`.

**[Lean]** `u80_parity_advantage_rapidity` (`≥ 0.0745`), `parity_advantage_still_fades`
(`bitlen-44 advantage > 1.8 × U80 advantage`, in rapidity).

## 6. Counterexample hunt

Two claims were tested for failure before being formalised.

* *"A Fisher interval is symmetric in correlation coordinates."*  **False**, and provably
  so at every positive reading: `lower_arm_longer`.  The record's "every CI dips below
  0.55 at its lower end" is therefore forced geometry.
* *"`artanh x ≥ x` follows from `log t ≤ t − 1`."*  **False** — every first-order bound
  obtainable that way (`x(2±x)/(2(1±x))`, `x/(1−x)`, `2(1−1/√A)`) fails, because the gap
  `artanh x − x = x³/3 + …` is cubic.  A derivative argument is needed, and is what
  `self_le_artanh` does.

## 7. OEIS

No integer sequence arises: the objects here are rational and real-analytic
(rapidity margins, sample-size costs).  No OEIS lookup was applicable.
