# Computational Evidence

## Small-case calculations

For the binary tropical aggregator

\[
F(x_0,x_1)=\min(x_0,x_1),
\]

the following profiles separate it from both coordinate projections.

| profile | `F` | first projection | second projection |
|---|---:|---:|---:|
| `(0,1)` | 0 | 0 | 1 |
| `(1,0)` | 0 | 1 | 0 |
| `(2,3)` | 2 | 2 | 3 |
| `(-1,4)` | -1 | -1 | 4 |

Translation equivariance is visible from
`F(x₀+c,x₁+c)=min(x₀,x₁)+c`. Preservation of coordinatewise tropical addition follows by rearranging four minima:

\[
\min(\min(a,c),\min(b,d))=\min(\min(a,b),\min(c,d)).
\]

## OEIS search results

No integer sequence is intrinsic to these structural claims, so an OEIS search is not applicable.

## Counterexample hunt

The two profiles `(0,1)` and `(1,0)` give a complete counterexample hunt for binary dictatorship: the first excludes the second projection and the second excludes the first projection. Since `Fin 2` has exactly these two possible dictators, binary minimum is non-dictatorial.

The broader unguarded uniqueness claim also fails for every electorate with at least two voters because distinct coordinate projections satisfy the same weak tropical linearity and normalization axioms.

## Structural table

| aggregator | normalized | translation equivariant | preserves coordinatewise min | dictatorial |
|---|---|---|---|---|
| `x ↦ x₀` | yes | yes | yes | yes |
| `x ↦ x₁` | yes | yes | yes | yes |
| `x ↦ min(x₀,x₁)` | yes | yes | yes | no |

These calculations motivated separating weak min-plus linearity from the stronger decisive-ultrafilter condition.
