# The Domination–Packing Ratio: Local Cover Engines, Geometric Bounds, and Extremal Families

**Author:** Aristotle
**Date:** 2026-08-20

## Abstract

For a finite simple graph $G$, the *domination number* $\gamma(G)$ is the least size of a vertex set meeting every radius-$1$ ball (closed neighbourhood) of $G$, and the *packing number* $\rho(G)$ is the largest number of pairwise disjoint radius-$1$ balls. Equivalently, $\gamma$ and $\rho$ are the transversal and matching numbers of the hypergraph of radius-$1$ balls, and $\rho(G) \le \gamma(G)$ always. We develop a self-contained theory of the reverse, Erdős–Pósa-type inequality $\gamma \le c\,\rho$.

Our central tool is a *local cover principle*: if every radius-$2$ neighbourhood of $G$ can be dominated by at most $c$ vertices, then $\gamma(G) \le c\,\rho(G)$. The principle is proved by observing that a maximum packing is maximal, hence its radius-$2$ neighbourhoods cover the graph. From it we derive $\gamma \le (\Delta+1)\rho$ for every finite graph of maximum degree $\Delta$, and a metric form: if $G$ is represented by points of a metric space $X$ with adjacency "distinct and at distance $\le 1$", and no ball of radius $2$ in $X$ contains more than $N$ points pairwise more than $1$ apart, then $\gamma \le N\rho$. A Haar-volume comparison gives the local packing bound $25$ for the plane and $5^n$ for $\mathbb{R}^n$, hence $\gamma \le 25\rho$ for every unit disk graph and $\gamma \le 5^n\rho$ for unit ball graphs in $\mathbb{R}^n$.

In dimension one we determine the local packing bound exactly: the line has local packing bound $4$ and not $3$, so the metric method yields $\gamma \le 4\rho$ for unit interval graphs and no better. The truth is sharper. We isolate an abstract *greedy dominator criterion* — for every nonempty vertex set $S$ some $u \in S$ has the part of its radius-$2$ neighbourhood inside $S$ contained in a single closed neighbourhood — and prove that this criterion alone forces $\gamma(G) = \rho(G)$. Interval graphs satisfy it via an earliest-endpoint sweep, and forests satisfy it via a deepest-vertex/parent rule, which recovers the classical theorem of Meir and Moon. The criterion is a genuine restriction: the $4$-cycle, a unit disk graph with $\gamma = 2$ and $\rho = 1$, fails it.

On the lower-bound side we show the constant cannot be small. The Wagner graph $V_8$ has $\rho = 1$ and $\gamma = 3$, and $k$ disjoint copies of it have $\rho = k$ and $\gamma = 3k$, so the ratio $3$ persists for arbitrarily large packing number and no bound of the form $\gamma \le c\rho + b$ holds with $c < 3$. Finally, over all finite graphs the ratio is unbounded: a "spread graph" built from a clique of $k$ indices and all $t$-subsets with $k < 2t$ has $\rho = 1$ and $\gamma \ge k - t + 1$, giving graphs with $\rho = 1$ and $\gamma \ge m$ for every $m$. Thus a restriction to a graph class is necessary, and geometry is exactly the structure that restores duality up to a constant.

**Keywords:** domination number, packing number, Erdős–Pósa duality, unit disk graphs, interval graphs, Meir–Moon theorem, Wagner graph, local packing bound.

---

## 1. Introduction

Domination and packing are the two sides of a covering duality. Fix a finite simple graph $G = (V,E)$ and, for $v \in V$, write
$$B(v) := \{v\} \cup \{u \in V : uv \in E\}$$
for the closed neighbourhood of $v$, which we call the **radius-$1$ ball** at $v$. Consider the hypergraph $\mathcal{B}(G) = \{B(v) : v \in V\}$ on $V$.

* A **dominating set** is a transversal of $\mathcal{B}(G)$: a set $D$ such that every $v \in V$ satisfies $v \in D$ or $v$ is adjacent to some $d \in D$. Its minimum size is $\gamma(G)$.
* A **packing** is a matching of $\mathcal{B}(G)$: a set $P$ with $B(p) \cap B(q) = \emptyset$ for distinct $p, q \in P$. Its maximum size is $\rho(G)$.

The general theory of transversal/matching duality asks how far a transversal number can exceed a matching number; a class of hypergraphs where the two are within a constant factor is said to have the *Erdős–Pósa property* with that constant. This paper studies the resulting invariant
$$\sup_{G \in \mathcal{C}} \frac{\gamma(G)}{\rho(G)}$$
over various graph classes $\mathcal{C}$, with particular attention to the geometric classes: unit disk graphs, unit ball graphs in $\mathbb{R}^n$, and interval graphs.

The results are organized as follows. Section 2 fixes definitions and proves the easy inequality $\rho \le \gamma$ and the distance characterization of packings. Section 3 proves the local cover principle and its degree corollary. Section 4 develops the metric form and the Euclidean local packing bounds, yielding $\gamma \le 25\rho$ for unit disk graphs. Section 5 treats dimension one, where the local packing bound $4$ is optimal but the truth is $\gamma = \rho$. Section 6 gives the abstract greedy criterion and the Meir–Moon theorem for forests. Section 7 constructs the extremal families: Wagner copies (ratio $3$ at every scale) and spread graphs (unbounded ratio in general). Section 8 records algorithms; Section 9 applications; Section 10 discussion and open problems.

Throughout, all graphs are finite and simple, and $\rho(G) \ge 1$ whenever $V \ne \emptyset$.

---

## 2. Definitions and the trivial duality

**Definition 2.1 (Ball, packing, packing number).** For $G$ on $V$ and $v \in V$, $B(v) = \{u : u = v \text{ or } uv \in E\}$. A finite set $P \subseteq V$ is a **packing** if $B(p) \cap B(q) = \emptyset$ for all distinct $p, q \in P$. The **packing number** is
$$\rho(G) = \max\{|P| : P \text{ is a packing}\}.$$

