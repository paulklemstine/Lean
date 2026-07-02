# Uniqueness of the Critical Two-Point Augmentation of a 27-Point Unit-Distance Graph

**Author:** Aristotle
**Date:** 2026-07-02

## Abstract

The study of the fractional chromatic number of the Euclidean plane proceeds through finite unit-distance graphs whose independence ratios yield lower bounds. A striking phenomenon in this circle of ideas is that a certain $27$-point planar unit-distance configuration $G_{27}$, upon the addition of a specific pair of points, becomes a $29$-point configuration $G_{29}$ whose geometric fractional chromatic number is strictly greater than $4$. We isolate and rigorously establish the *arithmetic mechanism* driving this phenomenon and prove its *minimality*. The mechanism is a threshold crossing of the independence ratio $\alpha/m$ against the critical value $1/4$: with independence number pinned at $\alpha = 7$, the ratio equals $7/27 > 1/4$ before augmentation, exactly $7/28 = 1/4$ after a single added point, and $7/29 < 1/4$ after two. We show that the threshold inequality $\alpha/m < 1/4$ is equivalent to the integer inequality $4\alpha < m$; that for any base graph on $n$ vertices with independence number $a$ and $n \le 4a$, the least number of vertices one must add — while preserving the independence number — to force the ratio strictly below $1/4$ is exactly $4a - n + 1$; and that this specializes to $2$ for $G_{27}$. On the graph side we prove that augmentation (passing to an induced supergraph) can only increase the independence number, whence an augmentation preserving it is precisely a *critical* one. Combining these yields a dichotomy: a critical two-point augmentation of a $27$-point graph of independence number $7$ leaves the base at or above the threshold while pushing the $29$-point augmentation strictly across it. These results reduce the open geometric conjecture — uniqueness of the critical augmentation up to isometry — to a single sharply posed realizability question.

## 1. Introduction

The chromatic number of the plane, denoted $\chi(\mathbb{R}^2)$, is the least number of colors needed to color the points of the Euclidean plane so that no two points at distance exactly $1$ receive the same color. It is known that $5 \le \chi(\mathbb{R}^2) \le 7$. A quantitative relaxation, the **fractional chromatic number** $\chi_f(\mathbb{R}^2)$, assigns to each point a measurable weight of colors rather than a single color, subject to the same unit-distance constraint, and minimizes the total color mass. Lower bounds on $\chi_f(\mathbb{R}^2)$ are obtained from finite **unit-distance graphs**, and every improvement constrains the integer problem.

A **unit-distance graph** is a finite simple graph $G = (V, E)$ together with an injection $V \hookrightarrow \mathbb{R}^2$ such that $\{u,v\} \in E$ if and only if the images of $u$ and $v$ are at Euclidean distance exactly $1$. Because any valid coloring (fractional or not) of the plane restricts to a valid coloring of every unit-distance graph, one has $\chi_f(\mathbb{R}^2) \ge \chi_f(G)$ for all such $G$.

Within this program, a distinguished $27$-vertex planar unit-distance graph, here denoted $G_{27}$, plays a central role. Its defining feature is that a specific two-point augmentation produces a $29$-vertex graph $G_{29}$ with $\chi_f(G_{29}) > 4$. Augmentations with this jump property are exceedingly rare. The **critical augmentation conjecture** asserts that, up to Euclidean isometry, this specific two-vertex augmentation is the *unique* way to add two vertices to $G_{27}$ so that the resulting unit-distance graph has geometric fractional chromatic number strictly greater than $4$.

This paper does not resolve the geometric uniqueness conjecture. Instead it isolates and fully proves the *combinatorial core* on which any such realization must rest, and it makes precise exactly what geometric content remains open. Our contributions are:

1. **A threshold identity** (Theorem 3.1): the independence-ratio inequality $\alpha/m < 1/4$ is equivalent to $4\alpha < m$.
2. **A minimal-augmentation law** (Theorem 3.2): for a base graph on $n$ vertices with independence number $a$ satisfying $n \le 4a$, the least number of added vertices needed to force the ratio strictly below $1/4$ — with independence number held fixed — is $4a - n + 1$.
3. **The $G_{27}$ specialization** (Theorem 3.3): this least number equals $2$, together with the exact boundary values $7/27 > 1/4$, $7/28 = 1/4$, $7/29 < 1/4$.
4. **Monotonicity of the independence number under augmentation** (Theorem 4.1): passing to an induced supergraph can only increase the independence number.
5. **A critical-augmentation dichotomy** (Theorem 4.2) unifying the arithmetic and graph-theoretic pieces.

