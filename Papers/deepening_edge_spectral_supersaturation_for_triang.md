# Computational evidence — spectral/combinatorial trace bridges

This cycle deepens `EdgeSpectralSupersaturationTriangles.lean` by *discharging*
its two trace hypotheses for a genuine graph adjacency matrix.  The new bridges are

* `tr(A²) = 2 · (#edges)`,
* `tr(A³) = 6 · (#triangles)`.

Both are classical facts of algebraic graph theory; below is the small-case evidence
confirming the exact constants `2` and `6`.

## 1. Small cases (adjacency matrix over ℝ)

For a simple graph `G` with adjacency matrix `A`:

* `(A²)_{ii} = deg(i)`, so `tr(A²) = Σ_i deg(i) = 2m` (handshake lemma).
* `(A³)_{ii} = #{closed walks i → · → · → i}`, so `tr(A³) = Σ_i (…)` counts all
  closed `3`-walks, and each triangle `{x,y,z}` supplies exactly `3! = 6` of them
  (`3` choices of start vertex × `2` directions).

| Graph            | #edges m | #triangles t | tr(A²) | tr(A³) | 2m | 6t |
|------------------|:--------:|:------------:|:------:|:------:|:--:|:--:|
| `K₃` (triangle)  | 3        | 1            | 6      | 6      | 6  | 6  |
| `K₄`             | 6        | 4            | 12     | 24     | 12 | 24 |
| `P₃` (path)      | 2        | 0            | 4      | 0      | 4  | 0  |
| `C₄` (4-cycle)   | 4        | 0            | 8      | 0      | 8  | 0  |
| `C₅` (5-cycle)   | 5        | 0            | 10     | 0      | 10 | 0  |

Every row satisfies `tr(A²) = 2m` and `tr(A³) = 6t`, matching the two bridge
theorems.  The `K₃` row is formalized directly (`completeGraph_three_counts`,
`completeGraph_three_trace_sq`, `completeGraph_three_trace_cube`).

## 2. The `3! = 6` counting core

The purely combinatorial fact underlying the triangle bridge is `card_ordered_triples`:
a `3`-element set `s` underlies exactly `6` ordered triples `(x,y,z)` with
`{x,y,z} = s`.  Enumeration for `s = {0,1,2}`:

```
(0,1,2) (0,2,1) (1,0,2) (1,2,0) (2,0,1) (2,1,0)   -- 6 permutations
```

These are the `3!` orderings; the lemma is proved by identifying the filter with this
explicit `6`-element finset.

## 3. Supersaturation sanity check on `K₃`

With `A(K₃)` having spectrum `{2, -1, -1}`: `λ = 2`, `m = 3`, `t = 1`, spectral excess
`q = λ² - m = 1`.  The graph bound `λ·q ≤ 3t` reads `2 ≤ 3` — a genuine, non-vacuous
triangle guarantee, consistent with the abstract `K3_supersaturation_example` from the
companion file.

## Conclusion

The constants `2` and `6` in the two bridges are confirmed across all tested small
graphs, and the `3! = 6` count is verified by explicit enumeration.  No
counterexamples were found; the formal proofs make the identities exact.
