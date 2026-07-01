# The Independence Ratio and the Fractional Chromatic Number: A Sharp $1/4$ Threshold for Unit-Distance Graphs

## Abstract

We develop, in full rigour, the finite-graph combinatorics that connects the
*independence ratio* of a graph to lower bounds on its (integral and fractional)
chromatic number, and we explain how this machinery bears on the fractional
chromatic number of the Euclidean plane. For a finite graph $G$ on $n > 0$
vertices with independence number $\alpha(G)$, the independence ratio is
$i(G) = \alpha(G)/n$. We prove the integral pigeonhole bound $n \le k\,\alpha(G)$
for every proper $k$-colouring, deduce that $i(G) < 1/4$ forces $G$ to be
non-$4$-colourable with chromatic number $\chi(G) > 4$, and show this threshold
is sharp via the complete graph $K_4$, whose ratio is exactly $1/4$. We then
formulate fractional colourings as nonnegative weightings of the independent sets
subject to a covering constraint, prove the linear-programming lower bound
$\text{value} \ge n/\alpha(G)$ by double counting, and conclude the fractional
analogue: $i(G) < 1/4$ implies that *every* fractional colouring has value
greater than $4$, i.e. $\chi_f(G) > 4$. Because any finite unit-distance graph
embeds in the plane, the existence of such a gadget forces
$\chi_f(\mathbb{R}^2) > 4$. We anchor the scale with the unit equilateral
triangle (ratio exactly $1/3$) and record a complementary edge-count
(Turán/Caro–Wei) route to independence-ratio bounds. These results isolate the
reduction "independence ratio below $1/4$ $\Rightarrow$ fractional chromatic
number above $4$" as the graph-theoretic engine of the Hadwiger–Nelson circle of
problems.

**Keywords:** independence ratio, fractional chromatic number, unit-distance
graph, Hadwiger–Nelson problem, chromatic number of the plane, pigeonhole
principle, linear-programming duality.

## 1. Introduction

The **Hadwiger–Nelson problem** asks for the least number of colours needed to
colour the Euclidean plane so that no two points at distance exactly $1$ share a
colour. This quantity, the chromatic number of the plane $\chi(\mathbb{R}^2)$,
was known for decades to lie between $4$ and $7$, and in 2018 was shown to be at
least $5$ by an explicit finite unit-distance graph requiring five colours.

A closely related and in many ways more tractable invariant is the **fractional
chromatic number** of the plane, $\chi_f(\mathbb{R}^2)$, which relaxes the
integrality of colour assignments. It had long been conjectured that
$\chi_f(\mathbb{R}^2) = 4$, and, in an equivalent finite-gadget formulation, that
*no* finite unit-distance graph in the plane can have independence ratio strictly
below $1/4$. Erdős asked in 1987 whether such a sub-$1/4$ gadget exists; a
positive answer refutes the conjecture and forces $\chi_f(\mathbb{R}^2) > 4$.

This paper does not construct the geometric gadget; rather, it isolates and
proves the *reduction* that gives the frontier its meaning. Our central message
is that the threshold $1/4$ is not an artefact of geometry but a transparent
consequence of two counting arguments — one integral and one fractional — each a
single application of the pigeonhole principle. The fraction $1/4$ is exactly the
reciprocal of the conjectured value $4$, so the statement "$i(G) < 1/4$" is
literally the statement "$n/\alpha(G) > 4$."

### Contributions

1. The integral colour-class bound $n \le k\,\alpha(G)$ (Theorem 3.1) and its
   corollaries: $i(G) < 1/4 \Rightarrow G$ not $4$-colourable (Theorem 3.3) and
   $\chi(G) > 4$ (Theorem 3.4).
2. Sharpness of the threshold: $K_4$ is $4$-colourable with ratio exactly $1/4$
   (Theorem 3.5), and more generally $K_k$ has ratio exactly $1/k$.
3. A formal notion of fractional colouring and its LP lower bound
   $\text{value} \ge n/\alpha(G)$ (Theorem 4.2), yielding the fractional frontier
   $i(G) < 1/4 \Rightarrow \chi_f(G) > 4$ (Theorem 4.3).
