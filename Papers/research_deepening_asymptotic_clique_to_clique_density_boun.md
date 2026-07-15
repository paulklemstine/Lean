# Iterated Shadows and Exact Clique-to-Clique Thresholds

**Aristotle**  
**July 15, 2026**

## Abstract

Let $K_r(G)$ denote the number of $r$-vertex cliques in a finite simple graph $G$. We establish an exact finite implication connecting every pair of clique orders: if $G$ has $n$ vertices and $s\le t\le k\le n$, then

$$
K_t(G)\ge \binom{k}{t}
\quad\Longrightarrow\quad
K_s(G)\ge \binom{k}{s}.
$$

The constants are sharp, as witnessed by a complete graph on $k$ vertices together with any number of isolated vertices. The argument factors into two independent components. A Kruskal–Katona shadow inequality forces the $(t-s)$-fold shadow of any family of at least $\binom{k}{t}$ many $t$-sets to contain at least $\binom{k}{s}$ sets. Separately, the hereditary nature of complete subgraphs ensures that every set in the iterated shadow of the $t$-clique family is an $s$-clique. This factorization yields a uniform generalization of the triangle-to-edge bound and provides exact normalized and asymptotic corollaries. We describe algorithms that expose the shadow mechanism on finite graphs, discuss equality and scope, and position the discrete threshold theorem as a structural foundation for sharper continuous clique-density envelopes and stability questions.

## 1. Introduction

Clique counts are basic coordinates of graph structure. Edges measure pairwise adjacency, triangles measure mutual adjacency among triples, and higher cliques detect increasingly rigid complete interaction. Although these statistics occur at different orders, they cannot vary independently. Every $t$-clique contains $\binom{t}{s}$ cliques of order $s$, but simply multiplying by this number overcounts because many $t$-cliques can share the same $s$-clique. The central extremal question is therefore not whether large cliques create smaller ones, but how efficiently a family of large cliques can reuse its lower-dimensional faces.

This paper gives an exact answer at binomial thresholds. For a finite simple graph $G$, write $K_r(G)$ for its number of $r$-cliques. Given integers $s\le t\le k$, the threshold $\binom{k}{t}$ is the number of $t$-cliques in the complete graph on $k$ vertices. We prove that reaching this threshold forces the corresponding lower threshold $\binom{k}{s}$. The result is uniform in the graph order and in both clique orders.

The proof uses the shadow of a set family. Deleting one element from every member of a uniform family produces its lower shadow; repeated deletion produces an iterated shadow. Two facts then meet. First, set-family theory gives a sharp lower bound on the size of an iterated shadow. Second, deleting vertices from a clique always leaves a clique. The former controls collisions among deleted faces, while the latter transfers the set-theoretic conclusion back to the graph.

The separation is useful conceptually. The quantitative work is entirely independent of adjacency, whereas the graph-specific work is entirely independent of extremal counting. It also suggests extensions: any hereditary collection of uniform sets inherits the same threshold implication, while sharper graph-specific results must exploit constraints beyond hereditary closure.

## 2. Definitions and notation

Throughout, $G=(V,E)$ is a finite simple undirected graph with $|V|=n$. Thus $E$ is a collection of unordered pairs of distinct vertices.

### 2.1. Cliques

A subset $X\subseteq V$ is a **clique** if every two distinct vertices in $X$ are adjacent. An **$r$-clique** is a clique with exactly $r$ vertices. We write

$$
\mathcal C_r(G)=\{X\subseteq V: |X|=r\text{ and }X\text{ is a clique}\}
$$

for the family of all $r$-cliques and

$$
K_r(G)=|\mathcal C_r(G)|
$$

for its cardinality. In particular, $K_2(G)=|E|$ and $K_3(G)$ is the number of triangles.

For $0\le r\le k$, the binomial coefficient

$$
\binom{k}{r}=\frac{k(k-1)\cdots(k-r+1)}{r!}
$$

counts the $r$-subsets of a $k$-element set. Hence $K_r(K_k)=\binom{k}{r}$ for the complete graph $K_k$.

### 2.2. Shadows

Let $\mathcal F$ be a family of finite sets, all of size $t$. Its **lower shadow** is

$$
\partial\mathcal F
=
\{Y: |Y|=t-1\text{ and }Y\subset X\text{ for some }X\in\mathcal F\}.
$$

Define iterated shadows recursively by

$$
\partial^0\mathcal F=\mathcal F,
\qquad
\partial^{i+1}\mathcal F=\partial(\partial^i\mathcal F).
$$

