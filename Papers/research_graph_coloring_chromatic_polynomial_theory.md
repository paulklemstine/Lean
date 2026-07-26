# Chromatic Counting Functions: Deletion–Contraction, Extremal Evaluations, and Component Factorization

**Aristotle**  
**26 July 2026**

## Abstract

For a finite simple graph $G$ and a nonnegative integer $q$, let $P(G,q)$ be the number of proper vertex colorings of $G$ by a palette of $q$ colors. This paper gives a self-contained development of the basic counting theory. We prove the empty-graph formula $P(E_n,q)=q^n$ and the complete-graph formula $P(K_n,q)=q^{\underline n}$. We define edge deletion and a concrete simple-graph contraction, then partition the proper colorings after deletion according to whether the endpoints of the deleted edge receive distinct or equal colors. An explicit restriction-and-extension bijection identifies the equal-color class with the proper colorings of the contraction. This yields

$$
P(G-e,q)=P(G,q)+P(G/e,q),
$$

and hence the traditional subtractive recurrence. We also prove multiplicativity under disjoint union,

$$
P(G\sqcup H,q)=P(G,q)P(H,q),
$$

and derive a bound on the contraction contribution. These results provide an exact recursive algorithm for chromatic counts. We discuss direct enumeration, deletion–contraction, component-aware evaluation, complexity, examples, applications, and the distinction between the established counting theory and broader goals involving polynomial coefficients, planar coloring, maximum-degree bounds, and basis positivity.

## 1. Introduction

Graph coloring models assignments subject to pairwise incompatibility. A graph vertex may represent a region, task, radio transmitter, register candidate, or experimental condition; an edge records that its endpoints may not receive the same label. The familiar feasibility question asks whether a graph can be colored from a palette of a given size. The enumerative question asks how many such colorings exist.

The enumerative viewpoint records more information. A count distinguishes a rigid instance with a unique assignment from a flexible instance with many assignments, even when both need the same minimum number of colors. Counts also support sensitivity analysis: one may ask exactly how many assignments are gained by removing a constraint, or how independent subsystems combine.

The fundamental relation is deletion–contraction. Given an edge $e$, delete it. Every proper coloring of the resulting graph either still separates the endpoints or gives them the same color. The first class is precisely the set of proper colorings before deletion. The second is naturally equivalent to the colorings of the graph in which the endpoints are merged. The recurrence follows by cardinality.

Our treatment emphasizes finite sets and explicit bijections. This keeps the argument valid for every nonnegative palette size, including $q=0$, and clarifies the exact role of contraction. Although the notation $P(G,q)$ anticipates the chromatic polynomial, the results below require only its counting interpretation at natural values. Constructing an integer-coefficient polynomial object and proving equality of polynomial expressions is a further algebraic step.

All arguments use only finite sets, elementary graph operations, and explicit correspondences between colorings. No interpolation or pre-existing polynomial theory is needed for the counting identities.

The principal results are:

1. For the edgeless graph $E_n$, $P(E_n,q)=q^n$.
2. For the complete graph $K_n$, $P(K_n,q)=q^{\underline n}$.
3. For every edge $e$ of $G$, $P(G-e,q)=P(G,q)+P(G/e,q)$.
4. For disjoint graphs $G$ and $H$, $P(G\sqcup H,q)=P(G,q)P(H,q)$.
5. The contraction count satisfies $P(G/e,q)\le P(G-e,q)$.

After proving these statements, we turn them into algorithms and illustrate them numerically.

## 2. Definitions and conventions

### 2.1 Finite simple graphs

A **finite simple graph** $G=(V,E)$ consists of a finite vertex set $V$ and an edge set $E$ made of unordered two-element subsets of $V$. Equivalently, adjacency is a symmetric, irreflexive relation: if $x$ is adjacent to $y$, then $y$ is adjacent to $x$, and no vertex is adjacent to itself. We write $x\sim_G y$ when $x$ and $y$ are adjacent.

The **edgeless graph** $E_n$ has $n$ vertices and no edges. The **complete graph** $K_n$ has $n$ vertices and an edge between every pair of distinct vertices.

### 2.2 Proper colorings and chromatic counts

