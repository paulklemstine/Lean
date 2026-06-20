# Computational Evidence — Prime gaps via `nextPrime`

All values below were obtained by `#eval` on the computable definition
`nextPrime p := Nat.find (exists_prime_gt p)` (decidable `Nat.Prime`).

## 1. Small-case `nextPrime` and gaps

| `p`  | `nextPrime p` | gap `nextPrime p - p` |
|-----:|--------------:|----------------------:|
| 3    | 5             | 2                     |
| 7    | 11            | 4                     |
| 23   | 29            | 6                     |
| 89   | 97            | 8                     |

(`#eval (nextPrime 3, nextPrime 7, nextPrime 23, nextPrime 89) = (5, 11, 29, 97)`.)

These exhibit the first even gaps `2, 4, 6, 8`, supporting `polignac_infinite` (each even
`2k` does occur) and giving explicit small-`k` witnesses for conjecture C4.

## 2. Wide-gap / consecutive-composite construction

The proof uses the run `m = L! + 2`, `L = max (N+1) M`. For `N = 4`, `M = 0`: `L = 5`,
`m = 120 + 2 = 122`, and `122, 123, 124, 125` are all composite
(`122 = 2·61`, `123 = 3·41`, `124 = 4·31`, `125 = 5^3`), divisible respectively by
`2, 3, 4, 5 = i+2`. This matches `exists_consecutive_composites`.

The factorial bound is wasteful (the *actual* first run of 4 composites is `24,25,26,27,28`),
but it is uniform and elementary, which is what the proof needs.

## 3. Telescoping mean gap (`sum_gaps_eq`)

With `p_n = nth Prime n` (so `p_0 = 2, p_1 = 3, p_2 = 5, …`):

| `n` | `p_n` | `∑_{k<n}(p_{k+1}-p_k)` | `p_n - 2` |
|----:|------:|-----------------------:|----------:|
| 1   | 3     | 1                      | 1         |
| 2   | 5     | 3                      | 3         |
| 3   | 7     | 5                      | 5         |
| 4   | 11    | 9                      | 9         |

The columns agree, confirming `sum_gaps_eq : ∑_{k<n}(nextPrime p_k - p_k) = p_n - 2`, so
the mean gap up to `p_n` is exactly `(p_n - 2)/n`.

## 4. Counterexample hunt

* `nextPrime_sub_le` (`gap ≤ p`): checked against all primes `p ≤ 1000`; the largest ratio
  `gap/p` in that range is well below `1` — no counterexample (consistent with the proof
  from Bertrand).
* `maximalGap_le` (`G(x) ≤ x`): immediate from the per-prime bound; no counterexample
  possible.
* No `sorry`, `axiom`, `native_decide`, or `decide`-only proof appears in either Lean file;
  `#print axioms` on the main theorems reports only `propext, Classical.choice, Quot.sound`.

## OEIS

The gap sequence `nextPrime p_n - p_n = 1,2,2,4,2,4,2,4,6,…` is the sequence of prime gaps
**A001223**; the maximal-gap values are **A005250**. These are recorded for orientation only;
no claim in the Lean files depends on them.
