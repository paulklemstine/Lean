# Computational Evidence: Reciprocal-Zero Harmonics

## Small-cutoff calculations

The first positive ordinate of a nontrivial zero of the Riemann zeta function is approximately
`14.1347251417`. Consequently, the windows `|Im ρ| ≤ 2` and `|Im ρ| ≤ 3` contain no
nontrivial zeros. Under the proposed finite-sum definition, both corresponding sums are
therefore empty:

| cutoff `n` | zeros in the window | harmonic |
|---:|---:|---:|
| 2 | 0 | 0 |
| 3 | 0 | 0 |

Thus the proposed values `harmonic 2 = 1` and “`harmonic 3` is transcendental” are already
contradicted at the support level. The exact implications from certified empty windows are
proved in `HarmonicZeros.lean`; the decimal ordinate above is numerical evidence rather than
an ingredient of those results.

## First-zero reciprocal check

Using the standard tabulated approximation `ρ₁ = 1/2 + 14.1347251417 i`, its reciprocal is
approximately

`1/ρ₁ = 0.0024997 - 0.070671 i`.

Pairing it with its conjugate gives approximately `0.0049994`, illustrating why a
conjugation-closed window has a real reciprocal sum. This is evidence for the structural
conjugation theorem, whose proof itself is exact and does not rely on the decimal values.

## Counterexample hunt and definition audit

1. **Small cutoffs:** `n = 2` and `n = 3` are counterexamples to the proposed octave/fifth
   assignments once emptiness below the first zero is taken into account.
2. **Multiplicity:** a `Finset` records distinct zeros, not multiplicity. A future analytic
   definition should use a locally finite multiset or a zero-counting measure.
3. **Summation convention:** for larger cutoffs, conjugate-symmetric truncation is essential.
   An unsymmetrized reciprocal sum can retain an artificial imaginary part.
4. **Growth premise:** the number of zeta zeros up to height `T` is of order `T log T`, not
   `log T / log log T`. The proved transfer theorem is therefore conditional on a supplied
   counting bound and does not assert that this particular bound holds for zeta zeros.

## OEIS and database search

No integer sequence is naturally produced by the complex-valued truncated sums, so an OEIS
identifier is not applicable. Standard zero tables are the relevant data source; no database
record is used as a premise of any theorem here.