Fix a finite color set $C$. A **proper $C$-coloring** of $G$ is a function

$$
c:V\longrightarrow C
$$

such that

$$
x\sim_G y\quad\Longrightarrow\quad c(x)\ne c(y).
$$

When $C$ has $q$ elements, the number of proper colorings depends only on $q$, not on the names of the colors. We define the **chromatic counting function** by

$$
P(G,q)=\#\{c:V\to \{1,\ldots,q\}:c\text{ is proper}\}.
$$

For $q=0$, the palette is empty. There is one function from the empty vertex set to the empty palette and no function from a nonempty vertex set to it, so the usual finite-set conventions handle this boundary case automatically.

### 2.3 Falling factorials

For nonnegative integers $q$ and $n$, the **falling factorial** is

$$
q^{\underline n}=q(q-1)(q-2)\cdots(q-n+1),
$$

with $q^{\underline 0}=1$. Combinatorially, $q^{\underline n}$ counts injections from an $n$-element set into a $q$-element set. If $n>q$, no injection exists and the count is zero.

### 2.4 Edge deletion

Let $e=\{a,b\}$ be an edge of $G$. The **edge deletion** $G-e$ has the same vertex set as $G$ and all edges except $e$. Thus

$$
x\sim_{G-e}y
$$

holds exactly when $x\sim_G y$ and $\{x,y\}\ne\{a,b\}$.

### 2.5 Edge contraction

The **edge contraction** $G/e$ merges $a$ and $b$ into one vertex. One concrete construction keeps every vertex other than $b$ and uses $a$ as the representative of the merged vertex. Distinct retained vertices $x$ and $y$ are adjacent in $G/e$ when either they were adjacent in $G$, or one is $a$ and the other was adjacent to $b$ in $G$. Duplicate edges have no effect, and loops are excluded.

This construction redirects every incidence of $b$ to $a$. It is isomorphic to the usual quotient construction that identifies $a$ and $b$, but it avoids ambiguity about representatives. The assumption that $e$ is an edge implies $a\ne b$.

### 2.6 Disjoint union

If $G=(V,E_G)$ and $H=(W,E_H)$ have disjoint vertex sets, their **disjoint union** $G\sqcup H$ has vertex set $V\sqcup W$. Adjacency inside each summand is inherited from its graph, and there are no edges between the summands.

## 3. Extremal evaluations

We begin with the two graphs for which properness has the simplest possible meaning.

### Theorem 3.1 (Empty-Graph Formula)

For every $n,q\ge 0$, the edgeless graph $E_n$ satisfies

$$
P(E_n,q)=q^n.
$$

#### Proof sketch

Because $E_n$ has no adjacent vertices, the properness condition imposes no restriction. Every function from its $n$ vertices to the $q$-element palette is proper. Each vertex has $q$ independent choices, giving $q^n$ functions. The formula includes $n=0$, where the unique empty function gives $q^0=1$. $\square$

### Theorem 3.2 (Complete-Graph Formula)

For every $n,q\ge 0$, the complete graph $K_n$ satisfies

$$
P(K_n,q)=q^{\underline n}.
$$

#### Proof sketch

Every two distinct vertices of $K_n$ are adjacent, so a coloring is proper exactly when no two vertices receive the same color. Proper colorings are therefore injections from an $n$-element vertex set into a $q$-element palette. Ordering the vertices, there are $q$ choices for the first image, $q-1$ for the second, and so forth, producing $q^{\underline n}$. If $n>q$, no injection exists and the falling factorial count is zero. $\square$

### Corollary 3.3

For $q\ge n$,

$$
P(K_n,q)=\frac{q!}{(q-n)!}.
$$

This is merely the factorial form of the falling factorial. The product formulation remains combinatorially meaningful without separately treating $q<n$.

## 4. The coloring partition associated with an edge

Fix a finite simple graph $G$, an edge $e=\{a,b\}$, and a finite palette $C$. Consider the set $\mathcal C(G-e,C)$ of proper $C$-colorings of the deletion. Partition it into

$$
\mathcal C_{\ne}=\{c\in\mathcal C(G-e,C):c(a)\ne c(b)\}
$$