**Definition 2.2 (Dominating set, domination number).** $D \subseteq V$ is **dominating** if for all $v \in V$ either $v \in D$ or there is $d \in D$ with $dv \in E$. The **domination number** is $\gamma(G) = \min\{|D| : D \text{ dominating}\}$.

The empty set is a packing, and $V$ is dominating, so both quantities are well defined; for $V \ne \emptyset$ every singleton is a packing, so $\rho(G) \ge 1$.

**Lemma 2.3 (Balls meet iff distance $\le 2$).** For $u, v \in V$, $B(u) \cap B(v) \ne \emptyset$ if and only if $u = v$, or $uv \in E$, or there is $w$ with $uw, wv \in E$; that is, iff $\operatorname{dist}(u,v) \le 2$.

*Proof.* If $w \in B(u) \cap B(v)$ then each of $w = u$/$w \sim u$ and $w = v$/$w \sim v$ holds, and the four cases give distance $0$, $1$, $1$, $2$ respectively. Conversely, if $u = v$ take $w = u$; if $u \sim v$ take $w = v$; if $u \sim w \sim v$ take $w$. $\square$

**Corollary 2.4.** $P$ is a packing iff its elements are pairwise at distance at least $3$ (a *$2$-packing* in the classical terminology).

**Theorem 2.5 (Trivial duality).** For every finite graph $G$, $\rho(G) \le \gamma(G)$.

*Proof.* Let $P$ be a maximum packing and $D$ a minimum dominating set. For each $p \in P$ choose $f(p) \in D \cap B(p)$: such an element exists since $D$ dominates $p$, and either $p \in D$ (take $f(p) = p$) or some $d \in D$ is adjacent to $p$ (take $f(p) = d$; note $d \in B(p)$). Since the balls $B(p)$ are pairwise disjoint, $f$ is injective, so $|P| \le |D|$. $\square$

The whole content of the subject is the reverse inequality, and Section 7 shows it fails outright without hypotheses on $G$.

---

## 3. The local cover principle

**Lemma 3.1 (Maximum packings are maximal).** Let $P$ be a packing with $|P| = \rho(G)$. Then for every $v \in V$ there is $p \in P$ with $B(v) \cap B(p) \ne \emptyset$, i.e. $\operatorname{dist}(v, p) \le 2$.

*Proof.* Suppose not: $B(v)$ is disjoint from $B(p)$ for all $p \in P$. Then $v \notin P$ (balls are nonempty and $B(v) \cap B(v) \ne \emptyset$), and $P \cup \{v\}$ is again a packing, of size $\rho(G) + 1$, contradicting maximality. $\square$

**Theorem 3.2 (Local cover principle).** Let $c \in \mathbb{N}$ and suppose that for every $p \in V$ there exists $D_p \subseteq V$ with $|D_p| \le c$ such that every $u \in V$ with $\operatorname{dist}(u,p) \le 2$ lies in $\bigcup_{d \in D_p} B(d)$. Then
$$\gamma(G) \le c \cdot \rho(G).$$

*Proof.* Choose such a family $(D_p)_{p \in V}$ and take a packing $P$ with $|P| = \rho(G)$. Put $D := \bigcup_{p \in P} D_p$. Given $v \in V$, Lemma 3.1 supplies $p \in P$ with $\operatorname{dist}(v,p) \le 2$, hence $v$ is dominated by some element of $D_p \subseteq D$; so $D$ is dominating. Finally
$$|D| \le \sum_{p \in P} |D_p| \le c\,|P| = c\,\rho(G). \qquad \square$$

Two features deserve emphasis. First, the hypothesis is entirely *local*: it concerns the radius-$2$ neighbourhood of a single vertex, with no reference to packings. Second, the proof is constructive modulo the choice of a maximum packing: a maximal packing suffices, and maximal packings are computable greedily. Section 8 turns this into an algorithm.

**Corollary 3.3 (Degree bound).** For every finite graph $G$ with maximum degree $\Delta$,
$$\gamma(G) \le (\Delta+1)\,\rho(G).$$

*Proof.* Take $D_p := B(p)$, of size $\deg(p) + 1 \le \Delta + 1$. If $\operatorname{dist}(u,p) \le 2$ then there is $w \in B(u) \cap B(p)$ by Lemma 2.3; $w \in B(p) = D_p$ and $u \in B(w)$, so $u$ is dominated by $D_p$. $\square$

Corollary 3.3 already shows that the ratio is bounded on any class of bounded degree. Unit disk graphs are *not* of bounded degree (arbitrarily many points can be packed into a disk of radius $\tfrac12$, forming a clique), so a genuinely geometric argument is needed.

---

## 4. The metric form and Euclidean bounds

**Definition 4.1 (Unit distance representation).** Let $X$ be a metric space. A **metric representation** of $G$ in $X$ is a map $\mathrm{pos} : V \to X$ such that for all $u,v$,
$$uv \in E \iff u \ne v \text{ and } d(\mathrm{pos}(u), \mathrm{pos}(v)) \le 1 .$$
A **unit disk graph** is a graph with a metric representation in $\mathbb{R}^2$ (equivalently $\mathbb{C}$); a **unit ball graph in $\mathbb{R}^n$** one with a representation in Euclidean $\mathbb{R}^n$; a **unit interval graph** one with a representation in $\mathbb{R}$.

**Definition 4.2 (Local packing bound).** A metric space $X$ has **local packing bound** $N$ if for every $c \in X$ and every finite $T \subseteq X$ with $d(x,c) \le 2$ for all $x \in T$ and $d(x,y) > 1$ for all distinct $x,y \in T$, one has $|T| \le N$.

The two notions interact through a maximal independent set.

**Lemma 4.3 (Maximal independent subsets dominate).** For every finite $T \subseteq V$ there is $I \subseteq T$ that is independent in $G$ and dominates $T$: every $u \in T$ lies in $I$ or is adjacent to an element of $I$.

