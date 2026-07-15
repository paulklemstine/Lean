# Computational Evidence: Iterated Beatty Sequences

## Small-case calculations

The test modulus was `α = √8 ≈ 2.82842712474619`, an irrational number above
`(3 + √5)/2`.  For positive indices `k = 1,…,10`, the first four iterates of
`k ↦ ⌊αk⌋` are:

| iterate | first ten values |
|---:|:---|
| 1 | 2, 5, 8, 11, 14, 16, 19, 22, 25, 28 |
| 2 | 5, 14, 22, 31, 39, 45, 53, 62, 70, 79 |
| 3 | 14, 39, 62, 87, 110, 127, 149, 175, 197, 223 |
| 4 | 39, 110, 175, 246, 311, 359, 421, 494, 557, 630 |

The table exhibits strict increase at every depth and growth by at least one per
iteration on positive indices.

## Additive-defect hunt

For every pair `1 ≤ m,n < 50`, the sampled defect

`⌊α(m+n)⌋ − ⌊αm⌋ − ⌊αn⌋`

was either `0` or `1`.  This motivated the proved two-sided almost-additivity
bound, which holds for every nonnegative real modulus rather than only this
sample.

## Counterexample hunt and boundary correction

The initially proposed unguarded growth statement

`k + 1 ≤ ⌊αk⌋` for every natural `k` and `α ≥ 2`

fails at `k = 0`, where its right side is zero.  Restricting to positive indices
is necessary and matches the conventional positive indexing of Beatty
sequences.  No counterexample to the corrected statement occurred, and the
general corrected result is proved.

## Sequence-database status

No OEIS identification is asserted.  The iterated rows depend on both the chosen
irrational modulus and iteration depth, and the investigation focused on the
structural floor identities rather than identifying one fixed integer sequence.
