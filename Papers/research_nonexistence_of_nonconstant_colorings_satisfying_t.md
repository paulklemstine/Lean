# Non-Existence of Non-Constant Blend Colorings on Strongly Connected Weighted Digraphs

**Author:** Aristotle
**Date:** 2026-07-04

## Abstract

We study *blend colorings* of finite edge-weighted directed graphs: assignments
of a real value to each vertex such that every vertex's value equals the
weighted convex combination of the values of the vertices it points to. Modeling
the graph by a row-stochastic weight matrix $w$ (so that the outgoing weights at
each vertex form a probability distribution), we prove that on a finite
**strongly connected** digraph every blend coloring is constant; equivalently,
no blend coloring assigns two vertices different values. The proof is a discrete
maximum principle: at a vertex attaining the global maximum value, the equality
case of the convex combination forces every positive-weight successor to also
attain the maximum, and strong connectivity propagates this to the whole graph.
This is a self-contained, elementary form of the classical statement that the
only harmonic functions of a finite irreducible Markov chain are the constants
(a discrete Liouville theorem). We record three companion results: a
vector-valued generalization obtained coordinatewise; a sharpness example
showing strong connectivity is necessary; and the specialization to the directed
$n$-cycle, an explicit infinite family of strongly connected instances. We also
frame quantitative and geometric extensions.

**Keywords:** blend coloring, harmonic function, discrete maximum principle,
row-stochastic matrix, strong connectivity, irreducible Markov chain, directed
cycle, discrete Liouville theorem, convex combination.

---

## 1. Introduction

A recurring theme across analysis, probability, and combinatorics is that a
*local averaging constraint* combined with *global connectivity* forces global
uniformity. The Laplace equation forbids interior maxima of harmonic functions;
a finite irreducible Markov chain has only constant harmonic functions; heat
flows until temperature is even. This paper isolates the purely combinatorial
core of these phenomena and proves it from first principles.

We work with a finite directed graph carrying nonnegative edge weights that are
*row-stochastic*: the weights leaving each vertex sum to one. A **blend
coloring** assigns to each vertex a real number equal to the weighted average of
the numbers on the vertices it points to. Our central question, framed as a
non-existence problem, is:

> *When does a finite edge-weighted digraph admit a non-constant blend
> coloring?*

Our main theorem answers this completely for strongly connected graphs: it does
not. The condition is sharp — dropping strong connectivity produces non-constant
blend colorings — and requires neither symmetry nor reversibility of the weights.

### 1.1 Contributions

1. **Main collapse theorem** (§3): on a finite strongly connected
   row-stochastic digraph, every blend coloring is constant.
2. **Local maximum principle** (§3.1): the reusable one-step lemma that
   maximality propagates along positive-weight arcs.
3. **Non-existence phrasing** (§3.2): there is no blend coloring taking two
   distinct values.
4. **Sharpness** (§4): a two-vertex non-strongly-connected example admitting a
   non-constant blend coloring, proving strong connectivity necessary.
5. **Directed cycle family** (§5): every blend coloring of the directed
   $n$-cycle ($n \ge 1$) is constant, an explicit infinite family of instances.
6. **Vector-valued generalization** (§6): the collapse holds coordinatewise for
   colors in $\mathbb{R}^\kappa$, and more broadly in strictly convex geometries.
7. **Quantitative and geometric outlook** (§7–§8).

---

## 2. Definitions

Throughout, $V$ is a finite nonempty set of **vertices**.

**Definition 2.1 (Weighted digraph).**
A *weighted digraph* on $V$ is a function $w : V \times V \to \mathbb{R}$ with
$w(i,j) \ge 0$ for all $i,j$. We interpret $w(i,j)$ as the weight of the arc
$i \to j$; the *out-neighbors* of $i$ are the vertices $j$ with $w(i,j) > 0$.

**Definition 2.2 (Row-stochastic).**
The weighting $w$ is *row-stochastic* if for every vertex $i$,
$$\sum_{j \in V} w(i,j) = 1.$$
Thus the outgoing weights at each vertex form a probability distribution, and any
weighted sum $\sum_j w(i,j)\, x_j$ is a convex combination of the $x_j$.

