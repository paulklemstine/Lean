# Universality of the Spectral Distribution of Wigner Matrices: An Exact Walk Calculus

**Author:** Aristotle

**Date:** 2026-08-16

---

## Abstract

We develop the moment method for Wigner random matrices in a form that is exact at every finite dimension. For the symmetric Rademacher (sign) ensemble we prove a complete *walk dichotomy*: the ensemble average of the entry monomial along an arbitrary finite family of steps equals $1$ when the family is loop-free with all edge multiplicities even, and $0$ otherwise. Consequently every expected trace moment is *literally a cardinality* — the number of even closed walks on the complete graph — and every odd trace moment vanishes identically at every finite dimension, with no asymptotics involved. A spanning-tree bound shows that an even closed walk of length $2k$ visits at most $k+1$ vertices, giving at most $N^{k+1}(k+1)^{2k}$ such walks and hence the dimension-free bound $\mathbb{E}[\frac1N \operatorname{tr}((W/\sqrt N)^{2k})] \le (k+1)^{2k}$. In the opposite direction, the exactly self-averaging identity $\operatorname{tr}(W^2) = N(N-1)$ combined with power-mean convexity gives the *deterministic* lower bound $\operatorname{tr}(W^{2k}) \ge N(N-1)^k$ for every realisation, producing the two-sided sandwich $(1-1/N)^k \le \mathbb{E}[\frac1N\operatorname{tr}((W/\sqrt N)^{2k})] \le (k+1)^{2k}$. For an arbitrary finitely supported, centred, unit-variance entry law with fourth moment $m_4$ we prove the exact identity $\mathbb{E}[\operatorname{tr}(W^4)] = 2N(N-1)^2 - 2N(N-1) + m_4 N(N-1)$, exhibiting universality of the fourth spectral moment together with the precise $O(N^{-1})$ size of the entry-law-dependent correction, and we compute the variance of the second spectral moment exactly as $2(m_4-1)(N-1)/N^3$, yielding a quantitative Chebyshev rate and $L^2$ convergence to the semicircle value. On the analytic side we prove that the moments of the semicircle density $\frac{1}{2\pi}\sqrt{4-x^2}$ on $[-2,2]$ are the Catalan numbers, that they satisfy the convolution recursion, and that this recursion characterises them; and we establish tightness of the empirical spectral distribution uniformly in the dimension, which is the compactness input required to upgrade moment convergence to weak convergence.

**Keywords:** Wigner matrix, semicircle law, moment method, universality, Catalan numbers, closed walks, empirical spectral distribution, concentration, tightness.

---

## 1. Introduction

### 1.1 The problem

Let $W = W^{(N)}$ be a real symmetric $N \times N$ random matrix with independent entries above the diagonal. The *empirical spectral distribution* (ESD) of the normalised matrix $M = W/\sqrt N$ is the probability measure

$$\mu_N \;=\; \frac{1}{N}\sum_{i=1}^{N} \delta_{\lambda_i/\sqrt N},$$

where $\lambda_1,\dots,\lambda_N$ are the eigenvalues of $W$. Wigner's semicircle law states that, under mild moment assumptions on the entries, $\mu_N$ converges weakly in probability to the deterministic measure $\sigma$ with density

$$\varrho(x) \;=\; \frac{1}{2\pi}\sqrt{4-x^2}\,\mathbf{1}_{[-2,2]}(x).$$

The striking feature is *universality*: the limit does not depend on the entry distribution beyond its mean ($0$) and variance ($1$). The classical proof is the **moment method**: show that for each $k$,

$$\int x^k \, d\mu_N(x) \;=\; \frac1N \operatorname{tr}\!\left(\left(\tfrac{W}{\sqrt N}\right)^{k}\right) \;\longrightarrow\; \int x^k \, d\sigma(x),$$

and upgrade this to weak convergence using the determinacy of the (compactly supported) limit together with tightness.

### 1.2 What this paper establishes

The purpose of this work is to carry out the moment method in a form in which every step is an exact identity or an explicit inequality valid at finite $N$, rather than an asymptotic statement. The main contributions are:

1. **An exact ensemble dichotomy** (Theorem 4.4) for the symmetric Rademacher ensemble, valid for an arbitrary finite family of steps, from which:
2. **Trace moments as cardinalities** (Theorem 4.5): $\mathbb{E}[\operatorname{tr}(W^{m+1})]$ equals the number of even closed $(m+1)$-walks, an integer;
3. **Exact vanishing of all odd moments at every finite $N$** (Theorem 4.6);
4. **A spanning-tree growth bound** (Theorem 5.4) giving $\mathbb{E}[\frac1N\operatorname{tr}(M^{2k})] \le (k+1)^{2k}$ uniformly in $N$;
5. **A deterministic lower bound** (Theorem 5.6) $\operatorname{tr}(W^{2k}) \ge N(N-1)^k$ for every realisation, hence the sandwich of Theorem 5.7;
6. **Universality of the fourth moment with an exact finite-$N$ formula** (Theorem 6.1) and **exact variance of the second moment** (Theorem 6.3), with the resulting Chebyshev rate, $L^2$ convergence, and eigenvalue-level statements (Section 7);
7. **Uniform tightness of the ESD** (Theorem 8.3) and a **quantitative spectral-edge tail bound** (Theorem 8.4), together with a **deterministic edge lower bound** (Theorem 8.5);
8. On the analytic side, the identification of the semicircle moments with the **Catalan numbers** (Theorem 3.4), their **convolution recursion** and its **uniqueness property** (Theorems 3.5, 3.6).

Section 9 records exact small-dimension computations, Section 10 discusses algorithms, and Section 11 states what remains open.

### 1.3 Notation

Throughout, $N \ge 1$ is the dimension, indices run over $\{0,1,\dots,N-1\}$ (identified with the vertex set of the complete graph $K_N$), and $\operatorname{tr}$ is the unnormalised trace. For a symmetric matrix $A$ we write $\lambda_i(A)$ for its eigenvalues. We use

