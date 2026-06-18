# Crossing Every Bridge Exactly Once: A Formally Verified Resolution of the Königsberg Bridge Problem

## Abstract

We present a complete formal verification in Lean 4 of the mathematical core of
Euler's 1736 resolution of the Königsberg Bridge Problem — the theorem that
launched graph theory. Our formalization includes three interconnected results:
(1) a proof that the complete graph K₄ admits no Eulerian walk, using Mathlib's
existing graph theory infrastructure; (2) a self-contained multigraph formalization
of the actual Königsberg bridge configuration, including the handshaking lemma
and parity theorem for multigraphs; and (3) structural theorems about bridge
edges (cut edges), including the fact that trees have only bridges while complete
graphs on 3+ vertices have none. All proofs are machine-checked with zero `sorry`
placeholders.

## 1. Introduction

In the summer of 1736, Leonhard Euler wrote a letter to the mayor of Danzig
containing what would become the first theorem of graph theory. The citizens of
Königsberg (now Kaliningrad, Russia) had long puzzled over whether one could
walk through the city crossing each of its seven bridges exactly once. Euler
proved this was impossible — and in doing so, invented an entirely new branch
of mathematics.

Euler's insight was profoundly simple: the problem has nothing to do with
geography, distances, or the shapes of the landmasses. It depends only on the
*connections* — which landmasses are linked by how many bridges. By abstracting
the city into what we now call a graph (vertices for landmasses, edges for
bridges), Euler reduced the problem to a question about vertex degrees.

**Euler's Theorem.** A connected graph has a walk traversing every edge exactly
once (an *Eulerian trail*) if and only if at most two vertices have odd degree.
If zero vertices have odd degree, the walk can return to its starting point
(an *Eulerian circuit*).

The Königsberg graph has four vertices, all with odd degree (5, 3, 3, 3).
Since 4 > 2, no Eulerian trail exists.

### 1.1 Contribution

We formalize this argument in Lean 4 using the Mathlib library, producing
machine-verified proofs of:

1. **The Eulerian Obstruction Theorem**: A graph with more than 2 odd-degree
   vertices admits no Eulerian walk (contrapositive of the necessary condition).

2. **K₄ Impossibility**: The complete graph on 4 vertices has no Eulerian walk,
   proved by computing that all 4 vertices have degree 3 (odd).

3. **Multigraph Handshaking Lemma**: For multigraphs (graphs with parallel edges),
   the sum of all vertex degrees is even.

4. **Multigraph Parity Theorem**: The number of odd-degree vertices in any
   multigraph is always even.

5. **Königsberg Degree Computation**: The Königsberg multigraph has degrees
   5, 3, 3, 3 — all odd, giving 4 odd-degree vertices (> 2).

6. **Bridge Edge Theorems**: In a tree, every edge is a bridge; in Kₙ (n > 2),
   no edge is a bridge; an edge is a bridge iff it lies in no cycle.

## 2. Mathematical Background

### 2.1 Graphs and Multigraphs

A **simple graph** G = (V, E) consists of a vertex set V and an edge set
E ⊆ {{u,v} : u,v ∈ V, u ≠ v}. A **multigraph** generalizes this by allowing
multiple edges between the same pair of vertices, described by a symmetric
multiplicity function adj : V × V → ℕ with adj(v,v) = 0.

The **degree** of a vertex v is the number of edges incident to v:
- Simple graph: deg(v) = |{w ∈ V : {v,w} ∈ E}|
- Multigraph: deg(v) = Σ_w adj(v,w)

### 2.2 The Handshaking Lemma

**Theorem (Handshaking Lemma).** In any finite graph, Σ_v deg(v) = 2|E|.

*Proof.* Each edge {u,v} contributes 1 to deg(u) and 1 to deg(v), hence 2
to the total sum. □

**Corollary (Parity Theorem).** The number of vertices with odd degree is even.

*Proof.* Since Σ deg(v) is even (= 2|E|), and the sum of the even-degree terms
is even, the sum of the odd-degree terms must also be even. A sum of odd numbers
is even iff there are evenly many of them. □

### 2.3 Eulerian Trails

An **Eulerian trail** (or Eulerian path) is a walk that traverses every edge
exactly once. An **Eulerian circuit** is an Eulerian trail that starts and ends
at the same vertex.

**Theorem (Euler, 1736).** A connected graph has an Eulerian trail if and only
if it has at most 2 vertices of odd degree.

The necessary condition follows from observing that at each intermediate vertex
of the trail, you enter and leave, using edges in pairs — so the degree must
be even. The start and end vertices may have odd degree (one edge used for
departure/arrival without a matching partner). The sufficient condition is
constructive (Fleury's algorithm or Hierholzer's algorithm).

