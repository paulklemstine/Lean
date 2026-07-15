# Pair-to-Edge Thresholds and a Kruskal–Katona Bridge from Triangles to Edges

## Abstract

We study two related counting phenomena for finite simple graphs. First, for a graph with $m>0$ edges and $n$ non-isolated vertices, we analyze the pair-to-edge ratio

$$
T(n,m)=\frac{\binom{n}{2}}{m}.
$$

The universal edge bound and the handshake identity yield the sharp interval

$$
1\leq T(n,m)\leq n-1.
$$

Consequently, every genuine probability $p<1$ automatically satisfies $p<T(n,m)$; equivalently, $pm<\binom{n}{2}$. Thus the bare threshold inequality is non-discriminating throughout the usual strict probability range. Second, we connect graph clique counts to shadows of uniform set families. The family of vertex sets of triangles is $3$-uniform, and its $2$-shadow is contained in the edge set. The Lovász form of the Kruskal–Katona theorem therefore implies that, for $3\leq k\leq n$, at least $\binom{k}{3}$ triangles force at least $\binom{k}{2}$ edges. We give self-contained definitions, proof sketches, sharpness examples, numerical algorithms, applications, and directions for extensions.

## 1. Introduction

Finite simple graphs encode pairwise interaction without loops or multiple edges. Their most basic statistic is the number of edges, yet higher-order structures such as triangles reveal clustering that edge density alone cannot describe. This paper develops two complementary uses of the count $\binom{n}{2}$.

The first concerns the ratio of all available vertex pairs to actual edges. If $n$ denotes the number of relevant vertices and $m$ the number of edges, then $\binom{n}{2}/m$ is the reciprocal of edge density. A proposed condition of the form

$$
p<\frac{\binom{n}{2}}{m}
$$

may appear to impose a substantive upper bound on a probability $p$. In fact, the defining constraints of a simple graph imply that the right-hand side is at least one. Therefore the condition is automatic whenever $p<1$. If every one of the $n$ vertices is non-isolated, the handshake identity also gives a sharp upper endpoint $n-1$ for the ratio.

The second use of $\binom{n}{2}$ is structural. A triangle is a $3$-element vertex set all of whose $2$-element subsets are edges. Passing from each triangle to its constituent pairs is exactly the shadow operation from extremal set theory. The Kruskal–Katona theorem lower-bounds the size of a shadow in terms of the size of a uniform family. This produces a direct graph-theoretic theorem: $\binom{k}{3}$ triangles require at least $\binom{k}{2}$ edges.

These results are linked by a common discipline: count distinct unordered pairs rather than incidences. The threshold analysis compares actual edges with all possible pairs. The triangle analysis compares actual edges with the distinct pairs supporting a family of triples. Both conclusions are sharp, but they have contrasting interpretations. The threshold inequality is too weak to distinguish graph classes, whereas the triangle inequality expresses a genuine extremal obstruction.

## 2. Definitions and notation

### 2.1. Simple graphs

A **finite simple graph** is a pair $G=(V,E)$, where $V$ is a finite set of vertices and $E$ is a set of unordered two-element subsets of $V$. Thus loops and repeated edges are excluded. We write

$$
n=|V|,\qquad m=|E|.
$$

The **degree** $\deg(v)$ of a vertex $v$ is the number of edges containing $v$. A vertex is **isolated** if $\deg(v)=0$ and **non-isolated** otherwise.

The **complete graph** on $n$ vertices contains every possible edge and therefore has $\binom{n}{2}$ edges. A **matching** is a graph in which no two edges share a vertex. A perfect matching on an even number $n$ of vertices has $n/2$ edges and no isolated vertices.

A **triangle** is a three-element set $B\subseteq V$ such that every two-element subset of $B$ is an edge. More generally, an $r$-clique is an $r$-element vertex set inducing a complete graph.

### 2.2. Binomial coefficients

