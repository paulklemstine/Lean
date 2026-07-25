# Computational evidence

## Small-case calculation

The counterexample uses the two-dimensional cochain complex

- `dPrev(a) = (a, 0)`,
- `dNext(x₀, x₁) = x₁`.

Thus `dNext (dPrev a) = 0`. A harmonic vector is closed (`x₁ = 0`) and orthogonal to the exact axis (`x₀ = 0`), hence is `(0,0)`. The test form `(0,1)` is not closed and cannot be exact plus harmonic.

| form | closed? | exact? | harmonic? |
|---|---:|---:|---:|
| `(0,0)` | yes | yes | yes |
| `(1,0)` | yes | yes | no |
| `(0,1)` | no | no | no |
| `(1,1)` | no | no | no |

These calculations are encoded and proved symbolically in `Catalog/Tropical/HodgeTheory/Contrarian/Counterexample.lean`; they are not merely sampled numerical tests.

## OEIS search

No integer sequence arises from the claims, so an OEIS search is inapplicable.

## Counterexample hunt

The universal conjecture “every cochain is exact plus harmonic” fails at dimension two, witnessed by `(0,1)`. The corrected closed-form conjecture survives and is proved abstractly in `HodgeDecomposition.lean`.

## Plots

No plot is useful: exact forms are the horizontal axis, harmonic forms are the origin, and `(0,1)` lies on the missing coexact axis.