and

$$
\mathcal C_{=}=\{c\in\mathcal C(G-e,C):c(a)=c(b)\}.
$$

Equality of colors is decidable in a finite palette, and every coloring belongs to exactly one class. Thus

$$
\#\mathcal C(G-e,C)=\#\mathcal C_{\ne}+\#\mathcal C_{=}.
$$

The next two lemmas identify these terms.

### Lemma 4.1 (Distinct-Endpoint Class)

The set $\mathcal C_{\ne}$ is exactly the set $\mathcal C(G,C)$ of proper $C$-colorings of $G$.

#### Proof sketch

A proper coloring of $G$ remains proper after an edge is deleted and, because $a$ and $b$ are adjacent in $G$, it gives them distinct colors. Conversely, a proper coloring of $G-e$ that gives $a$ and $b$ distinct colors satisfies the only constraint omitted during deletion. It therefore satisfies every edge constraint of $G$. $\square$

### Lemma 4.2 (Equal-Endpoint Contraction Bijection)

There is a bijection

$$
\mathcal C_{=}\cong \mathcal C(G/e,C).
$$

#### Proof sketch

Given $c\in\mathcal C_{=}$, restrict $c$ to the retained vertices of $G/e$, omitting $b$. This restriction is proper. An ordinary retained edge was already constrained in $G-e$. If an edge of the contraction arises by redirecting an edge incident to $b$, its other endpoint has color different from $c(b)$; since $c(a)=c(b)$, it also has color different from the merged vertex’s color.

Conversely, let $d$ be a proper coloring of $G/e$. Extend it to $G-e$ by assigning $d(a)$ to both $a$ and $b$, while preserving $d$ on every other vertex. The endpoints are equal by construction. Any edge not incident to $b$ is respected because it appears in the contraction. Any surviving edge incident to $b$ becomes an edge from its other endpoint to the merged representative $a$ in the contraction, so its endpoints receive different colors.

Restriction followed by extension recovers the original equal-endpoint coloring because that coloring already satisfies $c(a)=c(b)$. Extension followed by restriction plainly recovers $d$. Hence the maps are inverse bijections. $\square$

The concrete redirection definition of contraction is precisely what makes both directions transparent.

## 5. Deletion–contraction

### Theorem 5.1 (Deletion–Contraction)

Let $G$ be a finite simple graph, let $e$ be an edge of $G$, and let $q\ge 0$. Then

$$
P(G-e,q)=P(G,q)+P(G/e,q).
$$

#### Proof sketch

Partition the proper $q$-colorings of $G-e$ into the distinct-endpoint and equal-endpoint classes. Lemma 4.1 identifies the first class with the proper colorings of $G$. Lemma 4.2 identifies the second class bijectively with the proper colorings of $G/e$. The classes are disjoint and exhaustive, so their cardinalities add. $\square$

### Corollary 5.2 (Subtractive Form)

Under the same assumptions,

$$
P(G,q)=P(G-e,q)-P(G/e,q).
$$

#### Proof sketch

Theorem 5.1 expresses $P(G-e,q)$ as a sum of two natural numbers. Subtract the contraction contribution, which is no larger than the sum. $\square$

### Corollary 5.3 (Contraction Bound)

Under the same assumptions,

$$
P(G/e,q)\le P(G-e,q).
$$

#### Proof sketch

By Theorem 5.1, $P(G-e,q)$ is $P(G/e,q)$ plus the nonnegative integer $P(G,q)$. Equivalently, Lemma 4.2 embeds contraction colorings as the equal-endpoint subset of deletion colorings. $\square$

### Interpretation

Deleting an edge relaxes one inequality constraint. The newly admitted assignments are exactly those that give the two endpoints equal colors. Contraction turns this equality condition into an identification of variables. Therefore $P(G/e,q)$ is not merely an algebraic correction term: it is the exact increase in the number of feasible assignments caused by removing $e$:

$$
P(G-e,q)-P(G,q)=P(G/e,q).
$$

## 6. Disjoint-union multiplicativity

### Theorem 6.1 (Disjoint-Union Product Formula)

For finite simple graphs $G$ and $H$ and every $q\ge 0$,