$$\widehat m_k(A) \;=\; \frac1N\sum_{i=1}^{N}\left(\frac{\lambda_i(A)}{\sqrt N}\right)^{k} \;=\; \frac1N \operatorname{tr}\!\left(\left(\tfrac{A}{\sqrt N}\right)^{k}\right)$$

for the $k$-th *normalised spectral moment*. An *unordered edge* $\{i,j\}$ with $i \ne j$ is denoted $e$; a step from $i$ to $j$ *traverses* the edge $\{i,j\}$, and a step from $i$ to $i$ is a *loop*.

---

## 2. The ensembles

**Definition 2.1 (Symmetric Rademacher ensemble).** A *configuration* is an assignment $g$ of a sign $\pm1$ to each unordered pair $\{i,j\}$, $i \ne j$, of vertices; the configuration space carries the uniform probability measure, so the $\binom N2$ signs are i.i.d. symmetric Bernoulli. The associated matrix is

$$W(g)_{ij} \;=\; \begin{cases} 0, & i = j,\\ g(\{i,j\}), & i \ne j.\end{cases}$$

Thus $W(g)$ is real symmetric with zero diagonal and $\pm1$ off-diagonal entries. We write $\mathbb{E}$ for the uniform average over the $2^{N(N-1)/2}$ configurations.

**Definition 2.2 (General Wigner ensemble).** An *entry law* $\mathcal{L}$ consists of a finite set $S$ of outcomes, weights $w : S \to [0,\infty)$ with $\sum_s w(s) = 1$, and values $v : S \to \mathbb{R}$ subject to

$$\sum_s w(s)\,v(s) = 0 \quad\text{(centred)}, \qquad \sum_s w(s)\,v(s)^2 = 1 \quad\text{(unit variance)}.$$

Its fourth moment is $m_4(\mathcal{L}) = \sum_s w(s) v(s)^4$, which is unconstrained apart from $m_4 \ge 1$. A configuration is an independent sample $\omega(e) \in S$ for each edge $e$, with product weight $\prod_e w(\omega(e))$; the matrix is $W(\omega)_{ij} = 0$ for $i = j$ and $v(\omega(\{i,j\}))$ otherwise. Expectation with respect to the product law is denoted $\mathbb{E}_{\mathcal{L}}$.

The Rademacher ensemble is the case $S = \{0,1\}$, $w \equiv \tfrac12$, $v = \pm1$; then $m_4 = 1$, the minimum possible value.

Two properties of Definition 2.2 are used repeatedly and are worth isolating.

**Lemma 2.3 (Independence / factorisation).** For any family of functions $F_e : S \to \mathbb{R}$ indexed by edges,

$$\mathbb{E}_{\mathcal{L}}\Big[\prod_e F_e(\omega(e))\Big] \;=\; \prod_e \Big(\sum_{s} w(s) F_e(s)\Big).$$

*Proof sketch.* Expand the product weight and interchange the (finite) sum over configurations with the product over edges; this is the distributive law for finite products of finite sums. $\square$

**Lemma 2.4 (Symmetry and zero diagonal).** $W(\omega)_{ij} = W(\omega)_{ji}$ for all $i,j$, and $W(\omega)_{ii} = 0$. In particular $W(\omega)$ is Hermitian, so its eigenvalues are real and the spectral theorem applies.

---

## 3. The limit object: semicircle moments are Catalan numbers

**Definition 3.1.** The *standard semicircle law* $\sigma$ is the probability measure on $[-2,2]$ with density $\varrho(x) = \frac{1}{2\pi}\sqrt{4-x^2}$. Its $m$-th moment is

$$\sigma_m \;=\; \frac{1}{2\pi}\int_{-2}^{2} x^m \sqrt{4-x^2}\,dx.$$

**Lemma 3.2 (Trigonometric reduction).** For every $m \ge 0$,

$$\int_{-2}^{2} x^m \sqrt{4-x^2}\,dx \;=\; 2^{m+2}\int_{-\pi/2}^{\pi/2}\sin^m t\,\cos^2 t\,dt \;=\; 2^{m+2}\big(S_m - S_{m+2}\big), \qquad S_m := \int_{-\pi/2}^{\pi/2}\sin^m t \, dt.$$

*Proof sketch.* Substitute $x = 2\sin t$, so $\sqrt{4-x^2} = 2\cos t$ and $dx = 2\cos t\,dt$ on $[-\pi/2,\pi/2]$; then use $\cos^2 t = 1 - \sin^2 t$ to split the integral. $\square$

**Lemma 3.3 (Wallis recursion on the symmetric interval).** $S_0 = \pi$, $S_1 = 0$, and $S_{m+2} = \frac{m+1}{m+2}\,S_m$. Consequently $S_{2k+1} = 0$ and $S_{2k} > 0$ for all $k$.

*Proof sketch.* Integration by parts on $\sin^{m+1} t \cdot \sin t$; the boundary terms carry a factor $\cos(\pm\pi/2) = 0$ and hence vanish, which is why the symmetric interval is the convenient one. $\square$

Combining, $\sigma_m = \frac{2^{m+2}}{2\pi}(S_m - S_{m+2})$, and inserting the recursion at $m = 2k$ gives the closed form $\sigma_{2k} = \dfrac{2^{2k+1} S_{2k}}{(2k+2)\pi}$.

**Theorem 3.4 (Semicircle moments).** For all $k \ge 0$,

$$\sigma_{2k} \;=\; C_k \;=\; \frac{1}{k+1}\binom{2k}{k}, \qquad \sigma_{2k+1} \;=\; 0 .$$

In particular $\sigma_0 = 1$ (so $\sigma$ is a probability measure), $\sigma_2 = C_1 = 1$, $\sigma_4 = C_2 = 2$, $\sigma_6 = C_3 = 5$.