For $0\le i\le t$, every member of $\partial^i\mathcal F$ has size $t-i$. Equivalently,

$$
\partial^i\mathcal F
=
\{Y: |Y|=t-i\text{ and }Y\subseteq X\text{ for some }X\in\mathcal F\}.
$$

The equivalence follows by induction: a chain of $i$ one-element deletions is the same as choosing a subset of codimension $i$.

### 2.3. Normalized clique counts

We use two common normalizations. The **power-normalized count** is

$$
d_r(G)=\frac{K_r(G)}{n^r},
$$

while the **subset-normalized density** is

$$
p_r(G)=\frac{K_r(G)}{\binom{n}{r}}
$$

when $r\le n$. The latter is the probability that a uniformly chosen $r$-subset of vertices forms a clique. The former is convenient for asymptotic scaling because $\binom{n}{r}/n^r\to1/r!$.

## 3. Structural lemmas

We first isolate the graph-theoretic content.

### Lemma 3.1. One-step clique-shadow containment

For every integer $t\ge1$,

$$
\partial\mathcal C_t(G)\subseteq\mathcal C_{t-1}(G).
$$

#### Proof sketch

Take $Y\in\partial\mathcal C_t(G)$. By definition, some $t$-clique $X$ contains $Y$, and $|Y|=t-1$. Every pair of distinct vertices of $Y$ is also a pair of vertices of $X$. Since all such pairs are edges in $X$, they are edges in $Y$. Thus $Y$ is a $(t-1)$-clique. The cases $t=0$ and empty layers can be handled by the corresponding empty-family conventions; only $t\ge1$ is needed for a genuine deletion.

### Lemma 3.2. Monotonicity of iterated shadows

If $\mathcal A\subseteq\mathcal B$, then for every integer $i\ge0$,

$$
\partial^i\mathcal A\subseteq\partial^i\mathcal B.
$$

#### Proof sketch

For $i=0$, this is the hypothesis. If it holds for $i$, every codimension-one face of a member of $\partial^i\mathcal A$ is also a codimension-one face of a member of $\partial^i\mathcal B$. Therefore taking one more shadow preserves containment. Induction proves the claim.

### Lemma 3.3. Iterated clique-shadow containment

If $0\le i\le t$, then

$$
\partial^i\mathcal C_t(G)\subseteq\mathcal C_{t-i}(G).
$$

#### Proof sketch

The assertion is immediate for $i=0$. Assume it holds after $i$ deletions. By shadow monotonicity,

$$
\partial(\partial^i\mathcal C_t(G))
\subseteq
\partial\mathcal C_{t-i}(G).
$$

Lemma 3.1 places the right-hand side inside $\mathcal C_{t-i-1}(G)$. Induction completes the proof. Equivalently, every subset of a clique is a clique, so deleting any $i$ vertices preserves completeness.

The preceding lemma is exact as a containment statement, but it does not itself bound cardinalities sharply because different $t$-cliques can produce the same lower face. The required collision control comes from the next set-theoretic principle.

### Theorem 3.4. Binomial iterated-shadow principle

Let $\mathcal F$ be a finite family of $t$-element sets, and let $s\le t\le k$. If

$$
|\mathcal F|\ge\binom{k}{t},
$$

then

$$
|\partial^{t-s}\mathcal F|\ge\binom{k}{s}.
$$

#### Proof sketch

The Kruskal–Katona theorem states that, among uniform set families of a fixed cardinality, initial segments in colexicographic order minimize lower shadows. At the special cardinality $\binom{k}{t}$, the initial segment consists precisely of all $t$-subsets of a fixed $k$-element ground set. Its one-step shadow is all $(t-1)$-subsets of that ground set, of cardinality $\binom{k}{t-1}$. Repeating the argument through $t-s$ levels yields all $s$-subsets and cardinality $\binom{k}{s}$.

If $|\mathcal F|$ is larger than $\binom{k}{t}$, choose a subfamily $\mathcal F_0$ of exactly that size. Shadow monotonicity gives $\partial^{t-s}\mathcal F_0\subseteq\partial^{t-s}\mathcal F$, so the same lower bound applies. This proves the threshold form.

## 4. Main result

### Theorem 4.1. General clique-to-clique threshold theorem

Let $G$ be a finite simple graph on $n$ vertices. Let $s,t,k$ be integers satisfying

$$
s\le t\le k\le n.
$$

If

$$
K_t(G)\ge\binom{k}{t},
$$

then

$$
K_s(G)\ge\binom{k}{s}.
$$

#### Proof

Apply Theorem 3.4 to the $t$-uniform family $\mathcal C_t(G)$. The hypothesis gives

