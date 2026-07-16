# Translation Invariants of Local Observables in Finite Cayley Graphs

**Aristotle**  
**July 16, 2026**

## Abstract

Let $G$ be a group and let $S\subseteq G$ be an inverse-closed connection set not containing the identity. The associated simple undirected Cayley graph joins $a$ to $b$ exactly when $a^{-1}b\in S$. We develop a hierarchy of exact transport results for its local graph observables. Left multiplication gives an explicit graph automorphism and induces bijections between neighborhoods and between common neighborhoods. Normalizing an ordered pair $(a,b)$ by left multiplication with $a^{-1}$ yields the pair $(e,a^{-1}b)$. Consequently, the cardinality of a common neighborhood depends only on the group difference $a^{-1}b$. More strongly, the normalization preserves every adjacency relation among common neighbors, so the full induced common-neighborhood graph—and hence every isomorphism-invariant observable of that graph—factors through $a^{-1}b$. These results supply exact algebraic explanations for uniform degree, triangle-completion counts, and local four-cycle observables. We give set-intersection and autocorrelation formulations, algorithms for computing difference-indexed profiles, worked examples, applications to symmetry-aware data analysis, and boundaries distinguishing Cayley graphs from merely regular or vertex-transitive graphs.

## 1. Introduction

Finite groups are rigid algebraic systems, while finite graphs provide flexible models of pairwise interaction. A Cayley graph joins these viewpoints: its vertices are group elements, and its edges encode multiplication by selected elements. It is therefore natural to ask which network observables are forced by the underlying group action and which retain information capable of distinguishing groups or generating sets.

Local observables are particularly important. Vertex degree is the first such quantity. Triangle statistics depend on common neighbors of adjacent vertices. Four-cycle and square-clustering statistics depend on common neighbors of pairs and, in refined versions, on adjacency among those common neighbors. Data pipelines often compute these quantities independently for many vertices and ordered pairs. In a Cayley graph, however, many of these records are exact translates of one another.

The familiar statement that Cayley graphs are vertex-transitive explains uniform one-root measurements. The principal point of this paper is a two-root refinement. For an ordered pair $(a,b)$, simultaneous left translation preserves all adjacency data and sends the pair to $(ca,cb)$. Choosing $c=a^{-1}$ produces the canonical representative $(e,a^{-1}b)$. Thus pairwise local observables do not live naturally on $G\times G$; translation-invariant ones live on the relative coordinate $a^{-1}b\in G$.

We prove this first for common-neighbor sets and then at the stronger level of their induced graphs. The latter result preserves not only the number of common neighbors but also every internal edge. It therefore controls local graph invariants relevant to four-cycles and supports spectral extensions through permutation similarity.

The argument requires no commutativity and, at the level of bijections, no finiteness. Finiteness enters only when equivalences are converted to cardinality statements or finite algorithms. This separation reveals the structural core: cancellation in

$$
(ca)^{-1}(cb)=a^{-1}b.
$$

## 2. Algebraic and graph-theoretic setting

### 2.1 Groups and connection sets

Let $G$ be a group with multiplication written multiplicatively, identity $e$, and inverse $g^{-1}$. Let $S\subseteq G$ satisfy

$$
e\notin S
\qquad\text{and}\qquad
s\in S\Longrightarrow s^{-1}\in S.
$$

The first condition rules out loops. The second makes the resulting adjacency relation symmetric.

**Definition 2.1 (Cayley graph).** The simple undirected Cayley graph $\Gamma=\operatorname{Cay}(G,S)$ has vertex set $G$. Distinct vertices $a,b\in G$ are adjacent, written $a\sim b$, exactly when

$$
a^{-1}b\in S.
$$

Because $e\notin S$, one never has $a\sim a$. If $a^{-1}b\in S$, inverse closure gives $(a^{-1}b)^{-1}=b^{-1}a\in S$, and hence $b\sim a$.

**Definition 2.2 (Neighborhood and degree).** The neighborhood of $a$ is

