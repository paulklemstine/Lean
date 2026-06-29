# Computational Evidence — BQM strong chromatic index for bipartite graphs

All computations below were run in Lean (`#eval`) and the headline cases were
re-verified by compiled, `sorry`-free Lean theorems.

## 1. Complete bipartite graphs `K_{m,n}` (the extremal/tight case)

For `K_{m,n}` every two distinct edges are at distance ≤ 1, so the conflict graph
is the complete graph on the `m·n` edges. Hence `χ'_s(K_{m,n}) = m·n`, while
`Δ_A = n`, `Δ_B = m`, so `Δ_A·Δ_B = m·n`. The BQM bound holds **with equality**.

| (m, n) | χ'_s = m·n | Δ_A·Δ_B |
|--------|-----------|---------|
| (1,1)  | 1         | 1       |
| (2,2)  | 4         | 4       |
| (2,3)  | 6         | 6       |
| (3,3)  | 9         | 9       |
| (3,4)  | 12        | 12      |
| (4,5)  | 20        | 20      |

Verified in Lean: `completeBipartite_strongChromaticIndex`, and the concrete
instance `χ'_s(K_{2,3}) = 6`.

## 2. Riordan steep-diagonal row sums `A(n) = ∑_k C(n+k, 2k)` (OEIS A001519)

`A(n) = fib(2n+1)`, the odd-indexed Fibonacci numbers (OEIS A001519:
1, 2, 5, 13, 34, 89, 233, 610, …).

| n | A(n) = ∑_k C(n+k,2k) | fib(2n+1) |
|---|----------------------|-----------|
| 0 | 1   | 1   |
| 1 | 2   | 2   |
| 2 | 5   | 5   |
| 3 | 13  | 13  |
| 4 | 34  | 34  |
| 5 | 89  | 89  |
| 6 | 233 | 233 |
| 7 | 610 | 610 |

This identity is the catalog theorem `pascalRiordanA_eq_fib`.

## 3. Bridge: `χ'_s(K_{A(a), A(b)}) = fib(2a+1)·fib(2b+1)`

| (a, b) | A(a)·A(b) | fib(2a+1)·fib(2b+1) |
|--------|-----------|---------------------|
| (0,0)  | 1         | 1                   |
| (1,2)  | 10        | 10                  |
| (2,3)  | 65        | 65                  |
| (3,3)  | 169       | 169                 |

Verified in Lean: `strongChromaticIndex_riordan_complete_bipartite` and
`strongChromaticIndex_riordan_binomial`.

## 4. Counterexample hunt for the conjecture itself

The full BQM conjecture `χ'_s(G) ≤ Δ_A·Δ_B` for *all* bipartite `G` is open. No
counterexample is known in the literature, and our extremal analysis shows the
complete bipartite family meets the bound exactly (so no counterexample can come
from "denser than complete" — `K_{m,n}` is already the densest bipartite graph on
those parts). We therefore did **not** claim the general upper bound as a
theorem; only the proven lower bound `χ'_s ≥ Δ_A` and the complete-bipartite
equality are asserted.
