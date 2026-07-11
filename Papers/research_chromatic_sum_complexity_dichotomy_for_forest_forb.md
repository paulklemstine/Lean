# The Chromatic Sum of Finite Graphs: Foundations, Exact Formulas, and Contrarian Counterexamples

## Abstract

The *chromatic sum* $\Sigma(G)$ of a finite simple graph $G$ is the minimum, over all proper colorings using positive integer colors, of the total sum of colors assigned to vertices. Unlike the chromatic number $\chi(G)$, which measures only the size of the color palette, the chromatic sum is sensitive to the *multiplicity* with which each color is used, and its optimal colorings behave counterintuitively. We develop the chromatic sum from first principles: we establish that the defining minimum is attained, prove the universal lower-bound property, and derive the fundamental structural facts $\Sigma(G) \geq |V|$, equality for the edgeless graph, and monotonicity under subgraph inclusion. We then compute two exact closed forms: $\Sigma(K_n) = \binom{n+1}{2} = n(n+1)/2$ for the complete graph, and $\Sigma(K_{1,n}) = n + 2$ for the star, the simplest nontrivial family of trees. As a corollary we obtain $\Sigma(K_n) = |V| + |E|$. We use these formulas to *refute* two natural conjectures: (i) the closed form $\Sigma(G) = |V| + |E|$, though valid for edgeless graphs, single edges, and *all* complete graphs, fails already for the three-vertex path $P_3$ (a forest), where $\Sigma = 4 \neq 5$; and (ii) a proper coloring achieving the optimal number of colors need not minimize the color sum, again witnessed by $P_3$. These results form the combinatorial substrate of the conjectured complexity dichotomy for the Chromatic Sum problem on $H$-free graphs, and the star formula is a first exact result on the tractable (forest) side.

**Keywords:** chromatic sum, minimum color sum, graph coloring, proper coloring, triangular number, star graph, path graph, complexity dichotomy, $H$-free graphs, forests.

---

## 1. Introduction

Graph coloring is among the oldest and most influential topics in combinatorics. In its classical form one seeks the *chromatic number* $\chi(G)$: the least number of colors needed so that adjacent vertices receive distinct colors. A wealth of theory, from the Four Color Theorem to the modern classification of coloring complexity on hereditary graph classes, revolves around this single integer.

Yet in many applications colors are not interchangeable tokens; they carry *cost*. In scheduling, a "color" may represent a time slot, and later slots delay completion. In frequency assignment, higher channels are scarcer and more expensive. In resource allocation, one wishes not merely to separate conflicting tasks but to minimize the aggregate expense of the assignment. These applications motivate the **chromatic sum** (also called the *minimum color sum* or *vertex coloring sum*):

$$\Sigma(G) = \min_{c} \sum_{v \in V} c(v),$$

the minimum total color, taken over all proper colorings $c : V \to \{1, 2, 3, \dots\}$.

The chromatic sum superficially resembles the chromatic number — both are minimized by "using small colors" — but it is a genuinely finer invariant. It depends on how many vertices receive each color, not merely on how many colors appear. This paper develops the invariant rigorously and demonstrates, through exact computation, precisely how it departs from naive expectation.

Our contributions are:

1. **Foundations (§3).** A self-contained development: existence and attainment of the optimum, the universal lower-bound property characterizing $\Sigma(G)$ as a minimum, the bound $\Sigma(G) \geq |V|$, the exact value $\Sigma(\overline{K_n}) = |V|$ for the edgeless graph, and monotonicity $\Sigma(H) \leq \Sigma(G)$ under subgraph inclusion.

2. **Exact formulas (§4).** The triangular-number formula $\Sigma(K_n) = n(n+1)/2$, its corollary $\Sigma(K_n) = |V| + |E|$, and the star formula $\Sigma(K_{1,n}) = n + 2$.

3. **Contrarian refutations (§5).** Two tempting conjectures are disproved by the three-vertex path: the closed form $\Sigma(G) = |V| + |E|$ fails in general, and a chromatic-number-optimal coloring need not be sum-optimal.

4. **Context (§6–7).** We situate these results within the conjectured complexity dichotomy for the Chromatic Sum problem on $H$-free graphs and outline concrete next steps.

---

## 2. Preliminaries and Notation

