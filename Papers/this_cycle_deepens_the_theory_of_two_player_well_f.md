# Computational Evidence

## Small-case calculations

For countdown heaps of sizes `0` through `8`, the observed outcome table is:

| first \ second | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| 0 | L | W | W | W | W | W | W | W | W |
| 1 | W | L | W | W | W | W | W | W | W |
| 2 | W | W | L | W | W | W | W | W | W |
| 3 | W | W | W | L | W | W | W | W | W |
| 4 | W | W | W | W | L | W | W | W | W |
| 5 | W | W | W | W | W | L | W | W | W |
| 6 | W | W | W | W | W | W | L | W | W |
| 7 | W | W | W | W | W | W | W | L | W |
| 8 | W | W | W | W | W | W | W | W | L |

Here `W` means that the mover has a winning continuation and `L` means that
every move hands the opponent a winning continuation.

## Sequence search

The losing cells form the diagonal sequence `(0,0), (1,1), (2,2), …` rather
than a one-dimensional enumerative sequence, so no OEIS identification is
needed.  For a fixed row `m`, the binary outcome sequence has its unique zero at
index `m`.

## Counterexample hunt

Every pair with coordinates at most eight was tested against the conjecture
that a position is winning exactly when its heap sizes differ.  No
counterexample occurred.  The test also immediately refuted two broader claims:
`(1,1)` shows that a sum of winning components can lose, while `(0,1)` shows
that a losing component is not generally removable.

## Structural interpretation

Whenever the heap sizes differ, the larger heap can be reduced to the smaller,
producing a diagonal position.  From a diagonal position, every move can be
mirrored in the other coordinate.  This finite pattern suggests a proof that
depends only on well-founded recursion and therefore persists at transfinite
rank.