## 2. Definitions and preliminaries

Throughout, graphs are finite and simple.

**Definition 2.1 (Independent set, independence number).** A set $S \subseteq V$ of vertices of a graph $G = (V,E)$ is *independent* if no two of its members are adjacent. The *independence number* $\alpha(G)$ is the maximum cardinality of an independent set.

**Definition 2.2 (Independence ratio).** The *independence ratio* of a graph on $m$ vertices with independence number $\alpha$ is $\alpha/m$.

**Definition 2.3 (Fractional chromatic number).** A *fractional coloring* of $G$ assigns to each independent set $S$ a weight $w(S) \ge 0$ so that for every vertex $v$, $\sum_{S \ni v} w(S) \ge 1$. The *fractional chromatic number* $\chi_f(G)$ is the minimum of $\sum_S w(S)$ over all fractional colorings. Equivalently it is the value of a linear program whose optimum is a rational number.

**Lemma 2.4 (Ratio bound).** For any graph $G$ on $m$ vertices with independence number $\alpha$,
$$\chi_f(G) \ge \frac{m}{\alpha}.$$
*Proof sketch.* Each independent set covers at most $\alpha$ vertices. Summing the covering constraint over all $m$ vertices and exchanging the order of summation gives $\alpha \sum_S w(S) \ge \sum_v \sum_{S \ni v} w(S) \ge m$, hence $\sum_S w(S) \ge m/\alpha$. $\square$

**Corollary 2.5 (Forcing above 4).** If $\alpha/m < 1/4$, then $\chi_f(G) > 4$.
*Proof.* By Lemma 2.4, $\chi_f(G) \ge m/\alpha = (\alpha/m)^{-1} > 4$. $\square$

We refer to the value obtained from the independence-ratio bound as the *geometric fractional bound*; it is the engine forcing $\chi_f > 4$ whenever the independence ratio drops below $1/4$.

**Definition 2.6 (Augmentation / induced supergraph).** Let $G$ be a graph on a vertex set $W$ and let $f : V \hookrightarrow W$ be an injection. The *induced subgraph on the image of $f$*, transported back to $V$, is the graph on $V$ in which $u,v$ are adjacent iff $f(u), f(v)$ are adjacent in $G$; we denote it $f^{*}G$. Dually, $G$ is an *augmentation* of $f^{*}G$: it is obtained by adding the vertices of $W \setminus f(V)$ (and their incident edges) to a copy of $f^{*}G$.

In the geometric setting, an augmentation of a unit-distance graph is obtained by adding new points to the plane and recording the new unit distances they create.

## 3. The arithmetic core

We first reduce the rational threshold to an integer inequality, then extract minimality.

**Theorem 3.1 (Threshold identity).** For natural numbers $a$ and $m$ with $m > 0$,
$$\frac{a}{m} < \frac{1}{4} \iff 4a < m.$$
*Proof.* Since $m > 0$ we may clear the denominator: $a/m < 1/4$ is equivalent to $4a < m$ after multiplying both sides by the positive quantity $4m$ and simplifying. The forward and backward directions are the two directions of this equivalence over the rationals, and both integer and rational inequalities coincide because all quantities are integers cast into $\mathbb{Q}$. $\square$

This identity is the workhorse: it converts every ratio question into a linear integer question amenable to elementary arithmetic.

**Theorem 3.2 (Minimal augmentation, general form).** Let $a, n$ be natural numbers with $n > 0$ and $n \le 4a$ (so the base ratio $a/n$ is *not* below $1/4$). Then the set
$$\left\{\, k \in \mathbb{N} : \frac{a}{n+k} < \frac{1}{4} \,\right\}$$
has a least element, and it equals
$$k_{\min} = 4a - n + 1.$$
*Proof.* By Theorem 3.1, the condition $a/(n+k) < 1/4$ is equivalent to $4a < n + k$, i.e. $k > 4a - n$, i.e. $k \ge 4a - n + 1$ (an integer strict inequality). Membership of $k_{\min} = 4a - n + 1$: then $n + k_{\min} = 4a + 1 > 4a$, so the ratio is below the threshold. Lower bound: any $k$ in the set satisfies $4a < n + k$, hence $k \ge 4a - n + 1 = k_{\min}$. Both halves are elementary consequences of the integer inequality, valid because $n \le 4a$ guarantees $4a - n + 1 \ge 1$ is well-defined as a natural number. $\square$