Throughout, $G = (V, E)$ is a finite simple graph: $V$ is a finite vertex set and $E$ a set of unordered pairs of distinct vertices. We write $u \sim v$ when $\{u, v\} \in E$ (the vertices are *adjacent*), $|V|$ for the number of vertices, and $|E|$ for the number of edges. The *complete graph* $K_n$ has $n$ vertices, all pairs adjacent. The *edgeless graph* $\overline{K_n}$ on $n$ vertices has $E = \varnothing$. The *path* $P_3$ has vertices $\{0, 1, 2\}$ and edges $\{0,1\}, \{1,2\}$. The *star* $K_{1,n}$ has a central vertex adjacent to each of $n$ leaves, with no edges among leaves; note $P_3 = K_{1,2}$.

The colors are the positive integers $\{1, 2, 3, \dots\}$.

---

## 3. The Chromatic Sum: Definition and Basic Theory

### 3.1 Definitions

**Definition 3.1 (Proper coloring).** A function $c : V \to \mathbb{Z}_{\geq 1}$ is a *proper coloring* of $G$ if (i) $c(v) \geq 1$ for all $v$, and (ii) $c(u) \neq c(v)$ whenever $u \sim v$.

**Definition 3.2 (Color sum).** The *color sum* of a coloring $c$ is $\mathrm{colorSum}(c) = \sum_{v \in V} c(v)$.

**Definition 3.3 (Chromatic sum).** The *chromatic sum* of $G$ is
$$\Sigma(G) = \min\{\, \mathrm{colorSum}(c) : c \text{ is a proper coloring of } G \,\}.$$
Equivalently, $\Sigma(G)$ is the infimum of the set of achievable color sums; we show below this infimum is attained and hence is a genuine minimum.

### 3.2 Existence and attainment

**Lemma 3.4 (A proper coloring always exists).** *Every finite graph $G$ admits a proper coloring.*

*Proof sketch.* Enumerate the vertices $v_0, v_1, \dots, v_{n-1}$ via any bijection with $\{0, \dots, n-1\}$ and set $c(v_i) = i + 1$. All colors are $\geq 1$, and since distinct vertices receive distinct colors, adjacent vertices in particular receive distinct colors. $\square$

Consequently the set of achievable color sums is nonempty. Because it is a nonempty set of natural numbers, it contains a least element, so the infimum defining $\Sigma(G)$ is attained:

**Theorem 3.5 (Attainment).** *There exists a proper coloring $c^\star$ with $\mathrm{colorSum}(c^\star) = \Sigma(G)$.*

*Proof sketch.* The achievable color sums form a nonempty subset of $\mathbb{N}$; every nonempty subset of $\mathbb{N}$ has a minimum, and by definition $\Sigma(G)$ is that minimum, so it is realized by some coloring. $\square$

### 3.3 The universal property

The chromatic sum is characterized by two dual properties, exactly as a minimum should be.

**Proposition 3.6 (Lower bound by any coloring).** *For every proper coloring $c$, $\Sigma(G) \leq \mathrm{colorSum}(c)$.*

**Proposition 3.7 (Universal lower bound).** *If $k \in \mathbb{N}$ satisfies $k \leq \mathrm{colorSum}(c)$ for every proper coloring $c$, then $k \leq \Sigma(G)$.*

*Proof sketch.* Proposition 3.6 is immediate: $\Sigma(G)$ is the minimum, so it is $\leq$ any member of the set. For Proposition 3.7, apply the hypothesis to the optimal coloring $c^\star$ from Theorem 3.5: $k \leq \mathrm{colorSum}(c^\star) = \Sigma(G)$. $\square$

Together these say: to prove $\Sigma(G) = m$ it suffices to exhibit one coloring of sum $m$ (giving $\Sigma(G) \leq m$) and to argue that every proper coloring has sum $\geq m$ (giving $\Sigma(G) \geq m$). This *upper-bound-by-construction, lower-bound-by-argument* template drives every computation in §4.

### 3.4 Structural bounds

**Theorem 3.8 (Vertex floor).** *For every graph $G$ on $n$ vertices, $\Sigma(G) \geq n$.*

*Proof sketch.* In any proper coloring each of the $n$ vertices has color $\geq 1$, so the sum is $\geq \sum_{v} 1 = n$. Apply Proposition 3.7 with $k = n$. $\square$

**Theorem 3.9 (Edgeless graph).** *For the edgeless graph on $n$ vertices, $\Sigma(\overline{K_n}) = n$.*

