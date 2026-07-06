# Colour Classes of Proper Edge-Colourings: Matchings, Disjointness, and the Partition of the Edge Set

## Abstract

We develop the structural theory of colour classes in edge-coloured simple graphs and prove
that a proper edge-colouring induces a canonical decomposition of a graph's edge set into a
family of pairwise vertex-disjoint matchings. Concretely, we assign to every edge a
well-defined colour, collect the edges of each colour into a *colour class*, and establish
three theorems: (i) in a proper colouring each colour class is a matching; (ii) distinct
colours yield disjoint colour classes; and (iii) the colour classes partition the entire edge
set. As a companion to this decomposition, we record two vertex-local consequences of
properness — that the colour degree of every vertex equals its ordinary degree, and that in a
properly coloured complete graph on $n \ge 3$ vertices this common value is $n-1$ — and the
fact that properness forces every triangle to be rainbow. The results give a clean, fully
rigorous foundation for the study of rainbow substructures and for the classical
interpretation of proper edge-colouring as conflict-free scheduling. We accompany the theory
with algorithms that construct proper colourings, extract colour classes, and verify the
partition property, together with numerical demonstrations on complete graphs and random
graphs.

**Keywords.** edge-colouring, proper colouring, matching, colour class, partition, chromatic
index, rainbow triangle, colour degree, round-robin scheduling.

## 1. Introduction

Edge-colouring is among the most studied topics in graph theory, both for its intrinsic
elegance and for its ubiquity in applications: timetabling, frequency assignment, register
allocation, and the scheduling of round-robin tournaments are all, at heart, edge-colouring
problems. The single defining constraint — that edges sharing a vertex receive different
colours — is deceptively simple, yet it forces a rich global structure on the coloured graph.

The purpose of this paper is to isolate and prove, in complete rigour, the structural
backbone of that theory: **the decomposition of a properly coloured graph into colour
classes, each of which is a matching, together covering the edge set exactly once.** While
this decomposition is folklore, we present it with fully explicit statements and proofs,
organized around a robust definition of the colour of an edge that behaves well even when the
underlying colour function is defined on all pairs of vertices (not only on edges). This care
pays off in two ways. First, it makes the partition theorem an exact, checkable statement about
finite sets of edges. Second, it provides the structural atoms — individual colour classes —
from which finer results about rainbow substructures are assembled.

We also record the vertex-local face of properness. The *colour degree* of a vertex, meaning
the number of distinct colours on its incident edges, is in general at most its ordinary
degree; properness makes the two equal. On a properly coloured complete graph this pins the
colour degree of every vertex to $n-1$, which places such graphs squarely in the high
colour-degree regime studied in contemporary extremal work on rainbow triangles, in
particular the conjecture of Li, Ning, Shi, and Zhang (2024).

### 1.1 Contributions

- A robust definition of the **colour of an edge** as a value in $C \cup \{\bot\}$, defined by
  lifting a symmetric colour function through the unordered-pair (edge) structure and guarding
  it by edge membership (Section 3).
- The **matching theorem** for colour classes: in a proper colouring, two same-coloured edges
  sharing a vertex coincide (Theorem 4.1).
- **Disjointness** of colour classes for distinct colours (Theorem 4.2) and the **partition
  theorem**: colour classes cover the edge set and are pairwise disjoint (Theorem 4.3).
- The **colour-degree identity** $d_c(v)=\deg(v)$ under properness, its specialization $d_c(v)=n-1$
  on complete graphs, and the **rainbow-triangle theorem** for proper colourings (Section 5).
- Algorithms and numerical demonstrations realizing and verifying the decomposition
  (Sections 6–7).

## 2. Preliminaries and notation

Throughout, $V$ is a finite vertex set and $C$ is a set of colours. A **simple graph** $G$ on
$V$ is a symmetric, irreflexive adjacency relation; we write $u \sim v$ when $u$ and $v$ are
adjacent, and denote by $E(G)$ the set of edges, each edge an unordered pair
$\{u,v\}=\{v,u\}$ with $u \sim v$. For a vertex $v$, its **degree** $\deg(v)$ is the number of
neighbours, and $N(v)$ its neighbourhood.

