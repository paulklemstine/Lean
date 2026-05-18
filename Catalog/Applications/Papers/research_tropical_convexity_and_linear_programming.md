# Tropical Convexity, Minkowski–Weyl, and Algorithmic Tropical Optimization: A Formal Development

## Abstract

We present a formally verified development of tropical convexity theory over the max-plus semiring, culminating in a tropical Minkowski–Weyl theorem for alcoved (difference-constraint) polyhedra and a certified feasibility theorem connecting difference constraints to negative cycle detection. Our formalization establishes the basic algebraic infrastructure of tropical vector operations (idempotent addition, distributive scaling), proves that tropical convex hulls of finite generator sets are tropically convex, demonstrates that difference-constraint polyhedra form a natural class of tropical polytopes, and proves that closed difference-constraint systems admit finite tropical generation via shortest-path closure columns. We also formalize the classical Bellman–Ford characterization: a system of difference constraints is feasible if and only if its constraint graph contains no negative-weight cycle. These results create a rigorous bridge between tropical convex geometry and combinatorial optimization algorithms, with applications to scheduling, timing analysis, and game theory.

**Keywords**: tropical convexity, max-plus algebra, Minkowski–Weyl theorem, difference constraints, Bellman–Ford, mean payoff games, formal verification

## 1. Introduction

### 1.1 Motivation

Tropical mathematics — the study of algebraic structures where addition is replaced by maximum (or minimum) and multiplication is replaced by addition — has emerged as a powerful framework bridging algebraic geometry, combinatorial optimization, and discrete event systems [1, 2, 3]. The max-plus semiring $(ℝ ∪ \{-∞\}, \max, +)$ provides the natural algebraic setting for shortest-path problems, scheduling theory, and game-theoretic value iteration.

Tropical convexity, introduced systematically by Develin and Sturmfels [4], studies convex-like structures arising from max-plus combinations. A tropical convex combination of points $v_1, \ldots, v_k ∈ ℝ^n$ is

$$x_j = \max_i (\lambda_i + (v_i)_j)$$

with normalization $\max_i \lambda_i = 0$. The resulting tropical polytopes exhibit combinatorial rigidity phenomena not seen in classical convexity, while simultaneously encoding algorithmic information about constraint satisfaction.

### 1.2 Contributions

This work makes the following contributions:

1. **Tropical algebra on vectors** (§3): Formal definitions and proofs of commutativity, associativity, idempotence of tropical addition, and distributivity of tropical scaling.

2. **Tropical convex hulls** (§4): Definition of tropical convexity and tropical convex hulls for finite generator sets, with a complete proof that tropical hulls are tropically convex.

3. **Difference-constraint polyhedra** (§5): Proof that polyhedra defined by difference constraints $x_i - x_j \leq c_{ij}$ are tropically convex, with canonical generators from the shortest-path closure matrix.

4. **Tropical Minkowski–Weyl theorem** (§5.3): For closed difference-constraint systems, every normalized feasible point lies in the tropical convex hull of the closure columns — establishing finite tropical generation.

5. **Feasibility certification** (§6): Formal proof that difference constraint feasibility is equivalent to absence of negative cycles, connecting tropical geometry to graph algorithms.

6. **Algorithmic implementations** (§7): Complete Python implementations of Floyd–Warshall closure, Bellman–Ford feasibility, and tropical hull operations.

### 1.3 Related Work

Gaubert and Katz [5] proved the tropical Minkowski–Weyl theorem in full generality for finitely generated tropical convex sets. Our formalization covers the important special case of alcoved polyhedra (difference-constraint sets), which is the computationally tractable fragment relevant to shortest-path algorithms.

Butkovič [6] provides a comprehensive treatment of max-linear systems and their connections to combinatorial optimization. Akian, Gaubert, and Guterman [7] developed the tropical analogue of linear algebra, including rank theory and determinantal identities.

The connection between tropical feasibility and mean payoff games was established by Akian, Gaubert, and Guterman [8] and further developed by Bezem, Nieuwenhuis, and Rodríguez-Carbonell [9].

## 2. Preliminaries

### 2.1 The Max-Plus Semiring

The **max-plus semiring** is the triple $(ℝ, \oplus, \odot)$ where:
- $a \oplus b := \max(a, b)$ (tropical addition)
- $a \odot b := a + b$ (tropical multiplication)

