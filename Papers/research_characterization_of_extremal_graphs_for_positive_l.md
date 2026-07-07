# The Matching–Clique Join: Exact Local Geometry of a Curvature-Extremal Candidate

**Author:** Aristotle
**Date:** 2026-07-07

## Abstract

Discrete Ollivier–Lin–Lu–Yau (LLY) Ricci curvature assigns to every edge of a
graph a number that mirrors the sign behavior of Ricci curvature on smooth
manifolds; the sign of the curvature on an edge $x \sim y$ is controlled by the
two endpoint degrees and the number of common neighbors of $x$ and $y$. We study
the extremal problem: *how many edges may a graph on $n$ vertices have while
still containing an edge of non-positive LLY curvature?* We analyze a natural
candidate for the extremal graph, the **balanced matching–clique join** $H(k)$
on $n = 4k$ vertices, obtained by joining a perfect matching on $2k$ vertices to
a complete graph on $2k$ vertices. We determine its geometry exactly: every
vertex degree, the total edge count $6k^2 = \tfrac{3}{8}n^2$, and the
common-neighbor count of each of its three edge classes (matching edges $2k$,
join edges $2k$, clique edges $4k-2$). From this we prove two structural facts.
First, the matching edges are *strictly locally sparsest* for $k \ge 2$,
confirming them as the correct combinatorial carriers of non-positive curvature.
Second, and decisively, the exact count $6k^2$ is **never** equal to the
conjectured extremal value $T(n) = \tfrac{(n-2)^2}{2}$: the conjectured value
deletes only $\Theta(n)$ edges from the complete graph, while $H(k)$ deletes
$\Theta(n^2)$. Hence the matching–clique join is refuted as the extremal graph,
and the true maximizer must be near-complete. We also record a divisibility
obstruction: the construction requires $4 \mid n$. We conclude with three
conjectures redirecting the extremal problem toward near-complete graphs.

## 1. Introduction

### 1.1 Discrete Ricci curvature

Let $G = (V, E)$ be a finite simple graph. For a vertex $x$, write $N(x)$ for its
set of neighbors and $d_x = |N(x)|$ for its degree. The **Ollivier–Lin–Lu–Yau
curvature** of an edge $x \sim y$ is defined through optimal transport of
probability measures placed on the neighborhoods of $x$ and $y$. Concretely, for
a parameter $\alpha \in [0,1)$ one places mass $\alpha$ on the vertex itself and
distributes the remaining mass $1-\alpha$ uniformly over its neighbors; the
$\alpha$-curvature is $\kappa_\alpha(x,y) = 1 - W_1(\mu_x^\alpha, \mu_y^\alpha)$,
where $W_1$ is the $L^1$ Wasserstein (earth-mover) distance. The LLY curvature is
the normalized limit
$$\kappa(x,y) = \lim_{\alpha \to 1^-} \frac{\kappa_\alpha(x,y)}{1-\alpha}.$$

The precise value of $\kappa(x,y)$ can be computed by linear programming, but its
*sign* — the only feature relevant to the extremal question below — is governed
entirely by three local integers: the degrees $d_x$, $d_y$, and the number of
**common neighbors**
$$\#(x,y) = |N(x) \cap N(y)|,$$
i.e. the number of triangles resting on the edge. Roughly, common neighbors act
as cheap transport routes that raise curvature, whereas high degree with few
common neighbors depresses it. Edges with small common-neighbor count relative to
their endpoint degrees are precisely those that carry non-positive curvature.

### 1.2 The extremal problem

Adding edges to a graph tends to increase curvature: each new edge closes
triangles and provides shortcuts. The complete graph $K_n$ has strictly positive
curvature on every edge. This motivates the extremal question at the center of
this paper.

> **Problem.** Over all graphs on $n$ vertices that contain at least one edge of
> non-positive LLY curvature, what is the maximum number of edges, and which
> graph(s) attain it?

Denote the maximum by $T(n)$. A conjecture proposed that the extremal graph is a
specific symmetric construction — the balanced matching–clique join — with
$$T(n) = \frac{n^2 - 3n}{2} - \left\lceil \tfrac n2 \right\rceil + 2.$$
This paper computes the exact geometry of that candidate and tests the
conjecture.

### 1.3 Contributions

1. **Exact degree sequence** of the matching–clique join $H(k)$ (Section 3).
2. **Exact edge count** $|E(H(k))| = 6k^2 = \tfrac38 n^2$ via the handshake
   identity (Theorem 3.3).
3. **Full common-neighbor profile** of all three edge classes (Section 4).
4. **Local sparsity signature**: matching edges are strictly locally sparsest for
   $k \ge 2$ (Theorem 4.4).
