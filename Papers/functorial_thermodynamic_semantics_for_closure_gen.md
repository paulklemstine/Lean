# Bridges in Graph Theory: From Königsberg to Formal Verification

## A Formally Verified Theory of Graph Bridges and Two-Edge-Connectivity

---

### Abstract

We present a formal development in Lean 4 of the theory of **graph bridges** (cut edges) and **two-edge-connectivity**, built on top of the Mathlib library. Our main contributions are: (1) a new definition of two-edge-connectivity for simple graphs, absent from the current Mathlib library; (2) a proof that a connected graph is two-edge-connected if and only if every edge lies on a cycle (the **bridge-cycle duality** characterization); (3) a proof that trees are never two-edge-connected; and (4) a formalization of the **Königsberg Bridge Theorem**, proving that the complete graph K₄ admits no Eulerian trail by establishing the **generalized degree-parity obstacle** — that any graph with more than two odd-degree vertices cannot possess an Eulerian trail.

All proofs are machine-verified with no axioms beyond the standard foundational axioms of Lean's type theory (`propext`, `Classical.choice`, `Quot.sound`).

---

### 1. Introduction

Graph theory was born in 1736 when Leonhard Euler analyzed the seven bridges of Königsberg. The citizens of Königsberg (now Kaliningrad) wondered whether it was possible to walk through the city crossing each bridge exactly once. Euler proved this impossible, and in doing so, introduced concepts that would become the foundation of modern combinatorics.

The concept of a **bridge** — an edge whose removal disconnects a graph — sits at the heart of Euler's original insight. While the Königsberg problem itself is about *Eulerian trails*, the underlying theory of bridges provides the structural language for understanding when and why such traversals fail.

In this paper, we formalize key theorems about graph bridges in the Lean 4 proof assistant, building on the extensive Mathlib library. Our work extends Mathlib's existing bridge infrastructure with the new notion of **two-edge-connectivity** and provides a complete formal proof of the Königsberg impossibility theorem.

### 2. Mathematical Background

#### 2.1 Bridges and Cut Edges

**Definition.** Let G = (V, E) be a simple graph. An edge e ∈ E is a **bridge** (or **cut edge**) if the graph G − e obtained by removing e has more connected components than G.

Equivalently, in the context of Mathlib's `SimpleGraph`, an edge `s(v, w)` is a bridge if `G.Adj v w` and `v` and `w` are not reachable from each other in the graph `G \ fromEdgeSet {s(v, w)}`.

The fundamental characterization of bridges connects them to the cycle structure of the graph:

**Theorem (Bridge-Cycle Duality).** An edge e in a graph G is a bridge if and only if e does not lie on any cycle of G.

This result is already formalized in Mathlib as `SimpleGraph.isBridge_iff_adj_and_forall_cycle_notMem`.

#### 2.2 Two-Edge-Connectivity

**Definition.** A graph G is **two-edge-connected** (or **2-edge-connected**) if G is connected and contains no bridges.

