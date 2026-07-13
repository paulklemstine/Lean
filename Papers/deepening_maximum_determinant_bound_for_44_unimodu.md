# Computational Evidence: Maximal `4 × 4` Determinants with Bounded Entries

We study the maximum determinant `M(B)` of a `4 × 4` integer matrix whose entries
all lie in the symmetric range `{-B, …, B}`.

## 1. Small cases and the extremal construction

The scaled order-`4` Hadamard matrix

```
[  B  B  B  B ]
[  B -B  B -B ]
[  B  B -B -B ]
[  B -B -B  B ]
```

has mutually orthogonal rows (`A Aᵀ = 4B² · I`) and determinant `16 · B⁴`:

| B | det of construction = 16·B⁴ |
|---|------------------------------|
| 1 |                          16 |
| 2 |                         256 |
| 3 |                        1296 |
| 4 |                        4096 |
| 5 |                       10000 |

For `B = 1` this is a genuine Hadamard matrix, and `16` is the known maximum
determinant of a `4 × 4` matrix with entries in `{-1, 0, 1}` (indeed with entries
in `{-1, 1}`). Hadamard's bound `nⁿ/²` gives `4² = 16` for `n = 4`, matched
exactly because an order-`4` Hadamard matrix exists.

## 2. Two-sided bracket

* **Lower bound (achievability).** The construction above gives `M(B) ≥ 16·B⁴`.
* **Upper bound (Leibniz / permutation sum).** Expanding the determinant over the
  `4! = 24` permutations gives `|det| ≤ 24·B⁴`, so `M(B) ≤ 24·B⁴`.

Hence `16·B⁴ ≤ M(B) ≤ 24·B⁴`, and the exact value is `16·B⁴`. Closing the gap
from `24` to `16` is exactly Hadamard's inequality (equivalently the
Hadamard–Fischer inequality `det G ≤ ∏ Gᵢᵢ` for the positive‑semidefinite Gram
matrix `G = A Aᵀ`, whose diagonal entries are the squared row norms `≤ 4B²`).

## 3. Counterexample hunt: the circulated formula is false

The circulated candidate for the maximum on `{-(2k-1), …, 2k-1}` was

```
f(k) = (2k-1)⁴ - 2(2k-1)² + 1 = ((2k-1)² - 1)².
```

Testing against the achievable value `16·(2k-1)⁴`:

| k | 2k-1 | circulated f(k) | achievable 16·(2k-1)⁴ |
|---|------|-----------------|-----------------------|
| 1 |    1 |               0 |                    16 |
| 2 |    3 |              64 |                  1296 |
| 3 |    5 |             576 |                 10000 |
| 4 |    7 |            2304 |                 38416 |

The circulated formula is not even an upper bound: it is strictly below the
achievable determinant for every `k ≥ 1` (dramatically so — it is `0` at `k = 1`).
This refutation is proved in `MaxDeterminant4x4.lean` as `claimed_lt_true` and
`claimed_false_k_one`.

## 4. OEIS

The maxima `16·B⁴` for `B = 1, 2, 3, …` are `16, 256, 1296, 4096, 10000, …`,
i.e. `16 · B⁴` — the fourth powers scaled by `16`. The unscaled maximal
determinant of `n × n` `±1` matrices is OEIS A003432 (`1, 1, 2, 4, 16, 48, …`),
whose `n = 4` term is `16`, consistent with the value here.
