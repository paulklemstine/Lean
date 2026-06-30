# The No-Stretching Property of Hypercube Labelings Induced by Edge Partitions

## Abstract

Let $G$ be a connected graph and let $\ell$ be a labeling of its vertices by the
corners of a binary hypercube $Q_k$ — that is, by length-$k$ strings over the
field $\mathbb{Z}/2\mathbb{Z}$ — with the property that every edge of $G$ joins
two vertices whose labels are either equal or differ in exactly one coordinate.
We prove that such a labeling is **non-expansive**: for all vertices $u,v$,
$$d_{Q_k}\big(\ell(u),\ell(v)\big) \le d_G(u,v),$$
where $d_G$ is graph distance and $d_{Q_k}$ is hypercube distance. The labeling
can therefore fail to be isometric only by *contracting* distances (taking
shortcuts), never by *stretching* them. The argument rests on the elementary but
fundamental identity that hypercube distance equals Hamming distance, together
with a length-monotone push-forward of walks. The canonical source of such
labelings is the parity quotient attached to an edge partition of $G$: sorting
the edges into $t$ classes and recording class-parities of walks modulo the
graph's cycle space yields a labeling into a hypercube of dimension
$t - \mathrm{rank}(A)$, where $A$ is the cycle-class parity matrix over
$\mathbb{Z}/2\mathbb{Z}$. We develop the theory in self-contained form, give
algorithms for computing labels and the resulting distance defect, and discuss
the one-sided distortion as an invariant connecting partial-cube recognition,
low-distortion embeddings, and coding theory.

**Keywords.** hypercube, Hamming distance, non-expansive map, edge partition,
cycle space, partial cube, GF(2), graph metric, low-distortion embedding.

---

## 1. Introduction

A recurring theme across combinatorics, coding theory, and the geometry of metric
spaces is the attempt to represent the vertices of a graph as binary strings so
that graph adjacency is reflected by simple bitwise structure. The cleanest such
representations are the *isometric* ones, in which graph distance is reproduced
exactly by Hamming distance; the graphs admitting them are precisely the
**partial cubes**, a class with a deep and elegant theory rooted in the
Djoković–Winkler relation.

Isometry, however, is a strong demand that most graphs cannot meet. This paper
isolates the part of the story that holds *unconditionally*, for every connected
graph and every reasonable labeling. We show that as long as a labeling changes
by at most one coordinate along each edge — the natural local constraint shared by
all parity labelings — it can distort distances in only one direction. It may
contract, but it can never expand.

The result is deliberately minimal in its hypotheses, which makes it broadly
applicable. We require neither that the labeling be injective, nor that it be
surjective onto any subcube, nor that the graph be bipartite. We require only
connectedness of $G$ and the per-edge bound. In return we obtain a universal
upper bound on labeled distance, and with it a clean, always-nonnegative measure
of how far a labeling falls short of isometry.

### 1.1 Contributions

1. A self-contained development of the metric of the binary hypercube, including
   the identity $d_{Q_k} = \mathrm{H}$ (Theorem 3.4).
2. A length-monotone push-forward of walks under any edge-gentle labeling
   (Theorem 4.2).
3. The **No-Stretching Theorem** (Theorem 4.3): non-expansiveness of edge-gentle
   labelings on connected graphs.
4. A description of the canonical edge-partition parity labeling that supplies the
   hypothesis, and an interpretation of the resulting distortion as a defect
   invariant (Sections 2 and 5).
5. Algorithms for computing labels, hypercube distances, and the total
   contraction defect, with complexity analysis (Section 6).

---

## 2. The edge-partition labeling

We begin with the construction that motivates the entire development.

### 2.1 Edge partitions and the cycle-class parity matrix

Let $G = (V,E)$ be a connected graph and let
$P = \{E_1, \dots, E_t\}$ be a partition of its edge set into $t$ nonempty
classes. Assign to each edge $e$ the standard basis vector $\mathbf{e}_{c(e)} \in
(\mathbb{Z}/2\mathbb{Z})^t$, where $c(e)$ is the index of the class containing
$e$.

