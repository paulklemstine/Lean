# Shadows, Cliques, and Primitive Divisors: Two Finite Structural Forcing Theorems

**Aristotle**  
**July 15, 2026**

## Abstract

This paper presents two self-contained structural results in finite combinatorics and arithmetic. First, the lower-shadow operation on uniform set families is used to transfer the Lovász form of the Kruskal–Katona theorem to graph theory. If a finite simple graph on $n$ vertices has at least $\binom{k}{3}$ triangles, where $3\le k\le n$, then it has at least $\binom{k}{2}$ edges. The mechanism is exact: deleting one vertex from a triangle produces an edge, so the lower shadow of the triangle family embeds in the edge family. The complete graph on $k$ vertices, supplemented by isolated vertices, attains equality. Second, a bounded form of the Fibonacci primitive-divisor theorem is stated and explained: for every $n$ with $13\le n\le10000$, the Fibonacci number $F_n$ has a prime divisor that divides no earlier positive-index Fibonacci number. The proof architecture separates prime and composite indices; for composite indices, a finite primitive-part criterion supplies the new prime. We give definitions, proof sketches, computational algorithms, examples, complexity analyses, applications, limitations, and future research directions. The common theme is structural forcing: a collection of higher-order configurations forces lower-order support, while a recurrence term beyond its inherited factors forces arithmetic novelty.

## 1. Introduction

Two elementary questions motivate this study.

1. How many edges must a graph possess if it contains many triangles?
2. When must a Fibonacci number contain a prime factor that has never appeared earlier in the sequence?

The first question belongs to extremal graph theory. A rough incidence count is immediate: each triangle contains three edges, while each edge lies in at most $n-2$ triangles. Thus a graph with $T$ triangles satisfies $|E|\ge 3T/(n-2)$. This estimate, however, depends on the ambient number of vertices and can be far from sharp when the triangles are concentrated on a smaller active set.

The sharper viewpoint treats triangles as three-element sets and edges as two-element sets. The lower shadow of a family of triples consists of all pairs contained in at least one triple. For graph triangles, every such pair is an edge. The Kruskal–Katona theorem then converts the number of triples directly into a lower bound for the number of supporting pairs. This yields the exact binomial threshold

$$
|\{\text{triangles of }G\}|\ge\binom{k}{3}
\quad\Longrightarrow\quad
|E(G)|\ge\binom{k}{2}.
$$

The second question concerns primitive prime divisors. A prime divisor of $F_n$ is primitive if it divides no $F_j$ with $1\le j<n$. Primitive divisors certify that the arithmetic content of the sequence has genuinely expanded. The result considered here establishes their existence uniformly on the explicit interval $13\le n\le10000$. The upper endpoint is essential: the result is a bounded theorem, not a claim about an untreated infinite tail.

The two theorems are mathematically independent, but they exhibit parallel proof design. In the graph setting, one passes from an object to its forced support by deleting one vertex. In the Fibonacci setting, one removes inherited prime contributions and studies the remaining primitive part. Both isolate a residue of unavoidable structure.

## 2. Set families and lower shadows

### 2.1 Uniform families

Let $V$ be a finite set. A family $\mathcal{A}\subseteq 2^V$ is called **$r$-uniform** if every $S\in\mathcal{A}$ has cardinality $r$. For an $r$-uniform family with $r\ge1$, define its **lower shadow** by

$$
\partial\mathcal{A}
=
\{T\subseteq V: |T|=r-1\text{ and }T\subseteq S
\text{ for some }S\in\mathcal{A}\}.
$$

Equivalently, $T\in\partial\mathcal{A}$ exactly when there are $S\in\mathcal{A}$ and $x\in S$ such that $T=S\setminus\{x\}$.

The lower shadow records all codimension-one faces of the members of $\mathcal{A}$. Distinct sets may produce the same face, so the shadow can be much smaller than the sum of their individual numbers of faces. The central extremal question is to minimize $|\partial\mathcal{A}|$ subject to a lower bound on $|\mathcal{A}|$.

### 2.2 The shadow inequality

We use the following binomial-threshold form of the Kruskal–Katona theorem.

**Theorem 2.1 (Kruskal–Katona, binomial-threshold form).** Let $\mathcal{A}$ be an $r$-uniform family on a finite ground set containing at least $k$ points, with $1\le r\le k$. If

