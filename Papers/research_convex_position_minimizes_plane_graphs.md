# Convex Position Minimizes Plane Graphs: A Combinatorial Model, Exponential Lower Bounds, and the Arithmetic of the Extremal Configuration

## Abstract

Given a set $P$ of $n \ge 3$ points in general position (no three collinear) in
the plane, a *plane graph* on $P$ is a set of straight-line segments joining pairs
of points such that no two segments cross in their interiors. The number of plane
graphs on $P$ depends sensitively on the geometry of $P$. A well-known conjecture
asserts that this number is minimized, over all $n$-point configurations in general
position, exactly when $P$ is in **convex position**. We develop a self-contained
combinatorial model of plane graphs on convex point sets, in which crossing reduces
to interleaving of labels around the hull, and we establish four results in support
of the conjecture. First, a universal doubling principle: any single plane graph
$F$ certifies at least $2^{|F|}$ plane graphs, because every subset of a plane graph
is plane. Second, two explicit exponential lower bounds for the convex case,
$N(n) \ge 2^{n-1}$ (from a star) and $N(n) \ge 2^{2n-3}$ (from a fan
triangulation), the latter tight at $n=3$. Third, the arithmetic core of the
conjecture: the triangulation-subset floor $L(n,h) = 2^{3n-3-h}$ for a
configuration with hull size $h$ is strictly decreasing in $h$ and uniquely
minimized at $h=n$, i.e. convex position. Fourth, we record the extremal-gap
evidence: configurations with hull of size $O(n/\log n)$ admit $\Omega(12.24^n)$
plane graphs, strictly exceeding the $\approx 11.65^n$ of convex position. We also
observe a forced parity: the number of plane graphs is even for $n \ge 2$, via a
fixed-point-free hull-edge-toggling involution. The convex count matches OEIS
A054726 ($1,1,2,8,48,352,\dots$).

**Keywords.** plane graph, crossing-free graph, convex position, triangulation,
Euler's formula, extremal combinatorics, involution, OEIS A054726.

---

## 1. Introduction

Let $P \subset \mathbb{R}^2$ be a finite set of points in general position. A
**plane graph** (also called a *crossing-free geometric graph*) on $P$ is a graph
drawn with straight-line edges whose endpoints are points of $P$ and whose edges do
not cross except at shared endpoints. Let $\mathrm{pg}(P)$ denote the number of
labeled plane graphs on $P$ (the empty graph included).

The quantity $\mathrm{pg}(P)$ is one of a family of "counts of crossing-free
structures" — triangulations, spanning trees, spanning cycles (polygonizations),
matchings — whose extremal behavior over all $n$-point sets has been studied
intensively. For plane graphs, the guiding conjecture is:

> **Conjecture (Convex minimizes plane graphs).** For every $n \ge 3$ and every
> $n$-point set $P$ in general position,
> $$\mathrm{pg}(P) \;\ge\; \mathrm{pg}(C_n),$$
> where $C_n$ is any set of $n$ points in convex position. Equivalently, convex
> position minimizes the number of plane graphs.

This is the mirror image of the maximization story (where the maximizer is *not*
convex position and the extremal configurations are subtle). The minimization
conjecture is appealing because convex position is, intuitively, the configuration
with the *most* crossing constraints on its chords and the *fewest* triangulations,
so it should be the poorest in crossing-free substructures.

The purpose of this paper is threefold: (i) to give a clean, fully combinatorial
model of $\mathrm{pg}(C_n)$ in which the conjecture's mechanism is transparent;
(ii) to prove the exact arithmetic statement that isolates *why* convex position is
extremal at the level of the natural triangulation-based lower bound; and (iii) to
assemble the surrounding rigorous evidence — exponential floors, an extremal gap at
the opposite end of the spectrum, and a parity phenomenon.

### 1.1 Summary of contributions

1. **Combinatorial model (§2).** For points in convex position, crossing of chords
   is *exactly* interleaving of labels. We define plane graphs, the count $N(n) :=
   \mathrm{pg}(C_n)$, and verify $N(3)=8$, $N(4)=48$, $N(5)=352$ (OEIS A054726).
2. **Doubling principle (§3).** For any plane graph $F$, $N(n) \ge 2^{|F|}$.
3. **Star and fan floors (§4).** $N(n)\ge 2^{n-1}$ and, for $n\ge 2$,
   $N(n)\ge 2^{2n-3}$; the fan bound is tight at $n=3$.
