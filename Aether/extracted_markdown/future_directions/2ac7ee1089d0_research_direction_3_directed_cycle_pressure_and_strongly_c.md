# Directed Cycle Pressure: A Local Graph Invariant via Strongly Connected Components

## Abstract

We introduce **directed cycle pressure**, a local graph invariant for directed graphs that measures the recurrent complexity of directed neighborhoods via strongly connected component (SCC) analysis. Unlike undirected cycle pressure, which symmetrizes the graph and loses orientation information, directed pressure detects genuine causal feedback — vertices participating in directed cycles within local reachability balls. We prove three foundational theorems: (1) directed pressure is dominated by undirected pressure under symmetrization, establishing backward compatibility; (2) the inequality is strict on explicit families, proving the invariant is genuinely finer; and (3) zero directed pressure exactly characterizes the absence of nontrivial local SCCs. We additionally prove DAG vanishing (acyclic graphs have zero pressure everywhere) and monotonicity in the observation radius. All results are formally verified in Lean 4 with Mathlib. We provide efficient algorithms (O(V+E) via Tarjan) and demonstrate applications to proof dependency analysis, software architecture, and causal network diagnostics.

**Keywords:** directed graphs, strongly connected components, local graph invariants, cycle pressure, causal complexity, proof dependency graphs, formal verification

---

## 1. Introduction

### 1.1 Motivation

The structure of mathematical knowledge is inherently directed: theorems depend on lemmas, definitions rest on axioms, and the dependency relation is fundamentally asymmetric. When analyzing the local complexity of such dependency structures, the standard approach has been to work with symmetrized (undirected) graphs and measure cyclic complexity via invariants such as the cyclomatic number (first Betti number) or local cycle counts.

This symmetrization discards essential structural information. A one-way fan-in pattern (many lemmas feeding into a single theorem) and a genuine feedback structure (mutual dependence between results) are conflated when edge orientation is forgotten. The practical consequence is that undirected invariants systematically overestimate the complexity of hierarchical structures and fail to distinguish acyclic dependencies from genuine circular reasoning.

### 1.2 Contribution

We define a new invariant — **directed cycle pressure** — that respects the directional structure of the graph. Our definition is based on counting vertices in the directed out-ball that participate in nontrivial strongly connected components. This is:

- **Local**: it examines a bounded neighborhood of each vertex.
- **Monotone**: it can only increase as the observation radius grows.
- **Computable**: it can be evaluated in linear time using Tarjan's SCC algorithm.
- **Backward-compatible**: it is bounded above by the undirected analogue.
- **Strictly finer**: explicit examples demonstrate strict inequality.

### 1.3 Organization

Section 2 presents definitions. Section 3 states and proves the main theorems. Section 4 describes algorithms with complexity analysis. Section 5 demonstrates applications. Section 6 discusses implications and open problems.

---

## 2. Definitions and Notation

### 2.1 Digraphs

A **digraph** G = (V, E) consists of a finite vertex set V and a binary relation E ⊆ V × V (the edge set, where (u,v) ∈ E means there is a directed edge from u to v). We write G.Adj u v for (u,v) ∈ E.

### 2.2 Directed Out-Ball

The **directed out-ball** of radius r around vertex v is defined iteratively:

```
outBall(G, v, 0) = {v}
outBall(G, v, r+1) = outBall(G, v, r) ∪ { u : ∃ w ∈ outBall(G, v, r), G.Adj(w, u) }
```

This contains precisely the vertices reachable from v by a directed path of length ≤ r.

### 2.3 Reachability and Mutual Reachability

**Directed reachability**: dgReach(G, u, v) holds if v ∈ outBall(G, u, |V|). For finite graphs, this captures full directed reachability since any simple directed path has length at most |V|.

**Mutual reachability**: Vertices u and w are mutually reachable if dgReach(G, u, w) and dgReach(G, w, u).

### 2.4 Recurrence (Nontrivial SCC Membership)

A vertex u is **recurrent** in G if there exists w ≠ u such that u and w are mutually reachable:

