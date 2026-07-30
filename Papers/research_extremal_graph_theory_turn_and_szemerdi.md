# Extremal Graphs, Set-Family Shadows, and Arithmetic Progressions

**Aristotle**

**July 30, 2026**

## Abstract

This paper presents a self-contained account of five linked results in extremal combinatorics. First, the exact Turán number for a forbidden complete graph is expressed by the edge count of a balanced complete multipartite graph, including the residue correction when the number of parts does not divide the number of vertices; the usual real-valued density bound follows. Second, the Kruskal–Katona theorem is stated in colexicographic form, together with minimization of iterated lower shadows and the numerical Lovász consequence. Third, Szemerédi’s regularity lemma is formulated as an equitable partition theorem whose bound is uniform in the order of the graph. Fourth, the triangle removal lemma is given both as a repair theorem and as a supersaturation statement for graphs far from triangle-free. Finally, Roth’s theorem is stated in finite-density, witness, and asymptotic extremal forms. Proof sketches emphasize the common mechanisms: symmetrization, compression, energy increment, counting, removal, and arithmetic encoding. Algorithms for evaluating extremal quantities and exploring finite examples are also described.

## 1. Introduction

Extremal combinatorics studies the maximum size of a finite object that avoids a prescribed configuration. A graph may avoid a complete subgraph, a family of sets may be constrained by the size of its boundary, and a set of integers may avoid equally spaced triples. The guiding phenomenon is that sufficiently high density forces structure.

The results considered here occupy several levels of precision. Turán’s theorem gives an exact finite maximum. Kruskal–Katona gives an exact structural minimizer for shadows. Szemerédi regularity replaces exact structure by a bounded statistical model. Triangle removal translates a small number of local obstructions into a small global edit distance. Roth’s theorem concludes that positive density in an initial interval of the integers forces a nontrivial three-term arithmetic progression.

These levels are complementary. Exact extremal theorems identify optimal configurations when the forbidden pattern is rigid enough. Compression theorems control the boundary of high-dimensional set systems. Regularity is useful when no concise exact description exists. Removal principles then make regularity operational: if a graph is far from satisfying a hereditary-looking property such as triangle-freeness, it must contain many witnesses. Arithmetic encodings carry these graph-theoretic conclusions to additive patterns.

Throughout, all graphs are finite, simple, and undirected. For a finite set $X$, its cardinality is denoted $|X|$, and $\binom{a}{b}$ denotes a binomial coefficient. The interval $[N]$ will mean $\{0,1,\dots,N-1\}$ when arithmetic progressions are discussed.

## 2. Graph-theoretic preliminaries

### 2.1. Cliques and extremal numbers

A **simple graph** $G=(V,E)$ consists of a finite vertex set $V$ and a set $E$ of two-element subsets of $V$. A set $S\subseteq V$ is a **clique** if every two distinct vertices of $S$ form an edge. The complete graph on $r$ vertices is denoted $K_r$. The graph $G$ is **$K_r$-free** if it has no clique of cardinality $r$.

The **extremal number** $\operatorname{ex}(n,K_r)$ is the maximum of $|E(G)|$ over all $K_r$-free graphs on $n$ vertices.

A graph is **complete $t$-partite** if its vertices can be partitioned into $t$ independent sets and every pair of vertices in different parts is adjacent. The **Turán graph** $T_t(n)$ is the complete $t$-partite graph whose part sizes differ by at most one. If

$$
n=qt+s,\qquad 0\le s<t,
$$

then $T_t(n)$ has $s$ parts of size $q+1$ and $t-s$ parts of size $q$.

### 2.2. Edge density and regular pairs

For disjoint nonempty vertex sets $X,Y\subseteq V(G)$, let $e_G(X,Y)$ be the number of edges with one endpoint in $X$ and the other in $Y$. Their **edge density** is

$$
d_G(X,Y)=\frac{e_G(X,Y)}{|X||Y|}.
$$

For $\varepsilon>0$, the pair $(X,Y)$ is **$\varepsilon$-regular** if for every $X'\subseteq X$ and $Y'\subseteq Y$ satisfying $|X'|\ge\varepsilon|X|$ and $|Y'|\ge\varepsilon|Y|$, one has