$$
|\partial^{t-s}\mathcal C_t(G)|
\ge
\binom{k}{s}.
$$

By Lemma 3.3,

$$
\partial^{t-s}\mathcal C_t(G)
\subseteq
\mathcal C_s(G).
$$

Taking cardinalities yields

$$
\binom{k}{s}
\le
|\partial^{t-s}\mathcal C_t(G)|
\le
|\mathcal C_s(G)|
=
K_s(G),
$$

as required.

### Sharpness

The thresholds cannot be increased in the conclusion. Let $G$ be the disjoint union of $K_k$ and $n-k$ isolated vertices. Every clique of size at least $2$ lies in the $K_k$ component, so

$$
K_t(G)=\binom{k}{t}
\qquad\text{and}\qquad
K_s(G)=\binom{k}{s}.
$$

Thus equality occurs simultaneously. More generally, the set-family stage is also sharp: all $t$-subsets of a fixed $k$-set have exactly all $s$-subsets of that set as their iterated shadow.

### Corollary 4.2. Triangle-to-edge threshold

If $3\le k\le n$ and a graph $G$ on $n$ vertices has at least $\binom{k}{3}$ triangles, then it has at least $\binom{k}{2}$ edges.

#### Proof sketch

Take $t=3$ and $s=2$ in Theorem 4.1. The one-step shadow of the triangle family consists of edges that occur in at least one triangle and is therefore contained in the full edge set.

### Corollary 4.3. Consecutive-order threshold

If $2\le t\le k\le n$ and $K_t(G)\ge\binom{k}{t}$, then

$$
K_{t-1}(G)\ge\binom{k}{t-1}.
$$

#### Proof sketch

This is Theorem 4.1 with $s=t-1$. Iterating this consecutive implication recovers every lower order, although the direct iterated-shadow argument expresses the entire chain at once.

### Corollary 4.4. Power-normalized threshold

Under the hypotheses of Theorem 4.1,

$$
d_t(G)\ge\frac{\binom{k}{t}}{n^t}
\quad\Longrightarrow\quad
 d_s(G)\ge\frac{\binom{k}{s}}{n^s}.
$$

#### Proof sketch

Multiply the hypothesis by $n^t$, apply Theorem 4.1, and divide the conclusion by $n^s$.

### Corollary 4.5. Subset-normalized threshold

Under the same hypotheses,

$$
p_t(G)\ge\frac{\binom{k}{t}}{\binom{n}{t}}
\quad\Longrightarrow\quad
p_s(G)\ge\frac{\binom{k}{s}}{\binom{n}{s}}.
$$

#### Proof sketch

The denominators are positive because $t\le k\le n$ and $s\le t$. Clear the first denominator, invoke Theorem 4.1, and divide by $\binom{n}{s}$.

## 5. Asymptotic consequences

The finite theorem yields a scaling law when the comparison parameter grows proportionally to the graph order.

### Theorem 5.1. Asymptotic binomial-ray bound

Fix integers $1\le s\le t$. Let $(G_n)$ be a sequence of graphs with $|V(G_n)|=n$, and let $(k_n)$ be integers satisfying $t\le k_n\le n$ and

$$
\frac{k_n}{n}\longrightarrow\alpha
$$

for some $\alpha\in[0,1]$. If

$$
K_t(G_n)\ge\binom{k_n}{t}
$$

for all sufficiently large $n$, then

$$
\liminf_{n\to\infty}\frac{K_s(G_n)}{n^s}
\ge
\frac{\alpha^s}{s!}.
$$

#### Proof sketch

Theorem 4.1 gives $K_s(G_n)\ge\binom{k_n}{s}$. For fixed $s$,

$$
\frac{\binom{k_n}{s}}{n^s}
=
\frac{1}{s!}\prod_{j=0}^{s-1}\frac{k_n-j}{n}
\longrightarrow
\frac{\alpha^s}{s!}.
$$

Taking lower limits proves the claim.

The corresponding threshold at order $t$ satisfies

$$
\frac{\binom{k_n}{t}}{n^t}
\longrightarrow
\frac{\alpha^t}{t!}.
$$

Eliminating $\alpha$ along these binomial rays suggests the relation

$$
d_s\ge\frac{(t!d_t)^{s/t}}{s!}
$$

at the exact threshold points represented by complete subgraphs occupying an asymptotic fraction $\alpha$ of the vertices. This displayed relation should not be read as a complete sharp envelope for arbitrary intermediate values of $d_t$; the theorem establishes it through sequences satisfying the stated binomial-threshold hypothesis. Continuous interpolation between discrete thresholds is a separate extremal problem.

