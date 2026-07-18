# Computational Evidence

## Small-case calculations

Two exact shell models were evaluated.

| shell index | Coulomb degeneracy `2n²` | Coulomb cumulative filling |
|---:|---:|---:|
| 1 | 2 | 2 |
| 2 | 8 | 10 |
| 3 | 18 | 28 |
| 4 | 32 | 60 |
| 5 | 50 | 110 |

| oscillator level `N` | degeneracy `(N+1)(N+2)` | cumulative filling |
|---:|---:|---:|
| 0 | 2 | 2 |
| 1 | 6 | 8 |
| 2 | 12 | 20 |
| 3 | 20 | 40 |
| 4 | 30 | 70 |
| 5 | 42 | 112 |

These values are also instantiated directly in the accompanying theorem file.

## Sequence comparison

The Coulomb cumulative sequence begins `2, 10, 28, 60, 110`; the oscillator sequence begins `2, 8, 20, 40, 70, 112`. The relevant empirical comparison sequences are noble-gas atomic numbers `2, 10, 18, 36, 54, 86, 118` and standard nuclear magic numbers `2, 8, 20, 28, 50, 82, 126`.

No OEIS identifier is asserted here: the polynomial sequences are derived directly from their displayed formulas, and an unverified database match would add no evidential value.

## Counterexample hunt

The naive Coulomb-shell interpretation agrees with noble gases at `2` and `10` but fails at the third closure, predicting `28` instead of `18`. The bare oscillator agrees with nuclear magic numbers at `2`, `8`, and `20` but fails at the fourth closure, predicting `40` instead of `28`. Thus both universal identification claims have immediate counterexamples.

The stronger proposal `Z = round(E/E₀)` was not numerically fitted because no isotope selection rule, energy convention, or value of `E₀` was specified. Without those choices the claim is not a determinate computation.

## Interpretation boundary

The calculations support a restricted statement: shell closures are cumulative spectral multiplicities. They do not support the claim that every element is an energy eigenvalue, that the Hilbert-space dimension equals the number of stable isotopes, or that one fixed energy scale recovers atomic number.
