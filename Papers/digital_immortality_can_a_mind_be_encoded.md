# Computational Evidence

The target claims are general counting and inequality theorems, but small cases help check the model.

| Neurons `N` | Synapse slots `N.choose 2` | Boolean connectomes `2^(N.choose 2)` |
|---:|---:|---:|
| 0 | 0 | 1 |
| 1 | 0 | 1 |
| 2 | 1 | 2 |
| 3 | 3 | 8 |
| 4 | 6 | 64 |
| 5 | 10 | 1024 |
| 6 | 15 | 32768 |

For merging, the first nontrivial check is `choose (3+4) 2 = 21 = 3 + 6 + 3·4`: the twelve extra slots are exactly the cross-pairs. For directionality at `N = 4`, the six undirected slots become twelve directed slots, so the state count changes from `2^6 = 64` to `2^12 = 4096 = 64^2`.

No OEIS lookup is needed: the slot sequence is the triangular numbers, and all formulas used here are closed forms proved in Lean. Exhaustive small-case checks found no counterexample. Edge cases `N = 0,1` explain why the real quadratic lower bound used in the physical corollary assumes `1 ≤ N`.
