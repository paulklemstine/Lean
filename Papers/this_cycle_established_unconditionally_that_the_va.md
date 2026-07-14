# Computational Evidence — Cubic Rayleigh quotient of the (weighted) swap path

All values below are for the position statistic `i ↦ i` on the length-`n` path
with unit conductance `c = 1`. The closed forms proved in
`ChordSwapUniversality.lean` are:

- Dirichlet energy: `dir = 2c(n−1)`
- Variation: `vr = n²(n²−1)/6`
- Rayleigh quotient: `RQ = 12c / (n²(n+1))`
- Window: `6c·n^{-3} ≤ RQ ≤ 12c·n^{-3}`

## Small-case table (c = 1)

| n | energy `2(n−1)` | variation `n²(n²−1)/6` | `RQ = 12/(n²(n+1))` | `6/n³` | `12/n³` |
|---|-----------------|------------------------|---------------------|--------|---------|
| 2 | 2  | 2      | 1.0000 | 0.7500 | 1.5000 |
| 3 | 4  | 12     | 0.3333 | 0.2222 | 0.4444 |
| 4 | 6  | 40     | 0.1500 | 0.0938 | 0.1875 |
| 5 | 8  | 100    | 0.0800 | 0.0480 | 0.0960 |
| 6 | 10 | 210    | 0.0476 | 0.0278 | 0.0556 |
| 10| 18 | 1650   | 0.0109 | 0.0060 | 0.0120 |

Every `RQ` value lies inside its window `[6/n³, 12/n³]`, confirming
`RQ = Θ(n^{-3})`. The energy column grows linearly, the variation column grows
quartically, and their ratio contracts cubically — the difference of growth rates
`4 − 1 = 3`.

## Conductance scaling (Conjecture 3 / genus-through-the-constant)

At fixed `n = 5`, the quotient is exactly proportional to the conductance `c`:

| c   | `RQ = 12c/150` |
|-----|----------------|
| 0.0 | 0.0000 |
| 0.5 | 0.0400 |
| 1.0 | 0.0800 |
| 2.0 | 0.1600 |

The exponent is untouched; only the linear prefactor moves. At `c = 0` the chain
disconnects and `RQ = 0`, which is the boundary case recorded in the formal file.

## Sequence note

The variation values `2, 12, 40, 100, 210, …` follow `n²(n²−1)/6`, matching OEIS
A002415 (`n²(n²−1)/6`, "4-dimensional pyramidal numbers"), which is the standard
second-moment sum underlying the quartic variance of a monotone unit-step
statistic.

## Counterexample hunt

The universality claim (`gap ≤ (c_e/c_v)·n^{-3}` from energy `≤ c_e·n` and
variation `≥ c_v·n⁴`) was tested against the weighted path across `c ∈ {0,½,1,2}`
and `n ∈ {2,…,10}`; no violation was found, and the sharpness prediction
(exponent `= 1 − β` for variance exponent `β`) is consistent with the table above
(`β = 4` gives exponent `−3`). No counterexample to the monotonicity of the
leading constant in `c` was found: `RQ` is strictly increasing in `c` for every
tested `n ≥ 2`, matching `wpath_RQ_strictMono_cond`.