*Proof.* Take $I \subseteq T$ independent of maximum size. If some $u \in T$ were neither in $I$ nor adjacent to any element of $I$, then $I \cup \{u\}$ would be a larger independent subset of $T$. $\square$

**Theorem 4.4 (Local cover from a local packing bound).** Let $\mathrm{pos}$ be a metric representation of $G$ in $X$ and suppose $X$ has local packing bound $N$. Then for every $p \in V$ there is $D_p \subseteq V$ with $|D_p| \le N$ dominating $\{u : \operatorname{dist}_G(u,p) \le 2\}$.

*Proof.* Let $T := \{u \in V : \operatorname{dist}_G(u,p) \le 2\}$ and let $I \subseteq T$ be a maximal independent subset (Lemma 4.3); we show $|I| \le N$. If $\operatorname{dist}_G(u,p) \le 2$ then by Lemma 2.3 there is $w$ with $w \in B(u) \cap B(p)$, so $d(\mathrm{pos}(u),\mathrm{pos}(w)) \le 1$ and $d(\mathrm{pos}(w), \mathrm{pos}(p)) \le 1$ (an element of a ball is at distance $\le 1$ from its centre by Definition 4.1, with distance $0$ in the degenerate case), whence $d(\mathrm{pos}(u), \mathrm{pos}(p)) \le 2$ by the triangle inequality. Thus $\mathrm{pos}(I)$ lies in the ball of radius $2$ about $\mathrm{pos}(p)$. Distinct $u,v \in I$ are non-adjacent, so $d(\mathrm{pos}(u),\mathrm{pos}(v)) > 1$; in particular $\mathrm{pos}$ is injective on $I$ and $|\mathrm{pos}(I)| = |I|$. The local packing bound gives $|I| \le N$. $\square$

**Theorem 4.5 (Metric Erdős–Pósa bound).** If $G$ has a metric representation in a metric space $X$ with local packing bound $N$, then $\gamma(G) \le N\,\rho(G)$.

*Proof.* Combine Theorem 4.4 with Theorem 3.2. $\square$

It remains to compute local packing bounds. The following volume argument is entirely elementary.

**Proposition 4.6 (Volume comparison).** Let $X$ be a finite-dimensional normed space of dimension $n$ with Haar (Lebesgue) measure $\mu$, let $c \in X$, $r > 0$, $\delta > 0$, and let $T$ be a finite set of points within distance $r$ of $c$ that are pairwise more than $\delta$ apart. Then
$$|T| \le \left(\frac{2r+\delta}{\delta}\right)^{n}.$$

*Proof.* The open balls $B(x, \delta/2)$, $x \in T$, are pairwise disjoint (two points of intersecting balls would be at distance $< \delta$) and all contained in $B(c, r + \delta/2)$. Comparing measures, $|T| \cdot \mu(B(0,\delta/2)) \le \mu(B(0, r + \delta/2))$, and Haar measure scales as $\mu(B(0,s)) = s^n \mu(B(0,1))$. Hence $|T| \le \big((r + \delta/2)/(\delta/2)\big)^n = ((2r+\delta)/\delta)^n$. $\square$

**Corollary 4.7 (Local packing bounds in Euclidean space).** The plane has local packing bound $25$, and $\mathbb{R}^n$ has local packing bound $5^n$.

*Proof.* Apply Proposition 4.6 with $r = 2$, $\delta = 1$: $((2\cdot 2 + 1)/1)^n = 5^n$, which is $25$ for $n = 2$. $\square$

**Theorem 4.8 (Unit disk graphs).** For every unit disk graph $G$,
$$\gamma(G) \le 25\,\rho(G),$$
and for every unit ball graph $G$ in $\mathbb{R}^n$, $\gamma(G) \le 5^n\,\rho(G)$.

*Proof.* Theorem 4.5 with Corollary 4.7. $\square$

**Corollary 4.9 (Erdős–Pósa form).** For every unit disk graph $G$ and every $k$: either $G$ contains $k$ pairwise disjoint radius-$1$ balls, or there is a set of at most $25(k-1)$ vertices meeting all radius-$1$ balls. Equivalently, some dominating set has at most $25\,\rho(G)$ vertices.

*Proof.* If $\rho(G) < k$ then $\rho(G) \le k-1$ and Theorem 4.8 provides a dominating set of size $\le 25(k-1)$, which by definition meets every radius-$1$ ball. $\square$

The constant $25$ is not optimal; the literature on this problem has driven the unit disk constant to $18\sqrt3/\pi \approx 9.924$ and the planar constant to $5$, by finer arguments that do not go through a single crude volume count. What Theorem 4.8 provides is a bound of the correct shape from a completely elementary geometric input. Section 10 discusses the precise finite geometry question that would improve it.

---

## 5. Dimension one: the sharp local packing bound and the true answer

**Theorem 5.1 (The line has local packing bound $4$).** If $T \subseteq \mathbb{R}$ is finite, every element of $T$ is within distance $2$ of some fixed $c$, and the elements are pairwise more than $1$ apart, then $|T| \le 4$.

*Proof.* Every $x \in T$ lies in $[c-2, c+2]$, an interval of length $4$. Define $f(x) := \min\big(\lfloor x - (c-2)\rfloor, 3\big) \in \{0,1,2,3\}$. If $x < y$ in $T$ then $y - x > 1$, so $\lfloor y - (c-2)\rfloor \ge \lfloor x - (c-2)\rfloor + 1$ unless both are clipped at $3$; clipping happens only for $x - (c-2) \ge 3$, i.e. $x \ge c+1$, and two such points would be more than $1$ apart inside $[c+1, c+2]$, which is impossible for three of them. A direct check shows $f$ is injective on $T$; since $f$ takes at most four values, $|T| \le 4$. $\square$