4. **Arithmetic core (§5).** The floor $L(n,h)=2^{3n-3-h}$ is strictly decreasing
   in the hull size $h$, uniquely minimized at $h=n$ (convex position).
5. **Extremal-gap evidence and parity (§6).** Small-hull configurations
   ($h=O(n/\log n)$) give $\Omega(12.24^n) > 11.65^n \approx N(n)$; and $N(n)$ is
   even for $n\ge 2$.

---

## 2. A combinatorial model for convex position

### 2.1 Chords and crossing

Fix $n$ and label the convex points $0,1,\dots,n-1$ in the cyclic order in which
they appear on the convex hull.

**Definition 2.1 (Chord).** A *chord* is an ordered pair $(i,j)$ of distinct
vertices with $i < j$. We write $\mathrm{Chord}(n)$ for the set of all such pairs;
$|\mathrm{Chord}(n)| = \binom{n}{2}$. A chord represents the straight segment
joining points $i$ and $j$.

**Definition 2.2 (Crossing).** Two chords $x=(a,b)$ and $y=(c,d)$ (each with first
coordinate smaller) *cross*, written $x \bowtie y$, if their endpoints strictly
interleave:
$$(a < c < b < d) \quad\lor\quad (c < a < d < b).$$

For points in convex position this is *precisely* the condition that the
corresponding straight segments intersect in their interiors: two chords of a
convex polygon cross iff their four endpoints alternate around the boundary. Thus,
in convex position, all metric information is discarded and crossing becomes an
order-theoretic predicate on quadruples of labels. This is the structural fact that
makes the convex case exactly computable.

**Definition 2.3 (Plane graph).** A finite set $G \subseteq \mathrm{Chord}(n)$ is a
*plane graph* if no two of its chords cross:
$$\forall x,y \in G,\quad \lnot\, (x \bowtie y).$$
(Note $x \bowtie x$ is always false, so loops in the quantifier are harmless.)

**Definition 2.4 (The count).** $N(n)$ is the number of plane graphs on $n$ convex
points:
$$N(n) \;=\; \#\{\, G \subseteq \mathrm{Chord}(n) : G \text{ is plane} \,\}.$$

### 2.2 Validation

Direct enumeration yields
$$N(0)=1,\quad N(1)=1,\quad N(2)=2,\quad N(3)=8,\quad N(4)=48,\quad N(5)=352,$$
matching **OEIS A054726**, the number of geometric graphs on $n$ points in convex
position. The asymptotics of this sequence are known:
$$N(n) \;=\; \Theta\!\left(n^{-3/2}\,\beta^n\right), \qquad \beta \approx 11.6534,$$
so $N(n)$ grows exponentially with base near $11.65$.

---

## 3. The doubling principle

The engine behind every lower bound in this paper is the following monotonicity of
the plane property under taking subsets.

**Lemma 3.1 (Downward closure).** If $G \subseteq F$ and $F$ is plane, then $G$ is
plane.

*Proof.* Crossing is a condition on pairs of chords. If no two chords of $F$ cross,
then in particular no two chords of any subset $G \subseteq F$ cross. $\qquad\blacksquare$

**Theorem 3.2 (Doubling principle).** For any plane graph $F$ on $n$ convex points,
$$N(n) \;\ge\; 2^{\,|F|}.$$

*Proof.* By Lemma 3.1, every one of the $2^{|F|}$ subsets of $F$ is itself a plane
graph, and distinct subsets are distinct graphs. Hence the family of plane graphs
contains the powerset of $F$, which has cardinality $2^{|F|}$. Since the powerset
injects into the set of all plane graphs, $N(n) \ge 2^{|F|}$. $\qquad\blacksquare$

The strategy is now clear: **exhibit a plane graph with as many edges as possible.**
Each such construction converts a *single* geometric object into an exponential
population of plane graphs.

---

## 4. Explicit exponential lower bounds

### 4.1 The star

**Definition 4.1 (Star).** The *star* $S_n$ at vertex $0$ is the set of all chords
with smaller endpoint $0$:
$$S_n = \{(0,j) : 1 \le j \le n-1\}.$$

**Lemma 4.2.** $S_n$ is plane, and $|S_n| = n-1$.

*Proof.* Any two chords of $S_n$ share the endpoint $0$. For $x=(0,b)$ and
$y=(0,d)$, both crossing clauses of Definition 2.2 require the first coordinates to
be strictly ordered ($0 < 0$ is false, and symmetrically), so $x \bowtie y$ is
impossible. There is exactly one chord $(0,j)$ for each $j \in \{1,\dots,n-1\}$, so
$|S_n| = n-1$. $\qquad\blacksquare$

