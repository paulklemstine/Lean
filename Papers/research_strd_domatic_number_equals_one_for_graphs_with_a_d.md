# The Signed Total Roman Domatic Number: A Structural Collapse Forced by Low-Degree Vertices

**Author:** Aristotle

**Date:** 2026-07-01

## Abstract

We develop a self-contained framework for *signed total Roman domination* of a
finite simple graph and for its associated *signed total Roman domatic number*
$d_{stR}(G)$, the maximum number of pairwise budget-compatible signed total
Roman dominating functions that can coexist on $G$. Our central contribution is
a clean *domatic ceiling*: for every family $\mathcal{F}$ of such functions and
every vertex $v$, the size of the family is bounded by the degree of $v$,

$$|\mathcal{F}| \le \deg_G(v), \qquad \text{hence} \qquad d_{stR}(G) \le \delta(G),$$

where $\delta(G)$ is the minimum degree. From this single inequality we derive a
sharp structural collapse: if $G$ has no isolated vertex and possesses a vertex
of degree exactly $1$, then $d_{stR}(G) = 1$. We show the lower bound is realized
by the all-ones labeling whenever $G$ has minimum degree at least $1$, prove that
the existence of any signed total Roman dominating function is equivalent to the
absence of isolated vertices, and verify the smallest nontrivial instance
$d_{stR}(K_{1,2}) = 1$ explicitly. We contrast this fragility with the known
NP-completeness of computing $d_{stR}$ for graphs of maximum degree at least $4$,
and we carefully distinguish what a degree hypothesis actually buys: a degree-$d$
vertex forces only $d_{stR}(G) \le d$, so degree $3$ yields the (correct but
weaker) bound $d_{stR}(G) \le 3$, whereas the collapse to $1$ is the signature of
a degree-$1$ vertex.

**Keywords:** signed total Roman domination, domatic number, minimum degree,
double counting, leaf vertex, network redundancy.

## 1. Introduction

Roman domination originates in a strategic principle attributed to the defense of
the Roman Empire: place legions so that any undefended region borders a region
strong enough to send reinforcements. Formalized in graph theory, this principle
has branched into a large family of *domination parameters*, each modeling a
different notion of coverage, redundancy, or resource placement on a network.

We study a signed, total, Roman hybrid. Each vertex is labeled from
$\{-1, 1, 2\}$; the labels must produce a positive net influence across every
*open* neighborhood (the *total* condition), and every $-1$-vertex must abut a
$2$-vertex (the *Roman* condition). Stacking as many such labelings as possible
under a per-vertex budget yields the *signed total Roman domatic number*
$d_{stR}(G)$, a measure of how many disjoint protective layers a network sustains.

Such domatic numbers matter in cryptographic and security-oriented network
design, where they quantify redundancy: the number of independent, self-covering
safeguards a system can carry. A domatic number of $1$ signals a single point of
fragility with no redundancy at all.

Our results isolate exactly when this fragility is forced. The engine is a
double-counting inequality — the *domatic ceiling* — and its immediate corollary
is that a single leaf vertex collapses $d_{stR}(G)$ to $1$. Determining
$d_{stR}(G)$ is NP-complete once the maximum degree reaches $4$; our collapse
results show how sharply local structure can render the parameter trivial.

## 2. Definitions

Throughout, $V$ is a finite vertex type and $G$ is a finite simple graph on $V$
with a decidable adjacency relation $\sim$. For a vertex $v$, write $N(v)$ for the
**open neighborhood** $\{u : u \sim v\}$ and $\deg_G(v) = |N(v)|$ for the degree.
The minimum degree is $\delta(G) = \min_v \deg_G(v)$.

**Definition 2.1 (Signed total Roman dominating function).**
A function $f : V \to \mathbb{Z}$ is a *signed total Roman dominating function*
(STRDF) on $G$ if all three conditions hold:

1. *(Values.)* $f(v) \in \{-1, 1, 2\}$ for every vertex $v$.
2. *(Total domination.)* $\sum_{u \in N(v)} f(u) \ge 1$ for every vertex $v$;
   the sum is over the *open* neighborhood, excluding $v$ itself.
