# Computational Evidence — sharpness of the power-sum window `k ≤ N`

All numbers below were produced by `#eval` inside Lean 4 (mathlib4, `v4.28.0`), using the
enumeration code reproduced at the end of this file. The *claims* they support are proved
without any appeal to computation in `Catalog/Shared/PowerSumSharpness.lean`.

Setting: a multiset `s` of naturals with all elements `≤ N` is encoded by its multiplicity
vector `c = (c_0, …, c_N)`, and its power sums are `p_k = ∑_j c_j · j^k`.

## 1. Exhaustive collision search

For each level `N` we enumerated *all* multiplicity vectors with entries `≤ M`, i.e.
`(M+1)^(N+1)` multisets, and counted unordered pairs of **distinct** vectors whose power-sum
vectors `(p_0, …, p_K)` coincide.

| `N` | `M` | #multisets | collisions at `K = N` | collisions at `K = N − 1` |
|-----|-----|-----------|-----------------------|---------------------------|
| 1   | 2   | 9         | **0**                 | 5                         |
| 2   | 1   | 8         | **0**                 | 0                         |
| 2   | 2   | 27        | **0**                 | 4                         |
| 2   | 3   | 64        | **0**                 | 18                        |
| 3   | 2   | 81        | **0**                 | 0                         |
| 3   | 3   | 256       | **0**                 | 9                         |
| 4   | 1   | 32        | **0**                 | 0                         |

Reading of the table:

* The column `K = N` is identically `0`. This is the exhaustive-search shadow of the theorem
  `powerSums_determine`.
* The column `K = N − 1` is nonzero as soon as the multiplicities are allowed to reach
  `max_j C(N,j)`: for `N = 2` one needs multiplicity `2` (`C(2,1) = 2`), for `N = 3`
  multiplicity `3` (`C(3,1) = C(3,2) = 3`). The rows with `M` below that threshold report
  `0` collisions — a genuine near-counterexample to naive sharpness which the binomial
  construction explains exactly.
* The counts grow with `M` (4 → 18 when `M` goes 2 → 3 at `N = 2`), consistent with
  `infinitely_many_near_misses`.

## 2. The first witness found, per level

| `N` | first colliding pair (as multiplicity vectors) | as multisets |
|-----|------------------------------------------------|--------------|
| 2   | `([0,2,0], [1,0,1])`                            | `{1,1}` vs `{0,2}` |
| 3   | `([0,3,0,1], [1,0,3,0])`                        | `{1,1,1,3}` vs `{0,2,2,2}` |

These are precisely `oddPart N` and `evenPart N`, the multisets carrying multiplicity
`C(N,j)` at the odd, resp. even, values `j ≤ N`. In Lean:
`evenPart 2 = {0,2}`, `oddPart 2 = {1,1}`, `evenPart 3 = {0,2,2,2}`, `oddPart 3 = {1,1,1,3}`
(all four verified by `decide`). So the catalog's `(0,2)` / `(1,1)` example is level `2` of an
infinite family.

## 3. Power sums of the extremal pair

`(p_k(evenPart N), p_k(oddPart N))`:

* `N = 4`: `(8,8), (16,16), (40,40), (112,112), (352,328)` — agreement for `k ≤ 3`,
  gap `352 − 328 = 24 = 4!` at `k = 4`.
* `N = 5`: `(16,16), (40,40), (120,120), (400,400), (1440,1440), (5440,5560)` — agreement for
  `k ≤ 4`, gap `5440 − 5560 = −120 = −5!` at `k = 5`.

This is the content of `powerSum_evenPart_eq_oddPart` and
`powerSum_evenPart_sub_oddPart_top` (`gap = (-1)^N · N!`).

## 4. The alternating table `A(N,k) = ∑_{j≤N} (-1)^j C(N,j) j^k`

```
N=0: [1]
N=1: [0, -1]
N=2: [0, 0, 2]
N=3: [0, 0, 0, -6]
N=4: [0, 0, 0, 0, 24]
N=5: [0, 0, 0, 0, 0, -120]
N=6: [0, 0, 0, 0, 0, 0, 720]
N=7: [0, 0, 0, 0, 0, 0, 0, -5040]
N=8: [0, 0, 0, 0, 0, 0, 0, 0, 40320]
```

Strictly lower triangular with diagonal `(-1)^N N!`. The diagonal sequence
`1, 1, 2, 6, 24, 120, 720, 5040, 40320` is **OEIS A000142** (factorials); the row cardinalities
`|evenPart N| = |oddPart N| = 2^{N-1}` for `N ≥ 1` are **OEIS A000079**. Both are reproved
formally: `alternating_choose_pow`, `alternating_choose_pow_self`.

## 5. Counterexample hunt against the rigidity claim

The universal claim under test is: *bounded by `N` + equal `p_k` for all `k ≤ N` ⟹ equal.*
The search of §1 tests it on `9 + 8 + 27 + 64 + 81 + 256 + 32 = 477` multisets, i.e. on
`≈ 3.9 · 10^4` unordered pairs, and finds **no counterexample**. Separately, the punctured
claim (drop `k = 0`, keep `1 ≤ k ≤ N`) *does* have counterexamples, all of the form
`s` vs `s + {0,…,0}` — e.g. `{0}` vs `∅` — which is why the formal statement
`powerSums_determine_of_pos` excludes the value `0` and `zero_index_needed` records the
obstruction.

## 6. Reproduction code

```lean
import Mathlib

def vecs : ℕ → ℕ → List (List ℕ)
  | 0, _ => [[]]
  | (n+1), M => (List.range (M+1)).flatMap fun a => (vecs n M).map fun v => a :: v

def psums (v : List ℕ) (K : ℕ) : List ℕ :=
  (List.range (K+1)).map fun k => (v.zipIdx.map fun p => p.1 * p.2 ^ k).sum

def pairsColl (N M K : ℕ) : List (List ℕ × List ℕ) :=
  let vs := (vecs (N+1) M).zipIdx
  vs.flatMap fun p => vs.filterMap fun q =>
    if p.2 < q.2 ∧ psums p.1 K = psums q.1 K then some (p.1, q.1) else none

def alt (N k : ℕ) : ℤ :=
  ((List.range (N+1)).map fun j => (-1:ℤ)^j * (Nat.choose N j) * (j:ℤ)^k).sum

#eval (pairsColl 2 2 2).length          -- 0
#eval (pairsColl 2 2 1).length          -- 4
#eval (pairsColl 3 3 3).length          -- 0
#eval (pairsColl 3 3 2).length          -- 9
#eval (pairsColl 3 3 2).take 1          -- [([0,3,0,1], [1,0,3,0])]
#eval (List.range 9).map fun N => (List.range (N+1)).map fun k => alt N k
```
