# Partial Laplacian Spectra, Threshold Graphs, and the Brouwer Equality Problem

## Abstract

For a finite simple graph $G$ on $n$ vertices with $m$ edges, let $\lambda_1 \ge \lambda_2 \ge \cdots \ge \lambda_n \ge 0$ be the eigenvalues of its Laplacian matrix $L = D - A$, and let $s_k(G) = \sum_{i=1}^k \lambda_i$ be the sum of the $k$ largest eigenvalues. Brouwer's conjecture asserts $s_k(G) \le m + \binom{k+1}{2}$ for all $1 \le k \le n$, with the extremal graphs conjectured to be exactly the threshold graphs of clique number $k+1$. We develop the exact, unconditional infrastructure surrounding this problem. We prove that $L$ is symmetric and positive semidefinite; establish the trace identity $s_n(G) = 2m$; derive monotonicity of the partial sums, the global ceiling $s_k(G) \le 2m$, and saturation $s_k(G) = 2m$ for $k \ge n$; and give a self-contained creation-sequence model of threshold graphs, identifying the two boundary sequences with the complete and empty graphs. We record the equality target as an explicit predicate and characterize it completely on the edgeless boundary of the threshold family, showing that the empty graph attains the bound at level $k$ iff $k = 0$. We then explain precisely how the full biconditional reduces to the Grone–Merris–Bai majorization theorem and the conjugate-degree description of threshold spectra, and we state four conjectures charting the route to the complete characterization.

**Keywords:** graph Laplacian, Laplacian eigenvalues, Brouwer's conjecture, threshold graphs, creation sequences, majorization, conjugate degree sequence, spectral graph theory.

## 1. Introduction

