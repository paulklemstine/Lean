# Computational Evidence: Sums of Three Cubes Modulo Nine

## Small cases

For `x mod 9 = 0,1,…,8`, the cube residues are

| `x mod 9` | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `x³ mod 9` | 0 | 1 | 8 | 0 | 1 | 8 | 0 | 1 | 8 |

Thus each of `0, 1, 8` occurs three times. Enumerating triples of these three
cube residues gives the following numbers of ordered triples `(x,y,z)` in
`(Z/9Z)³` solving `x³+y³+z³=k`:

| `k mod 9` | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| number of solutions | 189 | 162 | 81 | 27 | 0 | 0 | 27 | 81 | 162 |

The counts sum to `729 = 9³`. In particular, the local obstruction is exactly
the pair of residues `4,5`, not merely a necessary condition detected by a
partial search.

Explicit cube-residue witnesses for the seven soluble targets are:
`(0,0,0)`, `(1,0,0)`, `(1,1,0)`, `(1,1,1)`, `(-1,-1,-1)`,
`(-1,-1,0)`, and `(-1,0,0)` for residues `0,1,2,3,6,7,8` respectively.

## OEIS search

No sequence is needed for the theorem: the object is the fixed finite fiber
count above rather than an integer sequence. Consequently no OEIS identifier
is asserted.

## Counterexample hunt

The universal local claim “every residue modulo nine is a sum of three cubes”
fails exactly at `4` and `5`. Exhausting all `9³=729` ordered triples finds no
other failure. This finite observation is proved symbolically in
`NumberTheory/SumsOfThreeCubes.lean`; the table here is supporting evidence,
not the basis on which the formal theorem is trusted.