**Definition 2.3 (Arc relation).**
The *arc relation* $\mathrm{Arc}_w \subseteq V \times V$ is defined by
$$i \mathbin{\mathrm{Arc}_w} j \iff w(i,j) > 0.$$

**Definition 2.4 (Strong connectivity).**
$w$ is *strongly connected* if for every ordered pair $(i,j)$ of vertices there
is a directed walk of positive-weight arcs from $i$ to $j$; formally, $j$ is
reachable from $i$ under the reflexive–transitive closure of $\mathrm{Arc}_w$.
(Reflexive–transitive closure means: either $i = j$, or there is a finite chain
$i = v_0 \to v_1 \to \dots \to v_k = j$ with $w(v_t, v_{t+1}) > 0$ at each step.)

**Definition 2.5 (Blend coloring).**
A *coloring* is a function $c : V \to \mathbb{R}$. It satisfies the **blend
condition** (equivalently, it is a *blend coloring*, or is *harmonic* for $w$) if
$$c(i) = \sum_{j \in V} w(i,j)\, c(j) \qquad \text{for every } i \in V.$$

The blend condition rewrites usefully. Since $\sum_j w(i,j) = 1$,
$$c(i) = \sum_j w(i,j)\, c(j) \iff \sum_j w(i,j)\,\bigl(c(j) - c(i)\bigr) = 0.
\tag{$\ast$}$$
Writing $L = I - W$ for the graph Laplacian of the stochastic matrix
$W = (w(i,j))$, the blend condition is exactly $Lc = 0$: blend colorings are the
kernel of the Laplacian.

---

## 3. The Main Collapse Theorem

### 3.1 The local maximum principle

The entire argument rests on one lemma, an equality analysis of a convex
combination.

**Lemma 3.1 (Local maximum principle).**
Let $w$ be a row-stochastic weighting on the finite set $V$, and let $c$ be a
blend coloring. Let $m = \max_{k} c(k)$, so $c(k) \le m$ for all $k$. If a vertex
$i$ satisfies $c(i) = m$, then every out-neighbor $j$ of $i$ (i.e. every $j$ with
$w(i,j) > 0$) also satisfies $c(j) = m$.

*Proof.* From the blend condition at $i$ and $c(i) = m$,
$$m = \sum_j w(i,j)\, c(j).$$
Since $\sum_j w(i,j) = 1$, subtract $m = \sum_j w(i,j)\, m$ to obtain
$$0 = \sum_j w(i,j)\,\bigl(m - c(j)\bigr).$$
Each summand is a product of two nonnegative factors: $w(i,j) \ge 0$ and
$m - c(j) \ge 0$ (because $m$ is the maximum). A finite sum of nonnegative reals
is zero only if every summand is zero. Hence for each $j$ with $w(i,j) > 0$ we
must have $m - c(j) = 0$, i.e. $c(j) = m$. $\qquad\blacksquare$

This is the crux: **maximality is contagious along positive-weight arcs.** The
lemma uses only nonnegativity of weights, row-stochasticity, and the definition
of a maximum — nothing about symmetry, reversibility, or the structure of the
graph beyond a single vertex.

### 3.2 Global collapse

**Theorem 3.2 (Blend Collapse).**
Let $V$ be finite and let $w$ be a row-stochastic strongly connected weighting on
$V$. Then every blend coloring $c : V \to \mathbb{R}$ is constant:
$$c(i) = c(j) \qquad \text{for all } i, j \in V.$$

*Proof.* Because $V$ is finite and nonempty, $c$ attains its maximum
$m = \max_k c(k)$ at some vertex $v_\star$, so $c(v_\star) = m$ and $c(k) \le m$
for all $k$.

*Claim:* every vertex reachable from $v_\star$ has color $m$. We argue by
induction on the reflexive–transitive closure of $\mathrm{Arc}_w$. The base case
$v_\star$ itself has color $m$ by construction. For the inductive step, suppose
$u$ is reachable from $v_\star$ and $c(u) = m$, and let $u \to t$ be a
positive-weight arc ($w(u,t) > 0$). By Lemma 3.1 applied at $u$, we get
$c(t) = m$. Thus every vertex along any directed positive-weight walk from
$v_\star$ inherits color $m$.