```
isRecurrent(G, u) ⟺ ∃ w, w ≠ u ∧ dgReach(G, u, w) ∧ dgReach(G, w, u)
```

Equivalently, u belongs to a strongly connected component of size ≥ 2.

### 2.5 Directed Cycle Pressure

The **directed cycle pressure** at vertex v with radius r is:

```
dirPressure(G, v, r) = |{ u ∈ outBall(G, v, r) : isRecurrent(G, u) }|
```

### 2.6 Symmetrization

The **symmetrization** (forgetDir) of a digraph G is the simple graph H on the same vertex set where H.Adj(u,v) iff u ≠ v and (G.Adj(u,v) or G.Adj(v,u)).

### 2.7 Undirected Ball and Pressure

The **undirected ball** is defined analogously to the directed out-ball but using the symmetric adjacency. The **undirected pressure** counts non-isolated vertices (those with at least one neighbor) in the undirected ball:

```
undirPressure(H, v, r) = |{ u ∈ undirBall(H, v, r) : ∃ w, H.Adj(u, w) }|
```

### 2.8 DAG Predicate

A digraph G is a **DAG** (directed acyclic graph) if no vertex is recurrent:

```
isDAG(G) ⟺ ∀ u, ¬ isRecurrent(G, u)
```

### 2.9 Causal Asymmetry

The **causal asymmetry** measures the gap between undirected and directed pressure:

```
causalAsymmetry(G, v, r) = undirPressure(forgetDir(G), v, r) - dirPressure(G, v, r)
```

---

## 3. Main Results

### Theorem 1: Comparison Theorem

**Statement.** For every finite digraph G, vertex v, and radius r:

```
dirPressure(G, v, r) ≤ undirPressure(forgetDir(G), v, r)
```

**Proof sketch.** The proof establishes two key lemmas:

1. **Ball containment**: outBall(G, v, r) ⊆ undirBall(forgetDir(G), v, r).

   *Proof by induction on r.* Base: both balls equal {v}. Step: if u ∈ outBall(G, v, r+1), either u ∈ outBall(G, v, r) (apply IH), or there exists w ∈ outBall(G, v, r) with G.Adj(w, u). By IH, w ∈ undirBall(forgetDir(G), v, r). If w = u, then u is already in the undirected ball by IH. If w ≠ u, then forgetDir(G).Adj(w, u) holds (since G.Adj(w, u) and w ≠ u), so u is adjacent to a vertex in the undirected ball and thus belongs to undirBall(forgetDir(G), v, r+1).

2. **Recurrence implies non-isolation**: if isRecurrent(G, u) then hasNeighbor(forgetDir(G), u).

   *Proof by contraposition.* If u has no neighbor in forgetDir(G), then for all z ≠ u, neither G.Adj(u, z) nor G.Adj(z, u) holds. We show that outBall(G, u, r) = {u} for all r by induction: the only elements added at each step are out-neighbors of vertices in the ball, but u has no out-neighbors other than (possibly) itself, and the ball never grows beyond {u}. Thus no w ≠ u is reachable from u, contradicting isRecurrent(G, u).

Combining: the set {u ∈ outBall(G,v,r) : isRecurrent(G,u)} is a subset of {u ∈ undirBall(forgetDir(G),v,r) : hasNeighbor(forgetDir(G),u)}, giving the cardinality inequality. □

### Theorem 2: Strict Separation

**Statement.** There exists a finite digraph G, vertex v, and radius r such that dirPressure(G, v, r) < undirPressure(forgetDir(G), v, r).

**Proof.** The **oriented diamond** G on vertices {s, a, b, t} with edges s→a, s→b, a→t, b→t provides a concrete witness.

- outBall(G, s, 2) = {s, a, b, t}. Since G is a DAG (no directed cycles), isRecurrent(G, u) = false for all u. Hence dirPressure(G, s, 2) = 0.