$$
|d_G(X',Y')-d_G(X,Y)|<\varepsilon.
$$

A vertex partition is **equitable** if the sizes of any two parts differ by at most one. A partition into $m$ parts is **$\varepsilon$-uniform** if all but at most $\varepsilon m^2$ ordered pairs of distinct parts are $\varepsilon$-regular. Equivalent conventions using unordered pairs change only harmless normalization constants.

### 2.3. Triangle-freeness and edit distance

A **triangle** is a clique of order $3$. A graph on $n$ vertices is **$\varepsilon$-far from triangle-free** if at least $\varepsilon n^2$ edge deletions are required to make it triangle-free. Since deleting edges cannot create triangles, additions are unnecessary for this property.

## 3. Turán’s theorem

The balanced multipartite construction is automatically $K_r$-free when it has $r-1$ parts: among any $r$ vertices, two lie in the same independent part. Turán’s theorem says this construction is optimal.

### Theorem 3.1 (Exact Turán theorem)

Let $n,r$ be integers with $r\ge2$, and put

$$
s=n\bmod(r-1),\qquad 0\le s<r-1.
$$

Then the maximum number of edges in a $K_r$-free graph on $n$ vertices is

$$
\operatorname{ex}(n,K_r)
=
\frac{\bigl(n^2-s^2\bigr)(r-2)}{2(r-1)}+\binom{s}{2}.
$$

This number is the edge count of the balanced complete $(r-1)$-partite graph $T_{r-1}(n)$.

#### Proof sketch

The standard symmetrization argument begins with an extremal $K_r$-free graph. If two nonadjacent vertices $u$ and $v$ have unequal degrees, replace the lower-degree vertex by a twin of the higher-degree vertex: remove its incident edges and connect it to precisely the neighbors of the other. This does not decrease the edge count. It also preserves $K_r$-freeness, because a newly created clique using the cloned vertex would correspond to a clique using its model.

Applying this operation consistently, including a tie-breaking version for equal degrees, transforms an extremal graph into a complete multipartite graph without losing edges. Such a graph can have at most $r-1$ nonempty parts, since selecting one vertex from each of $r$ parts would form $K_r$.

For fixed $n$ and number of parts, the number of edges is

$$
\sum_{i<j}n_i n_j
=\frac12\left(n^2-\sum_i n_i^2\right),
$$

where $n_i$ are the part sizes. If two part sizes differ by at least $2$, moving one vertex from the larger part to the smaller decreases $\sum_i n_i^2$ and hence increases the edge count. Thus all part sizes differ by at most one. The extremal graph is therefore $T_{r-1}(n)$.

To count its edges, set $t=r-1$ and write $n=qt+s$. The sum of squared part sizes is

$$
s(q+1)^2+(t-s)q^2.
$$

Substitution into $\frac12(n^2-\sum_i n_i^2)$ and algebraic simplification yield the stated residue formula.

### Corollary 3.2 (Turán density bound)

Every $K_r$-free graph $G$ on $n$ vertices, where $r\ge2$, satisfies

$$
|E(G)|\le
\left(1-\frac{1}{r-1}\right)\frac{n^2}{2}.
$$

#### Proof sketch

For $t=r-1$, the balanced complete $t$-partite graph satisfies

$$
|E(T_t(n))|=\frac12\left(n^2-\sum_{i=1}^{t}n_i^2\right).
$$

Cauchy’s inequality gives $\sum_i n_i^2\ge n^2/t$, so

$$
|E(T_t(n))|\le\frac12\left(1-\frac1t\right)n^2.
$$

Theorem 3.1 transfers this bound to every $K_r$-free graph. Equality in the smooth bound occurs when $t$ divides $n$.

### Example 3.3

For $n=10$ and $r=4$, there are $t=3$ parts and $s=1$. The balanced part sizes are $4,3,3$, so the extremal edge count is

$$
4\cdot3+4\cdot3+3\cdot3=33.
$$

The smooth bound gives $\frac23\cdot\frac{100}{2}=100/3$, confirming the integer bound $33$.

## 4. Uniform set families and their shadows

Let $[n]=\{1,2,\dots,n\}$. A family $\mathcal A\subseteq\binom{[n]}{r}$ is **$r$-uniform**. Its **lower shadow** is

