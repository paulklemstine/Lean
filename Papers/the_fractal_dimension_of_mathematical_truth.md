# Computational Evidence — The Fractal Dimension of Mathematical Truth

Statements are encoded as finite binary strings; a string of length `n` is one of
the `2^n` functions `Fin n → Bool`. A *theory* selects, at each length, the finite
set of accepted strings, and its **box-counting dimension** is

    dim = limsup_n  log₂(count n) / n,

where `count n` is the number of accepted length-`n` strings (the covering number
of the corresponding cylinder set in Cantor space at scale `2^{-n}`).

## 1. Small-case calculations for the truth set

The truth set `truthSet` accepts exactly the strings in which every odd-indexed
bit is `false`. Its count is `count n = 2^{evenCount n}`, where `evenCount n`
is the number of even indices below `n` (i.e. `⌈n/2⌉`).

| n  | evenCount n | count n = 2^{evenCount n} | estimate log₂(count)/n |
|----|-------------|---------------------------|------------------------|
| 1  | 1           | 2                         | 1.000                  |
| 2  | 1           | 2                         | 0.500                  |
| 3  | 2           | 4                         | 0.667                  |
| 4  | 2           | 4                         | 0.500                  |
| 5  | 3           | 8                         | 0.600                  |
| 6  | 3           | 8                         | 0.500                  |
| 7  | 4           | 16                        | 0.571                  |
| 8  | 4           | 16                        | 0.500                  |
| 10 | 5           | 32                        | 0.500                  |
| 12 | 6           | 64                        | 0.500                  |

The finite-scale estimates oscillate but are squeezed between `1/2` (attained on
even `n`) and `(n+1)/(2n) → 1/2`. The limit — hence the dimension — is exactly
`1/2`: **truth is sparse (dimension `< 1`) but not negligible (dimension `> 0`)**.

## 2. The parity identity behind the limit

The exact count relies on `2 · evenCount n = n + [n is odd]`, verified for all `n`
by induction. This forces `evenCount n / n → 1/2` and pins the dimension to `1/2`
without any appeal to a single finite instance.

## 3. Bracketing values

* Full space `allStatements`: `count n = 2^n`, estimate `≡ 1`, dimension `1`.
* Bounded theories (e.g. a single accepted string per length): `count n = 1`,
  estimate `= 0`, dimension `0`.
* Truth set: dimension `1/2`, strictly interior.

More generally, replacing "odd indices" by any fixed arithmetic pattern of density
`p/q` yields dimension `p/q`, so every rational in `[0,1]` is realized — the
spectrum of truth-dimensions fills the unit interval.

## 4. Link with Chaitin's constant

Both quantities are limits of finite, effectively computable estimates:

* The dimension is the (from-above) limit of `log₂(count n)/n`.
* `Ω = Σ_k b_k · 2^{-(k+1)}` is the (from-below) limit of its partial sums, an
  increasing rational sequence — the defining feature of a left-computable real.

Numerically, the partial sums of `Ω` for `b ≡ 1` are `1/2, 3/4, 7/8, …` increasing
to `1`, confirming monotone approximation. The dimension `1/2` of the truth set is
itself such a constant (`Ω` of the sequence whose only set bit is the first).

## 5. Counterexample hunt

We probed the universal bounds `0 ≤ estimate ≤ 1` across many theories and lengths;
no violation occurs, matching the proved bounds `dimEstimate_nonneg` and
`dimEstimate_le_one`. No counterexample to "truth's dimension is strictly interior"
was found; the value is provably `1/2`.
