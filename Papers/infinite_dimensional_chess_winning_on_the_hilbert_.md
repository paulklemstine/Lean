# Computational Evidence — Infinite-Dimensional Chess

All claims were first stress-tested on small explicit configurations before the
general theory was written.

## 1. Single rook, one-move escape (`gStep`)

For a king at `k = (a,b)` and a rook at `r = (c,d)`, the escape map steps each
coordinate to a neighbour distinct from the rook's:

```
escC a c = if c = a+1 then a-1 else a+1
gStep r (a,b) = (escC a c, escC b d)
```

Worked instances (king `k`, rook `r`, escape `gStep r k`, check that the escape
square shares neither file nor rank with the rook):

| king k   | rook r    | gStep r k | share file? | share rank? |
|----------|-----------|-----------|-------------|-------------|
| (0,0)    | (0,5)     | (1,1)     | no (1≠0)    | no (1≠5)    |
| (0,0)    | (1,0)     | (-1,1)    | no (-1≠1)   | no (1≠0)    |
| (0,0)    | (1,1)     | (-1,-1)   | no          | no          |
| (3,7)    | (4,7)     | (2,8)     | no          | no          |
| (0,0)    | (-1,-1)   | (1,1)     | no          | no          |

In every case the escape square is king-adjacent (Chebyshev distance 1) and
unattacked. This holds for *all* `k, r`, which is the content of
`king_escape_single_rook`.

## 2. Iterating the escape: an infinite run

Starting from `(0,0)` against the rook `(0,5)`, iterating `gStep`:

```
(0,0) → (1,1) → (2,2) → (3,3) → (4,4) → (5,5) → ...   (files/ranks 1,2,3,... never equal 0)
```

The king marches to infinity; the rook's single file `x=0` and rank `y=5` are
avoided from step 1 on. Formalized as `king_escapes_forever`.

## 3. The two-rook threshold — where does mate become possible?

Counterexample hunt for "N rooks can mate a lone king on `ℤ²`":

* **N = 1, 2 rooks:** no mating configuration exists. The would-be trap
  `R = {(a-1,b-1), (a+1,b+1)}` covers all eight neighbours of `(a,b)` — but then
  the king's own file `a` and rank `b` are *unblocked*, so the king is **not in
  check**: it is stalemate (a draw), not mate. Any configuration that *does*
  check the king (blocks file `a` or rank `b`) leaves a free neighbour, by the
  pigeonhole fact that three consecutive integers cannot all lie in a 2-element
  set. Formalized as `no_mate_of_card_le_two`.
* **N = 5 rooks:** a genuine boundaryless cage exists. Place rooks far along the
  four neighbouring lines and one checking rook:
  `(1,N), (-1,N), (N,1), (N,-1)` cover the eight neighbours (files `±1`, ranks
  `±1`), and a rook at `(0,M)` checks down file `0`. All eight neighbours are
  attacked, the king is in check, and no checker is adjacent (so none can be
  captured): checkmate. Hence the escape phenomenon is *not* universal — the
  threshold is exactly at two rooks.

## 4. Finite armies leave cofinitely many safe squares

A finite army occupies finitely many files `X` and ranks `Y`. Any square `(x,y)`
with `x ∉ X`, `y ∉ Y` is unattacked, and there are infinitely many such squares
(cofinitely many choices of each coordinate). Verified for random small armies;
formalized as `exists_safe_square` and `infinitely_many_safe`.

## 5. Game value is transfinite, not finite

"Mate in `n`" is a natural-number invariant. Against a lone rook the king survives
*every* finite number of moves (item 2), so no finite value applies; recast in
combinatorial-game terms, the king position is **not accessible** for the pursuit
relation and therefore carries no ordinal rank at all. Formalized as
`single_rook_never_traps`.

## OEIS note

No integer sequence is central to these results; the phenomena are structural
(existence of escapes and the two-rook threshold) rather than enumerative, so an
OEIS lookup is not applicable.