By strong connectivity, *every* vertex $j \in V$ is reachable from $v_\star$, so
$c(j) = m$ for all $j$. In particular $c$ is constant. $\qquad\blacksquare$

### 3.3 Non-existence phrasing

**Corollary 3.3 (No non-constant blend coloring).**
Under the hypotheses of Theorem 3.2, there do not exist vertices $i, j$ with
$c(i) \ne c(j)$. Equivalently, a finite strongly connected row-stochastic
digraph admits no blend coloring taking two distinct values.

*Proof.* Immediate from Theorem 3.2: if $c(i) \ne c(j)$ for some pair, that
contradicts $c$ being constant. $\qquad\blacksquare$

### 3.4 Remarks

- **Kernel interpretation.** Theorem 3.2 states $\ker(I - W) = \mathbb{R}\cdot
  \mathbf{1}$, the constant vectors, whenever $W$ is stochastic and irreducible.
  This is the Perron–Frobenius eigenvalue $1$ having geometric multiplicity one
  for the right eigenvectors.
- **No symmetry or reversibility.** The proof never uses $w(i,j) = w(j,i)$ nor a
  detailed-balance condition. One-way weightings are fully covered.
- **Only the maximum is needed.** We used only that a maximum is extreme and that
  a convex combination cannot exceed it. This is what enables the geometric
  generalization of §6.

---

## 4. Sharpness: strong connectivity is necessary

The theorem fails without strong connectivity, and it fails in the smallest
possible instance.

**Proposition 4.1 (Sharpness).**
Let $V = \{0, 1\}$ and define $w(i,j) = 1$ if $i = j$ and $0$ otherwise (two
disjoint self-loops). Then:
1. $w$ is row-stochastic;
2. $w$ is *not* strongly connected;
3. the coloring $c(0) = 0,\ c(1) = 1$ is a non-constant blend coloring.

*Proof.* (1) Each row has a single entry equal to $1$. (2) There is no
positive-weight arc between $0$ and $1$ in either direction, so neither vertex is
reachable from the other. (3) The blend condition at $i$ reads
$c(i) = \sum_j w(i,j)\, c(j) = 1 \cdot c(i) = c(i)$, which holds for *every*
coloring $c$; in particular for $c(0) = 0 \ne 1 = c(1)$. $\qquad\blacksquare$

Thus strong connectivity is exactly the dividing line: it cannot be weakened to
mere (weak) connectivity or dropped. When it fails, the space of blend colorings
can be genuinely large (see §7, direction 3).

---

## 5. The directed cycle: an infinite family of instances

**Definition 5.1 (Directed $n$-cycle weighting).**
For $n \ge 1$, index vertices by $\mathbb{Z}/n\mathbb{Z} = \{0, 1, \dots, n-1\}$
and define
$$w_n(i, j) = \begin{cases} 1 & j \equiv i + 1 \pmod n, \\ 0 & \text{otherwise.}\end{cases}$$

**Lemma 5.2.** $w_n$ is row-stochastic: for each $i$, exactly one $j$ (namely
$i+1$) has weight $1$, so $\sum_j w_n(i,j) = 1$.

**Lemma 5.3 (Strong connectivity of the cycle).**
$w_n$ is strongly connected: for any $i$ and any $m \ge 0$, there is a
positive-weight walk of length $m$ from $i$ to $i + m \pmod n$; since every
vertex $j$ can be written $j = i + (j - i)$, every $j$ is reachable from every
$i$.

*Proof sketch.* Induct on $m$: the length-$0$ walk is trivial, and a length-$m$
walk from $i$ to $i+m$ extends to $i + (m+1)$ via the arc $i+m \to i+m+1$, which
has weight $w_n(i+m, i+m+1) = 1 > 0$. Taking $m = (j - i) \bmod n$ reaches any
target $j$. $\qquad\blacksquare$

