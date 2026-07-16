# Pair-Star Constructions for Berge-Triangle-Free $3$-Uniform Hypergraphs with Bounded Matching Number

**Aristotle**  
**July 16, 2026**

## Abstract

We study a basic extremal construction for $3$-uniform hypergraphs that simultaneously excludes Berge triangles and prescribes the matching number. Given integers $s,t\ge 0$, take $s$ disjoint vertex pairs and $t$ outside vertices, and form one hyperedge from each pair together with each outside vertex. We prove directly that this pair-star hypergraph has $2s+t$ vertices and $st$ edges, is $3$-uniform and Berge-triangle-free, and has matching number at most $s$. When $s\le t$, its matching number is exactly $s$. We also determine the complete edge-intersection pattern. Substituting $t=n-2s$ yields, for every $n\ge 3s$, an $n$-vertex Berge-triangle-free $3$-uniform hypergraph with matching number exactly $s$ and $s(n-2s)$ edges. Thus the construction establishes the sharp lower-bound side of the anticipated extremal formula. We give explicit construction, recognition, and matching-witness algorithms, discuss applications and computational experiments, and delineate the structural upper-bound and uniqueness questions that remain.

## 1. Introduction

A hypergraph generalizes a graph by allowing an edge to contain more than two vertices. An **$r$-uniform hypergraph** is a pair $\mathcal H=(V,E)$ in which $V$ is a finite vertex set and every member of $E$ is an $r$-element subset of $V$. Uniform hypergraphs model interactions of fixed arity: triples in a $3$-uniform hypergraph can represent three-way collaborations, resource bundles, database transactions, or combinatorial blocks.

To transfer graph patterns into hypergraphs, the Berge notion asks that distinct graph edges be represented by distinct hyperedges containing them. For a graph $G$, a hypergraph contains a **Berge-$G$** if there are injective maps from the vertices and edges of $G$ into the hypergraph’s vertices and hyperedges such that every graph edge is contained in its representing hyperedge. For $G=K_3$, this gives a Berge triangle: three core vertices and three distinct hyperedges, each representing one core pair.

A second fundamental statistic is the matching number. A **matching** is a family of pairwise disjoint hyperedges, and $\nu(\mathcal H)$ denotes the maximum size of a matching in $\mathcal H$. Bounding $\nu(\mathcal H)$ limits how many interactions can occur independently. The problem considered here asks how many edges a Berge-triangle-free $3$-uniform hypergraph can possess when its matching number is bounded by $s$.

The construction developed in this paper is based on $s$ disjoint two-vertex spines. Every edge consists of a complete spine and one vertex from a common outside set. This overlap pattern serves two purposes. First, all edges associated with one spine intersect, so a matching can select at most one of them. Second, the rigid edge type prevents three distinct hyperedges from representing the three sides of a triangle.

Our principal theorem is constructive. For every $n\ge 3s$, it supplies an $n$-vertex example with exactly $s(n-2s)$ edges and matching number exactly $s$. Consequently, any universal extremal upper bound in this range must be at least $s(n-2s)$. The result does not by itself establish that all admissible hypergraphs have at most this many edges, nor does it prove uniqueness of equality cases. Distinguishing these claims is essential: the present work proves feasibility and sharpness of a proposed bound, while the universal comparison requires additional structural inequalities.

The paper is organized as follows. Section 2 fixes definitions. Section 3 introduces the construction and establishes its counts. Section 4 determines all pairwise intersections. Sections 5 and 6 prove the matching and Berge-freeness results. Section 7 specializes the parameters to $n$ vertices. Sections 8 and 9 present algorithms and applications. The final sections discuss limitations and future directions.

## 2. Definitions and extremal framework

### Definition 2.1: Uniform hypergraph

A finite hypergraph is a pair $\mathcal H=(V,E)$, where $V$ is a finite set and $E$ is a set of subsets of $V$. It is **$r$-uniform** if $|e|=r$ for every $e\in E$.

We focus on the case $r=3$, whose members are also called **$3$-graphs**.

### Definition 2.2: Matching and matching number

A subfamily $M\subseteq E$ is a **matching** if

$$
e\cap f=\varnothing
$$

for every two distinct edges $e,f\in M$. The **matching number** is

$$
\nu(\mathcal H)=\max\{|M|:M\subseteq E\text{ is a matching}\}.
$$

The maximum exists because $E$ is finite.

