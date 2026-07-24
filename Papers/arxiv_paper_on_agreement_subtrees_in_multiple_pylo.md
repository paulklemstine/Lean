# Computational Evidence

## Small-case values of the iterated exponential tower `iterExp n a`

`iterExp 0 a = a`, and `iterExp (n+1) a = 2^(iterExp n a)`.

| a \ n | 0 | 1 | 2        | 3            |
|-------|---|---|----------|--------------|
| 0     | 0 | 1 | 2        | 4            |
| 1     | 1 | 2 | 4        | 16           |
| 2     | 2 | 4 | 16       | 65536        |
| 3     | 3 | 8 | 256      | 2^256        |

These are confirmed in-file by `#eval` (e.g. `iterExp 2 2 = 16`, `iterExp 3 1 = 16`) and by
the `decide`-checked identities `iterExp 2 2 = 16` and `iterExp 4 0 = iterExp 3 1`.

## Double-exponential counting bound

For `|A| = a`, the number of distinct induced split systems on `A` is at most
`|𝒫(𝒫(A))| = 2^(2^a)`:

| a | 2^a | 2^(2^a) |
|---|-----|---------|
| 0 | 1   | 2       |
| 1 | 2   | 4       |
| 2 | 4   | 16      |
| 3 | 8   | 256     |

This is `iterExp 2 a`, the height-two tower, and is proved as `card_image_restrict_le`.

## Pigeonhole pivot — boundary check

With `k > 2^(2^a)` trees, two must induce the same system on `A` (`exists_agreeing_pair`).
The boundary is genuine: at `k = 2^(2^a)` one could, in principle, realize every element of
the double powerset exactly once, so no repeat is forced. This is exactly why the
exponential must be *iterated*: each pigeonhole step only descends to a strictly smaller,
still doubly-exponential, sub-problem.

## Counterexample hunt

No counterexamples were found to the containment `restrict T A ⊆ 𝒫(A)`, the counting bound,
or the tower monotonicity statements; all are proved without additional hypotheses. The
strict-inequality boundary of the pigeonhole pivot is documented as a genuine limit case
rather than a counterexample to the theorem.