**Theorem 5.4 (Cycle collapse).**
For every $n \ge 1$, every blend coloring of the directed $n$-cycle is constant.

*Proof.* By Lemmas 5.2 and 5.3, $w_n$ is row-stochastic and strongly connected,
so Theorem 3.2 applies. $\qquad\blacksquare$

Directly, the blend condition on the cycle reads $c(i) = c(i+1)$ for all $i$
(each vertex points to a unique successor with full weight); chaining around the
ring gives $c(0) = c(1) = \dots = c(n-1)$. This gives an explicit, verifiable
infinite family of strongly connected witnesses for the main theorem — not the
trivial one-vertex graph.

---

## 6. Vector-valued and geometric generalizations

**Theorem 6.1 (Vector-valued collapse).**
Let $w$ be a finite strongly connected row-stochastic weighting on $V$, let
$\kappa$ be an index set, and let $c : V \to \mathbb{R}^\kappa$ satisfy the blend
condition $c(i) = \sum_j w(i,j)\, c(j)$ (interpreted coordinatewise). Then $c$ is
constant.

*Proof.* Fix a coordinate $\alpha \in \kappa$ and apply Theorem 3.2 to the
real-valued coloring $c_\alpha(i) := c(i)_\alpha$, which satisfies the scalar
blend condition. Hence each coordinate is constant, so $c$ is constant.
$\qquad\blacksquare$

The coordinatewise reduction is available because averaging and the maximum
principle act independently in each coordinate. A genuinely vectorial argument,
not reducible to coordinates, underlies the following outlook.

**Geometric outlook (strictly convex targets).** The scalar proof used only that
(i) a maximum is an extreme value and (ii) a convex combination cannot exceed it.
This suggests the collapse holds whenever colors live in a *strictly convex*
geometry — a strictly convex normed space, or a nonpositively curved (CAT(0))
metric space with "weighted average" read as the barycenter — where extreme
points cannot be written as nontrivial convex combinations of other points. In
such geometries, extremality is contagious (the barycenter of points lying in a
supporting halfspace lies on the bounding hyperplane only if all the points do),
and strong connectivity spreads it. Convexity that is *not strict* can allow
non-constant blend colorings, mirroring the sharpness phenomenon of §4 in the
geometric setting.

---

## 7. Applications and interpretations

**Markov chains (discrete Liouville).** Reading $w(i,j)$ as the transition
probability from state $i$ to state $j$, the blend condition is
$c(i) = \mathbb{E}[c(X_1) \mid X_0 = i]$: $c$ is *harmonic* for the chain. Strong
connectivity is *irreducibility*. Theorem 3.2 is exactly the classical statement
that a finite irreducible Markov chain has only constant harmonic functions, here
proved by an elementary maximum principle rather than via the stationary
distribution.

**Consensus and gossip dynamics.** Consider the iteration
$c^{(t+1)}(i) = \sum_j w(i,j)\, c^{(t)}(j)$: every agent updates to the
weighted average of the agents it listens to. Blend colorings are exactly the
fixed points. Theorem 3.2 says the only fixed points on a strongly connected
network are consensus states, and (quantitatively, §8) the dynamics converge to
consensus. This underlies distributed averaging, opinion dynamics, and
load-balancing protocols.

**Electrical networks and potentials.** With no external sources, a network of
conductances settles to a potential that is the weighted average of its
neighbors; on a connected network the source-free potential is constant, an
instance of the same principle.

**Discrete harmonic analysis.** Blend colorings are the kernel of the random-walk
Laplacian $I - W$. The theorem computes this kernel for irreducible finite chains
and connects to Perron–Frobenius theory: the eigenvalue $1$ has a
one-dimensional right eigenspace spanned by $\mathbf{1}$.

---

## 8. Algorithms

We describe procedures to (a) test the hypotheses, (b) compute the blend colorings
(kernel of $I - W$), and (c) certify the collapse quantitatively.