### 2.4 Bridge Edges

A **bridge** (or cut edge) is an edge whose removal disconnects the graph.
Bridges are characterized by the following equivalence:

**Theorem.** An edge e is a bridge if and only if e lies in no cycle.

This connects to Eulerian trails via Fleury's algorithm: when constructing an
Eulerian trail, one should always prefer crossing non-bridge edges, since
crossing a bridge may strand unvisited edges on the other side.

## 3. Formalization

### 3.1 Architecture

Our formalization consists of three Lean 4 files:

| File | Theorems | Description |
|------|----------|-------------|
| `EulerianImpossibility.lean` | 4 | K₄ impossibility via Mathlib |
| `Konigsberg.lean` | 7 | Multigraph theory + Königsberg |
| `BridgeEdges.lean` | 5 | Bridge (cut edge) structure |

### 3.2 Simple Graph Approach (EulerianImpossibility.lean)

We define K₄ as the top element of the SimpleGraph lattice on Fin 4:

```lean
abbrev K4 : SimpleGraph (Fin 4) := ⊤
```

Computing degrees uses `fin_cases` and `decide`:

```lean
theorem K4_degree (v : Fin 4) : K4.degree v = 3 := by
  fin_cases v <;> simp +decide
```

The key bridge to impossibility is the **Eulerian Obstruction Theorem**,
which is the contrapositive of Mathlib's `Walk.IsEulerian.card_filter_odd_degree`:

```lean
theorem odd_degree_eulerian_obstruction
    {V : Type*} {G : SimpleGraph V} [DecidableEq V] [Fintype V] [DecidableRel G.Adj]
    (h : (Finset.filter (fun v => Odd (G.degree v)) Finset.univ).card > 2) :
    ∀ (u v : V) (p : G.Walk u v), ¬p.IsEulerian
```

The final theorem follows by computation:

```lean
theorem K4_no_eulerian_walk :
    ∀ (u v : Fin 4) (p : K4.Walk u v), ¬p.IsEulerian := by
  apply odd_degree_eulerian_obstruction
  native_decide
```

### 3.3 Multigraph Approach (Konigsberg.lean)

Since Mathlib's `SimpleGraph` does not support parallel edges, we define:

```lean
structure Multigraph (V : Type*) [Fintype V] [DecidableEq V] where
  adj : V → V → ℕ
  adj_self : ∀ v, adj v v = 0
  adj_symm : ∀ v w, adj v w = adj w v
```

We prove the handshaking lemma and parity theorem from scratch, then
instantiate the Königsberg graph with its historical adjacency matrix:

```lean
def konigsbergAdj : Fin 4 → Fin 4 → ℕ
  | 0, 1 => 2 | 1, 0 => 2  -- A ↔ B: 2 bridges
  | 0, 2 => 2 | 2, 0 => 2  -- A ↔ C: 2 bridges
  | 0, 3 => 1 | 3, 0 => 1  -- A ↔ D: 1 bridge
  | 1, 3 => 1 | 3, 1 => 1  -- B ↔ D: 1 bridge
  | 2, 3 => 1 | 3, 2 => 1  -- C ↔ D: 1 bridge
  | _, _ => 0
```

The degrees are computed to be 5, 3, 3, 3 — all odd — and the
impossibility follows from the count exceeding 2.

### 3.4 Bridge Edges (BridgeEdges.lean)

We prove five structural results, including:

- **Tree edge count**: |E| = |V| - 1 for trees
- **Complete graph resilience**: Kₙ has no bridges for n > 2
- **Cycle characterization**: an edge is a bridge iff it lies in no cycle

The complete graph theorem is particularly interesting: between any two
adjacent vertices u and v in Kₙ (n > 2), there exists a third vertex w,
providing an alternative path u → w → v even after removing {u,v}.

## 4. Discussion: A Walk Through History

*For the general reader.*

Imagine you're a tourist in an 18th-century Prussian city. The river Pregel
winds through Königsberg, creating two islands and dividing the city into four
districts. Seven bridges connect these districts. As you stroll along the
riverbanks, a question naturally arises: *Can you plan a walk that crosses
each bridge exactly once?*

The citizens of Königsberg tried for years. Some claimed to have found routes;
others argued it was impossible. But nobody could *prove* it either way.

Enter Leonhard Euler, the most prolific mathematician in history. In 1736,
Euler received a letter about the bridge puzzle from Carl Leonhard Gottlieb
Ehler, the mayor of Danzig. Euler initially dismissed the problem as "banal"
— it involved no deep calculation, no equations, no geometry. But then he
realized something profound: the very fact that the problem *couldn't* be
solved by traditional mathematics meant something new was needed.

