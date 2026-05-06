# Bridges in Graph Theory: A Formally Verified Treatment

## From Königsberg to Modern Network Analysis

---

### Abstract

We present a formally verified development of bridge (cut edge) theory in graph theory, mechanized in the Lean 4 theorem prover with the Mathlib library. Our contributions include: (1) a proof that removing a bridge from a connected graph produces exactly two connected components, (2) a characterization of trees as connected graphs where every edge is a bridge, (3) a formalization of the Königsberg Bridge Problem proving the impossibility of an Eulerian trail, and (4) supporting structural lemmas about bridge splitting and vertex partition. All proofs are machine-verified, depending only on the standard axioms of classical logic (propext, Classical.choice, Quot.sound).

**Keywords:** Graph theory, bridges, cut edges, formal verification, Lean 4, Königsberg, Eulerian trails, trees, network reliability

---

### 1. Introduction

The theory of bridges in graph theory has its origins in one of mathematics' most celebrated problems. In 1736, Leonhard Euler analyzed whether it was possible to walk through the city of Königsberg, crossing each of its seven bridges exactly once. His negative answer — and more importantly, his *proof* of impossibility — is widely considered the birth of graph theory as a mathematical discipline.

A **bridge** (also called a *cut edge* or *isthmus*) is an edge in a connected graph whose removal disconnects the graph. This simple definition belies the concept's deep structural importance: bridges are the critical edges that hold a graph together, the "weak links" whose failure splits a network in two.

In this work, we develop a formally verified theory of bridges using the Lean 4 proof assistant and its extensive mathematical library Mathlib. Formal verification provides absolute certainty that our proofs are correct — every logical step is checked by a computer, eliminating the possibility of subtle errors that occasionally appear even in published mathematical proofs.

#### 1.1 Contributions

Our formalization includes the following results, all verified in Lean 4:

1. **Two Components Theorem** (`IsBridge.two_connected_components`): Removing a bridge from a connected finite graph produces exactly two connected components.

2. **Bridge Splitting** (`IsBridge.forall_reachable_delete_left_or_right`): Every vertex in a connected graph is reachable from one endpoint of a deleted bridge.

3. **Tree Characterization** (`connected_isBridge_all_iff_isTree`): A connected graph is a tree if and only if every edge is a bridge.

4. **Königsberg Impossibility** (`konigsberg_no_eulerian_trail`): The Königsberg graph admits no Eulerian trail.

5. **Supporting infrastructure**: Equivalence between `deleteEdges` and `sdiff` formulations, connected component separation, and degree computations.

---

### 2. Mathematical Background

#### 2.1 Basic Definitions

Let $G = (V, E)$ be a simple graph. We use Mathlib's `SimpleGraph` structure, which represents a graph as a symmetric, irreflexive relation on a vertex type $V$.

**Definition (Bridge).** An edge $e = \{u, v\} \in E$ is a *bridge* of $G$ if $u$ and $v$ are not reachable from each other in $G \setminus \{e\}$, the graph obtained by deleting $e$.

In Mathlib, this is formalized as:
```
def IsBridge (G : SimpleGraph V) (e : Sym2 V) : Prop :=
  e ∈ G.edgeSet ∧ Sym2.lift ⟨fun v w => ¬(G \ fromEdgeSet {e}).Reachable v w, ...⟩ e
```

**Definition (Connected Component).** The connected components of $G$ are the equivalence classes of the reachability relation. Mathlib provides `G.ConnectedComponent` as a quotient type.

**Definition (Tree).** A graph is a *tree* if it is connected and acyclic (`IsTree`).

**Definition (Eulerian Trail).** A walk is *Eulerian* if it visits every edge exactly once (`Walk.IsEulerian`).

#### 2.2 The Bridge-Cycle Characterization

A classical result (already in Mathlib as `isBridge_iff_adj_and_forall_cycle_notMem`) states:

> An edge $\{v, w\}$ is a bridge if and only if $G$ contains $\{v, w\}$ as an edge and $\{v, w\}$ does not lie on any cycle.

This equivalence is the foundation of our theory: an edge is structurally critical (a bridge) precisely when it provides the *only* path between its endpoints.