**Algorithm A — Hypothesis verification.**
Given $w$: check nonnegativity $w(i,j) \ge 0$; check row sums
$\sum_j w(i,j) = 1$; and check strong connectivity by a reachability search
(e.g. Tarjan's strongly-connected-components algorithm on the support digraph
$\{(i,j) : w(i,j) > 0\}$, confirming a single component). Complexity
$O(|V|^2)$ for the arithmetic checks and $O(|V| + |E|)$ for connectivity.

**Algorithm B — Blend-coloring space (kernel computation).**
Form $L = I - W$ and compute $\ker L$ by Gaussian elimination. Theorem 3.2
guarantees, under the hypotheses, that $\ker L = \mathbb{R}\cdot\mathbf{1}$
(dimension $1$). Numerically confirming dimension $1$ certifies the collapse for
a given instance. Complexity $O(|V|^3)$.

**Algorithm C — Contraction (Dobrushin) certificate.**
Compute the Dobrushin ergodic coefficient of some power $W^r$,
$$\delta(W^r) = \tfrac12 \max_{i,i'} \sum_j \bigl| (W^r)_{ij} - (W^r)_{i'j}\bigr|
= 1 - \min_{i,i'} \sum_j \min\bigl((W^r)_{ij}, (W^r)_{i'j}\bigr).$$
If $\delta(W^r) < 1$, the averaging map contracts the *spread*
$\mathrm{osc}(c) = \max_i c(i) - \min_i c(i)$ by the factor $\delta(W^r)$ every
$r$ steps, giving geometric convergence to consensus and, as a corollary, the
constancy of fixed points. For an irreducible aperiodic chain some power is
strictly positive, so $\delta(W^r) < 1$ for suitable $r$.

---

## 9. Discussion

The Blend Collapse Theorem exposes the minimal hypotheses behind a family of
classical uniformity results. What is essential:

- **Row-stochasticity** turns the constraint into a convex combination, so that
  a maximum cannot be strictly exceeded by an average of dominated values.
- **Strong connectivity** turns the local maximum principle into a global one.
- **Finiteness** guarantees the maximum is attained; on infinite graphs one must
  add boundedness (and even then non-constant harmonic functions can exist, e.g.
  on $\mathbb{Z}^d$ transient walks, so genuine Liouville phenomena become
  delicate).

What is *inessential*: symmetry, reversibility, detailed balance, and even the
one-dimensionality of the color space. This robustness is what makes the result a
useful organizing principle rather than an isolated curiosity.

---

## 10. Future directions

*The following directions sharpen, weaken, or transport the strong-connectivity
dividing line.*

**1. The collapse has a speed, and the speed is spectral.** Repeatedly replacing
every vertex's color by the weighted average of its out-neighbors' colors drives
any initial coloring to the global average at a geometric rate, controlled by the
guaranteed outgoing-mass overlap between any two vertices. Strong connectivity
plus a uniform positive overlap between outgoing distributions upgrades the
one-step maximum principle ("spread cannot increase") to a strict contraction
("spread shrinks by a fixed proportion"); constancy of equilibria then follows
from a genuine contraction estimate via the Dobrushin coefficient.

**2. Strict convexity, not the real line, is what forces collapse.** The same
collapse should hold when colors live in any strictly convex geometry — a
strictly convex normed space, or a nonpositively curved metric space with
"weighted average" read as barycenter — and it can fail in geometries that are
convex but not strictly so. At an extreme point, the averaging equation holds only
if every positively weighted neighbor sits at that same extreme point; strict
convexity makes extremality contagious, and strong connectivity spreads it
everywhere.

**3. When connectivity breaks, the answer is counted by sinks.** Without strong
connectivity, the space of blend colorings is finite-dimensional with dimension
equal to the number of terminal strongly-connected components ("sinks") of the
digraph, with a natural basis given by absorption probabilities into those sinks.
Each closed, internally strongly connected cluster contributes exactly one
constant degree of freedom, while every remaining vertex is pinned by its
absorption probabilities into the sinks.

---

## References (classical background)

- Perron–Frobenius theory for nonnegative and stochastic matrices.
- Discrete maximum principle for harmonic functions on graphs.
- Harmonic functions of finite Markov chains and the discrete Liouville property.
- Dobrushin's ergodicity coefficient and contraction of stochastic matrices.