**Proposition 5.2 (Optimality of $4$).** The line does not have local packing bound $3$: the four points $0, \tfrac{11}{10}, \tfrac{11}{5}, \tfrac{33}{10}$ lie within distance $2$ of the point $2$ and are pairwise more than $1$ apart.

*Proof.* Distances to $2$ are $2, \tfrac9{10}, \tfrac15, \tfrac{13}{10}$, all $\le 2$; consecutive gaps are $\tfrac{11}{10} > 1$, and non-consecutive gaps are larger. $\square$

**Corollary 5.3.** For every unit interval graph $G$, $\gamma(G) \le 4\rho(G)$, and this is the best bound obtainable from the metric method.

The true one-dimensional answer is much stronger and holds for all interval graphs, not merely unit interval graphs.

**Definition 5.4 (Interval representation).** An **interval representation** of $G$ assigns to each $v \in V$ a nonempty closed interval $[\ell(v), r(v)]$ such that distinct $u,v$ are adjacent iff their intervals meet, i.e. $\ell(u) \le r(v)$ and $\ell(v) \le r(u)$. A graph with such a representation is an **interval graph**.

**Lemma 5.5.** In an interval representation, $w \in B(u)$ iff $\ell(w) \le r(u)$ and $\ell(u) \le r(w)$.

*Proof.* For $w = u$ this is $\ell(u) \le r(u)$, true. For $w \ne u$ it is the adjacency condition. $\square$

**Theorem 5.6 (Interval greedy).** Let $G$ have an interval representation. Then for every finite $S \subseteq V$ there are $P \subseteq S$ and $D \subseteq V$ with $P$ a packing, $|D| \le |P|$, and $D$ dominating every vertex of $S$.

*Proof.* Induct on $|S|$; the case $S = \emptyset$ is trivial. Otherwise let $u \in S$ minimize $r(u)$, and let
$$N := \{x \in V : \ell(x) \le r(u) \text{ and } \ell(u) \le r(x)\} = B(u) \ne \emptyset,$$
and let $d \in N$ maximize $r(d)$. Set $S' := \{s \in S : s \notin B(d)\}$ and apply the induction hypothesis to $S'$ — which is a proper subset, since $u \in B(d)$ (as $d \in B(u)$ and balls are symmetric in this sense) — obtaining $P'$, $D'$. Put $P := \{u\} \cup P'$, $D := \{d\} \cup D'$.

$D$ dominates $S$: a vertex of $S \setminus S'$ is in $B(d)$; a vertex of $S'$ is dominated by $D'$.

$|D| \le |P|$ follows from $|D'| \le |P'|$ once $u \notin P'$, which holds because $P' \subseteq S'$ and $u \notin S'$.

$P$ is a packing: it suffices to show $B(u) \cap B(q) = \emptyset$ for $q \in P' \subseteq S'$. Since $q \notin B(d)$, Lemma 5.5 gives $\ell(q) > r(d)$ or $\ell(d) > r(q)$. In the second case $q$ would end before $d$ starts, but $r(u) \le r(q)$ by minimality of $r(u)$ over $S$ and $\ell(d) \le r(u)$ since $d \in B(u)$ — a contradiction. Hence $\ell(q) > r(d) \ge r(x)$ for every $x \in B(u)$ (by maximality of $r(d)$ over $N = B(u)$). So no $x \in B(u)$ can meet $q$'s interval, and by Lemma 5.5 $B(u) \cap B(q) = \emptyset$. $\square$

**Theorem 5.7 (Interval graphs).** For every finite interval graph $G$, $\gamma(G) = \rho(G)$.

*Proof.* Apply Theorem 5.6 with $S = V$: it yields a dominating set $D$ and a packing $P$ with $|D| \le |P| \le \rho(G)$, so $\gamma(G) \le \rho(G)$. Combine with Theorem 2.5. $\square$

**Corollary 5.8 (Unit interval graphs).** For every unit interval graph $G$, $\gamma(G) = \rho(G)$.

*Proof.* A metric representation in $\mathbb{R}$ becomes an interval representation by $\ell(v) := \mathrm{pos}(v) - \tfrac12$, $r(v) := \mathrm{pos}(v) + \tfrac12$: the intervals $[\mathrm{pos}(u) \pm \tfrac12]$ and $[\mathrm{pos}(v) \pm \tfrac12]$ meet iff $|\mathrm{pos}(u)-\mathrm{pos}(v)| \le 1$. Apply Theorem 5.7. $\square$

**Example 5.9 (Paths).** For the path $P_n$ on vertices $0,\dots,n-1$,
$$\gamma(P_n) = \rho(P_n) = \left\lceil \frac n3 \right\rceil = \left\lfloor \frac{n+2}{3}\right\rfloor .$$
Indeed $P_n$ is a unit interval graph (place vertex $i$ at $i \in \mathbb{R}$), so $\gamma = \rho$ by Corollary 5.8; and the set $\{i : i \equiv 0 \pmod 3\}$ is a packing, since $B(i) = \{i-1,i,i+1\}$ and these are pairwise disjoint for indices differing by at least $3$, so $\rho(P_n) \ge \lfloor (n+2)/3\rfloor$, with the matching upper bound coming from $\gamma(P_n) = \lfloor (n+2)/3 \rfloor$.

Thus the domination–packing ratio is exactly $1$ in dimension one, and the interesting behaviour of the ratio (at least $2$ from below and at most $25$ from above for unit disk graphs) is a genuinely two-dimensional phenomenon.

---

## 6. An abstract greedy criterion and the Meir–Moon theorem

The interval sweep of Theorem 5.6 uses only one structural fact, which we now isolate.

