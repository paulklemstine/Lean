# The Exact Domination Number of the Path, and a Program Toward Transmission Zero Forcing on Trees

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Novelty (Structural / Algorithmic Graph Theory)

## Abstract

We give a complete, gap-free determination of the domination number of the path graph $P_n$, the canonical infinite family of trees:

$$\gamma(P_n) = \left\lceil \frac{n}{3} \right\rceil = \left\lfloor \frac{n+2}{3} \right\rfloor.$$

Two developments are presented and reconciled. First, a self-contained *combinatorial* model on the natural numbers, in which dominating sets of the path are subsets $S \subseteq \{0,\dots,n-1\}$ such that every vertex lies within graph distance one of $S$; here the domination number $\gamma(P_n)$ is computed exactly via a counting lower bound ($n \le 3\,|S|$ for every dominating set $S$) and an explicit optimal construction. Second, a *genuine graph-theoretic* definition of the domination number for an arbitrary finite simple graph, together with a cardinality-preserving bridge proving that the domination number of the standard path graph coincides with the combinatorial quantity, hence equals $\lceil n/3\rceil$. The lower-bound argument is exactly the maximum-degree bound $\gamma(G) \ge n/(\Delta+1)$ specialized to $\Delta = 2$, and is isolated as a reusable kernel. We then situate this result inside a research program: ordinary zero forcing satisfies $Z(P_n) = 1$ for all $n$, so it is decisively separated from domination; we conjecture that a distance-throttled variant — the *transmission zero forcing number* $\xi_T$ — satisfies $\xi_T(T) = \gamma(T)$ for every tree $T$, with the path as the first milestone and the conjectured extremal case. We record five precise, testable conjectures that build directly on the verified material.

## 1. Introduction

Domination is among the most studied invariants in graph theory. Given a finite simple graph $G = (V, E)$, a set $D \subseteq V$ is a **dominating set** if every vertex is either in $D$ or adjacent to a vertex of $D$. The **domination number** $\gamma(G)$ is the minimum cardinality of a dominating set. The notion models a recurring optimization principle — cover an entire structure using as few resources as possible — and arises in facility location, fault monitoring, sensor placement, and the analysis of influence in networks.

For the path graph $P_n$ on vertices $\{0, 1, \dots, n-1\}$ with edges between consecutive integers, the domination number is classically reported as $\lceil n/3 \rceil$. Our purpose is threefold:

1. To establish $\gamma(P_n) = \lceil n/3 \rceil$ with full rigor and no unexamined boundary cases, in a form whose individual components (a general definition of $\gamma$, a counting kernel, a construction template) are reusable for other tree families.
2. To make precise the relationship — in fact, the sharp *non*-relationship — between domination and ordinary zero forcing on paths.
3. To articulate, with mathematical precision, a conjectural framework in which a *transmission-weighted* variant of zero forcing coincides with domination on the class of trees.

Throughout, $\lceil n/3 \rceil = \lfloor (n+2)/3 \rfloor$, and we freely use the natural-number identity $(n+2)/3$ (integer division) for $\lceil n/3 \rceil$.

## 2. A combinatorial model of domination on the path

We first work over the natural numbers, modeling the vertex set of $P_n$ as $\{0,1,\dots,n-1\}$ and the adjacency-or-equality (closed neighborhood) relation as "distance at most one."

**Definition 2.1 (Dominating set of the path).** For $n \in \mathbb{N}$ and a finite set $S \subseteq \mathbb{N}$, we say $S$ *dominates* $P_n$, written $\mathrm{DominatesPath}\,n\,S$, when
$$S \subseteq \{0, \dots, n-1\} \quad\text{and}\quad \forall i < n,\ \exists s \in S,\ (i \le s+1 \ \wedge\ s \le i+1).$$
The conjunction $i \le s+1 \wedge s \le i+1$ is precisely $|i - s| \le 1$ over the natural numbers, i.e. graph distance at most one in $P_n$. (Working with two linear inequalities rather than an absolute value keeps every metric obligation inside linear integer arithmetic.)

**Definition 2.2 (Combinatorial domination number).** The domination number of $P_n$ is
$$\gamma(P_n) := \inf\{\, k \in \mathbb{N} \mid \exists S,\ \mathrm{DominatesPath}\,n\,S \ \wedge\ |S| = k \,\}.$$
This infimum is over a nonempty set of natural numbers (Lemma 2.4 below) and is therefore attained.

**Definition 2.3 (Closed neighborhood block).** For $s \in \mathbb{N}$ let
$$\mathrm{block}(s) := \{s-1,\ s,\ s+1\} = [\,s-1,\ s+1\,] \cap \mathbb{N},$$
the closed neighborhood of vertex $s$ on the path. Over $\mathbb{N}$ this has cardinality at most $3$ (exactly $3$ for $s \ge 1$, and $2$ for $s = 0$).