We package an edge-coloured graph as a triple.

> **Definition 2.1 (Edge-coloured graph).** An *edge-coloured graph* consists of a simple
> graph $G$ on $V$ together with a **symmetric colour function**
> $\mathrm{col}\colon V \times V \to C$ satisfying $\mathrm{col}(u,v)=\mathrm{col}(v,u)$ for
> all $u,v$. Only the values of $\mathrm{col}$ on pairs $u \sim v$ are semantically
> meaningful; values on non-edges are ignored by every definition below.

Allowing $\mathrm{col}$ to be a total symmetric function (rather than a partial function on
edges) is a convenience: it lets us speak of $\mathrm{col}(u,v)$ without carrying an adjacency
proof, while the guards in Definition 3.1 ensure only edge-values ever influence a colour
class.

> **Definition 2.2 (Proper colouring).** An edge-coloured graph is **proper** if for all
> vertices $u,v,w$ with $v \neq w$, whenever $u \sim v$ and $u \sim w$ we have
> $\mathrm{col}(u,v) \neq \mathrm{col}(u,w)$. Equivalently, any two distinct edges sharing a
> vertex receive different colours.

> **Definition 2.3 (Matching).** A set $M \subseteq E(G)$ of edges is a **matching** if no two
> distinct edges of $M$ share a vertex; equivalently, the edges of $M$ are pairwise
> vertex-disjoint.

## 3. The colour of an edge and colour classes

The colour function $\mathrm{col}$ acts on *ordered* pairs, but its symmetry means it descends
to unordered pairs. We make this precise and use it to colour edges.

> **Definition 3.1 (Colour of an edge).** Let $e$ be an unordered pair of vertices. The
> **colour of $e$**, written $\widehat{\mathrm{col}}(e) \in C \cup \{\bot\}$, is
> $$\widehat{\mathrm{col}}(e) = \begin{cases} \mathrm{col}(u,v) & \text{if } e=\{u,v\}\in E(G),\\ \bot & \text{if } e \notin E(G). \end{cases}$$
> The value $\mathrm{col}(u,v)$ is independent of the chosen representative $\{u,v\}=\{v,u\}$
> precisely because $\mathrm{col}$ is symmetric, so $\widehat{\mathrm{col}}$ is well defined.

Two elementary but foundational facts follow directly from the definition.

> **Lemma 3.2 (Colour of an actual edge).** If $u \sim v$, then
> $\widehat{\mathrm{col}}(\{u,v\}) = \mathrm{col}(u,v)$.

> **Lemma 3.3 (Edges are coloured).** Every edge $e \in E(G)$ satisfies
> $\widehat{\mathrm{col}}(e) \neq \bot$; in fact $\widehat{\mathrm{col}}(e)$ equals the
> symmetric lift of $\mathrm{col}$ evaluated at $e$.

*Proof.* Both are immediate from Definition 3.1: an edge $e$ lies in $E(G)$, so the first
branch applies, giving a value in $C$ and, when $e=\{u,v\}$, the value $\mathrm{col}(u,v)$. $\square$

> **Definition 3.4 (Colour class).** For a colour $c \in C$, the **colour class** of $c$ is
> $$\mathcal{C}(c) = \{\, e \in E(G) : \widehat{\mathrm{col}}(e) = c \,\}.$$
> Thus $e \in \mathcal{C}(c)$ if and only if $e$ is an edge of $G$ and its colour is $c$.

The following extraction lemma is the workhorse of the matching theorem: it lets us read off,
from an edge of a given colour through a given vertex, the other endpoint together with the
adjacency and colour data.