$$
|\mathcal{A}|\ge\binom{k}{r},
$$

then

$$
|\partial\mathcal{A}|\ge\binom{k}{r-1}.
$$

**Proof sketch.** The full Kruskal–Katona theorem states that among all $r$-uniform families of a fixed cardinality, the initial segment in colexicographic order has the smallest lower shadow. At the special cardinality $\binom{k}{r}$, this initial segment is precisely the family of all $r$-subsets of a fixed $k$-element set. Its shadow is the family of all $(r-1)$-subsets of that set and therefore has cardinality $\binom{k}{r-1}$. Monotonicity of the minimum shadow size with respect to family size gives the stated implication. $\square$

For triangles, only $r=3$ is needed:

$$
|\mathcal{A}|\ge\binom{k}{3}
\quad\Longrightarrow\quad
|\partial\mathcal{A}|\ge\binom{k}{2}.
$$

## 3. Graphs, triangles, and edges

### 3.1 Definitions

A **finite simple graph** $G=(V,E)$ consists of a finite vertex set $V$ and a set

$$
E\subseteq\{\{u,v\}:u,v\in V,\ u\ne v\}.
$$

A subset $S\subseteq V$ is a **clique** if every pair of distinct vertices in $S$ is an edge. Write $K_r(G)$ for the family of $r$-vertex cliques of $G$. Then $K_2(G)$ is naturally identical to $E$, and $K_3(G)$ is the triangle family.

### 3.2 The structural bridge

The graph-theoretic content required to invoke the shadow theorem is contained in one lemma.

**Lemma 3.1 (Triangle shadows are edges).** For every finite simple graph $G$,

$$
\partial K_3(G)\subseteq K_2(G)=E.
$$

**Proof.** Let $T\in\partial K_3(G)$. Then $T$ is obtained by deleting one vertex from some three-vertex clique $S$. Hence $T$ has two vertices. Since every two distinct vertices in $S$ are adjacent, the two vertices in $T$ form an edge. Therefore $T\in K_2(G)$. $\square$

This lemma does not assert equality. An edge need not lie in any triangle, so $K_2(G)$ may contain pairs absent from $\partial K_3(G)$. The inclusion is exactly the direction needed for a lower bound.

We also record the elementary counting identification.

**Lemma 3.2 (Two-cliques are edges).** For every finite simple graph $G$,

$$
|K_2(G)|=|E|.
$$

**Proof.** Map each two-vertex clique to its unique unordered pair of vertices. This gives a bijection with the edge set, because a two-element subset is a clique exactly when its two vertices are adjacent. $\square$

### 3.3 Main graph theorem

**Theorem 3.3 (Triangle–edge forcing theorem).** Let $G$ be a finite simple graph on $n$ vertices, and let $k$ be an integer satisfying $3\le k\le n$. If

$$
|K_3(G)|\ge\binom{k}{3},
$$

then

$$
|E|\ge\binom{k}{2}.
$$

**Proof.** The triangle family $K_3(G)$ is $3$-uniform. By Theorem 2.1,

$$
|\partial K_3(G)|\ge\binom{k}{2}.
$$

By Lemma 3.1, $\partial K_3(G)\subseteq K_2(G)$, and hence

$$
\binom{k}{2}
\le |\partial K_3(G)|
\le |K_2(G)|.
$$

Lemma 3.2 identifies $|K_2(G)|$ with $|E|$, proving the claim. $\square$

**Corollary 3.4 (Contrapositive form).** If a graph has fewer than $\binom{k}{2}$ edges, then it has fewer than $\binom{k}{3}$ triangles.

**Proof.** This is the contrapositive of Theorem 3.3. $\square$

### 3.4 Sharpness

**Proposition 3.5 (Equality construction).** For every $n\ge k\ge3$, there is a graph on $n$ vertices with exactly $\binom{k}{3}$ triangles and exactly $\binom{k}{2}$ edges.

**Proof.** Take a complete graph on $k$ vertices and make the remaining $n-k$ vertices isolated. Every triple among the $k$ active vertices is a triangle, and no other triangle exists, giving $\binom{k}{3}$ triangles. Every pair among those vertices is an edge, and there are no other edges, giving $\binom{k}{2}$ edges. $\square$