$$
\partial\mathcal A
=
\left\{B\in\binom{[n]}{r-1}: B\subset A\text{ for some }A\in\mathcal A\right\}.
$$

Define the iterated shadows recursively by $\partial^0\mathcal A=\mathcal A$ and $\partial^{i+1}\mathcal A=\partial(\partial^i\mathcal A)$.

For distinct finite sets $A$ and $B$, the **colexicographic order** declares $A<_{\mathrm{colex}}B$ if the greatest element of $A\triangle B$ belongs to $B$. An **initial colex segment** consists of the first prescribed number of $r$-sets in this order.

### Theorem 4.1 (Kruskal–Katona)

Let $\mathcal A\subseteq\binom{[n]}{r}$, and let $\mathcal C$ be an initial colex segment of $r$-subsets of $[n]$ satisfying $|\mathcal C|\le|\mathcal A|$. Then

$$
|\partial\mathcal C|\le|\partial\mathcal A|.
$$

Thus, among uniform families of a given cardinality, initial colex segments minimize the lower shadow.

#### Proof sketch

One applies a sequence of compressions. A compression replaces a larger label by a smaller available label whenever this replacement creates a set not already in the family. It preserves the cardinality and uniformity of the family and does not increase its shadow. Repeated compressions produce a left-compressed family.

The compressed family is analyzed by splitting according to the largest ground-set element and applying induction on $n$ and $r$. The binomial representation of the family size tracks how many complete layers occur. Colexicographic initial segments realize precisely this representation, and their shadows inherit the shifted binomial coefficients. The induction proves that no other family has fewer shadow members.

### Theorem 4.2 (Iterated Kruskal–Katona)

Under the hypotheses of Theorem 4.1, for every integer $i\ge0$ for which the iterated shadow is defined,

$$
|\partial^i\mathcal C|\le|\partial^i\mathcal A|.
$$

#### Proof sketch

Apply Theorem 4.1 first to $\mathcal A$ and $\mathcal C$. The shadow of a colex initial segment is again a colex initial segment at the next lower rank. Reapply the theorem to the two shadows and iterate. Cardinality inequalities are preserved at each stage.

### Theorem 4.3 (Lovász form of Kruskal–Katona)

Let $0\le i\le r\le k\le n$. If $\mathcal A\subseteq\binom{[n]}{r}$ and

$$
|\mathcal A|\ge\binom{k}{r},
$$

then

$$
|\partial^i\mathcal A|\ge\binom{k}{r-i}.
$$

#### Proof sketch

Take $\mathcal C$ to be the first $\binom{k}{r}$ sets in colex order. These are exactly the $r$-subsets of the first $k$ ground elements. Their $i$-fold shadow consists of all $(r-i)$-subsets of those $k$ elements and therefore has size $\binom{k}{r-i}$. Theorem 4.2 gives the required lower bound.

### Remark 4.4 (Clique-shadow interpretation)

If the $t$-cliques of a graph are regarded as a $t$-uniform set family, every lower face of a clique is itself a clique. Consequently, shadow estimates relate counts of large cliques to counts of smaller cliques. Care is needed because the shadow of the family of all $t$-cliques need not equal the entire family of smaller cliques, but it is contained in it, which is the direction required for lower bounds.

## 5. Szemerédi regularity

Regularity is a structural approximation theorem. It does not claim that every large graph is close to one exact model. Instead, it partitions the graph into a bounded number of cells so that almost every pair of cells behaves pseudorandomly at large scales.

### Theorem 5.1 (Szemerédi’s regularity lemma)

For every $\varepsilon>0$ and every positive integer $\ell$, there exists an integer $M(\varepsilon,\ell)$ with the following property. Every finite graph $G$ with at least $\ell$ vertices admits an equitable partition

$$
V(G)=V_1\sqcup\cdots\sqcup V_m
$$

such that

$$
\ell\le m\le M(\varepsilon,\ell)
$$

and all but at most $\varepsilon m^2$ ordered pairs $(V_i,V_j)$ with $i\ne j$ are $\varepsilon$-regular.

#### Proof sketch

For a partition $\mathcal P=\{V_1,\dots,V_m\}$, define its energy by a weighted mean of squared pair densities,

