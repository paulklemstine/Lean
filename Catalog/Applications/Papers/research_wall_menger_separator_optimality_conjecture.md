# Wall–Menger Separator Optimality: Tightness of Min-Cut / Max-Disjoint-Paths for the Left–Right Cut of Grid Graphs

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Applications (Structural Graph Theory / Combinatorial Optimization)

## Abstract

We study the vertex-Menger duality between separators and vertex-disjoint paths on
grid (wall) graphs, and we determine the exact value of the minimum left–right
vertex separator. Let the $(m+1)\times(n+1)$ grid be the Cartesian (box) product
of two paths, $G_{m,n} = P_{m+1}\,\square\,P_{n+1}$, with left region
$A = \{x : x_2 = 0\}$ (the leftmost column) and right region
$B = \{x : x_2 = n\}$ (the rightmost column). We prove that the minimum
$A$–$B$ vertex separator has exactly $m+1$ vertices and that this is matched by
$m+1$ pairwise vertex-disjoint $A$–$B$ paths, so the Menger inequality is tight:

$$\min\text{-cut}(A,B) \;=\; \max\text{-disjoint-paths}(A,B) \;=\; m+1.$$

Remarkably, the value depends only on the *height* $m+1$ of the grid and is
independent of its *width* $n+1$. Our proof develops two reusable ingredients: (i)
an abstract *easy direction* of Menger's theorem (any family of $k$ pairwise
vertex-disjoint $A$–$B$ paths forces every $A$–$B$ separator to have at least $k$
vertices), proved by an injection from path indices to separator vertices; and
(ii) a *discrete intermediate value theorem along a walk*, stating that any
integer vertex-labelling that changes by at most one across each edge attains
every intermediate value along any walk between a low-labelled and a high-labelled
endpoint. The IVT immediately yields that every column of the grid is a separator,
and the explicit row paths supply the matching disjoint family, pinning the optimal
value without invoking the hard direction of Menger's theorem. All results have
been formalized and machine-checked with no unproved assumptions. We situate the
result within wall-based structural graph theory, where it is a sharp instance of
the conjecture that the wall–Menger separator bound matches the classical Menger
bound $s'-1$.

## 1. Introduction

### 1.1 Menger duality and its sharpness

Menger's theorem (1927) is the cornerstone of connectivity theory. In its
vertex form, for disjoint vertex sets $A$ and $B$ in a graph $G$, the maximum
number of pairwise internally-vertex-disjoint $A$–$B$ paths equals the minimum
size of an $A$–$B$ vertex separator. This duality, the combinatorial parent of the
max-flow min-cut theorem, certifies that the cost of *blocking* all routes between
two regions equals the abundance of *independent routes* available between them.

While Menger's theorem guarantees equality of these two extremal quantities, it
does not determine their common value for any specific graph. Determining that
value on canonical families — and in particular on grids and walls — is a separate
and frequently subtle problem. Grids and their offset cousins, *walls*, are the
universal certificates of structural complexity in graph minor theory: by the
grid-minor theorem of Robertson and Seymour, a graph has large treewidth if and
only if it contains a large wall as a minor. Consequently, *Menger-type*
statements about walls — either a bounded separator detaches a target set $A$ from
the wall, or many disjoint $A$-to-wall paths exist landing on distinct attachment
vertices ("nails") — are workhorses of the theory, and the precise separator
bound governs the efficiency of structural decompositions.

The *wall–Menger separator optimality conjecture* asserts that the separator bound
$f$ in the wall version of Menger's theorem can be taken to equal $s'-1$, matching
the classical Menger bound: for all positive integers $s'$ and $t'$ there is an
integer $t$ such that for any vertex set $A$ and any wall $W$ of size at least $t$,
either there is a vertex set $X$ of size at most $s'-1$ separating $A$ from the
branch vertices of $W$, or there is a subwall $W'$ of size at least $t'$ together
with $s'$ vertex-disjoint $A$–$W'$ paths, each ending at a distinct nail of $W'$.

### 1.2 Contribution

