# Computational Evidence — Erdős Problem 550 (all-ones / Chvátal case)

This note records the small-case landscape that guided the formalization in
`ErdosProblem550Chvatal.lean` and `ErdosProblem550Base.lean`.

## 1. The all-ones reduction

For `1 ≤ m₁ ≤ ⋯ ≤ m_k`, the complete multipartite graph `K_{m₁,…,m_k}` with every
part of size `1` is the complete graph `K_k` (mutually-contained / isomorphic, see
`completeGraph_isContained_allOnes` and `allOnes_isContained_completeGraph`).  Hence
the Erdős–550 bound

  `R(T, K_{m₁,…,m_k}) ≤ (k-1)(R(T, K_{m₁,m₂}) - 1) + m₁`

specializes, at `m₁ = ⋯ = m_k = 1`, to

  `R(T, K_k) ≤ (k-1)(R(T, K₂) - 1) + 1 = (k-1)(n-1) + 1`,

since `R(T, K₂) = n` for any `n`-vertex tree (`ramsey_tree_edge`).  This right-hand
side is exactly **Chvátal's theorem** `R(T_n, K_k) = (k-1)(n-1) + 1`, so the all-ones
case of the conjecture is equivalent to Chvátal's theorem.

## 2. Small-case table of `R(T_n, K_k) = (k-1)(n-1) + 1`

Chvátal's exact values (used as the target the lower-bound construction must match):

| n \ k |  k=2 |  k=3 |  k=4 |  k=5 |
|-------|------|------|------|------|
| n=1   |  1   |  1   |  1   |  1   |
| n=2   |  2   |  3   |  4   |  5   |
| n=3   |  3   |  5   |  7   |  9   |
| n=4   |  4   |  7   | 10   | 13   |
| n=5   |  5   |  9   | 13   | 17   |

Entry `(n,k)` is `(k-1)(n-1)+1`.  The **lower bound** proven in this cycle states that
the colouring `blockGraph (k-1) (n-1)` on `(k-1)(n-1)` vertices has no red `T` and no
blue `K_k`, i.e. `R(T_n, K_k) > (k-1)(n-1)`, matching each table entry from below.

## 3. The extremal colouring `blockGraph (k-1) (n-1)`

Red graph = disjoint union of `k-1` cliques, each on `n-1` vertices.

* Red components have `n-1 < n` vertices, so the connected `n`-vertex tree cannot embed
  (verified abstractly via "graph homs preserve reachability", `no_red_connected`).
* Blue graph = complete `(k-1)`-partite, so its largest clique is a transversal of size
  `k-1 < k` (pigeonhole on block indices, `no_blue_clique`).

### Boundary check (counterexample hunt for the *statement*)

The naive statement "for all `k`" is **false** at `k = 0`: there `(k-1)` truncates to `0`
in `ℕ`, the host `K₀` is empty, and `K₀` is vacuously contained in every blue graph, so
`RamseyArrows 0 T K₀` holds and the lower bound fails.  This was found by an automated
disproof search and is the reason the theorems carry the hypothesis `1 ≤ k` (the problem
itself assumes `k ≥ 2`).  For every `k ≥ 1` and every `n ≥ 1` the construction works.

## 4. Why no OEIS entry is needed

`R(T_n, K_k) = (k-1)(n-1)+1` is a closed-form bilinear expression, not an irregular
integer sequence, so an OEIS lookup is not informative here.  The diagonal `R(T_n, K_n)
= (n-1)² + 1` gives `1, 2, 5, 10, 17, 26, …` (`A002522`, `n²+1` shifted), consistent with
the table above.