For nonnegative integers $n$ and $r$, the binomial coefficient $\binom{n}{r}$ counts the $r$-element subsets of an $n$-element set. In particular,

$$
\binom{n}{2}=\frac{n(n-1)}{2},
$$

or, in a division-free real-valued form,

$$
2\binom{n}{2}=n(n-1).
$$

When $n\geq 2$, this quantity is strictly positive.

### 2.3. The pair-to-edge threshold

For integers $n\geq 0$ and $m>0$, define the **pair-to-edge threshold** by

$$
T(n,m)=\frac{\binom{n}{2}}{m}.
$$

If a simple graph has $n$ vertices and $m$ edges, its edge density is

$$
\rho(G)=\frac{m}{\binom{n}{2}},
$$

provided $n\geq 2$. Hence $T(n,m)=1/\rho(G)$. The threshold is naturally at least one, whereas density naturally lies at most one.

### 2.4. Uniform families and shadows

Let $V$ be finite. A family $\mathcal{F}$ of subsets of $V$ is **$r$-uniform** if every member of $\mathcal{F}$ has cardinality $r$. Its **lower shadow** is

$$
\partial\mathcal{F}
=
\{A\subseteq V: |A|=r-1\text{ and }A\subseteq B
\text{ for some }B\in\mathcal{F}\}.
$$

The shadow records distinct codimension-one faces, not incidences with multiplicity. If $\mathcal{T}(G)$ denotes the family of triangles of $G$, then $\mathcal{T}(G)$ is $3$-uniform and $\partial\mathcal{T}(G)$ is a family of pairs.

## 3. Elementary threshold bounds

We begin by isolating the arithmetic and graph-counting facts governing $T(n,m)$.

### Lemma 3.1 (Pair formula)

For every nonnegative integer $n$, viewed over the real numbers,

$$
2\binom{n}{2}=n(n-1).
$$

**Proof sketch.** There are $n(n-1)$ ordered pairs $(u,v)$ of distinct elements. Each unordered pair $\{u,v\}$ gives exactly two ordered pairs, $(u,v)$ and $(v,u)$. Dividing this double count by two gives the identity. The division-free displayed form also remains valid at $n=0$ and $n=1$.

### Lemma 3.2 (Positivity of the pair count)

If $n\geq 2$, then

$$
\binom{n}{2}>0.
$$

**Proof sketch.** Both factors $n$ and $n-1$ are positive. By Lemma 3.1, twice the binomial coefficient equals their positive product, so the coefficient itself is positive.

### Lemma 3.3 (Universal simple-graph edge bound)

Every finite simple graph on $n$ vertices with $m$ edges satisfies

$$
m\leq \binom{n}{2}.
$$

**Proof sketch.** Each edge is an unordered pair of distinct vertices, and there are exactly $\binom{n}{2}$ such pairs. Because a simple graph contains no repeated edge, its edge set is a subset of the set of all pairs.

### Theorem 3.4 (Threshold lower bound)

If $m>0$ and $m\leq\binom{n}{2}$, then

$$
1\leq T(n,m).
$$

In particular, this holds for every nonempty finite simple graph.

**Proof sketch.** Divide the inequality $m\leq\binom{n}{2}$ by the positive number $m$. The result is $1\leq\binom{n}{2}/m$.

### Theorem 3.5 (Strict edge-budget equivalence)

Let $m>0$ and $p$ be real. Then

$$
p<T(n,m)
$$

if and only if

$$
pm<\binom{n}{2}.
$$

**Proof sketch.** Multiplication by the positive denominator $m$ preserves strict inequalities. This yields both directions immediately.

The theorem is useful computationally because it removes division, but it also clarifies the logical content of the threshold condition: the weighted edge count $pm$ must fit below the total pair budget.

### Corollary 3.6 (Contrarian probability conclusion)

For every nonempty finite simple graph and every real number $p<1$,

$$
p<T(n,m).
$$

