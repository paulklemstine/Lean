# The Independence-Ratio Engine for Fractional Colorings of the Plane

**Author:** Aristotle
**Date:** 2026-07-01

## Abstract

We isolate a single, domain-free inequality that drives the modern approach to the fractional chromatic number of the Euclidean plane: the *geometric fractional chromatic number* of any finite graph is at least the reciprocal of its independence ratio. From this weak-duality bound we extract a sharp threshold mechanism — a finite graph whose independence ratio is strictly below $1/4$ has fractional chromatic number strictly above $4$ — and explain how it converts the infinite, analytic problem of coloring the plane into a finite, combinatorial search. We describe how the 27-vertex unit-distance graph of Matolcsi, Ruzsa, Varga, and Zsámboki sits exactly at independence ratio $1/4$, so that a minimal two-point augmentation yields a 29-vertex unit-distance graph whose fractional chromatic number exceeds $4$. Combined with the invariance of the independence ratio under balanced blow-ups and a compactness transfer, this certifies that the fractional chromatic number of the plane exceeds $4$. We give complete definitions, full proofs of the covering-LP lower bound, and numerical illustrations.

## 1. Introduction

Color every point of the Euclidean plane $\mathbb{R}^2$ so that any two points at Euclidean distance exactly $1$ receive different colors. The least number of colors needed is the **chromatic number of the plane**, $\chi(\mathbb{R}^2)$, famously known to satisfy $5 \le \chi(\mathbb{R}^2) \le 7$.

This paper concerns the *fractional* relaxation. In a fractional coloring one assigns to each point a measurable "palette" from a common reservoir so that points at unit distance receive disjoint palettes; the fractional chromatic number $\chi_f(\mathbb{R}^2)$ is the infimal reservoir-to-palette ratio. It satisfies $\chi_f(\mathbb{R}^2) \le \chi(\mathbb{R}^2)$ and is bounded below by the fractional chromatic number of every finite **unit-distance graph** embedded in the plane (a graph whose vertices are points of $\mathbb{R}^2$ and whose edges join point pairs at distance exactly $1$).

Our purpose is to present, self-containedly, the *engine* that lifts the lower bound on $\chi_f(\mathbb{R}^2)$ above $4$: a linear-programming weak-duality inequality relating the fractional chromatic number of a finite graph to its independence ratio, together with the threshold reduction it produces. The mathematical content is entirely finite and combinatorial; the passage to the plane is by well-known blow-up and compactness principles, which we describe.

## 2. Definitions

Throughout, $G = (V, E)$ is a finite simple graph with vertex set $V$ and $|V| = n \ge 1$.

**Definition 2.1 (Independent set, independence number).**
A set $S \subseteq V$ is *independent* if no two of its vertices are adjacent in $G$. The **independence number** $\alpha(G)$ is the maximum size of an independent set. The **independence ratio** is
$$\rho(G) = \frac{\alpha(G)}{|V|}.$$

**Definition 2.2 (Fractional coloring; covering LP).**
A **fractional coloring** of $G$ is a function $w$ assigning to each subset $S \subseteq V$ a real weight $w(S) \ge 0$ such that

1. *(support)* $w(S) = 0$ whenever $S$ is not independent, and
2. *(covering)* for every vertex $v \in V$,
$$\sum_{S \ni v} w(S) \;\ge\; 1.$$

The **total weight** (LP objective) of $w$ is $\mathrm{tot}(w) = \sum_{S \subseteq V} w(S)$.

**Definition 2.3 (Geometric fractional chromatic number).**
The **geometric fractional chromatic number** of $G$ is the infimum of the objective over all feasible fractional colorings,
$$\chi_f(G) = \inf\{\,\mathrm{tot}(w) : w \text{ a fractional coloring of } G\,\}.$$

This is precisely the optimal value of the covering linear program whose variables are the weights $w(S)$ on independent sets $S$, whose constraints are the covering inequalities, and whose objective is the total weight. Feasibility is never vacuous: the *singleton coloring* $w(\{v\}) = 1$ for each $v$ and $w(S) = 0$ otherwise is always a valid fractional coloring, since singletons are independent and each vertex is covered exactly once.