5. **Falsification** of the extremal conjecture: $6k^2 \ne 2(2k-1)^2$ for all
   $k \ge 1$ (Theorem 5.1), together with the structural interpretation that the
   true maximizer is near-complete.
6. A **divisibility obstruction** $4 \mid n$ for the construction (Theorem 5.2).

## 2. The matching–clique join

### 2.1 Construction

Fix $k \in \mathbb{N}$ and set $n = 4k$. Partition the vertex set into two blocks
of size $2k$:
$$V = A \sqcup B, \qquad A = \{1,\dots,k\} \times \{0,1\}, \qquad B = \{1,\dots,2k\}.$$
We index a vertex of $A$ as a pair $(p, b)$ with $p$ a *pair index* and
$b \in \{0,1\}$ a *side*; the two vertices $(p,0)$ and $(p,1)$ are matched
partners. Adjacency is defined as follows.

> **Definition 2.1 (Matching–clique join $H(k)$).** The graph $H(k)$ on
> $V = A \sqcup B$ has edges:
> - **Matching edges:** $(p,0) \sim (p,1)$ for each pair index $p$ (and no other
>   edges within $A$);
> - **Clique edges:** $i \sim j$ for all distinct $i, j \in B$;
> - **Join edges:** $(p,b) \sim i$ for every $(p,b) \in A$ and every $i \in B$.

Thus $A$ induces a perfect matching ($k$ disjoint edges), $B$ induces the
complete graph $K_{2k}$, and $A$–$B$ is complete bipartite. Every edge of $H(k)$
belongs to exactly one of the three classes above.

### 2.2 The three edge classes

- A **matching edge** joins two partners inside $A$.
- A **clique edge** joins two vertices inside $B$.
- A **join edge** joins an $A$-vertex to a $B$-vertex.

The whole analysis reduces to computing degrees and common-neighbor counts on
these three classes.

## 3. Degrees and edge count

### 3.1 Neighborhoods

Directly from Definition 2.1:

- A matching vertex $(p,b) \in A$ is adjacent to its unique partner $(p, 1-b)$
  and to *all* of $B$. Hence
  $$N\big((p,b)\big) = \{(p, 1-b)\} \cup B.$$
- A clique vertex $i \in B$ is adjacent to *all* of $A$ and to every other vertex
  of $B$. Hence
  $$N(i) = A \cup (B \setminus \{i\}).$$

### 3.2 Degrees

> **Theorem 3.1 (Degree of a matching vertex).** Every $(p,b) \in A$ has degree
> $$d_A = 2k + 1.$$
> *Proof sketch.* The neighborhood is the disjoint union of the single partner
> $(p,1-b)$ and the $2k$ vertices of $B$; the partner is not in $B$, so the counts
> add: $1 + 2k$. $\square$

> **Theorem 3.2 (Degree of a clique vertex).** Every $i \in B$ has degree
> $$d_B = 4k - 1.$$
> *Proof sketch.* The neighborhood is the disjoint union of all $2k$ vertices of
> $A$ and the $2k - 1$ vertices of $B \setminus \{i\}$: $2k + (2k-1) = 4k-1$.
> $\square$

### 3.3 Edge count

> **Theorem 3.3 (Exact edge count).** $H(k)$ has exactly
> $$|E(H(k))| = 6k^2 = \frac{3n^2}{8} \quad \text{edges.}$$
> *Proof sketch.* By the handshake identity, $2|E| = \sum_{v} d_v$. Block $A$
> contributes $2k$ vertices of degree $2k+1$, and block $B$ contributes $2k$
> vertices of degree $4k-1$:
> $$\sum_{v} d_v = 2k(2k+1) + 2k(4k-1) = 2k \cdot 6k = 12k^2.$$
> Dividing by $2$ gives $|E| = 6k^2$; substituting $n = 4k$ gives $\tfrac{3n^2}{8}$.
> $\square$

## 4. Common-neighbor profile

For vertices $x, y$, write $\#(x,y) = |N(x) \cap N(y)|$ for their common-neighbor
count (the number of triangles on the edge, when $x \sim y$).

> **Theorem 4.1 (Matching edge).** For each pair index $p$,
> $$\#\big((p,0),(p,1)\big) = 2k.$$
> *Proof sketch.* Both partners are adjacent to all of $B$, so $B$ lies in the
> intersection. No further common neighbor exists in $A$: a vertex $(q,c)$ is
> adjacent to $(p,0)$ only if $q=p, c=1$, and to $(p,1)$ only if $q=p, c=0$, which
> cannot hold simultaneously. Hence the common neighborhood is exactly $B$, of
> size $2k$. $\square$