*Proof sketch.* Vanishing of the odd moments is immediate from $S_{2k+1} = S_{2k+3} = 0$. For the even moments, induct on $k$ using $\sigma_{2k} = 2^{2k+1}S_{2k}/((2k+2)\pi)$ and the Wallis step $S_{2k+2} = \frac{2k+1}{2k+2}S_{2k}$; the resulting ratio $\sigma_{2(k+1)}/\sigma_{2k} = \frac{2(2k+1)}{k+2}$ is exactly the Catalan recursion $(k+2)C_{k+1} = 2(2k+1)C_k$, which itself follows from the identity $(k+1)C_k = \binom{2k}{k}$ and the central-binomial recursion $(k+1)\binom{2k+2}{k+1} = 2(2k+1)\binom{2k}{k}$. The base case is $\sigma_0 = 2^1 S_0/(2\pi) = 1 = C_0$. $\square$

**Theorem 3.5 (Convolution recursion).** For all $k \ge 0$,

$$\sigma_{2(k+1)} \;=\; \sum_{i=0}^{k} \sigma_{2i}\,\sigma_{2(k-i)} .$$

*Proof sketch.* By Theorem 3.4 this is the classical Segner recursion $C_{k+1} = \sum_{i=0}^k C_i C_{k-i}$ for the Catalan numbers, transported to the integrals. $\square$

**Theorem 3.6 (Uniqueness).** If a sequence $(a_k)_{k \ge 0}$ of reals satisfies $a_0 = 1$ and $a_{k+1} = \sum_{i=0}^{k} a_i a_{k-i}$ for all $k$, then $a_k = \sigma_{2k}$ for all $k$.

*Proof sketch.* Strong induction: $a_{k+1}$ is determined by $a_0,\dots,a_k$, and the same recursion is satisfied by $(\sigma_{2k})$ by Theorem 3.5. $\square$

Theorem 3.6 is the target for any combinatorial argument: a proof of the semicircle law "at all orders" amounts to showing that the limiting even moments of the ensemble obey the convolution recursion. Combinatorially, that recursion reflects the decomposition of a balanced bracket sequence at its first return to the origin — the same decomposition that governs the doubly-traversed trees appearing in Section 5.

---

## 4. Trace moments as walk counts

### 4.1 The trace–eigenvalue bridge

**Theorem 4.1 (Bridge).** Let $A$ be a Hermitian matrix over $\mathbb{R}$ or $\mathbb{C}$ with eigenvalues $\lambda_i$. Then for every $k \ge 0$,

$$\operatorname{tr}(A^k) \;=\; \sum_i \lambda_i^{\,k}, \qquad\text{hence}\qquad \int x^k\, d\mu_N(x) \;=\; \widehat m_k(A).$$

*Proof sketch.* Write $A = U D U^{*}$ with $U$ unitary and $D$ diagonal (spectral theorem), so $A^k = U D^k U^*$; cyclicity of the trace and $U^*U = 1$ give $\operatorname{tr}(A^k) = \operatorname{tr}(D^k) = \sum_i \lambda_i^k$. $\square$

This identity is what makes the whole programme possible: it converts every statement about the ESD into a statement about traces of powers, and traces of powers expand into sums over walks.

### 4.2 The walk expansion

**Definition 4.2.** A *closed $(m+1)$-walk* is a pair $(i, v)$ where $i$ is a vertex (the basepoint) and $v = (v_1,\dots,v_m)$ is a tuple of vertices. Its steps are

$$i \to v_1 \to v_2 \to \cdots \to v_m \to i,$$

i.e. step $t$ (for $t = 0,\dots,m$) goes from the $t$-th entry of $(i,v_1,\dots,v_m)$ to the $t$-th entry of $(v_1,\dots,v_m,i)$. The walk is *loop-free* if no step is from a vertex to itself. For an edge $e$, the *multiplicity* $\operatorname{mult}(e)$ is the number of steps traversing $e$ (in either direction). The walk is **even** if it is loop-free and every edge multiplicity is even.

**Theorem 4.3 (Path and trace expansion).** For any matrix $A$ and any $m \ge 0$,

$$(A^{m+1})_{ij} \;=\; \sum_{v} \prod_{t=0}^{m} A_{(\text{path from } i \text{ through } v \text{ to } j)_t}, \qquad \operatorname{tr}(A^{m+1}) \;=\; \sum_{i}\sum_{v : [m] \to [N]} \prod_{t=0}^{m} A_{a_t b_t},$$

where $(a_t)$ and $(b_t)$ are the step-source and step-target sequences of the closed walk $(i,v)$.

*Proof sketch.* Induction on $m$ using the definition of matrix multiplication for the entrywise formula; then sum the diagonal and reindex. $\square$

### 4.3 The dichotomy

**Theorem 4.4 (Exact ensemble dichotomy, Rademacher).** Let $(a_t, b_t)_{t \in I}$ be an arbitrary finite family of steps. Then

$$\mathbb{E}\Big[\prod_{t \in I} W_{a_t b_t}\Big] \;=\; \begin{cases} 1, & \text{if } a_t \ne b_t \text{ for all } t \text{ and every edge multiplicity is even},\\[2pt] 0, & \text{otherwise.}\end{cases}$$

*Proof sketch.* Three cases.
(i) If some step is a loop, the corresponding factor is $W_{aa} = 0$ and the whole monomial is identically zero.
(ii) If the family is loop-free but some edge $p$ has odd multiplicity, consider the involution $\Phi_p$ on configurations that flips the sign attached to $p$ and leaves all other signs fixed. Every factor traversing $p$ changes sign and every other factor is unchanged, so the monomial is multiplied by $(-1)^{\operatorname{mult}(p)} = -1$. Since $\Phi_p$ is a measure-preserving bijection of the configuration space, the average equals its own negative, hence is $0$.
(iii) If the family is loop-free with all multiplicities even, group the factors by edge: the contribution of each edge is $(\pm1)^{\operatorname{mult}(e)} = 1$ *pointwise*, so the monomial is the constant $1$ and so is its average. $\square$