$$
q(\mathcal P)
=
\frac{1}{|V(G)|^2}
\sum_{i,j}|V_i||V_j|d_G(V_i,V_j)^2.
$$

This quantity lies between $0$ and $1$. Refining a partition cannot decrease energy, by convexity of the square function.

If the partition is not $\varepsilon$-uniform, many pairs $(V_i,V_j)$ fail regularity. For every irregular pair choose witness subsets on which density differs by at least $\varepsilon$. Refine each cell according to membership in the relevant witnesses, then rebalance into an equitable refinement. The witness inequalities imply an energy increment bounded below by a positive function of $\varepsilon$, independent of the order of the graph.

Since energy is at most $1$, only finitely many refinement rounds can occur. The number of parts may grow very rapidly at each round, but it is bounded recursively in terms of $\varepsilon$ and $\ell$ alone. The process stops at an equitable $\varepsilon$-uniform partition.

### 5.2. Reduced graphs and counting

Given a regular partition and a density threshold $d>0$, form a **reduced graph** whose vertices are the partition classes and whose edges correspond to $\varepsilon$-regular pairs of density at least $d$. The reduced graph is a coarse model with bounded order.

A typical counting lemma says that if three partition classes form a triangle in the reduced graph and the three corresponding pairs are regular with densities bounded below, then the original graph contains many triangles with one vertex in each class. The reason is that regularity makes typical vertices have approximately the expected number of neighbors in the other classes; intersecting these large neighborhoods produces many closing edges.

The exact numerical bounds can be weak, and the regularity bound $M(\varepsilon,\ell)$ is enormous. Nevertheless, its independence from $|V(G)|$ is the essential qualitative feature.

## 6. Triangle removal

### Theorem 6.1 (Triangle removal lemma)

For every $\varepsilon>0$, there exists $\delta>0$ such that every finite graph $G$ on $n$ vertices with fewer than $\delta n^3$ triangles contains a spanning triangle-free subgraph $G'\subseteq G$ satisfying

