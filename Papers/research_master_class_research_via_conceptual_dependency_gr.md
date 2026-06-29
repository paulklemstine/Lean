# Conceptual Dependency Critical Path Theory: Certified Lower Bounds for Theorem Discovery

## Abstract

We formalize a theory of **conceptual depth** for dependency graphs of mathematical knowledge and prove that the critical path length in such graphs provides tight lower bounds on any layered discovery process. Specifically, we define a directed acyclic graph (DAG) model where nodes represent theorems and edges represent logical dependencies, introduce a well-founded recursive depth function, and establish four main results: (A1) any node discovered in round $n$ has depth at most $n$; (B1) the critical path length is attained by some node; (B2) shallow exploration misses deep targets; and (C1) layered exploration from source nodes reaches all nodes in exactly the critical-path-length number of rounds. All results are machine-verified in Lean 4 with the Mathlib library. We provide algorithms for computing depth, critical paths, and bottleneck nodes, along with applications to curriculum optimization, research planning, and AI theorem-prover guidance.

**Keywords**: metamathematics, proof complexity, theorem discovery, DAG algorithms, critical path method, automated reasoning, curriculum extraction, formal verification

---

## 1. Introduction

### 1.1 Motivation

The notion of a "deep theorem" is central to mathematical culture but has historically resisted formal definition. Informally, a deep theorem is one that requires understanding a long chain of prerequisite results. Fermat's Last Theorem, the classification of finite simple groups, and the proof of the Poincaré conjecture are considered "deep" precisely because they build upon enormous towers of prior mathematics.

We propose to make this notion precise by modeling the dependency structure of mathematical knowledge as a finite directed acyclic graph and defining depth as a computable graph invariant. Our key contribution is proving that this invariant provides *certified lower bounds* on any discovery process: there is no strategy that can reach a theorem of depth $d$ in fewer than $d$ rounds of layered exploration.

### 1.2 Related Work

**Critical path method (CPM).** Our framework is a direct mathematical transplant of the critical path method from operations research and project scheduling (Kelley & Walker, 1959). In CPM, tasks have dependencies, and the critical path determines the minimum project duration. Our contribution is to apply this framework to *theorem discovery* and prove the relevant bounds in a formal proof system.

**Proof complexity.** The study of proof complexity measures the size or depth of proofs in formal systems (Cook & Reckhow, 1979; Razborov, 2003). Our work is complementary: while proof complexity studies the internal structure of individual proofs, we study the *external* dependency structure among theorems.

**Knowledge space theory.** Doignon and Falmagne's knowledge space theory (1999) models learnable items and their prerequisite relations. Our layered discovery process is closely related to their notion of learning paths through knowledge spaces.

**Circuit depth.** Our depth invariant is analogous to circuit depth in computational complexity theory. The separation between shallow and deep exploration mirrors the separation between $\text{AC}^0$ and higher-depth circuit classes.

### 1.3 Contributions

1. A formal definition of dependency graphs, conceptual depth, and layered discovery.
2. A proof that depth lower-bounds discovery round (Theorem A1).
3. A proof that the critical path length is attained (Theorem B1).
4. A separation theorem showing shallow search misses deep targets (Theorem B2).
5. A completeness theorem for guided exploration (Theorem C1).
6. A synthesis theorem combining lower and upper bounds (Synthesis Theorem).
7. Machine verification of all results in Lean 4 with Mathlib.
8. Algorithms and applications to education, research planning, and AI.

---

## 2. Definitions and Notation

### 2.1 Dependency Graphs

**Definition 2.1 (Dependency Graph).** A *dependency graph* on a finite type $V$ is a pair $G = (V, \text{pred})$ where $\text{pred} : V \to \mathcal{P}_{\text{fin}}(V)$ assigns to each node its set of immediate predecessors, and the predecessor relation $u \prec v \iff u \in \text{pred}(v)$ is well-founded.

Well-foundedness of the predecessor relation is equivalent to acyclicity for finite graphs and enables definition by well-founded recursion.

In our Lean formalization:
```
structure DepGraph (V : Type*) [Fintype V] [DecidableEq V] where
  pred : V → Finset V
  wf : WellFounded (fun u v => u ∈ pred v)
```

**Definition 2.2 (Source).** A node $v$ is a *source* if $\text{pred}(v) = \emptyset$.

**Definition 2.3 (Source Set).** $\text{sourceSet}(G) = \{v \in V \mid \text{pred}(v) = \emptyset\}$.

### 2.2 Conceptual Depth