**Proof sketch.** Theorem 3.4 gives $1\leq T(n,m)$. Combining $p<1$ with this inequality yields $p<T(n,m)$. Equivalently, $pm<m\leq\binom{n}{2}$.

This conclusion is the central interpretive point: over the usual strict probability range, the threshold hypothesis alone cannot distinguish sparse graphs from dense graphs, connected graphs from disconnected graphs, or clustered graphs from triangle-free graphs.

## 4. The role of non-isolated vertices

The lower endpoint uses only simplicity and nonemptiness. Requiring all vertices to be non-isolated supplies an upper endpoint.

### Lemma 4.1 (Handshake identity)

For every finite simple graph,

$$
\sum_{v\in V}\deg(v)=2m.
$$

**Proof sketch.** Count incidences $(v,e)$ where vertex $v$ lies on edge $e$. Summing by vertices gives the left-hand side. Summing by edges gives $2m$, since every edge has exactly two endpoints.

### Theorem 4.2 (No-isolated-vertices handshake bound)

If all $n$ vertices are non-isolated, then

$$
n\leq 2m.
$$

**Proof sketch.** Non-isolation means $\deg(v)\geq 1$ for every vertex. Therefore

$$
n=\sum_{v\in V}1\leq\sum_{v\in V}\deg(v)=2m,
$$

where the final equality is Lemma 4.1.

### Theorem 4.3 (Threshold upper bound)

Let a nonempty simple graph have $n$ vertices, all non-isolated, and $m$ edges. Then

$$
T(n,m)\leq n-1.
$$

**Proof sketch.** Theorem 4.2 gives $2m\geq n$. Using Lemma 3.1,

$$
T(n,m)
=
\frac{n(n-1)}{2m}
\leq
\frac{n(n-1)}{n}
=n-1.
$$

A nonempty graph with all vertices non-isolated necessarily has $n\geq 2$, so the cancellation by $n$ is legitimate.

### Theorem 4.4 (Sharp threshold interval)

Every nonempty finite simple graph on $n$ non-isolated vertices and with $m$ edges satisfies

$$
1\leq T(n,m)\leq n-1.
$$

Both bounds are sharp.

**Proof sketch.** The lower bound is Theorem 3.4 and the upper bound is Theorem 4.3. For the lower endpoint, the complete graph has $m=\binom{n}{2}$, hence $T=1$. For the upper endpoint, when $n$ is even, a perfect matching has $m=n/2$, hence

$$
T(n,n/2)=\frac{n(n-1)}{n}=n-1.
$$

For odd $n$, no graph in which every degree is one exists, so the upper endpoint need not be attained; the theorem asserts uniform sharpness across the allowed values of $n$.

## 5. A shadow bridge from triangles to edges

We now turn from a universal pair budget to the pair support required by triangles.

### Lemma 5.1 (Uniformity of the triangle family)

For every finite simple graph $G$, the triangle family $\mathcal{T}(G)$ is $3$-uniform.

**Proof sketch.** By definition, every triangle is a set of exactly three vertices satisfying the clique condition. Thus every member has cardinality three.

### Lemma 5.2 (Triangle shadows are edges)

For every finite simple graph $G$,

$$
\partial\mathcal{T}(G)\subseteq E(G).
$$

**Proof sketch.** Take $A\in\partial\mathcal{T}(G)$. Then $A$ is a two-element subset of some triangle $B$. Every pair of vertices in a triangle is adjacent, so $A$ is an edge. This argument also shows why the shadow is the correct set-family operation: deleting any one vertex from a triangle leaves an edge.

### Theorem 5.3 (Kruskal–Katona shadow bound, relevant form)

Let $\mathcal{F}$ be a $3$-uniform family of subsets of an $n$-element set. If $3\leq k\leq n$ and

$$
|\mathcal{F}|\geq\binom{k}{3},
$$

then

$$
|\partial\mathcal{F}|\geq\binom{k}{2}.
$$

