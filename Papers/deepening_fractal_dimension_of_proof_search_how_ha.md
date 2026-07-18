# Computational Evidence: Nonstationary Proof-Search Dimension

## Small-case calculations

For ambient branching profile `b` and successful branching profile `s`, the tested quantity was

`D(b,s) = log(∏ sᵢ) / log(∏ bᵢ)`.

| Ambient profile | Successful profile | Total paths | Successful paths | Dimension |
|---|---:|---:|---:|---:|
| `[2,2,2,2]` | `[1,2,1,2]` | 16 | 4 | 0.500000000 |
| `[2,3,2,3]` | `[1,2,2,1]` | 36 | 4 | 0.386852807 |
| `[2,2]` | `[1,2]` | 4 | 2 | 0.500000000 |
| `[5,5]` | `[2,2]` | 25 | 4 | 0.430676558 |

These cases support the proposed multiplicative-to-entropy translation: only the products of the levelwise branching values enter the finite-profile dimension.

## Composition test and counterexample hunt

Two phases were compared:

* phase 1 has ambient path count `4`, successful path count `2`, and dimension `0.5`;
* phase 2 has ambient path count `25`, successful path count `2`, and dimension approximately `0.215338279`.

Their concatenation has ambient count `100`, successful count `4`, and dimension
`log 4 / log 100 ≈ 0.301029996`. The ambient-entropy-weighted mean gives the same value. The unweighted arithmetic mean is approximately `0.357669140`, so the conjecture that equal-depth phases should be averaged equally is false when their ambient branching differs.

A representative finite search over branching values from `1` through `5` found no violation of the interval bound `0 ≤ D ≤ 1` when successful branching was coordinatewise bounded by ambient branching and the ambient logarithmic volume was positive.

## Sequence-database search

No integer sequence is intrinsic to the principal claim: the invariant is a logarithmic ratio attached to pairs of finite branching profiles. Consequently, an OEIS lookup would not identify the composition law. LMFDB data are likewise not relevant to this finite tree/entropy calculation.

## Interpretation

The experiments isolate the structural law subsequently proved: concatenation is additive at the logarithmic-volume level, hence relative dimension composes by ambient-information weighting rather than by level count.