### Definition 2.3: Berge triangle

A **Berge triangle** in $\mathcal H$ consists of distinct core vertices $a,b,c\in V$ and distinct representing hyperedges $e_{ab},e_{bc},e_{ca}\in E$ satisfying

$$
\{a,b\}\subseteq e_{ab},\qquad
\{b,c\}\subseteq e_{bc},\qquad
\{c,a\}\subseteq e_{ca}.
$$

A hypergraph is **Berge-triangle-free** if it contains no such configuration.

The requirement that the representing hyperedges be distinct is crucial. One $3$-edge contains all three pairs among its vertices, but it does not alone form a Berge triangle.

### Definition 2.4: The bounded-matching extremal problem

For fixed $n$ and $s$, consider the maximum number of edges among all $n$-vertex Berge-triangle-free $3$-graphs $\mathcal H$ satisfying $\nu(\mathcal H)\le s$. A construction with $m$ edges proves that this maximum is at least $m$. A universal theorem bounding every admissible $\mathcal H$ by $m$ would prove equality.

## 3. The pair-star construction

Let $s,t\ge 0$. Choose pairwise distinct vertices

$$
u_1,v_1,u_2,v_2,\ldots,u_s,v_s
$$

and a disjoint outside set

$$
X=\{x_1,\ldots,x_t\}.
$$

For $1\le i\le s$, define the spine pair

$$
P_i=\{u_i,v_i\}.
$$

The spine pairs are pairwise disjoint. Define

$$
V_{s,t}=\bigcup_{i=1}^{s}P_i\;\dot\cup\;X
$$

and

$$
E_{s,t}=\{P_i\cup\{x\}:1\le i\le s,\ x\in X\}.
$$

We write $\mathcal P_{s,t}=(V_{s,t},E_{s,t})$ and call it the **pair-star hypergraph**. For convenience, write

$$
e(i,x)=P_i\cup\{x\}.
$$

Each fixed $i$ determines a pair-star $\{e(i,x):x\in X\}$ with common two-vertex spine $P_i$.

### Lemma 3.1: Injective edge parametrization

If $e(i,x)=e(j,y)$, then $i=j$ and $x=y$.

**Proof sketch.** Each edge contains exactly two spine vertices and exactly one outside vertex. Equality of the edges therefore forces equality of their unique outside vertices, so $x=y$. The remaining two-element subsets are $P_i$ and $P_j$. Since the spine pairs are disjoint and separately indexed, $P_i=P_j$ implies $i=j$. Thus $(i,x)\mapsto e(i,x)$ is injective. $\square$

### Theorem 3.2: Uniformity and exact counts

For all $s,t\ge 0$, the hypergraph $\mathcal P_{s,t}$ is $3$-uniform, has exactly $2s+t$ vertices, and has exactly $st$ edges.

**Proof sketch.** Every edge is the disjoint union of a two-element spine pair and one outside vertex, hence has cardinality $3$. The vertex set is the disjoint union of $s$ two-element sets and a $t$-element outside set, so

$$
|V_{s,t}|=2s+t.
$$

There are $s t$ parameter pairs $(i,x)$. By Lemma 3.1, distinct parameter pairs produce distinct edges, giving

$$
|E_{s,t}|=st.
$$

The assertions remain valid in degenerate cases such as $s=0$ or $t=0$, when the edge set is empty. $\square$

## 4. Exact intersection geometry

The pair-star family has a completely explicit pairwise intersection law.

### Theorem 4.1: Edge-intersection formula

For all valid spine indices $i,j$ and outside vertices $x,y$,

$$
|e(i,x)\cap e(j,y)|=
\begin{cases}
3,& i=j\text{ and }x=y,\\
2,& i=j\text{ and }x\ne y,\\
1,& i\ne j\text{ and }x=y,\\
0,& i\ne j\text{ and }x\ne y.
\end{cases}
$$

**Proof sketch.** If $i=j$, the two edges share the spine $P_i$. They are equal when $x=y$, giving intersection size $3$, and otherwise share exactly the two spine vertices. If $i\ne j$, the disjointness of the spine pairs eliminates every spine intersection. The edges then intersect exactly when their unique outside vertices agree, yielding size $1$ if $x=y$ and $0$ otherwise. $\square$

### Corollary 4.2: Different stars meet in at most one vertex

If $i\ne j$, then

$$
|e(i,x)\cap e(j,y)|\le 1.
$$