$$
N(a)=\{x\in G:a\sim x\}.
$$

When $G$ is finite, the degree of $a$ is $\deg(a)=|N(a)|$.

The adjacency condition immediately gives

$$
N(a)=aS=\{as:s\in S\}.
$$

Indeed, $a\sim x$ if and only if $a^{-1}x=s$ for some $s\in S$, equivalently $x=as$.

**Definition 2.3 (Common neighborhood).** For an ordered pair $(a,b)$, define

$$
C(a,b)=N(a)\cap N(b)
       =\{x\in G:a\sim x\text{ and }b\sim x\}.
$$

The graph induced by $C(a,b)$, denoted $\Gamma[C(a,b)]$, has vertex set $C(a,b)$ and contains precisely those edges of $\Gamma$ whose endpoints both lie in $C(a,b)$.

### 2.2 Left translations

For each $c\in G$, define the left translation $L_c:G\to G$ by

$$
L_c(x)=cx.
$$

The map $L_c$ is bijective, with inverse $L_{c^{-1}}$. The identity

$$
(ca)^{-1}(cb)=a^{-1}c^{-1}cb=a^{-1}b
$$

shows that left translation preserves the group difference associated with every ordered pair.

## 3. Translation automorphisms and one-root observables

**Theorem 3.1 (Left-Translation Automorphism Theorem).** For every $c\in G$, the map $L_c$ is an automorphism of $\Gamma$. Explicitly, for all $a,b\in G$,

$$
a\sim b\quad\Longleftrightarrow\quad ca\sim cb.
$$

**Proof sketch.** By definition, $ca\sim cb$ precisely when $(ca)^{-1}(cb)\in S$. Cancellation reduces this element to $a^{-1}b$, which belongs to $S$ precisely when $a\sim b$. Since $L_c$ is a bijection with inverse $L_{c^{-1}}$, it is a graph automorphism. $\square$

**Theorem 3.2 (Neighborhood Transport Theorem).** For all $a,c\in G$, left translation restricts to a bijection

$$
L_c:N(a)\longrightarrow N(ca),
\qquad x\longmapsto cx,
$$

whose inverse is $L_{c^{-1}}$.

**Proof sketch.** If $x\in N(a)$, then $a\sim x$. Theorem 3.1 gives $ca\sim cx$, so $cx\in N(ca)$. The inverse translation proves bijectivity. $\square$

**Corollary 3.3 (Degree Regularity).** If $G$ is finite, every vertex has the same degree as the identity:

$$
\deg(a)=\deg(e)
$$

for all $a\in G$. In fact, $\deg(a)=|S|$.

**Proof sketch.** In Theorem 3.2 choose $c=a^{-1}$. This bijects $N(a)$ with $N(e)$. Also $N(e)=S$, because $e^{-1}x=x$. Taking cardinalities yields the result. $\square$

The theorem has a cardinality-free meaning: even for infinite groups, neighborhoods at different vertices are explicitly equivalent. Finiteness is needed only to speak of a finite numerical degree.

## 4. Simultaneous transport of common neighborhoods

**Theorem 4.1 (Common-Neighborhood Translation Theorem).** For every $a,b,c\in G$, the map

$$
L_c:C(a,b)\longrightarrow C(ca,cb),
\qquad x\longmapsto cx,
$$

is a bijection with inverse $L_{c^{-1}}$.

**Proof sketch.** Membership $x\in C(a,b)$ means both $a\sim x$ and $b\sim x$. Applying Theorem 3.1 to both relations gives $ca\sim cx$ and $cb\sim cx$, so $cx\in C(ca,cb)$. Translation by $c^{-1}$ reverses the construction. $\square$

This theorem says that the common-neighborhood configuration is constant on diagonal left-translation orbits in $G\times G$. These orbits admit a canonical coordinate.

**Lemma 4.2 (Difference Classification of Translation Orbits).** Two ordered pairs $(a,b)$ and $(a',b')$ lie in the same simultaneous left-translation orbit if and only if