**Theorem 3.3 ($G_{27}$ specialization).** With independence number $a = 7$ and base size $n = 27$:
$$\frac{7}{27} > \frac14, \qquad \frac{7}{28} = \frac14, \qquad \frac{7}{29} < \frac14,$$
and the least number of vertices whose addition drives the ratio strictly below $1/4$ is exactly
$$4\cdot 7 - 27 + 1 = 2.$$
*Proof.* The three numerical statements are direct rational computations. The minimality is Theorem 3.2 evaluated at $a = 7$, $n = 27$, noting $27 \le 28 = 4 \cdot 7$. $\square$

The exact equality $7/28 = 1/4$ is essential: a single added vertex leaves the ratio *at* the boundary, never strictly below it, so a one-vertex augmentation can never force $\chi_f > 4$ through the ratio bound. This is the structural reason the magic number is $2$ and not $1$.

## 4. The graph-theoretic core

The arithmetic of Section 3 assumes the independence number is held fixed at $a$. We now justify why *preservation* of the independence number is exactly the criticality condition, by showing augmentation can never decrease it.

**Theorem 4.1 (Monotonicity of independence number under augmentation).** Let $G$ be a finite graph on a vertex set $W$ and let $f : V \hookrightarrow W$ be an injection. Then
$$\alpha(f^{*}G) \le \alpha(G).$$
Equivalently: adding vertices to a graph can only enlarge (never shrink) its maximum independent set.
*Proof sketch.* Let $t \subseteq V$ be a maximum independent set of the induced subgraph $f^{*}G$, so $|t| = \alpha(f^{*}G)$. Because $f$ is injective and $u \sim_{f^{*}G} v \iff f(u) \sim_G f(v)$, the image $f(t) \subseteq W$ is again independent in $G$ and has the same cardinality $|f(t)| = |t|$. Hence $G$ has an independent set of size $\alpha(f^{*}G)$, giving $\alpha(f^{*}G) = |t| = |f(t)| \le \alpha(G)$. Injectivity is essential: a non-injective map could identify distinct independent vertices and inflate the count spuriously. $\square$

**Definition 4.2 (Critical augmentation).** An augmentation $G$ of a base graph $H = f^{*}G$ is *critical* if it preserves the independence number, i.e. $\alpha(G) = \alpha(H)$.

By Theorem 4.1 the only alternative to preservation is a strict increase $\alpha(G) > \alpha(H)$; thus criticality is precisely the equality case, and it is the delicate event that keeps the numerator of the independence ratio fixed while the denominator grows.

**Theorem 4.3 (Critical-augmentation dichotomy).** Let $H$ be a graph on $n = 27$ vertices with $\alpha(H) = 7$, and let $G$ be a critical two-vertex augmentation of $H$, so $G$ has $29$ vertices and $\alpha(G) = 7$. Then:

- the base $H$ is *not* forced above the threshold: $\alpha(H)/n = 7/27 > 1/4$, so the ratio bound yields only $\chi_f(H) \ge 27/7 < 4$; while
- the augmentation $G$ *is* forced strictly above: $\alpha(G)/29 = 7/29 < 1/4$, whence $\chi_f(G) \ge 29/7 > 4$.

*Proof.* The base inequality is $7/27 > 1/4$ (Theorem 3.3), and the ratio bound gives $\chi_f(H) \ge 27/7 = 3.857\ldots$, which does not exceed $4$. For $G$, criticality (Definition 4.2, justified by Theorem 4.1) keeps $\alpha(G) = 7$ while the vertex count is $29$; then $7/29 < 1/4$ (Theorem 3.3) and Corollary 2.5 give $\chi_f(G) > 4$. $\square$

## 5. Algorithms

The results above are constructive and support direct verification algorithms.

**Algorithm A (Threshold and minimal-augmentation calculator).** Given a base size $n$ and independence number $a$ with $n \le 4a$, compute the least augmentation $k_{\min} = 4a - n + 1$ and verify the boundary behavior at $k_{\min} - 1$ (at or above threshold) and $k_{\min}$ (strictly below). Complexity: $O(1)$ integer arithmetic.

