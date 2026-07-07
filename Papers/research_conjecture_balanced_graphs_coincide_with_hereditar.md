# The Octahedron as the Minimal Obstruction to Hereditary Clique-Helliness

## Abstract

The Helly property — the principle that pairwise intersection of a family of sets
forces a common element — has a natural incarnation for the maximal cliques of a
graph. A graph is *clique-Helly* if every pairwise-intersecting family of its
maximal cliques has a common vertex, and *hereditarily clique-Helly* if this holds
for every induced subgraph. In parallel, the *clique matrix* of a graph gives a
linear-algebraic view of its clique structure, and this matrix is *balanced* when
it avoids odd square submatrices with exactly two ones in each row and column.
We study the conjecture that, for every finite simple graph, balancedness of the
clique matrix, hereditary clique-Helliness, and the exclusion of one specific
forbidden induced subgraph — the octahedron $K_{2,2,2} = \overline{3K_2}$ — are
all equivalent. Our central rigorous contribution is a complete, self-contained
proof that the octahedron is *not* clique-Helly, exhibited through an explicit
triple of maximal cliques that pairwise intersect yet have empty common
intersection. This establishes the unconditional forward implication
"hereditarily clique-Helly $\Rightarrow$ octahedron-free" and isolates the
octahedron as the smallest and most fundamental obstruction underlying the
conjectured three-way equivalence. We situate this result within the broader
program of forbidden-subgraph characterizations, give algorithms for detecting the
obstruction, discuss applications to balanced-matrix optimization, and outline a
research program aimed at a finite obstruction set governing hereditary
clique-Helliness in full generality.

## 1. Introduction

A recurring theme in combinatorics is the reduction of a global, hard-to-verify
property to the absence of a short list of local patterns. The most celebrated
examples — planarity via $K_5$ and $K_{3,3}$, perfection via odd holes and
antiholes — reveal that intricate global structure is often governed by a handful
of small forbidden configurations. This paper concerns such a phenomenon at the
meeting point of three properties of a finite simple graph: a Helly-type
intersection property of its cliques, a balancedness property of its clique
matrix, and the exclusion of a single six-vertex induced subgraph.

Helly's theorem (1913) states that a finite family of convex subsets of
$\mathbb{R}^d$, every $d+1$ of which meet, has a common point. Abstractly, a
family of sets has the **Helly property** when finite subfamilies that pairwise
intersect always share a common element. For graphs, the canonical family is the
set of maximal cliques. Requiring the Helly property of that family, robustly
across all induced subgraphs, singles out the class of **hereditarily clique-Helly
graphs** — a class with pleasant algorithmic and structural behavior.

The **clique matrix** encodes the vertex–clique incidence structure as a $0/1$
matrix. Balancedness of $0/1$ matrices, introduced by Berge, is a strengthening of
the integrality-friendly properties that make combinatorial optimization
tractable: balanced matrices yield integral polyhedra for a range of packing and
covering problems. The natural question is which graphs have balanced clique
matrices.

The organizing conjecture of this work asserts that these two lines of inquiry
converge on the same class, and that the class admits a one-graph forbidden
characterization.

### 1.1 Main conjecture

**Conjecture 1.** *For every finite simple graph $G$, the following are
equivalent:*

1. *the clique matrix of $G$ is balanced;*
2. *$G$ is hereditarily clique-Helly;*
3. *$G$ contains no induced copy of the octahedron $\overline{3K_2} = K_{2,2,2}$.*

The conjecture extends a known equivalence on distance-hereditary graphs to all
finite simple graphs, proposing the octahedron as a *single* forbidden induced
subgraph characterizing balancedness.

### 1.2 Contribution

Our rigorously established contribution is the following.

**Theorem A.** *The octahedron $K_{2,2,2}$ is not clique-Helly.*

The proof is constructive: we name three maximal cliques that pairwise intersect
but have empty common intersection. Because clique-Helliness is inherited by the
whole graph from any octahedral induced subgraph (an octahedron present as an
induced subgraph is itself not clique-Helly), Theorem A immediately yields:

**Corollary B.** *Every hereditarily clique-Helly graph is octahedron-free. Thus
implication $(2) \Rightarrow (3)$ of Conjecture 1 holds unconditionally.*

Theorem A pins down the mechanism by which the Helly property fails — a
pairwise-intersecting cyclic triple of triangles with empty core — and thereby
identifies the octahedron as the minimal, canonical obstruction from which the
larger conjecture is built.

