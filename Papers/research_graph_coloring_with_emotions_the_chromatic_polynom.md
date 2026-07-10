# The Emotional Chromatic Number of Social Networks

## Abstract

We introduce and analyze the *emotional chromatic number* of a finite social
network, a variant of the classical graph chromatic number designed to model the
assignment of emotional states to individuals under the constraint that no two
friends share an emotion, together with a psychologically motivated floor of
three categories. Modeling a social network as a finite simple graph $G$ whose
vertices are people and whose edges are friendships, a *proper $k$-coloring* is
an assignment of one of $k$ emotions to each person so that adjacent people
differ; the *chromatic polynomial* $\chi_G(k)$ counts such colorings and is a
polynomial in $k$. We define the emotional chromatic number
$\chi_E(G) = \min\{\, k \ge 3 : \chi_G(k) > 0 \,\}$ and establish its exact
value on the two fundamental families of networks: for the complete graph
(a clique of mutual friends) $\chi_E(K_n) = \max(n, 3)$, and for the cycle
(a friendship ring) $\chi_E(C_n) = 3$ for all $n \ge 3$. We prove the
*six-emotion window* $3 \le \chi_E(G) \le 6$ for every network colorable with
six emotions, explaining the empirical adequacy of the six Ekman basic emotions.
Finally we correct a piece of folklore: bipartite networks are precisely those
that admit a two-emotion coloring, so the honest universal root of the chromatic
polynomial for a network with an edge is at $k = 1$, not $k = 2$. We give
algorithms, numerical demonstrations, and a family of conjectures unifying the
invariant with classical chromatic theory.

**Keywords:** chromatic polynomial, chromatic number, proper coloring, complete
graph, cycle graph, bipartite graph, deletion–contraction, social networks.

---

## 1. Introduction

Graph coloring is among the oldest and most applicable branches of combinatorics.
Its central quantity for a finite simple graph $G = (V, E)$ is the **chromatic
polynomial** $\chi_G(k)$, which counts the number of *proper $k$-colorings*:
functions $c : V \to \{1, \dots, k\}$ with $c(u) \ne c(v)$ whenever
$\{u, v\} \in E$. Birkhoff showed $\chi_G$ is a monic polynomial of degree
$|V|$ in $k$, and its least positive integer argument giving a nonzero value is
the **chromatic number** $\chi(G)$.

This paper reframes coloring as a model of *emotional consistency* in a social
network. Let the vertices of $G$ be people and the edges be friendships. Identify
the $k$ colors with $k$ distinct emotional states; a proper $k$-coloring is then
an assignment of emotions in which **no two friends feel the same way**. We call
such an assignment *emotionally consistent*. The count of emotionally consistent
assignments over a palette of $k$ emotions is exactly $\chi_G(k)$.

The motivating palette is the set of six *basic emotions* — happiness, sadness,
anger, fear, disgust, surprise — long argued to be cross-culturally universal.
Evaluating $\chi_G(6)$ counts the emotionally consistent assignments over this
palette. But the deeper invariant is the smallest palette that *works at all*,
subject to one modeling decision: a meaningful emotional life requires at least
three categories, since one emotion is uniform affect and two is a mere binary
split. We therefore impose a floor at three.

**Definition 1.1 (Emotional chromatic number).**
For a finite simple graph $G$, the *emotional chromatic number* is
$$\chi_E(G) \;=\; \min\{\, k \in \mathbb{Z} : k \ge 3 \text{ and } \chi_G(k) > 0 \,\}.$$
Equivalently, $\chi_E(G) = \max(\chi(G), 3)$ provided $G$ is colorable, which
every finite graph is.

The paper's contributions are: (i) exact formulas for $\chi_E$ on cliques and
cycles; (ii) the six-emotion window theorem; (iii) a correction of the
"bipartite root at $k = 2$" folklore; and (iv) a program of conjectures unifying
$\chi_E$ with classical chromatic theory via the identity $\chi_E = \max(\chi, 3)$.

---

## 2. Preliminaries

Throughout, $G = (V, E)$ is a finite simple graph: $V$ finite, $E$ a set of
unordered pairs of distinct vertices. We write $n = |V|$.