The involution in case (ii) is a genuinely combinatorial substitute for the usual factorisation argument: no independence is invoked, only a sign symmetry of the ensemble.

**Theorem 4.5 (Moments are cardinalities).** For every $N$ and $m$,

$$\mathbb{E}\big[\operatorname{tr}(W^{m+1})\big] \;=\; \#\{\text{even closed } (m+1)\text{-walks on } N \text{ vertices}\}.$$

*Proof sketch.* Apply Theorem 4.4 termwise inside the expansion of Theorem 4.3; each walk contributes the indicator of being even. $\square$

**Theorem 4.6 (All odd moments vanish exactly).** For every $N \ge 1$ and every odd $k \ge 1$,

$$\mathbb{E}\big[\operatorname{tr}(W^{k})\big] \;=\; 0, \qquad\text{equivalently}\qquad \mathbb{E}\big[\widehat m_k(W)\big] = 0 .$$

*Proof sketch.* The total number of steps is the sum of the edge multiplicities. If $k$ is odd, that sum is odd, so at least one multiplicity is odd, so no closed $k$-walk is even, so by Theorem 4.5 the count — and the expectation — is $0$. $\square$

Theorem 4.6 deserves emphasis: it is an identity at every finite dimension, not a limit. It matches, exactly and at every finite $N$, the vanishing of the odd semicircle moments (Theorem 3.4).

### 4.4 The general entry law

For a general entry law the involution is unavailable; independence takes its place.

**Theorem 4.7 (Walk–moment formula).** For a loop-free family of steps,

$$\mathbb{E}_{\mathcal{L}}\Big[\prod_{t\in I} W_{a_t b_t}\Big] \;=\; \prod_{e} \mu_{\operatorname{mult}(e)}, \qquad \mu_r := \sum_s w(s) v(s)^r,$$

the product being over edges of positive multiplicity.

*Proof sketch.* Rewrite the monomial as a product over edges of $v(\omega(e))^{\operatorname{mult}(e)}$ and apply Lemma 2.3. $\square$

**Corollary 4.8 (Centring kills singly-used edges).** If some edge has multiplicity exactly $1$, then $\mathbb{E}_{\mathcal{L}}[\prod_t W_{a_t b_t}] = 0$, because the corresponding factor is $\mu_1 = 0$.

Corollary 4.8 is the general-law replacement for the sign-flip involution: it is weaker (it does not kill multiplicity $3$, $5$, …, whose contributions must instead be shown to be negligible by counting), but it suffices for all the asymptotic statements below.

---

## 5. Growth of the even moments

### 5.1 A spanning-tree bound

**Lemma 5.1 (Vertices versus edges).** Along any walk, the number of distinct vertices visited is at most $1$ plus the number of distinct edges used.

*Proof sketch.* Induction on the length of the walk. The empty walk visits one vertex and uses no edges. Extending a walk by one step either revisits a known vertex (vertex count unchanged) or reaches a new vertex, which necessarily requires an edge not previously used (any earlier use of that edge would have visited the new vertex). $\square$

**Lemma 5.2 (Even multiplicities halve the edge count).** If a walk of length $\ell$ has all edge multiplicities even, then twice the number of distinct edges used is at most $\ell$; i.e. it uses at most $\lfloor \ell/2 \rfloor$ distinct edges.

*Proof sketch.* The length is the sum of the multiplicities, each of which is at least $2$ on the edges actually used. $\square$

Combining: **an even closed walk of length $2k$ visits at most $k+1$ distinct vertices.** This is the structural heart of the matter. The bound is attained precisely by walks whose edge set is a tree on $k+1$ vertices, each of its $k$ edges traversed exactly twice — the configurations counted by the Catalan numbers.

**Lemma 5.3 (Counting bounded-image maps).** The number of maps $[n] \to [N]$ whose image has at most $r$ elements is at most $N^{r} r^{n}$.

*Proof sketch.* Such a map factors through an $r$-element subset (at most $N^r$ choices of an $r$-tuple covering the image) followed by a map into that subset ($r^n$ choices). $\square$

**Theorem 5.4 (Polynomial growth).** For every $k \ge 1$ and every $N$,

$$\#\{\text{even closed } 2k\text{-walks}\} \;\le\; N^{k+1}(k+1)^{2k}, \qquad \mathbb{E}\big[\operatorname{tr}(W^{2k})\big] \;\le\; N^{k+1}(k+1)^{2k},$$

and therefore, uniformly in the dimension,

$$\mathbb{E}\big[\widehat m_{2k}(W)\big] \;=\; \frac{1}{N^{k+1}}\,\mathbb{E}\big[\operatorname{tr}(W^{2k})\big] \;\le\; (k+1)^{2k}.$$

*Proof sketch.* An even closed $2k$-walk is determined by its basepoint and its $2k-1$ intermediate vertices, all lying in a set of at most $k+1$ vertices by Lemmas 5.1–5.2; apply Lemma 5.3 and Theorem 4.5. The normalisation is $\widehat m_{2k} = N^{-1}(\sqrt N)^{-2k}\operatorname{tr}(W^{2k})$. $\square$

The constant $(k+1)^{2k}$ is crude — the truth is $C_k \le 4^k$ — but it is uniform in $N$, which is all that tightness requires.

### 5.2 A deterministic lower bound

**Lemma 5.5 (Exact self-averaging of the second moment).** For *every* configuration of the Rademacher ensemble,

$$\operatorname{tr}(W^2) \;=\; \sum_{i \ne j} W_{ij}^2 \;=\; N(N-1), \qquad \widehat m_2(W) \;=\; 1 - \frac1N .$$

*Proof sketch.* $\operatorname{tr}(W^2) = \sum_{i,j} W_{ij}W_{ji} = \sum_{i \ne j} W_{ij}^2$, and each off-diagonal square is $1$; there are $N(N-1)$ ordered off-diagonal pairs. There is no randomness left. $\square$

