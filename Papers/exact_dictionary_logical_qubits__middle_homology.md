# Computational Evidence

The conjectures settled this cycle are structural statements of finite-dimensional
linear algebra, so "evidence" takes the form of checking the exact dimension
bookkeeping on small explicit complexes. Every check below is subsumed by a
Lean theorem in `LogicalDimension.lean`.

## Conjecture 3 — realizability (rank prescription)

Model: `B = Kʳ × Kˢ × Kᵐ`, `d₁ = fst` (kills the last two factors),
`d₂ = inclusion of Kˢ` into the middle factor. Then
`ker d₁ = Kˢ × Kᵐ`, `im d₂ = Kˢ ⊆ ker d₁`, so `k = dim(ker d₁) − dim(im d₂) = m`.

| r | s | m | dim B = r+s+m | rank d₁ | rank d₂ | k = m |
|---|---|---|---------------|---------|---------|-------|
| 0 | 0 | 1 | 1             | 0       | 0       | 1     |
| 1 | 1 | 0 | 2             | 1       | 1       | 0     |
| 2 | 1 | 3 | 6             | 2       | 1       | 3     |
| 3 | 2 | 0 | 5             | 3       | 2       | 0     |

Every `(dim B, k)` with `k ≤ dim B` is hit (set `s = 0`, `r = dim B − k`,
`m = k`). Verified in general by `realizable_pair`, `realizable_le`,
`realizable_ranks`.

## Conjecture 4 — CSS self-duality

The dimension formula gives `k = dim B − rank d₁ − rank d₂`. Transposing swaps
the two check families but preserves each rank (`rank fᵀ = rank f`) and the
middle dimension (`dim B* = dim B`), hence `k` is unchanged.

Sample check on the rank-prescription model above with `(r,s,m) = (2,1,3)`:
- primal: `k = 6 − 2 − 1 = 3`.
- dual: `dim B* = 6`, `rank d₁ᵀ = 2`, `rank d₂ᵀ = 1`, so `k* = 6 − 2 − 1 = 3`. ✔

Proved in general by `numLogical_dual`.

## Conjecture 2 — code rate `1 − (V−1)/E`

For a connected graph complex `k = E − V + 1`, so `k/E = 1 − (V−1)/E`.

| graph                | V | E | k = E−V+1 | rate k/E |
|----------------------|---|---|-----------|----------|
| tree on 4 vertices   | 4 | 3 | 0         | 0        |
| 4-cycle `Q₂`         | 4 | 4 | 1         | 1/4      |
| `K₄`                 | 4 | 6 | 3         | 1/2      |
| bouquet of 5 loops   | 1 | 5 | 5         | 1        |
| hypercube `Q₄`       | 16| 32| 17        | 17/32    |

The endpoints (rate 0 = trees, rate 1 = single-vertex bouquets) are proved by
`rate_tree` and `rate_bouquet`; the formula by `rate_eq`. The hypercube column
matches the previous cycle's `Hypercube.betti1` values (17 for `Q₄`).

## Conjecture 1 — distance (not formalized)

Girth data for the hypercube `Qₙ` (`n ≥ 2`): shortest cycle length 4, no
triangles, so girth = 4 independent of `n`. Compared to the quantum Singleton
target `2^{n/2}`: 4 < 2^{n/2} for all `n ≥ 5`. These are elementary once a
homological distance is defined; the modeling of minimum-weight cycles is left
to a future cycle.