## 6. Algorithms and numerical exploration

The theorem is structural, but its mechanism can be demonstrated directly.

### 6.1. Clique enumeration

For fixed $r$, enumerate every $r$-subset of the vertex set and test its $\binom{r}{2}$ pairs for adjacency. This computes $\mathcal C_r(G)$ exactly. The straightforward running time is

$$
O\!\left(\binom{n}{r}r^2\right),
$$

with storage $O(K_r(G)r)$ if all cliques are retained. For small fixed $r$, this is polynomial in $n$; for variable $r$, clique enumeration is necessarily costly in the worst case.

### 6.2. Iterated-shadow construction

Given a family of $t$-sets, form its shadow by deleting each of the $t$ elements from each member and inserting the resulting $(t-1)$-set into a deduplicating set structure. Repeat $t-s$ times. If $M_j$ is the family size at level $j$, the work at that level is $O(M_jj)$ expected set operations, aside from tuple-construction and hashing costs. The algorithm makes collisions explicit: multiple parents may generate the same child, but deduplication records it once.

For a clique family, every generated set can be checked against the graph. Lemma 3.3 predicts that all checks succeed. One can then compare the observed shadow size with $\binom{k}{s}$ whenever the initial count exceeds $\binom{k}{t}$.

### 6.3. Threshold certification

Given $K_t(G)$, one may select the largest integer $k$ with $t\le k\le n$ and $\binom{k}{t}\le K_t(G)$. Theorem 4.1 certifies $K_s(G)\ge\binom{k}{s}$ for every $s\le t$. A binary search finds $k$ because $\binom{k}{t}$ is nondecreasing in $k$ and strictly increasing for $k\ge t$. Each binomial evaluation can be performed multiplicatively, avoiding factorials. With ordinary fixed-width arithmetic the search takes $O(\log n)$ evaluations; with arbitrary-precision integers, bit complexity also depends on the size of the binomial coefficients.

## 7. Examples

### Example 7.1. A sharp complete-core construction

Let $G$ consist of $K_6$ and four isolated vertices. Then $n=10$ and

$$
K_4(G)=\binom{6}{4}=15,
\quad
K_3(G)=\binom{6}{3}=20,
\quad
K_2(G)=\binom{6}{2}=15.
$$

Starting with the $15$ four-cliques, one shadow step produces all $20$ triples in the six-vertex core, and a second produces all $15$ pairs. Both bounds are equalities.

### Example 7.2. A non-extremal graph

For the complete graph $K_7$, suppose one uses the weaker threshold parameter $k=6$. Since

$$
K_4(K_7)=\binom{7}{4}=35\ge\binom{6}{4}=15,
$$

the theorem certifies only $K_2(K_7)\ge\binom{6}{2}=15$, whereas the actual count is $\binom{7}{2}=21$. Choosing the largest admissible $k$ gives the strongest threshold certificate.

### Example 7.3. Why an upward converse fails

A complete bipartite graph with two nonempty parts may have many edges but no triangles. Therefore a lower bound on $K_2(G)$ alone cannot force a positive $K_3(G)$. The theorem’s direction reflects hereditary closure: deleting vertices preserves a clique, while adding vertices need not preserve one.

## 8. Applications and interpretation

### 8.1. Clique complexes and face vectors

The **clique complex** of $G$ is the simplicial complex whose faces are the cliques of $G$. An $r$-clique corresponds to a face with $r$ vertices, conventionally of dimension $r-1$. Theorem 4.1 therefore constrains the face vector of every clique complex: at a binomial threshold in one dimension, every lower face count crosses the matching binomial threshold.

Clique complexes are flag complexes, meaning that their minimal nonfaces have two vertices. The shadow theorem uses only downward closure and hence applies to arbitrary simplicial complexes as well. Flagness can impose additional constraints, so the present inequalities are universal rather than a complete characterization of clique-complex face vectors.

### 8.2. Network motif consistency

In an observed network, motif counts are often estimated independently. The theorem supplies deterministic consistency checks. If an asserted count of $t$-cliques is at least $\binom{k}{t}$ while the asserted count of $s$-cliques is below $\binom{k}{s}$, the two claims cannot describe the same simple graph. This is useful as a validation principle even when the theorem’s bound is not the tightest possible for the dataset.

### 8.3. Higher-order interaction systems

The set-family component applies whenever high-order objects come with all their subobjects. Hyperedges, simplicial faces, and complete interaction groups naturally produce shadows. The graph application is distinguished by the fact that its high-order objects arise from pairwise adjacency, but the downward threshold itself is inherited from the broader geometry of finite set systems.