4. The scale-fixing computation $i(K_3) = 1/3$ for the unit equilateral triangle
   (Proposition 5.2), the unit-distance graph construction (Definition 5.1), and
   the reduction to $\chi_f(\mathbb{R}^2) > 4$ (Section 5).
5. A complementary Turán/Caro–Wei edge-count bound on the independence ratio
   (Theorem 6.1).

## 2. Definitions

Throughout, $G$ is a finite simple graph on a vertex set $V$ with
$n = |V| > 0$. We write $u \sim v$ when $u$ and $v$ are adjacent.

**Definition 2.1 (Independent set).** A set $S \subseteq V$ is *independent* if no
two of its vertices are adjacent: for all $u, v \in S$ with $u \ne v$, we have
$u \not\sim v$.

**Definition 2.2 (Independence number).** The *independence number* $\alpha(G)$ is
the maximum cardinality of an independent set in $G$.

**Definition 2.3 (Independence ratio).** The *independence ratio* of $G$ is
$$ i(G) = \frac{\alpha(G)}{n} \in (0, 1]. $$

**Definition 2.4 (Proper colouring).** A *proper $k$-colouring* is a map
$C : V \to \{1, \dots, k\}$ such that adjacent vertices receive distinct colours:
$u \sim v \Rightarrow C(u) \ne C(v)$. The *chromatic number* $\chi(G)$ is the
least $k$ for which a proper $k$-colouring exists; $G$ is *$k$-colourable* if
$\chi(G) \le k$.

**Definition 2.5 (Fractional colouring).** Let $\mathcal{I}$ denote the family of
all subsets of $V$. A *fractional colouring* of $G$ is a weight function
$w : \mathcal{I} \to \mathbb{Q}_{\ge 0}$ such that

- **(nonnegativity)** $w(s) \ge 0$ for all $s$;
- **(support)** $w(s) > 0$ only if $s$ is an independent set of $G$;
- **(covering)** for every vertex $v \in V$, $\displaystyle\sum_{s \ni v} w(s) \ge 1$.

Its *value* is $\displaystyle \text{value}(w) = \sum_{s} w(s)$. The *fractional
chromatic number* $\chi_f(G)$ is the infimum of $\text{value}(w)$ over all
fractional colourings.

A proper $k$-colouring induces the fractional colouring that puts weight $1$ on
each of its $k$ colour classes and $0$ elsewhere; its value is $k$. Hence
$\chi_f(G) \le \chi(G)$ for every $G$.

## 3. The integral colour-class bound and the $1/4$ threshold

The engine of the whole development is a single application of the pigeonhole
principle to the colour classes of a proper colouring.

**Theorem 3.1 (Colour-class bound).** *If $G$ admits a proper $k$-colouring
$C : V \to \{1,\dots,k\}$, then*
$$ n \;\le\; k \cdot \alpha(G). $$

*Proof.* For each colour $c$, let $V_c = \{v \in V : C(v) = c\}$ be the
corresponding colour class. Since $C$ is proper, no edge joins two vertices of
$V_c$, so $V_c$ is an independent set and therefore $|V_c| \le \alpha(G)$. The
classes partition $V$, so
$$ n = \sum_{c=1}^{k} |V_c| \;\le\; \sum_{c=1}^{k} \alpha(G) = k\,\alpha(G). \qquad\blacksquare $$

An immediate averaging reformulation is worth recording, since it is the form in
which the pigeonhole is usually applied.

**Proposition 3.2 (Large colour class).** *If $k > 0$ and $C$ is a proper
$k$-colouring, then some colour class has cardinality at least $n/k$; equivalently
there is an independent set $S$ with $n \le k\,|S|$.*

*Proof.* The $k$ colour classes have sizes summing to $n$, so by averaging at
least one has size at least $n/k$. That class is independent by properness.
$\blacksquare$

**Theorem 3.3 (Four colours are impossible below the threshold).** *If $n > 0$
and $i(G) < 1/4$, then $G$ is not $4$-colourable.*

*Proof.* Suppose for contradiction that $G$ has a proper $4$-colouring. By
Theorem 3.1 with $k = 4$, $n \le 4\,\alpha(G)$, hence
$i(G) = \alpha(G)/n \ge 1/4$, contradicting $i(G) < 1/4$. $\blacksquare$

