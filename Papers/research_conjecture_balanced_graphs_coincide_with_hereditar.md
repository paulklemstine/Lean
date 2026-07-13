# A Combinatorial Bridge Between Balanced Clique Matrices and Clique‑Helly Graphs

## Abstract

We study a conjectured three‑way equivalence for finite simple graphs relating a
linear‑algebraic property of the clique matrix (*balancedness*), a
graph‑theoretic Helly property of maximal cliques (the *hereditary clique‑Helly*
property), and a single forbidden induced subgraph (the octahedron
$K_{2,2,2}$, equivalently the complement of a perfect matching $3K_2$). Our
central contribution is the isolation of a single combinatorial configuration —
a **bad triple** of maximal cliques — that simultaneously obstructs *both*
balancedness and the clique‑Helly property. We prove that any graph carrying a
bad triple is neither balanced nor clique‑Helly, that the octahedron carries
such a triple, and that clique‑Helly‑ness is invariant under isomorphism.
Combining these facts yields two of the three implications of the conjecture in
full generality: every hereditary clique‑Helly graph, and every hereditary
balanced graph, is octahedron‑free. We discuss the obstacles to the remaining
implications and outline the theory of balanced matrices needed to complete the
program.

**Keywords.** balanced matrix, clique matrix, clique‑Helly graph, hereditary
property, octahedron, $K_{2,2,2}$, forbidden induced subgraph, Helly property.

## 1. Introduction

Two well‑studied notions of "good structure" in combinatorics arise in very
different settings.

In **polyhedral combinatorics and integer programming**, a $0/1$ matrix is
*balanced* if it contains no odd square submatrix in which every row and every
column has exactly two ones. Balanced matrices generalize totally balanced and
network matrices, and the linear systems they define enjoy strong integrality
properties, making them central to the theory of perfect and ideal $0/1$
systems.

In **structural graph theory**, a graph is *clique‑Helly* when its maximal
cliques satisfy the Helly property: any pairwise‑intersecting subfamily has a
common vertex. The *hereditary* version — every induced subgraph is clique‑Helly
— is the stable notion and admits a finite forbidden‑configuration
characterization.

The clique matrix of a graph — rows indexed by maximal cliques, columns by
vertices, with a $1$ marking membership — is the natural object linking the two
worlds. The following conjecture asserts that, read through the clique matrix,
the two notions coincide and are pinned down by one forbidden shape.

**Conjecture.** *For every finite simple graph $G$, the following are
equivalent:*

- *(i)* $G$ *is balanced: its clique matrix contains no odd square submatrix
  with exactly two ones in each row and each column;*
- *(ii)* $G$ *is hereditary clique‑Helly;*
- *(iii)* $G$ *contains no induced copy of the octahedron $K_{2,2,2}$,
  equivalently no induced copy of the complement of $3K_2$.*

This paper establishes the "downward" implications $(i)\Rightarrow(iii)$ and
$(ii)\Rightarrow(iii)$ through a unified mechanism, and lays out the structure
required for the converses.

Our organizing principle is a **cross‑domain bridge**: rather than proving the
two implications separately, we identify a *single* combinatorial object whose
presence breaks both properties at once.

## 2. Definitions

Throughout, $G = (V, E)$ is a finite simple graph. We write $u \sim v$ for
adjacency. For $S \subseteq V$, $S$ is a **clique** if its vertices are pairwise
adjacent.

**Definition 2.1 (Maximal clique).** A finite set $K \subseteq V$ is a *maximal
clique* of $G$ if $K$ is a clique and, for every vertex $v \notin K$, the set
$K \cup \{v\}$ is not a clique.

**Definition 2.2 (Clique‑Helly property).** $G$ is *clique‑Helly* if for every
finite family $\mathcal F$ of maximal cliques that is **pairwise intersecting**
(i.e. $K_1 \cap K_2 \neq \varnothing$ for all $K_1, K_2 \in \mathcal F$), the
whole family has a common vertex: $\bigcap_{K \in \mathcal F} K \neq
\varnothing$.