Thus the threshold in Theorem 3.3 cannot be improved in general.

### 3.5 Comparison with incidence counting

Let $T=|K_3(G)|$ and $m=|E|$. Counting pairs $(e,\tau)$ with edge $e$ contained in triangle $\tau$ gives $3T$ incidences. Since an edge can be extended to a triangle by choosing at most one of the remaining $n-2$ vertices,

$$
3T\le(n-2)m,
$$

or

$$
m\ge\frac{3T}{n-2}.
$$

At $T=\binom{k}{3}$ this becomes

$$
m\ge\frac{k(k-1)(k-2)}{2(n-2)}.
$$

The shadow theorem instead gives $m\ge k(k-1)/2$. The ratio between the latter and the former is $(n-2)/(k-2)$, which can be large. Shadow minimization is insensitive to isolated or otherwise irrelevant ambient vertices and therefore captures concentration much more effectively.

## 4. Fibonacci numbers and primitive prime divisors

### 4.1 Fibonacci divisibility

Define the Fibonacci sequence by

$$
F_0=0,\qquad F_1=1,\qquad F_{n+2}=F_{n+1}+F_n.
$$

A basic structural identity is

$$
\gcd(F_m,F_n)=F_{\gcd(m,n)}.
$$

In particular, if $d\mid n$, then $F_d\mid F_n$. Thus factors may propagate from earlier terms to later ones according to divisibility among indices.

**Definition 4.1 (Primitive prime divisor).** Let $n\ge1$. A prime $p$ is a primitive prime divisor of $F_n$ if

$$
p\mid F_n
$$

and, for every integer $j$ with $1\le j<n$,

$$
p\nmid F_j.
$$

The condition refers to the first positive index at which $p$ divides the sequence. It is stronger than merely asking for a prime factor of $F_n$.

### 4.2 Primitive parts

For explanatory purposes, define the **primitive part** of $F_n$ as the largest divisor of $F_n$ supported on prime-power contributions not wholly accounted for by earlier positive-index terms. One may implement this by factoring $F_n$ and retaining precisely those prime factors whose rank of apparition is $n$, where the rank of apparition of a prime $p$ is

$$
z(p)=\min\{j\ge1:p\mid F_j\}.
$$

Then the primitive part is greater than $1$ exactly when $F_n$ has a primitive prime divisor.

**Lemma 4.2 (Primitive-part criterion).** If the primitive part of $F_n$ is greater than $1$, then $F_n$ has a primitive prime divisor.

**Proof.** Choose any prime $p$ dividing the primitive part. By construction, $p\mid F_n$, while $p$ is not supported by any earlier positive-index term. Hence $p\nmid F_j$ for all $1\le j<n$. $\square$

### 4.3 The bounded primitive-divisor theorem

**Theorem 4.3 (Fibonacci primitive divisors through index $10000$).** For every integer $n$ such that

$$
13\le n\le10000,
$$

there exists a prime $p$ satisfying

$$
p\mid F_n
$$

and

$$
p\nmid F_j\qquad(1\le j<n).
$$

**Proof sketch.** Split into two cases.

If $n$ is prime, the prime-index argument uses the divisibility structure of the Fibonacci sequence to show that for every prime $n\ge13$, $F_n$ contains a prime whose first positive divisibility index is $n$.

If $n$ is composite, establish by exhaustive finite arithmetic over $14\le n\le10000$ that the primitive part of $F_n$ is greater than $1$. Lemma 4.2 then extracts a prime divisor of that primitive part, which is primitive for $F_n$. The prime and composite cases cover the entire interval. $\square$

The bound $n\le10000$ is load-bearing. The theorem should not be read as proving the corresponding assertion for all $n\ge13$ by an infinite argument; it establishes exactly the displayed finite interval.

### 4.4 Examples

At index $13$,

$$
F_{13}=233,
$$

and $233$ is prime. It divides no earlier positive-index Fibonacci number, so it is primitive.

At index $14$,

$$
F_{14}=377=13\cdot29.
$$

The factor $13$ is inherited from $F_7=13$. The factor $29$ is new, so $29$ is a primitive prime divisor of $F_{14}$.

At index $15$,

$$
F_{15}=610=2\cdot5\cdot61.
$$

The factors $2$ and $5$ occur earlier, whereas $61$ does not. Hence $61$ is primitive at index $15$.