This paper establishes a sharp, fully rigorous instance of this optimality
philosophy for the most natural test case: the left–right cut of a rectangular
grid. We prove that the Menger bound is achieved exactly — the minimum left–right
separator has precisely $m+1$ vertices, matched by $m+1$ disjoint paths — with no
slack and no dependence on the width. Concretely, we contribute:

1. **`menger_separator_lower_bound`** — an abstract, graph-agnostic proof of the
   easy direction of Menger: $k$ pairwise vertex-disjoint $A$–$B$ paths force
   $|S|\ge k$ for every $A$–$B$ separator $S$.
2. **`walk_exists_mem_support_of_le`** — a discrete intermediate value theorem
   along a walk, for any $\mathbb{N}$-valued vertex labelling whose value grows by
   at most one across each edge.
3. **`grid_column_isSeparator`** and **`grid_colFinset_card`** — every column of
   the grid is an $A$–$B$ separator, and it has exactly $m+1$ vertices.
4. **`grid_rows_disjoint`** and **`grid_disjoint_paths`** — the $m+1$ rows are
   pairwise vertex-disjoint $A$–$B$ paths.
5. **`grid_separator_optimal`** — separator optimality: there is an $A$–$B$
   separator of size $m+1$, and every $A$–$B$ separator has size at least $m+1$;
   hence the minimum separator is exactly $m+1$.

All results are machine-checked with no unproved assumptions (zero `sorry`s).

## 2. Definitions

Throughout, $G$ is a simple graph on a vertex set $V$ with adjacency relation
$\sim$. A *walk* from $u$ to $v$ is a finite alternating sequence of vertices and
edges starting at $u$ and ending at $v$; its *support* is the set (list) of
vertices it visits. We write $A, B \subseteq V$ for the two regions to be
separated.

**Definition 2.1 (Region separator).** A set $S \subseteq V$ is an *$A$–$B$
separator* if every walk that starts in $A$ and ends in $B$ contains a vertex of
$S$. Formally,
$$\mathrm{IsABSeparator}(G, A, B, S) \;:\Longleftrightarrow\;
\forall u,v,\ \forall w : \mathrm{Walk}_G(u,v),\ u \in A \to v \in B \to
\exists x \in \mathrm{support}(w),\ x \in S.$$
Using *walks* rather than *paths* in this definition makes the separator property
strictly stronger and hence the lower bounds we derive correspondingly robust;
since every path is a walk, a walk-separator is in particular a path-separator.

**Definition 2.2 (Grid / wall graph).** For $m, n \in \mathbb{N}$, the
*$(m+1)\times(n+1)$ grid* is the Cartesian (box) product of two path graphs,
$$G_{m,n} \;=\; P_{m+1}\,\square\,P_{n+1},$$
on the vertex set $\mathrm{Fin}(m+1)\times \mathrm{Fin}(n+1)$. Two vertices
$x=(x_1,x_2)$ and $y=(y_1,y_2)$ are adjacent iff either $x_1=y_1$ and
$x_2 \sim y_2$ in $P_{n+1}$, or $x_2=y_2$ and $x_1 \sim y_1$ in $P_{m+1}$, where
$P_k$ is the path graph on $\{0,\dots,k-1\}$ with $i \sim j \iff |i-j|=1$. We refer
to the first coordinate as the *row* and the second as the *column*.

**Definition 2.3 (Left and right regions).** The *left column* and *right column*
are
$$A \;=\; \mathrm{leftCol} \;=\; \{x : x_2 = 0\}, \qquad
B \;=\; \mathrm{rightCol} \;=\; \{x : x_2 = n\},$$
where $n$ denotes the maximum column index $\mathrm{last}\,n$.

**Definition 2.4 (Column set).** For $0 \le c \le n$, the *$c$-th column* is the
finite set
$$\mathrm{colFinset}(m,n,c) \;=\; \{x : (x_2)\text{ has value } c\}
\;=\; \{(i, c) : i \in \mathrm{Fin}(m+1)\}.$$

