# Computational Evidence

## Small-case calculations

For the escape coordinate

`escC(a,c) = a-1` when `c=a+1`, and `escC(a,c)=a+1` otherwise,

the following representative values were checked:

| king coordinate `a` | rook coordinate `c` | `escC(a,c)` | distance moved | differs from `c` |
|---:|---:|---:|---:|:---:|
| 0 | 1 | -1 | 1 | yes |
| 0 | 0 | 1 | 1 | yes |
| 0 | -1 | 1 | 1 | yes |
| 4 | 5 | 3 | 1 | yes |
| 4 | 12 | 5 | 1 | yes |

Applying this coordinatewise in two or more dimensions changes every coordinate by one and leaves the new square different from the rook in every coordinate. Since a rook line permits disagreement in at most one coordinate, the resulting square is unattacked.

For a rook at the origin and a king initially at the origin, the first iterates of the coordinatewise map alternate:

| time | square in two dimensions |
|---:|:---|
| 0 | `(0,0)` |
| 1 | `(1,1)` |
| 2 | `(2,2)` |
| 3 | `(3,3)` |
| 4 | `(4,4)` |

Thus this sample produces a visibly unbounded safe run.

The abstract winning-tree constructions have the first target values

| position | ordinal value |
|:---|:---|
| checkmate leaf | `0` |
| `opowGame 0` | `1 = ω^0` |
| `opowGame 1` | `ω` |
| `opowGame 2` | `ω²` |
| `opowGame 3` | `ω³` |
| diagonal game | `ω^ω` |

## Sequence search

The finite exponents in the hierarchy are `1, ω, ω², ω³, …`, an ordinal sequence rather than an integer sequence, so an OEIS search is not applicable. No arithmetic LMFDB object is involved.

## Counterexample hunt

The unrestricted slogan “the king always escapes” fails in one dimension. On the integer line, rooks at `k-1` and `k+1` checkmate a king at `k`: each adjacent rook is defended by the other. This counterexample motivates the guarded dimension-at-least-two statement.

The stronger assertion that every finite rook army permits a local escape from every non-mated position was not assumed. Global evidence proves that infinitely many unattacked squares remain, but this alone does not establish local reachability through safe king moves.

## Structural table

| setting | tested/proved behavior |
|:---|:---|
| one axis, two rooks | mate is possible |
| at least two axes, one rook | explicit safe move from every square |
| at least two axes, one rook, repeated play | infinite safe run |
| at least two axes, finite rook army | infinitely many globally safe squares |
| abstract countably branching winning tree | values through `ω^ω` realized |
