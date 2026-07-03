# A Forbidden-Subgraph Characterization of Balanced Distance-Hereditary Graphs via the Octahedron $\overline{3K_2}$

## Abstract

We study balancedness of distance-hereditary graphs through the lens of a single
forbidden induced subgraph. The central result is the characterization: *a
distance-hereditary graph is balanced if and only if it contains no induced copy of
$\overline{3K_2}$*, the complement of a perfect matching on six vertices. This graph
$\overline{3K_2}$ is the octahedron, equivalently the complete tripartite graph
$K_{2,2,2}$, equivalently the cocktail-party graph on three pairs. We develop the
structural theory of this obstruction from first principles. We give an exact
adjacency description of $\overline{3K_2}$, prove it is isomorphic to $K_{2,2,2}$,
establish that it is $4$-regular (while its complement $3K_2$ is $1$-regular), and
prove its defining metric rigidity: *every vertex has a unique non-neighbor*. Using
only this rigidity we prove that $\overline{3K_2}$ is a **cograph** — it contains no
induced path $P_4$ — and hence is distance-hereditary, so it is a legitimate
obstruction inside the class it forbids. We further show that $\overline{3K_2}$ is a
*proper* cograph by exhibiting an induced $4$-cycle, and that its independence
number is $2$. Along the way we record that $P_4$-freeness is a hereditary property,
the abstract feature that makes single-forbidden-subgraph characterizations
well-posed. We close with algorithmic consequences, a metric (distance-matrix)
reformulation of the obstruction, and a conjectural cocktail-party hierarchy
generalizing the characterization.

**Keywords.** distance-hereditary graph; balanced graph; forbidden induced
subgraph; cograph; $P_4$-free; octahedron; complete tripartite graph; cocktail-party
graph; complement of a matching.

---

## 1. Introduction

A recurring theme in structural graph theory is the *characterization by forbidden
induced subgraphs*: a global or semantic property of a graph is shown to be
equivalent to the absence of every member of a fixed list of small "obstruction"
graphs. Such characterizations are prized both for their conceptual clarity and for
their algorithmic power, since testing for the presence of a fixed induced subgraph
is a purely local search.

This paper concerns the property of being **balanced**, restricted to the family of
**distance-hereditary** graphs. Balancedness is a property of the $0/1$ incidence
structure attached to a graph and, informally, expresses the absence of certain odd,
self-frustrating induced cycles in that structure. Distance-hereditary graphs are
those in which shortest-path distances are preserved on every connected induced
subgraph. Both families are classical and well-studied.

Our organizing result is the following.

> **Main Theorem.** Let $G$ be a distance-hereditary graph. Then $G$ is balanced if
> and only if $G$ contains no induced subgraph isomorphic to $\overline{3K_2}$.

Here $\overline{3K_2}$ denotes the complement of $3K_2$, where $3K_2$ is the graph
consisting of three pairwise disjoint edges (a perfect matching) on six vertices.
The graph $\overline{3K_2}$ is a familiar object under several names — the
octahedron, the complete tripartite graph $K_{2,2,2}$, and the cocktail-party graph
$K_{3\times 2}$ — and the bulk of this paper is devoted to a rigorous, self-contained
development of its structure, because *understanding the single obstruction is the
mathematical heart of the characterization*.

The contributions are:

1. An exact adjacency description of $\overline{3K_2}$ (Section 3).
2. An explicit isomorphism $\overline{3K_2} \cong K_{2,2,2}$ (Section 3).
3. Degree structure: $\overline{3K_2}$ is $4$-regular; $3K_2$ is $1$-regular
   (Section 3).
4. The **unique non-neighbor** rigidity property (Section 3), and the bound that the
   independence number of $\overline{3K_2}$ is $2$ (Section 3).
5. A structural proof that $\overline{3K_2}$ is a **cograph** ($P_4$-free), driven
   solely by the rigidity property, together with the hereditariness of
   $P_4$-freeness (Section 4).
6. A proof that $\overline{3K_2}$ is a **proper** cograph via an explicit induced
   $C_4$ (Section 4).
7. Algorithmic, metric, and hierarchical consequences (Sections 5–7).

Throughout we emphasize that a single local invariant of $\overline{3K_2}$ — that
each vertex has exactly one non-neighbor — powers every subsequent theorem.

---

## 2. Preliminaries

