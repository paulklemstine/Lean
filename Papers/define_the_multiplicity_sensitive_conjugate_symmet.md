# Computational Evidence — Reciprocal-Zero Harmonics (cycle 1)

All numbers below were produced by `#eval` inside Lean 4 (`Float` for the analytic data,
exact `ℚ` for the arithmetic data).  They are *evidence*, not proofs; every claim that is
asserted as a theorem in `Catalog/Algebra/ReciprocalZeroHarmonics/` is proved there without
`sorry`, and the numerics below are only used to select the hypotheses and to falsify naive
conjectures.

## 1. The conjugate-paired harmonic sum converges

Input: the first 20 ordinates `γ_n` of the nontrivial zeros of `ζ` (standard tables,
`14.134725, 21.022040, 25.010858, …, 77.144840`).

Partial sums of the renormalised (conjugate-paired) series `Σ_{n<N} 1/(1/4 + γ_n²)`
(this is `Re H(T)` for the corresponding cutoff, by `harmonicSum_pairedOrdinates`):

| N | 1 | 2 | 3 | 5 | 10 | 15 | 20 |
|---|---|---|---|---|----|----|----|
| partial sum | 0.004999 | 0.007261 | 0.008859 | 0.010860 | 0.013535 | 0.014995 | 0.015959 |

The sequence is increasing and slowly approaching the classical value
`Σ_ρ 1/ρ = 1 + γ/2 − log(2√π) ≈ 0.0230957`; the residual `≈ 0.007` at `N = 20` is consistent
with a tail of size `O(log T / T)` at `T ≈ 77`.  This is the behaviour predicted by
`summable_renormalized_of_rvm` and `tail_bound_of_separated`.

By contrast the **unpaired** sum `Σ_{n<20} 1/γ_n = 0.491152` keeps growing like `log²`, matching
`not_summable_unpaired`: absolute convergence genuinely fails without conjugate pairing.

## 2. Calibrating the Riemann–von Mangoldt hypothesis

The hypothesis used in `summable_renormalized_of_rvm` is `γ_n ≥ a·(n+1)/log(n+2)`.  The observed
values of `γ_n · log(n+2)/(n+1)` for `n < 20` are

```
9.797, 11.548, 11.557, 12.242, 11.802, 12.190, 12.155, 11.900, 12.282, 11.935,
11.966, 12.065, 12.048, 11.767, 12.035, 11.878, 11.824, 11.789, 11.936, 11.743
```

so the hypothesis holds on this range with `a ≈ 9.79` and appears to stabilise near `2π ≈ 6.28`
times a slowly varying factor, as the Riemann–von Mangoldt formula predicts.

The stronger *separation* hypothesis `γ_n ≥ a·(n+1)` used for the explicit error term
`Σ_{n ≥ N} 1/(1/4+γ_n²) ≤ 1/(a²N)` requires `a ≤ min_n γ_n/(n+1)`; the observed ratios decrease
from `14.13` to `3.857` over the first 20 zeros, so the separation hypothesis is *not* valid
globally — which is exactly why the two theorems are stated separately, the sharp error term only
under separation and mere convergence under the (weaker, globally correct) RvM bound.

## 3. Counterexample hunt: prime chords

`primeChord n = Σ_{p^k ‖ n} k/p` computed exactly over `ℚ`.  Searching all pairs `2 ≤ n < m < 200`
for collisions `primeChord n = primeChord m` gives

```
(4, 27), (8, 54), (12, 81), (16, 108), (20, 135), (24, 162), (28, 189)
```

i.e. exactly the pairs `(4k, 27k)`.  The primitive collision is `primeChord 4 = 2/2 = 1 = 3/3 =
primeChord 27`; all others follow from complete additivity.  This is proved as
`primeChord_not_injective`, and additivity as `primeChord_mul`.

No collision occurs between two primes (consistent with `primeChord_prime_injective`), so the
statistic does distinguish the first hundred primes while failing to distinguish integers —
the sharp answer to Direction 5 of the previous cycle.

## 4. Sanity check of the Vieta identity

For `P = X² − 2` one has `−P'(0)/P(0) = −0/(−2) = 0`, and indeed `1/√2 + 1/(−√2) = 0`.  For
`P = X² − 3X + 2 = (X−1)(X−2)`: `−P'(0)/P(0) = 3/2 = 1/1 + 1/2`.  For `P = X³ − 6X² + 11X − 6`
(roots `1,2,3`): `−P'(0)/P(0) = −11/(−6) = 11/6 = 1 + 1/2 + 1/3`.  These agree with
`harmonicSum_roots_rat`.