**Definition 6.1 (Greedy cover, greedy dominator).** Let $c \in \mathbb{N}$. A graph $G$ **has a greedy cover with constant $c$** if for every nonempty finite $S \subseteq V$ there are $u \in S$ and $D \subseteq V$ with $|D| \le c$ such that every $s \in S$ with $B(u) \cap B(s) \ne \emptyset$ is dominated by $D$. It **has a greedy dominator** if the case $c = 1$ holds with $D$ a single closed neighbourhood: for every nonempty finite $S$ there are $u \in S$ and $d \in V$ such that every $s \in S$ with $B(u) \cap B(s) \ne \emptyset$ lies in $B(d)$.

**Theorem 6.2 (Greedy engine).** If $G$ has a greedy cover with constant $c$, then for every finite $S \subseteq V$ there are a packing $P \subseteq S$ and a set $D$ with $|D| \le c\,|P|$ dominating $S$. Consequently $\gamma(G) \le c\,\rho(G)$.

*Proof.* Induct on $|S|$. For $S = \emptyset$ take $P = D = \emptyset$. Otherwise take $u \in S$ and $D_u$ with $|D_u| \le c$ as in Definition 6.1, and put $S' := \{s \in S : s \text{ not dominated by } D_u\}$. Since $B(u) \cap B(u) \ne \emptyset$, $u$ is dominated by $D_u$, so $S' \subsetneq S$; apply induction to get $P', D'$. Set $P := \{u\} \cup P'$, $D := D_u \cup D'$. Then $D$ dominates $S$, and $|D| \le c + c|P'| = c|P|$ provided $u \notin P'$, which holds as $P' \subseteq S'$ and $u \notin S'$. Finally $P$ is a packing: for $q \in P' \subseteq S'$, $q$ is not dominated by $D_u$, hence by the defining property of $u$, $B(u) \cap B(q) = \emptyset$. Applying this to $S = V$ gives a dominating set of size $\le c\rho(G)$. $\square$

**Theorem 6.3 (Collapse theorem).** If $G$ has a greedy dominator, then $\gamma(G) = \rho(G)$.

*Proof.* A greedy dominator is a greedy cover with $c = 1$ (take $D := \{d\}$; every $s \in B(d)$ is dominated by $d$). Theorem 6.2 gives $\gamma \le \rho$, and Theorem 2.5 gives the converse. $\square$

**Theorem 6.4 (Interval graphs have a greedy dominator).** Every interval graph has a greedy dominator.

*Proof.* Given nonempty finite $S$, take $u \in S$ minimizing $r(u)$, let $N = B(u)$ and let $d \in N$ maximize $r(d)$. Let $s \in S$ with $B(u) \cap B(s) \ne \emptyset$, say $w \in B(u) \cap B(s)$. Then $w \in N$, so $r(w) \le r(d)$; from $w \in B(s)$ we get $\ell(s) \le r(w) \le r(d)$; from $d \in B(u)$ we get $\ell(d) \le r(u)$, and $r(u) \le r(s)$ by minimality, so $\ell(d) \le r(s)$. By Lemma 5.5, $s \in B(d)$. $\square$

This re-derives Theorem 5.7 from the abstract engine. The second, more substantial instance is the acyclic case.

**Theorem 6.5 (Forests have a greedy dominator).** Every finite forest has a greedy dominator.

*Proof.* Let $S$ be nonempty and pick $r \in S$. Let $C := \{x \in S : x \text{ reachable from } r\}$, a nonempty subset, and let $u \in C$ maximize the depth $\operatorname{dist}(r, u)$. Let $d$ be the parent of $u$ — a neighbour of $u$ at depth $\operatorname{dist}(r,u) - 1$ — if $u \ne r$, and $d := u$ otherwise.

Two structural facts about acyclic graphs are used.

1. *Adjacent vertices have different depths.* If $x \sim y$ with $\operatorname{dist}(r,x) = \operatorname{dist}(r,y)$, then two geodesics from $r$ together with the edge $xy$ produce a cycle.
2. *A vertex has at most one parent.* If $x \sim y$ and $x' \sim y$ with $\operatorname{dist}(r,x) = \operatorname{dist}(r,x') = \operatorname{dist}(r,y) - 1$ and $x \ne x'$, then geodesics from $r$ to $x$ and $x'$ plus the two edges close a cycle.

Now let $s \in S$ with $B(u) \cap B(s) \ne \emptyset$. Since balls of vertices in different components are disjoint, $s$ is reachable from $r$, hence $s \in C$ and $\operatorname{dist}(r,s) \le \operatorname{dist}(r,u)$ by maximality of $u$. If $s = u$ then $s \in B(d)$ since $d \in B(u)$ and adjacency is symmetric. If $s \sim u$ then by (1) $s$ has depth $\operatorname{dist}(r,u) \pm 1$, and depth $+1$ is excluded by maximality, so $s$ is a parent of $u$, hence $s = d$ by (2). If $\operatorname{dist}(u,s) = 2$, take a common neighbour $z$ of $u$ and $s$. Either $z = d$, in which case $s \in B(d)$ directly; or $z$ is a child of $u$ (depth $\operatorname{dist}(r,u)+1$ by (1) and the fact that $d$ is the unique parent), and then $s$, being adjacent to $z$ with depth $\le \operatorname{dist}(r,u)$, must be a parent of $z$, hence $s = u$ by (2), and again $s \in B(d)$. $\square$

**Theorem 6.6 (Meir–Moon).** For every finite forest $F$, $\gamma(F) = \rho(F)$. In particular $\gamma(T) = \rho(T)$ for every finite tree $T$.

*Proof.* Theorems 6.5 and 6.3. $\square$

Forests are genuinely more general than interval graphs (a subdivided claw is a tree but not an interval graph), so Theorem 6.5 is not subsumed by Theorem 6.4; conversely interval graphs contain arbitrarily large cliques. The abstract criterion covers both.

**Proposition 6.7 (The criterion is a genuine restriction).** The $4$-cycle $C_4$ does not have a greedy dominator.