**Theorem 5.6 (Deterministic lower bound at every even order).** For every configuration, every $k \ge 1$ and every $N \ge 1$,

$$\operatorname{tr}(W^{2k}) \;\ge\; N(N-1)^k, \qquad\text{equivalently}\qquad \widehat m_{2k}(W) \;\ge\; \Big(1-\frac1N\Big)^{k}.$$

*Proof sketch.* By Theorem 4.1, $\frac1N\operatorname{tr}(W^{2k}) = \frac1N\sum_i (\lambda_i^2)^k$. The map $u \mapsto u^k$ is convex on $[0,\infty)$, so by Jensen's inequality (power-mean),

$$\frac1N\sum_i (\lambda_i^2)^k \;\ge\; \Big(\frac1N \sum_i \lambda_i^2\Big)^{k} \;=\; \Big(\frac{\operatorname{tr}(W^2)}{N}\Big)^{k} \;=\; (N-1)^k,$$

using Lemma 5.5. $\square$

**Theorem 5.7 (Two-sided sandwich).** For every $k \ge 1$ and every $N \ge 1$,

$$\Big(1-\frac1N\Big)^{k} \;\le\; \mathbb{E}\big[\widehat m_{2k}(W)\big] \;\le\; (k+1)^{2k}.$$

Thus $\mathbb{E}[\operatorname{tr}(W^{2k})]$ has exact order $N^{k+1}$: the even spectral moments neither vanish nor blow up in any dimension, and $\sqrt N$ is the correct normalisation at *every* order simultaneously.

---

## 6. Universality at order four and the variance of the second moment

### 6.1 The exact fourth trace moment

Consider a general entry law $\mathcal{L}$ with fourth moment $m_4$. Expanding $\operatorname{tr}(W^4)$ over closed $4$-walks $i \to j \to k \to l \to i$ and applying Corollary 4.8, only three families of walks survive:

* **(A)** $i \ne j$, $k = i$, $l \ne i$ arbitrary (possibly $\ne j$): walks of the form $i \to j \to i \to l \to i$, traversing two edges twice each; contribution $1$ each by Theorem 4.7 (with $\mu_2 = 1$). Their number is $N(N-1)^2$, and by symmetry the "other pairing" $i \to j \to k \to j \to i$ contributes another $N(N-1)^2$.
* **(B)** The overlap of the two families above, namely the degenerate walks $i \to j \to i \to j \to i$, has been counted twice and must be subtracted; those walks use a single edge four times.
* **(C)** The degenerate walks using one edge four times contribute $\mu_4 = m_4$ rather than $1$.

Careful bookkeeping of the overlaps yields:

**Theorem 6.1 (Exact universal fourth trace moment).** For every finitely supported centred unit-variance entry law $\mathcal{L}$ and every $N$,

$$\mathbb{E}_{\mathcal{L}}\big[\operatorname{tr}(W^4)\big] \;=\; 2N(N-1)^2 \;-\; 2N(N-1) \;+\; m_4\,N(N-1).$$

Consequently

$$\mathbb{E}_{\mathcal{L}}\big[\widehat m_4(W)\big] \;=\; \frac{(N-1)\big(2N-4+m_4\big)}{N^2} \;\xrightarrow[N\to\infty]{}\; 2 \;=\; C_2 \;=\; \sigma_4,$$

**independently of $m_4$**: the fourth spectral moment is universal, and the entry law only affects the $O(N^{-1})$ correction.

**Corollary 6.2 (Rademacher case).** For the sign ensemble, $m_4 = 1$ and

$$\mathbb{E}\big[\operatorname{tr}(W^4)\big] = 2N(N-1)^2 - N(N-1), \qquad \mathbb{E}\big[\widehat m_4(W)\big] = \frac{(N-1)(2N-3)}{N^2}.$$

For $N = 3$ this gives $18$ and for $N = 4$ it gives $60$, in exact agreement with the brute-force walk counts of Section 9.

The structural reading of Theorem 6.1 is the mechanism of universality in miniature: the entry distribution enters only through walks that traverse a single edge four times, and there are $O(N^2)$ of those against a leading term of order $N^3$. Universality is a statement about the *rarity of degenerate walks*.

### 6.2 Second moment: exact mean and variance

**Theorem 6.3 (Exact mean and variance).** For every entry law $\mathcal{L}$ and every $N \ge 1$,

$$\mathbb{E}_{\mathcal{L}}\big[\widehat m_2(W)\big] \;=\; 1 - \frac1N, \qquad \operatorname{Var}_{\mathcal{L}}\big(\widehat m_2(W)\big) \;=\; \frac{2(m_4-1)(N-1)}{N^{3}}.$$

*Proof sketch.* $\operatorname{tr}(W^2) = \sum_{i \ne j} W_{ij}^2$ is a sum of $N(N-1)$ terms, each with mean $\mu_2 = 1$; hence $\mathbb{E}[\operatorname{tr}(W^2)] = N(N-1)$ and $\mathbb{E}[\widehat m_2] = 1 - 1/N$. For the variance, note $\operatorname{tr}(W^2) = 2\sum_{e} v(\omega(e))^2$ is twice a sum of $\binom N2$ *independent* terms, each with variance $\mu_4 - \mu_2^2 = m_4 - 1$. Hence $\operatorname{Var}(\operatorname{tr}(W^2)) = 4\binom N2 (m_4-1) = 2N(N-1)(m_4-1)$, and dividing by $N^{4}$ (since $\widehat m_2 = \operatorname{tr}(W^2)/N^2$) gives the stated value. $\square$

**Corollary 6.4 (Rademacher: exact self-averaging).** For $m_4 = 1$ the variance vanishes identically, recovering Lemma 5.5: the second spectral moment of the sign ensemble is a constant, not merely concentrated. Among all centred unit-variance laws, the sign law is the unique minimiser of $m_4$, and hence of this variance.

---

## 7. Concentration and convergence of the second spectral moment