$$
P(G\sqcup H,q)=P(G,q)P(H,q).
$$

#### Proof sketch

Restrict a proper coloring of $G\sqcup H$ to the vertices of $G$ and $H$. Because there are no cross edges, both restrictions are proper. Conversely, given a proper coloring of $G$ and one of $H$, combine the two functions on the disjoint vertex sets. Every edge lies entirely in one component, so the combined coloring is proper. Restriction and combination are inverse operations, establishing a bijection between colorings of the union and ordered pairs of component colorings. Cardinalities multiply. $\square$

### Corollary 6.2 (Finite Component Product)

If $G$ is the disjoint union of components $G_1,\ldots,G_r$, then repeated application of Theorem 6.1 gives

$$
P(G,q)=\prod_{i=1}^r P(G_i,q).
$$

This corollary follows by induction on $r$. A systematic theory indexed directly by connected components is a useful further development, but no new combinatorial idea is needed beyond finite iteration of the binary product formula.

## 7. Worked examples

### 7.1 A three-vertex path

Let $P_3$ be a path with vertices $u,v,w$ and edges $uv$ and $vw$. Directly, choose the middle color in $q$ ways, then choose independently a different color for each endpoint. Hence

$$
P(P_3,q)=q(q-1)^2.
$$

Alternatively, regard $P_3$ as $K_3-e$. Contracting the missing triangle edge in $K_3$ gives $K_2$. Deletion–contraction yields

$$
P(P_3,q)=P(K_3,q)+P(K_2,q).
$$

Using the complete-graph formula,

$$
P(P_3,q)=q(q-1)(q-2)+q(q-1)=q(q-1)^2.
$$

At $q=3$, this is $12=6+6$.

### 7.2 An edge and an isolated vertex

Let $G=K_2\sqcup E_1$. Multiplicativity and the extremal formulas give

$$
P(G,q)=P(K_2,q)P(E_1,q)=q(q-1)q=q^2(q-1).
$$

At $q=3$, the count is $18$.

### 7.3 A four-cycle

For the cycle $C_4$, a direct small computation gives

$$
P(C_4,q)=(q-1)^4+(q-1).
$$

At $q=3$, this equals $2^4+2=18$. This formula is included as an illustrative computation rather than as a general cycle theorem. It can be obtained by applying deletion–contraction and simplifying the resulting path and tree counts, or by conditioning on whether the final vertex agrees with the first during a sequential coloring.

## 8. Algorithms

### 8.1 Exhaustive enumeration

The direct algorithm iterates through all $q^n$ functions from an $n$-vertex set to the palette and tests every edge. If $m$ is the number of edges, the worst-case time is

$$
O(mq^n),
$$

with $O(n)$ space for a coloring. Early termination upon finding a monochromatic edge improves practical behavior but not the worst-case exponent.

This method is conceptually simple and serves as an independent reference for small graphs. It directly implements the definition and is especially useful for demonstrations.

### 8.2 Deletion–contraction evaluation

A recursive evaluator uses the subtractive recurrence:

1. If the graph has no edges, return $q^n$.
2. If the graph has multiple connected components, evaluate each and multiply.
3. Choose an edge $e$.
4. Return the value for $G-e$ minus the value for $G/e$.

Without memoization, the recursion can have up to two children at each edge-processing stage and is exponential in the worst case. Contraction lowers the vertex count, while deletion lowers the edge count, ensuring termination under a lexicographic measure such as $(|V|,|E|)$ or an equivalent well-founded size accounting.

The choice of edge changes the recursion tree but not the answer. Useful heuristics include selecting an edge incident to high-degree vertices, splitting components as early as possible, and canonicalizing graphs so isomorphic or repeated subproblems can share cached results.

### 8.3 Verification by partition

For a selected edge, an implementation may expose the theorem’s partition numerically. Enumerate proper colorings of $G-e$, count those with unequal endpoint colors, and count those with equal endpoint colors. The expected identities are

$$
N_{\ne}=P(G,q),\qquad N_{=}=P(G/e,q),
$$

and

$$
N_{\ne}+N_{=}=P(G-e,q).
$$