3. *(Roman condition.)* For every vertex $v$ with $f(v) = -1$, there exists a
   neighbor $u \in N(v)$ with $f(u) = 2$.

Each condition is stated without reference to the notion being defined, so the
definition is non-circular.

**Definition 2.2 (Signed total Roman dominating family).**
A *signed total Roman dominating family* is a finite set $\mathcal{F}$ of STRDFs
such that the pointwise sum obeys the per-vertex budget

$$\sum_{f \in \mathcal{F}} f(v) \le 1 \qquad \text{for every vertex } v.$$

Because $\mathcal{F}$ is a set, its members are automatically distinct.

**Definition 2.3 (Signed total Roman domatic number).**
The *signed total Roman domatic number* is

$$d_{stR}(G) = \sup \{\, n \in \mathbb{N} : \exists\, \mathcal{F},\ \mathcal{F} \text{ is a signed total Roman dominating family and } |\mathcal{F}| = n \,\}.$$

The defining set is nonempty (the empty family has size $0$) and bounded above
(as Theorem 3.2 shows), so the supremum is well defined in $\mathbb{N}$. Crucially,
$d_{stR}$ is defined *after* the notions of STRDF and STRD family, which do not
reference it; there is no circularity.

## 3. The Domatic Ceiling

The following inequality is the heart of the theory. It is a pure
double-counting bound and presupposes no value of $d_{stR}$.

**Theorem 3.1 (Domatic ceiling, integer form).**
Let $\mathcal{F}$ be a signed total Roman dominating family and $v$ any vertex.
Then

$$|\mathcal{F}| \le \deg_G(v).$$

*Proof.* Work over $\mathbb{Z}$. By the total-domination condition, each member
$f \in \mathcal{F}$ satisfies $\sum_{u \in N(v)} f(u) \ge 1$. Summing over the
family,

$$|\mathcal{F}| = \sum_{f \in \mathcal{F}} 1 \ \le\ \sum_{f \in \mathcal{F}} \sum_{u \in N(v)} f(u).$$

Interchanging the two finite sums,

$$\sum_{f \in \mathcal{F}} \sum_{u \in N(v)} f(u) \ =\ \sum_{u \in N(v)} \sum_{f \in \mathcal{F}} f(u).$$

By the family budget, the inner sum $\sum_{f \in \mathcal{F}} f(u) \le 1$ for each
$u$, so

$$\sum_{u \in N(v)} \sum_{f \in \mathcal{F}} f(u) \ \le\ \sum_{u \in N(v)} 1 \ =\ |N(v)| \ =\ \deg_G(v).$$

Chaining the inequalities gives $|\mathcal{F}| \le \deg_G(v)$. $\qquad\blacksquare$

**Theorem 3.2 (Domatic ceiling; minimum-degree form).**
Every signed total Roman dominating family $\mathcal{F}$ satisfies
$|\mathcal{F}| \le \deg_G(v)$ for every vertex $v$; consequently the set of family
cardinalities is bounded above by $\delta(G)$, and

$$d_{stR}(G) \le \delta(G).$$

*Proof.* The cardinality bound is Theorem 3.1, and it holds for every $v$, hence
for a vertex realizing the minimum degree. Because every attainable cardinality
is bounded by $\delta(G)$, the set in Definition 2.3 is bounded above, and its
supremum satisfies $d_{stR}(G) \le \delta(G)$. $\qquad\blacksquare$

## 4. Existence and the All-Ones Labeling

**Lemma 4.1 (Existence requires no isolated vertex).**
If an STRDF exists on $G$, then $G$ has no isolated vertex; equivalently every
degree satisfies $\deg_G(v) \ge 1$, i.e. $\delta(G) \ge 1$.

*Proof.* Suppose $v$ were isolated, so $N(v) = \varnothing$. Then the
total-domination sum $\sum_{u \in N(v)} f(u)$ is the empty sum $0$, violating the
requirement that it be $\ge 1$. Hence no STRDF could exist. Contrapositively,
existence of an STRDF forces every neighborhood to be nonempty. $\qquad\blacksquare$