$$
|E(G)|-|E(G')|<\varepsilon n^2.
$$

In other words, fewer than $\varepsilon n^2$ edge deletions suffice to remove all triangles.

#### Proof sketch

Choose regularity parameters much smaller than $\varepsilon$ and apply Theorem 5.1. Delete edges of three types: edges inside partition classes, edges between irregular pairs, and edges between regular pairs whose density is below a small threshold. Equitability and the parameter choices ensure that fewer than $\varepsilon n^2$ edges are deleted in total.

If the remaining graph contained a triangle, its vertices would lie in three distinct classes, and each of the three class pairs would be regular and have density above the threshold. The triangle counting lemma would then yield at least $\delta n^3$ triangles in the original graph, for some positive $\delta$ determined by the fixed parameters. This contradicts the assumed triangle count. Therefore the remaining graph is triangle-free.

### Corollary 6.2 (Many triangles in a far graph)

For every $\varepsilon>0$, there exists $\delta>0$ such that every graph on $n$ vertices that is $\varepsilon$-far from triangle-free contains at least

$$
\delta n^3
$$

triangles.

#### Proof sketch

This is the contrapositive of Theorem 6.1. If the graph had fewer than $\delta n^3$ triangles, fewer than $\varepsilon n^2$ deletions would make it triangle-free, contrary to its assumed distance.

### 6.3. Algorithmic application: property testing

The contrapositive gives a constant-query randomized test. Sample uniformly random triples of vertices and check whether each spans a triangle. If the graph is triangle-free, the test never rejects incorrectly. If it is $\varepsilon$-far from triangle-free, at least a constant fraction proportional to $\delta$ of vertex triples are triangles. After $O(\delta^{-1}\log(1/\eta))$ independent samples, a triangle is found with probability at least $1-\eta$. The query count depends on $\varepsilon$ and the desired error probability, but not on $n$.

## 7. Roth’s theorem on three-term arithmetic progressions

A triple $(a,b,c)$ of integers is a **three-term arithmetic progression** if

$$
a+c=2b.
$$

It is **nontrivial** if $a\ne b$; the displayed equation then also forces $b\ne c$. A set is **three-progression-free** if it contains no nontrivial such triple.

Define the extremal function

$$
R(N)=\max\bigl\{|A|:A\subseteq[N]\text{ is three-progression-free}\bigr\}.
$$

### Theorem 7.1 (Roth’s theorem, finite-density form)

For every real number $\varepsilon>0$, there exists a threshold $N_0(\varepsilon)$ such that, whenever $N\ge N_0(\varepsilon)$ and

$$
A\subseteq[N],\qquad |A|\ge\varepsilon N,
$$

there exist $a,b,c\in A$ satisfying

$$
a+c=2b,\qquad a\ne b.
$$

#### Proof sketch

One route passes through a multidimensional corners theorem, itself obtained by a removal argument. Embed the one-dimensional set into a two-dimensional grid using a construction in which a corner

$$
(x,y),\quad (x+d,y),\quad (x,y+d),\qquad d\ne0,
$$

corresponds to three elements of $A$ satisfying an additive relation. A dense subset of a sufficiently large grid determines an auxiliary tripartite graph with many edge-disjoint triangles. Triangle removal implies that the auxiliary graph contains many triangles in total. The encoding is arranged so that a triangle beyond the designated trivial ones yields a nonzero corner, and the corner decodes to a nontrivial arithmetic progression in $A$.

Boundary losses and the conversion between one- and two-dimensional densities require a smaller working density, commonly a fixed fraction of $\varepsilon$. Once $N$ exceeds the resulting corner-theorem threshold, the construction produces the desired witnesses.

### Corollary 7.2 (Asymptotic extremal form)

The largest three-progression-free subset of $[N]$ has vanishing relative density:

$$
R(N)=o(N).
$$

Equivalently,

$$
\lim_{N\to\infty}\frac{R(N)}{N}=0.
$$

#### Proof sketch

If the ratio did not tend to zero, there would be some $\varepsilon>0$ and arbitrarily large $N$ for which $R(N)\ge\varepsilon N$. An extremal progression-free set of that size would contradict Theorem 7.1 once $N\ge N_0(\varepsilon)$.

Conversely, the little-$o$ statement implies the density formulation: for fixed $\varepsilon>0$, eventually $R(N)<\varepsilon N$, so every set of size at least $\varepsilon N$ contains a nontrivial progression.

### Example 7.3

The set $\{0,1,3,4\}\subseteq[5]$ does not contain the candidate progression $(0,2,4)$ because $2$ is absent; however, checking that one candidate alone does not settle progression-freeness. Exhaustive finite checking must inspect every pair of possible endpoints whose sum is even. For a set $A$, one may enumerate $a<c$ in $A$, set $b=(a+c)/2$ when $a+c$ is even, and report a progression exactly when $b\in A$. Such enumeration illustrates the definition but does not replace Roth’s asymptotic argument.

## 8. Computational procedures

The central theorems are structural, but several finite aspects admit transparent algorithms.

### 8.1. Exact Turán evaluation

Given $n$ and $r\ge2$, set $t=r-1$, compute $s=n\bmod t$, and return

$$
\frac{(n^2-s^2)(t-1)}{2t}+\binom{s}{2}.
$$

Integer divisibility is guaranteed by the combinatorial derivation. The running time is $O(1)$ in the unit-cost arithmetic model and polynomial in the bit lengths under bit complexity.

A constructive variant forms part sizes $q+1$ repeated $s$ times and $q$ repeated $t-s$ times, where $q=\lfloor n/t\rfloor$. Summing all cross-products independently checks the formula.

### 8.2. Shadow generation

For an $r$-uniform family $\mathcal A$, generate its lower shadow by deleting each of the $r$ elements from every member and inserting the resulting $(r-1)$-set into a hash set. For $m=|\mathcal A|$, this requires $O(mr)$ generated faces, with representation-dependent hashing costs. Iterating this process computes $\partial^i\mathcal A$.

To generate a colex initial segment on a small ground set, sort all $r$-subsets by their colex rank or comparison key and select the first $m$. Comparing its shadow with arbitrary families provides finite demonstrations of Theorem 4.1.

### 8.3. Progression search and finite extremal enumeration

A direct progression search examines every ordered or unordered endpoint pair. With hash-set membership, it runs in $O(|A|^2)$ time and $O(|A|)$ auxiliary space. For small $N$, exhaustive search over all $2^N$ subsets computes $R(N)$ exactly; pruning subsets no larger than the best known candidate improves practice but not the worst-case exponential bound.

These computations are demonstrations rather than proofs of asymptotic claims. Their value lies in exposing extremizers, residue effects, and the difference between finite behavior and eventual density theorems.

## 9. Applications and synthesis

### 9.1. Network design and forbidden clusters

Turán’s theorem gives an exact capacity bound for a pairwise interaction network forbidden from containing a fully mutually connected group of size $r$. The balanced multipartite extremizer describes not just the maximum but an architecture: dense cross-group interaction and no within-group interaction.

### 9.2. Discrete boundaries and data representation

Kruskal–Katona quantifies how many lower-dimensional features a collection of high-dimensional records must expose. In a simplicial complex, chosen $r$-faces force a minimum number of $(r-i)$-faces. Colex order supplies the most economical packing. This perspective is useful whenever storage or enumeration cost is attached to all subfeatures of selected objects.

### 9.3. Graph compression

Regularity represents a massive graph by a bounded matrix of pair densities plus a controlled exceptional set. It is not an efficient compression method in ordinary numerical terms—the theoretical bounds are very large—but it is a decisive conceptual reduction. Statements about all large graphs can be reduced to statements about finitely many reduced graphs for fixed accuracy.

### 9.4. Robustness and local certification

Triangle removal equates global distance with abundance of local certificates. This is the conceptual basis of sublinear property testing: one can detect a graph far from triangle-free without reading all of its edges. Similar removal statements exist for broader fixed patterns and connect extremal graph theory with probabilistic algorithms.

### 9.5. Additive combinatorics

Roth’s theorem shows that positive density in the integers is incompatible with avoiding the simplest nontrivial affine pattern. The proof route through corners and removal demonstrates a general transfer principle: encode arithmetic equations as subgraphs or hypergraphs, apply a combinatorial removal theorem, and decode the resulting configuration.

## 10. Limitations and future directions

The exact Turán result addresses forbidden cliques, but near-extremal structure invites a stability theorem: a $K_r$-free graph with nearly the maximum number of edges should be close in edit distance to the balanced complete $(r-1)$-partite graph.

The shadow results suggest a clique-count hierarchy. If a graph contains many $K_t$ subgraphs, viewing those cliques as a uniform family should force quantitative lower bounds on its $K_s$ subgraphs for $s<t$.

Triangle removal controls ordinary triangles under edge deletion. An induced version would count triples spanning exactly the prescribed induced pattern and permit both additions and deletions of adjacencies. Such a result is subtler because deleting an edge may create a new induced configuration.

Roth’s theorem here is qualitative: $R(N)/N\to0$. A quantitative bound, for example one of the form

$$
R(N)\le C\frac{N}{(\log N)^{1+1/10}}
$$

for sufficiently large $N$, requires considerably sharper harmonic or combinatorial analysis than the qualitative removal route.

Finally, four-term arithmetic progressions naturally lead beyond graph removal to hypergraph removal. Constructing a sufficiently strong finite hypergraph framework would extend the local-to-global method to prove that the largest subset of $[N]$ without a nonzero four-term progression is $o(N)$.

## 11. Conclusion

The five results form a coherent progression. Turán’s theorem gives the exact edge threshold for a forbidden clique and identifies the balanced multipartite extremizer. Kruskal–Katona identifies colex segments as the uniform families with the smallest shadows and supplies exact binomial lower bounds. Szemerédi regularity reduces arbitrary large graphs to bounded pseudorandom pieces. Triangle removal turns a sparse collection of triangles into a cheap repair procedure, or contrapositively turns global distance into many local witnesses. Roth’s theorem transfers this principle to arithmetic and shows that a positive-density subset of a long integer interval must contain three equally spaced elements.

The common theme is that density cannot indefinitely coexist with avoidance. Depending on the setting, the forced structure appears as a clique, a shadow, a regular partition, a robust population of triangles, or an arithmetic progression. Exact optimization, compression, approximation, and removal are therefore not isolated techniques; they are successive tools for making the same extremal principle visible at different scales.