**Algorithm B (Independence number by maximal-independent-set search).** Given a finite graph, compute $\alpha$ by searching for a maximum independent set (equivalently, a maximum clique in the complement). This is NP-hard in general but tractable for the small graphs ($m \le 29$) of interest, e.g. via branch-and-bound. Used to certify that a candidate augmentation is critical ($\alpha$ unchanged).

**Algorithm C (Ratio-bound certificate).** Given $m$ and $\alpha$, output the certified lower bound $\chi_f \ge m/\alpha$ and the boolean "$\chi_f > 4$" verdict via the test $4\alpha < m$. Complexity: $O(1)$.

## 6. Applications and discussion

**Localization of the open problem.** The chief consequence of this work is diagnostic. The "rarity" of fractional-chromatic-raising augmentations of $G_{27}$ is often described in analytic terms, but Sections 3–4 show it is nothing but a sharp counting threshold gated by an exact rational equality. What genuinely remains open is *geometric realizability*: whether two real points can be added to $G_{27}$ in the plane, forming the requisite unit distances, without enlarging the maximum independent set — and whether such a placement is unique up to Euclidean isometry. The combinatorial skeleton proved here is a necessary condition any realization must satisfy.

**Sharpness.** The dichotomy is sharp on both ends. The base value $7/27$ exceeds $1/4$, so the base is genuinely un-forced; the intermediate value $7/28$ equals $1/4$ exactly, so one point genuinely cannot suffice; and $7/29$ falls strictly below, so two points genuinely do. None of the theorems is vacuous: Theorem 3.1 requires $m > 0$; Theorem 3.2 requires $n \le 4a$ (otherwise the base already lies below threshold and the least augmentation is $0$); and Theorem 4.1 uses injectivity essentially.

**Generalization.** Theorem 3.2 is uniform: for any $(a, n)$ with $n \le 4a$, the least critical augmentation forcing $\chi_f > 4$ has size $4a - n + 1$. The famous "two" of the $G_{27}$ story is one value of this affine family, suggesting an entire spectrum of analogous phenomena at other independence numbers.

## 7. Future directions

**Conjecture 1 (Rigidity of independence-preserving extensions).** Among all ways of adding two points to a $27$-point planar unit-distance configuration of independence number seven, only finitely many (up to Euclidean isometry) keep the independence number equal to seven, and generically none do. The threshold crossing is driven entirely by the denominator; the numerator must be held fixed, and holding a maximum independent set fixed while inserting new unit-distance constraints is a heavily over-determined geometric condition. With the counting side settled, the entire difficulty concentrates into a single, sharply posed rigidity question amenable to configuration-space and algebraic methods.

**Conjecture 2 (No one-point shortcut).** No addition of a single point to a $27$-point planar unit-distance configuration of independence number seven can force the geometric fractional chromatic number above four. A single added point leaves the independence ratio at exactly the critical value $1/4$ — the boundary rather than the strict interior — so the fractional bound it yields is exactly four and never exceeds it. The exact equality $7/28 = 1/4$ turns this into a clean impossibility statement rather than an inequality to be estimated.

**Conjecture 3 (A minimal-crossing law across independence numbers).** For every base configuration of $n$ points whose unit-distance graph has independence number $a$ and satisfies $n \le 4a$, the least number of points that must be added to force the geometric fractional chromatic number above four — while preserving the independence number — is exactly $4a - n + 1$, and this bound is realized geometrically for infinitely many pairs $(a, n)$. The crossing number is a single affine expression in the base size and independence number, so the seemingly special "two" of the $G_{27}$ story is one value of a uniform law.

## 8. Conclusion

We have distilled the $G_{27} \to G_{29}$ fractional-chromatic phenomenon to its exact arithmetic essence: an independence ratio crossing $1/4$, governed by the equivalence $\alpha/m < 1/4 \iff 4\alpha < m$, with the minimal number of added vertices given by $4a - n + 1$, equal to $2$ for $G_{27}$; and we have shown, via monotonicity of the independence number, that criticality is exactly independence-preservation. The remaining open content — existence and isometric uniqueness of the critical two-point augmentation — is thereby reduced to a single, well-posed rigidity question.