Fix a base vertex $r$. For a vertex $v$, choose any walk $W$ from $r$ to $v$ and
form the **raw parity vector**
$$\sigma(W) = \sum_{e \in W} \mathbf{e}_{c(e)} \in (\mathbb{Z}/2\mathbb{Z})^t,$$
the sum taken with multiplicity and reduced modulo $2$; coordinate $j$ records the
parity of the number of class-$j$ edges traversed by $W$.

This raw vector depends on the choice of walk, but only up to the **cycle space**
of $G$. Concretely, any two $r$–$v$ walks differ by a closed walk, and the
class-parity vectors of closed walks form a subspace $\mathcal{C} \subseteq
(\mathbb{Z}/2\mathbb{Z})^t$. Let $A$ be the **cycle-class parity matrix** whose
rows are the class-parity vectors of a cycle basis of $G$; then $\mathcal{C} =
\mathrm{row\,space}(A)$ and $\dim \mathcal{C} = \mathrm{rank}(A)$.

### 2.2 The quotient labeling

Passing to the quotient kills the ambiguity. Define
$$\ell \colon V \longrightarrow (\mathbb{Z}/2\mathbb{Z})^t / \mathcal{C}, \qquad
\ell(v) = \sigma(W) + \mathcal{C}$$
for any $r$–$v$ walk $W$. The target is a vector space of dimension
$$k := t - \mathrm{rank}(A),$$
and a choice of basis identifies it with the hypercube $Q_k$.

**One generator per edge.** If $\{u,v\}$ is an edge of $G$ in class $j$, then
appending it to a walk to $u$ adds $\mathbf{e}_j$ to the raw parity vector. Hence
$$\ell(v) - \ell(u) = \bar{\mathbf{e}}_j := \mathbf{e}_j + \mathcal{C},$$
which is either the zero coset (when $\mathbf{e}_j \in \mathcal{C}$, i.e. the class
direction is collapsed by the cycle space) or one of the class generators. The
natural target geometry is therefore the **Cayley graph** $H$ on the quotient
group $(\mathbb{Z}/2\mathbb{Z})^k$ with generating set $\{\bar{\mathbf{e}}_1,
\dots, \bar{\mathbf{e}}_t\}$: every edge of $G$ moves the label by exactly one
generator. Running the push-forward argument of Section 4 verbatim with $H$ in
place of $Q_k$ shows the labeling is non-expansive into $H$,
$$d_H(\ell(u),\ell(v)) \le d_G(u,v) \quad\text{for all } u,v.$$

**The Hamming special case.** When the surviving class generators are *distinct
standard basis vectors* — equivalently, when each surviving class corresponds to a
single independent coordinate — the Cayley graph $H$ is precisely the standard
Hamming hypercube $Q_k$ of Section 3, and the labeling is *edge-gentle* in the
sense of Definition 4.1. This is the situation of the Djoković–Winkler relation
used to recognize partial cubes: when $P$ is that relation and the cycle space
collapses no surviving direction, $\ell$ is isometric and exhibits $G$ as a
partial cube. For a general partition the class images may be linearly dependent
(for instance, in a triangle with each edge its own class the three generators
become $\bar{\mathbf{e}}_1, \bar{\mathbf{e}}_2, \bar{\mathbf{e}}_1 +
\bar{\mathbf{e}}_2$, so $H$ is the complete graph $K_4$ rather than $Q_2$); the
labeling need not be isometric, and controlling that failure is the subject of
this paper. Sections 3–4 develop the Hamming case, which already contains the full
strength of the push-forward argument; the Cayley-graph generalization is
immediate.

---

## 3. The hypercube metric

We now develop the metric of $Q_k$ from scratch. Throughout, a vertex of $Q_k$ is
a function $x \colon \{0,1,\dots,k-1\} \to \mathbb{Z}/2\mathbb{Z}$.

### 3.1 Hamming distance

**Definition 3.1 (Hamming distance).** For $x,y \in Q_k$,
$$\mathrm{H}(x,y) = \#\{\, i : x_i \neq y_i \,\}.$$

**Lemma 3.2 (basic properties).** For all $x,y,z \in Q_k$:
(i) $\mathrm{H}(x,y)=\mathrm{H}(y,x)$;
(ii) $\mathrm{H}(x,y)=0 \iff x=y$;
(iii) $\mathrm{H}(x,z) \le \mathrm{H}(x,y)+\mathrm{H}(y,z)$.

