# Computational Evidence — T-DIAL-56 tie-block ceiling (paper 178, exp 511)

All figures below were computed exactly (integer/rational arithmetic where
possible) before the Lean formalisation, and every inequality that is *used* in
the argument is re-proved in Lean by `norm_num` / `nlinarith`, not by these
scripts.  Nothing here is load-bearing on its own.

## 1. Small-case check of the discrete spread bound

Claim (`TieCeiling.spread_ge_of_injOn`): among all sets of `m` **distinct
integers**, the sum of squared deviations from the mean is minimised by `m`
consecutive integers, with value `(m³ − m)/12`.

Exhaustive search over all `m`-subsets of `{0,…,3m−1}`:

| m | brute-force minimum | `(m³ − m)/12` |
|---|---------------------|---------------|
| 1 | 0.0                 | 0.0           |
| 2 | 0.5                 | 0.5           |
| 3 | 2.0                 | 2.0           |
| 4 | 5.0                 | 5.0           |
| 5 | 10.0                | 10.0          |
| 6 | 17.5                | 17.5          |

Exact match in every case; no counterexample.  The sequence of numerators
`0, 6, 24, 60, 120, 210, …` of `(m³ − m)` is `m(m−1)(m+1)`, i.e. six times the
tetrahedral-like sequence **OEIS A007531** (`n(n−1)(n−2)`) shifted by one; the
variance values `(m³−m)/12` are the classical Spearman tie-correction terms.

## 2. The reported experiment: `n = 1200`, `m = 194` zero-hit moduli

```
ceiling on ρ²  = 1 − (194³ − 194)/(1200³ − 1200)
               = 1 − 7 301 190 / 1 727 998 800
               = 0.995774771371369…
ceiling on ρ   = 0.9978851493891314…
```

Target band lower edge is `0.55`, i.e. `ρ² = 0.3025`.  The ceiling is `0.9958`,
**three times the band edge**.  The reported `Spearman = 0.405` (`ρ² = 0.164`)
sits far below the ceiling, so the zero-hit tie block does not explain it.

## 3. Counterexample hunt: how much starvation *would* be needed?

Smallest `m` with `1 − (m³−m)/(1200³−1200) ≤ 0.3025`:

```
m = 1065   →  ρ² ceiling = 0.30096      m/n = 0.8875
m = 1064   →  ρ² ceiling = 0.30375      (still above the band edge)
```

So the tie mechanism becomes binding only at **88.75 % starvation**.  The Lean
statement `starvation_fraction_lower_bound` proves the (slightly conservative,
uniform in `n ≥ 10`) bound `m ≥ 0.88 n`, consistent with this exact value.
Observed starvation at bit length 56 is `194/1200 = 16.17 %`.

## 4. The quantization ceiling for coarse rate grids (`n = 1200`)

`1 − (n³/r² − n)/(n³ − n)` for `r` distinct measured rate values:

| r | ρ² ceiling | ρ ceiling |
|---|-----------|-----------|
| 2 | 0.750000  | 0.8660    |
| 3 | 0.888890  | 0.9428    |
| 4 | 0.937501  | 0.9683    |
| 5 | 0.960001  | 0.9798    |
| 6 | 0.972223  | 0.9860    |
| 8 | 0.984376  | 0.9922    |

Even a *binary* rate readout (`r = 2`) caps `ρ` only at `0.866`.  No `r ≥ 2`
brings the ceiling near `0.405`.  This is `quantization_ceiling_not_binding`.

## 5. The noise budget that remains

Rank-vector variance at `n = 1200`:

```
V = (1200³ − 1200)/12 = 143 999 900
```

Drop from the band edge `0.55` to the observed `0.405` is `Δρ = 0.145`, so the
required rank-displacement energy is

```
Δρ² · V = 0.021025 · 143 999 900 = 3 027 597.9
RMS displacement = sqrt(3 027 598 / 1200) ≈ 50.2 rank positions.
```

The Lean corollary `exp511_displacement_energy_ge` proves the (rounded-down)
bound `≥ 3 000 000`.  Interpretation: the Monte-Carlo error of the rate estimate
must move a typical modulus by about **50 of the 1200 rank positions** — about
`4 %` of the sample — for the observed collapse to be attributable to
measurement noise.  That is the falsifiable replacement for the tie hypothesis.