> **Lemma 3.5 (Endpoint extraction).** Suppose $e \in \mathcal{C}(c)$ and $x \in e$. Then
> there is a vertex $y$ with $e = \{x,y\}$, $x \sim y$, and $\mathrm{col}(x,y)=c$.

*Proof.* Write $e=\{a,b\}$. Membership in $\mathcal{C}(c)$ gives $e \in E(G)$ (so $a \sim b$)
and $\widehat{\mathrm{col}}(e)=c$; by Lemma 3.2 the latter reads $\mathrm{col}(a,b)=c$. Since
$x \in e$, either $x=a$ or $x=b$. If $x=a$, take $y=b$: then $e=\{x,y\}$, $x \sim y$, and
$\mathrm{col}(x,y)=c$. If $x=b$, take $y=a$: then $e=\{b,a\}=\{x,y\}$, $x \sim y$ by symmetry
of adjacency, and $\mathrm{col}(x,y)=\mathrm{col}(b,a)=\mathrm{col}(a,b)=c$ by symmetry of
$\mathrm{col}$. $\square$

## 4. The decomposition theorems

We now prove the three structural results. Throughout this section the colouring is proper.

> **Theorem 4.1 (Each colour class is a matching).** Let the colouring be proper and fix a
> colour $c$. If $e_1, e_2 \in \mathcal{C}(c)$ share a vertex $x$ (that is, $x \in e_1$ and
> $x \in e_2$), then $e_1 = e_2$. Consequently $\mathcal{C}(c)$ is a matching.

*Proof.* Apply Lemma 3.5 to each edge at the shared vertex $x$: there are $y_1, y_2$ with
$e_1=\{x,y_1\}$, $x \sim y_1$, $\mathrm{col}(x,y_1)=c$, and $e_2=\{x,y_2\}$, $x \sim y_2$,
$\mathrm{col}(x,y_2)=c$. Suppose for contradiction $y_1 \neq y_2$. Then properness
(Definition 2.2), applied at $x$ with neighbours $y_1 \neq y_2$, yields
$\mathrm{col}(x,y_1) \neq \mathrm{col}(x,y_2)$, contradicting that both equal $c$. Hence
$y_1=y_2$ and $e_1=\{x,y_1\}=\{x,y_2\}=e_2$. Since any two edges of $\mathcal{C}(c)$ that meet
must coincide, distinct edges of $\mathcal{C}(c)$ are vertex-disjoint, i.e. $\mathcal{C}(c)$ is
a matching. $\square$

> **Theorem 4.2 (Distinct colours give disjoint classes).** If $c_1 \neq c_2$, then
> $\mathcal{C}(c_1) \cap \mathcal{C}(c_2) = \varnothing$.

*Proof.* Suppose $e \in \mathcal{C}(c_1) \cap \mathcal{C}(c_2)$. Then
$\widehat{\mathrm{col}}(e)=c_1$ and $\widehat{\mathrm{col}}(e)=c_2$, so $c_1=c_2$ by
uniqueness of the value $\widehat{\mathrm{col}}(e)$, contradicting $c_1 \neq c_2$. Hence the
intersection is empty. $\square$

> **Theorem 4.3 (Colour classes partition the edge set).** The family
> $\{\mathcal{C}(c)\}_{c \in C}$ partitions $E(G)$:
> $$\bigcup_{c \in C} \mathcal{C}(c) = E(G), \qquad \mathcal{C}(c_1) \cap \mathcal{C}(c_2)=\varnothing \text{ for } c_1 \neq c_2.$$

*Proof.* Disjointness is Theorem 4.2. For the covering, one inclusion is immediate: every
$\mathcal{C}(c) \subseteq E(G)$ by definition, so the union is contained in $E(G)$.
Conversely, let $e \in E(G)$. By Lemma 3.3, $\widehat{\mathrm{col}}(e)$ is an actual colour
$c^\star \in C$ (not $\bot$). Then $e \in \mathcal{C}(c^\star)$ and hence $e$ lies in the
union. Therefore the union equals $E(G)$. $\square$

