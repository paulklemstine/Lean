# Computational Evidence: Winning on the Hilbert Board

The claims proved this cycle are universal statements over infinite boards, so
the decisive evidence is structural rather than numerical. Nonetheless several
finite spot-checks guided and confirmed the formalization.

## 1. The escape step is concrete and correct

The escape map moves every coordinate one step away from the rook. On `ℤ^3`
(`d = 1`), with rook and king both at the origin, the king steps to the all-ones
square:

    gStep 0 0 = (1, 1, 1)

which is verified as an `example` in the file. Each coordinate lands on `a ± 1`,
so the move is a legal king step (Chebyshev distance one) and disagrees with the
rook in *all three* coordinates, hence lies off every axis-line through it.

## 2. Small-case neighbour-covering counts

A checkmate must cover the king's `3^{d+2} - 1` neighbours with axis-lines:

| dimension `d+2` | neighbours `3^{d+2} - 1` |
|-----------------|--------------------------|
| 2               | 8                        |
| 3               | 26                       |
| 4               | 80                       |
| 5               | 242                      |

The rapid growth is the intuition behind Future Direction 1 (the material
threshold `m(d)` diverges): each new axis triples the neighbourhood while a lone
line still covers only a one-dimensional slice.

## 3. Counterexample hunt for "two rooks can mate"

We searched for a two-rook mate in dimension `≥ 2` and found none: for any two
rooks the projections onto the first two axes each miss cofinitely many integers,
so a safe neighbour of the king always exists. This matches the proved theorem
`single_rook_no_mate` (and the two-rook bound from the planar predecessor). In
dimension one the search instead *succeeds*: rooks at `k-1` and `k+1` mate the
king at `k`, because each checker defends the other. This boundary case is
formalized as `one_dim_two_rooks_mate`.

## 4. Infinite escape run

Iterating the escape step from any start produces an infinite sequence of safe
king moves; sampling the first several iterates confirms every coordinate keeps
moving and never revisits a rook line. This is exactly the descending chain used
to prove `single_rook_never_traps`.

No numerical counterexample to any stated theorem was found; all finite checks are
consistent with the universal results now proved.
