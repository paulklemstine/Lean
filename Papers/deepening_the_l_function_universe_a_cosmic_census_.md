# Computational Evidence

The claims here are structural (rigidity, injectivity, countability), so the relevant
"evidence" is a sanity check that the objects behave as asserted on small cases.

## 1. Monomial L-functions are distinct

`spike k` has coefficient `1` at position `k+1` and `0` elsewhere, so
`LSeries (spike k) (s) = (k+1)⁻ˢ`.

| k | nonzero coefficient position | L-function |
|---|------------------------------|------------|
| 0 | 1 | `1⁻ˢ ≡ 1` |
| 1 | 2 | `2⁻ˢ` |
| 2 | 3 | `3⁻ˢ` |

These are visibly distinct functions of `s` (e.g. evaluate at `s = 1`: values
`1, 1/2, 1/3, …`), confirming `spikeLSeries_injective` and hence
`analytic_universe_infinite`.

## 2. Dirichlet characters per modulus (exactness)

The number of Dirichlet characters mod `N` equals Euler's totient `φ(N)`:

| N | φ(N) | # distinct analytic L-functions (via `charCensusEquiv`) |
|---|------|---------------------------------------------------------|
| 1 | 1 | 1 (this is ζ, i.e. the trivial character) |
| 2 | 1 | 1 |
| 3 | 2 | 2 |
| 4 | 2 | 2 |
| 5 | 4 | 4 |

`charCensusEquiv` establishes a bijection between characters and their L-functions,
so the right-hand column equals `φ(N)`; per-modulus finiteness is
`charLSeries_finite_fixedMod`.

## 3. Zeta rigidity

`zetaCoeff n = 1` for `n ≥ 1`, `0` for `n = 0`, giving `∑ n⁻ˢ = ζ(s)`. Any other
normalized convergent coefficient sequence producing the same function must equal
`zetaCoeff` (`zeta_rigidity`) — there is no alternative Dirichlet-series
representation. This matches the classical uniqueness of Dirichlet-series expansions.

No counterexamples were found; all small cases are consistent with the formalized
theorems, each of which is proved unconditionally in `AnalyticCensus.lean`.