*Proof.* In $C_4$ every two closed neighbourhoods meet (each has $3$ of the $4$ vertices), so $\rho(C_4) = 1$; and no single vertex dominates $C_4$ (its closed neighbourhood misses the antipodal vertex), while any two adjacent vertices do, so $\gamma(C_4) = 2$. If $C_4$ had a greedy dominator, Theorem 6.3 would force $2 = 1$. $\square$

**Corollary 6.8.** $C_4$ is not a forest — a consistency check of the Meir–Moon theorem against a small extremal example.

$C_4$ is a unit disk graph: place its vertices at $(0,0)$, $(\tfrac45, 0)$, $(\tfrac45, \tfrac{21}{25})$, $(0, \tfrac{21}{25})$. The four side lengths are $\tfrac45$ and $\tfrac{21}{25}$, both $\le 1$, while the diagonals have length $\sqrt{(4/5)^2 + (21/25)^2} = \sqrt{400/625 + 441/625} = \sqrt{841/625} = \tfrac{29}{25} > 1$. Hence:

**Corollary 6.9 (Lower bound for unit disk graphs).** $\sup \gamma/\rho \ge 2$ over unit disk graphs.

---

## 7. Extremal families

### 7.1 The Wagner graph and the persistence of the ratio $3$

**Definition 7.1.** The **Wagner graph** $V_8$ (Möbius ladder $M_4$) has vertex set $\mathbb{Z}/8$, with $i \sim i+1$ (the $8$-cycle) and $i \sim i+4$ (the four main diagonals). It is $3$-regular on $8$ vertices.

**Proposition 7.2.** $\rho(V_8) = 1$ and $\gamma(V_8) = 3$, so $\gamma(V_8) = 3\rho(V_8)$.

*Proof (sketch).* Each closed neighbourhood is $B(i) = \{i-1,i,i+1,i+4\}$, of size $4$ out of $8$. A finite check over the $28$ unordered pairs shows every two of these sets intersect: for $|i-j| \in \{1,2,3,4\}$ modulo $8$ one exhibits a common element (for instance $B(0) \cap B(2) = \{1\}$, $B(0) \cap B(3) = \{4\}$, $B(0)\cap B(4) = \{0,4\}$). Hence $\rho = 1$. For domination, $\{0,1,2\}$ dominates: $B(0)\cup B(1)\cup B(2) = \{7,0,1,4\}\cup\{0,1,2,5\}\cup\{1,2,3,6\}$ is all of $\mathbb{Z}/8$. No two vertices dominate, since $|B(i) \cup B(j)| \le 8$ with equality only if $B(i)$ and $B(j)$ are disjoint, which never happens. Hence $\gamma = 3$. $\square$

A single small graph does not preclude $\gamma \le \rho + O(1)$ or $\gamma \le c\rho$ with $c < 3$ asymptotically. The disjoint-union family settles this.

**Definition 7.3.** For $k \in \mathbb{N}$, let $W_k$ denote $k$ disjoint copies of $V_8$: vertex set $\{1,\dots,k\}\times \mathbb{Z}/8$ with $(i,a) \sim (j,b)$ iff $i = j$ and $a \sim b$ in $V_8$.

**Lemma 7.4.** Every vertex of $B_{W_k}(i,a)$ has first coordinate $i$.

*Proof.* Immediate from the definition of adjacency. $\square$

**Theorem 7.5.** $\rho(W_k) = k$.

*Proof.* *Upper bound.* Let $P$ be a packing. If $(i,a), (i,b) \in P$ with $a \ne b$, then since $B_{V_8}(a) \cap B_{V_8}(b) \ne \emptyset$ (Proposition 7.2), picking $w$ in the intersection gives $(i,w) \in B(i,a) \cap B(i,b)$, contradicting disjointness. So the projection to the first coordinate is injective on $P$ and $|P| \le k$.

*Lower bound.* $P := \{(i, 0) : 1 \le i \le k\}$ is a packing of size $k$: balls of vertices in different copies are disjoint by Lemma 7.4. $\square$

**Theorem 7.6.** $\gamma(W_k) = 3k$.

*Proof.* *Upper bound.* $\{1,\dots,k\} \times \{0,1,2\}$ dominates, by Proposition 7.2 applied in each copy, and has $3k$ elements.

*Lower bound.* Let $D$ be a dominating set and let $D_i := \{x \in D : x_1 = i\}$ be its fibres, so $|D| = \sum_{i=1}^k |D_i|$. Fix $i$; we claim the projection $\pi(D_i) \subseteq \mathbb{Z}/8$ dominates $V_8$. Indeed, given $a \in \mathbb{Z}/8$, the vertex $(i,a)$ is dominated by some $x \in D$; by Lemma 7.4, $x_1 = i$, so $x \in D_i$ and $x_2 \in \pi(D_i)$ dominates $a$. Since $\gamma(V_8) = 3$, $|D_i| \ge |\pi(D_i)| \ge 3$, whence $|D| \ge 3k$. $\square$

**Corollary 7.7 (No constant below $3$).** For all constants $c, b$, if $\gamma(G) \le c\,\rho(G) + b$ holds for all $G$ in a class containing every $W_k$, then $c \ge 3$.

*Proof.* The hypothesis gives $3k \le ck + b$ for all $k$. If $c \le 2$ then at $k = b+1$ we get $3b+3 \le 2b+2+b = 3b + 2$, a contradiction. $\square$

Note that $V_8$ is not planar, so this family bounds the constant for graph classes containing it, while the $4$-cycle (Corollary 6.9) already forces the constant to be $\ge 2$ for unit disk graphs. The best known lower bound for both the planar and the unit disk constants is $3$.

### 7.2 Spread graphs: unbounded ratio in general

**Definition 7.8 (Spread graph).** For $k, t \in \mathbb{N}$ let $S_{k,t}$ have vertex set $[k] \sqcup \binom{[k]}{t}$ (indices and $t$-subsets), with: all indices pairwise adjacent; no two subsets adjacent; and $i \sim S$ iff $i \in S$.