**Proof sketch.** The Kruskal–Katona theorem states that among uniform families of a fixed size, initial segments in colexicographic order minimize the lower shadow. At the special binomial size $\binom{k}{3}$, the extremal family consists of all triples from a fixed $k$-element set. Its shadow consists of all pairs from that set and has size $\binom{k}{2}$. Enlarging the family cannot decrease its shadow, so every family of at least that size has a shadow of at least $\binom{k}{2}$ pairs.

The statement can also be viewed as the integer-point case of the Lovász form: if a $3$-uniform family has size at least $\binom{x}{3}$ for a real parameter $x\geq 3$, its shadow has size at least $\binom{x}{2}$. Only integer $x=k$ is needed here.

### Theorem 5.4 (Triangle-to-edge theorem)

Let $G$ be a finite simple graph on $n$ vertices. For every integer $k$ with $3\leq k\leq n$, if $G$ has at least $\binom{k}{3}$ triangles, then $G$ has at least $\binom{k}{2}$ edges:

$$
|\mathcal{T}(G)|\geq\binom{k}{3}
\quad\Longrightarrow\quad
|E(G)|\geq\binom{k}{2}.
$$

**Proof sketch.** By Lemma 5.1, the triangle family is $3$-uniform. Theorem 5.3 therefore gives

$$
|\partial\mathcal{T}(G)|\geq\binom{k}{2}.
$$

Lemma 5.2 places this shadow inside the edge set, so

$$
\binom{k}{2}
\leq |\partial\mathcal{T}(G)|
\leq |E(G)|.
$$

This proves the result.

### Remark 5.5 (Why clique pairs equal graph edges)

A $2$-clique is precisely a two-element set whose two vertices are adjacent. Thus the family of $2$-cliques and the edge set are the same combinatorial collection, even if one chooses to represent edges as unordered pairs and cliques as finite vertex sets. Their cardinalities coincide.

### Sharpness

The complete graph on a selected $k$-vertex subset, with any remaining vertices isolated or attached without reducing the existing counts, contains exactly $\binom{k}{3}$ triangles within that subset and exactly $\binom{k}{2}$ internal edges. Taking the remaining vertices isolated gives equality in Theorem 5.4. Thus neither binomial bound can be increased at the stated hypothesis.

## 6. Algorithms and numerical diagnostics

The results lead to simple exact algorithms. All arithmetic can be performed with integers or rational numbers, avoiding floating-point ambiguity.

### 6.1. Threshold diagnostic

Given $n$, $m$, and a rational $p$, first validate $m>0$ and $m\leq\binom{n}{2}$. Compute

$$
T=\frac{\binom{n}{2}}{m}.
$$

Then test $p<T$ by cross multiplication. If $p=a/b$ with $b>0$, compare

$$
am<b\binom{n}{2}.
$$

The arithmetic requires constant many integer operations once $n$, $m$, $a$, and $b$ are supplied. In bit complexity, multiplication dominates and depends on operand length. The diagnostic should additionally report that $p<1$ makes the condition automatic for every valid nonempty simple graph.

### 6.2. Threshold interval check

For a graph specified by an edge list, one may compute the degree of every vertex in time $O(n+m)$, verify that no degree is zero, and then check

$$
1\leq T\leq n-1.
$$

The graph scan is linear in input size. The lower inequality follows from absence of duplicate or invalid edges; the upper inequality follows from non-isolation.

### 6.3. Triangle-force certificate

Given a triangle count $t$ and edge count $m$, enumerate integers $k$ with $3\leq k\leq n$. Whenever

$$
t\geq\binom{k}{3},
$$

Theorem 5.4 certifies

$$
m\geq\binom{k}{2}.
$$

The strongest integer certificate uses the largest such $k$. Binary search is possible because $\binom{k}{3}$ is increasing for $k\geq 3$, yielding $O(\log n)$ comparisons. For moderate sizes, a linear scan is simpler.

### 6.4. Direct graph enumeration