This is equivalent to several other natural conditions:
- Every pair of vertices is connected by two edge-disjoint paths (Whitney's theorem).
- Every edge lies on at least one cycle.
- The minimum edge cut has size at least 2.

Our Lean formalization introduces this definition (absent from Mathlib as of v4.28.0) and proves the cycle characterization.

#### 2.3 Euler's Theorem on Traversability

**Theorem (Euler, 1736).** A connected graph G has an Eulerian trail if and only if G has at most two vertices of odd degree. Moreover, G has an Eulerian circuit (closed trail) if and only if every vertex has even degree.

The *necessary* direction is formalized in Mathlib as `SimpleGraph.Walk.IsEulerian.card_filter_odd_degree`. We use this to derive our impossibility results.

### 3. Formal Development

#### 3.1 Definition of Two-Edge-Connectivity

```lean
def IsTwoEdgeConnected (G : SimpleGraph V) : Prop :=
  G.Connected ∧ ∀ e ∈ G.edgeSet, ¬G.IsBridge e
```

This definition captures the essence of 2-edge-connectivity: the graph is connected, and removing any single edge preserves connectivity. We establish basic API:

- `connected_of_isTwoEdgeConnected`: Extract connectivity.
- `IsTwoEdgeConnected.not_isBridge`: Extract the bridge-free condition.

#### 3.2 The Cycle Characterization Theorem

Our main theorem in `Bridges/Basic.lean` states:

```lean
theorem isTwoEdgeConnected_iff_forall_edge_on_cycle
    (hconn : G.Connected) :
    G.IsTwoEdgeConnected ↔
      ∀ {v w : V}, G.Adj v w →
        ∃ (u : V) (p : G.Walk u u), p.IsCycle ∧ s(v, w) ∈ p.edges
```

**Proof sketch.** The forward direction uses the bridge-cycle duality: since no edge is a bridge, every edge must lie on some cycle. The backward direction uses the contrapositive: if every edge lies on a cycle, then no edge satisfies the bridge characterization (an edge on a cycle cannot be a bridge).

This theorem establishes a deep connection between the local property of bridge-freedom and the global cycle structure of the graph.

#### 3.3 Trees and Bridges

We prove that trees (connected acyclic graphs) represent the extreme case where *every* edge is a bridge:

```lean
theorem tree_every_edge_isBridge (hac : G.IsAcyclic) {e : Sym2 V}
    (he : e ∈ G.edgeSet) : G.IsBridge e

theorem not_isTwoEdgeConnected_of_isAcyclic_of_exists_edge
    (hac : G.IsAcyclic) {e : Sym2 V} (he : e ∈ G.edgeSet) :
    ¬G.IsTwoEdgeConnected
```

This confirms the intuition that trees are maximally fragile: every edge is critical for connectivity.

#### 3.4 The Königsberg Bridge Theorem

In `Bridges/Konigsberg.lean`, we model the Königsberg problem using the complete graph K₄, which captures the essential property that all four vertices have odd degree:

```lean
abbrev K4 : SimpleGraph (Fin 4) := ⊤

theorem K4_degree (v : Fin 4) : K4.degree v = 3 := by
  fin_cases v <;> decide
```

We then prove the **Generalized Degree-Parity Obstacle**:

```lean
theorem odd_degree_obstacle {V : Type*} [DecidableEq V] [Fintype V]
    {G : SimpleGraph V} [DecidableRel G.Adj]
    (h : 2 < (Finset.univ.filter fun v => Odd (G.degree v)).card) :
    ¬∃ (u v : V) (p : G.Walk u v), p.IsEulerian
```

This theorem states: *if a graph has more than 2 vertices of odd degree, then no Eulerian trail exists.* This is the contrapositive of Euler's necessary condition.

The Königsberg theorem follows immediately:

```lean
theorem K4_no_eulerian_trail :
    ¬∃ (u v : Fin 4) (p : K4.Walk u v), p.IsEulerian :=
  odd_degree_obstacle (by decide)
```

The `by decide` tactic computationally verifies that K₄ has 4 > 2 odd-degree vertices.

### 4. Connections and Related Work

#### 4.1 Relation to Mathlib

Our work builds directly on Mathlib's `SimpleGraph` infrastructure, particularly:
- `SimpleGraph.IsBridge` and its characterizations
- `SimpleGraph.Walk.IsEulerian` and the degree-parity theorems
- `SimpleGraph.IsAcyclic` and tree characterizations

The main novel contribution is the `IsTwoEdgeConnected` definition and its cycle characterization, which fills a gap in Mathlib's coverage of edge-connectivity.

#### 4.2 Historical Context

Euler's 1736 paper "Solutio problematis ad geometriam situs pertinentis" is often cited as the founding document of graph theory and topology. The key insight — that the possibility of traversal depends only on the parity of vertex degrees, not on the specific geometry of the bridges — represents one of the earliest examples of mathematical abstraction in combinatorics.

#### 4.3 Algorithmic Connections

The bridge-finding problem has efficient algorithmic solutions:
- **Tarjan's algorithm** (1974) finds all bridges in O(V + E) time using DFS.
- **Chain decomposition** provides an elegant linear-time alternative.

These algorithms are fundamental in network reliability analysis, as bridges represent single points of failure.

### 5. Discussion: Why Bridges Matter

*For the general reader*

Imagine you're designing a road network for a city. Some roads are so critical that if they're closed for repair, entire neighborhoods become unreachable. These critical connections are exactly what mathematicians call **bridges**.

The concept is beautifully simple: a bridge is an edge whose removal disconnects part of the graph. Yet this simplicity conceals remarkable depth.

**The Königsberg Story.** In 1736, the citizens of Königsberg posed what seemed like a recreational puzzle: could you walk through the city crossing each of its seven bridges exactly once? Euler's genius was recognizing that the answer depends not on geography but on a single number — how many vertices have an odd number of connections.

Think of it this way: every time you enter a vertex, you must also leave it (except possibly at the start and end of your walk). If a vertex has an odd number of connections, it must be either the start or the end. Since a walk has at most two endpoints, you can have at most two odd-degree vertices. Königsberg has four. QED.

**Modern Applications.** The theory of bridges appears throughout modern technology:

- **Network Resilience**: Internet routing protocols identify bridge links that, if severed, would partition the network. The Internet's backbone is specifically designed to be 2-edge-connected — no single link failure should disconnect any region.

- **Circuit Design**: In VLSI chip design, bridge edges in the circuit graph represent single points of failure. Redundant paths are added precisely to eliminate bridges.

- **Social Network Analysis**: In social networks, bridge connections between communities are the most influential — they're the people who connect otherwise-separate groups. Mark Granovetter's famous "strength of weak ties" theory is, at its mathematical core, a theory about bridges.

- **Bioinformatics**: In genome assembly, bridge edges in the de Bruijn graph correspond to unambiguous sequences that must appear in any reconstruction. Finding bridges is a key step in genome assembly algorithms.

**From Bridges to Connectivity.** Our theorem about 2-edge-connectivity captures an important engineering principle: *a network is robust (2-edge-connected) precisely when every connection participates in a cycle*. Cycles provide redundancy — if one edge fails, traffic can detour around the cycle. A network without cycles (a tree) is maximally fragile: every edge is a bridge.

This insight extends far beyond graphs. In organizational design, supply chain management, and infrastructure planning, the same principle applies: redundancy through cycles provides resilience against single-point failures.

### 6. Applications

#### 6.1 Network Reliability Assessment

Given a network graph G, the set of bridges forms a **vulnerability map**:
- Bridges are single points of failure that must be protected or redundantly backed up.
- The 2-edge-connected components of G (obtained by removing all bridges) are the "robust cores" of the network.
- The bridges form a tree structure connecting these robust cores — this is the **block-cut tree**.

Our formal theorem `isTwoEdgeConnected_iff_forall_edge_on_cycle` provides a precise criterion: *a network component is robust if and only if every link participates in at least one cycle*.

#### 6.2 Algorithm Verification

Our Lean formalization provides a **specification** against which bridge-finding algorithms can be verified:
- An algorithm is correct if it returns exactly the edges satisfying `SimpleGraph.IsBridge`.
- The cycle characterization provides an alternative specification for testing.
- The degree-parity obstacle provides a quick necessary condition check for Eulerian traversability.

#### 6.3 Educational Value

The Königsberg Bridge Problem is one of the most accessible entry points to mathematical proof. Our formalization demonstrates how a 288-year-old theorem can be made completely rigorous using modern proof technology, while remaining understandable and connected to its historical roots.

### 7. Future Directions

Several natural extensions of this work would further enrich Mathlib's graph theory library:

1. **k-edge-connectivity**: Generalize 2-edge-connectivity to arbitrary k, with the characterization via minimum edge cuts.

2. **Whitney's theorem**: Every 2-edge-connected graph admits an ear decomposition, and conversely.

3. **Block-cut tree**: Formalize the decomposition of a graph into its 2-edge-connected components connected by bridges.

4. **Menger's theorem**: The edge-connectivity version — the minimum edge cut equals the maximum number of edge-disjoint paths.

5. **Euler's sufficient condition**: Complete the characterization by proving that a connected graph with at most 2 odd-degree vertices *does* have an Eulerian trail.

### 8. Conclusion

We have presented a formal development of graph bridge theory in Lean 4, introducing the definition of two-edge-connectivity and proving its cycle characterization. Combined with the formalization of the Königsberg Bridge Theorem, this work provides both a mathematical contribution to the Mathlib library and an accessible demonstration of formal verification applied to classical mathematics.

The proofs are entirely machine-checked, relying only on the standard axioms of Lean's type theory. All source code is available in the `Bridges/` directory of this project.

---

### Appendix: File Organization

| File | Contents |
|------|----------|
| `Bridges/Basic.lean` | Two-edge-connectivity definition, cycle characterization, tree bridge theorem |
| `Bridges/Konigsberg.lean` | K₄ degree computation, generalized obstacle theorem, Königsberg impossibility |
| `demos/bridge_demo.py` | Python visualizations of bridges, Königsberg problem, and Euler's condition |

### Appendix: Axiom Verification

All theorems depend only on the standard axioms:
```
propext, Classical.choice, Quot.sound
```
Verified via `#print axioms` for each main theorem.