**Lemma 7.9.** If $k < 2t$ then any two $t$-subsets of $[k]$ intersect.

*Proof.* $|S \cap T| = |S| + |T| - |S \cup T| \ge 2t - k > 0$. $\square$

**Theorem 7.10.** If $0 < k$, $0 < t$, and $k < 2t$, then $\rho(S_{k,t}) = 1$.

*Proof.* We show every two balls meet, so no packing of size $2$ exists, while singletons are packings. Two index-balls share any index. An index-ball $B(i)$ and a subset-ball $B(S)$ share any $j \in S$ (nonempty since $t > 0$): $j \in B(S)$ as $j \sim S$, and $j \in B(i)$ since indices form a clique. Two subset-balls $B(S), B(T)$ share any $j \in S \cap T$, nonempty by Lemma 7.9. $\square$

**Theorem 7.11.** If $0 < t \le k$ then $\gamma(S_{k,t}) \ge k - t + 1$.

*Proof.* Let $D$ be dominating, $A := \{i \in [k] : i \in D\}$ the indices it uses, and $F := \{S \in \binom{[k]}{t} : S \in D\}$ the subsets it uses. If $|A| \ge k-t+1$ we are done. Otherwise $|A^c| = k - |A| \ge t$, so we may choose subsets of $A^c$: for each of the $|A^c| - (t-1)$ elements $x$ of $A^c$ outside a fixed $(t-1)$-subset $E \subseteq A^c$, the set $S_x := E \cup \{x\}$ is a $t$-subset disjoint from $A$. Such an $S_x$ has no neighbour in $D$ (its neighbours are the indices in $S_x$, all outside $A$, and no subset is adjacent to it), so $S_x \in D$, i.e. $S_x \in F$. The sets $S_x$ are distinct, so $|F| \ge |A^c| - (t-1) = k - |A| - t + 1$. Since $A$ and $F$ contribute disjointly to $D$,
$$|D| \ge |A| + |F| \ge |A| + k - |A| - t + 1 = k - t + 1. \qquad \square$$

**Theorem 7.12 (Unboundedness).** For every $m \ge 1$ the graph $S_{2m, m+1}$ satisfies $\rho = 1$ and $\gamma \ge m$. Consequently $\sup \gamma/\rho = \infty$ over all finite graphs, and no bound $\gamma \le c\rho + b$ holds for all finite graphs.

*Proof.* Here $k = 2m < 2(m+1) = 2t$ and $0 < t = m+1 \le 2m = k$ for $m \ge 1$, so Theorems 7.10 and 7.11 give $\rho = 1$ and $\gamma \ge 2m - (m+1) + 1 = m$. Given $c, b$, take $m := c + b + 1$: then $c\rho + b = c + b < m \le \gamma$. $\square$

Theorem 7.12 is the reason the subject is about graph *classes*: it is geometry, not general graph theory, that produces a bounded ratio.

---

## 8. Algorithms

Three algorithms are implicit in the proofs.

**Algorithm A (Maximal packing / local cover).** Compute a maximal packing $P$ greedily: scan the vertices, adding $v$ to $P$ whenever $\operatorname{dist}(v,p) \ge 3$ for all $p$ already chosen. Then for each $p \in P$ compute a maximal independent subset $I_p$ of the radius-$2$ neighbourhood of $p$ and output $D = \bigcup_p I_p$. Correctness: maximality of $P$ makes the radius-$2$ neighbourhoods cover $V$ (Lemma 3.1 holds for maximal, not only maximum, packings), and maximality of $I_p$ makes it dominate its neighbourhood (Lemma 4.3). For geometric inputs Theorem 4.4 bounds $|I_p| \le N$, so $|D| \le N|P| \le N\rho(G)$: the output is a dominating set within a factor $N$ of optimal, together with a certificate $P$ of a matching lower bound. Complexity: $O(|V|^2)$ distance computations for the packing (or $O(|V| + |E|)$ per BFS), plus $O(\sum_p |T_p|^2)$ for the independent sets.

**Algorithm B (Interval sweep).** Sort the vertices by right endpoint. Repeatedly take the first undominated $u$, choose $d$ maximizing $r(d)$ among vertices whose interval meets $u$'s, output $d$ into $D$ and $u$ into $P$, and delete $B(d)$. This produces $|D| = |P|$, hence *simultaneously* an optimal dominating set and an optimal packing of an interval graph, certifying optimality of each by the other. Complexity $O(|V|\log|V|)$ after sorting, given the representation.

**Algorithm C (Forest sweep).** Root each component, sort by depth, and repeatedly take the deepest undominated vertex $u$, output its parent $d$ (or $u$ itself if $u$ is a root) into $D$ and $u$ into $P$, and delete $B(d)$. As in Algorithm B this yields $|D| = |P|$, certifying $\gamma(F) = \rho(F)$ constructively in $O(|V|)$ time after a BFS.

All three follow the same schema: *bank a packing centre, spend the dominators covering its radius-$2$ neighbourhood, recurse.* The size of the dominator set spent per banked centre is precisely the constant in the resulting bound.

---

## 9. Applications

**Wireless coverage with a certificate.** In a unit disk model of transmitters, Algorithm A returns a set of at most $25\rho$ relays covering all nodes, plus a set of $\rho$ mutually non-interfering nodes. The latter is a lower-bound certificate: no covering scheme can use fewer than $\rho$ relays. Thus the algorithm is a $25$-approximation whose approximation guarantee is certified per-instance, often far better than $25$.

**Facility location on the line and on trees.** Theorems 5.7 and 6.6 say that on interval and forest structures the LP-style duality is exact: the greedy sweep gives an optimal facility placement whose optimality is witnessed by an equal-size set of pairwise independent demand clusters. This is a min–max theorem with an $O(n\log n)$ constructive proof.