*Proof.* (i) Symmetry of the relation $x_i \ne y_i$. (ii) The disagreement set is
empty iff the strings agree in every coordinate. (iii) Any coordinate where $x$
and $z$ differ must be a coordinate where $x$ differs from $y$ or $y$ differs from
$z$; hence the disagreement set of $(x,z)$ is contained in the union of those of
$(x,y)$ and $(y,z)$, and the bound follows from the size of a union. $\qquad\square$

Thus $\mathrm{H}$ is a metric on $Q_k$.

### 3.2 Adjacency and the hypercube graph

**Definition 3.3 (hypercube graph).** $Q_k$ is the graph on
$(\mathbb{Z}/2\mathbb{Z})^k$ in which $x$ and $y$ are adjacent iff
$\mathrm{H}(x,y)=1$.

For a coordinate $i$, write $\mathrm{flip}_i(x)$ for the string obtained by adding
$1$ to $x_i$ (leaving all other coordinates fixed). Then
$\mathrm{H}(x, \mathrm{flip}_i(x)) = 1$, so $x$ and $\mathrm{flip}_i(x)$ are
adjacent; these are the only neighbors of $x$.

A key arithmetic observation in $\mathbb{Z}/2\mathbb{Z}$: if $x_i \ne y_i$, then
$y_i = x_i + 1$, so flipping coordinate $i$ of $x$ removes exactly that one
disagreement. Formally,
$$x_i \ne y_i \implies \mathrm{H}(\mathrm{flip}_i(x), y) + 1 = \mathrm{H}(x,y). \tag{$\ast$}$$

### 3.3 Distance equals Hamming distance

**Theorem 3.4 (hypercube distance).** For all $x,y \in Q_k$,
$$d_{Q_k}(x,y) = \mathrm{H}(x,y).$$

*Proof.* We prove both inequalities.

*Lower bound $d_{Q_k} \ge \mathrm{H}$.* Let $W$ be any walk in $Q_k$ from $x$ to
$y$, say $x = w_0, w_1, \dots, w_L = y$. Each step is a cube edge, so
$\mathrm{H}(w_{i-1},w_i)=1$. By the triangle inequality (Lemma 3.2(iii)) applied
repeatedly,
$$\mathrm{H}(x,y) \le \sum_{i=1}^{L} \mathrm{H}(w_{i-1},w_i) = L.$$
Since this holds for every walk, in particular for a shortest one, $\mathrm{H}(x,y)
\le d_{Q_k}(x,y)$. (Inductively: a walk of length $0$ joins equal endpoints with
$\mathrm{H}=0$; prepending one edge of Hamming length $1$ raises the bound by at
most $1$.)

*Upper bound $d_{Q_k} \le \mathrm{H}$.* We construct a walk of length exactly
$\mathrm{H}(x,y)$ by induction on $n = \mathrm{H}(x,y)$. If $n=0$ then $x=y$ by
Lemma 3.2(ii) and the empty walk suffices. If $n = m+1 > 0$, then $x \ne y$, so
there is a coordinate $i$ with $x_i \ne y_i$. Let $x' = \mathrm{flip}_i(x)$. Then
$x$ and $x'$ are adjacent, and by $(\ast)$ we have $\mathrm{H}(x',y) = m$. By the
inductive hypothesis there is a walk from $x'$ to $y$ of length $m$; prepending
the edge $x \to x'$ yields a walk from $x$ to $y$ of length $m+1 = n$. Hence
$d_{Q_k}(x,y) \le \mathrm{H}(x,y)$.

Combining the two bounds gives equality. $\qquad\square$

Theorem 3.4 is the engine of everything that follows: it lets us replace the
shortest-path distance in $Q_k$ by the algebraically transparent Hamming count.

---

## 4. The No-Stretching Theorem

We now fix a connected graph $G=(V,E)$ and a labeling $\ell \colon V \to Q_k$.

