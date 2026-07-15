# Computational Evidence

## Small-case character table

For dimensions from `-4` through `4`, the two integral characters are:

| dimension `d` | trivial character | Euler character `(-1)^d` |
|---:|---:|---:|
| -4 | 1 | 1 |
| -3 | 1 | -1 |
| -2 | 1 | 1 |
| -1 | 1 | -1 |
| 0 | 1 | 1 |
| 1 | 1 | -1 |
| 2 | 1 | 1 |
| 3 | 1 | -1 |
| 4 | 1 | 1 |

The Euler column is unchanged by reflection `d ↦ -d`.

## Mixed-dimensional calculation

Take cellular coefficients

| dimension | -2 | -1 | 0 | 3 |
|---:|---:|---:|---:|---:|
| coefficient | 3 | 5 | 7 | 11 |

Then:

- even-dimensional mass: `3 + 7 = 10`,
- odd-dimensional mass: `5 + 11 = 16`,
- total mass: `10 + 16 = 26`,
- Euler characteristic: `10 - 16 = -6`,
- Fourier reconstruction: `26 + (-6) = 20 = 2·10` and `26 - (-6) = 32 = 2·16`.

This example is encoded and proved in Lean as `sampleSpace_calculation`.

## Counterexample hunt

The classification claim was checked conceptually on the generator of `ℤ`: a character is fixed by the image of dimension `1`, and an integer unit can only be `1` or `-1`. Hence no third integral unit-valued character can occur. The Lean theorem `dimensionCharacter_classification` proves this universally.

Potential confusion: without the codomain restriction to `ℤˣ`, there are additional multiplicative evaluations. The rigidity theorem specifically concerns characters into the integer unit group.

## OEIS search

The Euler-sign sequence is the elementary alternating sequence `1,-1,1,-1,…`; no OEIS lookup is needed for the proof, and no sequence-identification claim is used.
