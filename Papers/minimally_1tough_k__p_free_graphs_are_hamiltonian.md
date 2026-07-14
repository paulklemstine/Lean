# Computational Evidence — toughness, component counts, and `K₁ ∪ P₄`-freeness

The formal development is supported by the following small-case checks. The
component count `numComp G S` denotes the number of connected components of `G`
after deleting the vertex set `S`.

## 1. Complete graphs are `1`-tough (component count ≤ 1)
For `K_n` and any deletion set `S`, the remaining graph is still complete, hence
connected (or empty), so `numComp(K_n, S) ≤ 1`. Thus the toughness inequality
`numComp ≤ |S|` never has a chance to fail (it is never triggered, since it
requires `numComp ≥ 2`). This is the content of `numComp_complete_le_one`.

| graph | delete `S` | remaining components |
|-------|-----------|----------------------|
| `K_4` | `∅`       | 1 |
| `K_4` | 1 vertex  | 1 |
| `K_4` | 2 vertices| 1 |

## 2. Minimum degree of `1`-tough graphs
The path `P_3 = a—b—c` is **not** `1`-tough: deleting the centre `b` leaves the two
components `{a}` and `{c}`, so `numComp(P_3, {b}) = 2 > 1 = |{b}|`. The endpoints
have degree `1`, matching the theorem `oneTough_two_le_degree`: any `1`-tough graph
on `≥ 3` vertices has no degree-`≤ 1` vertex.

| graph | vertex `v` | `deg(v)` | `1`-tough? |
|-------|-----------|----------|------------|
| `P_3` | endpoint  | 1        | no  |
| `C_3` | any       | 2        | yes |
| `C_4` | any       | 2        | yes |
| `C_5` | any       | 2        | yes |

The smallest graphs that are simultaneously `1`-tough, `(K₁ ∪ P₄)`-free, and
Hamiltonian are the short cycles `C_3, C_4, C_5` and all complete graphs `K_n`
(`n ≥ 3`). For `n ≥ 6` the cycle `C_n` stops being `(K₁ ∪ P₄)`-free — four
consecutive vertices induce a `P₄` and any fifth vertex is isolated from them — so
the forbidden-subgraph hypothesis is genuinely restrictive.

## 3. `K₁ ∪ P₄` and complete graphs
`K₁ ∪ P₄` has the non-edges `0–1` (isolated vertex vs. path) and `1–3`, `1–4`,
`2–4` (path chords). Because a complete graph has no non-edge at all, it cannot
contain `K₁ ∪ P₄` as an induced subgraph. This is verified concretely
(`K1P4_not_adj_zero_one`, `K1P4_not_adj_one_three`, `K1P4_adj_one_two`) and lifted
to `complete_inducedFree_K1P4`.

## 4. Boundary of the toughness notion
A disconnected graph (e.g. `⊥` on two or more vertices) fails `1`-toughness purely
on the connectivity clause, independent of the component-count inequality; this
confirms that the connectivity requirement in `IsOneTough` is not redundant
(`not_isOneTough_bot`).

No counterexample to the proved statements was found in this range.