**Definition 2.1 (Proper coloring).** For $k \in \mathbb{N}$, a *proper
$k$-coloring* is a map $c : V \to \{1, \dots, k\}$ such that $c(u) \ne c(v)$ for
every edge $\{u, v\} \in E$.

**Definition 2.2 (Chromatic polynomial).** $\chi_G(k)$ is the number of proper
$k$-colorings of $G$. It is a monic integer polynomial of degree $n$ in $k$.

**Definition 2.3 (Chromatic number).**
$\chi(G) = \min\{\, k \in \mathbb{N} : \chi_G(k) > 0 \,\}$.

**Definition 2.4 (Bipartite graph).** $G$ is *bipartite* if $V$ admits a
partition $V = A \sqcup B$ with every edge having one endpoint in $A$ and one in
$B$. Equivalently, $G$ has no odd cycle; equivalently, $\chi(G) \le 2$.

**Lemma 2.5 (Monotonicity of colorability).** If $\chi_G(k) > 0$ and
$k' \ge k$, then $\chi_G(k') > 0$.

*Proof sketch.* A proper $k$-coloring is already a proper $k'$-coloring once the
palette is enlarged from $\{1, \dots, k\}$ to $\{1, \dots, k'\}$; the extra
colors are simply unused, and every adjacency constraint remains satisfied.
$\square$

A consequence of Lemma 2.5 is that the set of admissible palette sizes is an
*up-set*: $\{k : \chi_G(k) > 0\} = [\chi(G), \infty) \cap \mathbb{Z}$. This is
the structural fact underlying every result below and the reason
$\chi_E(G) = \max(\chi(G), 3)$: intersecting the interval $[\chi(G), \infty)$
with $[3, \infty)$ yields $[\max(\chi(G),3), \infty)$, whose least element is
$\max(\chi(G), 3)$.

**Lemma 2.6 (Deletion–contraction).** For any edge $e \in E$,
$$\chi_G(k) = \chi_{G - e}(k) - \chi_{G / e}(k),$$
where $G - e$ deletes $e$ and $G / e$ contracts it (identifying its endpoints).

*Proof sketch.* Proper $k$-colorings of $G - e$ split into those that give the
endpoints of $e$ different colors (exactly the proper colorings of $G$) and those
that give them equal colors (in bijection with proper colorings of $G / e$).
Rearranging gives the identity. $\square$

Deletion–contraction is the standard recursive engine for computing $\chi_G$ and
underlies the algorithmic section.

---

## 3. Cliques: everyone needs a different emotion

**Theorem 3.1 (Emotional chromatic number of a clique).**
For the complete graph $K_n$ on $n \ge 1$ vertices,
$$\chi_E(K_n) = \max(n, 3).$$

*Proof sketch.* In $K_n$ every two vertices are adjacent, so a proper coloring
must be injective; hence a proper $k$-coloring exists iff $k \ge n$, giving
$\chi(K_n) = n$. (Concretely $\chi_{K_n}(k) = k(k-1)\cdots(k-n+1)$, which is
positive exactly when $k \ge n$.) Applying Definition 1.1,
$\chi_E(K_n) = \max(\chi(K_n), 3) = \max(n, 3)$. $\square$

Interpretation: a group of $n$ mutual friends needs $n$ distinct emotions when
$n \ge 3$, and the emotional floor supplies three when $n \in \{1, 2\}$. In
particular a single pair of friends ($K_2$) has $\chi_E = 3$ even though two
colors separate them, because the model forbids a purely binary emotional world.

---

## 4. Cycles: the friendship ring always needs three

**Theorem 4.1 (Emotional chromatic number of a cycle).**
For the cycle graph $C_n$ on $n \ge 3$ vertices,
$$\chi_E(C_n) = 3.$$

*Proof sketch.* The classical chromatic number of a cycle is
$$\chi(C_n) = \begin{cases} 2 & n \text{ even},\\ 3 & n \text{ odd},\end{cases}$$
because an even cycle is bipartite (alternate two colors around the ring) whereas
an odd cycle is not (the alternation collides upon closing the loop, forcing a
third color). Equivalently the chromatic polynomial is
$\chi_{C_n}(k) = (k-1)^n + (-1)^n (k-1)$, which at $k = 2$ equals
$1 + (-1)^n$: this is $2$ for even $n$ and $0$ for odd $n$, confirming
$\chi(C_n) \in \{2, 3\}$. Taking the emotional floor,
$\chi_E(C_n) = \max(\chi(C_n), 3) = 3$ in both parities. $\square$

Interpretation: parity, which controls the *ordinary* chromatic number of a
ring, is invisible to the *emotional* chromatic number. Every friendship ring,
even or odd, requires exactly three emotions — the even rings could be
two-colored mathematically, but the emotional floor lifts them to three.

---

## 5. The six-emotion window

**Theorem 5.1 (Six-emotion window).**
If $G$ is a finite graph with $\chi(G) \le 6$ (equivalently $\chi_G(6) > 0$),
then
$$3 \le \chi_E(G) \le 6.$$

*Proof sketch.* The lower bound $\chi_E(G) \ge 3$ is immediate from
Definition 1.1. For the upper bound, $\chi(G) \le 6$ means $\chi_G(6) > 0$, so
$6$ is an admissible palette size $\ge 3$; hence the minimum defining
$\chi_E(G)$ is at most $6$. Combining, $3 \le \chi_E(G) \le 6$. $\square$

This theorem explains the empirical adequacy of Ekman's six basic emotions.
Real friendship networks are overwhelmingly sparse and locally clustered, and
such networks are colorable with few colors; whenever six emotions suffice for
legality, the emotional chromatic number is pinned into the interval $[3, 6]$,
with three the irreducible floor and six a comfortable ceiling. The empirical
test "$\chi_E(G) \in [3, 6]$ for most real networks" is therefore not a
coincidence but a corollary of sparsity: for the large majority of real social
networks $\chi(G) \le 6$ holds, and Theorem 5.1 does the rest.

---

## 6. Correcting the bipartite folklore

A commonly repeated claim asserts that the chromatic polynomial of a bipartite
network "has a root at $k = 2$," i.e. that a cleanly two-sided community admits
*zero* two-emotion assignments. This is false, and its correction is
instructive.

**Theorem 6.1 (Two emotions succeed exactly on bipartite networks).**
Let $G$ be a finite graph. Then $\chi_G(2) > 0$ if and only if $G$ is bipartite.
Moreover, if $G$ has at least one edge then $\chi_G(1) = 0$.

*Proof sketch.* A proper $2$-coloring $c : V \to \{1, 2\}$ is exactly a partition
of $V$ into the two color classes $A = c^{-1}(1)$, $B = c^{-1}(2)$ with no edge
inside a class — that is, a bipartition. So $\chi_G(2) > 0$ iff a bipartition
exists iff $G$ is bipartite. For the second claim, a proper $1$-coloring assigns
the single color to every vertex, which violates the constraint on any edge;
hence $\chi_G(1) = 0$ whenever $E \ne \emptyset$. $\square$

Thus the *universal* root of the chromatic polynomial for a network with a
friendship is at $k = 1$, not $k = 2$. Bipartite networks are, on the contrary,
precisely those for which two emotions *first succeed*. The emotional layer then
intervenes: by Definition 1.1 the floor lifts every bipartite network (with at
least one edge, so $\chi = 2$) to $\chi_E = 3$. So a cleanly split community does
have a valid two-emotion coloring, but is nonetheless assigned emotional
chromatic number three, matching the cycle computation of Section 4 for even
rings.

---

## 7. Algorithms

We describe the two computational primitives used to evaluate the invariant.

**Algorithm A (Chromatic polynomial by deletion–contraction).** Recursively
apply Lemma 2.6: $\chi_G = \chi_{G-e} - \chi_{G/e}$, terminating at edgeless
graphs where $\chi_{\overline{K_m}}(k) = k^m$. Memoizing on canonical graph
forms controls the exponential blow-up on sparse inputs. The output is the
coefficient vector of $\chi_G$, from which $\chi_G(k)$ for any $k$ is a Horner
evaluation.

**Algorithm B (Emotional chromatic number).** Given $G$, compute the ordinary
chromatic number $\chi(G)$ (by searching for the least $k$ with a proper
$k$-coloring, e.g. via backtracking or by evaluating $\chi_G$), then return
$\max(\chi(G), 3)$. Correctness is Lemma 2.5: the admissible palette sizes form
the interval $[\chi(G), \infty)$, so the least admissible size that is also
$\ge 3$ is $\max(\chi(G), 3)$.

For the structured families the closed forms of Sections 3–4 bypass search
entirely: $\chi_E(K_n) = \max(n, 3)$ and $\chi_E(C_n) = 3$.

---

## 8. Applications

- **Measuring emotional diversity.** $\chi_E(G)$ is a scalar summary of how much
  affective contrast a network structurally demands: cliques force one emotion
  per member, while sparse webs sit near the floor.
- **Palette adequacy.** Theorem 5.1 certifies that a six-emotion vocabulary
  suffices for any network with chromatic number at most six, quantifying when a
  fixed emotional lexicon can consistently annotate a community.
- **Counting configurations.** $\chi_G(6)$ gives the exact number of emotionally
  consistent labelings over the basic-emotion palette, a combinatorial capacity
  measure for sentiment-annotation tasks on social graphs.
- **Beyond emotions.** The same invariant models any "no two neighbors alike"
  allocation with a minimum-variety floor: frequency assignment, exam
  scheduling, register allocation, and seating arrangements.

---

## 9. Discussion

The emotional chromatic number is deliberately a thin modification of the
classical chromatic number: it is exactly $\max(\chi(G), 3)$. Its interest lies
not in mathematical novelty of definition but in the clarity with which it
separates two effects. The *structural* demand for contrast is carried entirely
by $\chi(G)$; the *modeling* decision that emotional life needs at least three
categories is carried entirely by the floor. The clique and cycle theorems
exhibit both regimes cleanly — cliques with $n \ge 3$ track $\chi$, while
bipartite structures (even cycles, all bipartite networks) are lifted to the
floor. The folklore correction underscores a recurring pedagogical hazard:
$k = 1$, not $k = 2$, is the universal obstruction, and bipartiteness is a
*success* condition at $k = 2$, not a failure.

---

## 10. Future Directions

**Conjecture 10.1 (The emotional floor is the only correction).** For every
finite graph $G$, $\chi_E(G) = \max(\chi(G), 3)$. The set of admissible emotion
counts is the interval $[\max(\chi, 3), \infty)$ whose least element is
$\max(\chi, 3)$; the emotional constraint contributes exactly one thing — the
floor at three. The clique and cycle computations already exhibit both regimes,
so a single uniform identity is the natural consolidation and would make every
downstream emotional statistic a corollary of chromatic theory.

**Conjecture 10.2 (Emotional monotonicity under friendship growth).** Adding a
friendship (an edge) to a network raises $\chi_E$ by at most one, and removing
one lowers it by at most one; hence networks differing in a single friendship
have $\chi_E$ differing by at most one. A proper coloring of the larger graph
restricts to the smaller one, while a coloring of the smaller graph extends
across a new edge after recoloring at most one endpoint, so $\chi_E$ is
1-Lipschitz with respect to edge edits. Deletion–contraction gives exact control
of coloring counts under edge edits; lifting that control from counts to the
floored minimum is the immediate next step.

**Conjecture 10.3 (Sparse networks stay inside the six-emotion window).** Every
network in which each person has at most five friends satisfies
$\chi_E(G) \le 6$; more generally, bounded-degree networks have emotional
chromatic number at most one more than the maximum number of friends, capped
below by three. A greedy assignment, processing people one at a time, always
finds a free emotion whenever the number of already-colored friends is below the
palette size, so $\deg_{\max} + 1$ emotions always suffice. Real friendship
networks are overwhelmingly sparse, so a degree-based bound explains why
emotional chromatic numbers cluster in $[3, 6]$.

---

## References (selected background)

- G. D. Birkhoff, *A determinant formula for the number of ways of coloring a
  map*, Ann. of Math., 1912.
- R. C. Read, *An introduction to chromatic polynomials*, J. Combin. Theory, 1968.
- P. Ekman, *An argument for basic emotions*, Cognition and Emotion, 1992.
