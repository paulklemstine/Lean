# Edge-Spectral Supersaturation for Triangles via Trace Bridges

**Author:** Aristotle
**Date:** 2026-07-13

## Abstract

We prove an edge-spectral supersaturation bound for triangles in finite simple graphs, phrased entirely in terms of a graph's own combinatorial invariants. Let $G$ be a finite simple graph with $m$ edges and $t$ triangles, let $A$ be its real adjacency matrix, and let $\lambda$ be an eigenvalue of $A$ that dominates the spectrum in absolute value (the Perron–Frobenius eigenvalue for a genuine graph). Writing $q = \lambda^2 - m$ for the *spectral excess*, we establish
$$\lambda\, q \le 3t.$$
Two corollaries follow immediately: a $\sqrt{m}$-scaled form $\sqrt{m}\,q \le 3t$ valid whenever $q \ge 0$, matching the shape of the conjectured sharp bound $t \gtrsim q\sqrt{m}$ with explicit constant $\tfrac13$; and Nosal's inequality $\lambda^2 \le m$ for triangle-free graphs as the boundary case $t = 0$. The engine of the proof is a pair of **trace bridges** connecting linear algebra to extremal combinatorics: $\operatorname{tr}(A^2) = 2m$ and $\operatorname{tr}(A^3) = 6t$. The second, which converts a count of closed length-three walks into a triangle count, rests on the elementary fact that a three-element set admits exactly $3! = 6$ orderings. We combine these with a self-contained spectral supersaturation inequality derived from a single pointwise cubic estimate. We include a concrete certification on the complete graph $K_3$, where $\operatorname{tr}(A^2) = 6 = 2m$ and $\operatorname{tr}(A^3) = 6 = 6t$.

## 1. Introduction

Extremal graph theory studies how a global constraint on a graph forces the presence — indeed the *abundance* — of local substructures. The paradigm is **supersaturation**: once a graph exceeds the threshold at which a forbidden subgraph becomes unavoidable, that subgraph appears not once but in numbers growing with the excess. For triangles the classical thresholds are stated in terms of edge count (Turán, Rademacher) or in terms of the spectral radius (Nosal, Nikiforov).

This paper develops the *spectral* route in a form that keeps all quantities graph-intrinsic. The central object is the adjacency matrix $A = A(G)$, a real symmetric $n \times n$ matrix, and its eigenvalues, the graph's *spectrum*. Two features of the spectrum matter: the second and third **power sums** $\sum_i \mu_i^2$ and $\sum_i \mu_i^3$ equal, respectively, twice the edge count and six times the triangle count; and the largest eigenvalue $\lambda$ dominates the whole spectrum in modulus for a non-negative symmetric matrix.

Our main theorem states that a graph whose squared spectral radius $\lambda^2$ overshoots its edge count $m$ by an amount $q$ must contain at least $\tfrac13\lambda q$ triangles. This simultaneously encodes:

- a **supersaturation** phenomenon: triangles grow linearly in the spectral excess;
- **Nosal's inequality** as the degenerate case $t = 0$;
- the **shape** of the conjectured sharp bound $t \gtrsim q\sqrt{m}$.

The novelty is not merely the statement but the *self-contained derivation*: we make explicit the two trace bridges that link the spectral and combinatorial worlds, isolating the combinatorial heart — the $3! = 6$ ordering count of a triangle's corners — as a standalone lemma. This turns an apparently analytic theorem into an assembly of three elementary, independently verifiable components.

### 1.1 Contributions

1. **A spectral supersaturation inequality** for real symmetric matrices: if $\lambda = \mu_j$ dominates the spectrum in modulus, then $2\lambda^3 - \lambda\sum_i \mu_i^2 \le \sum_i \mu_i^3$ (Theorem 3.3).
2. **The edge bridge**: $\operatorname{tr}(A^2) = 2m$ (Theorem 4.1).
3. **The triangle bridge**: $\operatorname{tr}(A^3) = 6t$ (Theorem 4.3), the cross-domain connector, built on the ordering lemma (Theorem 4.2).
4. **Graph supersaturation**: $\lambda q \le 3t$ and its $\sqrt m$ form (Theorems 5.1 and 5.2).
5. **Nosal's inequality** as a corollary (Theorem 5.3).
6. **A concrete certification** on $K_3$ (Section 6).

## 2. Definitions and setup

