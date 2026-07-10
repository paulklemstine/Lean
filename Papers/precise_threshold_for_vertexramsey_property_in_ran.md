# Computational Evidence — vertex-Ramsey threshold on complete graphs

The theorem proved in `Catalog/Novelty/VertexRamseyThreshold.lean` is the exact
threshold

> `Kₙ →_v (K_{s₀}, …, K_{s_{r-1}})`  ⇔  `∑ᵢ (sᵢ − 1) < n`   (each `sᵢ ≥ 1`),

i.e. the vertex-Ramsey number of a clique family is `N(s) = 1 + ∑ᵢ (sᵢ − 1)`.
This is the deterministic base case underlying the random-perturbation
conjecture in the mission statement.

## 1. Small-case calculations

For `r` colours, all targets equal to `K_t` (`sᵢ ≡ t`):

| r | t | N(s) = 1 + r(t−1) | meaning |
|---|---|-------------------|---------|
| 2 | 2 | 3 | any 2-colouring of `K₃` has a monochromatic edge |
| 2 | 3 | 5 | any 2-colouring of `K₅` has a monochromatic triangle |
| 3 | 2 | 4 | any 3-colouring of `K₄` has a monochromatic edge |
| r | 2 | r+1 | pigeonhole: r+1 vertices, r colours ⇒ repeat |
| 2 | t | 2t−1 | balanced 2-colouring of `K_{2t−2}` avoids `K_t` |

These are exactly `1 + ∑ᵢ (sᵢ − 1)` and match the classical pigeonhole values.
Two of them are checked in Lean by `decide`
(`triangle_two_colour_edge`, `edge_two_colour_no_edge`).

## 2. Sanity check of both directions

* **Upper (arrows).** With `n > ∑(sᵢ−1)`, in any colouring some class `i` has
  `≥ sᵢ` vertices (generalised pigeonhole `exists_large_fiber_finset`); in the
  complete graph those vertices form a clique.
* **Lower (extremal colouring).** With `n ≤ ∑(sᵢ−1)`, distribute the `n`
  vertices into bins of capacity `sᵢ−1` (`exists_bounded_coloring`, via an
  embedding `V ↪ Σᵢ Fin(sᵢ−1)`); every colour class then has `< sᵢ` vertices,
  so no monochromatic `K_{sᵢ}` exists.

Example `r = 2, s = (3,3)`: `∑(sᵢ−1) = 4`, so `N = 5`. Colour `K₄` with two
colour classes of size 2 → no monochromatic triangle. `K₅` cannot be split
`2+2`, so some class has 3 vertices → a monochromatic triangle. ✓

## 3. Counterexample hunt

The universal statement is the `↔` above. The only subtlety is the hypothesis
`sᵢ ≥ 1`: if some `sᵢ = 0`, a monochromatic `K₀ = ∅` always exists, so the
property holds vacuously for **every** `n` and the threshold formula (which
would give `N` too small) fails. This is why `sᵢ ≥ 1` is assumed in
`completeGraph_vertexArrows_iff` and `completeGraph_not_vertexArrows`; the
positive direction `completeGraph_vertexArrows` needs no such hypothesis. No
other counterexamples were found.

## 4. OEIS

`N(r) = r + 1` (edge case, `t = 2`) is A000027 (naturals). The two-parameter
family `1 + r(t−1)` is the standard vertex-Ramsey number of cliques and is not a
single OEIS entry.
