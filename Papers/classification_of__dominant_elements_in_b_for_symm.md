# Computational Evidence — ρ-dominant weights `λ_{D,I}` (simply-laced case)

We test the weight-dominance backbone of the `π_{D,I}` classification.  In the simply-laced
model the generalized Cartan matrix is `A = 2·Id − Adj(G)` for a simple graph `G`, and, using
`⟨ρ, α_iᵛ⟩ = 1`,

```
⟨λ_{D,I}, α_iᵛ⟩ = 2 − ⟨β_I, α_iᵛ⟩ − ⟨β_D, α_iᵛ⟩,   β_S = Σ_{j∈S} α_j.
```

With `I` the whole diagram, the closed forms `⟨β_S, α_iᵛ⟩ = 2 − deg_S i` (for `i ∈ S`) and
`= −deg_S i` (for `i ∉ S`) reduce dominance to the local inequality
`deg i + deg_D i ≥ 2` for every marked vertex `i ∈ D`.

## 1. Small-case calculations

### Path `P₃` (`0 — 1 — 2`)
Degrees, computed in Lean (`#eval`): `deg = [1, 2, 1]`.

Singleton marking `D = {v}` (recall `deg_{{v}} v = 0`): dominant iff `deg v ≥ 2`.

| vertex `v` | `deg v` | `λ_{{v},I}` dominant? |
|-----------:|:-------:|:---------------------:|
| 0 (leaf)   |   1     | **no**  |
| 1 (center) |   2     | yes     |
| 2 (leaf)   |   1     | **no**  |

Lean `#eval decide (2 ≤ deg v)` returns `[false, true, false]`, matching the table and the
theorem `tree_leaf_singleton_not_dominant` (the two leaves have no dominant singleton).

### Star `K_{1,3}` (center `c`, leaves `a,b,d`)
Degrees: `deg c = 3`, `deg (leaf) = 1`.

* `D = {c}`: `deg c = 3 ≥ 2` → dominant.
* `D = {leaf}`: `deg = 1 < 2` → not dominant.
* `D = {a,b}` (two leaves, non-adjacent): for `a`, `deg a + deg_D a = 1 + 0 = 1 < 2` → not dominant.
* `D = {c, a}`: `c` gives `3 + 1 = 4 ≥ 2`; `a` gives `1 + 1 = 2 ≥ 2` → **dominant** (the marked
  leaf `a` is "rescued" by having its neighbour `c` also marked, so `deg_D a = 1`).

This last row illustrates the genuine content of `dominant_univ_iff`: it is `deg i + deg_D i`,
not `deg i` alone, that governs dominance — a marked leaf can be admissible when its unique
neighbour is also marked.

### Cycle `C₃` (a triangle — *excluded* by "no cycle of length ≥ 3")
Every degree is `2`, so `dominant_of_min_degree` applies and `D = univ` is dominant.  This is
consistent but lies outside the forest hypothesis, confirming that `dominant_univ_iff` itself
does **not** require acyclicity — only the leaf-scarcity corollary does.

## 2. Degree-sum sanity check (trees)

`tree_sum_degrees`: for a tree on `n` vertices, `Σ deg = 2(n−1)`.

| tree        | `n` | `Σ deg` | `2(n−1)` |
|-------------|:---:|:-------:|:--------:|
| `P₃`        |  3  |  1+2+1=4|    4     |
| `K_{1,3}`   |  4  | 3+1+1+1=6|   6     |
| single edge |  2  |  1+1=2  |    2     |

Averaging `2(n−1) < 2n` forces a vertex of degree `≤ 1`: the leaf whose singleton fails
dominance.

## 3. Counterexample hunt

We searched for a **tree** with no leaf (which would break `tree_has_leaf` and hence the leaf
obstruction).  None exists: `Σ deg = 2(n−1) < 2n` makes "all degrees `≥ 2`" impossible for any
finite tree, so the universal claim survives.  We also checked that dropping the `i ∈ D`
restriction in `dominant_univ_iff` is necessary: for `i ∉ D` the coordinate is `deg i + deg_D i
≥ 0`, automatically nonnegative, so unmarked vertices never obstruct dominance.

## 4. OEIS note

No new integer sequence is introduced; the enumerated quantities (leaf counts, degree sums of
trees) are classical (`Σ deg = 2·#edges`, handshaking).  The evidence is structural rather than
sequence-generating, so no OEIS lookup was warranted.