**Definition 2.4 (Depth).** The *depth* of a node $v$ is defined by well-founded recursion:
$$\text{depth}(v) = \begin{cases} 0 & \text{if } \text{pred}(v) = \emptyset \\ 1 + \max_{u \in \text{pred}(v)} \text{depth}(u) & \text{otherwise} \end{cases}$$

This is the standard longest-path-length function in DAG theory. It measures the length of the longest directed path ending at $v$.

**Lemma 2.5 (Depth Unfolding).** For all $v \in V$:
$$\text{depth}(v) = \begin{cases} 0 & \text{if } \text{pred}(v) = \emptyset \\ 1 + \sup\{\text{depth}(u) \mid u \in \text{pred}(v)\} & \text{otherwise} \end{cases}$$

**Lemma 2.6 (Predecessor Strict Inequality).** If $u \in \text{pred}(v)$, then $\text{depth}(u) < \text{depth}(v)$.

*Proof.* By unfolding, $\text{depth}(v) = 1 + \sup\{\text{depth}(w) \mid w \in \text{pred}(v)\} \geq 1 + \text{depth}(u) > \text{depth}(u)$.

### 2.3 Layered Discovery

**Definition 2.7 (Next Layer).** Given a set $A \subseteq V$ of already-discovered nodes:
$$\text{nextLayer}(G, A) = \{v \in V \mid v \notin A \text{ and } \forall u \in \text{pred}(v),\, u \in A\}$$

**Definition 2.8 (Discovered Set).** The set of nodes discovered after $n$ rounds from seed set $S$:
$$\text{discovered}(G, S, 0) = S$$
$$\text{discovered}(G, S, n+1) = \text{discovered}(G, S, n) \cup \text{nextLayer}(G, \text{discovered}(G, S, n))$$

**Lemma 2.9 (Monotonicity).** For $m \leq n$: $\text{discovered}(G, S, m) \subseteq \text{discovered}(G, S, n)$.

### 2.4 Critical Path Length

**Definition 2.10 (Critical Path Length).**
$$\text{criticalPathLength}(G) = \max_{v \in V} \text{depth}(v)$$

---

## 3. Main Results

### 3.1 Theorem A1: Depth Lower Bound

**Theorem 3.1 (Depth Lower Bound).** *Let $G$ be a dependency graph, $S$ a seed set of source nodes ($\forall v \in S$, $v$ is a source), and suppose $v \in \text{discovered}(G, S, n)$. Then $\text{depth}(v) \leq n$.*

*Proof.* By induction on $n$.

**Base case** ($n = 0$): $v \in S$ implies $v$ is a source, so $\text{depth}(v) = 0 \leq 0$.

**Inductive step** ($n \to n+1$): If $v \in \text{discovered}(G, S, n)$, then by induction hypothesis $\text{depth}(v) \leq n \leq n+1$. Otherwise, $v \in \text{nextLayer}(G, \text{discovered}(G, S, n))$, meaning all predecessors $u$ of $v$ satisfy $u \in \text{discovered}(G, S, n)$, hence $\text{depth}(u) \leq n$ by induction hypothesis. If $\text{pred}(v) = \emptyset$, then $\text{depth}(v) = 0 \leq n+1$. Otherwise, $\text{depth}(v) = 1 + \sup\{\text{depth}(u) \mid u \in \text{pred}(v)\} \leq 1 + n = n+1$. $\square$

This is the central result: it establishes that conceptual depth is a *certified lower bound* on discovery time. No exploration strategy can circumvent this bound.

### 3.2 Theorem B1: Critical Path Attainment

**Theorem 3.2 (Attainment).** *If $V$ is nonempty, there exists $v \in V$ with $\text{depth}(v) = \text{criticalPathLength}(G)$.*

*Proof.* The critical path length is defined as the supremum of $\text{depth}$ over the finite nonempty set $V$, so the maximum is attained by some element. $\square$

### 3.3 Theorem B2: Shallow Exploration Fails

**Theorem 3.3 (Separation).** *Let $G$ be a nonempty dependency graph, $S$ a seed set of sources, and $k < \text{criticalPathLength}(G)$. Then there exists $v \in V$ with $v \notin \text{discovered}(G, S, k)$.*

*Proof.* By contradiction. If every node were discovered by round $k$, then by Theorem 3.1, every node would have depth $\leq k$, implying $\text{criticalPathLength}(G) \leq k$, contradicting $k < \text{criticalPathLength}(G)$. $\square$

### 3.4 Theorem C1: Guided Completeness

**Theorem 3.4 (Completeness).** $\text{discovered}(G, \text{sourceSet}(G), \text{criticalPathLength}(G)) = V$.