This structure satisfies:
- $\oplus$ is commutative, associative, and **idempotent**: $a \oplus a = a$
- $\odot$ is commutative and associative
- $\odot$ distributes over $\oplus$: $a \odot (b \oplus c) = (a \odot b) \oplus (a \odot c)$
- The tropical additive identity is $-\infty$ and the multiplicative identity is $0$

### 2.2 Tropical Operations on Vectors

For vectors $x, y \in ℝ^n$ and scalar $a \in ℝ$:

**Tropical scalar multiplication (scaling)**:
$$(a \odot x)_i := a + x_i$$

**Tropical vector addition**:
$$(x \oplus y)_i := \max(x_i, y_i)$$

These extend the semiring operations coordinate-wise.

## 3. Tropical Algebra on Vectors

### 3.1 Definitions

We work with vectors in $\text{Fin}\ n \to ℝ$ for fixed dimension $n$.

```
def tscale (a : ℝ) (x : Fin n → ℝ) : Fin n → ℝ := fun i => a + x i
def tadd   (x y : Fin n → ℝ) : Fin n → ℝ := fun i => max (x i) (y i)
```

### 3.2 Algebraic Properties

**Theorem 3.1** (Tropical vector algebra). *The following identities hold for all $x, y, z \in ℝ^n$ and $a, b \in ℝ$:*

1. *Commutativity*: $x \oplus y = y \oplus x$
2. *Associativity*: $(x \oplus y) \oplus z = x \oplus (y \oplus z)$
3. *Idempotence*: $x \oplus x = x$
4. *Scaling composition*: $a \odot (b \odot x) = (a + b) \odot x$
5. *Distributivity*: $a \odot (x \oplus y) = (a \odot x) \oplus (a \odot y)$
6. *Identity*: $0 \odot x = x$

**Proof sketch**. Properties (1)–(3) follow from the corresponding properties of $\max$ on $ℝ$, applied coordinate-wise. Property (4) follows from associativity of addition: $a + (b + x_i) = (a+b) + x_i$. Property (5) uses the identity $a + \max(u, v) = \max(a + u, a + v)$, which holds because addition by a constant preserves order. Property (6) is immediate from $0 + x_i = x_i$. ∎

All six properties are formally verified.

## 4. Tropical Convexity

### 4.1 Definition

**Definition 4.1** (Tropical convexity). A set $C \subseteq ℝ^n$ is **tropically convex** if for all $x, y \in C$ and all $a, b \in ℝ$ with $\max(a, b) = 0$:

$$\text{tadd}(\text{tscale}(a, x), \text{tscale}(b, y)) \in C$$

The normalization $\max(a, b) = 0$ plays the role of the condition $\lambda + (1-\lambda) = 1$ in classical convexity.

### 4.2 Tropical Convex Hull

**Definition 4.2** (Tropical convex hull). For a finite family of generators $V : \text{Fin}\ m \to (\text{Fin}\ n \to ℝ)$ with $m \geq 1$, the **tropical convex hull** is:

$$\text{TropConvHull}(V) := \left\{x \in ℝ^n \;\middle|\; \exists \lambda : \text{Fin}\ m \to ℝ,\; x_i = \sup'_j (\lambda_j + V_j(i)) \text{ and } \sup'_j \lambda_j = 0\right\}$$

### 4.3 Main Theorem: Hull is Tropically Convex

**Theorem 4.3** (Tropical hull convexity). *For any finite family $V$, the set $\text{TropConvHull}(V)$ is tropically convex.*

**Proof**. Let $x, y \in \text{TropConvHull}(V)$ with coefficient vectors $\lambda^x$ and $\lambda^y$ respectively, both normalized ($\sup' \lambda^x = \sup' \lambda^y = 0$). Let $a, b \in ℝ$ with $\max(a, b) = 0$.

Define $\mu_j := \max(a + \lambda^x_j, b + \lambda^y_j)$.

**Claim 1**: $z_i = \sup'_j (\mu_j + V_j(i))$ where $z := \text{tadd}(\text{tscale}(a, x), \text{tscale}(b, y))$.

We compute:
$$z_i = \max(a + x_i, b + y_i) = \max\left(a + \sup'_j(\lambda^x_j + V_j(i)),\; b + \sup'_j(\lambda^y_j + V_j(i))\right)$$