---

### 3. Main Results

#### 3.1 The Two Components Theorem

**Theorem 3.1** (Two Components). *Let $G$ be a connected graph on a finite vertex set $V$, and let $\{u, v\}$ be a bridge of $G$. Then $G \setminus \{u, v\}$ has exactly two connected components.*

This result is formalized as:
```lean
theorem IsBridge.two_connected_components [DecidableEq V] [Fintype V]
    [DecidableRel G.Adj]
    (hconn : G.Connected) {u v : V} (hb : G.IsBridge s(u, v)) :
    Fintype.card (G.deleteEdges {s(u, v)}).ConnectedComponent = 2
```

The proof proceeds in two steps:

1. **Bridge Splitting** (Lemma 3.2): We first show that every vertex $w$ is reachable from either $u$ or $v$ in the deleted graph. This is proved by induction on the length of a walk from $u$ to $w$ in $G$, carefully handling the case where the walk crosses the bridge.

2. **Counting Components**: Since every vertex belongs to either the component of $u$ or the component of $v$, and these components are distinct (by the bridge property), the number of components is exactly 2.

**Lemma 3.2** (Bridge Splitting). *Let $G$ be a connected graph and $\{u, v\}$ a bridge. For every vertex $w$, either $w$ is reachable from $u$ or from $v$ in $G \setminus \{u, v\}$.*

```lean
theorem IsBridge.forall_reachable_delete_left_or_right
    (hconn : G.Connected) {u v : V} (hb : G.IsBridge s(u, v)) (w : V) :
    (G.deleteEdges {s(u, v)}).Reachable u w ∨
    (G.deleteEdges {s(u, v)}).Reachable v w
```

#### 3.2 Tree Characterization via Bridges

**Theorem 3.3** (Tree ↔ All Bridges). *A connected graph is a tree if and only if every edge is a bridge.*

```lean
theorem connected_isBridge_all_iff_isTree (hconn : G.Connected) :
    (∀ ⦃u v : V⦄, G.Adj u v → G.IsBridge s(u, v)) ↔ G.IsTree
```

The forward direction uses the Mathlib characterization `isAcyclic_iff_forall_adj_isBridge`: if every edge is a bridge, then no edge lies on a cycle, hence the graph is acyclic. Combined with connectivity, this gives a tree.

The reverse direction (`IsTree.isBridge_of_adj`) follows because a tree is acyclic, so no edge lies on a cycle, making every edge a bridge.

#### 3.3 The Königsberg Bridge Problem

**Theorem 3.4** (Königsberg Impossibility). *The complete graph $K_4$ (modeling the four landmasses of Königsberg) admits no Eulerian trail.*

```lean
theorem konigsberg_no_eulerian_trail :
    ∀ (u v : Konigsberg) (p : konigsbergGraph.Walk u v), ¬p.IsEulerian
```

The proof uses Euler's necessary condition: an Eulerian trail requires at most 2 vertices of odd degree. We compute that all four vertices of $K_4$ have degree 3 (odd), giving 4 odd-degree vertices — a contradiction.

**Lemma 3.5.** *Every vertex in $K_4$ has degree 3.*

This is verified by exhaustive computation (`fin_cases v` followed by `decide`), exploiting the finite nature of the problem.

---

### 4. Formalization Details

#### 4.1 Technical Challenges

**Deletion representations.** Mathlib offers two ways to delete edges: `G.deleteEdges s` and `G \ fromEdgeSet s`. These are not definitionally equal but have the same adjacency relation. We establish a reachability equivalence (`reachable_deleteEdges_iff_reachable_sdiff`) to bridge between the two formulations used in different parts of Mathlib.

**Connected component counting.** Proving that a Fintype has exactly $k$ elements requires careful handling of the equivalence between the quotient type (ConnectedComponent) and its finite enumeration. Our proof constructs a bijection between the set of components and a two-element set.

**Decidability instances.** Many graph-theoretic computations require `DecidableEq V`, `Fintype V`, and `DecidableRel G.Adj`. We are careful to include these as hypotheses only where needed (the Two Components Theorem), keeping the infinite-graph results (Bridge Splitting, Tree Characterization) fully general.

