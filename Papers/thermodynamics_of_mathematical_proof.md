# Computational Evidence

The finite model has closed-form counts, so small cases can be tabulated exactly.

| Derivation depth `n` | candidates `2^n` | erased alternatives `2^n - 1` | created choices `n` |
|---:|---:|---:|---:|
| 0 | 1 | 0 | 0 |
| 1 | 2 | 1 | 1 |
| 2 | 4 | 3 | 2 |
| 3 | 8 | 7 | 3 |
| 4 | 16 | 15 | 4 |
| 5 | 32 | 31 | 5 |
| 6 | 64 | 63 | 6 |
| 8 | 256 | 255 | 8 |
| 10 | 1024 | 1023 | 10 |

The recurrence `E(n+1) = 2 E(n) + 1` holds throughout the table. The strict inequality `2n < E(n)` first holds at `n = 4` and persists thereafter. The universal compression claim was checked against the cardinality of all binary descriptions shorter than `n`, namely `2^n - 1`, which is one less than the `2^n` derivations.

No OEIS lookup is needed: the sequence `2^n - 1` is the elementary Mersenne-number sequence, and the argument uses its closed form rather than an empirical identification.

The counterexample hunt exposed an important boundary. Exponential candidate coverage is not a universal semantic verification lower bound: a structured verifier may recognize a proof without querying candidates as an unstructured oracle. Accordingly, the result is stated only for adversarial candidate coverage. Likewise, assigning one Landauer unit to each discarded alternative assumes those alternatives are stored as independent bits; compressed storage is governed instead by entropy and the incompressibility boundary.