The content of Theorem 4.3 is that a proper edge-colouring is exactly a partition of $E(G)$
into matchings indexed by colours. If $C$ is finite with $|C|=k$ colours actually used, this
is a decomposition of $G$ into at most $k$ matchings. The least such $k$ is the **chromatic
index** $\chi'(G)$, and Theorem 4.3 is the structural statement that underlies its scheduling
interpretation: a proper colouring with $k$ colours *is* a schedule of the edges into $k$
conflict-free rounds.

## 5. Vertex-local consequences of properness

We complement the edge-set decomposition with two vertex-local results and the rainbow-triangle
principle.

> **Definition 5.1 (Colour degree).** The **colour degree** $d_c(v)$ of a vertex $v$ is the
> number of distinct colours appearing on edges incident to $v$, i.e.
> $d_c(v) = \big|\{\mathrm{col}(v,u) : u \in N(v)\}\big|$.

> **Proposition 5.2 (Colour degree is bounded by degree).** For every vertex $v$,
> $d_c(v) \le \deg(v) \le n-1$, where $n=|V|$.

*Proof.* $d_c(v)$ counts the image of the map $u \mapsto \mathrm{col}(v,u)$ on $N(v)$, whose
domain has size $\deg(v)$; an image never exceeds its domain, giving $d_c(v)\le\deg(v)$. The
degree is at most $n-1$ since a vertex has at most $n-1$ neighbours. $\square$

> **Theorem 5.3 (Colour degree equals degree under properness).** If the colouring is proper,
> then $d_c(v)=\deg(v)$ for every vertex $v$.

*Proof.* Properness says $u \mapsto \mathrm{col}(v,u)$ is injective on $N(v)$: distinct
neighbours $u \neq u'$ satisfy $\mathrm{col}(v,u)\neq\mathrm{col}(v,u')$. An injective map has
image of the same size as its domain, so $d_c(v)=|N(v)|=\deg(v)$. $\square$

> **Corollary 5.4 (Complete graphs).** In a properly coloured complete graph on $n$ vertices,
> $d_c(v)=n-1$ for every vertex $v$. In particular, for $n \ge 3$ every vertex satisfies
> $d_c(v)=n-1 \ge \lceil (n+1)/2 \rceil$.

*Proof.* In the complete graph every vertex has degree $n-1$; apply Theorem 5.3. The
inequality $n-1 \ge (n+1)/2$ holds for $n \ge 3$. $\square$

Corollary 5.4 shows that properly coloured complete graphs sit exactly inside the high
colour-degree regime $\delta_c(G) \ge (n+1)/2$ studied in recent extremal work of Li, Ning,
Shi, and Zhang on the minimum number of rainbow triangles. The next theorem explains why they
are the natural extremal objects there.

> **Theorem 5.5 (Proper triangles are rainbow).** If the colouring is proper and $a,b,c$ are
> three distinct, pairwise-adjacent vertices, then the three edges $\{a,b\},\{a,c\},\{b,c\}$
> receive pairwise-distinct colours — the triangle is *rainbow*.

*Proof.* In a triangle every pair of edges meets at a common vertex. At $a$: since $b \neq c$
and $a \sim b$, $a \sim c$, properness gives $\mathrm{col}(a,b)\neq\mathrm{col}(a,c)$. At $b$:
since $a \neq c$ and $b \sim a$, $b \sim c$, properness gives
$\mathrm{col}(b,a)\neq\mathrm{col}(b,c)$; by symmetry $\mathrm{col}(a,b)\neq\mathrm{col}(b,c)$.
At $c$: since $a \neq b$ and $c \sim a$, $c \sim b$, properness gives
$\mathrm{col}(c,a)\neq\mathrm{col}(c,b)$; by symmetry $\mathrm{col}(a,c)\neq\mathrm{col}(b,c)$.
The three edge colours are therefore pairwise distinct. $\square$

## 6. Algorithms