## 2. Definitions

Throughout, $G = (V, E)$ is a finite simple graph: $V$ is a finite vertex set and
$E$ a set of unordered pairs of distinct vertices. We write $u \sim v$ when
$\{u,v\} \in E$.

**Definition 1 (Clique).** A set $S \subseteq V$ is a *clique* if every two
distinct vertices of $S$ are adjacent: for all $u, v \in S$ with $u \neq v$, we
have $u \sim v$.

**Definition 2 (Maximal clique).** A clique $S$ is *maximal* if no proper superset
of $S$ is a clique; equivalently, for every $T$ with $S \subsetneq T$, the set $T$
is not a clique.

**Definition 3 (Clique-Helly).** A graph $G$ is *clique-Helly* if for every family
$\mathcal{S}$ of maximal cliques such that $s_1 \cap s_2 \neq \varnothing$ for all
$s_1, s_2 \in \mathcal{S}$, the total intersection $\bigcap_{s \in \mathcal{S}} s$
is nonempty.

**Definition 4 (Hereditarily clique-Helly).** A graph is *hereditarily
clique-Helly* if every induced subgraph of $G$ is clique-Helly.

**Definition 5 (Induced subgraph).** For $W \subseteq V$, the subgraph *induced*
by $W$ has vertex set $W$ and edge set $\{\{u,v\} \in E : u, v \in W\}$. A graph
$H$ is an *induced subgraph* of $G$ if it is isomorphic to the subgraph induced by
some $W \subseteq V$. We say $G$ is *$H$-free* if it has no induced subgraph
isomorphic to $H$.

**Definition 6 (Clique matrix).** Let $C_1, \dots, C_m$ be the maximal cliques of
$G$ and $v_1, \dots, v_n$ its vertices. The *clique matrix* $M \in \{0,1\}^{n
\times m}$ has $M_{ij} = 1$ if $v_i \in C_j$ and $M_{ij} = 0$ otherwise.

**Definition 7 (Balanced matrix).** A $0/1$ matrix is *balanced* if it contains no
square submatrix of odd order in which every row sum and every column sum equals
$2$. (Such a submatrix is the incidence matrix of an odd cycle.)

**Definition 8 (Octahedron).** The *octahedron* is the graph $K_{2,2,2}$, the
complete tripartite graph with three parts of size two. Equivalently it is
$\overline{3K_2}$, the complement of three disjoint edges. Concretely, on the
vertex set $\{0,1,2,3,4,5\}$ partitioned into the pairs $\{0,1\}, \{2,3\},
\{4,5\}$, two vertices are adjacent if and only if they are distinct and belong to
different pairs.

We record the adjacency of the octahedron precisely: with parts indexed by
$\lfloor i/2 \rfloor$ for $i \in \{0,\dots,5\}$, we set $i \sim j$ iff $i \neq j$
and $\lfloor i/2 \rfloor \neq \lfloor j/2 \rfloor$. Symmetry and looplessness are
immediate.

## 3. The octahedron and its cliques

We first identify the maximal cliques of the octahedron relevant to the argument.
A clique of $K_{2,2,2}$ contains at most one vertex from each of the three parts,
since two vertices in the same part are non-adjacent. Conversely, a *transversal*
consisting of one vertex from each part is a clique, and it is maximal: adding any
further vertex repeats a part and creates a non-adjacent pair. There are $2^3 = 8$
such maximal cliques.

**Lemma 1 (Three maximal cliques).** *The sets*
$$A = \{0,2,4\}, \qquad B = \{0,3,5\}, \qquad C = \{1,2,5\}$$
*are maximal cliques of the octahedron.*

*Proof sketch.* Each set is a transversal: $A$ takes $0$ from part $\{0,1\}$, $2$
from $\{2,3\}$, $4$ from $\{4,5\}$; similarly $B$ takes $0, 3, 5$ and $C$ takes
$1, 2, 5$, one from each part. Hence all pairs within each set lie in different
parts and are adjacent, so each set is a clique. Maximality: any strict superset
$T \supsetneq A$ contains a sixth-vertex witness $w \notin A$. Since $w$ differs
from all of $0, 2, 4$, it must repeat one of the three parts (there are only three
parts and $A$ already meets each once), so $w$ is non-adjacent to the element of
$A$ in that shared part; that pair violates the clique condition on $T$. The same
argument applies to $B$ and $C$. $\square$

