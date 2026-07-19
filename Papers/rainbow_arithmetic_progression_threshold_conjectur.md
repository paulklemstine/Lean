# Computational Evidence: Rainbow Three-Term Progressions

## Model audited

For one labelled three-term arithmetic progression, each of its three positions is assigned
independently and uniformly one of `k` colours.  The progression is rainbow exactly when all
three assignments are distinct.  This finite local model is unambiguous even though the
mission's global threshold variable `T_k` is not defined.

## Small-case calculations

The exact probability is

\[
 p_k=\frac{k(k-1)(k-2)}{k^3}=\frac{(k-1)(k-2)}{k^2}.
\]

| `k` | rainbow assignments | all assignments | `p_k` | decimal |
|---:|---:|---:|---:|---:|
| 1 | 0 | 1 | 0 | 0.000000 |
| 2 | 0 | 8 | 0 | 0.000000 |
| 3 | 6 | 27 | 2/9 | 0.222222 |
| 4 | 24 | 64 | 3/8 | 0.375000 |
| 5 | 60 | 125 | 12/25 | 0.480000 |
| 6 | 120 | 216 | 5/9 | 0.555556 |
| 7 | 210 | 343 | 30/49 | 0.612245 |
| 8 | 336 | 512 | 21/32 | 0.656250 |
| 9 | 504 | 729 | 56/81 | 0.691358 |
| 10 | 720 | 1000 | 18/25 | 0.720000 |

These values are reproduced by the theorem `rainbowTripleProbability_small_table`.

## Sequence search

The rainbow-assignment counts begin

`0, 0, 6, 24, 60, 120, 210, 336, 504, 720`,

which is the elementary falling-factorial sequence `k(k-1)(k-2)`.  No external sequence
identifier is needed for the argument, and no database identification is asserted.

## Counterexample hunt and boundary audit

The universal statement “a fixed progression has positive rainbow probability for every
positive `k`” fails at `k=1` and `k=2`.  The corrected boundary is exact: positivity begins at
`k=3`.  The probability is always strictly below one for finite positive `k`.

The complementary collision probability is

\[
 1-p_k=\frac{3}{k}-\frac{2}{k^2}.
\]

Thus local non-rainbow events have order `1/k`, not `1/k²`.  This contradicts any attempted
explanation of a `k² log k` global threshold based solely on the rarity of collision on one
independent progression.  Dependence, coverage, or a different global event must supply the
additional scale.

## Arithmetic-progression packing

For each `m`, the triples

`(3i, 3i+1, 3i+2)` for `0 ≤ i < m`

are strict three-term arithmetic progressions and are pairwise vertex-disjoint inside
`[0,3m)`.  This gives `m` independent coordinate blocks in a product-colouring model.  The
injectivity and progression identities are established in
`Probability/RainbowArithmeticProgression.lean`.