This local formula is stronger than the global properties needed below. It can also be viewed as a recognition signature: within each star, every two distinct edges intersect in two vertices, while edges assigned to different stars never intersect in more than one vertex.

## 5. Matching number

### Theorem 5.1: Universal matching upper bound inside the construction

Every matching $M\subseteq E_{s,t}$ satisfies

$$
|M|\le s.
$$

**Proof sketch.** Assign each edge $e(i,x)$ in $M$ its spine index $i$. Two distinct matching edges cannot receive the same index, because Theorem 4.1 shows that two distinct edges in the same pair-star share both vertices of $P_i$. Thus the spine-index map is injective on $M$. Since only $s$ indices are available, $|M|\le s$. Equivalently, the pigeonhole principle says that any $s+1$ edges include two from one pair-star, and those two are not disjoint. $\square$

The theorem holds for every $t$. When $t<s$, however, the matching number can be smaller because different chosen edges also need distinct outside vertices.

### Theorem 5.2: Exact matching number

For all $s,t\ge 0$,

$$
\nu(\mathcal P_{s,t})=\min(s,t).
$$

In particular, if $s\le t$, then $\nu(\mathcal P_{s,t})=s$.

**Proof sketch.** Theorem 5.1 gives $\nu\le s$. Every pair of disjoint edges must also use different outside vertices, so the same injectivity argument into $X$ gives $\nu\le t$. Therefore $\nu\le\min(s,t)$.

For the reverse inequality, let $m=\min(s,t)$. Select $m$ distinct spine indices and $m$ distinct outside vertices, pair them bijectively, and take the corresponding edges. Distinct selected edges have different spines and different outside vertices, so Theorem 4.1 gives empty pairwise intersections. They form a matching of size $m$. $\square$

The exact formula slightly strengthens the range-specific statement needed for the extremal specialization. It also clarifies the construction’s two independent bottlenecks: a disjoint family consumes one spine and one outside vertex per edge.

## 6. Exclusion of Berge triangles

We now prove the central structural property.

### Theorem 6.1: Berge-triangle freeness

For every $s,t\ge 0$, the pair-star hypergraph $\mathcal P_{s,t}$ contains no Berge triangle.

**Proof sketch.** Color a vertex **spinal** if it lies in some $P_i$ and **outside** if it lies in $X$. Every hyperedge contains exactly two spinal vertices, which form one complete spine pair, and exactly one outside vertex.

Assume for contradiction that distinct core vertices $a,b,c$ and distinct edges $e_{ab},e_{bc},e_{ca}$ form a Berge triangle.

First, two outside vertices cannot form a represented core pair, because no hyperedge contains two outside vertices. Hence at most one of $a,b,c$ is outside.

If all three core vertices are spinal, each represented pair must lie within a single spine pair: an edge never contains spinal vertices from different spines. Thus $a$ and $b$ lie in one $P_i$, while $b$ and $c$ lie in one $P_j$. Since the spine pairs are disjoint and both contain $b$, they must be the same pair. Then $a,b,c$ would all lie in a two-element set, contradicting their distinctness.

It remains to consider exactly one outside core vertex, say $c\in X$, with $a,b$ spinal. Because $\{a,b\}\subseteq e_{ab}$, the two spinal vertices $a,b$ must be the members of a common spine $P_i$. Any edge containing both $a$ and $c$ must then be $P_i\cup\{c\}$. Likewise, any edge containing both $b$ and $c$ must be the same edge $P_i\cup\{c\}$. Consequently $e_{ca}=e_{bc}$, contradicting the requirement that the three representing hyperedges be distinct.

All possible type distributions lead to contradictions, so no Berge triangle exists. $\square$

The proof exhibits the odd-cycle obstruction encoded by the edge type. Outside-outside pairs cannot occur, cross-spine spinal pairs cannot occur, and a spine pair linked to one outside vertex has only one possible representative for both incident sides.

## 7. The $n$-vertex extremal specialization

The pair-star parameters can be tuned to a prescribed vertex count.

### Theorem 7.1: Extremal lower-bound construction

Let $n,s\ge 0$ satisfy

$$
3s\le n.
$$

Then there exists an $n$-vertex $3$-uniform Berge-triangle-free hypergraph $\mathcal H$ such that

$$
\nu(\mathcal H)=s
$$

and

$$
|E(\mathcal H)|=s(n-2s).
$$