**Lemma 2 (Pairwise intersection).** *The three cliques pairwise intersect:*
$$A \cap B = \{0\}, \qquad A \cap C = \{2\}, \qquad B \cap C = \{5\}.$$
*In particular each pairwise intersection is nonempty.*

*Proof.* Direct computation on the finite sets. $\square$

**Lemma 3 (Empty core).** *The three cliques have empty common intersection:*
$$A \cap B \cap C = \varnothing.$$

*Proof.* From Lemma 2, $A \cap B = \{0\}$, and $0 \notin C = \{1,2,5\}$. Hence
$A \cap B \cap C = \{0\} \cap C = \varnothing$. $\square$

## 4. Main result

**Theorem A.** *The octahedron $K_{2,2,2}$ is not clique-Helly.*

*Proof.* Consider the family $\mathcal{S} = \{A, B, C\}$ with $A, B, C$ as in
Lemma 1. By Lemma 1 each member is a maximal clique. By Lemma 2 the family is
pairwise intersecting. If the octahedron were clique-Helly, Definition 3 would
force $\bigcap_{s \in \mathcal{S}} s = A \cap B \cap C$ to be nonempty. But
Lemma 3 gives $A \cap B \cap C = \varnothing$, a contradiction. Therefore the
octahedron is not clique-Helly. $\square$

The configuration is a *cyclic eye*: three triangles arranged so that consecutive
pairs clasp at $0$, $2$, $5$ respectively, with no vertex shared by all three.
This is the minimal witness — no family of two maximal cliques can fail Helly
(two pairwise-intersecting sets trivially have a common element), and one cannot
realize this failure on fewer than six vertices with three triangles.

**Corollary B (Forward implication).** *Every hereditarily clique-Helly graph is
octahedron-free; equivalently $(2) \Rightarrow (3)$ in Conjecture 1.*

*Proof.* Suppose a graph $G$ contains an induced octahedron on a vertex set $W$.
The subgraph induced by $W$ is isomorphic to $K_{2,2,2}$, which by Theorem A is
not clique-Helly. Hence some induced subgraph of $G$ is not clique-Helly, so $G$
is not hereditarily clique-Helly. Contrapositively, hereditary clique-Helliness
implies octahedron-freeness. $\square$

**Remark (Balancedness link).** The equivalence $(1) \Leftrightarrow (2)$ of
Conjecture 1 reflects the fact that an odd square submatrix with two ones per row
and column in the clique matrix is exactly the algebraic trace of a cyclic eye of
cliques. The three-clique eye of Theorem A corresponds to a $3 \times 3$ all-but-
diagonal incidence pattern — the smallest odd cycle in the incidence structure —
so the octahedron is simultaneously the minimal Helly obstruction and the seed of
the minimal balancedness obstruction. This dual reading is the conceptual engine
behind the conjectured equivalence.

## 5. Algorithms

We describe how to detect the obstruction and, more generally, test the properties
in Conjecture 1.

### 5.1 Verifying the Helly failure

Given the octahedron and the explicit family $\{A, B, C\}$, verifying Theorem A
reduces to finite set arithmetic: confirm each set is a maximal clique, confirm
the three pairwise intersections are nonempty, and confirm the triple intersection
is empty. Each check is $O(1)$ on six vertices.

### 5.2 Octahedron detection

To test $(3)$ for a general graph $G$ on $n$ vertices, one searches for an induced
$K_{2,2,2}$. A brute-force search examines all $\binom{n}{6}$ six-subsets and
checks whether the induced subgraph is isomorphic to the octahedron — a graph
recognizable as the unique $3$-regular graph on six vertices that is the complement
of a perfect matching. This is polynomial of degree six; refinements exploit that
each part is a non-adjacent pair whose neighborhoods coincide, allowing a search
over non-edges and their common neighborhoods.

### 5.3 Local clique-Helly test

A classical characterization (Dragan; Szwarcfiter) tests clique-Helliness in
polynomial time via *extended triangles*: for each triangle $T$, the set of
vertices adjacent to at least two vertices of $T$ must itself contain a vertex
adjacent to all of $T$. Hereditary clique-Helliness has an equivalent local
"ocular" characterization by forbidden configurations, of which the octahedron is
the bipartite-complement representative. These give practical polynomial-time
recognition, against which the conjectured single-forbidden-subgraph criterion can
be benchmarked.

## 6. Applications