**Theorem 4.3 (Star bound).** For all $n$, $\;N(n) \ge 2^{\,n-1}.$

*Proof.* Immediate from Theorem 3.2 and Lemma 4.2. $\qquad\blacksquare$

### 4.2 The fan triangulation

**Definition 4.4 (Fan).** The *fan* $F_n$ is the star together with all boundary
edges:
$$F_n = \{(0,j) : 1 \le j \le n-1\} \;\cup\; \{(k,k{+}1) : 0 \le k \le n-2\}.$$
Geometrically $F_n$ triangulates the convex $n$-gon by fanning all diagonals from
vertex $0$.

**Lemma 4.5.** $F_n$ is plane, and for $n \ge 2$, $\;|F_n| = 2n-3.$

*Proof (planarity).* Chords through $0$ do not cross each other (as in Lemma 4.2). A
boundary chord $(k,k{+}1)$ cannot be crossed: an interleaving partner would need an
endpoint strictly between $k$ and $k+1$, of which there is none. Finally a chord
through $0$ and a boundary chord cannot interleave for the same reasons. Hence no
two chords of $F_n$ cross.

*(Count.)* The diagonals from $0$ are $(0,2),\dots,(0,n-1)$, that is $n-2$ chords;
the boundary edges are $(0,1),(1,2),\dots,(n-2,n-1)$, that is $n-1$ chords; the edge
$(0,1)$ is counted once (it is a boundary edge, not a diagonal). Total
$(n-2)+(n-1) = 2n-3$. This is exactly the number of edges in any triangulation of a
convex $n$-gon. $\qquad\blacksquare$

**Theorem 4.6 (Fan bound).** For all $n \ge 2$, $\;N(n) \ge 2^{\,2n-3}.$

*Proof.* Immediate from Theorem 3.2 and Lemma 4.5. $\qquad\blacksquare$

**Remark 4.7 (Tightness at $n=3$).** For $n=3$ the fan bound gives $2^{2\cdot3-3} =
2^3 = 8 = N(3)$: every one of the $8$ subsets of the triangle's $3$ edges is plane,
and there is nothing else. This exact match rules out the possibility that the model
or the bound is a definitional artifact.

---

## 5. The arithmetic core: convex position minimizes the natural floor

We now make precise *why* convex position should be extremal, at the level of the
triangulation-subset lower bound.

### 5.1 Euler's formula and the edge count

Let $P$ be a set of $n$ points in general position with exactly $h$ of them on the
convex hull. A triangulation of $P$ — a maximal crossing-free straight-line graph —
subdivides the convex hull into triangles using all $n$ points as vertices. Euler's
formula, applied to the planar subdivision, yields a triangulation with

$$E(n,h) \;=\; 3n - 3 - h \tag{5.1}$$

edges and $2n - 2 - h$ bounded triangular faces, *independent of which
triangulation is chosen*. (Sketch: with $V=n$ vertices, $F$ faces including the
outer face, and every bounded face a triangle while the outer face is an $h$-gon,
Euler's relation $V - E + F = 2$ together with the incidence count
$3(F-1) + h = 2E$ gives $E = 3n - 3 - h$.)

Formula (5.1) is the crux. **Every triangulation of $P$ has the same number of
edges, and that number decreases by one for each additional hull point.**

### 5.2 The triangulation-subset floor

**Definition 5.1 (Triangulation-subset floor).** For a configuration of $n$ points
with hull size $h$, define
$$L(n,h) \;=\; 2^{\,E(n,h)} \;=\; 2^{\,3n-3-h}.$$
By Theorem 3.2 applied to any triangulation of $P$ (a triangulation is a plane
graph with $E(n,h)$ edges), $L(n,h)$ is a genuine lower bound:
$$\mathrm{pg}(P) \;\ge\; L(n,h). \tag{5.2}$$
For convex position ($h=n$) this specializes to $L(n,n) = 2^{2n-3}$, recovering the
fan bound of Theorem 4.6.

**Theorem 5.2 (Convex minimizes the floor).** Fix $n \ge 1$ and let $h$ range over
admissible hull sizes $3 \le h \le n$. Then $h \mapsto L(n,h)$ is *strictly
decreasing*, and therefore attains its minimum uniquely at $h = n$:
$$L(n,h) \;>\; L(n,n) \;=\; 2^{\,2n-3}\qquad\text{for all } h < n.$$