This diagnostic is more informative than checking only the final recurrence, because it displays the bijective mechanism.

## 9. Applications

### 9.1 Scheduling and timetabling

Vertices represent events, edges represent conflicts, and colors represent time slots. The count $P(G,q)$ measures the number of feasible schedules using $q$ slots. The contraction correction quantifies how many schedules become available if one conflict is removed: it is the number of schedules of the graph obtained by identifying the two formerly conflicting events.

### 9.2 Frequency assignment

Transmitters that interfere are adjacent, and colors are frequency channels. A chromatic count measures assignment redundancy. Component factorization applies when geographical or technological separation removes all cross-interference.

### 9.3 Register allocation

Program values whose live ranges overlap are adjacent, and colors represent machine registers. Although practical allocators use additional constraints and heuristics, the basic graph model explains feasibility and the number of assignments. A large count indicates room for secondary optimization criteria.

### 9.4 Constraint sensitivity

For any edge $e$,

$$
P(G/e,q)=P(G-e,q)-P(G,q)
$$

is the exact marginal effect of deleting that constraint at palette size $q$. Ranking edges by this number identifies constraints whose relaxation produces the greatest increase in feasible assignments.

## 10. Scope and limitations

The established theory concerns natural-number evaluations of chromatic counts. It does not by itself prove several broader statements sometimes associated with graph coloring.

First, a polynomial-level theorem requires constructing an integer polynomial whose evaluation equals $P(G,q)$ for every $q$ and lifting deletion–contraction from pointwise counts to polynomial equality. The recurrence strongly motivates that construction, but the two claims should be distinguished.

Second, the Four Color Theorem requires a precise notion of planar embedding and a proof that every planar graph admits a coloring with at most four colors. The equivalence between colorability and a bound on the chromatic number is definitional in spirit, but it does not supply the planar theorem.

Third, Brooks’ theorem asserts that a connected graph can generally be colored using at most its maximum degree, except for complete graphs and odd cycles. This is a structural existence theorem, not a consequence of deletion–contraction alone.

Fourth, positivity statements for claw-free graphs require a precise basis and often richer symmetric or quasisymmetric polynomial infrastructure. Natural-number evaluations cannot substitute for coefficient positivity in a specified basis.

These distinctions preserve the strength of the present results: they give exact counting identities and algorithms without claiming unrelated structural theorems.

## 11. Future directions

A natural continuation begins by constructing the chromatic polynomial as an element of $\mathbb Z[X]$ and proving that its evaluations recover the counting function. Deletion–contraction can then be stated as polynomial equality, enabling proofs about degree, leading coefficient, and alternating signs.

Further graph operations deserve formulas, including joins, vertex sums, forests, cycles, and complete multipartite graphs. The disjoint-union product theorem suggests a systematic factorization over connected components.

Polynomial expansions in falling-factorial and tree-related bases may expose additional combinatorics. Positivity for claw-free graphs requires first fixing the intended $T$-basis and developing the corresponding algebraic framework.

On the structural side, complete treatments of Brooks’ theorem and planar four-colorability require methods beyond counting: greedy orderings and exception analysis for the former, and a robust embedding theory plus the Four Color Theorem for the latter.

Algorithmically, memoized deletion–contraction can be improved through graph canonicalization, separator detection, component splitting, and edge-selection heuristics. Experimental comparison against exhaustive enumeration can identify which graph families benefit most from each strategy.

## 12. Conclusion

Chromatic counting begins with a simple definition and acquires its power from a simple partition. For an edge $e=\{a,b\}$, proper colorings after deletion divide according to whether $a$ and $b$ are different or equal. The distinct class recovers the original graph; the equal class is in bijection with the contraction. Thus

$$
P(G-e,q)=P(G,q)+P(G/e,q).
$$

Together with $P(E_n,q)=q^n$, $P(K_n,q)=q^{\underline n}$, and multiplicativity on disjoint unions, this identity supplies a coherent calculus for exact chromatic counts. The theory explains boundary cases, supports recursive computation, and quantifies the effect of individual constraints. Its proofs are finite, bijective, and fully combinatorial: global coloring behavior is resolved by asking, at one edge, whether two colors differ or coincide.