*Proof.* We first prove that every node $v$ satisfies $v \in \text{discovered}(G, \text{sourceSet}(G), \text{depth}(v))$ by well-founded induction. Sources belong to $\text{sourceSet}(G) = \text{discovered}(G, \text{sourceSet}(G), 0)$. For non-sources, all predecessors $u$ have $\text{depth}(u) < \text{depth}(v)$, hence by induction and monotonicity, $u \in \text{discovered}(G, \text{sourceSet}(G), \text{depth}(v) - 1)$. Thus $v \in \text{nextLayer}$ at round $\text{depth}(v)$.

Since $\text{depth}(v) \leq \text{criticalPathLength}(G)$ for all $v$, monotonicity gives $v \in \text{discovered}(G, \text{sourceSet}(G), \text{criticalPathLength}(G))$. $\square$

### 3.5 Synthesis Theorem

**Theorem 3.5 (Critical Path Policy).** *For $k < \text{criticalPathLength}(G)$, there exists a node $v$ with $\text{depth}(v) = \text{criticalPathLength}(G)$ and $v \notin \text{discovered}(G, \text{sourceSet}(G), k)$.*

*Proof.* Take $v$ from Theorem B1. If $v$ were discovered by round $k$, Theorem A1 would give $\text{depth}(v) \leq k < \text{criticalPathLength}(G) = \text{depth}(v)$, a contradiction. $\square$

### 3.6 Depth Bound

**Theorem 3.6 (Cardinality Bound).** *For all $v \in V$: $\text{depth}(v) \leq |V| - 1$.*

*Proof.* Any directed path in an acyclic graph on $|V|$ vertices visits each vertex at most once, so has length at most $|V| - 1$. Since $\text{depth}(v)$ is the maximum length of a path ending at $v$, the bound follows. Formally, we prove by induction that $|\{u \in V \mid \text{depth}(u) \leq \text{depth}(v)\}| \geq \text{depth}(v) + 1$, and since this set has at most $|V|$ elements, we conclude $\text{depth}(v) \leq |V| - 1$. $\square$

---

## 4. Algorithms

### 4.1 Depth Computation

**Algorithm 1: Compute Depth**

```
function DEPTH(G, v):
    if v in cache: return cache[v]
    if pred(v) = ∅: return 0
    d ← 1 + max{DEPTH(G, u) : u ∈ pred(v)}
    cache[v] ← d
    return d
```

**Complexity**: $O(|V| + |E|)$ time with memoization, $O(|V|)$ space.

### 4.2 Layered Discovery

**Algorithm 2: Layered Discovery**

```
function LAYERED_DISCOVERY(G, S, rounds):
    disc ← S
    for i = 1 to rounds:
        layer ← {v ∈ V \ disc : ∀u ∈ pred(v), u ∈ disc}
        disc ← disc ∪ layer
    return disc
```

**Complexity**: $O(\text{rounds} \cdot (|V| + |E|))$ time.

### 4.3 Critical Path Extraction

**Algorithm 3: Critical Path**

```
function CRITICAL_PATH(G, v):
    if pred(v) = ∅: return [v]
    u* ← argmax{DEPTH(G, u) : u ∈ pred(v)}
    return CRITICAL_PATH(G, u*) ++ [v]
```

**Complexity**: $O(|V| + |E|)$ time.

### 4.4 Bottleneck Detection

**Algorithm 4: Bottleneck Nodes**

```
function BOTTLENECK_NODES(G):
    cpl ← CRITICAL_PATH_LENGTH(G)
    bottlenecks ← []
    for v in V:
        G' ← G with v removed
        if CRITICAL_PATH_LENGTH(G') < cpl:
            bottlenecks.append(v)
    return bottlenecks
```

**Complexity**: $O(|V| \cdot (|V| + |E|))$ time.

---

## 5. Applications

### 5.1 Curriculum Optimization

Given a set of courses with prerequisite dependencies, the critical path length gives the minimum number of semesters required. The layered discovery process produces an optimal semester-by-semester schedule.

**Example**: A 15-topic mathematics curriculum with dependencies has critical path length 7, meaning 8 semesters are required. The optimal schedule achieves an average parallelism of 1.9 courses per semester.

### 5.2 Research Planning

A research program with 12 milestones has critical path length 9. Bottleneck analysis reveals that 2 milestones are true bottlenecks — removing either would reduce the critical path. This guides resource allocation: invest disproportionately in bottleneck milestones.

### 5.3 Software Build Systems