*Proof sketch.* The constant coloring $c \equiv 1$ is proper (no edges to violate) and has sum $n$, giving $\Sigma \leq n$; combine with the floor $\Sigma \geq n$ of Theorem 3.8. $\square$

**Theorem 3.10 (Monotonicity).** *If $H$ is a subgraph of $G$ on the same vertex set (i.e. $E(H) \subseteq E(G)$), then $\Sigma(H) \leq \Sigma(G)$.*

*Proof sketch.* Every proper coloring of $G$ is also a proper coloring of $H$: the color constraints of $H$ are a subset of those of $G$. Hence every color sum achievable for $G$ is achievable for $H$, so the minimum for $H$ is no larger. Formally, apply Proposition 3.7: for any proper coloring $c$ of $G$, restricting attention to the edges of $H$ shows $c$ is proper for $H$, so $\Sigma(H) \leq \mathrm{colorSum}(c)$; minimizing over $c$ gives the claim. $\square$

Monotonicity confirms the intuition that *adding constraints (edges) can only raise the cost*.

---

## 4. Exact Formulas

### 4.1 The complete graph

In $K_n$ every pair of vertices is adjacent, so a coloring is proper iff it is *injective* with positive values.

**Lemma 4.1 (Proper = injective on $K_n$).** *A coloring $c$ of $K_n$ is proper iff $c(v) \geq 1$ for all $v$ and $c$ is injective.*

*Proof sketch.* Adjacency in $K_n$ means "distinct vertices"; the properness condition $u \sim v \Rightarrow c(u) \neq c(v)$ therefore reads "distinct vertices have distinct colors," i.e. injectivity. $\square$

The optimization now becomes: minimize the sum of $n$ *distinct* positive integers. The answer is the smallest such set.

**Lemma 4.2 (Minimality of the initial segment).** *If $T \subseteq \mathbb{Z}_{\geq 1}$ is a finite set of positive integers with $|T| = k$, then*
$$\sum_{x \in T} x \geq 1 + 2 + \cdots + k = \frac{k(k+1)}{2}.$$

*Proof sketch.* Induct on $|T|$, removing the maximum element $m = \max T$. Since $T \subseteq \{1, 2, \dots, m\}$, we have $|T| \leq m$, i.e. $k \leq m$. By induction the remaining $k - 1$ elements sum to at least $1 + \cdots + (k-1)$, and the removed element contributes $m \geq k$. Adding, $\sum_{x \in T} x \geq (1 + \cdots + (k-1)) + k$. $\square$

**Lemma 4.3 (Injective lower bound).** *Any injective positive coloring $c$ of an $n$-vertex graph satisfies $\mathrm{colorSum}(c) \geq n(n+1)/2$.*

*Proof sketch.* The image $c(V)$ is a set of $n$ distinct positive integers; its sum equals $\mathrm{colorSum}(c)$ by injectivity, and Lemma 4.2 bounds it below by $n(n+1)/2$. $\square$

**Theorem 4.4 (Chromatic sum of the complete graph).** *For all $n$,*
$$\Sigma(K_n) = \frac{n(n+1)}{2}.$$

*Proof sketch.* *Upper bound:* the coloring $c(v_i) = i + 1$ (colors $1, \dots, n$) is injective and positive, hence proper by Lemma 4.1, with sum $1 + \cdots + n = n(n+1)/2$. *Lower bound:* every proper coloring is injective (Lemma 4.1), so Lemma 4.3 gives sum $\geq n(n+1)/2$; conclude via Proposition 3.7. $\square$

**Corollary 4.5 (Vertices-plus-edges for $K_n$).** $\Sigma(K_n) = |V| + |E|$.

*Proof sketch.* $K_n$ has $|V| = n$ and $|E| = \binom{n}{2} = n(n-1)/2$, so $|V| + |E| = n + n(n-1)/2 = n(n+1)/2 = \Sigma(K_n)$ by Theorem 4.4. $\square$

### 4.2 The star

The star $K_{1,n}$ has a center adjacent to all $n$ leaves, and no other edges. It is a tree, hence a forest — placing it on the *tractable* side of the conjectured dichotomy (§6).

**Theorem 4.6 (Chromatic sum of the star).** *For every $n \geq 1$,*
$$\Sigma(K_{1,n}) = n + 2.$$