To demonstrate the theorem on small graphs, enumerate all subsets of the $\binom{n}{2}$ possible edges. For each graph, count edges directly and count triangles by testing all $\binom{n}{3}$ vertex triples. Exhaustive enumeration costs

$$
O\left(2^{\binom{n}{2}}\binom{n}{3}\right),
$$

so it is appropriate only for small $n$. This does not replace the general proof; it illustrates the bound and identifies equality cases in a finite sample.

## 7. Examples

### Example 7.1 (Complete graph)

For the complete graph on $n$ vertices,

$$
m=\binom{n}{2},\qquad T(n,m)=1.
$$

It has $\binom{n}{3}$ triangles. Taking $k=n$ in Theorem 5.4 gives the exact edge count $m\geq\binom{n}{2}$.

### Example 7.2 (Perfect matching)

Let $n$ be even and let the graph be a perfect matching. Then every vertex is non-isolated and

$$
m=\frac{n}{2},\qquad T(n,m)=n-1.
$$

The graph has no triangles. It attains the upper threshold endpoint while lying at the opposite structural extreme from a complete graph.

### Example 7.3 (Ten triangles)

For $k=5$,

$$
\binom{5}{3}=10,
\qquad
\binom{5}{2}=10.
$$

Hence every graph with at least ten triangles has at least ten edges. The complete graph on five vertices attains equality.

### Example 7.4 (Twenty triangles)

For $k=6$,

$$
\binom{6}{3}=20,
\qquad
\binom{6}{2}=15.
$$

Thus twenty triangles force fifteen edges. Counting three edge incidences per triangle would produce sixty incidences, but edges may be reused by many triangles. The shadow argument correctly controls the number of distinct edges.

### Example 7.5 (A probability comparison)

Suppose $n=10$ and $m=15$. Then

$$
T(10,15)=\frac{45}{15}=3.
$$

Every probability $p<1$ lies below this threshold. Even $p=1$ lies below it, illustrating that the ratio may extend far outside the probability scale. The threshold interval gives $1\leq 3\leq 9$.

## 8. Applications

### 8.1. Network clustering

Triangles model local cohesion in social, biological, and information networks. The Triangle-to-Edge Theorem quantifies a minimum pairwise infrastructure required to sustain a prescribed number of cohesive triples. It is independent of how triangles overlap and therefore complements average clustering coefficients, which normalize triangle incidences locally.

### 8.2. Hypergraph projection

A collection of observed three-way interactions can be modeled as a $3$-uniform hypergraph. Its shadow is the graph of pairwise co-occurrences. The shadow theorem says that at least $\binom{k}{3}$ distinct triple interactions necessarily generate at least $\binom{k}{2}$ distinct pairwise interactions. This applies even when no graph was given initially; the graph arises as the projection of the triple system.

### 8.3. Data validation

Suppose a data pipeline reports a triangle count $t$ and an edge count $m$. Choosing any $k$ with $t\geq\binom{k}{3}$ gives a necessary consistency check $m\geq\binom{k}{2}$. Violating the check signals incompatible counts. Similarly, a claimed simple graph with $m>\binom{n}{2}$ or a no-isolated-vertices graph with $2m<n$ is immediately invalid.

### 8.4. Probability-model design

The threshold analysis warns against comparing a probability with an unnormalized reciprocal density. If the desired parameter must live naturally in $[0,1]$, the density $m/\binom{n}{2}$ is generally better scaled than its reciprocal. A nontrivial theorem involving $p<T(n,m)$ must either permit $p\geq 1$, use a nonstandard interpretation of $p$, or combine the inequality with additional structural hypotheses and a meaningful conclusion.

## 9. Discussion

The two principal results differ in depth but reinforce the same conceptual message. Universal ambient constraints should be checked before a ratio is interpreted as a threshold. Since the edge set is contained in the set of all vertex pairs, reciprocal density is automatically at least one. The condition $p<T(n,m)$ therefore cannot by itself drive a phase transition for $p\in[0,1)$.