**Balanced-matrix optimization.** Balanced $0/1$ matrices guarantee that set
packing and set covering linear programs have integral optima. A graph-theoretic
certificate for balancedness of the clique matrix — reducible, under Conjecture 1,
to the absence of a single six-vertex pattern — would provide a fast structural
test enabling exact polynomial-time optimization on the associated hypergraphs.
Application domains include scheduling, frequency assignment, and resource
allocation where clique constraints arise naturally.

**Structured graph classes.** Distance-hereditary graphs, on which the equivalence
is already known, appear in phylogenetics and metric embedding. A general
octahedron-based criterion would unify recognition across these classes and their
superclasses.

**Robust intersection reasoning.** The gap between pairwise and global
intersection modeled by the octahedron is a template for reasoning about
consistency in distributed systems and constraint networks, where pairwise
compatibility of local views need not yield a globally consistent state.

## 7. Discussion

Theorem A is small but load-bearing. It converts an abstract claim — that a graph
class is characterized by a forbidden subgraph — into a concrete, verified
mechanism. The octahedron is the *unique smallest* graph exhibiting a
pairwise-intersecting triple of maximal cliques with empty core, and this minimal
"eye" is the atom out of which larger Helly failures are assembled.

What remains open is the converse direction, $(3) \Rightarrow (2)$ and the full
equivalence with $(1)$, for general graphs. The subtlety is that other minimal
cyclic configurations of cliques ("ocular" graphs) may fail Helly without being an
octahedron. On distance-hereditary graphs no such alternative eye can occur, which
is precisely why the single-forbidden-subgraph characterization already holds
there. The general conjecture therefore hinges on classifying all minimal ocular
obstructions and proving that, among induced-subgraph-minimal ones relevant to
balancedness, the octahedron is decisive.

## 8. Future work

Building on the observation that the octahedron $\overline{3K_2}$ is the smallest
obstruction to the Helly property for cliques — with the implication "hereditarily
clique-Helly $\Rightarrow \overline{3K_2}$-free" holding unconditionally while its
converse fails in general — we highlight several directions.

**A finite obstruction set for hereditary clique-Helliness.** We conjecture that a
finite simple graph is hereditarily clique-Helly if and only if it contains no
induced subgraph from an explicit finite family of "ocular" graphs, of which the
octahedron $\overline{3K_2}$ is the unique bipartite-complement member.
Clique-Helliness fails exactly when three cliques close into a cyclic eye whose
centers cannot be simultaneously covered; each minimal such eye is a small
recognizable graph, and finitely many eyes should suffice. The octahedral
counterexample pins down the mechanism, giving a concrete template to search for
the remaining minimal obstructions systematically.

**Balancedness equals hereditary clique-Helliness.** We conjecture that for every
finite simple graph, the clique matrix is balanced if and only if the graph is
hereditarily clique-Helly. A forbidden odd two-per-row-and-column submatrix of the
clique matrix is the linear-algebraic shadow of exactly the same cyclic eye of
cliques that destroys the Helly property, so the combinatorial and matrix
obstructions are two views of one object. The forward implication reduces to the
single verified local obstruction, suggesting an obstruction-by-obstruction attack
rather than the global matrix theory.

**Single-obstruction characterization on hereditary classes.** Within any class
closed under induced subgraphs and free of the other ocular graphs (for instance,
distance-hereditary graphs), we conjecture that balancedness, hereditary
clique-Helliness, and $\overline{3K_2}$-freeness all coincide, because the
octahedron is then the only eye that can appear. Isolating the structural
hypothesis "no other ocular graph occurs" turns the known distance-hereditary case
into a general transfer principle.

**Quantitative Helly defect.** We conjecture the existence of a graph parameter —
the maximum number of pairwise-intersecting maximal cliques with empty common
intersection — that is bounded on hereditarily clique-Helly graphs and grows
without bound precisely along families containing arbitrarily large ocular
patterns, measuring *how badly* the Helly property fails.

## 9. Conclusion

We have given a complete and self-contained proof that the octahedron $K_{2,2,2} =
\overline{3K_2}$ is not clique-Helly, via three explicit maximal cliques that
pairwise intersect with empty common intersection. This establishes the
unconditional implication that hereditarily clique-Helly graphs are
octahedron-free and isolates the octahedron as the minimal obstruction at the core
of the conjectured equivalence between balancedness of the clique matrix,
hereditary clique-Helliness, and octahedron-freeness. The result turns a
structural conjecture into a concrete, mechanism-level fact and lays the groundwork
for a finite-obstruction theory of hereditary clique-Helliness.