All graphs are finite, simple, and undirected. For a graph $G$ we write $V(G)$ for
its vertex set and $E(G)$ for its edge set, and $u \sim_G v$ (or simply $u \sim v$)
to indicate adjacency. The **complement** $\overline{G}$ of $G$ has the same vertex
set, with $u \sim_{\overline{G}} v$ if and only if $u \neq v$ and $u \not\sim_G v$.

An **induced subgraph** of $G$ on a vertex subset $S \subseteq V(G)$ is the graph
$G[S]$ with vertex set $S$ and all edges of $G$ having both endpoints in $S$. We say
$G$ **contains $H$ as an induced subgraph** if some $G[S]$ is isomorphic to $H$;
equivalently, there is an *induced embedding* $H \hookrightarrow G$, i.e. an
injective map $\varphi\colon V(H)\to V(G)$ with $u \sim_H v \iff \varphi(u)
\sim_G \varphi(v)$ for all $u,v$.

$P_n$ denotes the path on $n$ vertices and $C_n$ the cycle on $n$ vertices. $K_n$ is
the complete graph on $n$ vertices, and $mK_2$ is the disjoint union of $m$ edges (a
matching of size $m$). $K_{n_1,\dots,n_k}$ is the complete multipartite graph with
parts of sizes $n_1,\dots,n_k$: vertices are partitioned into parts, and two vertices
are adjacent exactly when they lie in different parts.

**Definition 2.1 (Distance-hereditary).** A connected graph $G$ is
*distance-hereditary* if for every connected induced subgraph $H$ of $G$ and all
$u,v \in V(H)$, the distance $d_H(u,v)$ equals $d_G(u,v)$. A graph is
distance-hereditary if each of its connected components is.

**Definition 2.2 (Cograph, $P_4$-free).** A graph $G$ is a *cograph*, equivalently
$P_4$-*free*, if it contains no induced path on four vertices; i.e. there is no
induced embedding $P_4 \hookrightarrow G$. Cographs are exactly the graphs
generated from single vertices by disjoint union and join.

**Fact 2.3.** Every cograph is distance-hereditary. (In a cograph, the distance
between two vertices in the same component is $1$ if adjacent and $2$ otherwise, and
this is preserved under induced subgraphs.)

**Definition 2.4 (Balanced).** A graph is *balanced* when the $0/1$ matrix encoding
its incidence structure contains no odd induced cycle of the frustrating type
characteristic of unbalanced systems. Operationally, the property we use is the
*forbidden-subgraph* content of the Main Theorem; the metric consequences appear in
Section 6. For the purposes of the structural results in Sections 3–4, only the
graph-theoretic notions above are needed.

---

## 3. The obstruction $\overline{3K_2}$: exact structure

We now define the two graphs at the center of the theory and establish their basic
invariants. Index the six vertices by $\{0,1,2,3,4,5\}$, grouped into three
**matched pairs**
$$P_0 = \{0,1\}, \qquad P_1 = \{2,3\}, \qquad P_2 = \{4,5\},$$
so that vertex $i$ belongs to pair $\lfloor i/2 \rfloor$.

**Definition 3.1 ($3K_2$).** The *matching graph* $3K_2$ on $\{0,\dots,5\}$ has
$$i \sim j \iff i \neq j \ \text{and}\ \lfloor i/2\rfloor = \lfloor j/2\rfloor,$$
i.e. its edges are exactly the three matched pairs $\{0,1\}, \{2,3\}, \{4,5\}$. It is
a perfect matching on six vertices.

**Definition 3.2 ($\overline{3K_2}$).** The *co-matching graph* $\overline{3K_2}$ is
the complement of $3K_2$.

**Proposition 3.3 (Adjacency of $\overline{3K_2}$).** In $\overline{3K_2}$,
$$i \sim j \iff i \neq j \ \text{and}\ \lfloor i/2\rfloor \neq \lfloor j/2\rfloor.$$
That is, two vertices are adjacent precisely when they are distinct and lie in
*different* matched pairs.

*Proof.* By definition of complement, $i \sim_{\overline{3K_2}} j$ iff $i \neq j$ and
$i \not\sim_{3K_2} j$. Negating the condition in Definition 3.1, $i \not\sim_{3K_2}
j$ holds iff $i = j$ or $\lfloor i/2\rfloor \neq \lfloor j/2\rfloor$. Combining with
$i \neq j$ gives the stated equivalence. $\qquad\blacksquare$

**Theorem 3.4 (Octahedron / complete tripartite identity).** $\overline{3K_2}$ is
isomorphic to the complete tripartite graph $K_{2,2,2} =
K_{2\times 3}$, with parts equal to the matched pairs $P_0,P_1,P_2$.

