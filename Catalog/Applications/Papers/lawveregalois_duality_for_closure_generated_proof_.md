# Bridge Edges in Graph Theory: A Formally Verified Development

## Abstract

We present a formally verified development of the theory of bridge edges in simple graphs, mechanized in the Lean 4 theorem prover with the Mathlib library. A **bridge** (or cut edge) is an edge whose removal disconnects the graph — a concept central to network reliability, graph decomposition, and connectivity theory. We prove seven theorems characterizing bridges from multiple perspectives: their relationship to trees, their effect on reachability, their connection to cycles, and their enumeration. All proofs are machine-checked and use only the standard axioms of Lean's type theory (propext, Classical.choice, Quot.sound). We accompany the formalization with computational demonstrations and applications to network vulnerability analysis.

**Keywords**: graph theory, bridges, cut edges, formal verification, Lean 4, Mathlib, network reliability

---

## 1. Introduction

In 1736, Leonhard Euler solved the Königsberg Bridge Problem by abstracting a city's geography into a mathematical graph — landmasses became vertices, and bridges became edges. This founding moment of graph theory was, fittingly, about *bridges*. Nearly three centuries later, the concept of a bridge edge remains central to graph theory and its applications.

A **bridge** (also called a *cut edge* or *isthmus*) in a connected graph is an edge whose removal disconnects the graph. Bridges represent single points of failure: in a communication network, a bridge link is the one whose failure partitions the network into unreachable halves. Understanding bridges is essential for:

- **Network design**: Identifying and eliminating bridges increases fault tolerance.
- **Algorithm design**: Tarjan's bridge-finding algorithm runs in linear time and is a fundamental tool in graph algorithms.
- **Structural graph theory**: The decomposition of a graph into its 2-edge-connected components (via bridge removal) is a basic structural result.

In this work, we present a **formally verified** development of bridge theory in the Lean 4 proof assistant, building on Mathlib's graph theory library. Formal verification provides the highest standard of mathematical certainty: every logical step is checked by a computer, eliminating the possibility of subtle errors in proofs.

---

## 2. Preliminaries

### 2.1 Simple Graphs in Lean/Mathlib

In Mathlib, a simple graph on a type `V` is defined as `SimpleGraph V` — a symmetric, irreflexive relation on `V`. Key notions we use:

- **Adjacency**: `G.Adj u v` means vertices `u` and `v` are connected by an edge.
- **Walk**: `G.Walk u v` is the type of walks from `u` to `v` in `G`.
- **Reachability**: `G.Reachable u v` means there exists a walk from `u` to `v`.
- **Connected**: `G.Connected` means every pair of vertices is reachable.
- **Cycle**: `p.IsCycle` for a closed walk `p` means it is a non-trivial cycle.

### 2.2 Bridge Definition

Mathlib defines bridge edges as:

```
def IsBridge (G : SimpleGraph V) (e : Sym2 V) : Prop :=
  e ∈ G.edgeSet ∧ ¬(G \ fromEdgeSet {e}).Reachable u v
```

where `u, v` are the endpoints of `e`. An edge is a bridge if (1) it belongs to the graph, and (2) its endpoints become unreachable after removing the edge.

---

## 3. Main Results

### 3.1 Tree Characterization via Bridges

**Theorem 1** (`isTree_iff_connected_and_forall_edge_isBridge`).
*A graph G is a tree if and only if G is connected and every edge of G is a bridge.*

```lean
theorem isTree_iff_connected_and_forall_edge_isBridge :
    G.IsTree ↔ G.Connected ∧ ∀ ⦃e⦄, e ∈ G.edgeSet → G.IsBridge e
```

This characterization unifies two classical viewpoints of trees:
- A tree is a *minimal connected graph* — removing any edge disconnects it (every edge is a bridge).
- A tree is a *maximal acyclic graph* — adding any edge creates a cycle (equivalent via `isAcyclic_iff_forall_edge_isBridge`).