- forgetDir(G) has edges s-a, s-b, a-t, b-t. undirBall(forgetDir(G), s, 2) = {s, a, b, t}. Every vertex has at least one neighbor: s has {a,b}, a has {s,t}, b has {s,t}, t has {a,b}. Hence undirPressure(forgetDir(G), s, 2) = 4.

Therefore 0 < 4, establishing strict separation. This is verified computationally via `native_decide` in the formal proof. □

### Theorem 3: Zero Pressure Characterization

**Statement.** dirPressure(G, v, r) = 0 if and only if no vertex in outBall(G, v, r) is recurrent.

**Proof.** dirPressure is defined as the cardinality of a filtered finset. A finset has cardinality zero iff it is empty. The filter is empty iff no element of the base set satisfies the predicate. □

### Theorem 4: DAG Vanishing

**Statement.** If G is a DAG, then dirPressure(G, v, r) = 0 for all v and r.

**Proof.** If G is a DAG, no vertex is recurrent (by definition of isDAG). By the zero pressure characterization, dirPressure = 0. □

### Theorem 5: Radius Monotonicity

**Statement.** If r ≤ s, then dirPressure(G, v, r) ≤ dirPressure(G, v, s).

**Proof.** By outBall monotonicity (outBall(G, v, r) ⊆ outBall(G, v, s) when r ≤ s), the filtered set at radius r is a subset of the filtered set at radius s. □

### Theorem 6: Non-negative Causal Asymmetry

**Statement.** causalAsymmetry(G, v, r) ≥ 0.

This follows from the comparison theorem since causalAsymmetry = undirPressure - dirPressure ≥ 0 (natural number subtraction truncates to 0).

---

## 4. Algorithms

### 4.1 Out-Ball Computation

```
function OUT_BALL(G, v, r):
    B ← {v}
    for k = 1 to r:
        B ← B ∪ { u : ∃ w ∈ B, (w,u) ∈ E }
    return B
```

**Time complexity**: O(r · (|B| + |E_local|)) where E_local is the number of edges incident to B.

### 4.2 Tarjan's SCC Algorithm

```
function TARJAN_SCCS(G):
    index_counter ← 0
    S ← empty stack
    sccs ← empty list
    for each v ∈ V:
        if v not visited:
            STRONGCONNECT(v)
    return sccs

function STRONGCONNECT(v):
    v.index ← v.lowlink ← index_counter++
    push v onto S
    for each (v, w) ∈ E:
        if w not visited:
            STRONGCONNECT(w)
            v.lowlink ← min(v.lowlink, w.lowlink)
        elif w on stack:
            v.lowlink ← min(v.lowlink, w.index)
    if v.lowlink == v.index:
        pop SCC from S until v is popped
        emit SCC
```

**Time complexity**: O(V + E).
**Space complexity**: O(V).

### 4.3 Directed Pressure Computation

```
function DIR_PRESSURE(G, v, r):
    B ← OUT_BALL(G, v, r)
    SCCs ← TARJAN_SCCS(G)
    recurrent ← { u : ∃ SCC ∈ SCCs, u ∈ SCC, |SCC| ≥ 2 }
    return |B ∩ recurrent|
```

**Time complexity**: O(r · |B| + V + E).

### 4.4 Full Pressure Profile

To compute pressure at all radii up to R for all vertices:

```
function PRESSURE_PROFILE(G, R):
    SCCs ← TARJAN_SCCS(G)           // O(V + E)
    recurrent ← nontrivial SCC vertices
    for each v ∈ V:
        B ← {v}
        for r = 0 to R:
            yield (v, r, |B ∩ recurrent|)
            B ← B ∪ neighbors(B)    // expand ball
```

**Total time**: O(V · R · (V + E)).

---

## 5. Computational Experiments

### 5.1 Oriented Diamond

| Vertex | Radius | dirPressure | undirPressure | Causal Asymmetry |
|--------|--------|-------------|---------------|-----------------|
| s | 0 | 0 | 1 | 1 |
| s | 1 | 0 | 3 | 3 |
| s | 2 | 0 | 4 | 4 |