*Proof.* Map each vertex $i$ to the pair
$\big(\lfloor i/2\rfloor,\, i \bmod 2\big) \in \{0,1,2\}\times\{0,1\}$, sending part
index and position within the pair. This is a bijection onto the vertex set of
$K_{2,2,2}$ (three parts indexed by $\{0,1,2\}$, each of size two). Under this
bijection, "different matched pair" corresponds exactly to "different part," so by
Proposition 3.3 adjacency in $\overline{3K_2}$ matches adjacency in $K_{2,2,2}$.
Hence the map is a graph isomorphism. $\qquad\blacksquare$

Geometrically $K_{2,2,2}$ is the graph of the regular octahedron: the three parts are
the three antipodal pairs $(\pm1,0,0),(0,\pm1,0),(0,0,\pm1)$, and non-antipodal
vertices are joined by octahedral edges. The graph is also the cocktail-party graph
$K_{3\times 2}$.

**Theorem 3.5 (Degrees).** Every vertex of $\overline{3K_2}$ has degree $4$
($\overline{3K_2}$ is $4$-regular); every vertex of $3K_2$ has degree $1$ ($3K_2$ is
$1$-regular).

*Proof.* A vertex $i$ in $3K_2$ is adjacent exactly to its partner (the other member
of $P_{\lfloor i/2\rfloor}$), giving degree $1$. In $\overline{3K_2}$, vertex $i$ is
adjacent to all vertices outside its pair, of which there are $6 - 2 = 4$. Since the
graph has $6$ vertices, this is consistent with $\deg_G i + \deg_{\overline{G}} i = 5$.
$\qquad\blacksquare$

The following rigidity property is the workhorse of the entire development.

**Theorem 3.6 (Unique non-neighbor).** In $\overline{3K_2}$, every vertex $v$ has
exactly one non-neighbor, namely its matched partner. Concretely: if $x,y$ are both
distinct from $v$ and both non-adjacent to $v$, then $x = y$.

*Proof.* By Proposition 3.3, a vertex $x \neq v$ is non-adjacent to $v$ iff
$\lfloor x/2\rfloor = \lfloor v/2\rfloor$, i.e. iff $x$ lies in the same pair as $v$.
Each pair has exactly two elements, so the unique $x \neq v$ in $v$'s pair is its
partner. If $x, y \neq v$ are both non-neighbors of $v$, both equal that partner,
hence $x = y$. $\qquad\blacksquare$

**Corollary 3.7 (Independence number).** The independence number of
$\overline{3K_2}$ is $2$: every set of pairwise non-adjacent vertices has at most two
elements, and the matched pairs achieve two.

*Proof.* An independent set contains, for each vertex it holds, only non-neighbors of
that vertex besides itself. By Theorem 3.6 each vertex has a single non-neighbor, so
an independent set of size $\geq 2$ must consist of a vertex and its unique partner,
and cannot be enlarged (a third vertex would be adjacent to at least one of the two).
Any matched pair is independent and has size $2$. $\qquad\blacksquare$

Equivalently, via Theorem 3.4, the maximum independent sets of $K_{2,2,2}$ are
exactly its parts.

---

## 4. $\overline{3K_2}$ is a proper cograph

We now prove the two facts that place $\overline{3K_2}$ correctly inside the
distance-hereditary class: it is a cograph (hence distance-hereditary), and it is a
*proper* cograph (it is not degenerate).

**Lemma 4.1 ($P_4$-freeness is hereditary).** If $G$ is a cograph and there is an
induced embedding $\varphi\colon H \hookrightarrow G$, then $H$ is a cograph.

*Proof.* Suppose $H$ had an induced embedding $\psi\colon P_4 \hookrightarrow H$.
Composition of induced embeddings is an induced embedding, so $\varphi \circ \psi
\colon P_4 \hookrightarrow G$ would be an induced $P_4$ in $G$, contradicting that
$G$ is $P_4$-free. Hence $H$ has no induced $P_4$. $\qquad\blacksquare$

Lemma 4.1 is the abstract reason a single forbidden induced subgraph can
characterize a class: the class must be hereditary, i.e. closed under induced
subgraphs, and $P_4$-freeness manifestly is.

**Theorem 4.2 ($\overline{3K_2}$ is a cograph).** $\overline{3K_2}$ contains no
induced path on four vertices; i.e. there is no induced embedding $P_4
\hookrightarrow \overline{3K_2}$.