**Definition 2.3 (Clique matrix and balancedness).** The *clique matrix* of $G$
is the $0/1$ matrix $M$ whose rows are the maximal cliques, whose columns are
the vertices, and with $M_{K,v} = 1$ iff $v \in K$. We call $G$ **balanced** if
$M$ contains no *odd* square submatrix having exactly two $1$'s in every row and
every column. Explicitly, $G$ fails to be balanced exactly when there exist an
odd integer $k$, distinct maximal cliques $K_1, \dots, K_k$, and distinct
vertices $v_1, \dots, v_k$ such that each $K_i$ contains exactly two of the
$v_j$, and each $v_j$ lies in exactly two of the $K_i$.

**Definition 2.4 (Bad triple).** A *bad triple* in $G$ consists of three
pairwise‑distinct maximal cliques $K_0, K_1, K_2$ and three pairwise‑distinct
vertices $a, b, c$ realizing the cyclic ("$C_3$") incidence pattern
$$
a \in K_1 \cap K_2 \setminus K_0, \quad
b \in K_0 \cap K_2 \setminus K_1, \quad
c \in K_0 \cap K_1 \setminus K_2,
$$
and satisfying $K_0 \cap K_1 \cap K_2 = \varnothing$.

**Definition 2.5 (Hereditary properties).** $G$ is *hereditary clique‑Helly* if
every graph $H$ that admits an induced embedding $H \hookrightarrow G$ is
clique‑Helly. Similarly, $G$ is *hereditary balanced* if every such $H$ is
balanced. (An induced embedding is an injection on vertices preserving both
adjacency and non‑adjacency.)

**Definition 2.6 (Octahedron and its matching).** Label $V = \{0,1,2,3,4,5\}$
with the three antipodal pairs $\{0,1\}, \{2,3\}, \{4,5\}$. The **octahedron**
$\mathrm{Oct} = K_{2,2,2}$ has $i \sim j$ iff $i \neq j$ and $i, j$ lie in
different pairs (equivalently $\lfloor i/2\rfloor \neq \lfloor j/2\rfloor$). The
matching $3K_2$ has $i \sim j$ iff $i \neq j$ and $i, j$ lie in the same pair.

## 3. The bridge

The technical core of the paper is that a bad triple is a *shared* obstruction.

### 3.1 The graph‑theoretic obstruction

**Theorem 3.1.** *If $G$ contains a bad triple, then $G$ is not clique‑Helly.*

*Proof sketch.* Take the family $\mathcal F = \{K_0, K_1, K_2\}$. Each member is
a maximal clique by hypothesis. The family is pairwise intersecting: $c \in K_0
\cap K_1$, $b \in K_0 \cap K_2$, and $a \in K_1 \cap K_2$. Yet the defining
condition $K_0 \cap K_1 \cap K_2 = \varnothing$ says no vertex lies in all
three. Thus $\mathcal F$ is a pairwise‑intersecting family of maximal cliques
with empty total intersection, which is exactly a violation of the clique‑Helly
property. $\qquad\blacksquare$

### 3.2 The matrix‑theoretic obstruction

**Theorem 3.2.** *If $G$ contains a bad triple, then $G$ is not balanced.*

*Proof sketch.* Use rows $K_0, K_1, K_2$ and columns $a, b, c$; here $k = 3$ is
odd, the three cliques are distinct, and the three vertices are distinct. The
incidence pattern of Definition 2.4 gives the $3\times 3$ submatrix
$$
\begin{array}{c|ccc}
 & a & b & c \\\hline
K_0 & 0 & 1 & 1 \\
K_1 & 1 & 0 & 1 \\
K_2 & 1 & 1 & 0
\end{array}
$$
because $a \notin K_0$ but $a \in K_1, K_2$; $b \in K_0$, $b \notin K_1$,
$b \in K_2$; and $c \in K_0, K_1$, $c \notin K_2$. Each row has exactly two
$1$'s and each column has exactly two $1$'s, and $3$ is odd. This is precisely a
forbidden submatrix, so $G$ is not balanced. $\qquad\blacksquare$

Theorems 3.1 and 3.2 are twins: they are read off from the *same* configuration,
one via the Helly property of set systems, the other via the incidence matrix of
those same sets. This is the bridge.

### 3.3 Isomorphism invariance

To promote a single‑graph obstruction to a hereditary statement we need the
Helly property to be transportable along isomorphisms.

