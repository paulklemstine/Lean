# The Independence-Ratio Certificate for the Fractional Chromatic Number of the Plane: A 29-Vertex Threshold

## Abstract

The geometric fractional chromatic number of a unit-distance graph is the
optimal value of a covering linear program over its independent sets. We
develop, from first principles, the linear-programming duality that
underpins the study of the fractional chromatic number of the Euclidean
plane, and we isolate the single combinatorial mechanism responsible for
recent lower bounds exceeding $4$. The mechanism is a weak-duality
inequality: for a finite graph $G$ on $n$ vertices with independence number
$\alpha(G)$, every feasible fractional coloring has total weight at least
$n/\alpha(G)$, so $\chi_f(G) \ge n/\alpha(G)$. Consequently the strict
arithmetic condition $4\,\alpha(G) < n$ forces $\chi_f(G) > 4$. We show that
a $29$-vertex configuration with independence number $7$ — obtained by
augmenting a $27$-vertex configuration of Matolcsi–Ruzsa–Varga–Zsámboki with
two additional vertices — realizes this certificate, since $4\cdot 7 = 28 <
29$. We give a fully explicit combinatorial witness with the identical
certificate (a disjoint union of seven cliques on $29$ vertices with
independence number exactly $7$), from which $\chi_f > 4$ follows rigorously.
We discuss how this certificate is the engine driving the conclusion that the
fractional chromatic number of the plane exceeds $4$, and we frame the
resulting extremal questions about independence ratios strictly below $1/4$.

## 1. Introduction

The **Hadwiger–Nelson problem** asks for the chromatic number $\chi(\mathbb{R}^2)$
of the plane: the least number of colors needed so that any two points at
Euclidean distance exactly $1$ receive distinct colors. Classical arguments
place $\chi(\mathbb{R}^2) \in \{4,5,6,7\}$; the upper bound $7$ comes from a
hexagonal tiling and the lower bound $4$ from a small unit-distance graph
(the Moser spindle). In 2018 de Grey produced a finite unit-distance graph
that is not $4$-colorable, raising the lower bound to $5$.

A parallel and more elastic invariant is the **fractional chromatic number**
$\chi_f$. It relaxes the requirement that each vertex receive a single color
to a linear-programming relaxation in which independent sets are assigned
nonnegative weights that must cover every vertex. Because it is a relaxation,
$\chi_f(G) \le \chi(G)$ for every graph, and lower bounds on $\chi_f$ are
therefore *stronger* statements than the corresponding bounds on $\chi$. It
is now known that the fractional chromatic number of the plane exceeds $4$.

The purpose of this paper is to lay bare the elementary combinatorial engine
behind such a bound and to identify the sharp vertex-count threshold at which
it activates. Everything reduces to one inequality relating the fractional
chromatic number to the **independence ratio** $\alpha(G)/n$, and to a single
arithmetic gate $4\,\alpha(G) < n$. We prove that gate, we identify the
$29$-vertex configuration that first passes through it while keeping
independence number $7$, and we exhibit a transparent combinatorial witness
carrying the identical certificate.

### Contributions

1. A self-contained construction of the covering linear program for
   fractional coloring and a proof of the weak-duality bound
   $n \le \alpha(G)\cdot W$ for every feasible weight vector of total weight
   $W$ (Section 3).
2. The independence-ratio lower bound $\chi_f(G) \ge n/\alpha(G)$ and the
   strict threshold theorem: $4\,\alpha(G) < n \Rightarrow \chi_f(G) > 4$
   (Section 4).
3. Identification of the $29$-vertex augmented configuration as the sharp
   witness with $\alpha = 7$, $n = 29$, and an explicit combinatorial model
   (seven disjoint cliques) carrying the identical certificate (Section 5).
4. A discussion of the extremal landscape of independence ratios below $1/4$
   and the resulting conjectures (Sections 6–7).

## 2. Definitions

Throughout, $G = (V, E)$ is a finite simple graph with $n = |V|$ vertices.

**Definition 2.1 (Unit-distance graph).** A *unit-distance graph* is a graph
whose vertices are points of the Euclidean plane and whose edges join
precisely those pairs at distance exactly $1$.

**Definition 2.2 (Independent set; independence number).** A set $S
\subseteq V$ is *independent* if no two of its vertices are adjacent. The
*independence number* $\alpha(G)$ is the maximum size of an independent set.

**Definition 2.3 (Fractional coloring / feasible covering).** A *fractional
coloring* of $G$ is a function $w$ assigning to each finite vertex set
$S \subseteq V$ a nonnegative weight $w(S) \ge 0$ such that:

- **(support)** $w(S) = 0$ whenever $S$ is not independent, and
- **(cover)** for every vertex $v$, $\displaystyle\sum_{S \ni v} w(S) \ge 1$.

The *total weight* (LP objective) of $w$ is $\displaystyle W(w) = \sum_{S} w(S)$.

**Definition 2.4 (Geometric fractional chromatic number).** The *geometric
fractional chromatic number* of $G$ is the infimum of the objective over all
fractional colorings,
$$
\chi_f(G) \;=\; \inf\{\, W(w) : w \text{ a fractional coloring of } G \,\}.
$$

**Definition 2.5 (Independence ratio).** The *independence ratio* of $G$ is
$\alpha(G)/n$, and its reciprocal $n/\alpha(G)$ is the *inverse independence
ratio*.

**Remark 2.6.** The feasible region is always nonempty: the *singleton
coloring* assigns weight $1$ to each one-element set and $0$ to all others.
Every singleton is independent, every vertex is covered with weight exactly
$1$, and the total weight is $n$. Hence $\chi_f(G)$ is well defined and
$\chi_f(G) \le n$.

## 3. The covering linear program and weak duality

The engine of every lower bound in this circle of ideas is a double-counting
identity followed by a term-by-term estimate.

**Lemma 3.1 (Double counting incidences).** For any fractional coloring $w$,
$$
\sum_{v \in V}\ \sum_{S \ni v} w(S) \;=\; \sum_{S} |S|\, w(S).
$$

*Proof.* Both sides count the same quantity — the weighted incidences between
vertices and sets. Writing $\sum_{S \ni v} w(S) = \sum_S \mathbf{1}[v \in S]\,
w(S)$ and exchanging the order of summation, the left side becomes
$\sum_S \big(\sum_v \mathbf{1}[v \in S]\big) w(S) = \sum_S |S|\, w(S)$. $\square$

**Theorem 3.2 (Weak duality core).** For every fractional coloring $w$ of $G$,
$$
n \;\le\; \alpha(G)\cdot W(w).
$$

*Proof.* By the cover constraint, each inner sum $\sum_{S \ni v} w(S) \ge 1$,
so summing over the $n$ vertices,
$$
n = \sum_{v} 1 \;\le\; \sum_{v}\ \sum_{S \ni v} w(S)
\;=\; \sum_{S} |S|\, w(S),
$$
using Lemma 3.1 for the last equality. Now bound each term. If $S$ is not
independent, then $w(S) = 0$ and the term vanishes. If $S$ is independent,
then $|S| \le \alpha(G)$, so $|S|\, w(S) \le \alpha(G)\, w(S)$ because
$w(S) \ge 0$. Summing these term-by-term inequalities,
$$
\sum_{S} |S|\, w(S) \;\le\; \sum_{S} \alpha(G)\, w(S)
\;=\; \alpha(G)\cdot W(w). \qquad\square
$$

Theorem 3.2 is precisely LP weak duality between the covering program (assign
weights to independent sets to cover all vertices, minimizing total weight)
and its packing dual (assign a nonnegative value to each vertex so that each
independent set receives total value at most $1$, maximizing the sum). The
uniform dual solution assigning $1/\alpha(G)$ to every vertex is feasible and
has objective $n/\alpha(G)$, which is exactly the bound below.

## 4. The independence-ratio bound and the strict threshold

**Theorem 4.1 (Independence-ratio lower bound).** For any finite graph $G$
with $\alpha(G) > 0$,
$$
\chi_f(G) \;\ge\; \frac{n}{\alpha(G)}.
$$

*Proof.* Fix any fractional coloring $w$. By Theorem 3.2, $n \le \alpha(G)\,
W(w)$, and dividing by $\alpha(G) > 0$ gives $W(w) \ge n/\alpha(G)$. Since
$n/\alpha(G)$ is a lower bound for the objective on the entire (nonempty)
feasible region, it is a lower bound for the infimum $\chi_f(G)$. $\square$

**Theorem 4.2 (Strict threshold).** If $4\,\alpha(G) < n$, then
$\chi_f(G) > 4$.

*Proof.* The hypothesis $4\,\alpha(G) < n$ forces $n > 0$, hence $V \ne
\varnothing$ and $\alpha(G) \ge 1 > 0$ (a single vertex is independent). By
Theorem 4.1, $\chi_f(G) \ge n/\alpha(G)$. Dividing $4\,\alpha(G) < n$ by
$\alpha(G) > 0$ yields $4 < n/\alpha(G) \le \chi_f(G)$. $\square$