*Proof sketch.* *Upper bound:* color the center $2$ and every leaf $1$. Leaves are mutually non-adjacent, so sharing color $1$ is legal; each leaf differs from the center's $2$. This coloring is proper with sum $2 + \underbrace{1 + \cdots + 1}_{n} = n + 2$, so $\Sigma(K_{1,n}) \leq n + 2$.

*Lower bound:* fix any proper coloring $c$ and split on the center's color $c(\text{center})$.
- If $c(\text{center}) = 1$: every leaf is adjacent to the center, so each leaf color is $\geq 2$. The $n$ leaves contribute $\geq 2n$ and the center contributes $1$, for a total $\geq 1 + 2n \geq n + 2$ (using $n \geq 1$).
- If $c(\text{center}) \geq 2$: each of the $n$ leaves contributes $\geq 1$ and the center contributes $\geq 2$, for a total $\geq n + 2$.

In both cases $\mathrm{colorSum}(c) \geq n + 2$; conclude via Proposition 3.7. $\square$

The comparison is instructive: the *worse* natural strategy — center $1$, leaves $2$ — costs $1 + 2n$, nearly double $n + 2$ for large $n$. The single choice of where to place the cheap color separates linear from nearly-doubled cost. Setting $n = 2$ recovers $\Sigma(P_3) = 4$ (§5).

---

## 5. Contrarian Results: Two Refuted Conjectures

Corollary 4.5 shows $\Sigma(G) = |V| + |E|$ for all complete graphs; it also holds for the edgeless graph ($n + 0 = n$) and the single edge ($2 + 1 = 3$). This invites a general conjecture, which we now demolish.

### 5.1 The path $P_3$

**Theorem 5.1 (Chromatic sum of $P_3$).** $\Sigma(P_3) = 4$.

*Proof sketch.* *Upper bound:* color the endpoints $1$ and the center $2$; this is proper (center differs from both endpoints) with sum $1 + 2 + 1 = 4$. *Lower bound:* let $c$ be any proper coloring with colors $c(0), c(1), c(2) \geq 1$, subject to $c(0) \neq c(1)$ and $c(1) \neq c(2)$. If $c(1) = 1$ then $c(0), c(2) \geq 2$, so the sum is $\geq 1 + 2 + 2 = 5$; if $c(1) \geq 2$ then the sum is $\geq 1 + 2 + 1 = 4$. In all cases the sum is $\geq 4$. (This is the $n = 2$ case of Theorem 4.6.) $\square$

### 5.2 First refutation: the naive closed form

**Theorem 5.2 (Refutation of $\Sigma = |V| + |E|$).** *It is false that $\Sigma(G) = |V| + |E|$ for all finite graphs $G$.*

*Proof.* For $P_3$ we have $|V| = 3$, $|E| = 2$, so $|V| + |E| = 5$, whereas $\Sigma(P_3) = 4$ by Theorem 5.1. Hence the identity fails. $\square$

The failure occurs at the smallest tree with a branch vertex — a *forest*. The mechanism is precisely the high-degree vertex: assigning the branch vertex an expensive color lets its several neighbors share the cheap one, undercutting the edge-counting heuristic.

### 5.3 Second refutation: fewest colors $\neq$ cheapest

The path $P_3$ is bipartite, so $\chi(P_3) = 2$. One might expect every coloring attaining $\chi$ colors to be sum-optimal. It is not.

**Theorem 5.3 (A $\chi$-optimal coloring need not be sum-optimal).** *There is a proper coloring of $P_3$ using exactly $2$ colors whose color sum exceeds $\Sigma(P_3)$.*

*Proof.* Color the endpoints $2$ and the center $1$. This is proper, uses exactly the two colors $\{1, 2\}$, and has sum $2 + 1 + 2 = 5 > 4 = \Sigma(P_3)$. $\square$

Thus minimizing the *number* of colors (the chromatic number) and minimizing the *sum* of colors (the chromatic sum) are distinct optimization problems; a palette-optimal solution can be cost-suboptimal. This separation is the conceptual core of what makes the chromatic sum harder than ordinary coloring.

---

## 6. Application: The Conjectured Complexity Dichotomy

The above results are the combinatorial groundwork for a computational-complexity question. For a fixed "forbidden pattern" graph $H$, an $H$-free graph is one containing no induced copy of $H$. The **Chromatic Sum problem** asks, given $G$ (and a budget), whether $\Sigma(G)$ is at most a given value.