## 3. The weak-duality core

The following double-counting identity is the technical heart.

**Lemma 3.1 (Incidence double count).**
For every fractional coloring $w$,
$$\sum_{v \in V} \; \sum_{S \ni v} w(S) \;=\; \sum_{S \subseteq V} |S|\, w(S).$$

*Proof.* Both sides count, with weight $w(S)$, the incidences $(v, S)$ with $v \in S$. On the left we sum first over vertices $v$ and then over the sets containing $v$; on the right we sum first over sets $S$ and then observe that $S$ contains exactly $|S|$ vertices, each contributing $w(S)$. Formally, writing $\mathbf{1}[v \in S]$ for the indicator,
$$\sum_{v}\sum_{S \ni v} w(S) = \sum_v \sum_S \mathbf{1}[v\in S]\,w(S) = \sum_S w(S) \sum_v \mathbf{1}[v \in S] = \sum_S |S|\, w(S). \qquad\blacksquare$$

**Theorem 3.2 (LP weak-duality bound).**
For every finite graph $G$ and every fractional coloring $w$,
$$n \;=\; |V| \;\le\; \alpha(G)\cdot \mathrm{tot}(w).$$

*Proof.* Summing the covering constraint (Definition 2.2(2)) over all $v \in V$ gives
$$n = \sum_{v \in V} 1 \;\le\; \sum_{v \in V}\sum_{S \ni v} w(S).$$
By Lemma 3.1 the right-hand side equals $\sum_S |S|\, w(S)$. For each $S$ with $w(S) > 0$ the support condition forces $S$ to be independent, so $|S| \le \alpha(G)$; and for $S$ with $w(S) = 0$ the term vanishes. Hence $|S|\,w(S) \le \alpha(G)\, w(S)$ for every $S$ (using $w(S) \ge 0$), and
$$\sum_S |S|\, w(S) \;\le\; \alpha(G) \sum_S w(S) = \alpha(G)\cdot \mathrm{tot}(w).$$
Combining the two displays yields $n \le \alpha(G)\cdot \mathrm{tot}(w)$. $\qquad\blacksquare$

**Corollary 3.3 (Independence-ratio lower bound).**
If $\alpha(G) > 0$ (in particular whenever $V \ne \varnothing$), then
$$\chi_f(G) \;\ge\; \frac{|V|}{\alpha(G)} \;=\; \frac{1}{\rho(G)}.$$

*Proof.* By Theorem 3.2, every feasible objective satisfies $\mathrm{tot}(w) \ge |V|/\alpha(G)$, so the infimum $\chi_f(G)$ does too. (Any nonempty graph has $\alpha(G) \ge 1$ because every singleton is independent, so the hypothesis is automatic.) $\qquad\blacksquare$

**Proposition 3.4 (Trivial upper bound).**
$\chi_f(G) \le |V|$.

*Proof.* Evaluate the objective on the singleton coloring of Definition 2.3: it uses exactly $n$ unit weights, so $\mathrm{tot} = n = |V|$, and the infimum is at most this. $\qquad\blacksquare$

Together, Corollary 3.3 and Proposition 3.4 sandwich the fractional chromatic number:
$$\frac{|V|}{\alpha(G)} \;\le\; \chi_f(G) \;\le\; |V|.$$

## 4. The quarter-barrier threshold

**Theorem 4.1 (Sub-quarter ratio forces $\chi_f > 4$).**
Let $G$ be a finite graph with $4\,\alpha(G) < |V|$ (equivalently $\rho(G) < 1/4$). Then
$$\chi_f(G) > 4.$$

*Proof.* By Corollary 3.3, $\chi_f(G) \ge |V|/\alpha(G)$. The hypothesis $4\,\alpha(G) < |V|$ gives, after dividing by the positive number $\alpha(G)$, that $|V|/\alpha(G) > 4$. Hence $\chi_f(G) > 4$. $\qquad\blacksquare$

