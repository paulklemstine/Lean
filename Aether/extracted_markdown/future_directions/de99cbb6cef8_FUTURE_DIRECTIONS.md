# Future Directions — Arithmetic Concentration of Nodal Counts

## Synthesis

`NodalCountConcentration.lean` isolates a small, fully-verified *arithmetic core*
underneath the (still open) conjecture on nodal counts of Hecke eigenfunctions on
arithmetic Ramanujan graphs. The whole development hangs on a single engine, the
**Rayleigh identity**

```
nodalEdgeSum G f = lam · energy f ,
```

which says that the signed sum of `f i · f j` over ordered adjacent pairs of an
adjacency eigenfunction is exactly `lam` times the L²-energy. Everything else is a
corollary obtained with elementary inequalities, so the graph-arithmetic content
(Ramanujan, Hecke) enters *only* through the spectral hypothesis `|lam| ≤ 2√q`:

* `nodal_edge_of_neg_eigenvalue` — a discrete Courant theorem: any negative
  eigenvalue forces a sign change across some edge.
* `ramanujan_gap` — the elementary separation `2√q < q + 1` (for `q ≠ 1`) that
  distinguishes the trivial eigenvalue of a `(q+1)`-regular graph from the Ramanujan
  window, the square-completion `(√q − 1)² > 0`.
* `nodalEdgeSum_le_ramanujan` — under `|lam| ≤ 2√q` the normalized signed nodal sum
  is at most `2√q`.
* `nodal_pair_count_lower_bound` — the headline *concentration* statement: with any
  uniform sup-norm cap `f v² ≤ M`, the number of ordered nodal pairs satisfies
  `(−lam)·energy ≤ (#nodal pairs)·M`. Delocalization (`M ≈ 1/|V|`) converts spectral
  data into a nodal count growing linearly in `|V|`.

## Results summary

| Theorem | Statement | Status |
|---|---|---|
| `rayleigh_identity` | `nodalEdgeSum = lam · energy` | proved, axiom-clean |
| `nodal_edge_of_neg_eigenvalue` | negative eigenvalue ⇒ a nodal edge | proved |
| `ramanujan_gap` | `2√q < q+1` for `q ≠ 1` | proved |
| `nodalEdgeSum_le_ramanujan` | `|nodalEdgeSum| ≤ 2√q · energy` | proved |
| `disagreement_lower_bound` | `(−lam)·energy ≤ Σ_{nodal} −f i f j` | proved |
| `nodal_pair_count_lower_bound` | `(−lam)·energy ≤ #nodal · M` | proved |

## Research directions

### 1. A two-sided nodal-count sandwich

Right now we only have a *lower* bound on the nodal-pair count from a negative
eigenvalue. The symmetric statement should hold: a *positive* eigenvalue near the
upper Ramanujan edge `+2√q` forces a comparable number of *agreement* edges, and
combining the two should sandwich the nodal count of a generic eigenfunction
between `c₁·(−lam)·energy/M` and `c₂·|V|`. The key insight is that the same
ordered-pair splitting that produced `disagreement_lower_bound` applies verbatim to
the positive part, so the *agreement* sum obeys a mirror bound `(lam)·energy ≤
Σ_{agree} f i f j`; subtracting the two filtered sums pins the count from both
sides. Why now? Both halves of the split are already formalized; the positive side
is a copy-paste of an existing proof, making this the cheapest high-value extension.

### 2. Sup-norm delocalization is necessary, not just sufficient

We use `f v² ≤ M` as a hypothesis. Conjecture: for `(q+1)`-regular Ramanujan graphs
the bound is essentially tight — there exist eigenfunctions whose nodal count is
`Θ((−lam)·energy/M)`, so no better universal constant than the one in
`nodal_pair_count_lower_bound` is possible. The key insight is that AM-GM equality
`|f i f j| = M` is achieved exactly when `|f i| = |f j| = √M` across nodal edges, i.e.
by `±√M`-valued (two-level) eigenfunctions; constructing such a function on an
explicit small regular graph (e.g. a cycle `C_n` or a complete bipartite graph) and
computing both sides falsifies or confirms tightness. Why now? The needed objects
are finite and computable in Lean via `decide`/`Finset` evaluation, so a concrete
extremal example can be machine-checked rather than argued informally.

### 3. From ordered pairs to genuine nodal domains

`nodalPairs` counts ordered edges with a sign change; the classical object is the
number of *nodal domains* (connected components of `{f > 0}` and `{f < 0}`).
Conjecture: the number of nodal domains is at most `1 + #nodal edges`, with equality
characterizing trees, giving a Courant-type upper bound
`#domains ≤ 1 + 2√q·energy/m` where `m = min_v f v²` on the support. The key insight
is that contracting every non-nodal edge collapses each nodal domain to a point, so
an Euler-characteristic / spanning-forest count on the contracted graph bounds the
domain count by the nodal-edge count plus components. Why now? Mathlib's
`SimpleGraph.ConnectedComponent` and `SimpleGraph.adjMatrix` are mature enough to
state and manipulate domain counts directly, so the combinatorial bridge can be
built on existing API.

### 4. Quantitative equidistribution of the nodal balance

Define the *nodal balance* `β(f) = nodalEdgeSum/((q+1)·energy) ∈ [−1, 1]`. For the
trivial eigenfunction `β = 1`; the Ramanujan bound gives `|β| ≤ 2√q/(q+1) → 0` as
`q → ∞`. Conjecture: along a sequence of Ramanujan graphs `G_n` with random Hecke
eigenfunctions, `β(f_n)` concentrates at `0` with fluctuations of order
`1/√|V_n|`. The key insight is that `β` is *exactly* the eigenvalue rescaled by the
degree (`β = lam/(q+1)`), so equidistribution of `β` is literally Kesten–McKay
equidistribution of the spectrum — a statement about counting eigenvalues in
windows, which is finitary per graph. Why now? `ramanujan_gap` already certifies the
deterministic envelope `|β| ≤ 2√q/(q+1) < 1`; layering a spectral-counting argument
on top turns a uniform bound into a concentration statement.

### 5. Weighted / Hecke-twisted Rayleigh identities

The adjacency operator is the first Hecke operator `T_1`; arithmetic Ramanujan
graphs carry a whole commuting family `T_p`. Conjecture: a weighted Rayleigh
identity `Σ_{(i,j)} w(i,j)·f i f j = (Σ_p c_p λ_p)·energy` holds for any polynomial
in the Hecke operators, and the corresponding nodal-count bound improves to
`Σ_p |c_p|·2√{q_p}`. The key insight is that the dot-product expansion in
`rayleigh_identity` never used that the matrix was 0/1 — it works for any symmetric
weighted adjacency matrix, so the proof generalizes by replacing `adjMatrix_apply`
with a generic symmetric-matrix entry lemma. Why now? The existing proof is already
matrix-generic at its core; abstracting `adjMatrix ℝ G` to an arbitrary
`Matrix.IsSymm` operator is a low-risk refactor that immediately opens the
multi-operator Hecke regime.