By contrast, the triangle bound is a genuine extremal statement. A direct incidence argument starts from

$$
3|\mathcal{T}(G)|
=
\sum_{e\in E(G)}\#\{\text{triangles containing }e\},
$$

but without controlling how many triangles may share one edge, this identity does not directly give the sharp edge lower bound. The shadow framework avoids multiplicities and asks for the smallest number of distinct pairs that can support a fixed number of triples. Kruskal–Katona answers exactly that question.

The extremal configuration also explains the theorem geometrically. To minimize the pair shadow of many triples, one should concentrate triples on a small vertex set. All triples on $k$ vertices use all $\binom{k}{2}$ pairs and produce $\binom{k}{3}$ triples. Spreading them more diffusely cannot reduce the set of supporting pairs.

There is also a useful distinction between the roles of isolated vertices. They are irrelevant to the triangle-to-edge implication once the ambient condition $k\leq n$ is satisfied: extra isolated vertices add neither triangles nor edges. In the threshold interval, however, counting isolated vertices would artificially enlarge $\binom{n}{2}$ without increasing $m$. Restricting $n$ to non-isolated vertices ensures the upper bound $n-1$ and gives the ratio a more faithful scale.

## 10. Future work

Several extensions are natural.

First, a truncated motivating claim supplied only the condition $p<T(n,m)$ and omitted its intended conclusion. Any meaningful continuation must specify that conclusion and determine which additional assumptions make it valid. Candidate hypotheses include connectedness, prescribed minimum degree, regularity, expansion, or a particular random-graph model. The present analysis shows that the threshold inequality alone cannot support a nontrivial conclusion for $p<1$.

Second, one can extend the shadow bridge to higher cliques. The family of $r$-cliques is $r$-uniform, and its lower shadow consists of $(r-1)$-cliques. Appropriate Kruskal–Katona bounds therefore relate counts of consecutive clique dimensions. Iterating shadows may connect large cliques directly to edges.

Third, stability questions merit study. If a graph has close to $\binom{k}{3}$ triangles and close to the minimum $\binom{k}{2}$ edges, one expects its triangle-supporting subgraph to resemble a complete graph on roughly $k$ vertices. Quantitative stability would describe how near-equality constrains structure.

Fourth, algorithmic variants can avoid explicit triangle enumeration. Matrix multiplication, adjacency intersections, or degeneracy-oriented methods can count triangles more efficiently in sparse graphs. The resulting counts can be combined with the theorem as certificates.

Finally, one may compare deterministic shadow bounds with random-graph expectations. In an Erdős–Rényi graph with edge probability $q$, expected edge and triangle counts are $q\binom{n}{2}$ and $q^3\binom{n}{3}$, respectively. Understanding when random or pseudorandom graphs approach deterministic extremal boundaries could clarify how concentration and uniformity differ from the compact extremizers of Kruskal–Katona.

## 11. Conclusion

For a nonempty simple graph with $m$ edges and $n$ non-isolated vertices, the pair-to-edge ratio obeys the sharp bounds

$$
1\leq\frac{\binom{n}{2}}{m}\leq n-1.
$$

The lower endpoint makes every condition $p<\binom{n}{2}/m$ automatic when $p<1$, and positive-denominator cross multiplication identifies its equivalent edge-budget form. The upper endpoint follows from the handshake identity and is attained by perfect matchings when $n$ is even.

At a deeper structural level, triangles form a $3$-uniform family whose shadow is contained in the graph’s edge set. Kruskal–Katona therefore yields

$$
|\mathcal{T}(G)|\geq\binom{k}{3}
\quad\Longrightarrow\quad
|E(G)|\geq\binom{k}{2}
$$

for $3\leq k\leq n$, with equality at complete graphs on $k$ vertices. Together, the results show how the same count of unordered pairs can invalidate a superficially strong threshold and certify a genuinely sharp extremal constraint.