Throughout, $V$ is a finite set of vertices, $|V| = n$, and $G$ is a **finite simple graph** on $V$: an irreflexive symmetric adjacency relation. We write $u \sim v$ for "$u$ is adjacent to $v$".

**Adjacency matrix.** The adjacency matrix $A = A(G)$ is the $n \times n$ real matrix with
$$A_{uv} = \begin{cases} 1 & \text{if } u \sim v,\\ 0 & \text{otherwise.}\end{cases}$$
Because $G$ is simple, $A$ is symmetric with zero diagonal; in particular $A$ is a real symmetric (Hermitian) matrix, hence diagonalizable with real eigenvalues.

**Spectrum.** Let $\mu_1, \dots, \mu_n \in \mathbb{R}$ denote the eigenvalues of $A$ listed with multiplicity. We single out a distinguished eigenvalue $\lambda = \mu_j$ and impose the **spectral-domination hypothesis**
$$|\mu_i| \le \lambda \quad\text{for all } i.$$
For the adjacency matrix of a genuine graph this holds with $\lambda$ the Perron–Frobenius (largest) eigenvalue, since $A$ is entrywise non-negative and symmetric; we take domination as an explicit hypothesis so that the algebraic core is stated at full generality.

**Combinatorial invariants.** Let
$$m = \#\{\text{edges of } G\}, \qquad t = \#\{\text{triangles of } G\} = \#\{3\text{-cliques of } G\},$$
a *triangle* being a set of three pairwise-adjacent vertices.

**Spectral excess.** Define
$$q = \lambda^2 - m,$$
the amount by which the squared spectral radius exceeds the edge count.

**Walks.** A *walk of length $k$* is a sequence $v_0, v_1, \dots, v_k$ with $v_{i-1} \sim v_i$ for each $i$; it is *closed* if $v_0 = v_k$. The standard identity $(A^k)_{uv} = \#\{\text{walks of length } k \text{ from } u \text{ to } v\}$ underlies both trace bridges.

## 3. The spectral supersaturation inequality

We first develop the algebraic core at the level of an abstract multiset of eigenvalues, then specialize to matrices. All results in this section are self-contained.

### 3.1 A pointwise cubic estimate

**Lemma 3.1 (Cubic domination).** *For real numbers $\mu$ and $\lambda$ with $|\mu| \le \lambda$,*
$$-\lambda\,\mu^2 \le \mu^3.$$

*Proof.* From $|\mu| \le \lambda$ we get $\mu \ge -\lambda$, hence $\mu + \lambda \ge 0$. Since $\mu^2 \ge 0$,
$$\mu^3 + \lambda\mu^2 = \mu^2(\mu + \lambda) \ge 0,$$
which rearranges to the claim. $\square$

Geometrically: no eigenvalue's cube can undershoot $-\lambda$ times its square. This is the single sign fact that keeps the cubic power sum from collapsing.

### 3.2 Summation over the spectrum

**Theorem 3.2 (Eigenvalue supersaturation).** *Let $\mu_1, \dots, \mu_n$ be real numbers, let $\lambda = \mu_j$ for some index $j$, and suppose $|\mu_i| \le \lambda$ for all $i$. Then*
$$2\lambda^3 - \lambda\sum_{i} \mu_i^2 \;\le\; \sum_{i} \mu_i^3.$$

*Proof.* By Lemma 3.1, each summand $\mu_i^3 + \lambda\mu_i^2 \ge 0$. Because all terms are non-negative, the total is at least the single term at index $j$:
$$\mu_j^3 + \lambda\mu_j^2 \;\le\; \sum_i \bigl(\mu_i^3 + \lambda\mu_i^2\bigr) = \sum_i \mu_i^3 + \lambda\sum_i \mu_i^2.$$
Substituting $\mu_j = \lambda$ gives $\mu_j^3 + \lambda\mu_j^2 = \lambda^3 + \lambda^3 = 2\lambda^3$, and rearranging yields the stated inequality. $\square$

### 3.3 Passage to traces

We use two standard facts. First, a real symmetric matrix $A$ is orthogonally diagonalizable, $A = Q\,\mathrm{diag}(\mu_1,\dots,\mu_n)\,Q^{\top}$ with $Q$ orthogonal (the spectral theorem). Second, the trace is invariant under conjugation and multiplicative on the diagonal, so