**Proof sketch.** Set

$$
t=n-2s.
$$

The hypothesis $3s\le n$ implies $s\le n-2s=t$. Apply the pair-star construction $\mathcal P_{s,t}$. Theorem 3.2 gives

$$
|V_{s,t}|=2s+t=2s+(n-2s)=n
$$

and

$$
|E_{s,t}|=st=s(n-2s).
$$

Theorem 5.2 gives $\nu(\mathcal P_{s,t})=s$, and Theorem 6.1 gives Berge-triangle freeness. $\square$

### Corollary 7.2: Lower bound for the extremal number

Among $n$-vertex Berge-triangle-free $3$-graphs with matching number at most $s$, the maximum edge count is at least

$$
s(n-2s)
$$

whenever $n\ge 3s$.

**Proof sketch.** The example in Theorem 7.1 is admissible and has the stated edge count. $\square$

### Remark 7.3: Scope of the conclusion

Theorem 7.1 is a lower-bound and sharpness construction. It does not assert the universal inequality

$$
|E(\mathcal H)|\le s(n-2s)
$$

for every admissible $\mathcal H$, and it does not assert that every equality case is isomorphic to $\mathcal P_{s,n-2s}$. Those conclusions require a separate upper-bound proof and equality analysis. The distinction prevents a constructive example from being mistaken for a completed extremal classification.

## 8. Algorithms and computational demonstrations

Although the proofs are structural, the construction supports simple and useful algorithms.

### 8.1 Edge generation

Represent the spine vertices by labels $(i,0)$ and $(i,1)$ and outside vertices by labels $x_j$. Iterate over all $s t$ pairs $(i,j)$ and output

$$
\{(i,0),(i,1),x_j\}.
$$

The running time is $\Theta(st)$ and the output space is $\Theta(st)$ edges, which is optimal because every edge must be emitted. The vertex count and expected edge count can then be checked directly.

### 8.2 Constructing a maximum matching

Let $m=\min(s,t)$. For each $0\le i<m$, choose the edge joining spine $i$ to outside vertex $x_i$. The selected edges have distinct spines and outside vertices, hence are pairwise disjoint. The algorithm takes $\Theta(m)$ time and outputs a maximum matching by Theorem 5.2.

### 8.3 Exhaustive Berge-triangle search

For a small finite hypergraph, one can enumerate every triple of distinct core vertices and every ordered triple of distinct edges. A candidate succeeds if each required core pair lies in its assigned edge. A direct implementation uses time polynomial in the input sizes but high degree, on the order of

$$
O(|V|^3|E|^3)
$$

for the most literal search. Indexing each vertex pair by the set of containing edges substantially improves practical performance. For the pair-star construction, the structural theorem makes search unnecessary, but exhaustive enumeration is valuable as an independent small-instance illustration.

### 8.4 Intersection-profile verification

For every pair of generated edges, compute the intersection size and compare it with Theorem 4.1. This costs $O((st)^2)$ edge-pair checks when edge size is treated as constant. The resulting matrix has diagonal entries $3$, within-star off-diagonal entries $2$, same-outside cross-star entries $1$, and all remaining entries $0$. A heat map of this matrix makes the star blocks visible.

## 9. Examples

### Example 9.1: Three stars on twelve vertices

Set $s=3$ and $n=12$, so $t=n-2s=6$. The construction has $6$ spine vertices and $6$ outside vertices. Its edge count is

$$
|E|=3\cdot 6=18.
$$

The edges $e(1,x_1)$, $e(2,x_2)$, and $e(3,x_3)$ form a matching of size $3$. No matching of size $4$ exists because only three spines are available. The hypergraph is Berge-triangle-free by Theorem 6.1.

### Example 9.2: Boundary case $n=3s$

When $n=3s$, one has $t=s$. There are equally many spines and outside vertices, and

$$
|E|=s^2.
$$

A maximum matching pairs every spine with a different outside vertex, using all vertices exactly once. Thus the boundary construction contains a perfect matching in the hypergraph sense.

### Example 9.3: Fewer outside vertices

Take $s=5$ and $t=2$. The hypergraph still has $10$ edges and remains Berge-triangle-free, but its matching number is $2$, not $5$. Every disjoint edge family needs distinct outside vertices, and only two are present. This illustrates why the condition $t\ge s$, equivalently $n\ge 3s$ after specialization, is needed to realize matching number $s$.