**Lemma 2.4 (Existence of dominating sets).** The full vertex set dominates: $\mathrm{DominatesPath}\,n\,\{0,\dots,n-1\}$. In particular dominating sets exist, so $\gamma(P_n)$ is well-defined.

*Proof.* The full set is trivially a subset of itself, and each $i < n$ is dominated by $s = i$, since $i \le i+1$ and $i \le i+1$. $\square$

### 2.1 The counting lower bound

**Theorem 2.5 (Counting lower bound).** If $S$ dominates $P_n$, then
$$n \le 3\,|S|.$$

*Proof.* Let $S$ dominate $P_n$. We claim $\{0,\dots,n-1\} \subseteq \bigcup_{s \in S} \mathrm{block}(s)$. Indeed, for any $i < n$, domination yields some $s \in S$ with $|i-s| \le 1$, i.e. $i \in [s-1, s+1] = \mathrm{block}(s)$. Therefore
$$n = |\{0,\dots,n-1\}| \le \Big| \bigcup_{s \in S} \mathrm{block}(s) \Big| \le \sum_{s \in S} |\mathrm{block}(s)| \le \sum_{s \in S} 3 = 3\,|S|,$$
using monotonicity of cardinality, the union bound (subadditivity of cardinality over a finite union), and $|\mathrm{block}(s)| \le 3$. $\square$

**Remark 2.6 (The degree bound).** Theorem 2.5 is the specialization to $\Delta = 2$ of the universal bound
$$\gamma(G) \ge \frac{n}{\Delta + 1} \qquad (\text{equivalently } n \le (\Delta+1)\,|S|)$$
for any $n$-vertex graph $G$ of maximum degree $\Delta$, proved identically by replacing $\mathrm{block}(s)$ with the closed neighborhood $N[s]$ (of size $\le \Delta + 1$) and applying the union bound. We isolate Theorem 2.5 precisely because this argument is the reusable kernel for the general tree program (Conjecture C2).

### 2.2 The optimal construction

**Definition 2.7 (Guard construction).** Define
$$\mathrm{domConstruction}(n) := \big\{\, \min(3k+1,\ n-1) \ \big|\ k < \lceil n/3 \rceil \,\big\} = \mathrm{image}\big(k \mapsto \min(3k+1, n-1)\big)\big(\{0, \dots, \lceil n/3\rceil - 1\}\big).$$
Intuitively, place a guard near the center of each consecutive triple of vertices ($1, 4, 7, \dots$), clamping the last guard to the final vertex $n-1$ so it never falls off the end.

**Theorem 2.8 (The construction dominates).** $\mathrm{DominatesPath}\,n\,(\mathrm{domConstruction}(n))$.

*Proof.* Subset condition: every element is $\min(3k+1, n-1)$, which is $\le n-1 < n$, so the set lies in $\{0,\dots,n-1\}$. Domination: given $i < n$, take $k = \lfloor i/3 \rfloor$. Then $k < \lceil n/3 \rceil$ and the guard $s = \min(3k+1, n-1)$ satisfies $|i - s| \le 1$: writing $i = 3k + r$ with $r \in \{0,1,2\}$, the unclamped guard $3k+1$ is within distance one of $i$ in all three residue cases, and clamping to $n-1$ only moves the guard toward $i$ when $3k+1 \ge n$. Every such metric obligation is linear arithmetic. $\square$

**Theorem 2.9 (Cardinality of the construction).** $|\mathrm{domConstruction}(n)| \le \lceil n/3 \rceil$.

*Proof.* The set is the image of $\{0,\dots,\lceil n/3\rceil - 1\}$ under a function, and the cardinality of an image is at most the cardinality of the domain, which is $\lceil n/3\rceil$. (No injectivity analysis is needed: clamping may identify the last few guards, only lowering the count.) $\square$

### 2.3 The exact value

**Theorem 2.10 (Domination number of the path).** For all $n \in \mathbb{N}$,
$$\gamma(P_n) = \left\lceil \frac{n}{3} \right\rceil = \frac{n+2}{3} \ \text{(integer division)}.$$

*Proof.* Upper bound: by Theorems 2.8 and 2.9, $\mathrm{domConstruction}(n)$ is a dominating set of cardinality $\le \lceil n/3\rceil$, so by definition of the infimum $\gamma(P_n) \le \lceil n/3 \rceil$. Lower bound: $\gamma(P_n)$ is attained by some dominating set $S$ with $|S| = \gamma(P_n)$ (Lemma 2.4 and the well-ordering of $\mathbb{N}$); Theorem 2.5 gives $n \le 3\,|S| = 3\,\gamma(P_n)$, whence $\gamma(P_n) \ge \lceil n/3 \rceil$. Antisymmetry of $\le$ concludes. $\square$

