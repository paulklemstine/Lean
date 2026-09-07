# Computational evidence — D3: the nonlinear probe ceiling

All numbers below were produced with Lean `#eval` (Float arithmetic) in the project toolchain,
and every claim that is used mathematically was subsequently proved in
`Catalog/Bridges/NonlinearProbeCeiling{D3,Anova,Design}.lean` with no `sorry`.

## 1. The ceiling of the tunable pooled family

The four-observation pooled population `quadImp c d = ![c+d, c-d, -c-d, -c+d]` with content map
`quadKey = ![0,0,1,1]` (two key contents, each seen in two windows) has

* `SS_tot = 4c² + 4d²`,
* `SS_within = 4d²`,
* ANOVA ceiling `= c²/(c²+d²)`.

| `c` | `d` | ceiling `c²/(c²+d²)` | D3 verdict (`< 0.5`?) |
|-----|-----|----------------------|------------------------|
| 1.0 | 0.0 | 1.00000              | false (content determines importance) |
| 2.0 | 1.0 | 0.80000              | false |
| 1.0 | 1.0 | 0.50000              | boundary |
| 1.0 | 2.0 | 0.20000              | true |
| 0.7 | 1.0 | 0.32886              | true |
| 0.0 | 1.0 | 0.00000              | true (pure swap: content explains nothing) |

Two observations drove the formal work:

* the ceiling ranges over the whole of `[0,1)` as `(c,d)` varies, so **no theorem can establish
  the `< 0.5` claim** for an unspecified pooled population — formalised as
  `exists_pooled_population_with_ceiling` and `ceiling_can_exceed_half`;
* at `c/d = 0.7` the ceiling is `0.32886`, numerically the measured linear `R² = 0.329`.  A
  population therefore exists in which the linear probe is already *optimal among all content
  functions*; a low measured `R²` is by itself no evidence of head-room.

## 2. The "more than two thirds" clause

Capture fraction `0.329 / ceiling`:

| ceiling | `0.329 / ceiling` | `> 2/3`? |
|---------|-------------------|----------|
| 0.3500  | 0.94000           | yes |
| 0.4000  | 0.82250           | yes |
| 0.4500  | 0.73111           | yes |
| 0.4935  | 0.66667           | boundary (exactly `2/3`) |
| 0.5000  | 0.65800           | **no** |
| 0.6000  | 0.54833           | no |

The conjecture's own worst allowed case (`ceiling = 0.5`) gives `0.658 < 0.6667`.  This
counterexample hunt is the origin of `two_thirds_clause_false_at_half`, of the exact repair
`two_thirds_threshold` (`> 2/3` iff ceiling `< 0.4935`), and of the salvaged
`measured_capture_gt_65`.

## 3. The swap witness and the ANOVA identity

Two windows, two key contents, importances `a w i = 1` if `w = i` and `0.4` otherwise
(the `swapImp 1 0.4` witness of `Novelty.NET58RelationalImportance`), pooled into four
observations:

```
SS_within = 0.36,  SS_tot = 0.36,  SS_between = 0.00,  ceiling = 0.00
```

The identity `SS_tot = SS_within + SS_between` was checked here before being proved in general
(`anova_decomposition`), and the ceiling `0` matches `swap_ceiling_zero`.

## 4. Counterexample hunt against the pair certificate

The certificate `SS_tot < Σ_y (a(p y) − a(q y))²` is a *sufficient* condition for
`ceiling < 1/2`.  Searching single-content populations with `n` values alternating `±1`:

| `n` | `SS_within = SS_tot` | best single squared gap | certificate fires? |
|-----|----------------------|--------------------------|--------------------|
| 2   | 2                    | 4                        | yes (`2 < 4`) |
| 3   | 2.667                | 4                        | yes |
| 4   | 4                    | 4                        | **no** (`4 < 4` false) |
| 6   | 6                    | 4                        | no |

So from `n = 4` upwards the certificate fails although the ceiling is `0`.  The `n = 4` instance
is formalised as `pair_certificate_incomplete`; the accompanying positive result
`ssWithin_eq_half_sum_pairs` shows that with exactly two windows per content the bound is an
equality, i.e. the certificate is complete precisely in the canonical train/test design.

## 5. Where the certificate stops being complete

The natural guess — "the pair certificate is complete whenever fibers have at most three
members" — was tested before formalising and **failed**.  The relevant quantity is the ratio
`SS_within / diam²` of a fiber, which the certificate always reports as `1/2`:

| fiber pattern            | `SS_within` | `diam²` | ratio  | certificate exact? |
|--------------------------|-------------|---------|--------|--------------------|
| `(-1, 1)`                | 2           | 4       | 0.5000 | yes |
| `(-4, 2, 2)`             | 24          | 36      | 0.6667 | no (under-reports) |
| `(1, -1, 1, -1)`         | 4           | 4       | 1.0000 | no |

Because a three-point fiber can hold `2/3` of its squared diameter, a population built from
three-window contents can hide its ceiling from every pair certificate:

```
windows          : -6.5, -0.5, -0.5 | -1.5, 4.5, 4.5      (two contents, three windows each)
SS_within        : 24 + 24 = 48
SS_tot           : 85.5
ceiling          : 1 - 48/85.5 = 0.438596  (< 0.5, so D3 holds here)
best certificate : 36 + 36 = 72  <  85.5   (no pair family fires)
```

Formalised as `tri_certificate_fails`; the matching positive result
`certificate_complete_of_fibers_card_le_two` shows completeness does hold at two windows per
content, so the threshold is exactly two.

## 6. No OEIS entry

No integer sequence arises: all objects here are ratios of sums of squares of real-valued
measurements, so an OEIS search is not applicable.