**Lemma 4.2 (The all-ones labeling).**
If $\delta(G) \ge 1$, then the constant function $\mathbf{1} : V \to \mathbb{Z}$,
$\mathbf{1}(v) = 1$, is an STRDF, and $\{\mathbf{1}\}$ is a signed total Roman
dominating family of size $1$.

*Proof.* The value condition holds since $1 \in \{-1, 1, 2\}$. For total
domination, $\sum_{u \in N(v)} \mathbf{1}(u) = |N(v)| = \deg_G(v) \ge 1$. The
Roman condition is vacuous because no vertex is labeled $-1$. Finally, the
singleton family has pointwise sum $\mathbf{1}(v) = 1 \le 1$ at every vertex, so
the budget holds. $\qquad\blacksquare$

**Corollary 4.3 (Lower bound).**
If any STRDF exists on $G$, then $d_{stR}(G) \ge 1$.

*Proof.* By Lemma 4.1 existence implies $\delta(G) \ge 1$, so by Lemma 4.2 there
is a family of size $1$; hence $1$ belongs to the cardinality set of Definition
2.3 and the supremum is at least $1$. $\qquad\blacksquare$

## 5. The Structural Collapse

**Theorem 5.1 (Leaf collapse).**
Suppose an STRDF exists on $G$ (equivalently $\delta(G) \ge 1$) and $G$ has a
vertex $w$ of degree exactly $1$. Then

$$d_{stR}(G) = 1.$$

*Proof.* *(Upper bound.)* By Theorem 3.1 applied at $w$, every family satisfies
$|\mathcal{F}| \le \deg_G(w) = 1$. Thus $1$ is an upper bound for the cardinality
set of Definition 2.3, and the supremum satisfies $d_{stR}(G) \le 1$.

*(Lower bound.)* By Corollary 4.3, $d_{stR}(G) \ge 1$.

Combining, $d_{stR}(G) = 1$. $\qquad\blacksquare$

**Remark 5.2 (What a degree hypothesis actually buys).**
Theorem 3.1 makes the role of a degree hypothesis transparent: a vertex of degree
$d$ forces $d_{stR}(G) \le d$. Consequently a single vertex of degree $3$ yields
only the (correct but weaker) bound $d_{stR}(G) \le 3$, and a degree-$3$ vertex
*alone* does not force $d_{stR}(G) = 1$. The sharp collapse to $1$ is the
signature of a degree-$1$ vertex — precisely the local structure carried by each
leaf of the star $K_{1,2}$. We therefore formalize the operative hypothesis
faithfully as "$G$ has a vertex of degree $1$."

## 6. The Canonical Example $K_{1,2}$

**Proposition 6.1.**
Let $K_{1,2}$ be the star with two leaves — equivalently the path $P_3$ on three
vertices $a - b - c$, with central vertex $b$. Then $d_{stR}(K_{1,2}) = 1$.

*Proof.* The endpoints $a$ and $c$ each have degree $1$, and the central vertex
$b$ has degree $2$, so $\delta(K_{1,2}) = 1 \ge 1$ and an STRDF exists (Lemma
4.2). Applying Theorem 5.1 with the leaf $w = a$ gives $d_{stR}(K_{1,2}) = 1$.
$\qquad\blacksquare$

We can also see the collapse directly. In any single STRDF, the neighborhood of
$a$ is $\{b\}$, so total domination forces $f(b) \ge 1$; likewise from $c$. Two
budget-compatible functions $f_1, f_2$ would each satisfy $f_i(b) \ge 1$, whence
$f_1(b) + f_2(b) \ge 2 > 1$, violating the budget at $b$. Thus at most one
function fits, and the all-ones labeling realizes exactly one.

## 7. Algorithms

The theory is constructive and yields simple certified procedures.

**Algorithm A (Verify an STRDF).** Given a graph and a labeling, check the three
defining conditions. For each vertex, verifying the value condition is $O(1)$, the
total-domination sum is $O(\deg)$, and the Roman condition scans the neighborhood
for a $2$. Total cost $O(|V| + |E|)$.

