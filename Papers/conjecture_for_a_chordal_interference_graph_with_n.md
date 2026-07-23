# Computational Evidence: Clique-Localized Spill Bounds

We test the central claim that on an interference graph the number of forced
spills under a `k`-register budget is governed locally by cliques, and that on a
single clique of size `q` the minimum number of spills is exactly `max(0, q - k)`.

## 1. Small-case calculations (single clique of size `q`)

A clique forces a proper coloring to be injective, so at most `k` of its vertices
can receive a register; the rest must spill. Minimum spills `= max(0, q - k)`.

| q \ k | k=0 | k=1 | k=2 | k=3 | k=4 |
|------:|:---:|:---:|:---:|:---:|:---:|
| q=1   |  1  |  0  |  0  |  0  |  0  |
| q=2   |  2  |  1  |  0  |  0  |  0  |
| q=3   |  3  |  2  |  1  |  0  |  0  |
| q=4   |  4  |  3  |  2  |  1  |  0  |
| q=5   |  5  |  4  |  3  |  2  |  1  |

Each entry equals `max(0, q - k)`, matching both the lower bound
(`clique_spill_lower_bound`) and the explicit construction (`stdAlloc`).

## 2. Sanity check on the canonical construction `stdAlloc q k`

`stdAlloc q k` assigns register `i` to vertex `i` for `i < k` and spills the rest.
- Validity: two distinct vertices `i ≠ j` of the complete graph get distinct
  colors (their colors are literally `i` and `j`), so no interference is violated.
- Spill count: exactly the vertices with index `≥ k`, i.e. `q - k` of them
  (`0` when `k ≥ q`). Confirms row/column values above.

## 3. Counterexample hunt for the local-to-global claim

The *lower* bound "spills `≥ ω(G) - k`" holds for every graph (pigeonhole on a
maximum clique). We looked for graphs where this local bound is *not tight*
globally, i.e. where more spills than `ω - k` are forced:

- Path `P_3` (a–b–c), `k = 1`: `ω = 2`, so the bound predicts `≥ 1` spill.
  Spilling the center `b` leaves an independent set `{a, c}`, colorable with one
  register — exactly `1` spill. Tight.
- Odd cycle `C_5`, `k = 1`: `ω = 2`, bound predicts `≥ 1`. But `C_5` needs `3`
  colors; with one register one must spill until the remainder is independent,
  which forces `2` spills, strictly above `ω - k = 1`.

`C_5` is **not chordal**, and there the local clique bound is *not* globally
tight — precisely the phenomenon the conjecture attributes to chordality. This
supports restricting exact clique-tree optimality to chordal graphs and confirms
the theorems here (which only claim tightness on a *single* clique) are correctly
scoped.

## 4. Zero-spill characterisation

For each `k` we checked: a spill-free allocation exists iff the graph is
`k`-colorable. Examples: `K_4` has a zero-spill allocation iff `k ≥ 4`; `C_5` iff
`k ≥ 3`; any bipartite graph iff `k ≥ 2` (when it has an edge). This is exactly
`zero_spill_iff_colorable`.