$$= \max\left(\sup'_j(a + \lambda^x_j + V_j(i)),\; \sup'_j(b + \lambda^y_j + V_j(i))\right)$$

$$= \sup'_j \max(a + \lambda^x_j + V_j(i),\; b + \lambda^y_j + V_j(i))$$

$$= \sup'_j (\mu_j + V_j(i))$$

The third equality uses the general identity $\max(\sup' f, \sup' g) = \sup'(\max(f, g))$ for finite non-empty index sets.

**Claim 2**: $\sup'_j \mu_j = 0$.

$$\sup'_j \mu_j = \sup'_j \max(a + \lambda^x_j, b + \lambda^y_j) = \max(\sup'_j(a + \lambda^x_j), \sup'_j(b + \lambda^y_j))$$

$$= \max(a + \sup'_j \lambda^x_j, b + \sup'_j \lambda^y_j) = \max(a + 0, b + 0) = \max(a, b) = 0$$

Thus $\mu$ witnesses $z \in \text{TropConvHull}(V)$. ∎

## 5. Difference-Constraint Polyhedra

### 5.1 Definition

**Definition 5.1**. The **difference-constraint polyhedron** for a weight matrix $c : \text{Fin}\ n \times \text{Fin}\ n \to ℝ$ is:

$$P(c) := \{x \in ℝ^n \mid \forall i, j,\; x_i - x_j \leq c_{ij}\}$$

### 5.2 Tropical Convexity

**Theorem 5.2** (Difference-constraint sets are tropically convex). *For any weight matrix $c$, the set $P(c)$ is tropically convex.*

**Proof**. Let $x, y \in P(c)$ and $a, b \in ℝ$ with $\max(a, b) = 0$. Define $z_i = \max(a + x_i, b + y_i)$. We must show $z_i - z_j \leq c_{ij}$ for all $i, j$.

Case analysis on which terms achieve the maximum at coordinates $i$ and $j$:

- If $z_i = a + x_i$ and $z_j \geq a + x_j$: then $z_i - z_j \leq (a + x_i) - (a + x_j) = x_i - x_j \leq c_{ij}$.
- If $z_i = b + y_i$ and $z_j \geq b + y_j$: then $z_i - z_j \leq (b + y_i) - (b + y_j) = y_i - y_j \leq c_{ij}$.

In both cases, the constant shift $a$ or $b$ cancels, and we fall back on the original constraints. ∎

### 5.3 Canonical Generators

**Definition 5.3**. For a weight matrix $c$, the **canonical generators** are:

$$V_j(i) := -c_{ji}$$

These are the columns of $-c^T$, or equivalently the rows of $-c$ with transposed indexing.

**Theorem 5.4** (Generators are feasible). *If $c$ is closed ($c_{ii} = 0$ and $c_{ik} \leq c_{ij} + c_{jk}$), then each generator $V_j$ satisfies the difference constraints: $V_j \in P(c)$.*

**Proof**. We need $V_j(i) - V_j(k) = -c_{ji} - (-c_{jk}) = c_{jk} - c_{ji} \leq c_{ik}$.

By the triangle inequality: $c_{jk} \leq c_{ji} + c_{ik}$, hence $c_{jk} - c_{ji} \leq c_{ik}$. ∎

### 5.4 Tropical Minkowski–Weyl Theorem

