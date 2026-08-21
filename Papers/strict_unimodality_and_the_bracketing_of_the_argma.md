# Computational evidence for the bracketing-degree theorems

All computations below were run in Lean 4 over `ℚ` (exact arithmetic, no floating
point) before the formal proofs were written.  They test the two candidate formulas

* lower bracketing degree `d⁻ = ⌈θ⌉₊ - 1`,
* upper bracketing degree `d⁺ = ⌊θ⌋₊`,

against a brute-force computation of the maximiser set of the weight sequence.

## 1. Binomial weights `C(n,k) p^k q^(n-k)`, `θ = (n+1)p/(p+q)`

Sweep: `n ∈ {1,2,3,4,5,6,7,8,12,17,30}` × `(p,q) ∈ {(1,1),(1,2),(2,1),(3,5),(1,4),
(7,3),(5,5),(2,3)}` — 88 cases.  For each case the brute-force maximiser set was
compared with `[d⁻, d⁺]` (a singleton when `d⁻ = d⁺`).

```
counterexamples found: []      -- empty list: all 88 cases agree
```

Sample values:

| n | p | q | θ | maximiser set (brute force) | (d⁻, d⁺) |
|---|---|---|---|---|---|
| 5 | 1 | 1 | 3   | `[2, 3]` | `(2, 3)` |
| 6 | 1 | 1 | 7/2 | `[3]`    | `(3, 3)` |
| 9 | 2 | 1 | 20/3| `[6]`    | `(6, 6)` |

Central case `p = q = 1` (`θ = (n+1)/2`), `n = 0 … 8`:

```
(0,[0]) (1,[0,1]) (2,[1]) (3,[1,2]) (4,[2]) (5,[2,3]) (6,[3]) (7,[3,4]) (8,[4])
```

i.e. the maximiser set is `{n/2}` for even `n` and `{(n-1)/2, (n+1)/2}` for odd `n`:
the gap between the two bracketing degrees is `1` exactly for odd `n`, matching
`choose_bracket_gap`, and the pair `(n/2, (n+1)/2)` matches `choose_firstArgmax`
and `choose_lastArgmax`.

## 2. Poisson weights `lam^k / k!`, `θ = lam`

Sweep: `lam ∈ {1/2, 3/2, 2, 7/2, 9/4, 5, 12, 1/3}`, window `[0, 20]`.

```
counterexamples found: []
```

Integral `lam` (e.g. `lam = 2, 5, 12`) always produced a two-element maximiser set
`{lam - 1, lam}`; non-integral `lam` always produced a singleton `{⌊lam⌋}`.  This is
the content of `poissonWeight_bracket_gap`.

## 3. Binomial versus Poisson brackets under the scaling `p = lam/n`

Window `n = 12`, `q = 1 - lam/n`:

| lam | Poisson maximisers | binomial maximisers |
|---|---|---|
| 1/2 | `[0]`     | `[0]`  |
| 1   | `[0, 1]`  | `[1]`  |
| 5/2 | `[2]`     | `[2]`  |
| 7/2 | `[3]`     | `[3]`  |
| 11/2| `[5]`     | `[5]`  |
| 10  | `[9, 10]` | `[10]` |

In every case the binomial upper bracket is `≥` the Poisson upper bracket and
exceeds it by at most one, as proved in `poisson_binomial_bracket_comparison`.  The
row `lam = 1` shows the inequality can be strict at the *lower* bracket while the
upper brackets coincide, which is why the formal statement is phrased as a
two-sided sandwich rather than an equality.

## 4. OEIS

The sequence of upper bracketing degrees for `p = q = 1`, i.e. `⌊(n+1)/2⌋` for
`n = 0, 1, 2, …`, is `0, 1, 1, 2, 2, 3, 3, 4, 4, …` (A004526, "integers repeated"),
and the lower bracketing degrees `⌊n/2⌋` give the same sequence shifted by one.  No
new sequence arises; the interest is in the *pair* and the exact criterion for the
gap, not in either degree alone.

## 5. Counterexample hunt for the boundary conditions

* Dropping `k + 2 ≤ n` in the strict Newton inequality is fatal: `C(n,n) *
  C(n,n+2) = 0 < C(n,n+1)^2 = 0` is false, which is why `StrictLogConcaveOn` only
  requires the inequality inside the window.
* Dropping `lam < n + 1` in the Poisson statements is fatal: for `lam = 30`,
  `n = 5` the weights are increasing on the whole window, `d⁻ = d⁺ = n = 5`, and
  `⌊lam⌋₊ = 30 ≠ 5`.  This is the reason the hypothesis appears in
  `poissonWeight_thresholdWindow`.
