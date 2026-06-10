# Bridge Edges in Finite Graphs: Formally Verified Structural Theorems

## Abstract

We present machine-verified proofs of fundamental theorems about bridge edges (cut edges) in finite simple graphs, formalized in Lean 4 using the Mathlib library. Our central result is the **Even-Degree Bridge-Free Theorem**: in a finite connected simple graph where every vertex has even degree, no edge is a bridge. The proof employs a parity argument via the handshaking lemma, providing a clean algebraic route to a classical result in structural graph theory. We additionally formalize the characterization of trees as precisely the connected graphs in which every edge is a bridge.

**Keywords:** graph theory, bridges, cut edges, formal verification, Lean 4, Mathlib, handshaking lemma, trees

---

## 1. Introduction

A **bridge** (or **cut edge**) of a connected graph $G$ is an edge $e$ whose removal disconnects $G$. Bridges are among the most fundamental structural features in graph theory, connecting local edge properties to global connectivity. The study of bridges dates to Leonhard Euler's 1736 analysis of the Königsberg bridge problem — widely regarded as the founding work of graph theory itself.

Despite their classical nature, bridges continue to find applications across computer science, network design, and combinatorial optimization. In network reliability, bridges represent single points of failure. In algorithm design, Tarjan's linear-time bridge-finding algorithm (1974) remains a cornerstone of graph algorithms. In combinatorics, the structure of bridge-free graphs connects to deep results about cycle spaces and edge connectivity.

In this work, we formalize two key theorems about bridges in the Lean 4 proof assistant, building on Mathlib's existing graph theory infrastructure:

1. **Even-Degree Bridge-Free Theorem** (Theorem 3.1): If $G$ is a finite connected graph where every vertex has even degree, then $G$ has no bridges.

2. **Tree–Bridge Characterization** (Theorem 4.1): A graph $G$ is a tree if and only if $G$ is connected and every edge of $G$ is a bridge.

These results are not new mathematically — the first is a classical consequence of Euler's theorem on Eulerian circuits, and the second is a standard characterization of trees. However, our formal proofs provide machine-checked certainty and demonstrate techniques for reasoning about parity, connectivity, and graph structure within a proof assistant.

---

## 2. Preliminaries

### 2.1 Definitions

We work with **simple graphs** $G = (V, E)$ where $V$ is a finite set of vertices and $E \subseteq \binom{V}{2}$ is a set of undirected edges (no loops, no parallel edges). In Lean 4/Mathlib, this is captured by `SimpleGraph V` with `[Fintype V]` and `[DecidableRel G.Adj]`.

**Definition 2.1 (Bridge).** An edge $e = \{u, v\} \in E(G)$ is a *bridge* if $u$ and $v$ are not reachable from each other in $G \setminus \{e\}$, the graph obtained by deleting $e$.

In Mathlib, this is `SimpleGraph.IsBridge`:
```
G.IsBridge s(u, v) ↔ G.Adj u v ∧ ¬(G \ fromEdgeSet {s(u, v)}).Reachable u v
```

**Definition 2.2 (Degree).** The *degree* of a vertex $v$ in $G$, written $\deg_G(v)$, is the number of edges incident to $v$, equivalently $|\{w \in V : G.\text{Adj}\, v\, w\}|$.

**Definition 2.3 (Tree).** A graph $G$ is a *tree* if it is connected and acyclic.

### 2.2 Key Existing Results in Mathlib

Our proofs build on several results already formalized in Mathlib:

- **Handshaking Lemma** (`SimpleGraph.sum_degrees_eq_twice_card_edges`):
$$\sum_{v \in V} \deg(v) = 2|E|$$

- **Bridge–Cycle Characterization** (`isBridge_iff_mem_and_forall_cycle_notMem`):
$$\text{IsBridge}(G, e) \iff e \in E(G) \wedge \forall\, \text{cycle } C,\; e \notin C$$

- **Acyclicity–Bridge Equivalence** (`isAcyclic_iff_forall_edge_isBridge`):
$$G \text{ is acyclic} \iff \forall e \in E(G),\; \text{IsBridge}(G, e)$$

---

## 3. The Even-Degree Bridge-Free Theorem

### 3.1 Statement

**Theorem 3.1.** Let $G = (V, E)$ be a finite connected simple graph. If every vertex of $G$ has even degree, then $G$ has no bridges.

### 3.2 Proof

*Proof.* Suppose for contradiction that $e = \{u, v\}$ is a bridge of $G$. Since $e$ is a bridge, after removing $e$ from $G$, the vertices $u$ and $v$ lie in different connected components. Let $C_u$ denote the connected component of $u$ in $G' = G \setminus \{e\}$.