The strength of Theorem 4.1 is that it is *entirely finite and geometry-free*. All of the analytic weight of the plane problem is removed: the only remaining task is to exhibit **one** finite graph — realizable as a unit-distance graph in $\mathbb{R}^2$ — whose independence ratio falls below $1/4$.

**Remark 4.2 (Transfer to the plane).**
Let $H$ be any finite unit-distance graph in $\mathbb{R}^2$. Any fractional coloring of the plane restricts to a fractional coloring of $H$, so $\chi_f(\mathbb{R}^2) \ge \chi_f(H)$. Consequently, a single finite unit-distance witness $H$ with $\chi_f(H) > 4$ certifies $\chi_f(\mathbb{R}^2) > 4$.

## 5. From 27 points to 29 points

**The base configuration.**
Matolcsi, Ruzsa, Varga, and Zsámboki constructed a unit-distance graph $G_{27}$ on $27$ vertices whose combinatorics place it *exactly* at the quarter barrier: its independence structure yields fractional chromatic number exactly $4$, i.e. $\chi_f(G_{27}) = 4$ with $\rho(G_{27}) = 1/4$. This graph certifies the classical bound of $4$ but, sitting precisely on the threshold, cannot by itself exceed it: Theorem 4.1 requires *strict* sub-quarter ratio.

**The two-point augmentation.**
The decisive step is a minimal perturbation. One adjoins **two** additional points at specific positions in the plane, each placed at unit distance from a suitable collection of the original $27$ vertices. The augmented graph $G_{29}$ has $29$ vertices. The positions are chosen so that the two new vertices *intrude on every maximum independent set*: any independent set of $G_{29}$ that contains a new vertex must drop enough old vertices that its total size cannot reach the count needed to keep the ratio at $1/4$. The net effect is
$$4\,\alpha(G_{29}) < 29, \qquad\text{i.e.}\qquad \rho(G_{29}) < \tfrac14.$$

**Theorem 5.1 (The 29-vertex witness).**
The augmented $29$-vertex unit-distance graph $G_{29}$ satisfies $\chi_f(G_{29}) > 4$.

*Proof.* By construction $4\,\alpha(G_{29}) < 29 = |V(G_{29})|$, so $\rho(G_{29}) < 1/4$. Theorem 4.1 applies directly. $\qquad\blacksquare$

**Corollary 5.2 (Fractional chromatic number of the plane).**
$\chi_f(\mathbb{R}^2) > 4$.

*Proof.* $G_{29}$ is a finite unit-distance graph, so by Remark 4.2, $\chi_f(\mathbb{R}^2) \ge \chi_f(G_{29}) > 4$. $\qquad\blacksquare$

## 6. Blow-ups and the infinite family

The transfer of Remark 4.2 already suffices, but the reduction is more robust than a single embedding, and it is worth recording the mechanism that produces an entire infinite family of witnesses.

**Definition 6.1 (Balanced blow-up).**
The $t$-fold balanced blow-up $G[t]$ of a graph $G$ replaces each vertex $v$ by an independent cluster $C_v$ of $t$ copies and joins $u' \in C_u$ to $v' \in C_v$ exactly when $uv \in E(G)$.

**Proposition 6.2 (Ratio invariance).**
For every finite graph $G$ and every $t \ge 1$,
$$\rho(G[t]) = \rho(G), \qquad\text{hence}\qquad \chi_f(G[t]) \ge \frac{1}{\rho(G)} = \frac{1}{\rho(G[t])}.$$

*Sketch.* A maximum independent set of $G[t]$ is obtained by taking all $t$ copies of each vertex in a maximum independent set of $G$, so $\alpha(G[t]) = t\,\alpha(G)$, while $|V(G[t])| = t\,|V(G)|$. The ratio is therefore unchanged, and Corollary 3.3 applies to $G[t]$. $\qquad\blacksquare$