**Theorem 3.4 (Chromatic number exceeds four).** *If $n > 0$ and $i(G) < 1/4$,
then $\chi(G) > 4$.*

*Proof.* $\chi(G) \le 4$ is equivalent to $4$-colourability, which Theorem 3.3
excludes. $\blacksquare$

The constant $1/4$ cannot be replaced by anything larger for the class of
$4$-colourable graphs: the bound is exactly sharp.

**Theorem 3.5 (Sharpness).** *For every $k \ge 1$, the complete graph $K_k$ is
$k$-colourable and satisfies $i(K_k) = 1/k$. In particular $K_4$ is
$4$-colourable with independence ratio exactly $1/4$.*

*Proof.* Colouring each of the $k$ vertices with its own colour is proper, so
$K_k$ is $k$-colourable. Every pair of vertices is adjacent, so any independent
set has at most one vertex, giving $\alpha(K_k) = 1$ and
$i(K_k) = 1/k$. $\blacksquare$

Thus the region "$i(G) \ge 1/4$" is exactly what four colours can guarantee: $K_4$
sits on the boundary, and any strict dip below $1/4$ certifies $\chi(G) > 4$.

## 4. Fractional colourings and the LP lower bound

The integral results have a fractional counterpart that is both strictly stronger
and, for the plane, the relevant one. The proof is again a single double-count,
now of the covering constraint.

**Theorem 4.2 (LP lower bound).** *Let $w$ be any fractional colouring of $G$ and
suppose $\alpha(G) > 0$. Then*
$$ \text{value}(w) \;\ge\; \frac{n}{\alpha(G)}. $$
*Consequently $\chi_f(G) \ge n/\alpha(G) = 1/i(G)$.*

*Proof.* Consider the double sum $\sum_{v \in V} \sum_{s \ni v} w(s)$. Summing
first over $v$ and using the covering constraint $\sum_{s \ni v} w(s) \ge 1$ for
each of the $n$ vertices gives
$$ \sum_{v \in V} \sum_{s \ni v} w(s) \;\ge\; n. $$
Exchanging the order of summation, each independent set $s$ is counted once for
every vertex it contains, so
$$ \sum_{v \in V} \sum_{s \ni v} w(s) \;=\; \sum_{s} w(s)\,|s|. $$
By the support condition, $w(s) > 0$ only for independent $s$, and every such $s$
satisfies $|s| \le \alpha(G)$; since $w(s) \ge 0$,
$$ \sum_{s} w(s)\,|s| \;\le\; \sum_{s} w(s)\,\alpha(G) \;=\; \alpha(G)\,\text{value}(w). $$
Chaining the three displays yields $n \le \alpha(G)\,\text{value}(w)$, and
dividing by $\alpha(G) > 0$ gives the claim. Taking the infimum over $w$ gives the
bound on $\chi_f(G)$. $\blacksquare$

Each hypothesis is load-bearing. Dropping the covering constraint admits the zero
weighting with value $0$; dropping the support constraint lets a single all-vertex
set carry all the weight and defeats the step $|s| \le \alpha(G)$; and $n > 0$ is
needed to have a nontrivial bound while $\alpha(G) > 0$ is needed to divide.

**Theorem 4.3 (Fractional frontier).** *If $n > 0$ and $i(G) < 1/4$, then
$\chi_f(G) > 4$; indeed every fractional colouring of $G$ has value strictly
greater than $4$.*

*Proof.* Since $i(G) < 1/4$ with $n > 0$ we have $\alpha(G)/n < 1/4$, i.e.
$n/\alpha(G) > 4$ (note $\alpha(G) \ge 1 > 0$ for any nonempty graph). By
Theorem 4.2 every fractional colouring has value at least $n/\alpha(G) > 4$.
$\blacksquare$

Because $\chi_f(G) \le \chi(G)$, Theorem 4.3 implies Theorem 3.4; the fractional
statement is the strictly stronger conclusion.