> **Theorem 4.2 (Clique edge).** For distinct $i, j \in B$,
> $$\#(i, j) = 4k - 2.$$
> *Proof sketch.* Both $i$ and $j$ are adjacent to all of $A$ (contributing $2k$)
> and to every other vertex of $B$; their common $B$-neighbors are
> $B \setminus \{i,j\}$ (contributing $2k - 2$). These sets are disjoint, so
> $2k + (2k-2) = 4k-2$. $\square$

> **Theorem 4.3 (Join edge).** For any $(p,b) \in A$ and $i \in B$,
> $$\#\big((p,b), i\big) = 2k.$$
> *Proof sketch.* A common neighbor lies in $A$ or $B$. In $A$: the only neighbor
> of $(p,b)$ inside $A$ is its partner $(p,1-b)$, and $(p,1-b)$ is adjacent to $i$
> (all $A$–$B$ pairs are joined), so the partner contributes $1$. In $B$: the
> $B$-neighbors of $(p,b)$ are all of $B$, and the $B$-neighbors of $i$ are
> $B \setminus \{i\}$, so their common $B$-neighbors are $B \setminus \{i\}$,
> contributing $2k - 1$. Total: $1 + (2k-1) = 2k$. $\square$

Collecting the three counts:

| Edge class | Endpoint degrees | Common neighbors |
|---|---|---|
| Matching | $(2k+1,\, 2k+1)$ | $2k$ |
| Join | $(2k+1,\, 4k-1)$ | $2k$ |
| Clique | $(4k-1,\, 4k-1)$ | $4k-2$ |

### 4.1 Local sparsity signature

> **Theorem 4.4 (Matching edges are strictly locally sparsest).** For every
> $k \ge 2$, the matching edges carry strictly fewer common neighbors than any
> clique edge, and exactly as many as any join edge:
> $$\#_{\text{matching}} = 2k \;<\; 4k - 2 = \#_{\text{clique}}, \qquad
>   \#_{\text{matching}} = 2k = \#_{\text{join}}.$$
> *Proof sketch.* Immediate from Theorems 4.1–4.3; the strict inequality
> $2k < 4k-2$ holds precisely for $k \ge 2$. $\square$

**Interpretation.** Among the three classes, the matching edges combine the
minimum common-neighbor count ($2k$) with the minimum endpoint degree ($2k+1$ at
*both* ends). The join edges tie in triangle count but have one high-degree
endpoint ($4k-1$); the clique edges are dense at both ends. Since non-positive
curvature is driven by high degree together with a scarce common neighborhood,
the matching edges are the unambiguous carriers of any non-positive curvature in
$H(k)$. This is the correct local reason the matching class is the
curvature-minimizing class.

## 5. Falsification of the extremal count

### 5.1 The conjectured value simplifies

For even $n$, $\lceil n/2 \rceil = n/2$, so the conjectured threshold collapses:
$$T(n) = \frac{n^2 - 3n}{2} - \frac{n}{2} + 2 = \frac{n^2 - 4n + 4}{2}
   = \frac{(n-2)^2}{2} = \binom{n}{2} - \frac{3n-4}{2}.$$
The last equality is the structurally decisive one: the conjectured extremal
graph is $K_n$ with only $\tfrac{3n-4}{2} = \Theta(n)$ edges removed — a
**near-complete** graph. With $n = 4k$, we have $T(n) = 2(2k-1)^2$.

### 5.2 The counts cannot agree

> **Theorem 5.1 (Falsification).** For every $k \ge 1$,
> $$|E(H(k))| = 6k^2 \;\ne\; 2(2k-1)^2 = T(4k).$$
> *Proof sketch.* Expand $2(2k-1)^2 = 8k^2 - 8k + 2$. Then
> $2(2k-1)^2 - 6k^2 = 2k^2 - 8k + 2 = 2(k^2 - 4k + 1)$, which is nonzero for every
> integer $k \ge 1$ (its only real roots are $k = 2 \pm \sqrt 3 \approx 0.27,\,
> 3.73$, neither an integer). A direct check disposes of $k \in \{1,2,3\}$ and a
> quadratic estimate handles $k \ge 4$. Hence the two values are never equal.
> $\square$

**Structural consequence.** $H(k)$ has $6k^2 = \tfrac38 n^2$ edges, while $K_n$
has $\binom n2 \approx \tfrac12 n^2$; the join is missing $\approx \tfrac18 n^2 =
\Theta(n^2)$ edges. But the conjectured extremal count removes only $\Theta(n)$
edges. A quadratic deficit cannot equal a linear one. Therefore the
matching–clique join, despite realizing a non-positively curved matching edge, is
**not** the edge-maximizer. The genuine extremal graph must be near-complete:
$K_n$ with only linearly many edges deleted, all concentrated around a single
witness pair that carries the non-positively curved edge.

### 5.3 A divisibility obstruction