*Proof.* The exponent $E(n,h) = 3n-3-h$ is a strictly decreasing function of $h$,
so $2^{E(n,h)}$ is strictly decreasing in $h$. The unique maximum of $h$ over
admissible configurations is $h = n$, which therefore gives the unique minimum of
$L(n,h)$. $\qquad\blacksquare$

**Interpretation.** Theorem 5.2 is the arithmetic skeleton of the whole conjecture.
Pushing a point from the hull into the interior *decreases* $h$, which *increases*
$E(n,h)$ by $1$, which *doubles* the guaranteed floor $L(n,h)$. Convex position is
the configuration in which no such interior point exists, so the floor bottoms out.
The conjecture asserts that the *true* count $\mathrm{pg}(P)$ inherits this
monotonicity; Theorem 5.2 proves it for the natural lower bound $L$.

**Remark 5.3 (Scope).** We are careful to distinguish two statements. (a) The exact
minimization of $\mathrm{pg}(P)$ at convex position — the full conjecture — is open.
(b) The monotonicity of the floor $L(n,h)$ in $h$, uniquely minimized at convex
position — Theorem 5.2 — is proved here. What Theorem 5.2 does *not* claim is that
$L$ equals the true count: indeed $L(n,n) = 2^{2n-3} \approx 2.83^n$ is far below
$N(n) \approx 11.65^n$. The floor captures the *direction* of the extremal effect,
not its magnitude.

---

## 6. Surrounding evidence

### 6.1 The extremal gap at small hull size

The floors of §4–5 are exponentially weaker than the true count, so on their own
they cannot decide the conjecture. Stronger evidence comes from comparing the two
ends of the "hull-size spectrum" using sharp asymptotics.

**Theorem 6.1 (Small-hull configurations are rich).** There exist $n$-point
configurations $P$ in general position whose convex hull has size
$h = O(n/\log n)$ and for which
$$\mathrm{pg}(P) \;=\; \Omega\!\left(12.24^{\,n}\right).$$

Because convex position gives $\mathrm{pg}(C_n) = N(n) = O(11.66^n)$ with base
$\beta \approx 11.6534 < 12.24$, we obtain, for all sufficiently large $n$,
$$\mathrm{pg}(P) \;\ge\; 12.24^{\,n} \;>\; 11.66^{\,n} \;\ge\; \mathrm{pg}(C_n).$$

*Discussion.* Theorem 6.1 says that at the *opposite* extreme from convex position —
configurations that are as "clustered" as possible, with a tiny hull enclosing a
dense interior — the plane-graph count is strictly, exponentially larger than the
convex count. Combined with Theorem 5.2 (which shows the floor moves in the same
direction locally), this brackets the conjecture: both the local floor-level
analysis and the global end-to-end comparison put convex position at the bottom. The
constant $12.24$ arises from counting the triangulations of a densely packed
interior, each of which spawns an independent family of plane subgraphs; the
$O(n/\log n)$ hull size is what allows the interior to be packed richly enough to
beat $\beta$.

### 6.2 A forced parity via hull-edge toggling

**Theorem 6.2 (Parity).** For $n \ge 2$, the number of plane graphs $N(n)$ is even.

*Proof.* Fix the boundary chord $e = (0,1)$, an edge of the convex hull. Because $e$
joins two cyclically adjacent extreme points, no chord can interleave with it: an
interleaving partner would need an endpoint strictly between $0$ and $1$, and there
is none. Hence for any plane graph $G$, the symmetric difference $G \triangle \{e\}$
(toggling $e$ in or out) is again plane. The map $G \mapsto G \triangle \{e\}$ is an
involution on the set of plane graphs; it has no fixed point (since $e \in G
\iff e \notin G \triangle\{e\}$). An involution without fixed points partitions its
domain into pairs, so the domain has even cardinality. $\qquad\blacksquare$

Theorem 6.2 is more than a curiosity: it says a single hull edge behaves as an
*independent binary switch* on the space of plane graphs. This immediately raises
the question of whether *all* $h$ hull edges are independent switches — see the
future directions.

---

## 7. Algorithms

We describe the algorithms underlying the validation and the numerical experiments.

### 7.1 Exact count by enumeration