We describe algorithms that realize and verify the theory. Complexities are stated for a graph
with $n$ vertices and $m$ edges, using adjacency-list representation.

### 6.1 Constructing a proper edge-colouring

For general graphs, a greedy scan colours each edge with the smallest colour absent from both
endpoints. It always produces a proper colouring, and it uses at most $2\Delta-1$ colours,
where $\Delta$ is the maximum degree (Vizing's theorem guarantees $\Delta$ or $\Delta+1$
colours are achievable by more refined methods, but greedy suffices to *witness* properness).

**Pseudocode.**
```
Greedy-Proper-Edge-Colour(G):
  col := empty map on edges
  for each edge e = {u,v} in a fixed order:
    used := { col[f] : f incident to u or v and already coloured }
    c := least colour not in used
    col[e] := c
  return col
```
Complexity: $O(m\Delta)$ time, $O(m)$ space.

### 6.2 Round-robin colouring of a complete graph

For $K_n$ the optimal colouring is explicit. For even $n$ use the *circle method*: fix player
$n-1$; arrange the others on a circle; in round $r$ ($0 \le r \le n-2$) pair the fixed player
with the player at position $r$ and pair the remaining players symmetrically across the circle.
This yields $n-1$ perfect matchings. For odd $n$, add a phantom player, apply the even
construction, and delete the phantom to obtain $n$ near-perfect matchings, each with one bye.
Complexity: $O(n^2)$ time, producing exactly $\chi'(K_n)$ colours ($n-1$ for even $n$, $n$ for
odd $n$).

### 6.3 Extracting colour classes and verifying the partition

Given any edge-colouring, group edges by colour to obtain the colour classes, then verify the
two theorems directly.

**Pseudocode.**
```
Colour-Classes-And-Verify(G, col):
  classes := group edges of G by col[e]      # buckets keyed by colour
  # (1) matching test
  for each colour c, for each vertex x:
    if two edges of classes[c] contain x: report NOT A MATCHING
  # (2) partition test
  assert union of classes == E(G)            # covering
  assert classes are pairwise disjoint       # automatic: each edge has one colour
  return classes
```
Complexity: $O(m + \sum_c |\mathcal{C}(c)|) = O(m)$ time once colours are known.

## 7. Numerical demonstrations

The accompanying computational demonstrations exercise the theory on concrete graphs:

1. **Round-robin on $K_n$.** For $n \in \{4,5,6,7,8\}$ we build the circle-method colouring,
   confirm every colour class is a perfect (or near-perfect) matching, confirm the classes
   partition the $\binom{n}{2}$ edges, and confirm the number of colours equals
   $\chi'(K_n)$.

2. **Greedy colourings of random graphs.** For Erdős–Rényi random graphs we build a greedy
   proper colouring and verify, exhaustively, the matching property of every colour class, the
   pairwise disjointness of classes, and the covering of the edge set — an empirical check of
   Theorems 4.1–4.3.

3. **Colour-degree identity and rainbow triangles.** We verify $d_c(v)=\deg(v)$ at every
   vertex under proper colourings and enumerate the triangles of properly coloured complete
   graphs, confirming that all of them are rainbow (Theorems 5.3 and 5.5).

These computations serve as independent, finite verifications of the theorems on a spectrum of
structured and random inputs.

## 7.5 A worked example: the complete graph $K_4$

To see every theorem at work on a small graph, take the complete graph $K_4$ on vertices
$\{0,1,2,3\}$, which has $\binom{4}{2}=6$ edges. Since $4$ is even, the circle method produces
$\chi'(K_4)=3$ perfect matchings. One valid proper colouring is

$$
\mathcal{C}(0)=\{\{0,1\},\{2,3\}\},\quad
\mathcal{C}(1)=\{\{0,2\},\{1,3\}\},\quad
\mathcal{C}(2)=\{\{0,3\},\{1,2\}\}.
$$