## 3. The graph-theoretic domination number and the bridge

The combinatorial model is convenient but bespoke. We now give a definition valid for *any* finite simple graph and prove it agrees with Section 2 on the path.

**Definition 3.1 (Dominating set of a graph).** For a simple graph $G$ on vertex set $V$ and a finite set $D \subseteq V$, $D$ is a **dominating set**, $\mathrm{IsDominatingSet}\,G\,D$, when
$$\forall v \in V,\quad v \in D \ \vee\ \exists d \in D,\ G.\mathrm{Adj}\,d\,v.$$

**Definition 3.2 (Domination number).** For a finite graph $G$, $\gamma(G)$ is the least cardinality of a dominating set $D \subseteq V$. (Stated for general finite graphs so that stars, spiders, caterpillars, and arbitrary trees can reuse it.)

**Theorem 3.3 (Bridge to the standard path graph).** Let $\mathrm{pathGraph}\,n$ denote the standard path graph on $n$ vertices (vertices $0,\dots,n-1$, edges between consecutive integers). Then
$$\gamma(\mathrm{pathGraph}\,n) = \gamma(P_n) \quad \text{(combinatorial value of Definition 2.2)}.$$

*Proof sketch.* One transports dominating sets across the two encodings while preserving cardinality. A combinatorial dominating set $S \subseteq \{0,\dots,n-1\}$ is carried to a vertex set of $\mathrm{pathGraph}\,n$ by attaching the bound $i < n$ to each element; conversely a graph dominating set is carried back by forgetting the bound. Adjacency in $\mathrm{pathGraph}\,n$ is exactly $|i - j| = 1$, so closed-neighborhood membership ($v \in D$ or $v$ adjacent to $D$) matches the combinatorial distance-$\le 1$ condition. Both maps preserve cardinality, so the minimum cardinalities coincide. The only technical care needed is that projecting a bounded vertex to its underlying integer must be reduced explicitly before linear-arithmetic reasoning. $\square$

**Corollary 3.4 (Exact graph-theoretic value).** $\gamma(\mathrm{pathGraph}\,n) = \lceil n/3 \rceil = (n+2)/3.$

*Proof.* Combine Theorem 3.3 with Theorem 2.10. $\square$

## 4. Separation from zero forcing

**Definition 4.1 (Zero forcing).** Color each vertex of $G$ blue or white. The **color-change rule**: if a blue vertex has exactly one white neighbor, that neighbor becomes blue. A set $B \subseteq V$ is a **zero forcing set** if, starting with $B$ blue and all else white and applying the rule until no further change is possible, every vertex becomes blue. The **zero forcing number** $Z(G)$ is the minimum size of a zero forcing set.

**Proposition 4.2 (Zero forcing of the path).** $Z(P_n) = 1$ for every $n \ge 1$.

*Justification.* Color vertex $0$ blue. At each step the unique "frontier" blue vertex has exactly one white neighbor (the next vertex), which then turns blue; the blue region advances one vertex at a time until all of $P_n$ is blue. A single seed suffices, and at least one seed is necessary, so $Z(P_n) = 1$. $\square$

**Corollary 4.3 (Sharp separation).** For $n \ge 4$, $Z(P_n) = 1 < \lceil n/3 \rceil = \gamma(P_n)$, and the gap $\gamma(P_n) - Z(P_n) = \lceil n/3\rceil - 1 \to \infty$. Hence ordinary zero forcing cannot equal domination on paths.

This separation is confirmed by exhaustive enumeration over $P_1,\dots,P_9$ (Section 6): $Z = (1,1,1,1,1,1,1,1,1)$ while $\gamma = (1,1,1,2,2,2,3,3,3)$. The contrast motivates a *distance-throttled* variant.

## 5. The transmission zero forcing program

Ordinary zero forcing is unbounded in reach: a single seed can be transitively responsible for forcing arbitrarily distant vertices through a long chain of single-vertex forces. We propose to charge for distance.

**Definition 5.1 (Transmission zero forcing number, informal).** The **transmission zero forcing number** $\xi_T(G)$ is the minimum, over zero forcing sets $B$, of the number of *transmission-bounded* forces — equivalently, the minimum size of a set that simultaneously zero-forces $G$ and dominates it, i.e. a forcing process throttled so that each force covers graph distance at most one. Under this throttling the single-seed cascade on $P_n$ is forbidden, and the admissible sets coincide with dominating sets.

**Conjecture C3 (Headline: forcing equals domination on trees).** For every tree $T$,
$$\xi_T(T) = \gamma(T).$$
**First milestone:** $\xi_T(P_n) = \lceil n/3 \rceil$, to be proved by showing the throttled forcing sets of $P_n$ are exactly its dominating sets and invoking Theorem 2.10.

The remaining conjectures package the foreseeable next cycles; each builds on the verified material of Sections 2–3.

