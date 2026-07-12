# Computational Evidence — Clique-to-Clique Density Bound

We test the count bound
`C(t,s) · k_t(G) ≤ C(n-s, t-s) · k_s(G)`
and the normalized-density antitonicity `k_t/C(n,t) ≤ k_s/C(n,s)` on small graphs.
Here `k_r(G)` is the number of `r`-cliques and `n` the number of vertices.

## Small-case calculations

### Complete graph K_4 (n = 4)
- k_2 = 6 (edges), k_3 = 4 (triangles), k_4 = 1.
- Bound (s=2, t=3): `C(3,2)·k_3 = 3·4 = 12` and `C(2,1)·k_2 = 2·6 = 12`. **Equality** —
  the bound is tight on the complete graph (see `clique_count_bound_top`).
- Normalized: `k_3/C(4,3) = 4/4 = 1`, `k_2/C(4,2) = 6/6 = 1`. Equal, so antitone (with `=`).

### K_4 minus one edge (n = 4)
- k_2 = 5, k_3 = 2, k_4 = 0.
- Bound (s=2, t=3): `3·2 = 6 ≤ C(2,1)·5 = 10`. Holds strictly.
- Normalized: `k_3/C(4,3) = 2/4 = 0.5 ≤ k_2/C(4,2) = 5/6 ≈ 0.833`. Strict antitonicity.

### Complete tripartite K_{2,2,2} (octahedron, n = 6)
- k_2 = 12, k_3 = 8, k_4 = 0.
- Bound (s=2, t=3): `3·8 = 24 ≤ C(4,1)·12 = 48`. Holds.
- Normalized: `k_3/C(6,3) = 8/20 = 0.4 ≤ k_2/C(6,2) = 12/15 = 0.8`. Antitone.

## Counterexample hunt
No counterexample to the bound or to antitonicity was found across complete graphs,
edge-deleted complete graphs, and complete multipartite graphs on up to 6 vertices.
Equality in the bound occurs exactly for the complete graph, matching the tightness
theorem `clique_count_bound_top`. This is consistent with the fact that the extremal
configuration for this *upper* comparison is the clique, in contrast to the complete
*multipartite* extremizers of the Lovász–Simonovits/Reiher *lower* bound.

## Summary table (s = 2, t = 3)

| Graph            | n | k_2 | k_3 | LHS `3·k_3` | RHS `C(n-2,1)·k_2` | k_3/C(n,3) | k_2/C(n,2) |
|------------------|---|-----|-----|-------------|--------------------|------------|------------|
| K_4              | 4 | 6   | 4   | 12          | 12                 | 1.00       | 1.00       |
| K_4 − e          | 4 | 5   | 2   | 6           | 10                 | 0.50       | 0.83       |
| K_{2,2,2}        | 6 | 12  | 8   | 24          | 48                 | 0.40       | 0.80       |

All rows satisfy LHS ≤ RHS and `k_3/C(n,3) ≤ k_2/C(n,2)`, as proved in general.
