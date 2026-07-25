# Computational Evidence

The central finite quantity is the escape probability when exactly one of `n` uniformly challenged locations is bad:

| locations `n` | rounds `k` | exact escape probability | decimal |
|---:|---:|---:|---:|
| 4 | 1 | `3/4` | 0.75 |
| 4 | 2 | `9/16` | 0.5625 |
| 4 | 3 | `27/64` | 0.421875 |
| 4 | 4 | `81/256` | 0.31640625 |
| 10 | 5 | `59049/100000` | 0.59049 |

For comparison, the claimed binary bounds for `n = 4` are `1/2, 1/4, 1/8, 1/16`; each is strictly below `(3/4)^k` for positive `k`. This is formalized for every positive `k` by `four_check_not_binary_sound`.

A representative counterexample hunt tested the universal claim “`k` random line checks give error at most `2^{-k}`” against the smallest useful cases. It fails already at `n = 3, k = 1`, where a certificate with one bad location escapes with probability `2/3 > 1/2`. The formal development proves the stronger unbounded-family result `no_fixed_repetition_half_bound`.

No OEIS search is relevant: the sequence `(n-1)^k/n^k` is an elementary geometric probability family rather than a new integer sequence.
