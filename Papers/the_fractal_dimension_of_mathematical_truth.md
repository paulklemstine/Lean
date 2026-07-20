# Computational evidence

The selected model consists of binary words with no adjacent `true` entries. Direct enumeration gives:

| depth `n` | admissible words | count | all binary words |
|---:|---|---:|---:|
| 0 | empty word | 1 | 1 |
| 1 | `0`, `1` | 2 | 2 |
| 2 | `00`, `01`, `10` | 3 | 4 |
| 3 | `000`, `001`, `010`, `100`, `101` | 5 | 8 |
| 4 | obtained by prefixing `0` to the depth-3 words or `10` to the depth-2 words | 8 | 16 |
| 5 | same recursion | 13 | 32 |
| 6 | same recursion | 21 | 64 |
| 7 | same recursion | 34 | 128 |
| 8 | same recursion | 55 | 256 |

Thus the first counts are `1, 2, 3, 5, 8, 13, 21, 34, 55`, namely the shifted Fibonacci sequence (OEIS A000045 under the conventional indexing `0,1,1,2,3,…`).

## Counterexample hunt

The proposed strict sparsity inequality cannot hold at depths 0 or 1: the admissible language is then the full binary language. This is why the formal theorem assumes `2 ≤ n`. At depths 2 through 8 the counts above satisfy both
`2^(n/2) ≤ count` (natural-number division in the exponent) and `count < 2^n`.

The exact recurrence and inequalities are not justified by this table alone; they are proved for every natural depth in `Catalog/FractalTruth.lean`.