$$
a^{-1}b=(a')^{-1}b'.
$$

**Proof sketch.** Translation invariance of the difference proves the forward implication. Conversely, if the differences agree, set $c=a'a^{-1}$. Then $ca=a'$, and

$$
cb=a'a^{-1}b=a'(a')^{-1}b'=b'.
$$

Thus $L_c$ sends one pair to the other. $\square$

**Theorem 4.3 (Pair-Difference Common-Neighborhood Theorem).** For every ordered pair $(a,b)\in G\times G$, the map

$$
\Phi_{a,b}:C(a,b)\longrightarrow C(e,a^{-1}b),
\qquad
\Phi_{a,b}(x)=a^{-1}x,
$$

is a bijection. Its inverse is $y\mapsto ay$.

**Proof sketch.** Apply Theorem 4.1 with $c=a^{-1}$. The roots become $a^{-1}a=e$ and $a^{-1}b$. The stated inverse is translation by $a$. $\square$

**Corollary 4.4 (Difference-Indexed Common-Neighbor Counts).** If $G$ is finite, then

$$
|C(a,b)|=|C(e,a^{-1}b)|
$$

for every $a,b\in G$. Hence the common-neighbor count is a function of $a^{-1}b$ alone.

**Proof sketch.** Take cardinalities in Theorem 4.3. $\square$

### 4.1 Intersection and autocorrelation formulations

Since $N(a)=aS$, one has

$$
C(a,b)=aS\cap bS.
$$

Writing $g=a^{-1}b$ and translating by $a^{-1}$ yields

$$
a^{-1}C(a,b)=S\cap gS.
$$

Therefore the difference profile

$$
\kappa(g)=|C(e,g)|
$$

satisfies

$$
\kappa(g)=|S\cap gS|.
$$

For finite $G$, let $1_S:G\to\{0,1\}$ be the indicator of $S$. Then

$$
\kappa(g)=\sum_{x\in G}1_S(x)1_S(g^{-1}x).
$$

Indeed, a term contributes exactly when $x\in S$ and $g^{-1}x\in S$, the latter being equivalent to $x\in gS$. Thus $\kappa$ is a group autocorrelation of the connection-set indicator.

If $a\sim b$, then $g=a^{-1}b\in S$, and $\kappa(g)$ counts triangles containing the edge $\{a,b\}$. If $a$ and $b$ are interpreted as opposite corners, $\kappa(g)$ counts length-two connections between them. Pairing such intermediates contributes to four-cycle statistics, subject to the convention used to exclude degeneracies or count orientations.

## 5. Preservation of induced common-neighborhood graphs

Cardinality alone does not describe the internal arrangement of common neighbors. The next result lifts the pair-difference theorem from sets to induced graphs.

**Theorem 5.1 (Induced Common-Neighborhood Translation Theorem).** Let $a,b,c\in G$. The bijection $L_c:C(a,b)\to C(ca,cb)$ is an isomorphism of induced graphs. For every $x,y\in C(a,b)$,

$$
x\sim y\quad\Longleftrightarrow\quad cx\sim cy.
$$

**Proof sketch.** Theorem 4.1 supplies the vertex bijection. Theorem 3.1 preserves adjacency between every pair of vertices, including those lying in the common neighborhood. Therefore the restricted map preserves and reflects all induced edges. $\square$

**Theorem 5.2 (Pair-Difference Induced-Graph Theorem).** For every $a,b\in G$, the map $x\mapsto a^{-1}x$ is a graph isomorphism

$$
\Gamma[C(a,b)]\cong \Gamma[C(e,a^{-1}b)].
$$

**Proof sketch.** Specialize Theorem 5.1 to $c=a^{-1}$. $\square$

**Corollary 5.3 (Factorization of Induced-Graph Observables).** Let $F$ be any graph invariant: whenever finite graphs $X$ and $Y$ are isomorphic, $F(X)=F(Y)$. Then

$$
F\bigl(\Gamma[C(a,b)]\bigr)
=
F\bigl(\Gamma[C(e,a^{-1}b)]\bigr).
$$

Accordingly, the following all depend only on $a^{-1}b$: the number of common neighbors; the number of edges among them; their induced degree multiset; their connected-component sizes; every induced cycle count; and the characteristic polynomial or spectrum of an adjacency matrix.

**Proof sketch.** Apply the defining isomorphism invariance of $F$ to Theorem 5.2. For spectra, order the vertices of the two induced graphs compatibly with the isomorphism. Their adjacency matrices satisfy $A'=PAP^{-1}$ for a permutation matrix $P$, so they have the same characteristic polynomial and eigenvalue multiset. $\square$

This corollary makes precise the hierarchy of information. Common-neighbor cardinality is a vertex count of an induced graph. Edges among common neighbors provide a richer four-cycle-sensitive statistic. The full isomorphism class retains every finite adjacency pattern internal to that common neighborhood.

## 6. Algorithms

Assume henceforth that $G$ is finite and that multiplication and inversion each take constant time after a multiplication table or efficient group representation has been supplied.

### 6.1 Canonical pair normalization

Given $(a,b)$, compute $g=a^{-1}b$. The pair is represented canonically by $(e,g)$, and a common neighbor $x$ is transported to $a^{-1}x$.

**Algorithm 1 (Pair Normalization).**

1. Input $a,b\in G$.
2. Compute $a^{-1}$.
3. Compute $g=a^{-1}b$.
4. Return $g$ and the transport rule $x\mapsto a^{-1}x$.

The group-operation cost is $O(1)$. Materializing the transported common-neighbor list costs $O(|C(a,b)|)$.

### 6.2 Difference-indexed common-neighbor profile

The profile $\kappa(g)=|S\cap gS|$ can be computed directly.

**Algorithm 2 (Common-Neighbor Autocorrelation Profile).**

1. Store $S$ in a hash set.
2. For every $g\in G$, initialize $\kappa(g)=0$.
3. For every $g\in G$ and $s\in S$, test whether $g^{-1}s\in S$.
4. Increment $\kappa(g)$ on each successful test.
5. Return $\kappa$.

With constant-time membership tests, the running time is $O(|G||S|)$ and storage is $O(|G|+|S|)$. A naive all-pairs computation over roots followed by neighborhood intersection may cost $O(|G|^2|S|)$, so indexing by differences removes a factor of $|G|$ when all pair values are wanted.

An equivalent accumulation method loops over $(s,t)\in S^2$ and increments the bin $g=st^{-1}$, because $s\in S\cap gS$ exactly when $s=gt$ for some $t\in S$. This costs $O(|S|^2+|G|)$ and may be preferable for sparse connection sets.

### 6.3 Induced common-neighborhood signatures

For each $g\in G$, first form $C(e,g)=S\cap gS$. Then inspect all unordered pairs in this set and retain those whose difference lies in $S$. This constructs the induced graph.

**Algorithm 3 (Difference-Indexed Induced Signature).**

1. For each $g\in G$, compute $C_g=S\cap gS$.
2. For each unordered pair $\{x,y\}\subseteq C_g$, test whether $x^{-1}y\in S$.
3. Build the induced graph on $C_g$.
4. Compute the desired isomorphism-invariant signature, such as edge count, degree multiset, component sizes, or spectrum.
5. Store the signature under $g$.

The set-construction phase costs $O(|G||S|)$. The edge phase costs

$$
O\left(\sum_{g\in G}|C_g|^2\right),
$$

which is at most $O(|G||S|^2)$. Spectral decomposition by dense methods adds $O\left(\sum_g |C_g|^3\right)$. The result answers every ordered-pair query by a constant-time difference lookup plus the cost of group multiplication and inversion.

## 7. Examples

### 7.1 A cyclic graph

Let $G=\mathbb Z/8\mathbb Z$ under addition and

$$
S=\{1,2,6,7\}=\{\pm1,\pm2\}.
$$

Adjacency is determined by whether $b-a$ modulo $8$ lies in $S$. Every vertex has degree $4$.

For $(a,b)=(2,5)$, the difference is $g=b-a=3$. Direct calculation gives

$$
N(2)=\{0,1,3,4\},\qquad N(5)=\{3,4,6,7\},
$$

and hence $C(2,5)=\{3,4\}$. At the normalized pair,

$$
N(0)=\{1,2,6,7\},\qquad N(3)=\{1,2,4,5\},
$$

so $C(0,3)=\{1,2\}$. Translation by $-2$ maps $3\mapsto1$ and $4\mapsto2$. Since both pairs of common neighbors differ by $1$, both induced common-neighborhood graphs consist of one edge.

### 7.2 A noncommutative example

Let $G=S_3$, the permutations of three symbols, and let $S$ be the three transpositions. Since every transposition is its own inverse and the identity is excluded, $S$ is a valid connection set. Every vertex has degree $3$. If $a,b\in S_3$, then the common-neighborhood structure at $(a,b)$ is transported to that at $(e,a^{-1}b)$. No commutativity is used: the order in $a^{-1}b$ is essential. This demonstrates that the theory is genuinely group-theoretic rather than an artifact of additive cyclic examples.

## 8. Applications

### 8.1 Lossless compression of pairwise observables

An ordered-pair table on an $n$-element group has $n^2$ positions. If its value is an invariant of the induced common-neighborhood graph, Theorem 5.2 shows that it can be represented by at most $n$ difference-indexed values. The original table is recovered by looking up the entry at $a^{-1}b$. This is exact compression, not approximation.

Further compression may occur. If distinct differences yield isomorphic induced common-neighborhood graphs, they share all such signatures. In normal Cayley graphs, where $S$ is invariant under conjugation, conjugate differences often provide an additional natural indexing reduction; that extension requires the conjugation symmetry to be stated separately.

### 8.2 Symmetry-aware learning and evaluation

When translated configurations appear in both training and test sets, a predictive model may be evaluated on examples that are structurally identical to its training data. Difference indexing makes this dependence explicit. Dataset splits can be organized by differences or by orbits of an enlarged automorphism action. Features can likewise be canonicalized at $(e,g)$ rather than redundantly recomputed at every $(a,b)$.

The theory also bounds discriminatory power. Degree is constant and cannot identify a vertex. The scalar profile $\kappa(g)$ sees only translated-set overlap. The induced graph $\Gamma[C(e,g)]$ retains more information, but it may still coincide for several differences or several nonisomorphic groups. These observables are useful signatures, not complete invariants.

### 8.3 Triangle, square, and spectral statistics

For an edge $(a,b)$, $|C(a,b)|$ counts triangle completions. For arbitrary pairs, it counts two-step intermediates. Internal edges in $C(a,b)$ encode additional incidences among those intermediates and therefore feed refined local cycle and square-clustering measurements. Theorem 5.2 guarantees that all such edge-based observables depend only on $a^{-1}b$.

Once an adjacency matrix is chosen for each finite induced graph, graph isomorphism transports it by a permutation similarity. Thus local characteristic polynomials, spectral moments, and eigenvalue multisets also factor through the difference. This spectral consequence uses no claim that spectra classify the induced graphs; only their invariance under isomorphism is required.

## 9. A general finite-pattern transport principle

The preceding results illustrate a mechanism that applies beyond common neighborhoods. Consider a finite pattern with labeled vertices, some designated as roots and the rest free. Suppose its constraints use only equality, inequality, adjacency, and nonadjacency. A realization in $\Gamma$ assigns group elements to the labels while satisfying those constraints.

**Proposition 9.1 (Finite-Pattern Translation Principle).** If a pattern has roots assigned to $(r_1,\ldots,r_k)$, then left multiplication by $c$ gives a bijection from its realizations at those roots to its realizations at $(cr_1,\ldots,cr_k)$. After choosing the first root as a base point, the realization set is therefore determined up to canonical bijection by

$$
(e,r_1^{-1}r_2,\ldots,r_1^{-1}r_k).
$$

**Proof sketch.** Multiply every assigned vertex, rooted or free, by $c$. Equality and inequality are preserved because left multiplication is bijective. Adjacency and nonadjacency are preserved by Theorem 3.1. Translation by $c^{-1}$ is the inverse on realizations. Finally choose $c=r_1^{-1}$ to normalize the first root. $\square$

This proposition includes neighborhood transport as a one-root pattern and common-neighborhood transport as a two-root pattern with one free vertex adjacent to both roots. It also applies to fixed-length paths, cycles through designated roots, and finite motifs with prescribed missing edges. For a finite group, taking cardinalities proves that every corresponding rooted motif count factors through a tuple of relative elements. If the construction retains adjacency among selected free vertices instead of merely counting realizations, the same transport produces isomorphic auxiliary incidence structures.

The proposition should not be confused with an assertion about arbitrary analytic statistics or externally attached vertex labels. A quantity that uses an ordering of group elements, a non-translation-invariant weight, or metadata not transported by the group action need not factor through differences. The precise criterion is equivariance: every ingredient in the observable must be carried along by simultaneous left translation.

## 10. Scope and limitations

The assumptions on $S$ are structural. If $e\in S$, loops occur. If $S$ is not inverse-closed, adjacency is naturally directed. Left translation continues to preserve the defining relation in either case, but statements about simple undirected graphs must be reformulated.

Regular graphs need not satisfy any pair-difference principle. They guarantee equal degrees but may have multiple inequivalent common-neighbor configurations. Vertex-transitive graphs do ensure that configurations are constant on automorphism orbits, yet they need not possess a canonical group coordinate $a^{-1}b$. Cayley graphs contribute both a transitive action and an explicit normalization map.

No converse is asserted. Uniform degree, difference-like count tables, or repeated local spectra do not by themselves prove that a graph is Cayley. Nor do the local observables developed here necessarily determine the underlying group or connection set.

## 11. Future directions

The transport mechanism suggests several testable extensions.

**Rooted-pattern factorization.** For any finite graph pattern with distinguished roots, the number of adjacency-preserving embeddings with those roots fixed should be constant on simultaneous left-translation orbits. Fixing one root at $e$ would express the count through a tuple of group differences. The present common-neighbor theorem is the case of two roots and one free vertex.

**Square clustering as autocorrelation.** Standard local square-clustering numerators should admit explicit expressions in the indicator $1_S$, extending the two-point autocorrelation formula for $\kappa(g)$. Internal edges of common neighborhoods indicate where higher-order products of translated indicators enter.

**Spectral reconstruction.** For connected normal Cayley graphs, it is natural to investigate whether spectra of induced common-neighborhood graphs, indexed by conjugacy classes of differences, determine ambient fourth spectral moments or separate families indistinguishable by degree and triangle counts.

**Quantitative stability.** An approximate converse would ask whether a finite graph satisfying degree, common-neighbor, and induced-spectrum consistency identities for all but an $\varepsilon$ fraction of ordered pairs must lie close, in normalized edit distance, to a graph with a large semiregular automorphism subgroup. Exact transport is elementary; robust reconstruction is substantially deeper.

## 12. Conclusion

Left translation organizes the local geometry of a Cayley graph at several levels. It is an automorphism of the ambient graph, a bijection between neighborhoods, a simultaneous bijection between common neighborhoods, and an isomorphism between the graphs induced on them. Normalizing $(a,b)$ by $a^{-1}$ reduces every result to the canonical pair $(e,a^{-1}b)$.

For finite groups, degree is therefore uniform, common-neighbor counts are difference-indexed autocorrelations, and all isomorphism-invariant features of induced common-neighborhood graphs factor through the same relative element. The practical implication is a lossless reduction from pair-indexed local data to difference-indexed profiles. The conceptual implication is broader: in a Cayley graph, local network geometry is governed not by absolute location but by algebraic relative position.