**Remark 4.4 (The trivial fractional colouring).** Placing weight $1$ on every
singleton $\{v\}$ and $0$ elsewhere is a valid fractional colouring: singletons
are independent, and each vertex is covered by exactly its own singleton. Its
value is $n$. This shows $\chi_f(G) \le n$ always and provides a concrete
feasible point against which the lower bound $n/\alpha(G)$ can be compared.

## 5. Unit-distance graphs and the plane

**Definition 5.1 (Unit-distance graph).** Given points
$p : \iota \to \mathbb{R}^2$ indexed by a finite set $\iota$, the *unit-distance
graph* $U(p)$ has vertex set $\iota$, with $i \sim j$ iff $i \ne j$ and the
Euclidean distance $\lVert p_i - p_j \rVert = 1$.

**Proposition 5.2 (The equilateral triangle).** *Let $p$ realise the three
vertices of an equilateral triangle of side length $1$. Then $U(p) = K_3$,
$\alpha(U(p)) = 1$, and*
$$ i(U(p)) = \tfrac{1}{3}. $$

*Proof.* All three pairwise distances equal $1$, so every pair is adjacent and
$U(p) = K_3$. Every independent set has at most one vertex, so $\alpha = 1$ and
$i = 1/3$. $\blacksquare$

The value $1/3 > 1/4$ fixes the natural scale of the problem: the smallest
nondegenerate unit-distance clique already lies above the frontier, and the search
for sub-$1/4$ gadgets is a search for configurations far richer than a single
triangle.

**The reduction to the plane.** The fractional chromatic number of the plane
$\chi_f(\mathbb{R}^2)$ is the infimal value of a fractional colouring of the
entire plane under the unit-distance rule. Any fractional colouring of the plane
restricts to a fractional colouring of any finite unit-distance subgraph $U(p)$:
the weights of independent sets in the plane, intersected with the finite vertex
set, remain nonnegative, supported on independent sets, and cover each vertex.
Hence

$$ \chi_f(\mathbb{R}^2) \;\ge\; \chi_f(U(p)) \;\ge\; \frac{|\iota|}{\alpha(U(p))} \;=\; \frac{1}{i(U(p))}. $$

Combining with Theorem 4.3 gives the headline reduction.

**Corollary 5.3 (Sub-$1/4$ gadget forces $\chi_f(\mathbb{R}^2) > 4$).** *If there
exists a finite set of points $p$ in the plane with $i(U(p)) < 1/4$, then
$\chi_f(\mathbb{R}^2) > 4$, refuting the conjecture $\chi_f(\mathbb{R}^2) = 4$ and
answering Erdős's 1987 question in the affirmative.*

The threshold is sharp for the target quantity as well: $1/4$ is precisely the
reciprocal of the conjectured value $\chi_f(\mathbb{R}^2) = 4$, so a ratio of
exactly $1/4$ is consistent with the conjecture while any strict decrease breaks
it.

## 6. A complementary edge-count bound

Colourability is not the only route to independence-ratio estimates. The classical
Turán/Caro–Wei inequality bounds the independence number from below in terms of
edge count, and is sharp for unions of cliques.

**Theorem 6.1 (Turán/Caro–Wei route).** *Let $G$ have $n$ vertices and
$m \ge 1$ edges. Then $G$ has an independent set $S$ with*
$$ |S| \;\ge\; \frac{n^2}{2m + n}, \qquad\text{equivalently}\qquad i(G) \ge \frac{n}{2m + n}. $$

*Proof sketch.* The Caro–Wei bound gives
$\alpha(G) \ge \sum_{v} \frac{1}{d(v) + 1}$ where $d(v)$ is the degree of $v$; by
convexity (or the Cauchy–Schwarz/AM–HM inequality) this is at least
$n^2/\big(\sum_v (d(v)+1)\big) = n^2/(2m + n)$, using $\sum_v d(v) = 2m$.
$\blacksquare$

For a graph that is simultaneously $4$-colourable and sparse, combining
Theorems 3.1 and 6.1 gives
$$ i(G) \;\ge\; \max\!\left(\tfrac14,\ \frac{n}{2m + n}\right), $$
an edge-count complement to the colouring bound. In the sub-$1/4$ regime this
inequality constrains how dense any candidate gadget must be: forcing
$n/(2m+n) < 1/4$ requires $m > 3n/2$, so a gadget with $i(U(p)) < 1/4$ must have
average degree exceeding $3$.