**Interference-aware scheduling.** A packing is a set of nodes that may transmit simultaneously with no shared receiver at distance $\le 1$. The inequality $\gamma \le N\rho$ says the cost of coverage never exceeds $N$ times the achievable parallelism — an operational statement about the trade-off between coverage cost and interference-free throughput.

**Degree-bounded networks.** Corollary 3.3 gives $\gamma \le (\Delta+1)\rho$ for every graph, which for sparse networks (small $\Delta$) is stronger than the geometric bounds and requires no embedding.

---

## 10. Discussion and future directions

The results assemble into a coherent picture.

| class | ratio $\gamma/\rho$ |
| --- | --- |
| all finite graphs | unbounded (Theorem 7.12) |
| maximum degree $\Delta$ | $\le \Delta + 1$ (Corollary 3.3) |
| forests, trees | $= 1$ (Theorem 6.6) |
| interval graphs, unit interval graphs, paths | $= 1$ (Theorem 5.7, Corollary 5.8) |
| unit interval graphs, by the metric method alone | $\le 4$, optimal for that method (Corollary 5.3, Proposition 5.2) |
| unit disk graphs | $\ge 2$ (Corollary 6.9); $\le 25$ (Theorem 4.8) |
| unit ball graphs in $\mathbb{R}^n$ | $\le 5^n$ (Theorem 4.8) |
| classes containing all Wagner unions | $\ge 3$ (Corollary 7.7) |

Three structural observations. First, the entire geometric input to Theorem 4.8 is one finite number: the maximum size of a $1$-separated set in a ball of radius $2$. Everything else is soft. Second, in dimension one the two methods separate cleanly: the metric method saturates at $4$ (Proposition 5.2), while the greedy criterion delivers the exact answer $1$. This shows the local-cover route is intrinsically lossy on structured classes, and suggests looking for greedy dominators (or greedy covers with small $c$) rather than better local packing bounds where the class allows it. Third, the additive slack in $\gamma \le c\rho + b$ is worthless against a family whose ratio persists at every scale, which is exactly what the disjoint Wagner unions supply.

### Future directions

The following directions are stated so that each could be settled by a single precise theorem.

**Conjecture 1 — the unit disk constant can be pushed to $19$, and $19$ is optimal for this proof scheme.** A closed disk of radius $2$ in the plane contains at most $19$ points that are pairwise more than $1$ apart, and $19$ is attained — for instance by the centre, a ring of six points at radius $1.05$ (mutual distance $1.05$, distance $1.05$ to the centre), and a ring of twelve points at radius $2$ offset by $15°$ (mutual distance $4\sin(\pi/12) \approx 1.035$, distance $\approx 1.023$ to the inner ring); consequently the plane has local packing bound $19$ and $\gamma \le 19\rho$ for unit disk graphs, while no bound below $19$ follows from the maximal-independent-set-in-the-radius-$2$-ball argument. The key insight is that the whole geometric input of the engine is one finite packing number — the maximum number of $1$-separated points in a disk of radius $2$ — so improving the graph theorem is exactly a planar packing problem, and the crude volume count ($25$) is the only lossy step in the entire chain.

**Direction 2 — closing the gap to the literature.** The published bounds are $\gamma \le 5\rho$ for planar graphs and $\gamma \le (18\sqrt3/\pi)\rho \approx 9.924\rho$ for unit disk graphs, against a best known lower bound of $3$ in both cases. Reproducing the planar bound requires discharging or a structural decomposition rather than the volume count; reproducing the unit disk bound requires the hexagonal-density estimate. Both are natural next targets, and both would be materially strengthened by determining the exact optimal constants, which remain open.

**Direction 3 — a characterization of the collapse.** Which graphs have a greedy dominator? Interval graphs and forests do; $C_4$ does not. A structural characterization (perhaps in terms of forbidden induced subgraphs, or of a suitable elimination ordering) would explain in one statement all classes on which $\gamma = \rho$, and the quantitative version — which graphs have a greedy cover with constant $c$? — would interpolate towards the geometric bounds.

**Direction 4 — higher dimension and other metrics.** The bound $\gamma \le 5^n\rho$ in $\mathbb{R}^n$ is exponentially lossy; the true growth rate of the local packing bound of $\mathbb{R}^n$ (the maximum number of $1$-separated points in a radius-$2$ ball) is a classical sphere-packing quantity of order $c^n$ with $c$ strictly below $5$. Determining the optimal exponential rate, and the corresponding statement for $\ell_p$ metrics and for doubling metric spaces (where the local packing bound is a doubling constant), would give a general theory: *any doubling metric space yields an Erdős–Pósa duality with constant its local packing number.*

**Direction 5 — algorithmic optimality.** Algorithm A is a $25$-approximation for domination in unit disk graphs with a per-instance certificate. Is the certificate ratio $\rho$-versus-$\gamma$ tight for the algorithm — that is, are there unit disk instances on which the algorithm's output is a constant factor above $\gamma$ while $\rho$ is far below $\gamma$? Understanding the worst case of the *algorithm* (rather than of the ratio) would clarify whether local covering is a good approximation strategy or only a good proof technique.

---

## 11. Conclusion

Domination and packing are dual invariants whose gap measures how badly local covering can fail to be certified locally. Without hypotheses the gap is unbounded; with bounded degree it is at most $\Delta+1$; with a one-dimensional or acyclic structure it vanishes entirely; and with a Euclidean embedding it is bounded by a purely geometric constant — the maximum number of $1$-separated points in a ball of twice the adjacency radius. The lower bound side is equally structural: the ratio $3$ realized by the Wagner graph survives disjoint unions and therefore persists at every scale, so no Erdős–Pósa inequality with a constant below $3$ is available even with additive slack. What separates the classes is precisely the presence of a *greedy dominator*: a local rule that lets one vertex pay for the whole radius-$2$ neighbourhood of the next packing centre. Where such a rule exists, covering is exactly as expensive as packing is profitable.