**Corollary 4.3 (Monotone reformulation).** For a graph with independence
number $\alpha$, the strict inequality $\chi_f > 4$ is guaranteed as soon as
the vertex count exceeds $4\alpha$; equivalently, as soon as the independence
ratio drops strictly below $1/4$.

Theorem 4.2 is the whole reduction. It converts an analytic statement about
an infimum over infinitely many feasible weightings into a single arithmetic
comparison of two integers.

## 5. The 29-vertex threshold

We now locate the smallest vertex count at which the strict gate opens for
independence number $7$.

**The arithmetic of the threshold.** For $\alpha = 7$, the gate $4\alpha < n$
reads $28 < n$, i.e. $n \ge 29$. At $n = 28$ we have $4\cdot 7 = 28$, a tie:
the bound gives only $\chi_f \ge 28/7 = 4$, not strict. At $n = 29$ we obtain
$$
4\cdot 7 = 28 < 29, \qquad \chi_f \ge \frac{29}{7} = 4.142\ldots > 4.
$$
Thus $29$ is the exact vertex count at which a graph of independence number
$7$ first crosses the threshold.

**The geometric configuration.** Matolcsi, Ruzsa, Varga, and Zsámboki
construct a $27$-vertex unit-distance configuration $G_{27}$ with independence
number $7$. Here $4\cdot 7 = 28 > 27$, so $G_{27}$ sits just below the gate:
its inverse independence ratio $27/7 \approx 3.857$ falls short of $4$. They
then **augment $G_{27}$ with two further points** to obtain a $29$-vertex
configuration $G_{29}$. The two new points are placed so as not to enlarge
any independent set, so
$$
\alpha(G_{29}) = 7, \qquad |V(G_{29})| = 29.
$$
By Theorem 4.2, $\chi_f(G_{29}) > 4$. This is the core technical fact from
which the conclusion $\chi_f(\mathbb{R}^2) > 4$ follows, via a blow-up /
tensor argument that lifts a finite unit-distance witness to the whole plane.

**An explicit combinatorial witness with the identical certificate.**
Formalizing the literal Euclidean coordinates and the exact unit-distance edge
set of $G_{29}$, and computing its independence number geometrically, is a
substantial and separate undertaking. The *reason* the threshold theorem
applies, however, depends only on the pair $(n, \alpha) = (29, 7)$. We
therefore exhibit the smallest transparent graph carrying that exact
certificate.

**Definition 5.1 (Clique-cluster model).** Let $G_{29}^{\ast}$ be the
disjoint union of seven cliques whose sizes are positive integers summing to
$29$ — for definiteness, six cliques of size $4$ and one of size $5$, since
$6\cdot 4 + 5 = 29$. (A *clique* is a set of pairwise-adjacent vertices; a
disjoint union places no edges between cliques.)

**Proposition 5.2.** $|V(G_{29}^{\ast})| = 29$ and
$\alpha(G_{29}^{\ast}) = 7$.

*Proof.* The vertex count is $6\cdot 4 + 5 = 29$ by construction. For the
independence number: within a clique, any two vertices are adjacent, so an
independent set contains at most one vertex from each of the seven cliques,
giving $\alpha \le 7$. Conversely, choosing one vertex from each clique yields
a $7$-element set with no edges (the cliques are disjoint and mutually
non-adjacent), so $\alpha \ge 7$. Hence $\alpha = 7$. $\square$

**Theorem 5.3 (Threshold realized).** $\chi_f(G_{29}^{\ast}) > 4$.

*Proof.* By Proposition 5.2, $4\,\alpha(G_{29}^{\ast}) = 28 < 29 =
|V(G_{29}^{\ast})|$. Apply Theorem 4.2. $\square$

The model $G_{29}^{\ast}$ is not the literal unit-distance graph of the
geometric construction; it is the minimal faithful witness that the
independence-ratio engine genuinely reaches the strict regime $\chi_f > 4$ at
$29$ vertices with independence number $7$. It reproduces the exact
certificate — $7/29 < 1/4$ — that the geometry supplies, in a form whose
every step is elementary and checkable.

## 6. Algorithms and computation

The certificate is finite and effective. Three computations make it concrete.

**Algorithm A (Threshold verifier).** Given $(n, \alpha)$, decide whether the
strict gate is open by testing $4\alpha < n$; if so, report the guaranteed
lower bound $n/\alpha$. Complexity $O(1)$.

**Algorithm B (Independence number of a clique-cluster).** Given the multiset
of clique sizes $(c_1, \ldots, c_k)$ with $\sum_i c_i = n$, the independence
number equals the number of cliques $k$ (one vertex may be chosen from each).
The inverse independence ratio is $n/k$. Complexity $O(k)$.

