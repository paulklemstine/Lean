# Computational evidence

## Small cases

Starting from `(a₀,b₀) = (0,1)` and applying
`(a,b) ↦ (2a+b, a+2b)` gives:

| n | aₙ | bₙ | aₙ/bₙ | bₙ²-aₙ² | 3ⁿ |
|---:|---:|---:|:---:|---:|---:|
| 0 | 0 | 1 | 0 | 1 | 1 |
| 1 | 1 | 2 | 1/2 | 3 | 3 |
| 2 | 4 | 5 | 4/5 | 9 | 9 |
| 3 | 13 | 14 | 13/14 | 27 | 27 |
| 4 | 40 | 41 | 40/41 | 81 | 81 |
| 5 | 121 | 122 | 121/122 | 243 | 243 |

The data suggest the exact formulas
`2aₙ = 3ⁿ-1` and `2bₙ = 3ⁿ+1`. Both formulas, the norm identity, and the
Möbius recurrence are proved for every natural `n` in
`Physics/HyperbolicArithmetic.lean`; the table is therefore illustrative rather
than the basis of the result.

## OEIS

The unsigned sequences beginning `0, 1, 4, 13, 40, 121` and
`1, 2, 5, 14, 41, 122` are the elementary sequences `(3ⁿ-1)/2` and
`(3ⁿ+1)/2`. No OEIS identifier is asserted here because no external database
lookup was used.

## Counterexample hunt

Direct recurrence evaluation for `n = 0,…,5` found no failure of the proposed
norm identity or disk bound. More decisively, the Lean theorem is universal in
`n`, so there can be no natural-number counterexample to the formalized claim.

## Geometric interpretation

Each ratio is in `[0,1)` and approaches the ideal boundary point `1`. One step
sends `x` to `(x+1/2)/(1+x/2)`, the Möbius translation law on a diameter of the
Poincaré disk. The preserved-up-to-scale quadratic form is visible in the last
two columns.