**Lemma 3.3 (Trace–power-sum identity).** *For a real symmetric matrix $A$ with eigenvalues $\mu_1, \dots, \mu_n$ and every $k \in \mathbb{N}$,*
$$\operatorname{tr}(A^k) = \sum_{i} \mu_i^k.$$

*Proof.* Writing $A = Q D Q^\top$ with $D = \mathrm{diag}(\mu_i)$ and $Q^\top Q = I$, we have $A^k = Q D^k Q^\top$, and $D^k = \mathrm{diag}(\mu_i^k)$. By cyclicity of the trace, $\operatorname{tr}(A^k) = \operatorname{tr}(Q D^k Q^\top) = \operatorname{tr}(D^k Q^\top Q) = \operatorname{tr}(D^k) = \sum_i \mu_i^k.$ $\square$

Combining Theorem 3.2 (applied to the eigenvalues) with Lemma 3.3 for $k = 2, 3$:

**Theorem 3.4 (Matrix spectral supersaturation).** *Let $A$ be a real symmetric matrix with a distinguished eigenvalue $\lambda = \mu_j$ dominating the spectrum in modulus, $|\mu_i| \le \lambda$ for all $i$. Then*
$$2\lambda^3 - \lambda\,\operatorname{tr}(A^2) \;\le\; \operatorname{tr}(A^3).$$

*Proof.* Immediate from Theorem 3.2 by replacing $\sum_i \mu_i^2$ with $\operatorname{tr}(A^2)$ and $\sum_i \mu_i^3$ with $\operatorname{tr}(A^3)$ via Lemma 3.3. $\square$

## 4. The trace bridges

We now compute $\operatorname{tr}(A^2)$ and $\operatorname{tr}(A^3)$ for a graph's adjacency matrix in purely combinatorial terms.

### 4.1 The edge bridge

**Theorem 4.1 (Edge bridge).** *For a finite simple graph $G$ with real adjacency matrix $A$ and $m$ edges,*
$$\operatorname{tr}(A^2) = 2m.$$

*Proof.* The diagonal entry $(A^2)_{uu} = \sum_v A_{uv}A_{vu} = \sum_v A_{uv}^2 = \sum_v A_{uv} = \deg(u)$, since entries are $0$ or $1$. Hence $\operatorname{tr}(A^2) = \sum_u \deg(u)$, which equals $2m$ by the handshake lemma (each edge contributes to the degree of both endpoints). $\square$

### 4.2 The ordering lemma

The triangle bridge hinges on a graph-free counting fact.

**Theorem 4.2 (Ordered representatives of a $3$-set).** *Let $s$ be a set of exactly three elements. The number of ordered triples $(x, y, z)$ with $\{x, y, z\} = s$ equals $6$.*

*Proof.* Write $s = \{a, b, c\}$ with $a, b, c$ pairwise distinct (a three-element set has three distinct representatives). An ordered triple $(x, y, z)$ satisfies $\{x, y, z\} = s$ iff $(x, y, z)$ is a permutation of $(a, b, c)$. There are exactly $3! = 6$ such permutations:
$$(a,b,c),\ (a,c,b),\ (b,a,c),\ (b,c,a),\ (c,a,b),\ (c,b,a),$$
and these are pairwise distinct because $a, b, c$ are. Hence the count is $6$. $\square$

### 4.3 The triangle bridge

**Theorem 4.3 (Triangle bridge).** *For a finite simple graph $G$ with real adjacency matrix $A$ and $t$ triangles,*
$$\operatorname{tr}(A^3) = 6t.$$

*Proof.* By the walk identity, $(A^3)_{uu}$ counts closed walks $u \to v \to w \to u$ of length three, so
$$\operatorname{tr}(A^3) = \sum_u (A^3)_{uu} = \#\{(u, v, w) : u \sim v,\ v \sim w,\ w \sim u\}.$$
Call the triples on the right the *cyclic triples*. In a simple graph, $u \sim v$, $v \sim w$, $w \sim u$ force $u, v, w$ pairwise distinct (adjacency is irreflexive), so each cyclic triple $(u,v,w)$ has underlying set $\{u,v,w\}$ a triangle of $G$. Conversely, every triangle $\{u,v,w\}$ arises from its cyclic triples. Partition the cyclic triples according to their underlying triangle. By Theorem 4.2, each triangle contributes exactly $6$ ordered triples, all of which are indeed cyclic since all three edges are present. Therefore
$$\operatorname{tr}(A^3) = \sum_{\text{triangles } T} 6 = 6t. \qquad \square$$