These examples illustrate why one must inspect first occurrence rather than simply factor the term.

## 5. Algorithms and computational demonstrations

### 5.1 Triangle and edge enumeration

Represent an undirected graph by a set of normalized pairs $(u,v)$ with $u<v$. To count triangles, enumerate all triples $u<v<w$ and test whether $(u,v)$, $(u,w)$, and $(v,w)$ are edges.

**Algorithm 5.1 (Clique-threshold audit).**

1. Normalize and deduplicate the edge list.
2. Enumerate every three-element vertex subset.
3. Count a triple when all three constituent pairs are edges.
4. For each $k$ with $3\le k\le n$, test whether $T\ge\binom{k}{3}$.
5. Whenever the premise holds, report the guaranteed bound $m\ge\binom{k}{2}$ and compare it with the actual edge count.

With an adjacency matrix or hash set, each triple test takes constant expected time, so the running time is $O(n^3)$ and storage is $O(n^2)$ in the dense representation or $O(m)$ with a hash set. Faster triangle-counting methods are available for sparse graphs, but cubic enumeration is transparent and sufficient for demonstrations.

### 5.2 Primitive-divisor search

For moderate indices, compute $F_1,\ldots,F_n$, factor $F_n$, and test each distinct prime factor against earlier terms.

**Algorithm 5.2 (First-occurrence divisor search).**

1. Generate Fibonacci numbers through $F_n$ by recurrence.
2. Factor $F_n$ by trial division or a stronger integer-factorization method.
3. For each distinct prime factor $p$, scan $F_1,\ldots,F_{n-1}$.
4. Return $p$ if no earlier term is divisible by it.

Fibonacci generation requires $O(n)$ big-integer additions. Naive trial division up to $\sqrt{F_n}$ is exponential in the bit length and is suitable only for small demonstrations. The divisibility scan uses $O(n)$ modular reductions per candidate. A scalable implementation would use fast doubling for Fibonacci evaluation, ranks of apparition, and modern factorization algorithms.

### 5.3 Demonstration scope

Numerical examples serve two purposes: they show equality in the graph theorem through a complete active core, and they display primitive factors at selected Fibonacci indices. They do not replace the shadow argument or the finite-range arithmetic theorem. In particular, checking selected indices is an illustration rather than a proof of all $9988$ cases from $13$ through $10000$.

## 6. Applications

### 6.1 Network motif certification

Triangles model clustered interaction. In social networks they represent mutually connected triples; in communication networks they represent local redundancy; in biological networks they can represent three-way patterns of pairwise interaction. Theorem 3.3 gives a certificate of minimum pairwise infrastructure from a motif count. Unlike the incidence estimate, it remains strong when the active cluster occupies only a small part of a large network.

### 6.2 Database and hypergraph projections

A database of ternary relationships can be viewed as a $3$-uniform hypergraph. Its pairwise projection is the lower shadow. Theorem 2.1 says that at least $\binom{k}{3}$ distinct ternary records force at least $\binom{k}{2}$ distinct projected pairs. The graph theorem is the special case in which every recorded triple must be a triangle in an underlying pairwise network.

### 6.3 Arithmetic novelty and recurrence diagnostics

Primitive divisors identify the first appearance of prime moduli in a recurrence. If $p$ is primitive for $F_n$, then the Fibonacci sequence modulo $p$ reaches zero for the first time at index $n$. Such primes therefore encode exact information about modular periods and ranks of apparition. Bounded primitive-divisor certification can also serve as a diagnostic for computational tables of recurrence factorizations.

### 6.4 Exact witnesses

Both theorems provide witness-oriented conclusions. In the graph setting, the lower shadow explicitly lists supporting edges. In the Fibonacci setting, the conclusion supplies a particular prime $p$ and a checkable property: $p$ divides $F_n$ but none of the preceding positive-index terms. This makes the results suitable for certificate-producing algorithms.

## 7. Discussion and limitations

The graph result is universal and exact at binomial thresholds. It does not characterize all equality cases, nor does it provide the sharp minimum number of edges for every arbitrary triangle count $T$ not equal to a binomial coefficient. The full Kruskal–Katona binomial representation can refine the bound for general $T$, and stability questions can ask whether near equality forces a graph to resemble a complete graph on an active core.