### 4.1 The Birth of Graph Theory

Euler's breakthrough was to strip away everything irrelevant. The shapes of
the islands don't matter. The lengths of the bridges don't matter. The only
thing that matters is *which landmasses are connected to which*, and by how
many bridges.

He represented each landmass as a point (a *vertex*) and each bridge as a
line (an *edge*). This was the first graph in the mathematical sense — a
concept that would eventually underpin everything from social networks to
GPS navigation to molecular biology.

### 4.2 The Handshake Argument

Euler's key insight is beautifully simple. Think about what happens at each
landmass as you walk. Every time you enter a landmass, you must also leave
it (unless it's your starting or ending point). Each entrance uses one bridge;
each exit uses another. So bridges are consumed in pairs.

This means that at every intermediate landmass, the number of bridges must be
*even* — you need pairs for entering and leaving. Only the starting and ending
landmasses can have an odd number of bridges.

Now count: the central island (A) has 5 bridges. The north bank (B) has 3.
The south bank (C) has 3. The east bank (D) has 3. *All four* have an odd
number — but only two landmasses are allowed to be odd (the start and end).

Four is greater than two. The walk is impossible. Q.E.D.

### 4.3 The Handshaking Lemma in Everyday Life

The handshaking lemma — that the number of odd-degree vertices is always
even — appears everywhere once you know to look for it.

At a party, the number of people who have shaken an odd number of hands is
always even. In a telephone network, the number of people who have made an
odd number of calls is always even. In a city, the number of intersections
with an odd number of roads is always even.

This is not a coincidence — it's the same theorem wearing different clothes.

### 4.4 Why This Matters Today

Euler's bridge problem is far from obsolete. Its descendants include:

- **Route optimization**: Postal carriers, garbage trucks, and street sweepers
  must traverse every street. The Chinese Postman Problem generalizes
  Euler's question to find the shortest route covering all edges.

- **DNA sequencing**: Modern genome sequencing algorithms (de Bruijn graphs)
  are essentially Eulerian path problems on enormous graphs.

- **Circuit design**: Wiring a circuit board to test every connection requires
  finding Eulerian paths in the testing graph.

- **Network reliability**: Bridge edges identify single points of failure.
  If a network has no bridge edges, it can survive any single link failure.

## 5. Applications

### 5.1 Network Reliability Assessment

Our formalization of bridge edges has direct applications in network design.
The theorem `completeGraph_no_bridges` proves that fully connected networks
have no single points of failure. In practice, this motivates redundant
connections in critical infrastructure.

**Application**: Given a network topology, identify all bridge edges
(single points of failure) and add redundant connections to eliminate them.
Our bridge characterization theorem shows that adding an edge that creates a
cycle through a bridge converts it from a bridge to a non-bridge.

### 5.2 Route Planning

The Eulerian obstruction theorem provides a quick check for route planning
problems: count odd-degree vertices. If more than 2, no perfect route exists
and edges must be duplicated. The minimum number of duplications needed equals
(odd_count - 2) / 2.

### 5.3 Puzzle Design

The degree-parity check is a powerful tool for puzzle design:
- Want a solvable maze? Ensure at most 2 odd-degree vertices.
- Want an impossible puzzle? Include 4+ odd-degree vertices.
- Want a circuit (return to start)? Make all degrees even.

## 6. Conclusion

We have formally verified the mathematical core of the Königsberg Bridge
Problem in Lean 4, producing machine-checked proofs of impossibility for
both the simple-graph analog (K₄) and the actual multigraph configuration.
Our formalization includes the handshaking lemma, parity theorem, and bridge
edge characterization, totaling approximately 315 lines of Lean code with
16 formally verified theorems and zero uses of `sorry`.

The formalization demonstrates that 288-year-old mathematics can be made
completely rigorous by modern proof assistants, and that the foundational
theorems of graph theory — born from a recreational puzzle about bridges —
continue to find applications in network design, biology, and algorithm
design today.

## References

1. L. Euler, "Solutio problematis ad geometriam situs pertinentis,"
   *Commentarii Academiae Scientiarum Petropolitanae* 8 (1741), 128–140.
   (Presented 1736.)

2. The Mathlib Community, *Mathlib: a unified library of mathematics
   formalized in Lean 4*, 2024. https://github.com/leanprover-community/mathlib4

3. R. Diestel, *Graph Theory*, 5th edition, Graduate Texts in Mathematics 173,
   Springer, 2017.
