# Computational evidence — NET-55 (THE-KNEE-IS-SIZE-INVARIANT)

All numbers below were computed in exact rational arithmetic before the corresponding
Lean statements were written; every claim that survives is proved in
`Catalog/Pythagorean/NET55*.lean` with zero `sorry`s (verified axioms:
`propext`, `Classical.choice`, `Quot.sound` only).

## 1. Exact knees of geometric attention profiles at the NET-55 gate 0.98

`retained(r, n, k) = (1 - r^k) / (1 - r^n)`; the knee is the least `k` clearing `0.98`.

| decay ratio `r` | k\*(ctx 64) | k\*(ctx 512) | k\*(ctx 1024) | proved as |
|---|---|---|---|---|
| 3/5      | 8  | 8  | 8  | `knee_three_fifths_98` |
| 39/50    | 16 | 16 | 16 | `net55_flat_knee_chain` |
| 4/5      | 18 | 18 | 18 | `knee_four_fifths_98` |
| 696/985 (Pell short leg) | 12 | 12 | 12 | `pell_short_leg_knee_eq_twelve_98` |
| 708/1000 (extremal short-leg bound) | 12 | 12 | 12 | bound in `pyth_short_leg_budget_le_twelve_98` |
| 1/100    | 1  | 1  | 1  | `knee_hundredth_98` |

Observations that shaped the formalisation:

* For every geometric profile the knee is **identical at 64, 512 and 1024**: geometric
  decay makes the knee context-flat on this grid, so the measured `{16, 16}` chain is a
  geometric-profile signature. (Exact flatness is *not* automatic in general — see
  `Shared/AttentionBudgetScaling.lean`, `exact_flatness_refuted`.)
* The pass certificate `r^K ≤ 1 - τ` never involves the context, while the fail
  certificate only becomes *easier* as `n` grows. This suggested the lemma
  `kstar_geomProfile_eq_of_small_powers`, which reduces exact knees at ctx 1024 to
  arithmetic with `r^64` — decisive, since `(696/985)^1024` is a ~3000-digit rational.
* Extremal short-leg ratio: any Pythagorean triple with `a ≤ b` has `a/c ≤ 0.708`, and
  `0.708^12 = 0.01586 ≤ 0.02 < 0.02241 = 0.708^11`, so `12` — and not `11` — is the
  universal short-leg budget at gate `0.98`. The Pell triple attains it exactly
  (`(696/985)^11 = 0.021923 > 0.02 ≥ 0.015491 = (696/985)^12`).

## 2. Counterexample hunt on the reported sweeps

Retained mass is strictly increasing in the budget below the context length
(`retained_lt_retained`). Scanning the two reported NET-55 sweeps for violations:

```
ctx  512 : 8:0.9727  16:0.9896  24:0.9915  32:0.9969  48:0.9993  64:0.9988   <- decrease at 48 -> 64
ctx 1024 : 16:0.9806 24:0.9867  32:0.9881  48:0.9928  64:0.9927  96:0.9954  128:0.9974
                                                        ^ decrease at 48 -> 64
```

Both sweeps contain exactly one decrease, both at the same grid step `48 → 64`
(`-5·10⁻⁴` and `-1·10⁻⁴`, i.e. inside the quoted `SE ≈ 0.3%`). Consequence, formalised
as `net55_sweep_512_not_retained_mass` and `net55_sweep_1024_not_retained_mass`: **no
positive attention profile has these numbers as retained masses**, so the measured
agreement ratio is a downstream, non-monotone statistic, not the retained-mass
functional itself.

The monotone prefix, by contrast, is realizable exactly
(`net55_sweep_512_prefix_realizable`), by the three-block profile of
`two_point_sweep_realizable_iff`.

## 3. Grid-floor probe at ctx 1024

The 1024 cell measured a pass at `k = 16` and nothing below it. Search over geometric
profiles for ones that pass at 16:

* `r = 39/50`: passes at 16, fails at 15 → knee `16`;
* `r = 1/100`: passes at 1 → knee `1`.

So the measurement is compatible with every knee in `[1, 16]`; formalised as
`net55_grid_floor_indeterminate`. This is why the reported `k* = 16` at 1024 must be read
as an upper bound.

## 4. Distortion probe (cycle 2)

Looking for two profiles that are comparable within a bounded factor but have different
knees, on a context of length 3 at gate `0.9`:

```
w₁ = (95, 4, 1, ...) : retained(1) = 0.95 ≥ 0.9         -> knee 1
w₂ = (85, 14, 1, ...): retained(1) = 0.85 < 0.9 ≤ 0.99  -> knee 2
comparability factor: max(95/85, 14/4) = 3.5 ≤ 4
```

Hence the `lam^2` gate shift in `kstar_le_of_comparable` cannot be removed
(`comparable_knees_can_differ`).

## 5. No OEIS sequence

The objects here are real-valued attention profiles and their knees; the integer data
that does appear (`8, 12, 16, 18` at gate `0.98`; `9, 12, 13, 14, 19` at gate `0.985`
in the NET-79 round) are gate-dependent floor values of `log(1-τ)/log r`, not a
combinatorial sequence, so no OEIS lookup applies.