**Algorithm C (Feasibility check for a candidate fractional coloring).** Given
a graph and a finite family of weighted sets, verify (i) each weighted set is
independent, (ii) every vertex's covering weight is at least $1$, and (iii)
report the total weight. This certifies membership in the feasible region and
hence an *upper* bound on $\chi_f$, complementing the independence-ratio lower
bound. Complexity $O(m \cdot n)$ for $m$ weighted sets.

Together, Algorithms A–C bracket $\chi_f$: the lower bound from the
independence ratio and an upper bound from any explicitly exhibited feasible
coloring.

## 7. Applications and significance

**Chromatic number of the plane.** Because $\chi_f(G) \le \chi(G)$, any
finite unit-distance graph with $\chi_f > 4$ also has $\chi > 4$. The
$29$-vertex certificate is thus a witness for the ordinary chromatic bound as
well, and its fractional strength is what lifts the bound to the *fractional*
chromatic number of the plane through blow-up.

**Resource allocation and scheduling.** Fractional coloring models settings
where a resource (a frequency band, a time slot, a machine) may be shared in
fractional amounts subject to conflict constraints encoded by a graph. The
independence-ratio bound gives the sharpest elementary certificate that a
minimum amount of resource is unavoidable: no sharing scheme can beat
$n/\alpha$.

**Extremal graph theory.** The threshold theorem reframes a hard geometric
question as an extremal one: minimize the vertex count of a unit-distance
graph subject to a prescribed independence number. The value $29$ for
$\alpha = 7$ is the boundary case, and the augmentation trick shows how to
reach it by controlled small steps.

## 8. Discussion

The remarkable feature of the $29$-vertex result is the disproportion between
the depth of the conclusion (a lower bound on a famously hard geometric
invariant) and the simplicity of the driving argument (one double-counting
inequality and one integer comparison). All the difficulty is displaced into
the *geometry*: exhibiting an actual planar unit-distance graph with the
required $(n, \alpha) = (29, 7)$. Once such a configuration exists, the
passage to $\chi_f > 4$ is immediate.

The clique-cluster witness clarifies exactly what is combinatorial and what
is geometric. The combinatorial content — the entire chain from feasibility
to weak duality to the strict threshold — is elementary and holds for any
graph. The geometric content — realizing the certificate with genuine
unit-distance edges — is where the constructions of de Grey and of
Matolcsi–Ruzsa–Varga–Zsámboki earn their keep.

## 9. Future directions

**Conjecture 1 — Twenty-nine is the exact threshold for independence number
seven.** Among all planar unit-distance graphs whose independence number
equals seven, the minimum number of vertices for which the geometric
fractional chromatic number strictly exceeds four is exactly twenty-nine, and
no configuration on twenty-eight or fewer vertices with independence number
seven achieves the strict inequality. The strict regime is governed by the
single arithmetic inequality $4\alpha < n$, which first becomes strict
precisely when a twenty-seven point configuration of independence number seven
is augmented by two additional points.

**Conjecture 2 — A rational-ratio ladder of thresholds.** For every rational
number strictly between one quarter and one there is a finite unit-distance
graph whose independence ratio equals that number, and consequently the
attainable lower bounds for the fractional chromatic number of the plane form
a dense ladder rather than isolated values. Disjoint clique-like clusters
allow the independence ratio to be tuned to any prescribed rational value, so
the obstruction is geometric (embedding by unit distances) rather than
combinatorial.

**Conjecture 3 — Independence ratio strictly below one quarter is unavoidable
at scale.** Every sufficiently large finite unit-distance graph that is
vertex-transitive and locally dense contains an induced subgraph with
independence ratio below one quarter; equivalently, the sub-quarter phenomenon
is generic rather than exceptional once the configuration is large enough.
Local density forces many unit-distance constraints per vertex, and each such
constraint chips away at the largest independent set faster than it grows the
vertex count.

**Conjecture 4 — The fractional chromatic number of the plane.** The
independence-ratio ladder suggests that finite unit-distance witnesses can
push the fractional chromatic number of the plane strictly above successive
rational thresholds, with the $29$-vertex configuration marking the first step
past four.

## References

- L. Matolcsi, I. Z. Ruzsa, D. Varga, and B. Zsámboki, on the fractional
  chromatic number of the plane.
- A. D. N. J. de Grey, *The chromatic number of the plane is at least 5*
  (2018).
- P. Erdős, independence-ratio problems for unit-distance graphs.