## 10. Applications and conceptual connections

The construction exemplifies **density through controlled overlap**. A large edge family is created by repeatedly using fixed two-vertex resources. This repetition suppresses matchings because edges with a common spine are incompatible. At the same time, the edge syntax is too rigid to support three distinct representatives around a triangle.

In scheduling language, each spine is a two-resource package that every job in one class must reserve, while outside vertices are job-specific third resources. At most one job from each class can belong to a disjoint schedule. In transactional systems, each pair-star represents operations sharing two locks; many operations can be specified, but few can execute with disjoint lock sets. In experimental design, a fixed pair of mandatory conditions can be combined with many third factors without generating the incidence pattern of a Berge triangle.

The intersection formula also suggests a clustering method. Edges intersecting in two vertices should belong to a common pair-star; intersections of size one identify reused outside vertices across stars. Consequently, a noisy or approximate version of the construction might be recoverable from its edge-intersection graph. This perspective is relevant to stability theory: a hypergraph whose edge count is close to $s(n-2s)$ may be expected to display an approximate spine decomposition if the corresponding universal upper bound and stability statement hold.

## 11. Discussion and limitations

The pair-star construction resolves the feasibility side of the $3$-uniform bounded-matching problem. Its achievements are exact:

1. every edge has cardinality $3$;
2. the vertex count is $2s+t$;
3. the edge count is $st$;
4. the complete pairwise intersection profile is known;
5. the matching number is $\min(s,t)$;
6. no Berge triangle occurs;
7. for $n\ge 3s$, the specialization has $n$ vertices, matching number $s$, and $s(n-2s)$ edges.

What remains outside these conclusions is equally precise. A full extremal theorem must begin with an arbitrary Berge-triangle-free $3$-graph $\mathcal H$ satisfying $\nu(\mathcal H)\le s$ and derive the upper bound $|E(\mathcal H)|\le s(n-2s)$. One natural strategy fixes a maximum matching, partitions the vertices into matched and unmatched sets, analyzes how edges may meet matching blocks, and sums local inequalities forced by Berge-triangle freeness. To prove uniqueness, one must also show that equality in every local inequality forces $s$ disjoint spine pairs and a common outside set with all possible pair-star edges present.

The construction does not address the analogous $4$-uniform formula or its exceptional congruence case. Those require different edge architectures and separate analysis. Nor does the present paper derive an unrestricted bound by optimizing over possible matching numbers. These are continuations rather than consequences of the theorems proved here.

## 12. Future work

Several directions follow naturally.

First, develop the universal upper bound for arbitrary finite vertex sets. Useful intermediate notions include links, pair-codegrees, maximum matchings, and a partition into matched and unmatched vertices. Local restrictions around each matching edge should then be aggregated into the global inequality.

Second, analyze equality. A robust isomorphism theory would allow the preservation of uniformity, Berge-freeness, edge count, and matching number to be stated independently of vertex labels. Equality conditions should force an isomorphism with the pair-star construction.

Third, extend the program to $4$-uniform hypergraphs, including exceptional behavior when $s=1$ and the vertex count lies in a particular congruence class modulo $4$.

Fourth, build finite enumerators for very small hypergraphs. Such programs can compute candidate extremal numbers, test equality cases, and reveal stability patterns. They do not replace structural proofs, but they are valuable for discovery and diagnostics.

Finally, investigate quantitative stability. If an admissible hypergraph has $s(n-2s)-o(n)$ or $s(n-2s)-o(n^2)$ edges in an appropriate asymptotic regime, determine how many edge edits are required to transform it into a pair-star hypergraph.

## 13. Conclusion

The pair-star hypergraph turns overlap into an extremal resource. Its $s$ disjoint spine pairs each support $t$ edges, producing exactly $st$ triples on $2s+t$ vertices. The same overlap that creates abundance prevents large matchings, while the one-spine-plus-one-outside edge type excludes Berge triangles. When $n\ge 3s$, choosing $t=n-2s$ yields an $n$-vertex construction with matching number exactly $s$ and $s(n-2s)$ edges.

The construction therefore establishes a concrete and exact lower bound for the bounded-matching Berge-triangle problem. Its transparent intersection geometry provides both the proof mechanism and a blueprint for algorithms, recognition, and future stability analysis. The next structural challenge is to show that no admissible $3$-graph can do better and that equality forces this architecture.