**Definition 2.5 (Row embedding).** For each row index $i \in \mathrm{Fin}(m+1)$,
the map $\mathrm{rowHom}(m,n,i) : P_{n+1} \to G_{m,n}$, $j \mapsto (i,j)$, is a
graph homomorphism: if $j \sim j'$ in $P_{n+1}$ then $(i,j)\sim(i,j')$ in
$G_{m,n}$ by the second disjunct of box-product adjacency. The *row walk*
$\mathrm{rowWalk}(m,n,i)$ is the image under $\mathrm{rowHom}(m,n,i)$ of a fixed
$0$-to-$\mathrm{last}\,n$ walk in $P_{n+1}$; it is a walk in $G_{m,n}$ from
$(i,0)$ to $(i,n)$.

## 3. Main results

### 3.1 The easy direction of Menger (abstract lower bound)

**Theorem 3.1 (`menger_separator_lower_bound`).** Let $S$ be a finite $A$–$B$
separator of $G$. Suppose there are $k$ pairwise vertex-disjoint $A$–$B$ paths:
indices $i \in \mathrm{Fin}(k)$, endpoints $a_i \in A$ and $b_i \in B$, walks
$p_i : \mathrm{Walk}_G(a_i, b_i)$, such that for $i \ne j$ the supports of $p_i$
and $p_j$ are disjoint. Then
$$k \;\le\; |S|.$$

*Proof sketch.* For each index $i$, apply the separator property of $S$ to the
walk $p_i$ (whose endpoints lie in $A$ and $B$ respectively) to obtain a vertex
$f(i) \in \mathrm{support}(p_i)$ with $f(i) \in S$. This defines a function
$f : \mathrm{Fin}(k) \to S$. The function is *injective*: if $f(i)=f(j)$ with
$i\ne j$, then $f(i)$ would be a common vertex of $\mathrm{support}(p_i)$ and
$\mathrm{support}(p_j)$, contradicting disjointness. An injection from a
$k$-element set into $S$ forces $|S| \ge k$. $\;\blacksquare$

This argument is entirely graph-agnostic and uses nothing about grids; it is the
universally valid half of Menger's duality. Its strength here is that it converts
*any* explicit family of disjoint paths into a certified separator lower bound.

### 3.2 A discrete intermediate value theorem along walks

**Theorem 3.2 (`walk_exists_mem_support_of_le`).** Let $f : V \to \mathbb{N}$ be a
vertex labelling such that crossing any edge increases the label by at most one:
$$x \sim y \;\Longrightarrow\; f(y) \le f(x) + 1.$$
Let $w$ be a walk from $u$ to $v$ and let $c \in \mathbb{N}$ satisfy
$f(u) \le c \le f(v)$. Then there is a vertex $x \in \mathrm{support}(w)$ with
$f(x) = c$.

*Proof sketch.* Induct on the structure of the walk $w$.

- *Base case* ($w$ is the trivial walk at $u$, so $u=v$): then
  $f(u) \le c \le f(v) = f(u)$ forces $c = f(u)$, and $u$ is in the support.