**Theorem 3.3.** *If $e : G \xrightarrow{\ \cong\ } H$ is a graph isomorphism
and $G$ is clique‑Helly, then $H$ is clique‑Helly.*

*Proof sketch.* Given a pairwise‑intersecting family $\mathcal F$ of maximal
cliques of $H$, pull it back through $e^{-1}$ to a family
$e^{-1}(\mathcal F)$ in $G$. An isomorphism preserves adjacency and
non‑adjacency, hence sends maximal cliques to maximal cliques and preserves all
intersections. Thus $e^{-1}(\mathcal F)$ is a pairwise‑intersecting family of
maximal cliques of $G$; by hypothesis it has a common vertex $v$. Then $e(v)$
lies in every member of $\mathcal F$. $\qquad\blacksquare$

## 4. The octahedron carries a bad triple

We now instantiate the bridge on the octahedron.

**Lemma 4.1.** *In $\mathrm{Oct}$, each transversal triangle
$\{0,2,4\}$, $\{1,2,5\}$, $\{1,3,4\}$ (one vertex from each antipodal pair) is a
maximal clique.*

*Proof sketch.* Any two vertices drawn from different pairs are adjacent, so a
transversal set of three is a clique. Adding a fourth vertex forces two vertices
into the same antipodal pair, which are non‑adjacent; hence the triangle is
maximal. A direct finite check confirms each of the three named triples.
$\qquad\blacksquare$

**Proposition 4.2.** *The three triangles*
$$
K_0 = \{0,2,4\},\quad K_1 = \{1,2,5\},\quad K_2 = \{1,3,4\}
$$
*together with $a = 1$, $b = 4$, $c = 2$ form a bad triple of $\mathrm{Oct}$.*

*Proof sketch.* The three cliques are maximal (Lemma 4.1) and pairwise distinct.
The incidences hold: $a = 1 \in K_1 \cap K_2$ and $1 \notin K_0$;
$b = 4 \in K_0 \cap K_2$ and $4 \notin K_1$; $c = 2 \in K_0 \cap K_1$ and
$2 \notin K_2$. The vertices $1, 4, 2$ are distinct, and a finite check shows no
vertex lies in all of $K_0, K_1, K_2$. $\qquad\blacksquare$

**Corollary 4.3.** *The octahedron is neither clique‑Helly nor balanced.*

*Proof.* Immediate from Proposition 4.2 with Theorems 3.1 and 3.2.
$\qquad\blacksquare$

**Proposition 4.4 (Identification of the shape).** *The complement of $3K_2$ is
the octahedron: $(3K_2)^{\mathsf c} = K_{2,2,2}$.*

*Proof sketch.* Two distinct vertices are non‑adjacent in $3K_2$ iff they lie in
different antipodal pairs; complementing turns exactly those into edges, which is
the adjacency of $\mathrm{Oct}$. $\qquad\blacksquare$

## 5. The hereditary implications

**Theorem 5.1 (Implication (ii) $\Rightarrow$ (iii)).** *A hereditary
clique‑Helly graph contains no induced octahedron.*

*Proof.* Suppose $G$ is hereditary clique‑Helly and admits an induced embedding
$\mathrm{Oct} \hookrightarrow G$. By heredity $\mathrm{Oct}$ is clique‑Helly,
contradicting Corollary 4.3. $\qquad\blacksquare$

**Theorem 5.2 (Implication (i) $\Rightarrow$ (iii), matrix side).** *A
hereditary balanced graph contains no induced octahedron.*

*Proof.* Symmetric to Theorem 5.1, using that $\mathrm{Oct}$ is not balanced
(Corollary 4.3). $\qquad\blacksquare$

**Theorem 5.3 (The unified bridge).** *The complement of $3K_2$ is the
octahedron, and it is simultaneously not balanced and not clique‑Helly; both
failures are witnessed by the same bad triple.*

This packages Propositions 4.2, 4.4 and Corollary 4.3 into the single statement
that makes the octahedron the concrete meeting point of the two worlds.

## 6. Algorithms

The results above translate directly into finite checks. We describe three.

