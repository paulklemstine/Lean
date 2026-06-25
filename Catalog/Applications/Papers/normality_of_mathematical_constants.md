# Computational Evidence — Simple Normality of Digit Streams

All numbers below were computed in Lean (`#eval`) with
`countDigit b s d n = #{ k < n : s k = d }`.

## 1. The cyclic stream `cyc b k = k mod b` (base 10)

Digit counts among the first `n` terms, for digits `0..9`:

| `n`   | counts `[d=0 .. d=9]` |
|-------|------------------------|
| 1000  | `[100,100,100,100,100,100,100,100,100,100]` |
| 1003  | `[101,101,101,100,100,100,100,100,100,100]` |

* At `n = 1000` (a multiple of `b = 10`) every digit occurs **exactly** `n/b = 100`
  times, so each empirical frequency is exactly `1/10`.
* At `n = 1003` the boundary correction appears precisely for the digits
  `d < n mod b = 3`, matching the exact formula
  `countDigit (cyc b) d n = n/b + [d mod b < n mod b]`
  (`NormalConstants.cyc_count`), and the discrepancy is `O(1)`.

This is the computational shadow of `cyc_simplyNormal`: the deterministic block
structure pins the frequency to `1/b` with discrepancy at most `1`.

## 2. The eventually-constant stream (terminating rational)

`ec` has digits `7,3,1,4,1` and then `0` forever (the base-10 stream of a
terminating rational). Counts at `n = 1000`:

```
[995, 2, 0, 1, 1, 0, 0, 1, 0, 0]
```

Digit `0` already owns `995/1000 = 0.995` of the mass and the share `→ 1`, while
every other digit's frequency `→ 0`. So no digit approaches `1/10`: the stream is
**not** simply normal, illustrating `not_simplyNormal_of_eventually_const`.

## 3. Counterexample hunt for the obstruction theorems

* `not_simplyNormal_of_freq_tendsto`: searched for a digit with `freq → L ≠ 1/b`
  inside a normal stream — impossible by uniqueness of limits (no counterexample).
* The `b = 1` degenerate alphabet: with one digit, `freq ≡ 1 = 1/1`, so *every*
  stream is "simply normal" and the obstruction theorems are genuinely false
  there. This is exactly why the obstruction results assume `2 ≤ b`; the boundary
  is recorded in code, not hidden.

## 4. OEIS

The cyclic-count sequence `a(n) = countDigit (cyc 10) 0 n = ⌈n/10⌉`-type block
count is the elementary "n div 10 with boundary" and not a distinctive OEIS entry;
no nontrivial integer sequence requiring OEIS lookup arises in this cycle.
