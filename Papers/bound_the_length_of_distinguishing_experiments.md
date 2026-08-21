# Computational Evidence — length of distinguishing experiments

All numbers below were produced by **exhaustive enumeration** inside Lean 4 (`#eval`
on a purely computational reimplementation of bounded agreement).  They are
*exploration*, not proof: the statements that are kernel-checked live in
`Catalog/Pythagorean/DistinguishingWord*.lean`.

## Setup

A Moore machine with `n` states over an alphabet of size `|A|` is encoded as a
transition table `t : List (List Nat)` (`n` rows, `|A|` columns) and an output vector
`o : List Bool`.  For a pair of machines and initial states `x, y` we compute

```
minDist = least k with ¬ (x and y agree on all words of length ≤ k)   (none if equivalent)
```

by the recursion `agree 0 x y = (out x == out y)`,
`agree (k+1) x y = (out x == out y) && ∀ a, agree k (step x a) (step y a)`,
which is exactly the `AgreeUpTo` recursion formalised in
`DistinguishingWordBound.lean`.

## Exhaustive worst case over all machine pairs

`max` is the largest `minDist` over **all** transition tables, output vectors and pairs
of initial states; `#pairs` is the number of (machine pair, initial state pair)
instances enumerated.

| `|S|` | `|T|` | `|A|` | #pairs    | observed max | Moore bound `|S|+|T|-2` | product bound `|S|·|T|-1` |
|------:|------:|------:|----------:|-------------:|------------------------:|--------------------------:|
| 2 | 2 | 1 | 1 024     | **2** | 2 | 3 |
| 2 | 2 | 2 | 16 384    | **2** | 2 | 3 |
| 3 | 1 | 1 | 1 296     | **2** | 2 | 2 |
| 3 | 2 | 1 | 20 736    | **3** | 3 | 5 |
| 3 | 2 | 2 | 2 239 488 | **3** | 3 | 5 |
| 4 | 1 | 1 | 32 768    | **3** | 3 | 3 |
| 5 | 1 | 1 | 1 000 000 | **4** | 4 | 4 |
| 4 | 2 | 1 | 524 288   | **4** | 4 | 7 |
| 3 | 3 | 1 | 419 904   | **4** | 4 | 8 |

### Readings

1. **The observed worst case is always exactly `|S| + |T| - 2`.**  Never `|S|·|T| - 1`
   except in the degenerate cases where the two coincide (`|T| = 1`).  This is what
   motivated proving the linear (Moore) bound in `DistinguishingWordMoore.lean`, and
   the matching lower bound is now a theorem for *all* sizes
   (`Extremal.moore_bound_attained`).
2. **Alphabet size is irrelevant to the worst case.**  Rows `(3,2,|A|=1)` and
   `(3,2,|A|=2)` both give `3`; likewise `(2,2)`.  The extremal family we then
   constructed and verified is indeed unary (alphabet `Unit`).
3. **The extremal shape is "long tail vs. short cycle".**  Inspecting extremal
   instances at `(3,2)` and `(3,3)` shows a saturating chain on one side and a cycle on
   the other — the Fine–Wilf pattern that the formal construction
   `Extremal.tailMachine` / `Extremal.cycleMachine` abstracts: a sequence of preperiod
   `n-1` and a sequence of period `m` can agree for `n + m - 3` steps and differ at
   step `n + m - 2`.

## Sequence data

The worst-case function `W(n,m) = n + m - 2` is trivial as a sequence, so no OEIS entry
is relevant.  The *size of the complete test suite* over an alphabet of size `q`,
`∑_{i ≤ k} q^i`, is the repunit-in-base-`q` family (e.g. `1, 3, 7, 15, …` for `q = 2`);
the file `DistinguishingWordTestSuite.lean` proves the clean upper estimate
`(q + 1)^k` for it.

## Counterexample hunt

We searched for a pair violating `minDist ≤ |S| + |T| - 2` in every table row above
(≈ 4.2 million instances in total, search depth 8–10, far above the bound).  **No
violation was found**, consistent with the now-proved theorem
`exists_distinguishing_word_moore`.