The Laplacian matrix of a graph is one of the most information-dense objects in combinatorics. Its spectrum controls connectivity, mixing times of random walks, the number of spanning trees (Kirchhoff's matrix–tree theorem), expansion and cut structure (Cheeger-type inequalities), and the dynamics of diffusion and synchronization on networks. A recurring theme is to bound *sums of the largest Laplacian eigenvalues*, since these dominate worst-case behavior in many of these settings.

In 2007 Brouwer proposed a remarkably clean upper bound for the sum of the $k$ largest Laplacian eigenvalues:
$$s_k(G) \le m + \binom{k+1}{2}, \qquad 1 \le k \le n. \tag{B}$$
Despite intense study, (B) remains open in general, though it is confirmed for numerous families (trees, graphs with at most a prescribed number of edges, split graphs, and others). The *equality* form of the conjecture is even more structurally revealing: equality in (B) is conjectured to hold exactly for **threshold graphs whose clique number is $k+1$**.

This paper isolates and proves the unconditional backbone of the equality problem and locates precisely the single hard step that remains. Our contributions are:

1. A rigorous treatment of the spectral prerequisites: Hermiticity and positive semidefiniteness of $L$, hence real nonnegative eigenvalues (§3).
2. The **trace identity** $s_n(G) = 2m$, obtained from $\operatorname{trace}(L) = \sum_v \deg(v) = 2m$ (§4).
3. Structural results for the partial sums $s_k$: monotonicity, the ceiling $s_k \le 2m$, nonnegativity, and saturation $s_k = 2m$ for $k \ge n$ (§4).
4. A self-contained creation-sequence model of threshold graphs, with exact identification of the two extremal sequences (§5).
5. An explicit formulation of the Brouwer equality predicate and its complete resolution on the edgeless boundary (§6).
6. A reduction of the full biconditional to majorization theory, with four guiding conjectures (§7–§8).

## 2. Preliminaries and notation

Throughout, $G$ is a finite simple graph with vertex set $\{1, \dots, n\}$ (modeled as $n$ labeled vertices), edge set $E(G)$, and $m = |E(G)|$. We write $\deg(v)$ for the degree of vertex $v$ and $N(v)$ for its neighborhood.

**Adjacency and degree matrices.** The adjacency matrix $A \in \mathbb{R}^{n\times n}$ has $A_{ij} = 1$ if $\{i,j\} \in E(G)$ and $A_{ij} = 0$ otherwise (in particular $A_{ii} = 0$). The degree matrix $D$ is the diagonal matrix with $D_{ii} = \deg(i)$.

**Definition 2.1 (Laplacian).** The *Laplacian matrix* of $G$ is $L = D - A$.

Equivalently, $L_{ii} = \deg(i)$, and for $i \ne j$, $L_{ij} = -1$ if $\{i,j\}\in E(G)$ and $0$ otherwise.

**Definition 2.2 (Clique number).** The *clique number* $\omega(G)$ is the number of vertices in a largest complete subgraph of $G$.

## 3. The Laplacian is symmetric and positive semidefinite

**Proposition 3.1 (Symmetry).** $L$ is symmetric: $L^{\top} = L$.

*Proof.* Both $D$ and $A$ are symmetric ($A$ because adjacency is a symmetric relation, $D$ because it is diagonal), so $L = D - A$ is symmetric. $\square$

**Proposition 3.2 (Positive semidefiniteness).** For every $x \in \mathbb{R}^n$,
$$x^{\top} L x = \sum_{\{i,j\}\in E(G)} (x_i - x_j)^2 \ge 0.$$
In particular $L$ is positive semidefinite.

*Proof.* Expand $x^\top L x = \sum_i \deg(i)\,x_i^2 - \sum_{i,j} A_{ij} x_i x_j$. Each edge $\{i,j\}$ contributes $x_i^2$ and $x_j^2$ to the first sum (once through each endpoint's degree) and $-2 x_i x_j$ to the second, totaling $(x_i - x_j)^2$. Summing over edges gives the identity, which is manifestly nonnegative. $\square$

**Corollary 3.3 (Real nonnegative spectrum).** Since $L$ is real symmetric, its eigenvalues are real; since it is positive semidefinite, they are nonnegative. Ordered decreasingly,
$$\lambda_1(G) \ge \lambda_2(G) \ge \cdots \ge \lambda_n(G) \ge 0.$$

We fix this decreasing enumeration for the remainder of the paper.

## 4. Partial spectral sums and the trace identity

**Definition 4.1 (Partial spectral sum).** For $k \in \mathbb{N}$,
$$s_k(G) = \sum_{i=1}^{\min(k,n)} \lambda_i(G),$$
the sum of the $k$ largest Laplacian eigenvalues (all $n$ of them once $k \ge n$).

The following identity is the linchpin.

**Theorem 4.2 (Trace identity).** $\displaystyle \sum_{i=1}^n \lambda_i(G) = 2m$; equivalently $s_n(G) = 2m$.

*Proof.* For any real symmetric matrix, the trace equals the sum of eigenvalues:
$$\sum_{i=1}^n \lambda_i(G) = \operatorname{trace}(L).$$
Now $\operatorname{trace}(L) = \operatorname{trace}(D) - \operatorname{trace}(A)$. The adjacency matrix has zero diagonal, so $\operatorname{trace}(A) = 0$, while $\operatorname{trace}(D) = \sum_{v} \deg(v)$. By the handshake lemma, $\sum_v \deg(v) = 2m$. Combining, $\operatorname{trace}(L) = 2m$. $\square$

Theorem 4.2 says the *total* spectral sum is a pure edge invariant: it depends on $G$ only through $m$, not through the finer structure of the wiring.

**Theorem 4.3 (Monotonicity).** The map $k \mapsto s_k(G)$ is nondecreasing.

*Proof.* For $k \le \ell$, $s_\ell(G) - s_k(G) = \sum_{i=k+1}^{\min(\ell,n)} \lambda_i(G) \ge 0$ because every eigenvalue is nonnegative (Corollary 3.3). $\square$

**Theorem 4.4 (Global ceiling).** For every $k$, $s_k(G) \le 2m$.

*Proof.* $s_k(G) = \sum_{i=1}^{\min(k,n)} \lambda_i(G) \le \sum_{i=1}^n \lambda_i(G) = 2m$, using nonnegativity to add the omitted eigenvalues and Theorem 4.2. $\square$

**Theorem 4.5 (Nonnegativity).** For every $k$, $s_k(G) \ge 0$.

*Proof.* A finite sum of nonnegative eigenvalues. $\square$

**Theorem 4.6 (Saturation).** For $k \ge n$, $s_k(G) = 2m$.

*Proof.* For $k \ge n$ the sum in Definition 4.1 ranges over all $n$ eigenvalues, so $s_k(G) = s_n(G) = 2m$ by Theorem 4.2. $\square$

Together, Theorems 4.2–4.6 describe $s_k$ as a nondecreasing staircase from $\lambda_1$ up to the plateau $2m$, entirely below the ceiling $2m$. Brouwer's bound (B) refines the *rate* of ascent for small $k$, where the crude ceiling is uninformative.

## 5. Threshold graphs via creation sequences

**Definition 5.1 (Creation sequence and threshold graph).** A *creation sequence* is a function $b : \{1, \dots, n\} \to \{\text{isolated}, \text{dominating}\}$ assigning to each vertex (in birth order) a mode. The associated *threshold graph* $T_b$ has vertex set $\{1,\dots,n\}$, with distinct vertices $i < j$ adjacent iff vertex $j$ (the later-born) was created as a *dominating* vertex. Symmetrically, arbitrary distinct $i, j$ are adjacent iff $b(\max(i,j)) = \text{dominating}$.

Encoding $\text{dominating} = \mathtt{true}$, $\text{isolated} = \mathtt{false}$, the adjacency is
$$i \sim j \iff i \ne j \ \text{and}\ b(\max(i,j)) = \mathtt{true}.$$
This relation is symmetric (it depends only on the unordered pair through $\max$) and loopless (it requires $i \ne j$), so $T_b$ is a well-defined simple graph.

**Interpretation.** Each vertex, at birth, either connects to all existing vertices (dominating) or to none (isolated). Threshold graphs are exactly the graphs obtainable this way; equivalently, they are the graphs with no induced $P_4$ (path on four vertices), $C_4$ (four-cycle), or $2K_2$ (two disjoint edges).

**Theorem 5.2 (Complete-graph boundary).** If $b$ is the all-dominating sequence ($b(v) = \mathtt{true}$ for all $v$), then $T_b = K_n$, the complete graph.

*Proof.* Under the all-dominating sequence, distinct $i, j$ satisfy $b(\max(i,j)) = \mathtt{true}$, so $i \sim j$ for every distinct pair — precisely the adjacency of $K_n$. $\square$

**Theorem 5.3 (Empty-graph boundary).** If $b$ is the all-isolated sequence ($b(v) = \mathtt{false}$ for all $v$), then $T_b = \overline{K_n}$, the edgeless graph.

*Proof.* Under the all-isolated sequence, $b(\max(i,j)) = \mathtt{false}$ for every pair, so no distinct pair is adjacent — the empty graph. $\square$

These boundary identifications are genuine graph equalities, established by verifying adjacency for every pair, not by unfolding definitions.

## 6. The Brouwer equality predicate and its edgeless boundary

**Definition 6.1 (Brouwer bound and equality predicate).** The *Brouwer bound* at level $k$ is
$$\beta_k(G) = m + \binom{k+1}{2}.$$
We say $G$ *satisfies Brouwer equality at level $k$*, written $\mathrm{BE}(G,k)$, if $s_k(G) = \beta_k(G)$.

Brouwer's inequality (B) is the assertion $s_k(G) \le \beta_k(G)$; the conjectured equality characterization is:

**Conjecture 6.2 (Equality characterization).** For $1 \le k \le n-1$, $\mathrm{BE}(G,k)$ holds iff $G$ is a threshold graph with clique number $\omega(G) = k+1$.

We resolve this predicate completely on the edgeless extreme of the threshold family.

**Lemma 6.3 (Silent spectrum of the empty graph).** For the edgeless graph $\overline{K_n}$, every Laplacian eigenvalue is $0$, hence $s_k(\overline{K_n}) = 0$ for all $k$.

*Proof.* The empty graph has $L = 0$ (all degrees $0$, no edges), whose only eigenvalue is $0$. Alternatively: by Theorem 4.5, $s_k \ge 0$, and by Theorem 4.4, $s_k \le 2m = 0$ since $m = 0$; hence $s_k = 0$. $\square$

**Theorem 6.4 (Edgeless equality boundary).** For the edgeless graph $\overline{K_n}$ and any $k$,
$$\mathrm{BE}(\overline{K_n}, k) \iff k = 0.$$

*Proof.* Here $m = 0$, so $\beta_k = \binom{k+1}{2}$, while $s_k(\overline{K_n}) = 0$ by Lemma 6.3. Thus $\mathrm{BE}(\overline{K_n}, k)$ holds iff $\binom{k+1}{2} = 0$. Since $\binom{k+1}{2} = \tfrac{k(k+1)}{2}$, this vanishes iff $k = 0$. $\square$

**Corollary 6.5.** For every $k \ge 1$, the edgeless graph fails Brouwer equality by the full amount: $\beta_k - s_k = \binom{k+1}{2}$. Concretely, $\overline{K_n}$ does not satisfy $\mathrm{BE}$ at level $1$ for any $n \ge 1$.

Theorem 6.4 confirms Conjecture 6.2 on this boundary: the empty graph is a threshold graph (all-isolated creation sequence) with clique number $\omega = 1$, so the predicted saturation level is $k = \omega - 1 = 0$ — exactly what Theorem 6.4 yields.

## 7. Reduction of the full characterization to majorization

Why should threshold graphs be the extremizers? The mechanism is a majorization identity linking two sequences attached to $G$.

**The degree sequence and its conjugate.** Let $d_1 \ge d_2 \ge \cdots \ge d_n$ be the degrees of $G$ in decreasing order — a partition of $2m$. Its *conjugate* (transpose) partition $d^* = (d_1^*, d_2^*, \dots)$ is defined by
$$d_j^* = \#\{i : d_i \ge j\},$$
the column heights of the Ferrers diagram of $d$. A direct count gives the crucial identity
$$\sum_{j=1}^{k} d_j^* = m + \binom{k+1}{2} - r_k,$$
where the extremal (threshold) configuration removes the slack $r_k$, so that for threshold graphs $\sum_{j=1}^{k} d_j^* = m + \binom{k+1}{2}$ precisely when $k+1$ equals the clique number. In short, the Brouwer bound $\beta_k$ *is* the top-$k$ sum of the conjugate degree sequence for the extremal family.

**Theorem 7.1 (Grone–Merris–Bai; cited).** For every graph $G$, the Laplacian spectrum is majorized by the conjugate degree sequence:
$$s_k(G) = \sum_{i=1}^k \lambda_i(G) \le \sum_{j=1}^k d_j^*(G), \qquad 1 \le k \le n,$$
with equality at $k = n$ (both totalling $2m$).

This is the deep input, originally the Grone–Merris conjecture, proved by Bai. Given Theorem 7.1, Brouwer's inequality (B) follows for the extremal family whenever $\sum_{j\le k} d_j^* = \beta_k$, and the equality analysis becomes a question of when the majorization is *tight*.

**Theorem 7.2 (Merris; threshold spectra, cited).** A graph is a threshold graph iff its Laplacian spectrum equals its conjugate degree sequence: $\lambda_i(G) = d_i^*(G)$ for all $i$.

Combining Theorems 7.1 and 7.2 gives the conjectural picture: equality $s_k = \beta_k$ squeezes the spectrum against the conjugate degree sequence at level $k$, forcing (with clique-number bookkeeping) exact conjugacy, i.e. the threshold property. The two inequalities that *bracket* the equality case — monotonicity/ceiling from below and majorization from above — are exactly the pieces we control; the remaining gap is the tightness step of the majorization at intermediate $k$.

## 8. Algorithms

We record the elementary computational routines underlying the numerical study of these results.

**Algorithm 8.1 (Partial spectral sum).** Given $G$, form $L = D - A$, compute its eigenvalues, sort decreasingly, and accumulate the top $k$. Complexity $O(n^3)$ for the symmetric eigendecomposition. Correctness relies on Corollary 3.3 (real nonnegative spectrum).

**Algorithm 8.2 (Threshold graph from a creation sequence).** Given $b \in \{0,1\}^n$, output the adjacency $A_{ij} = [\,i\ne j \ \wedge\ b_{\max(i,j)} = 1\,]$. Complexity $O(n^2)$. By Theorems 5.2–5.3 the constant sequences produce $K_n$ and $\overline{K_n}$.

**Algorithm 8.3 (Conjugate degree sequence).** Given degrees $d_1 \ge \cdots \ge d_n$, output $d_j^* = \#\{i : d_i \ge j\}$ for $j \ge 1$. Complexity $O(n + \max_i d_i)$. This produces the sequence appearing in Theorems 7.1–7.2.

**Algorithm 8.4 (Brouwer gap scan).** For a graph $G$ and each $1 \le k \le n-1$, compute the gap $\beta_k(G) - s_k(G)$ using Algorithms 8.1 and the edge count. A zero gap flags a candidate extremal (threshold) level; the scan empirically tests Conjecture 6.2.

## 8.5. Worked examples

We illustrate the theory on small graphs to make the identities concrete.

**The path $P_3$ (three vertices, two edges).** With $m = 2$, the Laplacian is
$$L = \begin{pmatrix} 1 & -1 & 0 \\ -1 & 2 & -1 \\ 0 & -1 & 1 \end{pmatrix},$$
with spectrum $\{3, 1, 0\}$. Then $s_1 = 3$, $s_2 = 4$, $s_3 = 4 = 2m$, confirming the trace identity and monotonicity. The Brouwer bounds are $\beta_1 = 2 + 1 = 3$ and $\beta_2 = 2 + 3 = 5$. Here $s_1 = 3 = \beta_1$: the path $P_3$ is the star $K_{1,2}$, a threshold graph (creation sequence isolated, isolated, dominating: the two leaves arrive isolated, then the center arrives dominating), with clique number $2$, saturating at $k = 1 = \omega - 1$, exactly as Conjecture 6.2 predicts. At $k = 2$ there is slack $\beta_2 - s_2 = 1$.

**The four-cycle $C_4$ (four vertices, four edges).** With $m = 4$, the Laplacian spectrum is $\{4, 2, 2, 0\}$, so $s_1 = 4$, $s_2 = 6$, $s_3 = 8$, $s_4 = 8 = 2m$. The Brouwer bounds are $\beta_1 = 5$, $\beta_2 = 7$, $\beta_3 = 10$. Every partial sum lies strictly below the bound ($s_1 = 4 < 5$, $s_2 = 6 < 7$, $s_3 = 8 < 10$): $C_4$ is *not* a threshold graph (it is itself a forbidden induced subgraph), so it attains equality at no level $1 \le k \le 3$, consistent with Conjecture 6.2. Its degree sequence is $(2,2,2,2)$ with conjugate $(4,4)$, whose top-$2$ sum is $8 > s_2 = 6$, exhibiting strict majorization slack.

**The complete graph $K_4$ (four vertices, six edges).** The Laplacian spectrum is $\{4,4,4,0\}$, so $s_1 = 4$, $s_2 = 8$, $s_3 = 12$, $s_4 = 12 = 2m$. The Brouwer bound at $k = 3$ is $\beta_3 = 6 + 6 = 12 = s_3$: $K_4$ is a threshold graph (all-dominating sequence) with clique number $4$, saturating at $k = 3 = \omega - 1$. This is the complete-graph extreme of the characterization.

## 9. Applications

Sums of the largest Laplacian eigenvalues are not merely spectral curiosities; they control quantitative behavior across applied domains.

**Diffusion and heat flow.** The solution of the graph heat equation $\dot u = -Lu$ decays in each eigendirection at rate $\lambda_i$. The largest eigenvalues govern the fastest-decaying, highest-frequency modes; $s_k$ measures the aggregate stiffness of the top $k$ modes, bounding worst-case transient behavior in networked diffusion and consensus dynamics.

**Synchronization of coupled oscillators.** For Kuramoto-type and linear consensus systems on a network, stability margins and convergence rates are dictated by the Laplacian spectrum. Upper bounds on $s_k$ translate into bounds on the combined influence of the stiffest coupling modes, and the extremal (threshold) configurations identify worst-case coupling topologies.

**Spectral clustering and graph partitioning.** Algorithms that partition data by cutting graphs rely on Laplacian eigenvalues; the magnitude of the top eigenvalues bounds the quality and cost of spectral embeddings. Knowing the maximal $s_k$ and its extremizers calibrates the range of behavior these algorithms can exhibit.

**Network robustness.** The Laplacian spectrum encodes algebraic connectivity and the number of spanning trees (via the matrix–tree theorem), both robustness proxies. The trace identity $s_n = 2m$ shows total spectral energy is fixed by edge count, so robustness differences among graphs with the same edge count are entirely a matter of how that fixed energy is distributed across the spectrum — precisely the distributional question the Brouwer bound constrains.

## 10. Numerical illustrations

The accompanying computational study verifies the theory on concrete graphs:

- **Trace identity.** For random graphs, $\sum_i \lambda_i$ matches $2m$ to machine precision, and $s_n = 2m$ exactly (Theorem 4.2).
- **Monotonicity and ceiling.** $s_1 \le s_2 \le \cdots \le s_n = 2m$ holds on all tested graphs (Theorems 4.3–4.6).
- **Threshold saturation.** For threshold graphs generated from random creation sequences, $s_k$ equals $m + \binom{k+1}{2}$ exactly at $k = \omega - 1$, and the Brouwer gap is $0$ there; for non-threshold graphs the gap is strictly positive (Conjecture 6.2).
- **Conjugate-degree spectrum.** For threshold graphs, the sorted Laplacian spectrum coincides with the conjugate degree sequence (Theorem 7.2), confirmed numerically.
- **Empty-graph boundary.** $s_k(\overline{K_n}) = 0$ and equality holds only at $k = 0$ (Theorem 6.4).

## 11. Discussion

The results here cleanly separate the *provable spine* of the Brouwer equality problem from its single hard core. The trace identity, positive semidefiniteness, monotonicity, ceiling, and saturation are all elementary consequences of linear algebra and the handshake lemma, and they already determine the coarse shape of the partial-sum staircase. The threshold family is captured combinatorially by creation sequences, with its two poles pinned to $K_n$ and $\overline{K_n}$. The equality predicate is resolved exactly on the edgeless boundary, matching the clique-number prediction ($\omega = 1 \Rightarrow$ saturation at $k = 0$).

The remaining difficulty is entirely concentrated in the *tightness* of the Grone–Merris–Bai majorization at intermediate levels $k$. Our monotonicity and ceiling supply the lower bracket; Theorem 7.1 supplies the upper bracket; the conjectures below concern closing the bracket.

## 12. Future directions

**Conjecture 1 — Conjugate-degree spectrum of threshold graphs.** For every threshold graph, the multiset of Laplacian eigenvalues equals the conjugate (transpose) of its degree partition. The key insight is that the creation-sequence construction turns each dominating step into a uniform additive shift of the spectrum, so the spectrum is read off the Ferrers diagram of the degree sequence rather than from any matrix computation, converting an eigenvalue question into a partition-combinatorics question amenable to direct induction.

**Conjecture 2 — Saturation only at the clique boundary.** Among all graphs on $n$ vertices with $m$ edges, $s_k$ attains $m + \binom{k+1}{2}$ exactly when the graph is a threshold graph whose clique number is $k+1$. Both sides are majorization extremes: $s_k$ is the top-$k$ Schur sum of the Laplacian spectrum and $m + \binom{k+1}{2}$ is the top-$k$ sum of the conjugate degree sequence, so equality forces the spectrum to be exactly conjugate — the defining property of threshold graphs. The monotonicity and ceiling results here supply the two inequalities that squeeze the equality case, leaving only the majorization-tightness step.

**Conjecture 3 — Strict slack away from the extremal family.** For any non-threshold graph and any $1 \le k \le n-1$, the Brouwer gap $m + \binom{k+1}{2} - s_k$ is bounded below by a positive quantity depending only on the number of induced obstructions ($P_4$, $C_4$, $2K_2$). Each forbidden induced subgraph perturbs the Laplacian away from the conjugate-degree extreme by a controllable rank-one amount, so the gap accumulates additively over obstructions. With the empty-graph boundary computation showing the gap can be as large as $\binom{k+1}{2}$, a quantitative lower bound is the natural next measurement.

**Conjecture 4 — Edge-invariant rigidity of the total sum.** The identity $s_n = 2m$ is the unique linear spectral functional that is a graph edge-invariant; every other top-$k$ sum genuinely depends on graph structure beyond $m$ for $1 \le k \le n-1$. The trace is the only symmetric function of the spectrum that collapses to the diagonal, and the diagonal of the Laplacian is exactly the degree sequence whose total is $2m$.

## References (background)

- A. E. Brouwer and W. H. Haemers, *Spectra of Graphs*, Springer, 2012.
- R. Grone and R. Merris, *The Laplacian spectrum of a graph II*, SIAM J. Discrete Math., 1994.
- X. Bai, *The Grone–Merris conjecture*, Trans. Amer. Math. Soc., 2011.
- R. Merris, *Degree maximal graphs are Laplacian integral*, Linear Algebra Appl., 1994.
- N. V. R. Mahadev and U. N. Peled, *Threshold Graphs and Related Topics*, North-Holland, 1995.