**Algorithm A (Bad‑triple detector).** Given a graph and its maximal cliques,
search over unordered triples of maximal cliques and test the bad‑triple
pattern: pairwise intersections nonempty, total intersection empty, with three
witness vertices in the cyclic incidence pattern. Complexity is $O(m^3 \cdot n)$
in the number of maximal cliques $m$ and vertices $n$. A positive result
certifies *both* non‑balancedness and non‑clique‑Helly‑ness.

**Algorithm B (Balancedness sub‑check via odd two‑regular submatrices).** Given
a $0/1$ matrix, enumerate candidate square submatrices of small odd order and
test the two‑per‑row‑and‑column condition; the $3\times3$ case already captures
the octahedral obstruction. Detecting the full balancedness property in general
requires the bipartite even‑cycle reformulation discussed in §8.

**Algorithm C (Induced‑octahedron search).** Given a graph, test each
$6$‑subset of vertices for isomorphism to $K_{2,2,2}$ by checking that the
induced subgraph is $4$‑regular with exactly three non‑edges forming a perfect
matching. Complexity $O(n^6)$ naively; a positive result forbids both hereditary
properties by Theorems 5.1 and 5.2.

## 7. Applications

- **Certifying integrality.** Balanced clique matrices give integral polytopes
  for the associated set‑covering and set‑packing problems. A visual,
  local octahedron test provides a fast *necessary* certificate: any graph
  containing an induced octahedron cannot have a balanced clique matrix, ruling
  out the strongest integrality guarantees before any linear program is solved.

- **Recognizing hereditary clique‑Helly graphs.** The bad‑triple detector gives
  a direct witness of failure, useful in algorithms that must decide or exploit
  the clique‑Helly property (e.g. in clique‑graph dynamics and fixed‑point
  questions for the clique operator).

- **Structural decomposition.** Forbidden‑subgraph characterizations feed
  decomposition theorems; a single forbidden octahedron, where valid, is the
  most economical possible obstruction and simplifies such decompositions.

## 8. Discussion and future work

The two implications proved here flow from one obstruction, but the converses
are genuinely harder.

**The hard direction $(iii)\Rightarrow(i)$: octahedron‑free $\Rightarrow$
balanced.** The subtlety is that balancedness concerns the matrix of *maximal*
cliques of the ambient graph, whereas a triangle of an induced octahedron need
not remain maximal in a larger host. A faithful route requires a genuine theory
of balanced $0/1$ matrices: closure under taking submatrices, together with a
precise relation between the clique matrix of an induced subgraph and that of the
whole graph. This is the classical Berge / Conforti–Cornuéjols–Rao theory, not a
single forbidden pattern.

**The reverse $(iii)\Rightarrow(ii)$.** Prisner's theorem characterizes
hereditary clique‑Helly graphs by *three* forbidden "ocular" (Hajós‑type)
configurations, not by the octahedron alone. Showing that forbidding only
$(3K_2)^{\mathsf c}$ is equivalent would require reconciling the
single‑obstruction claim with Prisner's list, and may need an additional
hypothesis such as the distance‑hereditary restriction of the motivating source.

**A general balanced‑matrix library.** The natural foundation is a
domain‑independent notion of a balanced $0/1$ matrix, with the
closure‑under‑submatrix lemma and the bipartite "even‑cycle" reformulation
(a $0/1$ matrix is balanced iff its bipartite representation graph has no
induced odd cycle of length $\geq 3$ with the two‑regular pattern). The
graph‑level notion of balancedness would then be a special case.

**Full clique enumeration of the octahedron.** Proving that the eight
transversal triangles are *exactly* the maximal cliques of $\mathrm{Oct}$ yields
its entire clique matrix and lets one exhibit the octahedral obstruction in
completely explicit matrix form.

## 9. Conclusion

We isolated a single combinatorial configuration — the bad triple — and showed
it simultaneously breaks the linear‑algebraic property of balancedness and the
graph‑theoretic clique‑Helly property. The octahedron $K_{2,2,2} =
(3K_2)^{\mathsf c}$ carries such a triple, yielding two clean hereditary
implications toward a conjectured single‑forbidden‑subgraph characterization of
balanced graphs. The bad triple is the bridge; the octahedron is where the two
worlds visibly meet.