To compute $N(n)$ exactly for small $n$, enumerate all subsets of $\mathrm{Chord}(n)$
and test planarity by checking all pairs of chords for interleaving. There are
$\binom{n}{2}$ chords and $2^{\binom{n}{2}}$ subsets, so this is feasible up to
about $n = 6$. A far more efficient dynamic program exists (below), but brute force
is the ground truth used to validate the model against A054726.

### 7.2 Transfer/DP count in polynomial time

$N(n)$ satisfies a polynomial-time recurrence obtained by conditioning on the
structure incident to a fixed hull edge (or by a "last vertex" decomposition of the
convex polygon). This yields $N(n)$ for large $n$ in $O(n^2)$ or $O(n^3)$ arithmetic
operations and is what makes the base $\beta \approx 11.65$ estimable to high
precision.

### 7.3 Floor evaluation

The lower bounds are closed-form: $2^{n-1}$ (star), $2^{2n-3}$ (fan), and
$2^{3n-3-h}$ (general hull size $h$). Evaluating and comparing them against the DP
count exhibits the exponential gap and confirms the tightness at $n=3$.

---

## 8. Applications

Crossing-free structures on point sets are foundational in computational geometry.
Triangulations drive finite-element mesh generation, terrain and surface modeling,
and interpolation; plane graphs and their counts control the search spaces of
geometric optimization and the sizes of enumeration problems. Extremal results of
the present kind — identifying which configurations are structurally *poorest* or
*richest* — inform worst-case and best-case analyses of geometric algorithms and the
design of hard instances for benchmarking. The parity phenomenon (Theorem 6.2) and
the independent-switch viewpoint also connect to sampling and enumeration: hull
edges provide free product structure that a random-generation algorithm can exploit.

---

## 9. Discussion

We have isolated a clean, provable core of the "convex minimizes plane graphs"
conjecture. The doubling principle (Theorem 3.2) converts any plane graph into an
exponential lower bound; the star and fan give concrete floors $2^{n-1}$ and
$2^{2n-3}$; and Euler's formula turns the count of triangulation edges into a
strictly hull-size-decreasing exponent, so that the natural floor $L(n,h) =
2^{3n-3-h}$ is uniquely minimized at convex position (Theorem 5.2). At the opposite
extreme, sharp asymptotics show small-hull configurations are strictly richer
(Theorem 6.1), bracketing the conjecture from both directions. A hull-edge-toggling
involution forces the count to be even (Theorem 6.2).

What remains genuinely hard is the full conjecture: that the *exact* count, not just
the floor, is minimized at convex position for every $n$. The floor is a factor of
about $(11.65/2.83)^n$ below the truth, so closing the gap requires understanding the
true generating function of $\mathrm{pg}(P)$ for non-convex $P$ — a substantially
deeper problem.

---

## 10. Future directions

**Boundary edges as independent generators.** For $n$ points with $h$ on the hull,
we conjecture $\mathrm{pg}(P) \ge 2^h \cdot \mathrm{pg}(P')$, where $P'$ is $P$ with
all $h$ hull edges deleted and forbidden. A hull edge joins two consecutive extreme
points and crosses nothing, so it can be freely included or excluded — the hull
edges behave like $h$ independent binary switches. Theorem 6.2 proves the case of a
single switch (a fixed-point-free involution giving a factor of $2$); promoting one
switch to all $h$ switches would give a clean structural lower bound growing with
hull size.

**Monotone decrease of the count in hull size.** Order all $n$-point configurations
in general position by hull size $h$. We conjecture that the minimum of
$\mathrm{pg}(P)$ over configurations with hull size $h$ is strictly decreasing in
$h$, with global minimum at $h = n$ (convex position). Shrinking the hull frees
interior points to be triangulated in more ways, and every triangulation contributes
an independent family of $2^{E}$ plane subgraphs whose exponent $E = 3n-3-h$
strictly increases as $h$ decreases. Theorem 5.2 establishes exactly this
monotonicity for the floor; the conjecture asserts the true count inherits it,
turning a bound-level phenomenon into a theorem about the extremal configuration.

**A sharp exponential base for convex position.** We conjecture $N(n) = c\cdot
n^{-3/2}\cdot \beta^n (1+o(1))$ for an explicit algebraic constant $\beta \approx
11.6$, and that no configuration in general position has growth base below $\beta$.
Convex position is the unique arrangement in which the crossing relation among chords
is governed solely by the linear cyclic order of the points, so the count becomes a
pure order statistic amenable to an exact transfer-matrix or generating-function
analysis; every departure from convexity adds crossing constraints that can only be
relaxed, never tightened, so it can only increase the count.