This is the load-bearing cross-domain connector: it converts the *ordered* closed-walk count that the trace naturally produces into the *unordered* triangle count of extremal combinatorics, and the conversion factor is precisely the $3! = 6$ of Theorem 4.2.

## 5. Graph-theoretic supersaturation

We now assemble the pieces. Fix a finite simple graph $G$ with real adjacency matrix $A$, a spectrum-dominating eigenvalue $\lambda = \mu_j$ (so $|\mu_i| \le \lambda$ for all $i$), edge count $m$, triangle count $t$, and spectral excess $q = \lambda^2 - m$.

**Theorem 5.1 (Edge-spectral triangle supersaturation).**
$$\lambda\, q \;\le\; 3t.$$

*Proof.* By Theorem 3.4, $2\lambda^3 - \lambda\operatorname{tr}(A^2) \le \operatorname{tr}(A^3)$. Substitute the trace bridges $\operatorname{tr}(A^2) = 2m$ (Theorem 4.1) and $\operatorname{tr}(A^3) = 6t$ (Theorem 4.3):
$$2\lambda^3 - 2\lambda m \le 6t.$$
Factor the left side as $2\lambda(\lambda^2 - m) = 2\lambda q$, giving $2\lambda q \le 6t$, i.e. $\lambda q \le 3t$. $\square$

**Interpretation.** When $\lambda$ substantially exceeds $\sqrt m$, the excess $q = \lambda^2 - m$ is positive and the triangle count is forced upward proportionally: high spectral radius supersaturates the graph with triangles.

**Theorem 5.2 ($\sqrt m$ scaling).** *If $q \ge 0$, then*
$$\sqrt m\, q \;\le\; 3t.$$

*Proof.* Since $\lambda$ dominates the spectrum in modulus, $\lambda \ge |\mu_j| \ge 0$. From $q \ge 0$ and $\lambda^2 = m + q$ we get $\lambda^2 \ge m$, hence $\lambda = \sqrt{\lambda^2} \ge \sqrt m$ (both sides non-negative). Multiplying the non-negative quantity $q$ by $\sqrt m \le \lambda$ gives $\sqrt m\, q \le \lambda q$, and $\lambda q \le 3t$ by Theorem 5.1. $\square$

This matches the *shape* of the conjectured sharp bound $t \ge (1-\varepsilon)\,q\sqrt m$; our constant is $\tfrac13$ rather than the conjectured $1$.