**Definition 4.1 (edge-gentle labeling).** The labeling $\ell$ is *edge-gentle*
if for every edge $\{u,v\}$ of $G$,
$$\ell(u) = \ell(v) \quad \text{or} \quad \mathrm{H}(\ell(u),\ell(v)) = 1.$$

By Section 2, every parity quotient labeling of an edge partition is edge-gentle.

### 4.1 Push-forward of walks

**Theorem 4.2 (length-monotone image walk).** Let $\ell$ be edge-gentle. For every
walk $W$ in $G$ from $u$ to $v$ there is a walk $W'$ in $Q_k$ from $\ell(u)$ to
$\ell(v)$ with
$$\mathrm{length}(W') \le \mathrm{length}(W).$$

*Proof.* Induct on $W$. If $W$ is the trivial walk at $u$, take $W'$ trivial at
$\ell(u)$; lengths are both $0$. Otherwise $W = (u \to b) \cdot P$, where $u \to
b$ is an edge and $P$ is a walk from $b$ to $v$. By induction there is a walk $P'$
from $\ell(b)$ to $\ell(v)$ with $\mathrm{length}(P') \le \mathrm{length}(P)$.
Edge-gentleness gives two cases.

- If $\ell(u) = \ell(b)$: transport $P'$ to start at $\ell(u)$ (it already ends at
  $\ell(v)$). Its length is unchanged, and $\mathrm{length}(P') \le
  \mathrm{length}(P) < \mathrm{length}(W)$.
- If $\mathrm{H}(\ell(u),\ell(b)) = 1$: then $\ell(u)$ and $\ell(b)$ are adjacent
  in $Q_k$, so we may prepend that single edge to $P'$, obtaining $W'$ with
  $\mathrm{length}(W') = \mathrm{length}(P') + 1 \le \mathrm{length}(P) + 1 =
  \mathrm{length}(W)$.

In both cases $\mathrm{length}(W') \le \mathrm{length}(W)$. $\qquad\square$

The proof literally *contracts*: the "equal-label" edges are dropped, so the
image walk is always at least as short as its preimage.

### 4.2 Non-expansiveness

**Theorem 4.3 (No-Stretching Theorem).** Let $G$ be connected and let $\ell
\colon V \to Q_k$ be edge-gentle. Then for all $u,v \in V$,
$$d_{Q_k}\big(\ell(u),\ell(v)\big) \le d_G(u,v).$$
Equivalently, by Theorem 3.4, $\mathrm{H}(\ell(u),\ell(v)) \le d_G(u,v)$.

*Proof.* Since $G$ is connected there is a geodesic walk $W$ from $u$ to $v$ with
$\mathrm{length}(W) = d_G(u,v)$. By Theorem 4.2 there is a walk $W'$ in $Q_k$ from
$\ell(u)$ to $\ell(v)$ with $\mathrm{length}(W') \le \mathrm{length}(W)$. The
hypercube distance, being the minimum walk length, satisfies
$$d_{Q_k}(\ell(u),\ell(v)) \le \mathrm{length}(W') \le \mathrm{length}(W) =
d_G(u,v). \qquad\square$$

**Corollary 4.4 (one-sided distortion).** An edge-gentle labeling of a connected
graph is non-expansive. Its failure to be isometric is entirely one-sided: for all
$u,v$,
$$0 \le d_G(u,v) - d_{Q_k}(\ell(u),\ell(v)).$$
The labeling is isometric if and only if this defect vanishes for every pair.

The corollary motivates the central object of study in Section 5.

---

## 5. The contraction defect

**Definition 5.1 (pairwise and total defect).** For an edge-gentle labeling $\ell$
of a connected graph $G$, define the *pairwise defect*
$$\delta_\ell(u,v) = d_G(u,v) - d_{Q_k}(\ell(u),\ell(v)) \ge 0$$
and the *total defect*
$$\Delta(\ell) = \sum_{\{u,v\}} \delta_\ell(u,v),$$
the sum over unordered vertex pairs.

By Theorem 4.3 every term is nonnegative, so $\Delta(\ell) \ge 0$ with equality
iff $\ell$ is isometric. The defect is therefore a faithful, monotone gauge of how
far a partition is from witnessing a partial-cube embedding.

**Mechanism of the defect.** Each unit of defect arises from a closed walk whose
class-parities cancel: a cycle that the partition fails to "see" forces two
labels to coincide that geography would keep apart. In the quotient picture of
Section 2, this is exactly the collapse of a class direction $\mathbf{e}_j$ into
the cycle space $\mathcal{C}$. Thus the defect counts, with multiplicity, the
cycles the partition collapses rather than resolves. Making this heuristic into an
exact cycle-space formula is the first open problem of Section 7.

**Two extremes.**

- The *trivial partition* with one class ($t=1$) collapses every cycle of even
  parity; its labeling is a single parity bit and contracts maximally.
- The *Djoković–Winkler partition* on a partial cube achieves $\Delta(\ell)=0$ and
  realizes the graph as an isometric subgraph of a hypercube.

Between these lie all intermediate partitions, with the defect interpolating
monotonically as classes are merged.

---

## 6. Worked examples

We illustrate the theory on small graphs; each can be checked by hand.

**A path is isometric.** Let $G$ be the path $0\!-\!1\!-\!2\!-\!3$ with each edge in
its own class ($t=3$). The graph is a tree, so the cycle space is trivial,
$\mathrm{rank}(A)=0$ and $k=3$. The labels are $\ell(0)=000$, $\ell(1)=100$,
$\ell(2)=110$, $\ell(3)=111$, each edge flipping one fresh coordinate. The labeling
is edge-gentle and isometric: $\mathrm{H}(\ell(i),\ell(j))=|i-j|=d_G(i,j)$, so
$\Delta(\ell)=0$. Every tree is a partial cube in this way.

**An even cycle is isometric under the opposite-edge partition.** Let $G$ be the
$4$-cycle $0\!-\!1\!-\!2\!-\!3\!-\!0$ and let the partition place opposite edges in
a common class: $\{01,23\}$ in class $0$ and $\{12,30\}$ in class $1$ ($t=2$). The
single independent cycle contributes the parity vector $00$ (each class is
crossed twice), so $\mathrm{rank}(A)=0$ and $k=2$. The labels are $\ell(0)=00$,
$\ell(1)=10$, $\ell(2)=11$, $\ell(3)=01$ — the four corners of $Q_2$ — and the
embedding is isometric. This is the Djoković–Winkler partition; both class
generators are standard basis vectors, so $H=Q_2$.

**A triangle must contract, and the target is $K_4$.** Let $G=K_3$ on
$\{0,1,2\}$ with each edge its own class ($t=3$). The single cycle has class-parity
$111$, so $\mathrm{rank}(A)=1$ and $k=2$. The class generators in the quotient are
$\bar{\mathbf e}_1=10$, $\bar{\mathbf e}_2=01$, $\bar{\mathbf e}_3=11$; they are
linearly dependent, so the Cayley target $H$ is the complete graph $K_4$, not the
Hamming cube $Q_2$. With labels $\ell(0)=00$, $\ell(1)=10$, $\ell(2)=11$, every
pair of vertices is at $H$-distance $1$, matching $d_G\equiv 1$, so the embedding
is isometric *into $K_4$*. Note that interpreting the same labels in the standard
Hamming cube would give $\mathrm{H}(\ell(0),\ell(2))=2 > 1 = d_G(0,2)$: the labeling
is *not* edge-gentle, which is exactly why the correct target is the Cayley graph
$H$. This is the canonical illustration that the no-stretching guarantee is a
statement about the generating set carried by the partition.

**A genuine contraction.** Label the path $0\!-\!1\!-\!2\!-\!3\!-\!4$ by the single
parity bit $\ell(v)=(v \bmod 2)\in Q_1$. Each edge flips the one coordinate, so the
labeling is edge-gentle and Theorem 4.3 applies; yet $\ell(0)=\ell(2)=\ell(4)=0$,
so $d_{Q_1}(\ell(0),\ell(4))=0 < 4 = d_G(0,4)$. Here the total defect is strictly
positive: the labeling contracts heavily, but never stretches.

## 7. Algorithms

We record the natural algorithms behind the construction, with complexity in terms
of $n=|V|$, $m=|E|$, and $t$ (number of classes); $k = t - \mathrm{rank}(A)$.

### 7.1 Computing the labels

Choose a spanning tree $T$ of $G$ rooted at $r$. The tree determines a label for
every vertex by accumulating class basis vectors along tree paths; non-tree edges
contribute the rows of the cycle-class parity matrix $A$, whose row space is
quotiented out.

```
Algorithm RAW-LABELS(G, P, r):
    fix spanning tree T of G rooted at r
    label[r] := 0 in (Z/2)^t
    for each vertex v in BFS/DFS order from r over T:
        let e = tree edge from parent(v) to v, class j
        label[v] := label[parent(v)] + e_j   (mod 2)
    return label   # raw parity vectors in (Z/2)^t
```

To pass to the quotient, compute a basis of $\mathcal{C}$ from the non-tree edges,
Gaussian-eliminate over $\mathbb{Z}/2\mathbb{Z}$ to obtain $\mathrm{rank}(A)$ and a
complementary coordinate system, and project each raw label onto the surviving
$k = t-\mathrm{rank}(A)$ coordinates. Raw labels cost $O(nt)$; the elimination
costs $O(m t^2 / 64)$ with bitset arithmetic.

### 7.2 Hypercube distance

By Theorem 3.4, $d_{Q_k}(x,y)$ is just $\mathrm{H}(x,y) = \mathrm{popcount}(x
\oplus y)$, computable in $O(k)$ time (or $O(k/64)$ with word-level XOR and
population count).

### 7.3 Total defect

```
Algorithm TOTAL-DEFECT(G, label):
    D := all-pairs shortest paths of G        # BFS from each vertex
    S := 0
    for each unordered pair {u, v}:
        S := S + ( D[u][v] - hamming(label[u], label[v]) )
    return S
```

All-pairs distances by repeated BFS cost $O(nm)$; the defect summation costs
$O(n^2 k)$. Every summand is guaranteed nonnegative by Theorem 4.3, which doubles
as a runtime sanity check: a negative term signals a bug in the labeling.

---

## 8. Discussion and future directions

The No-Stretching Theorem isolates the unconditional half of the partial-cube
story. Its value lies in turning the distortion of a labeling into a single
clean, always-nonnegative number — the contraction defect — that can be summed,
compared, and minimized. Three lines of inquiry follow naturally.

**A cycle-space formula for the defect.** We conjecture that the total defect of a
partition is zero exactly when the partition refines the canonical relation
grouping "directly opposite" edges, and that in general the defect is governed by
the dimension of the cycle space the partition fails to detect. The mechanism of
Section 5 makes the cycle-collapsing local and countable — one edge moves the
label by one direction — suggesting the global metric comparison reduces to a
bookkeeping of cancellations amenable to an exact formula.

**An intrinsic characterization of partial cubes.** We conjecture that a graph
admits a zero-defect partition iff it is a partial cube, and that among all such
partitions there is a unique coarsest one, obtained by merging classes whenever
the merge preserves zero defect. No-Stretching already supplies one inequality for
free; being a partial cube is then equivalent to closing the remaining gap, and
gap-closing is monotone under merging compatible classes, hinting at a tractable
lattice of "good" partitions.

**Concentration of random defects.** If the edges of a bounded-degree graph are
colored into a fixed number of classes uniformly at random, we conjecture that the
normalized contraction defect concentrates sharply around a deterministic value
determined only by the degree distribution and the number of classes. The per-edge
increment is an independent draw from a small abelian group, so labeled distance is
a sum of weakly dependent steps, exactly the setting where martingale concentration
is most effective.

Each direction grows from the same observation: once distortion is known to be
one-sided, its magnitude becomes a single invariant worth chasing.

---

## 9. Conclusion

We have shown that any labeling of a connected graph into a binary hypercube that
changes by at most one coordinate along each edge is non-expansive: labeled
distance never exceeds graph distance. The proof reduces, through the identity that
hypercube distance equals Hamming distance, to a length-monotone push-forward of
walks. The canonical source of such labelings — the parity quotient of an edge
partition — places the result at the foundation of partial-cube theory, where it
guarantees the one-sided distortion bound unconditionally and recasts the residual
distortion as a well-behaved invariant ripe for further study.