The proof chains Mathlib's `IsTree = Connected ∧ IsAcyclic` with the characterization `IsAcyclic ↔ ∀ e ∈ edgeSet, IsBridge e`.

### 3.2 Bridge Removal Disconnects

**Theorem 2** (`IsBridge.not_connected_deleteEdge`).
*If G is a connected graph and {u,v} is a bridge of G, then G \ {u,v} is not connected.*

```lean
theorem IsBridge.not_connected_deleteEdge {u v : V}
    (hconn : G.Connected) (hb : G.IsBridge s(u, v)) :
    ¬ (G \ fromEdgeSet {s(u, v)}).Connected
```

This is the defining property of bridges, but stated as a theorem about the graph-level property `Connected` rather than just `Reachable`. The proof extracts the unreachability of `u` and `v` from the bridge hypothesis and derives a contradiction with assumed connectivity.

### 3.3 Bridge Partition Theorem

**Theorem 3** (`IsBridge.reachable_xor_of_connected`).
*In a connected graph G with bridge {u,v}, after removing the bridge, every vertex w is reachable from exactly one of u or v — but not both.*

```lean
theorem IsBridge.reachable_xor_of_connected {u v w : V}
    (hconn : G.Connected) (hb : G.IsBridge s(u, v)) :
    (G \ fromEdgeSet {s(u, v)}).Reachable u w ↔
    ¬ (G \ fromEdgeSet {s(u, v)}).Reachable v w
```

This theorem shows that a bridge cleanly **partitions** the vertex set into two non-empty parts. The forward direction uses transitivity and symmetry of reachability: if both u→w and v→w hold, then u→w→v, contradicting the bridge property. The backward direction uses connectivity of the original graph to show every vertex is reachable from at least one endpoint in the reduced graph.

### 3.4 Bridgeless Graphs and Cycles

**Theorem 4** (`connected_no_bridges_iff_forall_edge_on_cycle`).
*A connected graph has no bridges if and only if every edge lies on a cycle.*

```lean
theorem connected_no_bridges_iff_forall_edge_on_cycle (hconn : G.Connected) :
    (∀ ⦃e⦄, e ∈ G.edgeSet → ¬ G.IsBridge e) ↔
    (∀ ⦃v w : V⦄, G.Adj v w →
      ∃ (u : V) (p : G.Walk u u), p.IsCycle ∧ s(v, w) ∈ p.edges)
```

This is a fundamental characterization of **2-edge-connected** graphs (connected graphs with no bridges). The proof leverages Mathlib's `isBridge_iff_adj_and_forall_cycle_notMem`, which says an edge is a bridge iff it is not contained in any cycle.

### 3.5 Bridge Counting in Trees

**Theorem 5** (`IsTree.card_bridges`).
*A tree on n vertices has exactly n − 1 bridges.*

```lean
theorem IsTree.card_bridges [Fintype V] [Fintype G.edgeSet] [DecidableEq V]
    [DecidablePred (G.IsBridge ·)]
    (hT : G.IsTree) :
    (G.edgeFinset.filter (G.IsBridge ·)).card = Fintype.card V - 1
```

The proof combines two facts: (1) every edge of a tree is a bridge (Theorem 1), so the filter is the identity; (2) Mathlib's `IsTree.card_edgeFinset` gives that a tree on n vertices has n − 1 edges.

### 3.6 Alternative Paths and Non-Bridges

**Theorem 6** (`not_isBridge_of_alternative_path`).
*If there exists a walk from u to v that avoids the edge {u,v}, then {u,v} is not a bridge.*

```lean
theorem not_isBridge_of_alternative_path {u v : V} (_hadj : G.Adj u v)
    (hp : ∃ p : G.Walk u v, s(u, v) ∉ p.edges) :
    ¬ G.IsBridge s(u, v)
```