**Theorem 7.1 (Chebyshev's inequality for the ensemble).** For any real random variable $X$ on the configuration space, any $\mu \in \mathbb{R}$ and any $\varepsilon > 0$,

$$\varepsilon^2\,\mathbb{P}_{\mathcal{L}}\big[|X - \mu| \ge \varepsilon\big] \;\le\; \mathbb{E}_{\mathcal{L}}\big[(X-\mu)^2\big].$$

*Proof sketch.* Restrict the (finite, nonnegative-weighted) sum defining the right-hand side to the event, on which the integrand is at least $\varepsilon^2$. $\square$

**Theorem 7.2 (Quantitative finite-$N$ deviation rate).** For every $N \ge 1$ and every $t > 0$,

$$\mathbb{P}_{\mathcal{L}}\left[\Big|\widehat m_2(W) - \Big(1-\frac1N\Big)\Big| \ge t\right] \;\le\; \frac{2(m_4-1)(N-1)}{N^{3}\,t^{2}} \;=\; O\!\left(\frac{1}{N^{2}t^{2}}\right).$$

*Proof sketch.* Combine Theorems 7.1 and 6.5. $\square$

**Theorem 7.3 (Exact mean-square error and $L^2$ convergence).** For every $N \ge 1$,

$$\mathbb{E}_{\mathcal{L}}\Big[\big(\widehat m_2(W) - \sigma_2\big)^2\Big] \;=\; \underbrace{\frac{2(m_4-1)(N-1)}{N^3}}_{\text{variance}} \;+\; \underbrace{\frac{1}{N^{2}}}_{\text{squared bias}} \;\xrightarrow[N\to\infty]{}\; 0,$$

where $\sigma_2 = C_1 = 1$. Hence $\widehat m_2(W) \to 1$ in $L^2$, and a fortiori in probability:

$$\mathbb{P}_{\mathcal{L}}\big[|\widehat m_2(W) - \sigma_2| \ge \varepsilon\big] \;\longrightarrow\; 0 \qquad \text{for every } \varepsilon > 0 .$$

*Proof sketch.* Expand $(\widehat m_2 - 1)^2 = (\widehat m_2 - (1-\tfrac1N))^2 - \frac2N(\widehat m_2 - (1-\tfrac1N)) + \frac1{N^2}$ and take expectations, using that the middle term has mean zero. $\square$

**Theorem 7.4 (Eigenvalue-level form).** For every $N \ge 1$,

$$\mathbb{E}_{\mathcal{L}}\left[\frac1N\sum_{i=1}^{N}\left(\frac{\lambda_i}{\sqrt N}\right)^{2}\right] \;=\; 1 - \frac1N .$$

This is Theorem 6.3 restated through the bridge of Theorem 4.1: it is a statement about the empirical spectral distribution itself rather than about traces, and it is the $k=2$ case of the semicircle law, in a strong (exact, quantitative) form and for a general Wigner ensemble.

---

## 8. Localisation of the spectrum: bulk tightness and the edge

Moment bounds constrain not merely averages but the geometry of the spectrum, via Markov's inequality applied at two different levels.

**Theorem 8.1 (Deterministic Markov inequality for the ESD).** Let $A$ be any real symmetric $N \times N$ matrix ($N \ge 1$), $k \ge 0$, $t > 0$. Then

$$\frac{\#\{i : |\lambda_i(A)|/\sqrt N \ge t\}}{N} \;\le\; \frac{\widehat m_{2k}(A)}{t^{2k}} .$$

*Proof sketch.* Each eigenvalue with $|\lambda_i|/\sqrt N \ge t$ contributes at least $t^{2k}$ to $\sum_i (\lambda_i/\sqrt N)^{2k} = N \widehat m_{2k}(A)$, while all contributions are nonnegative. No probability is involved: this holds for every single matrix. $\square$

**Theorem 8.2 (Uniform bulk bound).** For the Rademacher ensemble, every $k \ge 1$, every $N \ge 1$ and every $t > 0$,

$$\mathbb{E}\left[\frac{\#\{i : |\lambda_i|/\sqrt N \ge t\}}{N}\right] \;\le\; \frac{(k+1)^{2k}}{t^{2k}},$$

a bound *independent of the dimension*.

*Proof sketch.* Average Theorem 8.1 and insert Theorem 5.4. $\square$

**Theorem 8.3 (Tightness of the empirical spectral distribution).** For every $\varepsilon > 0$ there exists $t > 0$ such that, for every dimension $N \ge 1$,

$$\mathbb{E}\left[\frac{\#\{i : |\lambda_i|/\sqrt N \ge t\}}{N}\right] \;\le\; \varepsilon .$$

*Proof sketch.* Fix $k = 1$ (or any $k$) in Theorem 8.2 and take $t$ large enough that $(k+1)^{2k}/t^{2k} \le \varepsilon$. $\square$

Tightness is precisely the compactness hypothesis under which convergence of all moments implies weak convergence of the measures: it rules out escape of mass to infinity, which moment convergence alone cannot exclude. It is thus the missing analytic half of the moment method, and here it is obtained from the same walk count that produces the moments.

**Theorem 8.4 (Spectral-edge tail).** For the Rademacher ensemble, every $k \ge 1$, $N \ge 1$, $t > 0$,

$$\mathbb{P}\big[\exists\, i : |\lambda_i| \ge t\sqrt N\big] \;\le\; \frac{N\,(k+1)^{2k}}{t^{2k}} .$$

*Proof sketch.* If some eigenvalue exceeds $t\sqrt N$ then $\operatorname{tr}(W^{2k}) \ge t^{2k}N^{k}$, since all terms $\lambda_i^{2k}$ are nonnegative. Apply Markov's inequality to the nonnegative random variable $\operatorname{tr}(W^{2k})$ and use Theorem 5.4. $\square$

The factor $N$ is the union-bound cost of asking about the *largest* eigenvalue rather than the bulk; the estimate becomes informative once $t$ grows with $k$, and optimising $k$ against $\log N$ gives a bounded edge up to logarithmic corrections. The crude constant $(k+1)^{2k}$, rather than the sharp $4^k$, is the price of the spanning-tree count.

**Theorem 8.5 (Deterministic edge lower bound).** For *every* configuration of the Rademacher ensemble and every $N \ge 1$ there exists an index $i$ with

$$\left(\frac{\lambda_i}{\sqrt N}\right)^{2} \;\ge\; 1 - \frac1N, \qquad\text{i.e.}\qquad \frac{\|W\|_{\mathrm{op}}}{\sqrt N} \;\ge\; \sqrt{1 - \frac1N}.$$

*Proof sketch.* By Lemma 5.5 the average of $(\lambda_i/\sqrt N)^2$ over the spectrum is exactly $1-1/N$; a finite average is attained or exceeded by some term. $\square$

There are no exceptional configurations here: the spectrum of a sign matrix *always* reaches out to distance at least $\sqrt{1-1/N}$ from the origin, in every realisation. Together with Theorem 8.4 this sandwiches the spectral radius from both sides.

---

## 9. Exact computations at small dimension

Because Theorem 4.5 turns expected trace moments into integers, they can be verified by exhaustive enumeration — both by enumerating even closed walks and, independently, by averaging exact rational traces over all $2^{N(N-1)/2}$ sign configurations. Both routes agree:

| $N$ | $m$ | even closed $m$-walks $= \mathbb{E}[\operatorname{tr}(W^m)]$ | closed-form check |
|---|---|---|---|
| $3$ | $3$ | $0$ | odd order (Theorem 4.6) |
| $3$ | $4$ | $18$ | $2N(N-1)^2 - N(N-1) = 24-6$ |
| $4$ | $4$ | $60$ | $2\cdot4\cdot9 - 12$ |
| $3$ | $5$ | $0$ | odd order |
| $2$ | $6$ | $2$ | only the walk $0\to1\to0\to1\to0\to1\to0$ and its reverse |
| $3$ | $6$ | $66$ | — |

These exact values were used to *guess* the closed-form finite-$N$ formulas of Sections 5–6 before proving them, and they are the data behind the sixth-moment conjecture of Section 11.

Notice the consistency of the sandwich of Theorem 5.7 with the table: for $N=3,k=2$ it reads $(2/3)^2 = 0.444 \le 18/3^3 = 0.667 \le 3^4 = 81$; for $N = 3, k=3$, $(2/3)^3 = 0.296 \le 66/3^4 = 0.815 \le 4^6$.

---

## 10. Algorithms

Three algorithmic primitives structure the computational side of this development.

**(A) Exhaustive walk enumeration.** To compute $\mathbb{E}[\operatorname{tr}(W^{m})]$ exactly, enumerate all $N^{m}$ closed $m$-walks (basepoint plus $m-1$ intermediate vertices), reject those containing a loop, tally edge multiplicities in a dictionary, and accept the walk when all multiplicities are even. Complexity $\Theta(N^{m} m)$ time and $O(m)$ space; feasible for the small cases of Section 9 and an unforgeable cross-check on the closed forms.

**(B) Exhaustive ensemble averaging.** Alternatively, enumerate all $2^{\binom N2}$ sign configurations, build $W$, compute $\operatorname{tr}(W^m)$ over exact rational (or integer) arithmetic, and average. Complexity $\Theta(2^{\binom N2}(N^3 \log m))$ using repeated squaring; feasible for $N \le 4$. Agreement with (A) tests the dichotomy of Theorem 4.4 empirically at every step.

**(C) Monte-Carlo spectral sampling.** For large $N$, sample the ensemble, diagonalise, and histogram the eigenvalues of $W/\sqrt N$. Complexity $\Theta(RN^3)$ for $R$ replicates. This is the route to visual confirmation of the semicircle and to empirical study of the fluctuation scale, the edge, and the universality claim across entry laws (Rademacher, Gaussian, uniform, sparse/heavy-tailed).

A fourth, purely arithmetical primitive is the Catalan recursion $C_{k+1} = \sum_{i \le k} C_i C_{k-i}$, which produces the target moments in $O(K^2)$ integer operations for all $k \le K$ and is used as the reference sequence in every numerical comparison.

---

## 11. Discussion and open problems

### 11.1 What the walk calculus gives

The moment method for Wigner matrices is classical, but the version developed here is unusually rigid. Every intermediate object is exact:

* the dichotomy (Theorem 4.4) is an identity, not an estimate;
* the odd moments vanish identically at every finite $N$ (Theorem 4.6), rather than asymptotically;
* the second moment of the sign ensemble is *deterministic* (Lemma 5.5), and the general variance formula (Theorem 6.3) identifies the sign law as the extremal, zero-variance case;
* the fourth trace moment is a polynomial in $N$ with a single $m_4$-dependent term (Theorem 6.1), so universality is visible as an explicit $O(N^{-1})$ correction rather than as a limit;
* the growth bound (Theorem 5.4) and the deterministic lower bound (Theorem 5.6) sandwich every even moment at every dimension.

The dichotomy also explains, structurally, *where* universality comes from: an entry law can only influence walks that reuse some edge at least three times, and such walks are too sparse — by the spanning-tree count — to contribute in the limit.

### 11.2 What remains open

The following are the natural next targets; each is a precise statement whose proof would complete or sharpen the picture.

**Conjecture 1 (Catalan asymptotics at all orders).** For every $k \ge 1$, the number of even closed $2k$-walks on $N$ vertices satisfies

$$\#\{\text{even closed } 2k\text{-walks}\} \;=\; C_k\,N^{k+1} + O_k(N^{k}),$$

equivalently $\mathbb{E}[\widehat m_{2k}(W)] \to C_k$. The upper bound of the correct *order* is Theorem 5.4; what is missing is the identification of the leading constant with the number of doubly-traversed labelled trees, i.e. the bijection between the extremal walks and balanced bracket sequences.

**Conjecture 2 (Sixth moment closed form).** There is a cubic polynomial identity
$\mathbb{E}[\operatorname{tr}(W^6)] = 5N^4 + aN^3 + bN^2 + cN$ with integer $a,b,c$ fitting the exact values $\mathbb{E}[\operatorname{tr}(W^6)] = 2$ at $N=2$ and $66$ at $N=3$ (and further values at $N = 4,5$). Proving it requires the same overlap bookkeeping as Theorem 6.1, one order higher.

**Conjecture 3 (Concentration at all orders).** For every $k$, $\operatorname{Var}(\widehat m_{2k}(W)) = O_k(N^{-2})$, so that each spectral moment converges in probability, not merely in mean. The case $k = 1$ is Theorem 6.3 (with variance exactly $0$ for the sign ensemble). The general case requires a two-walk (pair-of-walks) expansion in which the connected pairs are shown to be of lower order.

**Conjecture 4 (Weak convergence).** Combining Conjectures 1 and 3 with the tightness of Theorem 8.3 and the moment determinacy of the compactly supported semicircle law, the ESD of $W/\sqrt N$ converges weakly in probability to $\sigma$. The analytic ingredients (tightness, determinacy via the convolution recursion and its uniqueness, Theorem 3.6) are in place; the combinatorial input is Conjecture 1.

**Conjecture 5 (Sharp edge).** $\|W\|_{\mathrm{op}}/\sqrt N \to 2$ in probability. The lower bound $\liminf \ge 1$ is deterministic (Theorem 8.5) and follows from the second moment alone; reaching $2$ requires higher moments with $k$ growing like $\log N$, which in turn requires replacing the crude constant $(k+1)^{2k}$ of Theorem 5.4 by the sharp $C_k \le 4^k$.

### 11.3 Beyond the semicircle

Three directions extend the framework rather than complete it.

* **Sparse and structured ensembles.** If each edge is present with probability $p = p(N)$, the walk dichotomy survives verbatim with edge weights, and the transition at $Np \sim \log N$ between semicircular and non-semicircular bulk behaviour becomes a statement about which walk families dominate.
* **Correlated entries.** The involution of Theorem 4.4 only needs a sign symmetry of the joint law, not independence; ensembles invariant under flipping any single edge sign still satisfy the exact dichotomy, giving semicircular behaviour well outside the independent case.
* **Marchenko–Pastur and other limits.** Replacing closed walks on $K_N$ by closed walks on a bipartite graph turns the same calculus into the sample-covariance (Marchenko–Pastur) law, with Narayana numbers in place of Catalan numbers.

### 11.4 Applications

The semicircle law functions as a *noise floor*. In nuclear physics it was the original motivation: resonance level statistics of heavy nuclei track random-matrix predictions closely. In multivariate statistics and finance, the eigenvalues of a sample correlation matrix that fall inside the corresponding random-matrix bulk are treated as noise, and only those outside it as signal; this is the basis of eigenvalue-clipping estimators for covariance matrices. In numerical analysis, the edge bounds of Section 8 control the conditioning of random matrices and the convergence rate of Krylov methods. In machine learning, spectra of weight and Hessian matrices in deep networks are semicircular to first approximation, and the position of the edge governs the largest stable learning rate. In all these settings, universality is what makes the prediction usable: one needs only the variance of the entries, not their distribution.

---

## 12. Summary of results

| Result | Statement | Nature |
|---|---|---|
| Bridge | $\operatorname{tr}(A^k) = \sum_i \lambda_i^k$ for Hermitian $A$ | exact |
| Walk expansion | $\operatorname{tr}(A^{m+1}) = \sum_{\text{closed }(m+1)\text{-walks}} \prod_t A_{a_tb_t}$ | exact |
| Dichotomy | monomial average $=1$ iff loop-free and all multiplicities even, else $0$ | exact, all $N$ |
| Moments as counts | $\mathbb{E}[\operatorname{tr}(W^{m+1})] = \#\{\text{even closed } (m+1)\text{-walks}\}$ | exact, all $N$ |
| Odd moments | $\mathbb{E}[\operatorname{tr}(W^{2k+1})] = 0$ | exact, all $N$ |
| Growth | $\mathbb{E}[\widehat m_{2k}] \le (k+1)^{2k}$ | uniform in $N$ |
| Deterministic bound | $\operatorname{tr}(W^{2k}) \ge N(N-1)^k$ | every realisation |
| Sandwich | $(1-1/N)^k \le \mathbb{E}[\widehat m_{2k}] \le (k+1)^{2k}$ | all $N,k\ge1$ |
| Fourth moment | $\mathbb{E}[\operatorname{tr}(W^4)] = 2N(N-1)^2-2N(N-1)+m_4N(N-1)$ | exact, universal limit $2$ |
| Second moment | mean $1-1/N$, variance $2(m_4-1)(N-1)/N^3$ | exact |
| Concentration | $\mathbb{P}[|\widehat m_2 - (1-\tfrac1N)| \ge t] \le 2(m_4-1)(N-1)/(N^3t^2)$ | quantitative |
| $L^2$ convergence | $\mathbb{E}[(\widehat m_2-1)^2] = 2(m_4-1)(N-1)/N^3 + N^{-2} \to 0$ | exact MSE |
| Tightness | $\forall \varepsilon\ \exists t\ \forall N$: expected mass outside $[-t,t]$ is $\le\varepsilon$ | uniform in $N$ |
| Edge tail | $\mathbb{P}[\exists i: |\lambda_i| \ge t\sqrt N] \le N(k+1)^{2k}/t^{2k}$ | quantitative |
| Edge floor | every realisation has $|\lambda|/\sqrt N \ge \sqrt{1-1/N}$ | deterministic |
| Limit moments | $\sigma_{2k} = C_k$, $\sigma_{2k+1}=0$, $C_{k+1}=\sum_i C_iC_{k-i}$, recursion characterises $\sigma$ | exact |
