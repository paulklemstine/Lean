# Computational Evidence

## Small-case calculations

The least-element construction predicts `q = n-sk+s` colours. Representative admissible parameters give:

| `s` | `k` | `n` | `q` |
|---:|---:|---:|---:|
| 2 | 2 | 4 | 2 |
| 3 | 2 | 6 | 3 |
| 3 | 3 | 9 | 3 |
| 3 | 3 | 10 | 4 |
| 4 | 3 | 12 | 4 |

At the packing boundary `n=sk`, the cyclic arithmetic progression `{0,s,2s,…,(k-1)s}` realizes equality in every gap and the predicted palette has size `s`.

## Sequence search

For fixed `s` and `k`, the predicted number of colours is the affine sequence `n-sk+s` as `n` varies. No specialized sequence identification is needed beyond this linear form.

## Counterexample hunt

The proof obligations expose two necessary boundary conditions. Empty sets (`k=0`) have no least element, so the colouring theorem explicitly assumes `k≥1`. A nonzero stability parameter is needed to ensure the palette is inhabited under `n≥sk`; the theorem explicitly assumes `s≥1`. Within these guards, the packing inequality forces every least element below the palette cutoff, leaving no small-case counterexample to the upper-colouring claim.

## Structural table

For a stable set with ordered elements `a₀<⋯<aₖ₋₁`, repeated gap inequalities produce

`aᵢ ≥ a₀ + si`,

and therefore

`a₀ + s(k-1) < n`.

This is the numerical invariant used throughout the construction. The boundary examples above attain equality up to the strict endpoint inequality, confirming sharpness of the cutoff.