## 9. A broader hereditary-family principle

The graph theorem is an instance of a general transfer mechanism. Let $\mathcal H$ be a family of finite subsets of a ground set that is **hereditary**, meaning that $X\in\mathcal H$ and $Y\subseteq X$ imply $Y\in\mathcal H$. Write $\mathcal H_r$ for its members of size $r$.

### Theorem 9.1. Hereditary binomial-threshold principle

If $\mathcal H$ is hereditary, $s\le t\le k$, and

$$
|\mathcal H_t|\ge\binom{k}{t},
$$

then

$$
|\mathcal H_s|\ge\binom{k}{s}.
$$

#### Proof sketch

Apply the binomial iterated-shadow principle to $\mathcal H_t$. Every member of $\partial^{t-s}\mathcal H_t$ is an $s$-element subset of some member of $\mathcal H_t$. Heredity therefore places the entire iterated shadow inside $\mathcal H_s$. The shadow has at least $\binom{k}{s}$ members, giving the conclusion.

Clique families satisfy heredity because completeness is preserved under taking subsets. The general formulation clarifies that pairwise adjacency enters only when identifying the hereditary system of interest. It also explains the relevance to simplicial complexes, whose defining property is precisely hereditary closure.

There is a useful converse perspective. Any improvement to Theorem 4.1 that relies only on heredity would have to hold for every simplicial complex, and is therefore constrained by sharp set-family examples. Sharper bounds specialized to graphs must use flagness: a set is a clique exactly when all its two-element subsets are edges. This distinction identifies where genuinely graph-theoretic information must enter future arguments.

## 10. Scope and limitations

The result is exact at binomial thresholds, but it does not determine the full minimum of $K_s(G)$ for every prescribed value of $K_t(G)$. General set families admit a detailed binomial representation through the full Kruskal–Katona theorem. Graph clique families are more constrained than arbitrary uniform families because they must arise as complete subsets of a single edge relation. Exploiting that extra structure may improve bounds away from threshold points.

Nor does the theorem characterize all equality cases among graphs. The complete-core construction proves sharpness, but determining whether other configurations attain equality for particular parameters is a separate structural question. Near-equality is subtler still: a stability theorem would need to show that small deficit in the conclusion forces a graph to resemble an extremal construction in edit distance or another metric.

Finally, the theorem is finite and unweighted. Dense graph limits suggest measurable analogues, but an appropriate shadow operation for graphons would have to replace finite subsets and cardinalities by measurable structures and masses. Sampling offers a plausible bridge, provided concentration and limiting arguments preserve the relevant inequalities.

## 11. Future research

A first objective is the sharp generalized-inverse lower envelope for normalized clique counts. For $2\le s<t$, one seeks the exact minimum $t$-clique density at prescribed $s$-clique density, including the interpolation between consecutive binomial regimes and the multipartite equality structures.

A second objective is quantitative stability. The iterated proof exposes a sequence of shadow steps, and the excess or loss at each step may serve as a defect parameter. Controlling all defects could turn near equality in a global count into nested neighborhood structure and proximity to a multipartite extremizer.

A third objective is a weighted graphon shadow principle. One possible route is to sample large finite graphs from a graphon, apply the finite theorem uniformly, and pass to the limit through concentration of clique densities.

A fourth objective is a face-vector characterization for flag complexes. Universal shadow inequalities describe constraints shared by all simplicial complexes, while flagness adds quadratic forbidden-face information. Identifying the closure of vectors satisfying both kinds of restrictions would clarify exactly how graph clique profiles differ from arbitrary face profiles.

A fifth objective is a local-to-global recursion based on common neighborhoods. Since a $t$-clique can be viewed through a vertex and a $(t-1)$-clique in its neighborhood, sharp convex functionals of codegree data may offer analytic inequalities unavailable to a purely global shadow argument.

## 12. Conclusion

The clique-to-clique threshold theorem gives a single exact law across the entire hierarchy of clique orders. If a graph contains at least $\binom{k}{t}$ cliques of order $t$, then it contains at least $\binom{k}{s}$ cliques of every lower order $s$. The proof is the composition of a sharp set-family shadow bound and the elementary but decisive fact that every subset of a clique remains a clique.

This factorization explains both the theorem’s strength and its boundary. It is strong because shadow minimization controls arbitrary overlap among high-order cliques; it is limited because it uses no graph structure beyond hereditary closure. As a result, the theorem supplies an exact finite skeleton on which sharper density interpolation, stability, and limit theories can be built.