### 3.7 Non-Bridge Removal Preserves Connectivity

**Theorem 7** (`Connected.deleteEdge_connected_of_not_bridge`).
*In a connected graph, removing a non-bridge edge preserves connectivity.*

```lean
theorem Connected.deleteEdge_connected_of_not_bridge {u v : V}
    (hconn : G.Connected) (hadj : G.Adj u v) (hnb : ¬ G.IsBridge s(u, v)) :
    (G \ fromEdgeSet {s(u, v)}).Connected
```

This is the converse of Theorem 2 and completes the picture: an edge of a connected graph is a bridge if and only if its removal disconnects the graph.

---

## 4. Applications

### 4.1 Network Vulnerability Analysis

The most immediate application of bridge theory is in **network reliability**. In any communication, transportation, or power network modeled as a graph:

- **Bridges are single points of failure.** If any bridge link goes down, part of the network becomes unreachable (Theorem 2).
- **Non-bridge links have built-in redundancy.** Removing a non-bridge link leaves the network fully connected (Theorem 7).
- **The partition theorem (Theorem 3) tells you exactly who is affected** when a bridge fails — the network splits into precisely two parts.

Tarjan's linear-time bridge-finding algorithm makes this analysis practical even for very large networks. Our Python demonstration (`bridge_demo.py`) includes a concrete network vulnerability analysis showing which nodes become isolated when each bridge fails.

### 4.2 Network Design

The bridgeless characterization (Theorem 4) provides a design criterion: **to make a network resilient to any single link failure, ensure every edge lies on a cycle.** In practice, this means adding redundant links until no bridges remain.

For a tree network (all bridges, Theorem 5), this requires adding at least ⌈n/2⌉ edges to eliminate all n−1 bridges — a well-studied optimization problem known as the **bridge-connectivity augmentation problem**.

### 4.3 Graph Decomposition

The bridge partition theorem (Theorem 3) enables **block-cut tree decomposition**: iteratively removing bridges decomposes a connected graph into its 2-edge-connected components (blocks). This decomposition is foundational in structural graph theory and has applications in:

- **Planarity testing** (Hopcroft–Tarjan algorithm)
- **Network flow** optimization
- **Social network analysis** (identifying communities connected by weak ties)

---

## 5. Discussion: What Bridges Tell Us About Connectivity

*For a general audience*

Imagine a medieval kingdom with several towns connected by roads. Most towns can reach each other by multiple routes — if one road is washed out by a flood, travelers can find an alternate path. But some roads are irreplaceable: block them, and entire regions become isolated. These critical roads are the **bridges** of the kingdom's road network.

This intuition captures the essence of bridge edges in graph theory. A bridge is a connection so important that it cannot be lost without fracturing the network. The remarkable insight, formalized in our Theorem 4, is that a connection is a bridge *precisely when* it doesn't participate in any cycle — any circular route. If you can go from town A to town B and back by a loop that includes the road between them, then that road has a backup; it's not a bridge. But if every path from A to B must use that specific road, it's a bridge.

Trees — those elegant branching structures found everywhere from family lineages to file systems to evolutionary phylogenies — are the extreme case. In a tree, *every* connection is a bridge (Theorem 1). This is what makes trees so fragile: cut any single link, and the tree splits in two. It's also what makes them so efficient: with n nodes, a tree uses exactly n−1 edges (the minimum possible for a connected network), and every one of those edges is essential.

The bridge partition theorem (Theorem 3) reveals something beautiful about what happens when a bridge breaks. The network doesn't shatter into arbitrary fragments — it splits into exactly *two* pieces, and every node ends up on one side or the other. This clean binary partition is a consequence of the bridge being, in a precise sense, the *only* connection between two halves of the network.

### Historical Context

The study of bridges connects directly to the founding moment of graph theory. In 1736, Euler proved that there was no way to walk through Königsberg crossing each of its seven bridges exactly once. His insight — that the problem depended only on the *structure* of connections, not on distances or geography — created an entirely new branch of mathematics.