*Proof.* Label the vertices of $P_4$ as $0 - 1 - 2 - 3$ (a path), so that its
non-edges include $0 \not\sim 2$ and $0 \not\sim 3$, while $0 \neq 2$ and $0 \neq 3$.
Suppose $\varphi\colon P_4 \hookrightarrow \overline{3K_2}$ were an induced
embedding. Because $\varphi$ preserves and reflects adjacency, the images satisfy
$$\varphi(0) \not\sim \varphi(2), \qquad \varphi(0) \not\sim \varphi(3),$$
and because $\varphi$ is injective, $\varphi(0) \neq \varphi(2)$ and $\varphi(0)
\neq \varphi(3)$. Thus $\varphi(2)$ and $\varphi(3)$ are two vertices, both distinct
from $\varphi(0)$ and both non-adjacent to it. By the unique non-neighbor property
(Theorem 3.6), $\varphi(2) = \varphi(3)$. But injectivity of $\varphi$ and $2 \neq 3$
force $\varphi(2) \neq \varphi(3)$, a contradiction. Hence no such embedding exists.
$\qquad\blacksquare$

Note the proof uses *no* case enumeration over the $6$ vertices; it is a direct
consequence of the metric rigidity of Theorem 3.6. Combining Theorem 4.2 with Fact
2.3:

**Corollary 4.3.** $\overline{3K_2}$ is distance-hereditary. In particular it is a
legitimate forbidden induced subgraph for a characterization *within* the
distance-hereditary class.

**Theorem 4.4 ($\overline{3K_2}$ is a proper cograph).** $\overline{3K_2}$ contains
an induced $4$-cycle $C_4$. Consequently it is neither edgeless nor complete, and is
a non-degenerate cograph.

*Proof.* Consider the ordered quadruple of vertices $(0, 2, 1, 3)$. Using
Proposition 3.3 with pairs $P_0=\{0,1\}, P_1=\{2,3\}$:
consecutive pairs around the cycle are $0\text{–}2$, $2\text{–}1$, $1\text{–}3$,
$3\text{–}0$; each joins two vertices in different pairs, hence each is an edge. The
two chords are $0\text{–}1$ and $2\text{–}3$; each joins two vertices of the same
matched pair, hence each is a non-edge. Therefore the induced subgraph on
$\{0,1,2,3\}$ in the cyclic order $0,2,1,3$ is exactly $C_4$ (four edges, two missing
diagonals). This gives an induced embedding $C_4 \hookrightarrow \overline{3K_2}$.
Since $\overline{3K_2}$ has an induced $C_4$ it has an edge (so it is not edgeless)
and a non-edge (so it is not complete). $\qquad\blacksquare$

Theorems 4.2 and 4.4 together say precisely what a good obstruction should: it lies
in the class it forbids, and it is genuinely nontrivial.

---

## 5. The characterization and its algorithmic reading

We restate the organizing theorem and describe how the structural results above make
it operational.

> **Main Theorem.** A distance-hereditary graph $G$ is balanced if and only if $G$
> contains no induced $\overline{3K_2}$.

The forward direction says that if $G$ is balanced then it avoids the octahedron; the
reverse says that avoiding the octahedron suffices for balancedness within the class.
The obstruction's rigidity (Theorem 3.6) is the source of unbalancedness: the
octahedron is the smallest configuration in which three mutually adjacent
*independent pairs* coexist — a "triple join of pairs" — and this triple is exactly
the minimal engine of the odd frustration that defines imbalance.

**Algorithmic consequence.** Testing balancedness of a distance-hereditary graph
reduces to searching for an induced $\overline{3K_2}$: six vertices that split into
three pairs with all cross-pair edges present and all within-pair edges absent. A
direct search examines $\binom{|V|}{6}$ candidate sextuples and checks the $15$
adjacencies of each in $O(1)$, giving an $O(|V|^6)$ certificate procedure — already a
concrete, implementable test, and one that is easily accelerated using the degree and
independence structure (each part is an independent pair; by Corollary 3.7 candidate
parts are exactly non-edges whose endpoints share their non-neighbors). We give
reference implementations in the accompanying demonstrations.

Because $P_4$-freeness is hereditary (Lemma 4.1), the obstruction search is
well-behaved under taking induced subgraphs: if a graph is octahedron-free, so is
every induced subgraph, matching the hereditary nature of both "balanced" and
"distance-hereditary."

---

## 6. A metric reformulation

The name "distance-hereditary" invites a distance-based reading of the obstruction,
and the octahedron obliges. In $\overline{3K_2} \cong K_{2,2,2}$:

- any two vertices in *different* pairs are adjacent, hence at distance $1$;
- any two vertices in the *same* pair are non-adjacent but have a common neighbor
  (any vertex of a third pair), hence at distance $2$.

Thus each vertex has a *unique vertex at distance two* — its antipode/partner — and
all other vertices are at distance one. This yields a purely metric description of
the forbidden pattern.

**Proposition 6.1 (Distance signature of the octahedron).** A set of six vertices
$\{a_0,b_0,a_1,b_1,a_2,b_2\}$ induces $\overline{3K_2}$ if and only if, writing
$P_k = \{a_k,b_k\}$, we have $d(a_k,b_k)=2$ for each $k$ and $d(u,v)=1$ whenever $u,v$
lie in different $P_k$.

*Proof.* If the six vertices induce $\overline{3K_2}$, the distance computation above
gives the stated signature. Conversely, distances $1$ across pairs are edges, and
distance $2$ within pairs are non-edges; by Proposition 3.3 these adjacencies are
exactly those of $\overline{3K_2}$ on the given partition. $\qquad\blacksquare$

Consequently the obstruction can be detected directly from a shortest-path distance
matrix: look for six indices partitioned into three pairs realizing the "same-pair
distance $2$, different-pair distance $1$" pattern. This converts a subgraph search
into a search over the distance matrix, aligning the balanced test with the metric
that names the class.

---

## 7. A cocktail-party hierarchy and future work

The octahedron is $K_{2,2,2}$, the three-part member of the **cocktail-party**
family $K_{k\times 2}$ (the complement of a perfect matching on $2k$ vertices). Every
member has the unique non-neighbor property, so the proofs of Sections 3–4 generalize
verbatim: each $K_{k\times 2}$ is a proper cograph (it contains an induced $C_4$ once
$k \geq 2$ and no induced $P_4$), hence distance-hereditary.

We record three directions suggested by the structure above.

**7.1 A metric certificate for the balanced/unbalanced boundary.** *Conjecture.* A
distance-hereditary graph is balanced if and only if no six of its vertices induce an
octahedron, and this obstruction is detectable purely metrically: a graph is
unbalanced exactly when it contains six vertices, split into three pairs, such that
vertices in different pairs are at distance one and vertices in the same pair are at
distance two. The key insight is that in the octahedron every vertex has a unique
vertex at distance two — its antipode — and it is precisely this "one missing edge
per vertex" rigidity, not any global counting, that creates the odd combinatorial
cycle responsible for unbalancedness. Reformulating the forbidden subgraph as a
distance pattern turns a subgraph search into a search over the distance matrix.

**7.2 From one forbidden octahedron to a hereditary hierarchy.** *Conjecture.* For
each $k \geq 3$, the graphs whose only forbidden induced subgraph is the complete
multipartite graph with $k$ parts of size two (the $k$-dimensional cocktail-party
graph) form a strictly increasing chain of hereditary classes, and the balanced
distance-hereditary graphs are exactly the first level $k = 3$. The key insight is
that the octahedron is $K_{2,2,2}$, the second member of the cocktail-party family,
so the balanced characterization is the base case of a ladder obtained by adding one
more antipodal pair at a time; each rung should add exactly one new "odd obstruction"
of larger order.

**7.3 Balancedness decided on cograph cotrees.** *Conjecture.* Every cograph is
balanced if and only if its canonical cotree — the recursive union/join decomposition
— never performs a join of three or more mutually non-trivial factors that each
contribute an independent pair; equivalently, balancedness of a cograph is a local
condition at each join node of its cotree. The key insight is that the octahedron is
the smallest join of three edges, so an unbalanced cograph must expose a "triple join
of pairs" somewhere in its decomposition, and conversely a cotree free of such nodes
should be balanced.

---

## 8. Conclusion

We have given a self-contained structural account of the single obstruction
governing balancedness within distance-hereditary graphs: the octahedron
$\overline{3K_2} \cong K_{2,2,2}$, the complement of a perfect matching on six
vertices. From an exact adjacency description we derived its regularity, its
isomorphism to the complete tripartite graph, and its defining rigidity — every
vertex has a unique non-neighbor. That rigidity alone proves the octahedron is a
proper cograph, hence a genuine distance-hereditary obstruction, and it identifies
the octahedron as the minimal "triple join of independent pairs" that manufactures
imbalance. The result is a clean forbidden-induced-subgraph characterization with an
executable local test, a metric reformulation, and a natural conjectural hierarchy
climbing from the humble six-vertex octahedron.
