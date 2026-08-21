# Computational evidence: counting even closed walks

All numbers below were produced by `#eval` on the *formal* definition
`EvenWalks.evenClosedWalkCount` (file `Catalog/Combinatorics/EvenClosedWalks.lean`),
which is the same definition the theorems are proved about.  Every entry marked
"proved" is additionally backed by a `sorry`-free Lean theorem; the remaining rows are
exploratory data used to guess the formulas before proving them.

## 1. Small-case table

`evenClosedWalkCount N L` = number of maps `w : Fin L → Fin N` such that
`w t ≠ w (t+1)` for all `t` (indices cyclic) and every edge `{w t, w (t+1)}` is
traversed an even number of times.

| L \ N | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 | 0 | 0 | – | – |
| 2 | 0 | 0 | 2 | 6 | 12 | 20 | – |
| 3 | 0 | 0 | 0 | 0 | 0 | – | – |
| 4 | 0 | 0 | 2 | 18 | 60 | – | – |
| 5 | 0 | 0 | 0 | 0 | – | – | – |
| 6 | 0 | 0 | 2 | 66 | 372 | 1220 | 3030 |

Observations that became theorems:

* every odd row vanishes identically — proved as
  `EvenWalks.evenClosedWalkCount_eq_zero_of_odd`;
* row `L = 2` is `N(N-1)` — proved as `evenClosedWalkCount_two`;
* row `L = 4` is `N(N-1)(2N-3)` — proved as `evenClosedWalkCount_four`
  (check: `N = 3 → 3·2·3 = 18`, `N = 4 → 4·3·5 = 60`);
* row `L = 6` fits `N(N-1)(5N² - 15N + 11)` — proved as
  `evenClosedWalkCount_six_real`
  (check: `N = 3 → 6·11 = 66`, `N = 4 → 12·31 = 372`, `N = 5 → 20·61 = 1220`,
  `N = 6 → 30·101 = 3030`).

## 2. The binomial (shape) basis

Dividing the `L = 6` row by binomial coefficients suggested the decomposition
`count(N,6) = 2·C(N,2) + 60·C(N,3) + 120·C(N,4)`:

| N | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|
| `2C(N,2)` | 2 | 6 | 12 | 20 | 30 |
| `60C(N,3)` | 0 | 60 | 240 | 600 | 1200 |
| `120C(N,4)` | 0 | 0 | 120 | 600 | 1800 |
| total | 2 | 66 | 372 | 1220 | 3030 |

This matches the table exactly and became the theorem
`EvenWalks.evenClosedWalkCount_six`, with the general statement
`evenClosedWalkCount_eq_sum_choose` proved for all lengths.  The three shape counts
`2, 60, 120` are verified by exhaustive kernel evaluation (`decide`, no
`native_decide`), and the vanishing of the shape counts for five or more vertices is
proved from the vertex bound rather than computed.

## 3. Structural sanity check on the top shape

The `120` walks on four vertices decompose as `12` labelled path trees contributing
`6` closed walks each and `4` labelled star trees contributing `12` each:
`12·6 + 4·12 = 120`.  The same pattern at lengths `2` and `4` gives `2` and `12`, and

| k | length `2k` | top shape count | `catalan k · (k+1)!` |
|---|---|---|---|
| 1 | 2 | 2 | `1 · 2 = 2` |
| 2 | 4 | 12 | `2 · 6 = 12` |
| 3 | 6 | 120 | `5 · 24 = 120` |

all three rows are proved in `Catalog/Combinatorics/EvenWalkCatalanShapes.lean`.
The general identity is conjectured in `FUTURE_DIRECTIONS.md`.

## 4. Counterexample hunt

The universal claims were tested before being proved:

* "all odd counts vanish": verified for `L ∈ {1,3,5}` and `N ≤ 4`; no counterexample
  (now proved for all `N`, all odd `L`).
* "an even closed walk of length `L` visits at most `L/2 + 1` vertices": the `L = 6`
  data confirms it — no even 6-walk uses five vertices (the `N = 5` count `1220`
  is exactly `2C(5,2)+60C(5,3)+120C(5,4)`, with no `C(5,5)` term).  Proved in
  `Catalog/Combinatorics/EvenWalkVertexBound.lean`.
* "the count is a polynomial in `N`": every row of the table is reproduced by the
  binomial expansion; proved in general.

## 5. OEIS

The sequence of sixth-moment counts `2, 66, 372, 1220, 3030` (for `N = 2,3,4,5,6`)
and the shape triple `(2, 60, 120)` were not matched against OEIS; no OEIS
identification is claimed here.
