# Computational Evidence — Deep Tent Efficiency / Width-vs-Depth

Mission: ML Universal Approximation, width vs depth trade-offs. We add the
**deep upper-bound** side that complements the catalog's shallow lower bound
(`TentDepthSeparation.depth_separation_width_lower_bound`).

## 1. The tent map is exactly 2 ReLU neurons

Claim: `tent x = 1 - |2x-1| = 1 - relu(2x-1) - relu(1-2x)` since `|y| = relu(y) + relu(-y)`.

Verified at the 9 dyadic nodes `i/8`, `i = 0..8` (`#eval`):

| x    | 1-|2x-1| | 1 - max(2x-1,0) - max(1-2x,0) |
|------|----------|-------------------------------|
| 0.0  | 0.00     | 0.00 |
| 0.125| 0.25     | 0.25 |
| 0.25 | 0.50     | 0.50 |
| 0.375| 0.75     | 0.75 |
| 0.5  | 1.00     | 1.00 |
| 0.625| 0.75     | 0.75 |
| 0.75 | 0.50     | 0.50 |
| 0.875| 0.25     | 0.25 |
| 1.0  | 0.00     | 0.00 |

Exact agreement at every sample. (Formalized: `tentBlock_eval`.)

## 2. Deep size (2k) vs oscillation count / shallow width (2^k)

`tent^[k]` has `2^k` oscillations (catalog `tent_discreteTV`). The deep net
that realizes it is `k` stacked copies of the 2-neuron block, total size `2k`.

`#eval` of `(2*k, 2^k)`:

```
[(0,1),(2,2),(4,4),(6,8),(8,16),(10,32),(12,64),(14,128),(16,256)]
```

Deep size `2k` is strictly below the oscillation count `2^k` for all `k ≥ 3`
(6 < 8, 8 < 16, ...), and the gap grows exponentially. This is the width-vs-depth
separation: depth `k` ↔ `O(log N)` deep neurons vs `Ω(N)` shallow neurons,
where `N = 2^k` is the oscillation count. (Formalized: `two_mul_lt_two_pow`,
`deep_size_log`, `depth_width_separation`.)

## 3. No counterexample to the 2-neuron identity

Tested across the dyadic grid; the affine + 2-ReLU form is an exact equality
(not an approximation), so there is nothing to falsify — it is an algebraic
identity, proved in Lean rather than only sampled.