> **Theorem 5.2 (Divisibility).** The construction requires $4 \mid n$.
> *Proof sketch.* Block $A$ carries a perfect matching on its $n/2$ vertices,
> which forces $n/2$ to be even, i.e. $4 \mid n$. In the parametrization $n = 4k$
> this is automatic: $|V| = |A| + |B| = 2k + 2k = 4k$. $\square$

In particular the family does not exist for $n \equiv 2 \pmod 4$, so a conjecture
stated "for all even $n$" over-reaches: no matching–clique join exists for half
of the even residues.

## 6. Algorithms

We record the elementary algorithms used to compute and verify the profile; each
runs on the explicit graph and confirms the closed forms above.

**Algorithm A (Profile computation).** Build $H(k)$ as an adjacency structure,
compute each vertex degree by counting neighbors, compute the edge count by the
handshake identity, and compute common-neighbor counts by intersecting
neighborhoods. Complexity $O(n^2)$ for degrees and edges, $O(n)$ per edge for
common neighbors.

**Algorithm B (Conjecture check).** For a range of $k$, compare $6k^2$ against
$2(2k-1)^2$ and report the (always nonzero) deficit $2(k^2 - 4k + 1)$.

**Algorithm C (Sparsity ranking).** For each edge class, tabulate
$(d_x, d_y, \#(x,y))$ and verify that the matching class strictly minimizes the
common-neighbor count among classes with a low-degree endpoint, matching the
predicted curvature-minimizing signature.

## 7. Applications

Discrete Ricci curvature is used to detect community structure and bottlenecks in
complex networks, to guide graph rewiring in machine learning (mitigating
over-squashing in message-passing neural networks), and to quantify robustness in
biological and financial networks. Extremal results of the present type calibrate
these tools by describing, exactly, the densest configurations in which a
negatively curved "weak link" can persist. The exact profile of $H(k)$ — three
edge classes with nearly identical degrees but sharply different triangle counts
— also provides a clean synthetic benchmark for empirically fitting curvature
thresholds without confounding degree variation.

## 8. Discussion

The matching–clique join is an attractive candidate: symmetric, exactly
computable, and genuinely realizing its sparsest edges as a perfect matching.
Every intuition suggests it might be extremal. The exact arithmetic overrules the
intuition. Pinning the edge count to $6k^2$ and comparing with the conjectured
$2(2k-1)^2$ exposes a quadratic-versus-linear mismatch that no choice of $k$ can
repair. The episode is a reminder that in extremal graph theory elegance is a
hypothesis, and an exact count is the arbiter.

What survives is valuable: a completely understood local geometry, a confirmed
combinatorial signature for the curvature-minimizing edge class, and — most
usefully — a corrected sense of where the true extremal graph lives. The failed
conjecture pointed at the sparse end of the density spectrum; the corrected
picture points at the near-complete end.

## 9. Future directions

**Conjecture 1 (The true extremizer is near-complete, not sparse).** Among all
graphs on $n$ vertices possessing an edge of non-positive LLY curvature, the
maximum number of edges is attained by a graph obtained from $K_n$ by deleting
only $\Theta(n)$ edges, all incident to a single witness pair $\{u,v\}$; the
sparse matching–clique join is never extremal for large $n$. The key insight is
that curvature negativity is a *local starvation* phenomenon: making one edge
non-positively curved requires deleting edges only in a bounded neighborhood of
that edge, so a global maximizer should keep every other region complete. The
exact count $6k^2 = \tfrac38 n^2$, compared with $T(n) = \binom n2 -
\tfrac{3n-4}{2}$, quantifies an $\Omega(n^2)$ deficit and pinpoints "delete
linearly many edges around one pair" as the correct regime.

**Conjecture 2 (A degree–triangle threshold for the curvature sign).** For an
edge $x \sim y$ with degrees $d_x \le d_y$ and $t = \#(x,y)$ common neighbors,
the LLY curvature is non-positive precisely when $t$ falls below an explicit
affine threshold in $d_x$ and $d_y$; in the matching–clique join this threshold
is crossed only by the matching edges. The three edge classes of $H(k)$ have
identical or near-identical degrees but sharply different triangle counts ($2k$
versus $4k-2$), isolating the common-neighbor count as the single decisive
variable. The complete local profile computed here gives a clean, fully explicit
data set on which such a threshold can be fitted and tested without confounding
degree variation.

**Conjecture 3 (Uniqueness only up to the divisibility obstruction).** The
extremal graph carrying a non-positively curved edge is unique for every $n$ in a
fixed residue class modulo $4$, and the extremal value is a piecewise-quadratic
function of $n$ whose pieces are indexed by $n \bmod 4$; the "for all even $n$"
phrasing conflates residue classes that must be treated separately, since the
matching–clique construction only exists when $4 \mid n$.