The term "bridge" in graph theory (an edge whose removal disconnects the graph) is a deliberate echo of Euler's physical bridges. The progression from Euler's specific problem to the general theory of cut edges illustrates how mathematics transforms concrete puzzles into abstract principles.

### The Value of Formal Verification

Why formalize these results in a proof assistant? After all, the theorems we prove here are well-known and have appeared in textbooks for decades. Three reasons:

1. **Certainty**: Every step is machine-checked. No hand-waving, no "clearly" or "by symmetry" hiding a subtle gap. The proof of Theorem 3 (bridge partition), for instance, requires careful tracking of reachability through walk induction — exactly the kind of argument where informal proofs can harbor bugs.

2. **Composability**: Formally verified theorems become building blocks. Future work on edge connectivity, Menger's theorem, or network flow can import and use our results with complete confidence.

3. **Documentation**: A formal proof is a perfectly precise record of the mathematical argument. Combined with the doc comments in our Lean files, it serves as an unambiguous reference that never becomes outdated.

---

## 6. Related Work

### In Mathlib
Our development builds directly on Mathlib's graph connectivity module, which provides the definitions of `IsBridge`, `Walk`, `Connected`, `IsTree`, and `IsAcyclic`, along with several characterizations of bridges in terms of walks and cycles. We extend this foundation with the tree characterization, partition theorem, bridge counting, and connectivity preservation results.

### In Other Proof Assistants
- Gonthier's formalization of the Four Color Theorem in Coq includes substantial graph theory infrastructure, though bridge theory is not specifically developed.
- The Isabelle/HOL Archive of Formal Proofs contains graph theory developments including connectivity and trees, but the bridge-specific theory we develop here appears to be novel in the formally verified setting.

---

## 7. Future Directions

Several natural extensions of this work suggest themselves:

1. **Menger's theorem**: The edge version states that the maximum number of edge-disjoint paths between two vertices equals the minimum edge cut. Our bridge theory handles the base case (minimum cut = 1).

2. **Block-cut tree**: Formally constructing the block-cut tree decomposition of a graph, using bridges to identify the 2-edge-connected components.

3. **Bridge-connectivity augmentation**: Given a graph with bridges, what is the minimum number of edges to add to make it bridgeless? This optimization problem has a known O(n) solution.

4. **Tarjan's bridge algorithm**: Verifying the correctness of the linear-time DFS-based algorithm for finding all bridges.

5. **Ear decomposition**: Formally proving that a graph is 2-edge-connected if and only if it has an ear decomposition (Whitney's theorem).

---

## 8. Conclusion

We have presented a formally verified development of bridge theory in Lean 4/Mathlib, proving seven theorems that characterize bridges from multiple perspectives. The development demonstrates that modern proof assistants can handle combinatorial graph theory arguments naturally, and that formal verification adds genuine value even for classical, well-understood results. Our accompanying Python demonstrations and network reliability application show how these theorems connect to practical problems in network design and analysis.

All code is available in the project repository:
- **Lean formalization**: `Bridges/Basic.lean` (7 theorems, ~160 lines, zero `sorry`)
- **Python demonstrations**: `Bridges/bridge_demo.py` (6 demos with visualizations)

---

## References

1. R. Diestel, *Graph Theory*, 5th edition, Springer, 2017.
2. R. E. Tarjan, "A note on finding the bridges of a graph," *Information Processing Letters*, vol. 2, no. 6, pp. 160–161, 1974.
3. The Mathlib Community, "Mathlib: A unified library of mathematics formalized in Lean 4," 2024. Available: https://github.com/leanprover-community/mathlib4
4. L. Euler, "Solutio problematis ad geometriam situs pertinentis," *Commentarii Academiae Scientiarum Petropolitanae*, vol. 8, pp. 128–140, 1741.