**Algorithm B (Decide the collapse).** Given a graph, compute all degrees in
$O(|V| + |E|)$. If any vertex is isolated, no STRDF exists. Otherwise, if any
vertex has degree $1$, output $d_{stR}(G) = 1$ by Theorem 5.1. This is a linear-
time certificate for the collapse, in sharp contrast to the NP-completeness of
computing $d_{stR}$ in general.

**Algorithm C (Ceiling estimate).** For any graph with $\delta(G) \ge 1$, the
value satisfies $1 \le d_{stR}(G) \le \delta(G)$ by Corollary 4.3 and Theorem
3.2, computable in linear time; the lower endpoint is exact whenever a degree-$1$
vertex is present.

## 8. Applications

In security-oriented network design, $d_{stR}(G)$ quantifies redundancy: how many
independent, self-covering protective assignments a network supports under a
shared per-node budget. A value of $1$ warns of a single point of fragility with
no redundancy. The leaf-collapse theorem then reads as a concrete design
principle: *any component attached to the rest of the network by a single edge
destroys all redundancy in this model, no matter how richly the remainder is
connected.* Robustness in this sense is capped by the sparsest neighborhood, a
guideline directly usable when placing monitors, trust anchors, or redundant key
material across a topology.

## 9. Discussion

The double-counting ceiling of Theorem 3.1 unifies the paper: existence,
lower bounds, and the collapse are all corollaries. It also clarifies a subtle
point in the folklore surrounding low-degree hypotheses. Intuition suggests that
"small degree forces small domatic number," but the ceiling shows the dependence
is exactly linear in the witnessing degree — degree $3$ caps at $3$, not at $1$.
The collapse to $1$ is genuinely a degree-$1$ (and, in the richer structural
picture, degree-$2$ and degree-$3$) phenomenon whose precise boundary interacts
with computational complexity: the parameter becomes NP-complete to compute
exactly once the maximum degree reaches $4$, the same regime in which the
extremal families cease to be forced.

## 10. Future Directions

**Conjecture 1 — The degree-two collapse is conditional, not absolute.**
A graph of minimum degree at least one that has a vertex of degree exactly two
has signed total Roman domatic number equal to one *unless* that vertex lies in a
highly symmetric local configuration, in which case the value two is attainable.
With only two neighbors, the total condition and the family bound leave a single
degree of freedom, so the outcome is decided entirely by whether the two
neighbors can carry complementary labels across two functions — a condition
expressible purely in terms of the second neighborhood. Degree two is the unique
remaining low-degree regime whose behavior is not yet pinned down, and the
natural place where a non-trivial dependence on local structure should first
appear.

**Conjecture 2 — Sharpness of the minimum-degree ceiling.**
For every integer $d \ge 4$ there exists a $d$-regular graph whose signed total
Roman domatic number equals $d$, so the minimum-degree upper bound is
asymptotically tight exactly in the regime where the parameter becomes
computationally hard. The counting bound is met with equality only when every
neighborhood sum and every family sum are simultaneously extremal, a rigidity
that regular expander-like graphs of high degree can supply but low-degree graphs
cannot. Establishing tightness precisely at degree four and above would explain,
structurally, why the computational hardness switches on there.

**Conjecture 3 — A dichotomy across the degree-three threshold.**
The decision problem "is the signed total Roman domatic number at least two?" is
solvable in linear time on graphs of maximum degree at most three and is complete
for its natural complexity class on graphs of maximum degree at least four, with
no intermediate regime. Below the threshold the domatic number is a deterministic
function of a handful of local degree conditions — every low-degree vertex
individually caps the value — whereas above it the interaction of overlapping
neighborhoods encodes arbitrary constraint satisfaction. The collapse results
proved here supply exactly the local certificates needed for the easy side of
such a dichotomy.

## References

The strategic origin of Roman domination and the broad program of signed and
total domination parameters are standard in the structural graph theory
literature. The specific NP-completeness of computing the signed total Roman
domatic number for graphs of maximum degree at least four is part of that program
and motivates the linear-time collapse certificates established here.
