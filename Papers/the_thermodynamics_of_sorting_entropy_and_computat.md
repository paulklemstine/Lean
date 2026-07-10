# Computational Evidence — The Thermodynamics of Sorting

All conjectures below were checked in Lean with `#eval` before formalization.

## 1. Decision-tree / entropy lower bound

A binary tree of height `h` has at most `2^h` leaves; a correct comparison sort must have
`≥ n!` leaves, so its worst-case comparison count (height) is `≥ ⌈log₂(n!)⌉ = clog 2 (n!)`.

| n | n! | ⌈log₂(n!)⌉ = clog 2 (n!) | n·log₂ n (approx) |
|---|----|--------------------------|-------------------|
| 2 | 2  | 1  | 2  |
| 3 | 6  | 3  | 4.75 |
| 4 | 24 | 5  | 8  |
| 5 | 120| 7  | 11.6 |
| 6 | 720| 10 | 15.5 |
| 12| 4.8e8 | 29 | 43 |

Note the classic subtlety: `⌈log₂(12!)⌉ = 29`, yet 12 elements provably require **30**
comparisons — the entropy bound is not always tight (see FUTURE_DIRECTIONS).

## 2. Factorial lower bound `(n/2)^(n/2) ≤ n!`

Verified for all `n < 20`: `(List.range 20).all (fun n => (n/2)^(n/2) ≤ n!) = true`.

## 3. `log₂(n!) = Ω(n log n)`: `(n/2)·⌊log₂(n/2)⌋ ≤ ⌊log₂(n!)⌋`

Verified for all `n < 60` (`= true`).

## 4. `k·⌊log_b a⌋ ≤ ⌊log_b(a^k)⌋`

Verified for all `a < 12`, `k < 8` (`= true`).

## 5. Bubble sort comparison count (contrarian correction)

The brief claims bubble sort does `n²` comparisons. The true count is `∑_{i<n} i = n(n-1)/2`.

Exact identity `2·C(n) + n = n²` verified for all `n < 60` (`= true`), i.e. `C(n) = (n²-n)/2`.

| n | bubble C(n)=n(n-1)/2 | claimed n² | overcount factor |
|---|----------------------|-----------|------------------|
| 2 | 1   | 4    | 4.0  |
| 4 | 6   | 16   | 2.67 |
| 10| 45  | 100  | 2.22 |
| 100| 4950 | 10000 | 2.02 |

So the quoted `n²` overcounts by a factor approaching 2 (never equal): the conjecture
`W_bubble = kT·n²` is quantitatively false.

## 6. Bubble sort respects the entropy floor

`(n/2)·⌊log₂(n/2)⌋ ≤ n(n-1)/2` verified for all `n < 200` (`= true`): bubble sort, being a
correct comparison sort, pays at least the `Ω(n log n)` thermodynamic floor (and, for large
`n`, far more — the wasted work).

## 7. Irreversibility

`[0,1].mergeSort (≤)  =  [1,0].mergeSort (≤)  =  [0,1]` — two distinct inputs, one output:
the sorting map is not injective, so it erases information and (by Landauer) does work.
