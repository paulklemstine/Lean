# Computational Evidence — Singleton Bound for Neural Codes

We collect small-case evidence for the two theorems proved in
`NeuralCodeSingletonBound.lean`: the Singleton bound
`|C| ≤ 2^(N + 1 − d)` and its noise-tolerance corollary
`|C| ≤ 2^(N − 2t)` for `t`-error-correcting codes.

## 1. Singleton bound vs. small codebooks

For patterns in `{0,1}^N` with minimum Hamming distance `d`, the bound reads
`|C| ≤ 2^(N + 1 − d)`.

| N | d | Singleton ceiling 2^(N+1−d) | attained by |
|---|---|-----------------------------|-------------|
| 3 | 1 | 2^3 = 8                     | full space `{0,1}^3` (8 words) |
| 3 | 2 | 2^2 = 4                     | even-weight parity code (4 words: 000,011,101,110) |
| 3 | 3 | 2^1 = 2                     | repetition `{000,111}` |
| 4 | 4 | 2^1 = 2                     | repetition `{0000,1111}` |
| 5 | 3 | 2^3 = 8                     | (Hamming ceiling here is 2^5/(5+1)=5.3, so Singleton is looser) |

Observations:
- At `d = 1` the ceiling is `2^N`, the raw capacity, matched by the full space
  (`full_code_attains_singleton`).
- At `d = N` the ceiling is `2^1 = 2`, matched by the repetition code
  (`repetition_attains_singleton`).
- The `[3,2]` even-weight code (a single parity check) meets the bound at `d = 2`,
  illustrating that Singleton is tight for the whole family of single-parity codes,
  not only the two extremes.

## 2. Robust capacity `2^N ↦ 2^(N−2t)`

For `t`-error correction (`d = 2t+1`):

| N | t | 2t+1 | robust ceiling 2^(N−2t) |
|---|---|------|--------------------------|
| 3 | 1 | 3    | 2^1 = 2                  |
| 5 | 1 | 3    | 2^3 = 8                  |
| 7 | 1 | 3    | 2^5 = 32                 |
| 7 | 3 | 7    | 2^1 = 2                  |

The `[7,4,3]` Hamming code has 16 words with `t = 1`; the robust ceiling `2^5 = 32`
correctly upper-bounds it (Singleton is not tight for the Hamming code — the
sphere-packing bound `2^7/8 = 16` is the tight one there, confirming the two
bounds are genuinely different and complementary).

## 3. Counterexample hunt

We tested the universal claim `|C| ≤ 2^(N+1−d)` on all minimum-distance-`d`
codebooks obtainable by greedy construction for `N ≤ 6`, `1 ≤ d ≤ N`. No
codebook exceeded the ceiling; the repetition, parity, and full codes met it with
equality at `d = N`, `d = 2`, and `d = 1` respectively. No counterexample was
found, consistent with the proof.

## 4. Relationship to the Hamming bound

For fixed `N`, the two ceilings cross: Singleton `2^(N+1−d)` is smaller (stronger)
for large `d`, while the sphere-packing bound `2^N / ∑_{k≤t} C(N,k)` is smaller
for moderate `d`. Neither dominates the other, which is why both are worth having.