- *Inductive step* ($w = (u \sim u') \cdot w'$ with $w'$ a walk from $u'$ to $v$):
  if $c \le f(u')$, then since $f(u) \le c$ the desired vertex already exists on
  the tail $w'$ by the induction hypothesis (with the same $c$), and the support
  of $w'$ is contained in that of $w$. If instead $c > f(u')$, then because the
  step from $u$ to $u'$ obeys $f(u') \le f(u)+1$ (apply the hypothesis to the
  reverse edge $u' \sim u$, or symmetrically), and $f(u) \le c$, we get
  $c \le f(u)+1$... more directly: the constraint that the label changes by at
  most one per edge means the value sequence along $w$ has consecutive
  differences bounded by one in absolute terms relevant to the threshold $c$;
  the first vertex whose label reaches $c$ exists because the sequence starts at
  $f(u) \le c$ and ends at $f(v) \ge c$ and never jumps over $c$. Formally the
  Lean proof discharges the step automatically by case analysis on whether $u$
  already attains $c$ and otherwise recursing on $w'$. $\;\blacksquare$

The labelling hypothesis is exactly a discrete Lipschitz condition with constant
one. The conclusion is the no-skipping property: a value that starts at or below a
threshold and ends at or above it must be hit exactly. This lemma is the reusable
engine that converts a *global* coordinate spread into a *local* certificate, and
it underlies every separator we build.

### 3.3 Columns are separators

**Lemma 3.3 (`grid_col_step`).** In $G_{m,n}$, if $x \sim y$ then the column value
of $y$ is at most the column value of $x$ plus one:
$$x \sim y \;\Longrightarrow\; \mathrm{val}(y_2) \le \mathrm{val}(x_2) + 1.$$

*Proof sketch.* Case on the box-product adjacency. If $x$ and $y$ share a row, the
columns are path-adjacent, so they differ by exactly one. If they share a column,
the column values are equal. In both cases the bound holds (and is in fact symmetric
in $x,y$). $\;\blacksquare$

**Theorem 3.4 (`grid_column_isSeparator`).** For every $c$ with $0 \le c \le n$,
the column $\mathrm{colFinset}(m,n,c)$ is an $A$–$B$ separator of $G_{m,n}$.

*Proof sketch.* Let $w$ be a walk from $u \in A$ to $v \in B$, so the column value
of $u$ is $0$ and that of $v$ is $n$. Apply the discrete IVT (Theorem 3.2) with
$f(x) = \mathrm{val}(x_2)$, the column-value labelling; the Lipschitz hypothesis is
exactly Lemma 3.3. Since $f(u)=0 \le c \le n = f(v)$, the walk contains a vertex
$x$ with $f(x) = c$, i.e. $x$ lies in column $c$, hence $x \in
\mathrm{colFinset}(m,n,c)$. $\;\blacksquare$

**Lemma 3.5 (`grid_colFinset_card`).** For $0 \le c \le n$,
$$|\mathrm{colFinset}(m,n,c)| \;=\; m+1.$$

*Proof sketch.* The map $i \mapsto (i, c)$ is a bijection from $\mathrm{Fin}(m+1)$
onto $\mathrm{colFinset}(m,n,c)$: it is injective in the first coordinate and its
image is exactly the set of vertices in column $c$. Hence the column has one vertex
per row, $m+1$ in total. $\;\blacksquare$

### 3.4 Rows are disjoint paths

**Lemma 3.6 (`rowWalk_support_fst`).** Every vertex on $\mathrm{rowWalk}(m,n,i)$
lies in row $i$: if $x \in \mathrm{support}(\mathrm{rowWalk}(m,n,i))$ then
$x_1 = i$.

*Proof sketch.* The row walk is the image of a $P_{n+1}$-walk under
$\mathrm{rowHom}(m,n,i)$, whose every output has first coordinate $i$. Any support
vertex of the mapped walk is therefore of the form $(i, j)$. $\;\blacksquare$

**Theorem 3.7 (`grid_rows_disjoint`).** For $i \ne j$ the row walks
$\mathrm{rowWalk}(m,n,i)$ and $\mathrm{rowWalk}(m,n,j)$ are vertex-disjoint: no
vertex lies on both.

*Proof sketch.* A common vertex $x$ would satisfy $x_1 = i$ (by Lemma 3.6 applied
to $i$) and $x_1 = j$ (applied to $j$), forcing $i = j$, contrary to hypothesis.
$\;\blacksquare$

**Theorem 3.8 (`grid_disjoint_paths`).** The grid $G_{m,n}$ admits $m+1$ pairwise
vertex-disjoint $A$–$B$ paths. Precisely, there exist endpoint families
$a, b : \mathrm{Fin}(m+1) \to V$ and walks $p_i : \mathrm{Walk}(a_i, b_i)$ with
$a_i \in A$, $b_i \in B$ for all $i$, and disjoint supports for $i \ne j$.

*Proof sketch.* Take $a_i = (i, 0) \in A$, $b_i = (i, n) \in B$, and
$p_i = \mathrm{rowWalk}(m,n,i)$. Membership in $A$ and $B$ is immediate; pairwise
disjointness is Theorem 3.7. $\;\blacksquare$

### 3.5 Separator optimality

**Theorem 3.9 (`grid_separator_optimal`).** For the left–right cut of $G_{m,n}$:

1. *(Achievability)* There exists an $A$–$B$ separator of size exactly $m+1$,
   namely any column $\mathrm{colFinset}(m,n,c)$ with $0 \le c \le n$ (Theorem 3.4
   and Lemma 3.5).
2. *(Lower bound)* Every $A$–$B$ separator $S$ satisfies $|S| \ge m+1$.

Consequently the minimum $A$–$B$ vertex separator of $G_{m,n}$ has exactly $m+1$
vertices.

*Proof sketch.* Part 1 is immediate from Theorem 3.4 (a column separates) and
Lemma 3.5 (a column has $m+1$ vertices). For Part 2, combine the explicit disjoint
family from Theorem 3.8 (with $k = m+1$) with the abstract lower bound Theorem 3.1:
the $m+1$ disjoint row paths force $|S| \ge m+1$ for every separator $S$. The two
parts together pin the minimum at exactly $m+1$. $\;\blacksquare$

**Corollary 3.10 (Menger tightness, width-independence).** For the left–right cut
of the $(m+1)\times(n+1)$ grid,
$$\min\text{-cut}(A,B) \;=\; \max\text{-disjoint-paths}(A,B) \;=\; m+1,$$
a quantity depending only on the height $m+1$ and independent of the width $n+1$.

*Proof.* The chain
$m+1 \le \max\text{-disjoint-paths} \le \min\text{-cut} \le m+1$
holds: the middle inequality is the easy direction of Menger (Theorem 3.1), the
outer bounds are Theorems 3.8 and 3.9(1). All inequalities are therefore
equalities. $\;\blacksquare$

## 4. Algorithms

The constructive content of the proof translates directly into efficient
algorithms operating on the $(m+1)\times(n+1)$ grid.

### 4.1 Minimum separator construction

Any single column is an optimal separator. The algorithm simply enumerates the
$m+1$ vertices $\{(i,c) : 0\le i \le m\}$ of a chosen column $c$. This runs in
$O(m)$ time and $O(m)$ space and returns a provably minimum-size separator. There
is no need for a flow computation: optimality is certified by Theorem 3.9.

### 4.2 Maximum disjoint path packing

The $m+1$ horizontal rows are a maximum packing of vertex-disjoint $A$–$B$ paths.
Path $i$ is the sequence $(i,0), (i,1), \dots, (i,n)$. Constructing all of them is
$O((m+1)(n+1))$ time — linear in the number of vertices — and the packing is
provably maximum by Corollary 3.10.

### 4.3 Discrete IVT separator extraction

Given any monotone-Lipschitz vertex labelling $f$ (changing by at most one per
edge) and a walk $w$ from a low-labelled to a high-labelled vertex, the
level-set $\{x : f(x) = c\}$ is a separator and a witness vertex can be located by
scanning the walk's support and returning the first vertex with $f(x) = c$. This is
$O(|w|)$ and generalizes the column construction to arbitrary layered labellings
(distance-to-a-set, BFS depth, potential functions).

## 5. Applications

**Network reliability.** The minimum $A$–$B$ separator is the vertex-connectivity
between the two boundary columns: the number of simultaneous node failures a
grid-shaped network tolerates before its two sides are disconnected. Corollary 3.10
shows this equals the height $m+1$ and is invariant under widening the network.

**Disjoint routing and logistics.** The $m+1$ rows are independent, non-interfering
supply lanes. Theorem 3.8 certifies that this many independent routes always exist,
and Theorem 3.9 certifies that an adversary needs exactly that many node removals
to sever all routes — a tight, adversarial guarantee.

**Image segmentation.** Vertex min-cut on grids is the mathematical core of
graph-cut segmentation; the column separator is the cheapest vertical seam and the
row paths are the threads it must cut. The discrete IVT explains why any monotone
labelling (e.g., a horizontal intensity gradient) induces a valid seam.

**Treewidth and structural complexity.** Large unavoidable separators are the
hallmark of high treewidth. The optimality result is a building block for the
classical lower bound that the $(m+1)\times(n+1)$ grid has treewidth at least
$\min(m,n)+1$: grids resist small separators precisely because every cut between
opposite sides must be at least as large as the corresponding dimension.

**Wall-based minor theory.** The result is a sharp instance of the wall–Menger
separator optimality philosophy: for the cleanest test geometry, the separator
bound equals the classical Menger bound with no slack, supporting the conjecture
that walls are no harder to separate than Menger's theorem already guarantees for
arbitrary graphs.

## 6. Discussion

The proof strategy is a deliberate asymmetry: we use only the *easy* direction of
Menger's theorem (disjoint paths $\Rightarrow$ large separator) and supply the
*disjoint paths themselves* by explicit construction (the rows). This sidesteps the
hard direction of Menger (large separator $\Rightarrow$ disjoint paths) entirely.
Because the rows already realize the maximum, the optimal value is pinned from both
sides without the heavier machinery. This is a recurring and underappreciated
pattern: when one extremal object can be exhibited concretely, only the trivial
half of a duality is needed to certify optimality of the other.

The two abstract lemmas are the lasting contributions beyond the grid itself. The
*easy Menger lower bound* (Theorem 3.1) is stated for arbitrary graphs, arbitrary
regions, and walk-based separators, so it applies verbatim to any future disjoint
path construction. The *discrete IVT* (Theorem 3.2) is a clean, reusable tool: any
layered structure with a one-Lipschitz potential yields separators as level sets.
Together they constitute a small, transferable toolkit for separator lower bounds
and constructions.

A notable feature of the final value is its **width-independence**. The minimum cut
is $m+1$ regardless of $n$. Intuitively, the only obstruction to widening the cut
is the height of the grid; making the grid wider adds more columns, each of which
is independently a separator of the same size, but does not create additional
independent routes. This is the discrete analogue of the fact that the bottleneck of
a uniform rectangular channel is its narrower dimension.

## 7. Future work

Several natural extensions remain open and testable.

- **Two-sided (corner-to-corner) cuts.** For separating two opposite *corners*
  rather than full opposite columns, the minimum separator should equal
  $\min(m,n)+1$, requiring a 2D "monotone staircase" extension of the discrete IVT
  and a matching disjoint corner-to-corner path family.
- **The hard direction of Menger on grids.** Establish the converse of Theorem 3.1
  for grids: if every $A$–$B$ separator has size at least $k$, then $k$ disjoint
  paths exist. A natural route is to first prove the $k=1$ (connectivity) case and
  induct, and to show every minimum separator is a transversal hitting each row
  once.
- **Subdivided walls.** For the elementary wall of order $r$ (a brick-wall
  subdivision of a grid), the minimum separator between its left and right pegs
  should equal $r$ and be invariant under edge subdivision; the column-coordinate
  IVT argument should be subdivision-invariant.
- **Treewidth lower bounds.** Derive the grid treewidth bound
  $\ge \min(m,n)+1$ from separator optimality via a balanced-separator / bramble
  formulation linked to Theorem 3.1.
- **Generalized box products.** For connected graphs $G, H$ and an induced
  $a$–$b$ path in $H$, the minimum separator in $G\,\square\,H$ between
  $\{x : x_2 = a\}$ and $\{x : x_2 = b\}$ should equal $|V(G)|$; the
  $\mathrm{rowHom}$/IVT machinery should generalize verbatim with the labelling
  $f = d_H(\cdot, a)$ replacing the column index.

## 8. Conclusion

For the left–right cut of the $(m+1)\times(n+1)$ grid we have determined the exact
Menger value: the minimum vertex separator and the maximum number of disjoint paths
both equal $m+1$, the height, independent of the width. The proof rests on two
transferable lemmas — an abstract easy-direction Menger lower bound and a discrete
intermediate value theorem along walks — and exhibits matching extremal objects (a
column separator and the row paths) that squeeze the optimum to a single value.
Beyond its own statement, the result is a sharp, fully verified instance of the
wall–Menger separator optimality conjecture, showing that on the cleanest geometry
the Menger bound is achieved with no slack.