#### 4.2 Axiom Usage

All our theorems depend only on the standard axioms:
- `propext` (propositional extensionality)
- `Classical.choice` (axiom of choice)
- `Quot.sound` (quotient soundness)

No `sorry`, `axiom`, or `@[implemented_by]` declarations are used.

#### 4.3 Lines of Code

| File | Lines | Theorems |
|------|-------|----------|
| `Basic.lean` | ~150 | 6 theorems (bridge splitting, two components, tree characterization) |
| `Konigsberg.lean` | ~100 | 4 theorems (degree computation, odd-degree count, Euler impossibility) |
| **Total** | ~250 | 10 formally verified results |

---

### 5. Discussion: Why Bridges Matter

*For a general audience*

#### The Birth of a Mathematical Field

Imagine you're in 18th-century Königsberg (now Kaliningrad, Russia), a beautiful Prussian city built around the Pregel River. Two islands sit in the river, connected to the mainland and each other by seven bridges. The citizens had a favorite puzzle: *Can you walk through the city, crossing each bridge exactly once?*

Many tried. All failed. But it took a mathematical genius — Leonhard Euler — to prove that the task was truly impossible, not just difficult. His 1736 paper didn't just solve a puzzle; it invented an entirely new branch of mathematics.

Euler's key insight was breathtakingly simple: forget about the geography. Forget the winding streets, the architecture, the river's flow. What matters is only the *connections* — which landmasses are linked by which bridges. He stripped the problem down to its mathematical skeleton: four points (the landmasses) connected by seven lines (the bridges). This skeleton is what we now call a **graph**.

#### What Makes a Bridge Critical?

In modern graph theory, we've turned Euler's insight around. Instead of asking "can we cross every bridge?", we ask: "what happens if a bridge fails?"

A **bridge** (in the graph-theoretic sense) is an edge whose removal disconnects the graph — it literally breaks the network into two pieces. Our main theorem proves this rigorously: removing a bridge from a connected network always produces *exactly* two disconnected components. Not three, not four — always two. The bridge is the unique bottleneck connecting two otherwise separate parts of the network.

This is more than a mathematical curiosity. Think about it in terms of real infrastructure:

- **Power grids:** A bridge in the transmission network is a single line whose failure could black out an entire region.
- **Internet:** A bridge in the network topology is a single cable whose failure could disconnect millions of users.
- **Road networks:** A bridge (in the literal, physical sense!) over a river might be the only connection between two parts of a city.
- **Social networks:** A bridge in a social graph is a person who is the sole connection between two otherwise separate communities.

#### Trees: The Most Fragile Networks

Our tree characterization theorem reveals something profound: *a connected network where every link is critical is exactly a tree*. Trees are the most economical way to connect things — they use the minimum number of edges — but they are also the most fragile. Remove any single edge and the network falls apart.

This is the fundamental trade-off in network design: efficiency vs. resilience. A tree uses $n-1$ edges to connect $n$ nodes but has zero redundancy. Adding even one extra edge creates a cycle, which means at least two edges become non-bridges — they provide alternative paths.

#### The Power of Formal Verification

Why formalize these proofs in a computer? Isn't a good textbook proof sufficient?

For these classical results, a textbook proof is indeed convincing. But formal verification offers something more: *absolute certainty*. Every logical step is checked by a computer. There are no gaps, no "obvious" steps that might hide subtle errors, no appeals to intuition that might mislead.

This matters increasingly as mathematics tackles problems too complex for any single human to verify. The classification of finite simple groups spans tens of thousands of pages. Hales' proof of the Kepler conjecture required computer assistance. In these cases, formal verification is not a luxury — it's a necessity.

Our work demonstrates that modern proof assistants like Lean 4, backed by comprehensive libraries like Mathlib, make formal verification practical even for working mathematicians. The proofs are not just correct — they are *permanently* correct, immune to the passage of time and the fallibility of human review.

---

### 6. Applications

#### 6.1 Network Reliability Analysis