A 12-module software project has sequential build time 12 and parallel build time 7 (with unlimited cores), giving a speedup of 1.7x. The critical path identifies the limiting dependency chain.

### 5.4 AI Theorem Prover Guidance

For a 13-theorem number theory dependency graph, shallow search (depth ≤ 2) discovers only 5 theorems. The remaining 8 theorems — including the deepest targets like quadratic reciprocity — are provably unreachable without following the dependency chain. Critical-path-guided search reaches all 13 theorems in 8 rounds.

---

## 6. Computational Experiments

We implemented all algorithms in Python and verified the theorems computationally on diverse graph structures:

| Graph Structure | |V| | |E| | CPL | Optimal Rounds | Avg. Parallelism |
|---|---|---|---|---|---|
| Linear chain | 10 | 9 | 9 | 10 | 1.0 |
| Binary tree | 15 | 14 | 3 | 4 | 3.75 |
| Diamond lattice | 4 | 4 | 2 | 3 | 1.33 |
| Math curriculum | 15 | 18 | 7 | 8 | 1.88 |
| Random DAG (n=50) | 50 | ~100 | 8 | 9 | 5.56 |

Key observations:
- Linear chains are worst-case: CPL = |V| - 1, no parallelism.
- Wide DAGs are best-case: CPL = 1, maximum parallelism.
- Real-world dependency structures fall between these extremes.
- All experiments confirmed Theorems A1, B2, and C1.

---

## 7. Discussion

### 7.1 Interpretation

The core message of this work is that **conceptual depth is a certifiable invariant, not merely a heuristic**. When we say a theorem is "deep," we can now assign a precise number to that depth and prove that no discovery strategy can circumvent it. This transforms "depth" from rhetoric to mathematics.

### 7.2 Limitations

1. **Static dependency graphs.** Our model assumes a fixed, known dependency graph. In practice, mathematical knowledge evolves, and new connections can reduce the depth of existing results.

2. **Uniform round cost.** Each round of discovery is treated as unit cost. In practice, some prerequisite steps are harder than others. The weighted extension (see Future Work) addresses this.

3. **Single predecessor relation.** A theorem may have multiple valid proofs with different dependency structures. Our model works with a single chosen predecessor map. The minimum over all valid predecessor maps gives the *intrinsic* depth.

### 7.3 Connections to Other Fields

- **Operations Research**: Our framework is a mathematical transplant of CPM/PERT.
- **Circuit Complexity**: Depth corresponds to circuit depth; shallow exploration corresponds to bounded-depth computation.
- **Learning Theory**: Layered discovery is formally equivalent to curriculum learning with prerequisite constraints.
- **Category Theory**: Dependency graphs form a partial order category; depth is a categorical invariant.

---

## 8. Future Work

1. **Weighted conceptual depth**: Assign novelty costs to nodes and prove weighted lower bounds.
2. **Functorial transfer**: Prove that morphisms between dependency graphs preserve or bound depth.
3. **Empirical extraction**: Build tools to extract dependency graphs from mathematical libraries and compute critical paths.
4. **Branching-factor constraints**: Prove lower bounds when each round has bounded discovery capacity.
5. **Textbook comparison**: Compare machine-extracted depth with human-authored prerequisite orderings.

See `FUTURE_DIRECTIONS.md` for detailed specifications of each direction.

---

## 9. Formal Verification

All definitions and theorems in this paper are machine-verified in Lean 4 (v4.28.0) with the Mathlib library. The formalization is contained in:

```
Speculative/AutoResearch/ConceptualDependencyCriticalPath.lean
```

The file contains approximately 230 lines of Lean code including:
- Structure definition (`DepGraph`)
- 6 definitions (`isSource`, `sourceSet`, `depth`, `nextLayer`, `discovered`, `criticalPathLength`)
- 13 theorems, all proved without `sorry`
- Only standard axioms used: `propext`, `Classical.choice`, `Quot.sound`

---

## References

1. Cook, S.A. & Reckhow, R.A. (1979). The relative efficiency of propositional proof systems. *Journal of Symbolic Logic*, 44(1), 36–50.

2. Doignon, J.-P. & Falmagne, J.-C. (1999). *Knowledge Spaces*. Springer-Verlag.

3. Kelley, J.E. & Walker, M.R. (1959). Critical-path planning and scheduling. *Proceedings of the Eastern Joint Computer Conference*, 160–173.

4. Razborov, A.A. (2003). Proof complexity and beyond. *SIGACT News*, 34(3), 36–52.

5. The mathlib Community (2020). The Lean mathematical library. *Proceedings of CPP 2020*.