**Degree analysis.** In $G'$:
- $\deg_{G'}(u) = \deg_G(u) - 1$ (since exactly one edge to $v$ was removed, and simple graphs have at most one edge between any pair)
- For every vertex $w \in C_u$ with $w \neq u$: since $v \notin C_u$ (as $e$ is a bridge and $v$ is in a different component), the vertex $w$ retains all its edges from $G$, so $\deg_{G'}(w) = \deg_G(w)$.

**Parity argument.** By hypothesis, $\deg_G(u)$ is even, so $\deg_{G'}(u) = \deg_G(u) - 1$ is odd. For all other $w \in C_u$, $\deg_{G'}(w) = \deg_G(w)$ is even.

By the handshaking lemma applied to the subgraph induced by $C_u$:
$$\sum_{w \in C_u} \deg_{G'[C_u]}(w) = 2|E(G'[C_u])|$$

Since $C_u$ is a connected component of $G'$, the degree of each vertex within $C_u$ equals its degree in $G'$. Therefore:
$$\sum_{w \in C_u} \deg_{G'}(w) = 2|E(G'[C_u])|$$

The left side has exactly one odd term ($\deg_{G'}(u)$) and all remaining terms even, giving an odd sum. But the right side is even. This is a contradiction.

Therefore, $G$ has no bridges. $\square$

### 3.3 Formal Statement in Lean 4

```lean
theorem not_isBridge_of_even_degree (hconn : G.Connected)
    (heven : ∀ v : V, Even (G.degree v)) : ∀ e, ¬G.IsBridge e
```

The formal proof in Lean 4 runs approximately 40 lines of tactic-mode proof, using `Finset.sum_bij` to establish the degree-sum equality for induced subgraphs, modular arithmetic (`Nat.add_mod`, `Finset.sum_nat_mod`) for the parity contradiction, and `aesop` for routine graph-theoretic deductions.

### 3.4 Relationship to Euler's Theorem

Theorem 3.1 is sometimes presented as a corollary of Euler's theorem: if $G$ is connected and every vertex has even degree, then $G$ has an Eulerian circuit — a closed walk that traverses every edge exactly once. Given any edge $e = \{u, v\}$, the Eulerian circuit provides an alternative path from $u$ to $v$ not using $e$, so $e$ is not a bridge.

Our proof avoids Euler's theorem entirely, using only the handshaking lemma and a parity argument. This makes the formalization significantly simpler while remaining mathematically illuminating.

---

## 4. Tree Characterization via Bridges

### 4.1 Statement

**Theorem 4.1.** A graph $G$ is a tree if and only if $G$ is connected and every edge of $G$ is a bridge.

### 4.2 Proof

This follows directly from the definitions and existing Mathlib results:

- A tree is a connected, acyclic graph (`SimpleGraph.IsTree`).
- A graph is acyclic if and only if every edge is a bridge (`isAcyclic_iff_forall_edge_isBridge`).

Combining these yields the equivalence immediately.

### 4.3 Formal Statement

```lean
theorem isTree_iff_connected_and_forall_edge_isBridge :
    G.IsTree ↔ G.Connected ∧ ∀ e ∈ G.edgeSet, G.IsBridge e
```

---

## 5. Applications

### 5.1 Network Reliability

In communication and transportation networks, bridges represent **single points of failure**. If a network is modeled as a graph where vertices are nodes (routers, cities, servers) and edges are links (cables, roads, connections), then:

- **Bridges are critical**: removing a bridge disconnects the network.
- **Even-degree design principle**: Theorem 3.1 tells us that if we design a network where every node has an even number of connections, the network is guaranteed to have no single points of failure (no bridges). This is a practical design heuristic for robust networks.

### 5.2 Algorithm Design

Tarjan's bridge-finding algorithm (1974) identifies all bridges in $O(V + E)$ time using depth-first search. Our theorems provide:

- **Correctness certificates**: The formal proofs can serve as foundations for verified implementations of bridge-finding algorithms.
- **Quick screening**: Before running bridge detection, one can check if all degrees are even — if so, no bridges exist (by Theorem 3.1), saving computation.

### 5.3 Structural Graph Theory

The bridge-free property (2-edge-connectivity) is a fundamental notion in structural graph theory:

- **Whitney's theorem**: A graph is 2-edge-connected if and only if every pair of vertices has two edge-disjoint paths.
- **Ear decomposition**: A graph is 2-edge-connected if and only if it has an open ear decomposition.
- **Spanning tree analysis**: A connected graph with $n$ vertices and $m$ edges has at most $n - 1$ bridges (with equality if and only if the graph is a tree).

---

## 6. Discussion: Bridges Between Mathematics and the Real World

*A Scientific American–style perspective*

### The Fragile Thread

Imagine a map of airline routes connecting cities across a continent. Most major cities are served by multiple airlines with many connecting flights — if one route is cancelled, travelers can find alternatives. But occasionally, a single route connects two regions: perhaps a small island served by only one flight, or a remote town linked to the highway system by a single road. Cut that link, and an entire region becomes isolated.

In mathematics, we call such critical connections **bridges**. The term is apt — not just metaphorically, but historically. Graph theory itself was born from a question about bridges: in 1736, Leonhard Euler asked whether one could walk through the city of Königsberg, crossing each of its seven bridges exactly once. His proof that this was impossible laid the foundations for an entire branch of mathematics.

### The Handshake Principle

Our central theorem reveals a surprising connection between a local property (how many connections each node has) and a global structural feature (whether the network has vulnerable links).

The key insight comes from a simple counting principle that mathematicians call the **handshaking lemma**: at any party, the total number of handshakes is always even, because each handshake involves exactly two hands. In graph language: the sum of all vertex degrees equals twice the number of edges.

Now suppose every person at the party has shaken an even number of hands, and suppose we try to find a "bridge handshake" — one whose removal would split the party into two groups that never interacted. Our theorem says: impossible. The parity of the counting simply doesn't allow it.

Here's the beautiful argument: if we remove a bridge and look at one of the resulting groups, the person who lost the bridge connection now has an odd number of remaining handshakes (one less than their even total). Everyone else in that group still has their even count. But the handshaking lemma says the total within any group must be even. One odd number plus any number of even numbers gives an odd total — contradiction.

### From Pure Mathematics to Internet Design

This elegant piece of pure mathematics has immediate practical consequences. Modern internet infrastructure relies on redundant connections to maintain service when links fail. The principle our theorem captures — **even connectivity prevents single points of failure** — is essentially the mathematical foundation underlying redundant network design.

When network engineers design critical infrastructure (backbone internet connections, power grids, water systems), they often aim for what graph theorists call "2-edge-connectivity": every edge lies on a cycle, ensuring no single link failure can disconnect the network. Our theorem provides one sufficient condition: ensure every node connects to an even number of neighbors.

### The Broader Landscape

The study of bridges sits at the intersection of several active areas of mathematics and computer science:

- **Algorithmic graph theory**: Robert Tarjan's 1974 algorithm finds all bridges in linear time, a landmark result in algorithm design that earned him the Turing Award.
- **Network science**: Understanding which connections are bridges helps identify vulnerabilities in social networks, biological networks, and technological systems.
- **Matroid theory**: The bridge structure of a graph connects to deep algebraic structures called matroids, linking graph theory to abstract algebra and optimization.

What makes our work distinctive is not the theorems themselves — they are classical — but the level of certainty. By formalizing these proofs in Lean 4, we have produced arguments that have been checked by a computer, line by line, with absolute logical rigor. In an age where mathematical proofs grow increasingly complex, such machine verification provides a new standard of confidence.

---

## 7. Future Directions

Several natural extensions of this work present themselves:

1. **Menger's theorem** (edge version): The minimum edge-cut between two vertices equals the maximum number of edge-disjoint paths. This would generalize our bridge results to $k$-edge-connectivity.

2. **Ear decomposition theorem**: A connected graph is 2-edge-connected if and only if it has an ear decomposition. This provides constructive insight into bridge-free graph structure.

3. **Bridge-block tree**: Every connected graph decomposes uniquely into 2-edge-connected components connected by bridges, forming a tree structure. Formalizing this decomposition would be a significant contribution.

4. **Algorithmic verification**: Formally verifying Tarjan's bridge-finding algorithm within Lean 4, connecting our structural results to computational guarantees.

---

## 8. Conclusion

We have formally verified two fundamental theorems about bridge edges in finite graphs:

1. Connected graphs with all even degrees contain no bridges — a result connecting vertex-local information to global connectivity structure via a parity argument.

2. Trees are precisely the connected graphs in which every edge is a bridge — a clean characterization combining acyclicity and bridge structure.

Both proofs are machine-checked in Lean 4, building on the Mathlib library's graph theory infrastructure. The even-degree theorem, while classically derivable from Euler's theorem on Eulerian circuits, receives here a direct and self-contained proof via the handshaking lemma, demonstrating that formal verification need not sacrifice mathematical elegance.

---

## References

1. Euler, L. (1736). "Solutio problematis ad geometriam situs pertinentis." *Commentarii Academiae Scientiarum Petropolitanae*, 8, 128–140.

2. Tarjan, R. E. (1974). "A note on finding the bridges of a graph." *Information Processing Letters*, 2(6), 160–161.

3. Diestel, R. (2017). *Graph Theory* (5th ed.). Springer.

4. The Mathlib Community. (2020–). *Mathlib: the Lean mathematical library.* https://github.com/leanprover-community/mathlib4

5. de Moura, L., & Ullrich, S. (2021). "The Lean 4 theorem prover and programming language." *CADE 2021*.

---

## Appendix: Lean 4 Code

The complete Lean 4 formalization is available in `Bridges/BridgeTheory.lean`. The code:

- Defines no new axioms; proofs use only standard logical foundations (propext, Classical.choice, Quot.sound).
- Builds on Mathlib's `SimpleGraph` infrastructure.
- Compiles with Lean 4.28.0 and Mathlib v4.28.0.