**Conjecture 6.1 (Chromatic Sum dichotomy).** *For every fixed graph $H$:*
- *If $H$ is a forest, the Chromatic Sum problem restricted to $H$-free graphs is solvable in polynomial time.*
- *If $H$ contains a cycle, the Chromatic Sum problem restricted to $H$-free graphs is NP-complete.*

This mirrors, for the sum invariant, the well-studied dichotomy landscape for ordinary coloring on hereditary classes. A single structural feature of the forbidden pattern — the presence or absence of a cycle — is conjectured to draw the line between tractable and intractable.

Our formulas populate the *forest* (tractable) side with exact, constructive answers. The star family $K_{1,n}$ — the simplest nontrivial trees — is solved completely by $\Sigma(K_{1,n}) = n + 2$, with an explicit optimal coloring. The refutations of §5 show that even on this easy side the problem is genuinely nontrivial: it cannot be reduced to counting edges, nor to standard chromatic-number heuristics. Understanding *why* forests are easy therefore requires understanding the color-placement subtleties these examples isolate.

Complexity-theoretic statements themselves (membership in P, NP-completeness, reductions) require a formal model of computation and lie beyond the combinatorial scope of this paper; we establish the invariant and its structural theory, on which such statements would be built.

---

## 7. Discussion and Future Work

### 7.1 Summary

We built the chromatic sum $\Sigma(G)$ from first principles, proving it is a well-defined attained minimum with the expected universal property, together with the floor $\Sigma \geq |V|$, edgeless equality, and subgraph monotonicity. We computed $\Sigma(K_n) = n(n+1)/2 = |V| + |E|$ and $\Sigma(K_{1,n}) = n + 2$, and used the path $P_3$ to refute both the seductive closed form $\Sigma = |V| + |E|$ and the belief that a chromatic-number-optimal coloring minimizes cost.

### 7.2 Future directions

1. **General forest formula.** The star case is complete; the natural next step is a polynomial recursion for $\Sigma$ on arbitrary trees via dynamic programming over subtrees (root each subtree, track the optimal cost under each possible root color). This is the constructive heart of the conjectured tractable side.

2. **Bipartite lower bounds.** Establish bounds of the form $\Sigma(G) \geq |V| + (\text{matching number})$ and compute the exact value on complete bipartite graphs $K_{m,n}$.

3. **The $\Sigma$-vs-$\chi$ gap.** Exhibit families (e.g. balanced binary trees) in which *every* minimum-sum coloring provably uses strictly more than $\chi = 2$ colors, quantifying how far cost-optimality departs from palette-optimality.

4. **Toward the hard side.** Identify the smallest cyclic forbidden patterns for which intractability is expected, and isolate the gadget constructions (built from paths and stars like those here) that would drive an eventual hardness reduction.

### 7.3 Closing remark

The chromatic sum recasts coloring as economics: its optimal solutions sacrifice busy, high-degree vertices to expensive colors so that their many neighbors can crowd onto cheap ones. That single principle explains the triangular number for complete graphs, the $n + 2$ for stars, and the collapse of the $|V| + |E|$ heuristic — and it is the same principle a future algorithm must exploit to conquer the tractable side of the dichotomy.

---

## Appendix: Table of Computed Values

| Graph | $|V|$ | $|E|$ | $\chi$ | $\Sigma$ | $|V| + |E|$ | Optimal coloring |
|---|---|---|---|---|---|---|
| Edgeless $\overline{K_n}$ | $n$ | $0$ | $1$ | $n$ | $n$ | all $1$ |
| Single edge $K_2$ | $2$ | $1$ | $2$ | $3$ | $3$ | $1, 2$ |
| Complete $K_n$ | $n$ | $\binom{n}{2}$ | $n$ | $n(n+1)/2$ | $n(n+1)/2$ | $1, 2, \dots, n$ |
| Path $P_3 = K_{1,2}$ | $3$ | $2$ | $2$ | $4$ | $5$ | ends $1$, center $2$ |
| Star $K_{1,n}$ | $n+1$ | $n$ | $2$ | $n+2$ | $2n+1$ | center $2$, leaves $1$ |

The columns $\Sigma$ and $|V| + |E|$ agree exactly for edgeless graphs, single edges, and complete graphs, and diverge for the path and general stars — precisely the content of Theorem 5.2.
