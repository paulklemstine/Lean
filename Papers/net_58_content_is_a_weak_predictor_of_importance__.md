# Computational evidence — NET-58 (CONTENT-IS-A-WEAK-PREDICTOR-OF-IMPORTANCE)

All numbers below were computed before the corresponding Lean statements were written, and each
one is now backed by a machine-checked theorem in `Catalog/Novelty/NET58*.lean` (the Lean name
is given in brackets).  Nothing in this file is used as a proof; it is the exploration record.

## 1. The measured table (input, paper 143)

| `B` | accumulated-HH (NET-56) | static probe | oracle |
|-----|-------------------------|--------------|--------|
| 32  | 0.8633                  | 0.8395       | 0.9913 |
| 64  | 0.8822                  | 0.8938       | 0.9953 |
| 128 | 0.9189                  | 0.9284       | —      |

Per-`(layer, kv-head)` probe `R²`: mean `0.329`, min `0.113`, max `0.639`.

## 2. Closure fractions

`closure = (probe - accumulation) / (oracle - accumulation)`

| `B` | closure    | verdict |
|-----|------------|---------|
| 32  | `-0.18594` | probe is **worse** than the baseline [`net58_probe_hurts_at_B32`] |
| 64  | `+0.10256` | `10.26 % < 33 %` — **P1 refuted** [`net58_P1_refuted`] |

Remaining oracle gap: `0.9913 - 0.8395 = 0.1518` at `B = 32`, `0.9953 - 0.8938 = 0.1015` at
`B = 64` — **P2 confirmed** [`net58_P2_confirmed`].

## 3. Counterexample hunt: is prediction accuracy the cause?

Searched small instances for a monotone relation between `R²` and retained mass.  None exists:
`Novelty.ProbeRetentionLimits.exists_probe_perfect_retention_with_Rsq` (prior round) already
exhibits, for *every* target `R²`, a probe that reproduces the oracle exactly.  So the size of
`1 - R² = 0.671` cannot by itself explain the 10-point deficit.  This redirected the search
towards a *structural* explanation and produced the relational ceiling.

## 4. The two-context swap witness (verified numerically, then proved parametrically)

Contexts `w ∈ {0,1}`, key contents `i ∈ {0,1}`, importances

```
a[0] = (u, v)      a[1] = (v, u)        u > v
```

Budget `B = 1`.  Averaged importance profile is `((u+v)/2, (u+v)/2)`; both singletons are top
sets; every static policy retains `(u+v)/2`; the per-context oracle retains `u`.

| `u`  | `v`  | static | oracle | deficit |
|------|------|--------|--------|---------|
| 1.0  | 0.0  | 0.5    | 1.0    | 0.5     |
| 0.9  | 0.4  | 0.65   | 0.9    | 0.25    |
| 0.99 | 0.98 | 0.985  | 0.99   | 0.005   |

Deficit `= (u-v)/2` exactly, and `> 0` iff `u > v` [`swap_relational_deficit`,
`swap_adaptive_beats_every_static`].

## 5. Budget-crossing instance (integer search over 4-key profiles)

```
v      = (5, 1, 9, 0)      true future attention
acc    = (4, 3, 2, 1)      accumulation-like ranking  0 > 1 > 2 > 3
probe  = (2, 4, 3, 1)      static probe ranking       1 > 2 > 0 > 3
```

| budget | accumulation set | retained | probe set | retained | winner |
|--------|------------------|----------|-----------|----------|--------|
| 1      | `{0}`            | 5        | `{1}`     | 1        | accumulation |
| 2      | `{0,1}`          | 6        | `{1,2}`   | 10       | probe |
| oracle @2 | `{0,2}`       | 14       |           |          | — |

This reproduces the measured sign flip between `B = 32` and `B = 64`
[`net58_no_uniform_budget_ordering`, `crossing_below_oracle`].

*Negative result recorded:* no 4-key (indeed no single-window) instance can reproduce the
measured retained **levels**, because two policies each retaining ≈ 0.86 of a unit mass on
disjoint singletons is impossible (`0.8633 + 0.8395 > 1`).  The measured levels are therefore
handled as arithmetic over the reported averages, and the instance certifies only the
phenomenon.  This is why `net58_P1_refuted` is stated over the reported numbers rather than
extracted from a synthetic instance.

## 6. Depth structure (P3): does `R²` heterogeneity help or hurt the guarantee?

With residual variances `x = 1 - 0.639 = 0.361` and `y = 1 - 0.113 = 0.887`:

```
√x + √y            = 0.60083 + 0.94181 = 1.54264
2 √((x+y)/2)       = 2 √0.624          = 1.57987
```

so heterogeneity **strictly lowers** the aggregate worst-case bound (`1.5426 < 1.5799`), by
strict concavity of `√` [`net58_depth_structure_strict`,
`heterogeneity_strictly_improves_bound`].  Reporting only the mean `R² = 0.329` therefore
*understates* the probe slightly; it does not rescue it.

## 7. Dimension count

Context length `n = 1024`, key dimension `d = 64`.  An affine probe reads `d + 1 = 65` linear
functionals of the importance profile, so the invisible subspace has dimension at least
`1024 - 65 = 959` (`93.7 %` of directions), and the visible fraction is `65/1024 = 0.0635`
[`net58_blind_dimension_1024_64`, `net58_visible_fraction_small`].

Sanity check of the direction of the argument: the measured `R² = 0.329 ≫ 0.0635`, so the actual
importance profile is *far* from a random direction — the probe is genuinely informative, and
the eviction failure is still structural.  Both facts are consistent, which is the point of
`exists_importance_linear_blind`: it is a statement about the class, not about the fitted probe.

## 8. Capstone check: deficit versus dispersion

On the swap witness with `B = 1`, `|W| = 2`, dispersion `∑_w ‖a_w - ā‖² = (u-v)²`:

| `u`  | `v`  | true deficit | bound `√(B·disp/|W|)` | ratio |
|------|------|--------------|-----------------------|-------|
| 1.0  | 0.0  | 0.5          | 0.70711               | 0.7071 |
| 0.9  | 0.4  | 0.25         | 0.35355               | 0.7071 |
| 0.99 | 0.98 | 0.005        | 0.00707               | 0.7071 |

The ratio is exactly `√2/2`, independently of `u, v` [`swap_deficit_ratio`], so the general bound
`deficit ≤ √(B · dispersion / |W|)` [`deficit_le_sqrt_dispersion`] has the right shape and a
constant that is loose by exactly `√2` on this family.

## 9. OEIS

No integer sequence arises in this round; the objects are real-valued retention curves and
subspace dimensions.  No OEIS lookup was applicable.