## 7. Discussion

The results above cleanly separate the two components of the Hadwiger–Nelson
circle of problems. The *hard* component is geometric: constructing a finite
planar unit-distance configuration whose independence ratio dips below $1/4$. The
*reduction* component — turning such a configuration into a lower bound on the
fractional chromatic number of the plane — is elementary, and is captured in full
by Theorems 3.1, 4.2, and 4.3. Both directions of the argument, integral and
fractional, are a single pass of the pigeonhole principle applied to,
respectively, the colour classes and the covering constraint.

Three features deserve emphasis. First, the threshold $1/4$ is not tuned to
geometry; it is the reciprocal of $4$, and the entire content of "$i(G) < 1/4$" is
"$n/\alpha(G) > 4$." Second, the fractional bound is strictly stronger than the
integral one and is the one relevant to $\chi_f(\mathbb{R}^2)$, precisely because
$\chi_f \le \chi$. Third, sharpness is genuine: $K_4$ realises ratio exactly
$1/4$, so no argument from four-colourability alone can push the guaranteed ratio
higher.

## 8. Future directions

The following conjectures organise the natural next steps. They isolate the
reduction "independence ratio below $1/4$ forces the fractional chromatic number
above $4$" and use the exact value $i(K_3) = 1/3$ as a scale anchor.

**Conjecture 8.1 (Threshold sharpness for planar unit-distance graphs).** There is
a sequence of finite planar unit-distance graphs whose independence ratios
converge to the infimal value $1/4$ from above, but no finite planar unit-distance
graph attains independence ratio equal to $1/4$; the infimum is approached but
never met. The guiding intuition is that the independence ratio behaves like a
supremal packing density — each geometric constraint shaves the ratio only by a
rational amount, so the extremal value is a limit of rationals rather than a
single attained rational.

**Conjecture 8.2 (Ratio–fractional-chromatic duality is tight for vertex-transitive
gadgets).** For every finite vertex-transitive unit-distance graph, the fractional
chromatic number equals exactly the reciprocal of the independence ratio,
$\chi_f = n/\alpha$, with no gap. Consequently a vertex-transitive planar gadget
with independence ratio below $1/4$ gives the cleanest possible certificate that
$\chi_f(\mathbb{R}^2) > 4$. Symmetry averages any fractional colouring into a
uniform one, so the linear-programming lower bound $n/\alpha$ is simultaneously an
upper bound, collapsing the duality gap.

**Conjecture 8.3 (A $1/4 - \varepsilon$ barrier scales the chromatic number of the
plane).** If finite planar unit-distance graphs exist with independence ratio at
most $1/4 - \varepsilon$ for some fixed $\varepsilon > 0$, then
$$ \chi_f(\mathbb{R}^2) \;\ge\; \frac{1}{1/4 - \varepsilon} \;=\; 4 + \frac{4\varepsilon}{1 - 4\varepsilon}; $$
in particular any uniform improvement on the ratio translates into a quantitative
improvement on the plane's fractional chromatic number. The reciprocal map turns
an additive gain in independence ratio into a strictly larger additive gain in the
chromatic lower bound, so ratio improvements are amplified rather than merely
inherited.

**Conjecture 8.4 (Simplices are the worst anchors).** Among small unit-distance
cliques, the complete graphs $K_k$ (realised only for $k \le 3$ in the plane, and
by higher-dimensional simplices in general) are the extremal ratio-$1/k$
configurations, and no planar gadget built purely from triangle-rich
substructures can beat the frontier without introducing longer-range
non-adjacencies.

## 9. Conclusion

We have given a complete, self-contained account of the combinatorial reduction
underlying the fractional Hadwiger–Nelson problem: independence ratio below $1/4$
forces the fractional chromatic number above $4$, both for finite graphs and, by
restriction, for the plane. The argument rests on two double-counting
inequalities, is sharp at $K_4$, and is anchored by the exact value $i(K_3) =
1/3$. What remains is the geometric construction of a witness — a task the present
framework converts, mechanically, into quantitative progress on the colouring of
the plane.
