# Computational evidence — sharpness of `shell_thickness_le`

Setting: `B(0,R) ⊆ ℝ^d` is peeled into `N` equal-volume shells; the outermost
sphere has radius `shellRadius R d N 1 = R (1 - 1/N)^{1/d}`, so the outermost
shell has thickness

```
T(d,N) = R (1 - (1 - 1/N)^{1/d}).
```

The previous cycle proved `T(d,N) ≤ R / (d (N-1))` (`shell_thickness_le`).
This cycle asks how sharp that is.

## 1. Small-case table (R = 1)

Values of `T`, of the previous upper bound `U = 1/(d(N-1))` and of the
conjectured lower bound `L = 1/(dN) = U · (1 - 1/N)`:

| d | N | T = 1-(1-1/N)^(1/d) | L = 1/(dN) | U = 1/(d(N-1)) | T/U |
|---|---|---------------------|------------|----------------|-----|
| 1 | 2 | 0.500000 | 0.500000 | 1.000000 | 0.500 |
| 2 | 2 | 0.292893 | 0.250000 | 0.500000 | 0.586 |
| 10 | 2 | 0.066967 | 0.050000 | 0.100000 | 0.670 |
| 100 | 2 | 0.006908 | 0.005000 | 0.010000 | 0.691 |
| 10 | 5 | 0.021926 | 0.020000 | 0.025000 | 0.877 |
| 10 | 100 | 0.001004 | 0.001000 | 0.0010101 | 0.994 |
| 100 | 100 | 0.000100 | 0.000100 | 0.000101 | 0.995 |

Observations, all confirmed by the table:

* `L ≤ T ≤ U` in every case, with **equality `T = L` exactly at `d = 1`**
  (`1 - (1-1/N) = 1/N`), so the lower bound cannot be improved by a constant.
* `T/U → 1` as `N → ∞`, uniformly in `d`: the upper bound is tight up to the
  factor `1 - 1/N`, which is the statement formalised as
  `shell_thickness_le_sharp`.
* `d·T` is increasing in `d` and converges: for `N = 2`,
  `d·T = 0.5, 0.586, 0.670, 0.691, …` → `log 2 = 0.6931…`.
  For `N = 5`: `10·T = 0.21926…` → `log(5/4) = 0.22314…`.
  This is the content of `shell_thickness_asymptotics`:
  `d·T(d,N) → R log(N/(N-1))`.
* Since `1/N ≤ d·T ≤ 1/(N-1)` for every `d`, the limit yields the classical
  sandwich `1/N ≤ log(N/(N-1)) ≤ 1/(N-1)` — a purely analytic inequality
  obtained here as a *consequence* of the geometry
  (`log_ratio_sandwich_of_shell`).

## 2. Exponential profile

Peeling a shell of thickness `R·u/d` off `B(0,R)` leaves the volume fraction
`(1 - u/d)^d`. Numerically for `u = 1`:

| d | (1-1/d)^d | e^(-1) |
|---|-----------|--------|
| 2 | 0.250000 | 0.367879 |
| 10 | 0.348678 | 0.367879 |
| 100 | 0.366032 | 0.367879 |
| 1000 | 0.367695 | 0.367879 |

so the removed fraction converges to `1 - e^{-u}`; this is
`peel_volume_fraction_tendsto` / `peel_removed_fraction_tendsto`, the
"exponential profile after rescaling by `d`".

Dually, at fixed `d` the exact profile is *already* exponential in the
rescaled parameter `t(d,N,k) = -log(1 - k/N)/d`:
`R - shellRadius R d N k = R (1 - e^{-t})` exactly
(`shell_thickness_exp_profile`), with no limit at all; the limit statements
above just identify the scale on which `t` stays of order 1.

## 3. Counterexample hunt

A sweep of `1 ≤ d ≤ 200`, `2 ≤ N ≤ 200` (floating point) found no violation of
`1/(dN) ≤ 1-(1-1/N)^{1/d} ≤ 1/(d(N-1))`, and the extreme cases of the ratio
`T/U` were exactly the boundary `d = 1, N = 2` (`T/U = 1/2`) and `N` large
(`T/U → 1`). No counterexample to the conjectured lower bound was found; the
Lean proofs below make the sweep unnecessary.

*(The floating-point figures above are exploratory only; the inequalities and
limits they suggest are what is proved, without `sorry`, in
`Catalog/Shared/ShellThicknessSharp.lean`.)*

## 4. Cycles 4–5 data: monotonicity, optimal constant, rate

`R = 1`, `N = 2`, `Λ = log 2 = 0.693147`:

| d | d·thickness | Λ − d·thickness | proved bound Λ²/(d+Λ) | catalog constant 1/(N−1) |
|---|-------------|------------------|------------------------|--------------------------|
| 1 | 0.500000 | 0.193147 | 0.283 | 1 |
| 2 | 0.585786 | 0.107361 | 0.178 | 1 |
| 10 | 0.669670 | 0.023477 | 0.04496 | 1 |
| 100 | 0.690750 | 0.002397 | 0.004774 | 1 |

`d·thickness` is increasing (evidence for `shell_thickness_rescaled_monotone`),
stays below `Λ` (`shell_thickness_le_log`), and the gap is bounded by
`Λ²/(d+Λ)` (`shell_thickness_rate`) with the observed gap about half of it —
the source of the second-order conjecture in `FUTURE_DIRECTIONS.md`.

Dichotomy (`N = 2`): outer thickness `1 − 2^{−1/d}` is `0.0670 (d=10)`,
`0.00691 (d=100)` → 0; innermost radius `2^{−1/d}` is `0.933 (d=10)`,
`0.9931 (d=100)` → 1.