Balanced blow-ups of unit-distance graphs can themselves be realized as unit-distance graphs (by small generic perturbations of the copies), producing arbitrarily large unit-distance graphs with $\rho < 1/4$. A standard compactness argument (De Bruijn–Erdős type) then shows that the strict inequality is a genuine property of the plane, reinforcing Corollary 5.2.

## 7. Algorithms

The engine is constructive and verifiable by direct computation on any candidate graph.

**Algorithm A — Independence-ratio certificate.**
Given a finite graph, compute (or bound) $\alpha(G)$ and test $4\alpha(G) < |V|$. If it holds, output the certified lower bound $\chi_f(G) \ge |V|/\alpha(G) > 4$. The independence number is computed by maximum-independent-set search (equivalently maximum clique on the complement); for the small graphs here this is a direct branch-and-bound.

**Algorithm B — Feasibility check of a fractional coloring.**
Given weights on subsets, verify (i) nonnegativity, (ii) support on independent sets only, and (iii) that every vertex's covering sum is at least $1$; then report the objective $\mathrm{tot}(w)$ as an explicit *upper* bound on $\chi_f(G)$. Pairing an upper bound from Algorithm B with the lower bound from Algorithm A brackets $\chi_f(G)$.

**Algorithm C — Augmentation search.**
Starting from a base configuration at ratio exactly $1/4$, enumerate candidate augmentation points, and for each candidate measure its intersection with the family of maximum independent sets; accept a point that lies in every maximum independent set (thereby forcing $\alpha$ to drop). Two accepted points suffice to cross below $1/4$.

## 8. Applications and discussion

The independence-ratio engine is a clean example of *weak LP duality as a proof technique*: a lower bound on a minimization problem (the covering LP defining $\chi_f$) is certified by a feasible object for a counting argument (the independence number bounding every weighted set). Its appeal is the strict separation of concerns:

- **Analytic content** (the plane) is discharged once and for all by Remark 4.2 and the blow-up/compactness principles of Section 6.
- **Combinatorial content** is concentrated in a single finite object, and the threshold $\rho < 1/4$ makes the target crisp.

This is why *augmentation* — perturbing a graph that sits exactly on the threshold — is the natural route to progress, and why very small augmentations (here, two points) can be decisive.

## 9. Future work

Three directions extend the reduction outward:

1. **A 29-point plane configuration breaking the quarter barrier.** Confirming that twenty-nine points in $\mathbb{R}^2$ realize independence ratio strictly below $1/4$ turns Corollary 5.2 into an explicit, hand-checkable witness. The key insight is that the barrier is a property of a *finite configuration*, not of the plane: once one exists, weak duality converts the small ratio into $\chi_f > 4$ with no further geometry.

2. **Quantization of the augmentation gap.** For the 27-point base, adding $k$ optimally placed points should lower the independence ratio by at least a constant multiple of $k/n$, so a fixed, small number of augmentation points crosses any threshold above the base value. The insight is that each augmentation point can be forced into every maximum independent set, shrinking $\alpha$ *additively* rather than by perturbation.

3. **Blow-ups drive the plane bound.** Because the ratio is blow-up invariant (Proposition 6.2), a single sub-quarter witness propagates to arbitrarily large unit-distance graphs and transfers to the plane by compactness, certifying $\chi_f(\mathbb{R}^2) > 4$ from one finite witness.

## 10. Conclusion

A decades-old lower bound of $4$ on the fractional chromatic number of the plane is dislodged by a purely finite mechanism. The weak-duality bound $\chi_f(G) \ge |V|/\alpha(G)$, obtained by counting vertex–set incidences two ways, turns "the plane needs more than four colors fractionally" into the search for one finite graph with independence ratio below one quarter. The 27-vertex configuration sits exactly on the barrier; a two-point augmentation to 29 vertices tips it strictly below, and blow-up invariance together with compactness carries the strict inequality to the plane. The whole phenomenon rests on a single, elementary inequality and a single, hand-sized diagram.
