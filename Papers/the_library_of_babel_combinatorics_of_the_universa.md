# Computational Evidence

## Small-case calculations

For an alphabet of size four and passages of length two, there are `4² = 16` possible passages. The cyclic word

`0010203112132233`

has the successive cyclic windows

| position | window |
|---:|:---|
| 0 | 00 |
| 1 | 01 |
| 2 | 10 |
| 3 | 02 |
| 4 | 20 |
| 5 | 03 |
| 6 | 31 |
| 7 | 11 |
| 8 | 12 |
| 9 | 21 |
| 10 | 13 |
| 11 | 32 |
| 12 | 22 |
| 13 | 23 |
| 14 | 33 |
| 15 | 30 |

Thus every ordered pair occurs once. Repeating the initial symbol linearizes the cycle to the length-seventeen word `00102031121322330`.

For a binary ambient volume of length three and the fixed pattern `11`, the matching volumes are `011`, `110`, and `111`. The exact probability is `3/8`; the placement union bound is `2·2⁻² = 1/2`.

## Sequence search

The number of words of length `L` over an alphabet of size `A` is `A^L`. For `A = 4`, the initial values are `1, 4, 16, 64, 256, 1024, ...`, the standard powers-of-four sequence (OEIS A000302).

## Counterexample hunt

The proposed prefactor “passage length” is not the correct general union-bound prefactor. A length-one target in a length-three binary volume has three possible placements, not one. For the target symbol `1`, seven of eight volumes contain it, whereas the expression `1·2⁻¹ = 1/2` underestimates the probability. The corrected prefactor is the number of windows, `L-m+1`; this gives the valid upper bound `3/2` (loose but correct).

The proposed distributed threshold based only on raw bit capacity also fails under the one-entry-per-catalog-volume model. Listing every member of a library with `A^L` volumes requires at least `A^L` entries. A smaller information-theoretic threshold presupposes a block decoder that extracts multiple addresses from one catalog volume.

## Summary table

| claim tested | outcome |
|:---|:---|
| `4²` cyclic windows can list all two-symbol volumes | confirmed by the explicit word above |
| all windows can be collision-free beyond the de Bruijn length | false by finite cardinality |
| passage length is the universal probability prefactor | false; placements supply the union-bound prefactor |
| a one-entry-per-volume catalog can use fewer than `A^L` entries | false |
