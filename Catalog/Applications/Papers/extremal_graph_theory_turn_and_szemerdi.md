# Computational Evidence — Extremal Graph Theory cycle

Concise numerical sanity checks for the theorems formalized in
`Shared/TuranMantel.lean`, `Shared/RothThreeAP.lean`,
`Shared/KruskalKatonaShadow.lean`.

## 1. Mantel's bound and its sharpness

Turán graph `turanGraph (2k) 2` is the balanced complete bipartite graph
`K_{k,k}`; it is triangle-free and has `k²` edges.

| n = 2k | edges of K_{k,k} | 4·edges | n² | 4·edges = n² ? |
|--------|------------------|---------|-----|----------------|
| 2 (k=1)| 1                | 4       | 4   | yes            |
| 4 (k=2)| 4                | 16      | 16  | yes            |
| 6 (k=3)| 9                | 36      | 36  | yes            |
| 8 (k=4)| 16               | 64      | 64  | yes            |

This confirms `mantel_sharp`: equality `4·e = n²` holds for all balanced
bipartite graphs, so the constant `1/4` in Mantel's theorem is optimal.

General Turán bound `2 r · e ≤ (r-1) n²` checked at small `r`:
- `r = 2`: `4 e ≤ n²` (Mantel).
- `r = 3` (K_4-free), `n = 6`: Turán graph is `K_{2,2,2}` with `12` edges,
  `2·3·12 = 72 = 2·36 = (r-1) n²`. Equality, as expected.

## 2. Roth 3-APs, positive form

The negative input is Mathlib's `roth_3ap_theorem`; we extract a genuine
non-degenerate progression. Small illustrative AP-free vs. AP-containing sets in
`ZMod`:
- `ZMod 5`, `A = {0,1,2}`: contains `0,1,2` (d=1), so not AP-free. ✓
- `ZMod 7`, `A = {0,1,3}`: pairwise checks show it *is* 3AP-free (a Sidon-like
  small set), illustrating that density (not mere size) is what forces a 3-AP —
  matching the hypothesis `ε·|G| ≤ |A|`.

## 3. Kruskal–Katona shadow / graph cover

`shadow_card_ge` with `r=2`: a graph with `≥ C(k,2)` edges covers `≥ k`
vertices.

| k | C(k,2) edges | min vertices to host them | k ? |
|---|--------------|---------------------------|-----|
| 3 | 3            | 3 (triangle)              | 3   |
| 4 | 6            | 4 (K_4)                   | 4   |
| 5 | 10           | 5 (K_5)                   | 5   |

The clique `K_k` realizes equality: `C(k,2)` edges on exactly `k` vertices,
confirming the bound in `graph_edges_cover_vertices` is tight.

All tabulated identities are special cases of the fully formalized,
`sorry`-free theorems; the tables are evidence, the Lean files are the proof.