**Conjecture C1 (Stars and spiders).** For the star $K_{1,m}$ ($m \ge 1$), $\gamma(K_{1,m}) = 1$. For the spider $S(\ell,\dots,\ell)$ with $k$ legs each of length $\ell$, $\gamma = k\lfloor \ell/3\rfloor + c$ for an explicit center-adjustment $c \in \{0,1\}$. *Method:* encode stars/spiders as simple graphs, reuse Definition 3.2, and replay the counting-plus-construction template of Section 2.

**Conjecture C2 (Sharp degree bound).** For every $n$-vertex graph $G$ of maximum degree $\Delta$, $\gamma(G) \ge n/(\Delta+1)$, with equality characterized by efficient domination (a perfect code: closed neighborhoods of $D$ partition $V$). *Method:* Theorem 2.5 is the $\Delta = 2$ instance; the general case is $n \le (\Delta+1)|S|$ via the union bound over closed neighborhoods.

**Conjecture C4 (Path is extremal among trees).** Among all trees $T$ on $n$ vertices, $\gamma(T) \le \lceil n/3\rceil = \gamma(P_n)$, with equality iff $T$ is a "caterpillar of $P_3$'s" (a disjoint-block structure). *Method:* induction peeling a longest path; the counting bound lower-bounds $\gamma$ while a greedy construction upper-bounds it.

**Conjecture C5 (Tribonacci recurrence for the domination polynomial).** Let $d(P_n, k)$ be the number of dominating sets of $P_n$ of size $k$, and $D(P_n) = \sum_k d(P_n,k) x^k$ the domination polynomial. Then the counts obey
$$D(P_n) = D(P_{n-1}) + D(P_{n-2}) + D(P_{n-3})$$
(with suitable monomial weights), reflecting the size-$3$ closed neighborhood. *Method:* transfer-matrix / last-block case analysis.

## 6. Algorithms and computational evidence

Two algorithms underlie the experimental program.

**Algorithm A (Brute-force domination number).** Given $G$ on $n$ vertices, iterate over candidate set sizes $k = 0, 1, 2, \dots$; for each $k$, enumerate all $\binom{n}{k}$ subsets and test the domination predicate (every vertex in the set or adjacent to it). Return the first $k$ admitting a dominating set. Worst-case time $O\!\left(2^n \cdot n^2\right)$; correct by construction. Used to certify $\gamma(P_n)$ for small $n$ against the closed form.

**Algorithm B (Greedy/clamped path construction).** Realize $\mathrm{domConstruction}(n)$ directly: emit $\min(3k+1, n-1)$ for $k = 0,\dots,\lceil n/3\rceil - 1$ and deduplicate. Linear time $O(n)$; produces an optimal dominating set witnessing the upper bound of Theorem 2.10.

**Evidence.** Exhaustive enumeration over $P_1,\dots,P_9$ yields $\gamma(P_n) = 1,1,1,2,2,2,3,3,3$, matching $\lceil n/3\rceil$ exactly, while $Z(P_n) = 1$ throughout — the decisive separation of Corollary 4.3.

## 7. Discussion

The value $\gamma(P_n) = \lceil n/3\rceil$ is elementary, but the manner of its establishment yields durable infrastructure: a general definition of the domination number for finite graphs, a counting kernel that is the $\Delta = 2$ face of a universal degree bound, a construction template that needs only existence (not injectivity) of a small set, and a cardinality-preserving bridge between a computation-friendly natural-number model and a library-standard graph. Two modeling lessons proved decisive: (i) representing path vertices as natural numbers (with the bound $i < n$ as a side condition) keeps all metric reasoning inside linear integer arithmetic, whereas a bounded-index type entangles every step in wrap-around bookkeeping; and (ii) proving the value once in the easy model and *bridging* — rather than re-deriving in the hard model — is dramatically cleaner.

The conceptual payload is the sharp separation $Z(P_n) = 1$ versus $\gamma(P_n) = \lceil n/3\rceil$, which rules out any equality between ordinary zero forcing and domination and pinpoints distance-throttling as the necessary modification. Conjecture C3 — $\xi_T(T) = \gamma(T)$ for trees — is the organizing goal; the path result is both its first milestone and, via C4, its conjectured extremal anchor.

## 8. Future work

The immediate next cycle targets Conjecture C1 (stars and spiders) using the Section 2 template, and the first milestone of C3 ($\xi_T(P_n) = \lceil n/3\rceil$) by identifying throttled forcing sets with dominating sets on the path. Medium-term goals are C2 (the general sharp degree bound, a near-direct generalization of Theorem 2.5) and C5 (the tribonacci recurrence for the domination polynomial). The long-term summit is C4 (path extremality among trees) and the full headline equality C3 across all trees.

## References

Self-contained; all definitions, statements, and proof sketches appear inline above.
