# A Certified Locality Theorem for Incremental Recomputation on Dependency DAGs

## Abstract

We formalize and prove a locality theorem for incremental recomputation on finite directed acyclic graphs (DAGs): when a new node is inserted into a dependency graph and the predecessor function is modified only within the forward reachability cone of that node, the recursively defined *level* function — measuring the longest incoming path length — is provably unchanged on the complement of the cone. The result is established by well-founded induction on the acyclic predecessor relation and is mechanically verified. We derive a support theorem showing the set of affected vertices is contained in the forward cone, prove monotonicity properties of the level function, and provide executable algorithms demonstrating that incremental recomputation restricted to the forward cone is both correct and significantly more efficient than global recomputation.

**Keywords:** directed acyclic graphs, incremental recomputation, dependency analysis, well-founded induction, locality principle, build systems, formal verification

## 1. Introduction

### 1.1 Motivation

Dependency-structured computation appears in software build systems [1], theorem provers, package managers, educational prerequisite systems, and knowledge ontologies. A common pattern across these domains is:

1. Entities are organized in a directed acyclic graph (DAG) where edges represent prerequisite relationships.
2. Each entity has a recursively computed attribute (e.g., compilation stage, prerequisite depth, skill tier).
3. The system is modified by inserting new entities with associated dependency edges.

The fundamental question is: **which attributes must be recomputed after a local modification?**

Engineering practice overwhelmingly adopts the heuristic that only "downstream" entities need recomputation. Build systems like `make`, `cargo`, and Bazel implement this principle, as do dependency resolution algorithms in package managers. However, a rigorous mathematical proof that this heuristic is correct — that skipping recomputation outside the forward cone yields exactly the same result as full recomputation — has not previously been established in a mechanically verified form.

### 1.2 Contributions

We provide:

1. **A formal model** of dependency DAGs as predecessor functions on finite types, with acyclicity encoded as well-foundedness of the predecessor relation.

2. **A recursive level function** defined by well-founded recursion, computing the longest incoming path length for each vertex.

3. **The main locality theorem** (`level_eq_of_not_reaches`): for any vertex not reachable from the inserted node, the level is identical before and after the update.

4. **A support theorem** (`recomputation_support_subset_forward_cone`): the set of vertices with changed levels is a subset of the forward reachability cone.

5. **Monotonicity properties**: the level function is strictly monotone along edges and along non-trivial reachability paths.

6. **Executable algorithms** for computing levels, forward cones, and performing incremental updates, with computational experiments validating the theoretical results.

### 1.3 Related Work

**Incremental computation.** The theory of self-adjusting computation [2] and change propagation [3] addresses incremental recomputation in general settings. Our result is more specialized (finite DAGs with a specific recursive function) but correspondingly more precise and fully verified.

