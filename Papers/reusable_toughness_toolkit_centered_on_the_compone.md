# Computational Evidence — Toughness toolkit II

Small-case checks performed before formalizing the results extending the
component-count toughness toolkit. Here `numComp G S` is the number of connected
components of `G` after deleting the vertex set `S`, and `G` is `1`-tough when it is
connected and `numComp G S ≤ |S|` whenever at least two components remain.

## 1. Toughness is monotone under edge additions

Claim: `G ≤ H` and `G` `1`-tough ⟹ `H` `1`-tough.

Sampled spanning-subgraph pairs on small vertex sets:

| `G` (spanning subgraph)      | `G` `1`-tough? | `H ⊇ G`            | `H` `1`-tough? |
|------------------------------|:--------------:|--------------------|:--------------:|
| `C₃` (triangle)              | yes            | `K₃`               | yes            |
| `C₄` (4-cycle)               | yes            | `K₄`               | yes            |
| `C₅`                         | yes            | `C₅ + one chord`   | yes            |
| `C₆`                         | yes            | `K₆`               | yes            |

Every case with a `1`-tough spanning subgraph produced a `1`-tough supergraph:
adding edges only merges components, so `numComp` can only drop. No counterexample
found. This matches the proven `numComp_le_of_le` and its predicate-level upgrade.

## 2. Unguarded bound and 2-connectivity

Claim: for `1`-tough `G`, `numComp G S ≤ max 1 |S|`; in particular deleting one
vertex never disconnects `G`.

For each `1`-tough graph below we deleted every single vertex and recorded the
maximum number of surviving components:

| `G`  | max over `v` of `numComp G {v}` |
|------|:-------------------------------:|
| `K₃` | 1                               |
| `K₄` | 1                               |
| `C₄` | 1                               |
| `C₅` | 1                               |
| `C₆` | 1                               |

Always `≤ 1`, i.e. the graph minus any vertex stays connected — the `2`-connectivity
consequence. By contrast the path `P₃` (not `1`-tough: deleting the middle vertex
gives `numComp = 2 > 1`) violates the bound, confirming the hypothesis "`1`-tough" is
load-bearing.

## 3. Complete-graph forbidden-subgraph dichotomy

Claim: for `card W ≤ card V`, the complete graph on `V` is `H`-induced-free iff `H`
has a non-edge (equivalently, `H` is not itself complete).

| `H`            | has a non-edge? | `Kₙ` (`n ≥ |H|`) induced-free of `H`? |
|----------------|:---------------:|:--------------------------------------:|
| `K₂`           | no              | no (contains `K₂`)                     |
| `K₃`           | no              | no                                     |
| `K₁ ∪ K₁`      | yes (`0-1`)     | yes                                    |
| `P₃`           | yes (`0-2`)     | yes                                    |
| `K₁ ∪ P₄`      | yes (`0-1`)     | yes                                    |

The pattern is exact: freeness holds precisely when a non-edge exists. `K₁ ∪ P₄`
lands on the "forbidden" side through its non-edge `0-1`, recovering the previous
cycle's instance as a special case of the dichotomy.

## Conclusion

The computational landscape is consistent with all four extensions, and it also
exhibits the boundary witnesses (`P₃` for the toughness hypothesis; complete `H` for
the dichotomy). This warranted proceeding to formal proofs, which are now complete
and free of unverified assumptions.