Each class contains two edges that share no vertex, so each is a perfect matching pairing all
four vertices (Theorem 4.1). No edge appears in two classes, so the classes are disjoint
(Theorem 4.2), and the three classes together list all six edges exactly once, partitioning
$E(K_4)$ (Theorem 4.3). Every vertex meets three edges of three different colours, so
$d_c(v)=3=\deg(v)=n-1$ (Theorem 5.3, Corollary 5.4). Finally, each of the $\binom{4}{3}=4$
triangles, say $\{0,1,2\}$ with edge colours $\{0,1\}\mapsto 0$, $\{0,2\}\mapsto 1$,
$\{1,2\}\mapsto 2$, uses three distinct colours and is therefore rainbow (Theorem 5.5). The
same phenomena persist verbatim for larger complete graphs: the odd case $K_5$ needs
$\chi'(K_5)=5$ colours with each class a near-perfect matching leaving one vertex unmatched.

## 7.6 Applications

**Timetabling and tournament scheduling.** Interpreting vertices as agents and edges as
required pairwise meetings, a proper colouring with $k$ colours *is* a schedule into $k$
conflict-free time slots, each slot a matching of simultaneously runnable meetings. Theorem 4.3
is precisely the statement that no meeting is dropped or double-booked. Round-robin sports
leagues use exactly the circle-method colouring of Section 6.2.

**Frequency and channel assignment.** Replacing colours by radio channels, properness is the
non-interference constraint at each transceiver, and the colour classes are the sets of links
that can transmit simultaneously without collision.

**Optical and switching networks.** In wavelength-division and crossbar switching, the
decomposition of a demand graph into matchings is the standard route to conflict-free routing;
the chromatic index bounds the number of switching configurations required.

**Extremal rainbow theory.** As a structural substrate, the colour-class atoms feed directly
into counting arguments for rainbow substructures; Corollary 5.4 and Theorem 5.5 identify
properly coloured complete graphs as the canonical high-colour-degree, rainbow-rich extremal
family.

## 8. Discussion

The results here establish a piece of graph-theoretic folklore with unusual care about the
*colour of an edge*. By defining the edge colour through a symmetric lift guarded by edge
membership, we obtain statements about honest finite sets of edges: the partition theorem is
an equality of edge sets, not an informal correspondence. This precision matters when the
colour classes become building blocks for finer arguments — for instance, counting rainbow
substructures, where one repeatedly needs that each colour contributes a matching and that no
edge is counted twice.

The vertex-local results place properly coloured complete graphs precisely in the regime of
current extremal conjectures on rainbow triangles, and the rainbow-triangle theorem explains
their extremal role: properness upgrades *every* triangle to a rainbow one, so complete graphs
maximize the raw supply of triangles while properness guarantees each is rainbow.

## 9. Future work

Several directions extend naturally from this foundation.

- **Chromatic index and Vizing's theorem.** Establish the bound $\chi'(G)\in\{\Delta,\Delta+1\}$
  and the exact values $\chi'(K_n)=n-1$ ($n$ even), $\chi'(K_n)=n$ ($n$ odd), using the
  colour-class decomposition as the notion of a "round".
- **Rainbow-triangle counts.** Build on the colour-class atoms toward the Li–Ning–Shi–Zhang
  lower bound $rt(G)\ge \lceil (n-1)(n-3)/8 \rceil$ in the regime $\delta_c(G)\ge (n+1)/2$.
- **Fractional and list variants.** Extend the partition viewpoint to fractional
  edge-colourings and to list-edge-colouring, where colour classes are replaced by fractional
  matchings and by constrained matchings respectively.
- **Applications to scheduling.** Turn the constructive round-robin colouring into verified
  schedulers with provable optimality guarantees.

## References

- V. G. Vizing, *On an estimate of the chromatic class of a p-graph*, Diskret. Analiz **3**
  (1964), 25–30.
- B. Li, B. Ning, Y. Shi, S. Zhang, *Rainbow triangles in edge-coloured graphs* (2024).