**Build systems.** Mokhov et al. [4] survey the design space of build systems and identify key properties including minimality (only rebuild what's necessary) and correctness (the result matches full recomputation). Our theorem provides a formal proof of the correctness of minimal rebuilds for level-like recursive functions.

**Graph algorithms.** Topological sorting and longest-path computation in DAGs are classical algorithms [5]. Our contribution is not algorithmic novelty but the formal verification of a correctness property that connects these algorithms to the locality principle.

## 2. Definitions and Notation

### 2.1 Predecessor Functions and DAGs

Let $V$ be a finite type with decidable equality. A **predecessor function** is a mapping $\text{pred} : V \to \text{Finset}(V)$, where $\text{pred}(v)$ gives the set of immediate predecessors (dependencies) of $v$.

The **predecessor relation** is defined by:
$$u \prec v \iff u \in \text{pred}(v)$$

**Definition (DAGAcyclic).** A predecessor function $\text{pred}$ is *acyclic* if the relation $\prec$ is well-founded:
$$\text{DAGAcyclic}(\text{pred}) := \text{WellFounded}(\prec)$$

Well-foundedness ensures there are no infinite descending chains $\cdots \prec v_2 \prec v_1 \prec v_0$, which is equivalent to the absence of directed cycles in the graph.

### 2.2 The Level Function

**Definition (level).** Given an acyclic predecessor function $\text{pred}$ with well-foundedness witness $h_{\text{acyc}}$, the level function $\ell : V \to \mathbb{N}$ is defined by well-founded recursion:

$$\ell(v) = \begin{cases} 0 & \text{if } \text{pred}(v) = \emptyset \\ \max_{u \in \text{pred}(v)} (\ell(u) + 1) & \text{otherwise} \end{cases}$$

In the formalization, this is implemented using `WellFounded.fix` on the acyclicity witness, with `Finset.sup'` for the maximum over a nonempty finite set.

**Lemma (Unfolding).** The level satisfies:
$$\ell(v) = \begin{cases} 0 & \text{if } \text{pred}(v) = \emptyset \\ \sup' \{\ \ell(u) + 1 \mid u \in \text{pred}(v) \ \} & \text{otherwise} \end{cases}$$

This is proved by `WellFounded.fix_eq`.

### 2.3 Reachability

**Definition (Reaches).** The reachability relation $\text{Reaches}(\text{pred}, u, v)$ is defined inductively:

- **refl:** $\text{Reaches}(\text{pred}, v, v)$ for all $v$
- **step:** If $\text{Reaches}(\text{pred}, u, w)$ and $w \in \text{pred}(v)$, then $\text{Reaches}(\text{pred}, u, v)$

Intuitively, $\text{Reaches}(\text{pred}, u, v)$ means there is a directed path from $u$ to $v$, following edges from predecessors to dependents.

**Lemma (Transitivity).** If $\text{Reaches}(\text{pred}, u, v)$ and $\text{Reaches}(\text{pred}, v, w)$, then $\text{Reaches}(\text{pred}, u, w)$. Proved by induction on the second reachability derivation.

### 2.4 The Forward Cone

**Definition.** The *forward cone* of a vertex $n$ in graph $\text{pred}$ is:
$$\text{Cone}(\text{pred}, n) = \{ v \in V \mid \text{Reaches}(\text{pred}, n, v) \}$$

This is the set of all vertices reachable from $n$, including $n$ itself.

## 3. Main Results

### 3.1 Locality Lemma

**Theorem (level_eq_of_pred_eq_and_levels_eq).** *Let $\text{pred}_{\text{old}}$ and $\text{pred}_{\text{new}}$ be acyclic predecessor functions. If for a vertex $v$:*
1. *$\text{pred}_{\text{old}}(v) = \text{pred}_{\text{new}}(v)$, and*
2. *$\ell_{\text{old}}(u) = \ell_{\text{new}}(u)$ for all $u \in \text{pred}_{\text{old}}(v)$,*

*then $\ell_{\text{old}}(v) = \ell_{\text{new}}(v)$.*

**Proof sketch.** Unfold both sides using the level recurrence. Since the predecessor sets are equal, both sides evaluate to the same case (empty or nonempty). In the nonempty case, the supremum ranges over the same set, and each term $\ell(u) + 1$ agrees by hypothesis (2). $\square$

### 3.2 Main Locality Theorem

**Theorem (level_eq_of_not_reaches).** *Let $\text{pred}_{\text{old}}$ and $\text{pred}_{\text{new}}$ be acyclic predecessor functions, and let $n$ be a designated vertex. Suppose:*

$$\forall v,\ \neg\text{Reaches}(\text{pred}_{\text{new}}, n, v) \implies \text{pred}_{\text{old}}(v) = \text{pred}_{\text{new}}(v) \qquad (\star)$$

*Then for any vertex $v$ with $\neg\text{Reaches}(\text{pred}_{\text{new}}, n, v)$:*
$$\ell_{\text{old}}(v) = \ell_{\text{new}}(v)$$

**Proof.** By well-founded induction on $v$ using the acyclicity of $\text{pred}_{\text{new}}$.

**Base case:** If $v$ has no predecessors in $\text{pred}_{\text{new}}$, then by $(\star)$ it has no predecessors in $\text{pred}_{\text{old}}$ either, so both levels are 0.

**Inductive step:** Assume the result holds for all $u \in \text{pred}_{\text{new}}(v)$.

Since $\neg\text{Reaches}(\text{pred}_{\text{new}}, n, v)$, condition $(\star)$ gives $\text{pred}_{\text{old}}(v) = \text{pred}_{\text{new}}(v)$.

For any $u \in \text{pred}_{\text{old}}(v) = \text{pred}_{\text{new}}(v)$, we claim $\neg\text{Reaches}(\text{pred}_{\text{new}}, n, u)$. Indeed, if $\text{Reaches}(\text{pred}_{\text{new}}, n, u)$ held, then since $u \in \text{pred}_{\text{new}}(v)$, the step rule would give $\text{Reaches}(\text{pred}_{\text{new}}, n, v)$, contradicting our hypothesis.

By the inductive hypothesis, $\ell_{\text{old}}(u) = \ell_{\text{new}}(u)$ for all predecessors $u$. By the Locality Lemma (Theorem 3.1), $\ell_{\text{old}}(v) = \ell_{\text{new}}(v)$. $\square$

### 3.3 Support Theorem

**Theorem (recomputation_support_subset_forward_cone).** *Under the same hypotheses:*
$$\{ v \mid \ell_{\text{old}}(v) \neq \ell_{\text{new}}(v) \} \subseteq \text{Cone}(\text{pred}_{\text{new}}, n)$$

**Proof.** Immediate by contrapositive of Theorem 3.2: if $v \notin \text{Cone}(\text{pred}_{\text{new}}, n)$, then $\ell_{\text{old}}(v) = \ell_{\text{new}}(v)$, so $v$ is not in the set of changed vertices. $\square$

### 3.4 Complement Characterization

**Theorem (unchanged_on_complement_of_forward_cone).** *The complement of the forward cone is a safe region: for every vertex in $\text{Cone}(\text{pred}_{\text{new}}, n)^c$, levels are provably identical before and after the update.*

This is a direct reformulation of the main theorem, stated in terms of set complements for clarity.

### 3.5 Monotonicity Properties

**Theorem (level_ge_succ_of_pred).** *If $u \in \text{pred}(v)$, then $\ell(v) \geq \ell(u) + 1$.*

**Proof.** By unfolding the level definition: since $u$ is in the nonempty set $\text{pred}(v)$, the supremum over this set is at least $\ell(u) + 1$. $\square$

**Theorem (level_strict_mono_of_pred).** *If $u \in \text{pred}(v)$, then $\ell(u) < \ell(v)$.*

**Proof.** Immediate from the preceding theorem. $\square$

## 4. Algorithms

### 4.1 Level Computation

**Algorithm 1: ComputeLevels**

```
Input: DAG G = (V, pred)
Output: level[v] for all v ∈ V

1. order ← TopologicalSort(V, pred)
2. for v in order:
3.     if pred(v) = ∅:
4.         level[v] ← 0
5.     else:
6.         level[v] ← max{level[u] + 1 : u ∈ pred(v)}
7. return level
```

**Complexity:** $O(|V| + |E|)$ time, $O(|V|)$ space.

### 4.2 Forward Cone Computation

**Algorithm 2: ForwardCone**

```
Input: DAG G = (V, pred, succ), source vertex n
Output: Cone(G, n)

1. visited ← {n}
2. queue ← [n]
3. while queue ≠ []:
4.     v ← dequeue(queue)
5.     for w in succ(v):
6.         if w ∉ visited:
7.             visited ← visited ∪ {w}
8.             enqueue(queue, w)
9. return visited
```

**Complexity:** $O(|V| + |E|)$ time, $O(|V|)$ space.

### 4.3 Incremental Recomputation

**Algorithm 3: IncrementalUpdate**

```
Input: old DAG G, new DAG G', new vertex n, old levels
Output: new levels for G'

1. cone ← ForwardCone(G', n)
2. for v ∈ V' \ cone:
3.     newlevel[v] ← oldlevel[v]      // Guaranteed correct by Theorem 3.2
4. order ← TopologicalSort(cone, pred'|_cone)
5. for v in order:
6.     if pred'(v) = ∅:
7.         newlevel[v] ← 0
8.     else:
9.         newlevel[v] ← max{newlevel[u] + 1 : u ∈ pred'(v)}
10. return newlevel
```

**Complexity:** $O(|V| + |E_{\text{cone}}|)$ where $|E_{\text{cone}}|$ is the number of edges incident to the cone. The key saving is that when $|\text{cone}| \ll |V|$, this is dramatically faster than global recomputation.

**Correctness:** The correctness of step 3 (copying old levels for non-cone vertices) is exactly the content of Theorem 3.2. Steps 4–9 compute levels within the cone using the standard algorithm with correct boundary conditions.

## 5. Computational Experiments

### 5.1 Concrete Examples

**Example 1: Linear chain.** $A \to B \to C$ with insertion of $X$ depending on $B$. The forward cone of $X$ is $\{X\}$. Levels of $A$, $B$, $C$ are unchanged (0, 1, 2). Level of $X$ is 2.

**Example 2: Diamond DAG.** $A \to B$, $A \to C$, $B \to D$, $C \to D$. Inserting $X$ between $B$ and $D$ ($B \to X \to D$) gives cone $\{X, D\}$. Levels of $A$, $B$, $C$ unchanged. Level of $D$ changes from 2 to 3.

**Example 3: Large DAG (10 nodes, 12 edges).** Inserting a node between $C$ and $E$ gives a forward cone of size 4. Seven of 11 nodes (64%) have unchanged levels, demonstrating significant savings.

### 5.2 Incremental vs. Global Recomputation

| Metric | Global | Incremental |
|--------|--------|-------------|
| Nodes processed | All $|V|$ | $|\text{cone}|$ |
| Correctness | By definition | Guaranteed by Theorem 3.2 |
| Time complexity | $O(|V| + |E|)$ | $O(|V| + |E_{\text{cone}}|)$ |

In all experiments, incremental recomputation produced results identical to global recomputation, as guaranteed by the theorem.

### 5.3 Scaling Behavior

Monte Carlo experiments with random DAGs of sizes 10 to 500 nodes show that the forward cone size (as a fraction of total nodes) decreases as the graph grows, for fixed edge density. This means incremental savings become more significant for larger graphs.

## 6. Applications

### 6.1 Incremental Build Systems

A software project with modules `utils → lexer → parser → typechecker → codegen → linker` and additional edges. Adding a `validator` module between `parser` and `typechecker`:
- Forward cone: `{validator, typechecker, codegen, linker}` (4 modules)
- Unaffected: `{utils, lexer, parser, optimizer}` (4 modules)
- 50% of modules skip recompilation

### 6.2 Curriculum Management

A mathematics curriculum DAG with 10 courses. Adding "Numerical Methods" between "Calculus II" and "PDE":
- Forward cone: `{Numerical Methods, PDE}` (2 courses)
- Unaffected: 9 courses (82%)
- Semester assignments for unaffected courses are provably stable

### 6.3 Package Dependency Management

An ecosystem of 9 packages. Adding `libauth` between `libssl` and `curl`:
- Forward cone: `{libauth, curl, git, npm}` (4 packages)
- Unaffected: `{libc, libssl, pip, python, ssh, zlib}` (6 packages)
- 60% of packages skip metadata recomputation

## 7. Discussion

### 7.1 Strength of the Result

The locality theorem is stronger than it may initially appear. It does not merely say that levels "usually" stay the same outside the cone. It provides an absolute guarantee: under the stated conditions, levels are *provably identical*. This is the difference between a heuristic and a theorem.

The condition $(\star)$ — that predecessor functions agree outside the forward cone — is natural and minimally restrictive. It captures exactly the notion of a "localized update": the graph changes only at the new node and its immediate neighbors.

### 7.2 Generality

While we state results for the specific level function (longest incoming path length), the proof technique generalizes to any recursively defined function on a DAG that depends only on the values at predecessors. The key structural property used is:

> If the function's value at $v$ depends only on the function's values at $\text{pred}(v)$, and both the predecessor set and predecessor values are unchanged, then the value at $v$ is unchanged.

This applies to minimum path lengths, aggregated costs, weighted depths, and many other quantities.

### 7.3 Limitations

1. The theorem assumes the predecessor function itself encodes the update localization. If the update modifies predecessor sets far from the inserted node, the forward cone may be large.

2. The result characterizes *which* vertices can change, not *by how much*. A tighter bound on the magnitude of level changes within the cone would be a natural extension.

3. The formalization uses well-founded recursion, which is inherently noncomputable in constructive settings. Extracting efficient executable code requires separate development.

## 8. Future Work

See `FUTURE_DIRECTIONS.md` for detailed next steps. Key directions include:

1. Generalizing from $\mathbb{N}$-valued levels to semiring-valued dependency propagation.
2. Formalizing a certified incremental fixed-point theorem for monotone dataflow frameworks.
3. Extracting an executable recomputation kernel with verified complexity bounds.
4. Connecting to causal semantics via Alexandrov topology.
5. Building a theorem-dependency observer interface for proof-carrying updates.

## References

[1] S. I. Feldman. Make — A program for maintaining computer programs. *Software: Practice and Experience*, 9(4):255–265, 1979.

[2] U. A. Acar, G. E. Blelloch, R. Harper. Adaptive functional programming. *ACM Transactions on Programming Languages and Systems*, 28(6):990–1034, 2006.

[3] Y. A. Liu, S. D. Stoller, T. Teitelbaum. Static caching for incremental computation. *ACM Transactions on Programming Languages and Systems*, 20(3):546–585, 1998.

[4] A. Mokhov, N. Mitchell, S. Peyton Jones. Build systems à la carte. *Proceedings of the ACM on Programming Languages*, 2(ICFP):1–29, 2018.

[5] T. H. Cormen, C. E. Leiserson, R. L. Rivest, C. Stein. *Introduction to Algorithms*. MIT Press, 4th edition, 2022.