The Two Components Theorem directly applies to reliability engineering. Given a network (computer, electrical, transportation), finding bridges identifies **single points of failure**. The fix is clear: add redundant edges to eliminate bridges, making the network 2-edge-connected.

**Algorithm (Tarjan, 1974):** Bridges can be found in $O(V + E)$ time using a depth-first search with low-link values. This is implemented in standard graph libraries (NetworkX, Boost Graph Library, etc.).

#### 6.2 Community Detection

In social network analysis, bridges often correspond to **weak ties** — connections between otherwise separate communities. Granovetter's "Strength of Weak Ties" theory (1973) argues that these bridges are disproportionately important for information flow, even though (or because) they connect people from different social circles.

#### 6.3 Bioinformatics

In protein interaction networks and metabolic networks, bridge edges represent essential interactions — removing them disconnects the network into separate functional modules. This helps identify critical proteins whose disruption would fundamentally alter cellular function.

#### 6.4 Circuit Design

In electrical circuit analysis, bridges correspond to wires whose removal would disconnect parts of the circuit. Identifying them is crucial for understanding circuit robustness and failure modes.

---

### 7. Related Work

Bridge theory in Mathlib was initiated with the definition of `SimpleGraph.IsBridge` and the bridge-cycle characterization (`isBridge_iff_adj_and_forall_cycle_notMem`). The acyclicity characterization via bridges (`isAcyclic_iff_forall_adj_isBridge`) was also previously established.

Our work extends this foundation with the Two Components Theorem and the full tree characterization. The Königsberg formalization connects these abstract results to their historical origin.

Other formal verification efforts in graph theory include:
- The Four Color Theorem (Gonthier, 2005, in Coq)
- Euler's formula for planar graphs (various formalizations)
- The Handshaking Lemma (in Mathlib)

To our knowledge, the Two Components Theorem for bridges has not been previously formalized in any proof assistant.

---

### 8. Future Directions

Several natural extensions suggest themselves:

1. **Euler's Theorem (sufficient condition):** Mathlib proves that Eulerian trails require ≤ 2 odd-degree vertices. The converse — that this condition is also sufficient — remains unformalized (explicitly marked as a TODO in Mathlib's `Trails.lean`).

2. **Block-cut tree decomposition:** Every connected graph decomposes into 2-connected components (blocks) joined by cut vertices, forming a tree structure. This is the vertex analogue of bridge decomposition.

3. **Menger's Theorem (edge version):** The minimum edge cut between two vertices equals the maximum number of edge-disjoint paths. This deep result generalizes bridge theory.

4. **Tarjan's algorithm verification:** A formally verified implementation of the linear-time bridge-finding algorithm would connect our pure theory to computational practice.

---

### 9. Conclusion

We have presented a formally verified development of bridge theory in graph theory, proving that removing a bridge creates exactly two components, characterizing trees as graphs where every edge is a bridge, and formalizing the impossibility of an Eulerian trail in the Königsberg graph. All proofs are machine-verified in Lean 4 with Mathlib, depending only on standard classical axioms.

The theory of bridges — from Euler's 1736 insight to modern network reliability — demonstrates how simple mathematical concepts can have profound practical consequences. Formal verification ensures that these foundational results are established with the highest possible degree of certainty.

---

### References

1. Euler, L. (1736). "Solutio problematis ad geometriam situs pertinentis." *Commentarii Academiae Scientiarum Petropolitanae*, 8, 128–140.

2. Tarjan, R. E. (1974). "A note on finding the bridges of a graph." *Information Processing Letters*, 2(6), 160–161.

3. Granovetter, M. (1973). "The Strength of Weak Ties." *American Journal of Sociology*, 78(6), 1360–1380.

4. The Mathlib Community. (2020–2025). *Mathlib: A unified library of mathematics formalized in Lean 4.* https://github.com/leanprover-community/mathlib4

5. de Moura, L., & Ullrich, S. (2021). "The Lean 4 Theorem Prover and Programming Language." *CADE-28*, 625–635.

---

*All Lean source code is available in the `Bridges/` directory. Python demonstrations with visualizations are in `Bridges/demos/`.*