The Fibonacci result is deliberately bounded. Its statement includes $n\le10000$, and no extrapolation beyond that interval follows from the finite verification used for composite indices. A complete unbounded treatment would require a quantitative growth argument controlling the part of $F_n$ explainable by earlier terms.

The phrase “primitive part” also deserves care in implementations because prime powers can interact with valuations. For merely finding a primitive prime, it is enough to factor $F_n$ and test each prime’s first occurrence. For multiplicity-sensitive statements, one must track exact $p$-adic valuations.

Finally, although both results feature a reduction to essential support, there is no claim that their theories are formally equivalent. The comparison is conceptual: shadow formation and removal of inherited factors each expose unavoidable structure.

## 8. Future work

Several extensions are natural.

For graphs, one may replace triangles by $r$-cliques. Deleting one vertex from an $r$-clique leaves an $(r-1)$-clique, so the same shadow mechanism suggests

$$
|K_r(G)|\ge\binom{k}{r}
\quad\Longrightarrow\quad
|K_{r-1}(G)|\ge\binom{k}{r-1}.
$$

One may also seek exact bounds for non-binomial clique counts and classify near-extremal graphs.

For Fibonacci numbers, the principal task is to replace the finite composite-index check by a transparent infinite-tail estimate, thereby extending the stated interval. More refined work could compute primitive parts with multiplicity, characterize the ranks of apparition of the resulting primes, and generalize the analysis to Lucas sequences and other divisibility sequences.

A computational direction is to develop efficient certificate generators. For graphs, sparse matrix multiplication and degeneracy orderings can count triangles at scale while retaining the edge-shadow witness. For recurrences, fast doubling, modular rank tests, and modern factorization can produce compact primitive-divisor certificates at much larger indices.

## 9. Further structural consequences

The shadow viewpoint also yields useful monotonicity. Adding edges to a graph can create triangles but cannot destroy any existing triangle or shadow pair. Conversely, deleting vertices outside every triangle leaves both the triangle family and its shadow unchanged. These observations explain why the theorem naturally measures an active combinatorial core rather than the ambient graph order. If the graph contains many isolated vertices, neither the premise nor the sharp conclusion changes.

A related inverse question asks what can be inferred when the number of edges is close to $\binom{k}{2}$ and the number of triangles is close to $\binom{k}{3}$. The equality construction suggests concentration on approximately $k$ vertices. Proving a quantitative stability theorem would require controlling not only shadow cardinality but also the shape of nearly minimal-shadow families. Such a result could distinguish networks whose clustering is genuinely localized from networks with the same motif count spread diffusely across many vertices.

On the arithmetic side, a primitive prime $p$ for $F_n$ gives an exact first-zero certificate modulo $p$. Namely, $F_n\equiv0\pmod p$, while $F_j\not\equiv0\pmod p$ for $1\le j<n$. This immediately implies that the rank of apparition $z(p)$ equals $n$. Thus Theorem 4.3 can equivalently be read as saying that every integer $n$ in the interval $13\le n\le10000$ occurs as the rank of apparition of at least one prime. This reformulation connects factor novelty with the modular dynamics of the Fibonacci recurrence.

The witness can be checked without storing all earlier Fibonacci integers. Starting from $(F_0,F_1)=(0,1)$ modulo $p$, iterate the recurrence and verify that the first zero occurs at step $n$. This uses $O(n)$ modular additions and constant working memory. Once a candidate $p$ is supplied, checking the certificate is therefore much easier than discovering the factor by factoring the full integer $F_n$. The distinction between expensive discovery and efficient verification is important in computational number theory.

## 10. Conclusion

The lower shadow turns triangle abundance into an exact edge lower bound: at least $\binom{k}{3}$ triangles force at least $\binom{k}{2}$ edges. The proof is short because the correct translation makes the geometry explicit—every two-face of a triangle is an edge—and Kruskal–Katona supplies the optimal set-family estimate.

The Fibonacci theorem asserts a different form of forced novelty: every $F_n$ with $13\le n\le10000$ has a prime factor absent from all earlier positive-index terms. Prime and composite indices require different arguments, with a primitive-part criterion organizing the composite case.

Together, the results illustrate how a carefully chosen reduction can reveal structure that elementary counting alone obscures. Shadows expose necessary support; primitive divisors expose necessary novelty.