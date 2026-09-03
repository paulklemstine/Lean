# Computational evidence: the argmax staircase word

All numbers below were produced by exact rational arithmetic in Lean 4 (`#eval`, `ℚ`
floors — no floating point), with

```
S α n = ⌊(n+1)α⌋          (argmax staircase, = lastArgmax of the binomial weights)
w α n = S α (n+1) - S α n (increment word)
```

## 1. The words themselves

| slope α | first letters of `w α` |
|---|---|
| `3/7`  | `0 1 0 1 0 1 0 0 1 0 1 0 1 0 0 1 0 1 0 1 0 0 1 0 1 0 1 0 0 1` |
| `1/2`  | `1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0` |
| `≈ 2-√2` (`0.585786437626905`) | `1 0 1 0 1 1 0 1 0 1 1 0 1 0 1 0 1 1 0 1 0 1 1 0 1 0 1 0 1 1 0 1 0 1 1 0 1 0 1 1` |

Note the very first letter: for `α = 1/2` the staircase word starts with `1`, while the
lower mechanical word of slope `1/2` starts with `⌊1/2⌋ = 0`.  This is the `+1` shift
proved in `incWord_ne_mechanical_zero`.

## 2. Subword complexity `p(L)` (number of distinct factors of length `L`)

Computed over the first 300–400 positions.

| slope α | `p(0..9)` |
|---|---|
| `3/7`   | `1, 2, 3, 4, 5, 6, 7, 7, 7, 7` |
| `1/2`   | `1, 2, 2, 2, 2, 2, 2, 2, 2, 2` |
| `5/13`  | `1, 2, 3, 4, 5, 6, 7, 8, 9, 10` |
| `≈ 2-√2` | `1, 2, 3, 4, 5, 6, 7, 8, 9, 10` |
| `≈ 1/φ = 0.618033988749895` | `1, 2, 3, 4, 5, 6, 7, 8, 9, 10` |

Observations, all of which are now theorems in the Lean files:

* `p(L) ≤ L + 1` always (`factorSet_ncard_le`);
* for rational `α = P/(P+Q)` the count saturates at the period `P+Q`
  (`incWord_periodic_slope`; e.g. `3/7` saturates at `7`, `1/2` at `2`);
* for irrational `α`, `p(L) = L + 1` for all tested `L` (`factorSet_ncard_eq`).

## 3. Balance / window sums

Sums of `L` consecutive letters, `L` fixed, over positions `m = 0..20`:

* `α = 3/7`, `L = 7`: `3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3` — constantly `P = 3`
  (`incWord_ones_per_period`).
* `α ≈ 2-√2`, `L = 10`: `6 6 6 6 6 6 5 6 6 6 6 5 6 6 6 6 6 6 5 6 6` — only the two
  values `⌊10α⌋ = 5` and `6` occur (`windowSum_bounds`, `staircase_balanced`).

A direct check of `max − min ≤ 1` over all windows of length `L ≤ 11` and all positions
`m < 300` returned `true` for `α = 3/7`, `α = 5/13` and `α ≈ 2-√2`.

## 4. Sequence identification

For `α = 1/2` the staircase is `S n = ⌊(n+1)/2⌋ = 0,1,1,2,2,3,3,…`, the classical
position of the last maximal binomial coefficient in row `n` (`⌈n/2⌉`), and the
increment word is the periodic word `(10)^ω`.  For `α = P/(P+Q)` the staircase is the
Beatty sequence of `P/(P+Q)` shifted by one index; the increment words are the periodic
balanced (Christoffel) words of slope `P/(P+Q)`.

Everything reported here is reproduced by the Lean theorems in
`Catalog/MachineLearning/SturmianArgmaxStaircase.lean` and
`Catalog/MachineLearning/SturmianArgmaxComplexity.lean`; the tables above are
exploratory data, and the general statements they suggested are proved there without
`sorry`.