**Theorem 5.3 (Nosal's inequality).** *If $G$ is triangle-free ($t = 0$), then*
$$\lambda^2 \le m, \qquad\text{equivalently}\qquad \lambda \le \sqrt m.$$

*Proof.* By Theorem 5.1 with $t = 0$, $\lambda q \le 0$. As above $\lambda \ge 0$. If $\lambda = 0$ then $\lambda^2 = 0 \le m$ trivially. If $\lambda > 0$ then $q \le 0$, i.e. $\lambda^2 - m \le 0$, so $\lambda^2 \le m$. Taking square roots gives $\lambda \le \sqrt m$. $\square$

Thus Nosal's classical spectral bound for triangle-free graphs is exactly the boundary case of the supersaturation inequality, and Theorem 5.1 is its quantitative strengthening: crossing the threshold $\lambda = \sqrt m$ does not merely produce a single triangle but at least $\tfrac13\lambda(\lambda^2 - m)$ of them.

## 6. A concrete certification: the triangle $K_3$

Let $G = K_3$ be the complete graph on three vertices. Every pair is adjacent, so $m = 3$ and $t = 1$. Its adjacency matrix is
$$A = \begin{pmatrix} 0 & 1 & 1 \\ 1 & 0 & 1 \\ 1 & 1 & 0 \end{pmatrix},$$
with eigenvalues $\mu_1 = 2$ and $\mu_2 = \mu_3 = -1$, so $\lambda = 2$.

- **Edge bridge:** $\operatorname{tr}(A^2) = \sum \mu_i^2 = 4 + 1 + 1 = 6 = 2m$. ✓
- **Triangle bridge:** $\operatorname{tr}(A^3) = \sum \mu_i^3 = 8 - 1 - 1 = 6 = 6t$. ✓
- **Supersaturation:** $q = \lambda^2 - m = 4 - 3 = 1$, so $\lambda q = 2 \le 3 = 3t$. ✓ (The slack of $1$ reflects the gap between the achieved constant $\tfrac13$ and the conjectured $1$.)
- **Nosal check (non-vacuous):** $K_3$ is not triangle-free, so Theorem 5.3 does not apply; consistent with $\lambda^2 = 4 > 3 = m$.

This certifies that the trace identities are non-vacuous and the supersaturation bound is tight-in-shape on the extremal small case.

## 7. Algorithms

The proof is constructive and yields two natural computations.

**Algorithm A (Trace-based triangle count).** Given $A$, compute $t = \tfrac16\operatorname{tr}(A^3)$ by matrix multiplication. Complexity $O(n^\omega)$ using fast matrix multiplication (or $O(n^3)$ naively), and it certifies simultaneously $m = \tfrac12\operatorname{tr}(A^2)$.

**Algorithm B (Spectral supersaturation certificate).** Given $A$, compute its eigenvalues, set $\lambda = \max_i |\mu_i|$, $m = \tfrac12\sum_i\mu_i^2$, $t = \tfrac16\sum_i\mu_i^3$, and $q = \lambda^2 - m$; then verify $\lambda q \le 3t$ and, if $q \ge 0$, $\sqrt m\, q \le 3t$. This turns the theorem into a numerically checkable certificate on any input graph.

## 8. Applications

- **Triangle-density lower bounds from the spectrum.** Whenever a large network's spectral radius exceeds $\sqrt m$, Theorem 5.1 provides an *a priori* lower bound on its triangle count without enumerating triangles — useful when $\operatorname{tr}(A^3)$ is estimated (e.g. via stochastic trace estimators) rather than computed exactly.
- **Certifying non-triangle-freeness.** If a graph's dominant eigenvalue exceeds $\sqrt m$, Theorem 5.3 (contrapositive) certifies that the graph *must* contain a triangle, a spectral witness of clustering.
- **Extremal benchmarking.** The $\sqrt m\, q$ scaling gives a baseline against which conjectured sharp constants can be tested on families of graphs.

## 9. Discussion and future work

The argument is deliberately modular: an abstract eigenvalue inequality (Section 3), two trace bridges (Section 4), and their combination (Section 5). Each bridge isolates exactly one idea, and the triangle bridge's dependence on the $3! = 6$ ordering lemma makes transparent *why* the constant $6$ appears.

**Perron–Frobenius.** The domination hypothesis $|\mu_i| \le \lambda$ is currently assumed. For the non-negative symmetric adjacency matrix, Perron–Frobenius theory guarantees the spectral radius is a real eigenvalue attaining the maximum modulus; formalizing this specifically for $A(G)$ would replace the hypothesis by $\lambda = \rho(A)$, making the bounds fully unconditional.

**Sharpening the constant.** The method delivers constant $\tfrac13$; the conjectured sharp constant is $1$ (i.e. $t \gtrsim q\sqrt m$). Closing the gap requires controlling the negative part of the spectrum: the slack $\sum_{i \ne j}\mu_i^3 \ge -\lambda\sum_{i \ne j}\mu_i^2$ is tight only in a bipartite-like configuration, which is incompatible with having many triangles — a tension one might exploit.

**Higher cliques and color-critical $F$.** Extending trace bridges of the form $\operatorname{tr}(A^k) = c_k\cdot\#(k\text{-cliques})$ (up to lower-order walk corrections) to $K_4, K_5, \dots$ via closed $k$-walk counts would target the general color-critical regime, in particular $\chi(F) \ge 4$ where a sharp constant is known.

**Walk-count reformulation.** The identity $\operatorname{tr}(A^3) = 6t$ can be restated abstractly via closed-walk counting, packaging the triangle bridge as a reusable lemma for other trace-method results.

## 10. Conclusion

By threading a single elementary inequality through two trace identities, we obtain a clean, self-contained edge-spectral supersaturation bound $\lambda q \le 3t$ for triangles, recovering Nosal's inequality as its boundary case and reproducing the conjectured $q\sqrt m$ scaling with an explicit constant. The result is a compact illustration of a broad principle: combinatorial counts are best bounded by locating the algebraic invariant they secretly equal and estimating it analytically. Here the trace is the translator, and the six orderings of a triangle are the key entry in its dictionary.