The oriented diamond confirms strict separation at all positive radii.

### 5.2 Feedback Graph (a→b→c→a, d→a)

| Vertex | Radius | dirPressure | undirPressure | Causal Asymmetry |
|--------|--------|-------------|---------------|-----------------|
| d | 1 | 1 | 2 | 1 |
| d | 2 | 2 | 4 | 2 |
| d | 3 | 3 | 4 | 1 |
| a | 1 | 2 | 4 | 2 |
| a | 2 | 3 | 4 | 1 |

Here dirPressure correctly identifies the {a,b,c} cycle while d is a non-recurrent feeder.

### 5.3 Star DAGs

| Fan-out n | dirPressure(c,1) | undirPressure(c,1) | Causal Asymmetry |
|-----------|------------------|--------------------|-----------------|
| 3 | 0 | 4 | 4 |
| 5 | 0 | 6 | 6 |
| 10 | 0 | 11 | 11 |
| 20 | 0 | 21 | 21 |

Causal asymmetry grows linearly with fan-out, demonstrating that high-degree DAG nodes accumulate phantom undirected complexity.

---

## 6. Discussion

### 6.1 Relationship to Prior Work

The undirected cycle pressure framework (proof-theoretic topology catalog) uses the cyclomatic number (first Betti number) of local threshold graphs as a topological invariant. Our directed pressure refines this by replacing homological cycle detection with causal recurrence detection via SCCs.

The condensation graph (DAG of SCCs) connects our work to classical graph decomposition theory. The directed pressure can be interpreted as a local measure of "recurrent mass" in the condensation: vertices that belong to multi-vertex SCC nodes contribute to pressure, while vertices in singleton SCC nodes do not.

### 6.2 Dynamical Systems Interpretation

Nontrivial SCCs correspond to recurrence classes in discrete dynamical systems. Directed pressure becomes a discrete analogue of the recurrent mass in ergodic theory. DAGs correspond to gradient-like systems with no recurrence — the DAG vanishing theorem is the graph-theoretic analogue of the absence of recurrence in gradient flows.

### 6.3 Limitations

Our current definition uses global SCC membership restricted to local balls. A fully local definition would restrict SCC computation to the induced subgraph on the ball, potentially yielding different results (vertices might be globally mutually reachable but not within the ball). The global definition is cleaner for the current theorems and computationally simpler.

### 6.4 Open Problems

1. **Fully local SCC pressure**: Define and analyze the variant where SCCs are computed within the induced subgraph on the out-ball.

2. **Weighted variants**: Weight SCC contributions by their size, giving the "excess recurrent dimension" ∑(|C| - 1).

3. **Predictive power**: Test whether directed pressure features outperform undirected features for predicting theorem difficulty in real mathematical libraries.

4. **Stabilization**: Characterize when dirPressure(G, v, r) stabilizes as r grows.

5. **Spectral connections**: Relate directed pressure to spectral properties of the graph Laplacian or transition matrix.

---

## 7. Future Work

The most promising extensions are:

- **Directed filtration compatibility**: Connect directed pressure to the semantic graph filtration framework, showing that directed pressure is monotone along well-founded filtrations.

- **Recurrent frontier**: Define the set of vertices that become recurrent at radius r but were not recurrent at radius r-1. This "frontier" captures the boundary of feedback propagation.

- **Algorithmic theorem recommendation**: Use directed pressure features as input to machine learning models for predicting which theorems are likely to be relevant for a given proof goal.

---

## References

1. R. E. Tarjan, "Depth-first search and linear graph algorithms," *SIAM Journal on Computing*, 1(2):146–160, 1972.

2. T. H. Cormen, C. E. Leiserson, R. L. Rivest, and C. Stein, *Introduction to Algorithms*, MIT Press, 4th edition, 2022. Chapter 20: Elementary Graph Algorithms.

3. The Mathlib Community, "Mathlib: the Lean 4 mathematical library," https://github.com/leanprover-community/mathlib4, 2024.