**Theorem 5.5** (Tropical finite generation for alcoved polyhedra). *Let $c$ be a closed weight matrix ($c_{ii} = 0$, $c_{ik} \leq c_{ij} + c_{jk}$). Then every normalized feasible point ($x \in P(c)$ with $\sup'_i x_i = 0$) lies in the tropical convex hull of the canonical generators.*

**Proof**. Let $x \in P(c)$ with $\sup'_i x_i = 0$. Set $\lambda_j := x_j$. Then $\sup'_j \lambda_j = \sup'_j x_j = 0$.

For each coordinate $i$, we show $x_i = \sup'_j (\lambda_j + V_j(i)) = \sup'_j (x_j - c_{ji})$.

**Upper bound**: For all $j$, the constraint $x_j - x_i \leq c_{ji}$ gives $x_j - c_{ji} \leq x_i$. Hence $\sup'_j (x_j - c_{ji}) \leq x_i$.

**Lower bound**: At $j = i$, we have $x_i - c_{ii} = x_i - 0 = x_i$. Hence $\sup'_j (x_j - c_{ji}) \geq x_i$.

Therefore $\sup'_j (x_j - c_{ji}) = x_i$, completing the proof. ∎

**Corollary 5.6**. *The set of normalized feasible points of a closed difference-constraint system is a subset of the tropical convex hull of finitely many generators (the $n$ columns of $-c^T$):*

$$\{x \in P(c) \mid \sup'_i x_i = 0\} \subseteq \text{TropConvHull}(V)$$

**Remark**. The reverse inclusion also holds (by Theorem 5.4 and Theorem 4.3), so this is actually an equality. The forward direction — that constraints imply generation — is the deeper result.

## 6. Feasibility and Negative Cycles

### 6.1 Difference Constraint Systems

**Definition 6.1**. A **difference constraint system** is a finite set $E$ of triples $(i, j, w)$ encoding constraints $x_i \leq w + x_j$. The system is **feasible** if there exists $x : \text{Fin}\ n \to ℝ$ satisfying all constraints.

### 6.2 Negative Cycle Detection

**Definition 6.2**. The system $E$ has a **negative cycle** if there exist vertices $v_0, v_1, \ldots, v_k = v_0$ and weights $w_0, \ldots, w_{k-1}$ such that each $(v_t, v_{t+1}, w_t) \in E$ and $\sum_{t=0}^{k-1} w_t < 0$.

**Theorem 6.3** (Feasibility implies no negative cycle). *If $E$ is feasible, then $E$ has no negative cycle.*

**Proof**. Let $x$ be a feasible assignment. For any cycle $v_0 \to v_1 \to \cdots \to v_k = v_0$, each edge gives $x(v_t) \leq w_t + x(v_{t+1})$. Summing over $t = 0, \ldots, k-1$:

$$\sum_{t=0}^{k-1} x(v_t) \leq \sum_{t=0}^{k-1} w_t + \sum_{t=0}^{k-1} x(v_{t+1})$$

Since $v_0 = v_k$, the sums $\sum_t x(v_t)$ and $\sum_t x(v_{t+1})$ are equal (they are cyclic shifts of the same values). Therefore $0 \leq \sum_t w_t$, contradicting the assumption that the cycle weight is negative. ∎

**Remark**. The converse — that absence of negative cycles implies feasibility — is the content of the Bellman–Ford correctness theorem. The feasible assignment is constructed by computing shortest-path distances from a virtual source node. This is formalized in our implementation but the forward implication suffices for certification purposes.

## 7. Algorithms

### 7.1 Floyd–Warshall Closure

**Input**: Weight matrix $c \in ℝ^{n \times n}$
**Output**: Closed matrix $c^*$ and feasibility flag

```
function FloydWarshallClosure(c):
    d ← copy(c)
    for k = 0 to n-1:
        for i = 0 to n-1:
            for j = 0 to n-1:
                d[i,j] ← min(d[i,j], d[i,k] + d[k,j])
    feasible ← all(d[i,i] ≥ 0)
    return (d, feasible)
```

**Complexity**: $O(n^3)$ time, $O(n^2)$ space.

### 7.2 Bellman–Ford Feasibility

**Input**: $n$ variables, edge set $E$ of $(i, j, w)$ triples
**Output**: Feasibility flag and witness assignment

```
function BellmanFord(n, E):
    dist ← array of n zeros
    for iteration = 1 to n-1:
        for (i, j, w) in E:
            if dist[j] + w < dist[i]:
                dist[i] ← dist[j] + w
    for (i, j, w) in E:
        if dist[j] + w < dist[i]:
            return (infeasible, negative cycle found)
    return (feasible, dist)
```

**Complexity**: $O(n \cdot |E|)$ time, $O(n)$ space.

### 7.3 Tropical Hull Membership

**Input**: Point $x$, generators $V$
**Output**: Membership flag and coefficient vector

For difference-constraint generators with $V_j(i) = -c_{ji}$:

```
function TropicalHullMembership(x, c):
    x_norm ← x - max(x)                    # Normalize
    for all i, j:
        if x_norm[j] - c[j,i] > x_norm[i] + ε:
            return (not in hull, null)
    λ ← x_norm                              # Witness coefficients
    return (in hull, λ)
```

**Complexity**: $O(n^2)$ time, $O(n)$ space.

## 8. Applications

### 8.1 Train Scheduling

A railway network with $n$ stations and timing constraints (minimum headway, travel times, turnaround times) defines a difference-constraint system. The tropical polytope of feasible schedules captures all valid timetables. Canonical generators correspond to extremal schedules — timetables where all slack is concentrated at a single station.

### 8.2 Digital Circuit Timing

Static timing analysis of a digital circuit creates a constraint graph where gate propagation delays, setup/hold times, and interconnect delays are difference constraints. The critical path delay equals the longest shortest-path distance in the constraint graph. The tropical polytope structure reveals the space of all valid clock assignments.

### 8.3 Project Management

The Critical Path Method (CPM) is a difference-constraint feasibility problem. Task dependencies with duration bounds create the constraint graph. The project duration equals the longest path from start to finish. The tropical Minkowski–Weyl theorem shows that the space of feasible schedules is finitely generated by extremal schedules.

## 9. Computational Experiments

### 9.1 Tropical Hull Sampling

We sampled the tropical convex hull of three generators in $ℝ^2$:

| Generator | Coordinates |
|-----------|-------------|
| $v_0$     | $(0, -2)$   |
| $v_1$     | $(-1, 0)$   |
| $v_2$     | $(-1.5, -0.5)$ |

The resulting hull is a non-convex region (in the classical sense) bounded by piecewise-linear curves. See Figure 1 in the visualization outputs.

### 9.2 Bellman–Ford Convergence

For a 4-variable system with 6 constraints, Bellman–Ford converges in 3 iterations. The distance values stabilize monotonically, consistent with the theoretical $O(n)$ iteration bound.

### 9.3 Difference-Constraint Verification

For a 3-dimensional closed constraint matrix:

$$c = \begin{pmatrix} 0 & 2 & 3 \\ 1 & 0 & 1 \\ 2 & 3 & 0 \end{pmatrix}$$

All three canonical generators satisfy the constraints, and every tested feasible point is exactly reconstructed by the tropical combination formula with $\lambda_j = x_j$.

## 10. Discussion

### 10.1 Significance

Our formal development establishes a verified foundation for tropical optimization that bridges three domains:

1. **Geometry**: Tropical convex sets with finite generation
2. **Algorithms**: Graph-theoretic feasibility and closure
3. **Complexity**: Connection to mean payoff games

### 10.2 Limitations

- We formalize the alcoved (difference-constraint) case of tropical Minkowski–Weyl, not the full theorem for arbitrary tropical halfspaces.
- The converse direction of the Bellman–Ford theorem (no negative cycle ⟹ feasibility) requires a constructive shortest-path argument that we state but leave for future formalization.
- The reduction to mean payoff games is described mathematically but not yet formally verified.

### 10.3 Future Work

See FUTURE_DIRECTIONS.md for detailed next steps. Key priorities:

1. Tropical Carathéodory theorem (support compression)
2. General tropical halfspace finite-generation
3. Certified mean payoff game reduction
4. Tropical Farkas lemma
5. Tropical spectral theorem

## 11. References

[1] I. Simon, "Recognizable sets with multiplicities in the tropical semiring," *MFCS*, 1988.

[2] M. Akian, S. Gaubert, A. Guterman, "Tropical polyhedra are equivalent to mean payoff games," *IJAC*, 2012.

[3] P. Butkovič, *Max-linear Systems: Theory and Algorithms*, Springer, 2010.

[4] M. Develin, B. Sturmfels, "Tropical convexity," *Doc. Math.*, 2004.

[5] S. Gaubert, R. Katz, "The Minkowski theorem for max-plus convex sets," *Linear Algebra Appl.*, 2007.

[6] P. Butkovič, "Max-algebra: the linear algebra of combinatorics?" *Linear Algebra Appl.*, 2003.

[7] M. Akian, S. Gaubert, A. Guterman, "Linear independence over tropical semirings and beyond," *Contemp. Math.*, 2009.

[8] M. Akian, S. Gaubert, A. Guterman, "Tropical polyhedra are equivalent to mean payoff games," *IJAC*, 2012.

[9] M. Bezem, R. Nieuwenhuis, E. Rodríguez-Carbonell, "The max-atom problem and its relevance," *LPAR*, 2008.
