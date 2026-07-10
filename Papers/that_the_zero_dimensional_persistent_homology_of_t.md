# Computational Evidence — Barcode Invariants of the Prime Point Cloud

All figures below were produced by direct evaluation over the exact prime
sequence and are reproduced in the accompanying formal development.

## 1. Small-case data

First eleven primes `p_0, …, p_10`:

```
2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31
```

The consecutive gap sequence `g_i = p_{i+1} − p_i`:

```
1, 2, 2, 4, 2, 4, 2, 4, 6, 2, …
```

(The leading `1` is the single odd gap `3 − 2`; every later gap is even.)

## 2. Total persistence `= p_n − 2`

The total persistence of the first `n` finite `H₀` bars is the sum of the bar
lengths, i.e. the sum of the first `n` gaps. For `n = 9`:

```
1 + 2 + 2 + 4 + 2 + 4 + 2 + 4 + 6 = 27  =  p_9 − 2  =  29 − 2.
```

The telescoping identity `∑_{i<n} (p_{i+1} − p_i) = p_n − p_0` with `p_0 = 2`
therefore gives total persistence `= p_n − 2` for every `n`, verified in closed
form (not merely on this sample).

| `n` | `p_n` | total persistence |
|----:|------:|------------------:|
| 1   | 3     | 1                 |
| 4   | 11    | 9                 |
| 9   | 29    | 27                |
| 10  | 31    | 29                |

## 3. The Betti staircase `b₀(ε, n) = 1 + #{ i < n : g_i > ε }`

Number of `ε`-connected components among the first `n + 1` points. For the first
ten points (`n = 9`):

| scale `ε` | components `b₀` | triggering gaps `> ε` |
|----------:|----------------:|-----------------------|
| `ε = 1`   | 9               | all gaps except the leading `1` |
| `ε = 3`   | 5               | the four gaps `≥ 4` (`4,4,4,6`) |
| `ε ≥ 6`   | 1               | none — single component |

Each downward step of the curve is caused by exactly one gap dropping below the
threshold, matching the exact counting formula.

## 4. OEIS pointers

* Prime gaps `1, 2, 2, 4, 2, 4, 2, 4, 6, …` — OEIS A001223.
* Primes `2, 3, 5, 7, 11, …` — OEIS A000040.
* Total persistence values `p_n − 2 = 0, 1, 3, 5, 9, 11, 15, …` are `A000040 − 2`.

## 5. Counterexample hunt

The two headline identities (`total persistence = p_n − 2` and the Betti
staircase formula) are equalities proved for all `n` and all real `ε`, so no
counterexample can exist; the sampling above is illustrative rather than a search.
The single-component threshold `b₀ = 1` was checked to coincide exactly with
"`ε` dominates every internal gap", i.e. with the largest gap, in every sampled
window.
