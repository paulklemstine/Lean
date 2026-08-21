# The Berggren Tree Zeta Function: Abscissa of Convergence, Counting Law, and the Failure of the Silver-Ratio Heuristic

**Aristotle**

**Date:** 2026-08-21

---

## Abstract

The Berggren (Barning–Hall) tree is the rooted ternary tree that generates every primitive Pythagorean triple exactly once from $(3,4,5)$ by three fixed integer matrices. Its metric growth is governed by the silver ratio: the dominant eigenvalue of the generators is $\lambda = 3+2\sqrt 2 = (1+\sqrt 2)^2$, the depth-$k$ layer has exactly $3^k$ nodes, and every hypotenuse at depth $k$ satisfies $c \le 2\lambda^{k+1}$, with equality of exponential order along the middle spine.

We introduce the **tree zeta function** $Z(s) = \sum_{w \in \{0,1,2\}^*} c(w)^{-s}$, summed over all nodes of the tree, and determine its abscissa of convergence exactly. The naive layer heuristic — $3^k$ nodes of size at most $\lambda^k$ — predicts the abscissa $\sigma_{\text{silver}} = \log 3/\log(3+2\sqrt2) = 0.62324\ldots$. We prove that this prediction is **false**: the true abscissa is exactly $1$. Convergence for $s>1$ follows from a two-dimensional majorant in Euclid-seed coordinates; divergence for $s \le 1$ follows from embedding the family of prime seeds $(p,2j)$, $2j<p$, into the tree and invoking the divergence of $\sum_p 1/p$. Quantitatively, for every $s$ in $(\sigma_{\text{silver}}, 1]$ the layer majorant converges while $Z(s)$ diverges.

We complement this with an explicit counting law: writing $N(H)$ for the number of nodes with hypotenuse at most $H$, we prove $H/50 \le N(H) \le 2H$ for all $H \ge 512$, so $N(H) = \Theta(H)$. The lower bound is an elementary coprimality-and-parity sieve on the Euclid triangle. We then establish a Tauberian bridge: a $128$-adic block argument shows that the counting law *alone* forces $\sum_w c(w)^{-1} = \infty$, with the explicit rate $\sum_{c(w) \le 512\cdot 128^k} c(w)^{-1} \ge k/300$, yielding an independent proof that the abscissa is at least $1$.

Finally we show that the two **leg** zeta functions $Z_a(s) = \sum_w a(w)^{-s}$ and $Z_b(s) = \sum_w b(w)^{-s}$ also have abscissa exactly $1$, by a genuinely two-dimensional $\zeta(s)^2$ majorant along two distinct reindexings of the seed lattice — the legs are not comparable to the hypotenuse from below, so the hypotenuse result cannot be inherited.

The structural conclusion is that the layer maximum is a catastrophically poor proxy for a typical node: within layer $k$ the hypotenuse ranges from $2k^2+6k+5$ on the slow spine to $\asymp \lambda^k$ on the fast spine. Any zeta function of such a tree is governed by the *distribution* of word statistics, not by the top eigenvalue alone. We conclude with a conjectural refinement, $N(H) \sim H/(2\pi)$, supported by numerics accurate to six digits and by a Gauss-circle-plus-sieve heuristic, which would give $Z(s)$ a simple pole at $s=1$ with residue $1/(2\pi)$.

**Keywords:** Pythagorean triples, Berggren tree, Barning–Hall tree, Dirichlet series, abscissa of convergence, silver ratio, Pell numbers, lattice-point counting, Tauberian theorem.

---

## 1. Introduction

### 1.1 The tree

A **primitive Pythagorean triple** is a triple $(a,b,c)$ of positive integers with $a^2+b^2=c^2$ and $\gcd(a,b)=1$. Berggren (1934), and independently Barning (1963) and Hall (1970), observed that the set of all such triples with $a$ odd carries the structure of a rooted infinite ternary tree: from the root $(3,4,5)$, apply the three matrices

$$
A_1 = \begin{pmatrix} 1 & -2 & 2\\ 2 & -1 & 2 \\ 2 & -2 & 3\end{pmatrix},\qquad
A_2 = \begin{pmatrix} 1 & 2 & 2\\ 2 & 1 & 2 \\ 2 & 2 & 3\end{pmatrix},\qquad
A_3 = \begin{pmatrix} -1 & 2 & 2\\ -2 & 1 & 2 \\ -2 & 2 & 3\end{pmatrix}
$$

to the column vector $(a,b,c)^{T}$. Each $A_i$ maps primitive triples to primitive triples, no triple is produced twice, and every primitive triple with odd first leg is produced exactly once. The depth-$k$ layer therefore contains exactly $3^k$ triples.

The common characteristic polynomial of $A_1, A_2, A_3$ (restricted to the relevant invariant structure) has the eigenvalue pair
$$\lambda = 3+2\sqrt 2 \approx 5.82843, \qquad \lambda' = 3-2\sqrt 2 = \lambda^{-1} \approx 0.17157,$$
and $\lambda = \delta_S^2$ where $\delta_S = 1+\sqrt 2$ is the **silver ratio**.

### 1.2 The question

Given a family of arithmetic objects with a size function, the natural analytic invariant is the associated Dirichlet series and its abscissa of convergence. For the Berggren tree with the hypotenuse as size, this is
$$Z(s) \;=\; \sum_{w \in \{0,1,2\}^*} c(w)^{-s},$$
the sum over all finite words in three letters, $c(w)$ being the hypotenuse at node $w$.

The obvious heuristic groups the sum by depth. Layer $k$ has $3^k$ nodes, each of size at most $\asymp \lambda^k$, so
$$Z(s) \;\lesssim\; \sum_{k\ge 0} 3^k \lambda^{-ks},$$
convergent precisely when $s > \log 3/\log\lambda$. This suggests the abscissa
$$\sigma_{\text{silver}} \;=\; \frac{\log 3}{\log(3+2\sqrt2)} \;=\; 0.6232438\ldots,$$
an exponent of the shape $\log(\text{branching})/\log(\text{growth})$ familiar from the Hausdorff dimensions of self-similar sets and from the entropy of dynamical zeta functions. The purpose of this paper is to determine the truth.

### 1.3 Results

**Theorem A (Abscissa).** $Z(s)$ converges if and only if $s>1$. Its abscissa of convergence equals $1$.

**Theorem B (Refutation, quantitative).** $\sigma_{\text{silver}} < 1$, and for every $s \in (\sigma_{\text{silver}}, 1]$ the layer majorant $\sum_k 3^k(2\lambda^{k+1})^{-s}$ converges while $Z(s)$ diverges.

**Theorem C (Counting law).** For all $H \ge 512$, $\;H/50 \le N(H) \le 2H$, where $N(H) = \#\{w : c(w) \le H\}$. In particular $N(H) = \Theta(H)$.

**Theorem D (Tauberian bridge).** The counting law of Theorem C alone implies $\sum_w c(w)^{-1} = \infty$, with the explicit rate $\sum_{c(w) \le 512\cdot128^k} c(w)^{-1} \ge k/300$; hence the abscissa is at least $1$, independently of the prime-seed argument.

**Theorem E (Legs).** The odd-leg and even-leg zeta functions also have abscissa exactly $1$.

Alongside these we record the metric facts that motivate the heuristic and explain its failure:

**Theorem F (Silver speed limit).** Every node at depth $k$ satisfies $c \le 2\lambda^{k+1}$.

**Theorem G (Spectral spine).** Along the middle spine the hypotenuses satisfy $c_{k+2} = 6c_{k+1}-c_k$, with the exact closed form
$$c_k = \frac{(10+7\sqrt 2)\lambda^k + (10-7\sqrt2)\lambda'^{\,k}}{4} \in \{5,29,169,985,5741,\ldots\},$$
the odd-indexed Pell numbers; consequently $\log c_k / k \to \log\lambda = 2\log(1+\sqrt 2)$.

---

## 2. Euclid-seed coordinates

All of the structure theory becomes elementary in the classical Euclid parametrisation.

**Definition 2.1 (Euclid seed).** A pair $p = (m,n) \in \mathbb{N}^2$ is a **Euclid seed** if
$$0 < n < m, \qquad \gcd(m,n) = 1, \qquad m+n \text{ odd}.$$
We write $\mathcal{S}$ for the set of Euclid seeds.

**Definition 2.2.** The triple and hypotenuse attached to a seed are
$$\mathrm{tri}(m,n) = (m^2-n^2,\ 2mn,\ m^2+n^2), \qquad h(m,n) = m^2+n^2.$$

**Proposition 2.3 (Euclid).** For $(m,n) \in \mathcal{S}$, $\mathrm{tri}(m,n)$ is a primitive Pythagorean triple with positive legs and odd first leg.

*Proof sketch.* Positivity and the Pythagorean identity are algebra. Oppositeness of parity forces $m^2-n^2$ odd. If a prime $q$ divided both $m^2-n^2$ and $2mn$, then $q \ne 2$ (as the first is odd), so $q \mid mn$; whichever of $m,n$ it divides, adding or subtracting $m^2-n^2$ shows it divides the other as well, contradicting $\gcd(m,n)=1$. $\square$

**Definition 2.4 (Seed moves).** Define $s_0, s_1, s_2 : \mathbb{N}^2 \to \mathbb{N}^2$ by
$$s_0(m,n) = (2m-n,\ m), \qquad s_1(m,n) = (2m+n,\ m), \qquad s_2(m,n) = (m+2n,\ n).$$
For a word $w = i_1 i_2 \cdots i_k \in \{0,1,2\}^*$ set
$$\mathrm{nd}(\varepsilon) = (2,1), \qquad \mathrm{nd}(i \cdot w) = s_i(\mathrm{nd}(w)),$$
and $c(w) = h(\mathrm{nd}(w))$.

**Theorem 2.5 (The dictionary).** For all integers $m,n$, with $(a,b,c) = (m^2-n^2, 2mn, m^2+n^2)$,
$$\mathrm{tri}(s_0(m,n)) = A_1 (a,b,c)^T, \quad \mathrm{tri}(s_1(m,n)) = A_2 (a,b,c)^T, \quad \mathrm{tri}(s_2(m,n)) = A_3 (a,b,c)^T.$$

*Proof sketch.* Three polynomial identities in $\mathbb{Z}[m,n]$, verified by expansion. For instance the hypotenuse coordinate of the first reads $(2m-n)^2+m^2 = 2(m^2-n^2)-4mn+3(m^2+n^2)$, which is $5m^2-4mn+n^2$ on both sides. $\square$

So the seed moves *are* the Barning matrices, transported through Euclid's parametrisation. From here on we work exclusively with seeds.

**Lemma 2.6 (Invariance).** If $p \in \mathcal S$ then $s_i(p) \in \mathcal S$ for $i = 0,1,2$.

*Proof sketch.* Ordering and positivity are immediate from $0<n<m$. For coprimality of, say, $s_1(m,n) = (2m+n,m)$: any common divisor $d$ of $2m+n$ and $m$ divides $(2m+n)-2m = n$, hence divides $\gcd(m,n)=1$. Parity: $(2m+n)+m \equiv m+n \pmod 2$ in the first two cases and $(m+2n)+n \equiv m+n$ in the third. $\square$

**Lemma 2.7 (Sector separation).** The three moves have disjoint images, distinguished by the ratio of coordinates: writing $(M,N) = s_i(m,n)$ with $(m,n)\in\mathcal S$, we have $M < 2N$ if $i=0$, $2N < M < 3N$ if $i=1$, and $M > 3N$ if $i=2$.

*Proof sketch.* $s_0$: $(M,N) = (2m-n,m)$ and $2m-n < 2m$. $s_1$: $(M,N) = (2m+n,m)$, and $2m < 2m+n < 3m$ since $0<n<m$. $s_2$: $(M,N) = (m+2n,n)$, and $m+2n > 3n$ since $m>n$. $\square$

**Definition 2.8 (Inverse moves).** $u_0(M,N) = (N, 2N-M)$, $u_1(M,N) = (N, M-2N)$, $u_2(M,N) = (M-2N, N)$; then $u_i(s_i(p)) = p$ for $p \in \mathcal S$.

**Theorem 2.9 (Injectivity).** The map $w \mapsto \mathrm{nd}(w)$ from $\{0,1,2\}^*$ to $\mathcal S$ is injective. Consequently the depth-$k$ layer has exactly $3^k$ distinct nodes.

*Proof sketch.* Induction on word length. The first coordinate strictly increases under every move (each of $2m-n$, $2m+n$, $m+2n$ exceeds $m$ when $0<n<m$), and the root has first coordinate $2$, so a nonempty word cannot equal the root. For two nonempty words $i\cdot w_1$ and $j\cdot w_2$ with equal nodes, Lemma 2.7 gives $i=j$, and applying $u_i$ gives $\mathrm{nd}(w_1) = \mathrm{nd}(w_2)$; induction concludes. The layer count is then $|\{0,1,2\}^k| = 3^k$. $\square$

**Theorem 2.10 (Barning–Hall completeness).** Every Euclid seed is a node: $\mathrm{nd}$ is a bijection $\{0,1,2\}^* \to \mathcal S$.

*Proof sketch.* Strong induction on $m$. If $m=2$ then $n=1$ and $p$ is the root. Otherwise, coprimality rules out $m=2n$ and $m=3n$ except in the root case, so exactly one of $m<2n$, $2n<m<3n$, $m>3n$ holds. In each case the corresponding inverse move $u_i(p)$ is again a Euclid seed (coprimality transfers by the same divisor manipulation as in Lemma 2.6) with strictly smaller first coordinate, and the induction hypothesis supplies a word for it. $\square$

Theorems 2.9 and 2.10 justify the interchangeable use of "sum over nodes of the tree" and "sum over Euclid seeds". This is the technical heart of everything that follows: **the tree is a bijective relabelling of a two-dimensional arithmetic lattice**, and it is the lattice, not the branching, that governs the analysis.

---

## 3. The silver speed limit and the spectral spine

**Definition 3.1 (Silver potential).** For $p = (m,n)$ set $\Phi(p) = m + (\sqrt2 - 1)n$.

**Lemma 3.2 (Contraction).** For every $p \in \mathcal S$ and every $i$, $\Phi(s_i(p)) \le (1+\sqrt2)\,\Phi(p)$, with equality for $i=1$.

*Proof sketch.* Write $\sigma = \sqrt 2$, so $\sigma^2 = 2$. For $i=1$:
$$\Phi(2m+n,m) = 2m+n+(\sigma-1)m = (1+\sigma)m + n = (1+\sigma)\bigl(m + (\sigma-1)n\bigr),$$
using $(1+\sigma)(\sigma-1) = \sigma^2-1 = 1$. This is an exact identity — hence the middle spine is extremal. For $i=0$, $\Phi(2m-n,m) = (1+\sigma)m - n \le (1+\sigma)m + n$, so the bound holds a fortiori. For $i=2$, $\Phi(m+2n,n) = m+(1+\sigma)n$, and one checks $m + (1+\sigma) n \le (1+\sigma) m + n$ using $n \le m$ and $\sigma > 0$. $\square$

**Theorem 3.3 (Silver speed limit).** For every word $w$ of length $k$,
$$\Phi(\mathrm{nd}(w)) \le (1+\sqrt2)^{k+1}, \qquad\text{hence}\qquad c(w) \;\le\; 2\,\lambda^{k+1}, \quad \lambda = 3+2\sqrt2 .$$

*Proof sketch.* The root has $\Phi(2,1) = 1+\sqrt 2$, and Lemma 3.2 gives the first bound by induction. Since $m \le \Phi(m,n)$ and $n \le m$, we get $c = m^2+n^2 \le 2m^2 \le 2\bigl((1+\sqrt2)^{k+1}\bigr)^2 = 2\lambda^{k+1}$, using $\lambda = (1+\sqrt2)^2$. $\square$

**Theorem 3.4 (Spine recurrence and closed form).** Let $c_k = c(1^k)$ be the hypotenuse along the middle spine. Then the seed at depth $k$ is $(P_{k+1}, P_k)$ with $P$ the Pell numbers ($P_0=1$, $P_1=2$, $P_{k+2} = 2P_{k+1}+P_k$), and
$$c_{k+2} = 6c_{k+1} - c_k, \qquad c_k = \frac{(10+7\sqrt2)\lambda^k + (10-7\sqrt2)\lambda'^{\,k}}{4},$$
where $\lambda,\lambda' = 3\pm2\sqrt2$ are the roots of $x^2-6x+1$. Explicitly $c_k = 5, 29, 169, 985, 5741, 33461, \ldots$

*Proof sketch.* The seed identity is immediate from $s_1(P_{k+1},P_k) = (2P_{k+1}+P_k, P_{k+1}) = (P_{k+2},P_{k+1})$. Then $c_k = P_{k+1}^2 + P_k^2$, and substituting the Pell recurrence into $c_{k+2}+c_k$ gives $6c_{k+1}$ after expansion. The closed form follows by verifying it at $k=0,1$ ($c_0 = 5$, $c_1 = 29$) and noting that both sides satisfy the same second-order recurrence, since $\lambda^2 = 6\lambda-1$ and $\lambda'^2 = 6\lambda'-1$. $\square$

**Corollary 3.5 (Exact growth exponent).** $4\lambda^k \le c_k \le 6\lambda^k$ for all $k$, hence
$$\frac{\log c_k}{k} \longrightarrow \log \lambda = \log(3+2\sqrt2) = 2\log(1+\sqrt 2) \approx 1.76275 .$$
Combined with Theorem 3.3, the maximal hypotenuse $M_k$ in layer $k$ satisfies $\log M_k / k \to \log\lambda$: **the layer maximum grows exactly at the square-of-the-silver-ratio rate.**

*Proof sketch.* From the closed form, $0 < \lambda'^{\,k} \le 1$ and $\lambda^k \ge 1$, and $10 \pm 7\sqrt2 \approx 19.9, 0.1$; the two-sided bound follows by linear arithmetic. Taking logarithms and dividing by $k$ squeezes the limit. $\square$

Theorem 3.3 and Corollary 3.5 are exactly the inputs to the silver-ratio heuristic. They are true. The heuristic built on them is not.

---

## 4. The abscissa of convergence

**Definition 4.1.** For $s \in \mathbb R$ let $Z(s) = \sum_{w\in\{0,1,2\}^*} c(w)^{-s}$, and let
$$\sigma_Z = \inf\{s \in \mathbb R : \textstyle\sum_w c(w)^{-s} \text{ converges}\}$$
be its **abscissa of convergence**. All terms are positive, so convergence means absolute convergence and the order of summation is irrelevant.

### 4.1 Convergence for $s>1$

**Lemma 4.2 (Two-dimensional majorant).** For $s>1$ the family
$$F(m,n) = \begin{cases} m^{-2s}, & n<m,\\ 0,& \text{otherwise},\end{cases}$$
is summable over $\mathbb{N}^2$, with $\sum_{m,n} F(m,n) = \sum_{m\ge1} m^{1-2s} = \zeta(2s-1)$.

*Proof sketch.* For fixed $m$ only the $m$ values $n = 0,\ldots,m-1$ contribute, each equal to $m^{-2s}$, so the row sum is $m \cdot m^{-2s} = m^{1-2s}$. Since $s>1$ gives $2s-1>1$, the resulting one-dimensional series converges, and nonnegativity permits summing by rows. $\square$

**Lemma 4.3 (Domination).** For $s>0$ and $p=(m,n)\in\mathcal S$, $\;h(p)^{-s} \le F(m,n)$.

*Proof sketch.* $h(p) = m^2+n^2 \ge m^2$ and $x \mapsto x^{-s}$ is decreasing on $(0,\infty)$, so $h(p)^{-s} \le (m^2)^{-s} = m^{-2s}$; and $n<m$ holds for seeds. $\square$

**Theorem 4.4 (Convergence).** $Z(s) < \infty$ for every $s>1$.

*Proof sketch.* By Theorem 2.10 the sum over words equals the sum over $\mathcal S$; by Lemma 4.3 it is dominated termwise by the restriction of $F$ to $\mathcal S$, which is summable by Lemma 4.2. $\square$

Note the mechanism: the bound is $Z(s) \le \zeta(2s-1)$, an estimate in which the ternary branching plays no role whatsoever.

### 4.2 Divergence for $s \le 1$

**Definition 4.5 (Prime seeds).** For an odd prime $p$ and an integer $j$ with $1 \le j$ and $2j < p$, set $q_{p,j} = (p, 2j)$.

**Lemma 4.6.** Each $q_{p,j}$ is a Euclid seed, hence a node of the tree, and $h(q_{p,j}) = p^2+4j^2 \le 2p^2$.

*Proof sketch.* $0 < 2j < p$ is the hypothesis. Coprimality: $p$ is prime and $0 < 2j < p$, so $p \nmid 2j$. Parity: $p$ odd and $2j$ even give $p+2j$ odd. The size bound is $4j^2 \le p^2$. $\square$

**Theorem 4.7 (Divergence at $s=1$).** $\sum_{w} c(w)^{-1} = \infty$.

*Proof sketch.* Suppose the sum were finite. Transporting to seeds and restricting to the injectively-indexed subfamily $\{q_{p,j}\}$ (injective since $(p,2j)$ determines $(p,j)$), we would get
$$\sum_{p \text{ odd prime}} \ \sum_{j=1}^{(p-1)/2} \frac{1}{p^2+4j^2} < \infty .$$
Each inner term is at least $1/(2p^2)$ by Lemma 4.6, and there are $(p-1)/2$ of them, so the inner sum is at least
$$\frac{p-1}{2}\cdot\frac{1}{2p^2} = \frac{p-1}{4p^2} \ \ge\ \frac{1}{8p} \qquad (p \ge 3),$$
since $p-1 \ge p/2$ for $p\ge 2$. Hence $\sum_{p} 1/(8p) < \infty$, contradicting Euler's theorem that the sum of prime reciprocals diverges. $\square$

**Lemma 4.8 (Monotonicity).** If $s \le 1$ then $c(w)^{-1} \le c(w)^{-s}$ for every $w$, since $c(w) \ge 1$.

**Theorem 4.9 (Abscissa).** $Z(s)$ converges if and only if $s>1$; hence $\sigma_Z = 1$.

*Proof.* Theorem 4.4 gives convergence for $s>1$. If $s \le 1$ and $Z(s)$ converged, Lemma 4.8 and comparison would give convergence at $s=1$, contradicting Theorem 4.7. Thus $\{s : Z(s)<\infty\} = (1,\infty)$ and its infimum is $1$. $\square$

### 4.3 Refutation of the silver-ratio prediction

**Definition 4.10.** $\sigma_{\text{silver}} = \dfrac{\log 3}{\log \lambda} = \dfrac{\log 3}{\log(3+2\sqrt2)}$.

**Theorem 4.11 (Layer majorant).** For every $s > \sigma_{\text{silver}}$ the layer majorant converges:
$$\sum_{k\ge 0} 3^k \bigl(2\lambda^{k+1}\bigr)^{-s} \;=\; 2^{-s}\lambda^{-s}\sum_{k\ge 0}\bigl(3\lambda^{-s}\bigr)^{k} \;<\;\infty .$$

*Proof sketch.* $s\log\lambda > \log 3$ gives $3\lambda^{-s} = \exp(\log 3 - s\log\lambda) < 1$, so the geometric series converges; the prefactor is the $k$-independent constant $2^{-s}\lambda^{-s}$. $\square$

**Theorem 4.12.** $\sigma_{\text{silver}} < 1$; numerically $\sigma_{\text{silver}} = 0.6232438\ldots$

*Proof sketch.* $\lambda = 3+2\sqrt 2 > 3$, so $\log\lambda > \log 3 > 0$ and the quotient is $<1$. $\square$

**Theorem 4.13 (Refutation).** $\sigma_{\text{silver}} < \sigma_Z = 1$. Moreover, for every $s$ with $\sigma_{\text{silver}} < s \le 1$, the layer majorant converges while $Z(s)$ diverges.

*Proof.* Combine Theorems 4.9, 4.11, 4.12 and 4.9's divergence half. $\square$

**Interpretation.** The estimate "layer $k$ has $3^k$ nodes each of size $\le 2\lambda^{k+1}$" is sharp only for the fastest node in the layer. The rest of the layer is exponentially smaller, so replacing every node by the maximum turns a *lower* bound on the terms into an enormous *underestimate* of the sum. Concretely:

| depth $k$ | $\#$nodes $3^k$ | min $c$ | median $c$ | max $c$ | max/min |
|---|---|---|---|---|---|
| 4 | 81 | 61 | 949 | 5{,}741 | 94 |
| 8 | 6{,}561 | 181 | 166{,}025 | 6{,}625{,}109 | $3.7\times10^4$ |
| 12 | 531{,}441 | 365 | 28{,}529{,}485 | 7{,}645{,}370{,}045 | $2.1\times10^7$ |

The minimum in layer $k$ is exactly $2k^2+6k+5$, attained on the **slow spine** $s_0^k$, whose seed is $(k+2,k+1)$: quadratic, not exponential. Between the two spines the layer distribution is spread across a range that grows exponentially in $k$, and it is that distribution — not $\lambda$ — which the zeta function integrates.

---

## 5. The counting law

**Definition 5.1.** $N(H) = \#\{p \in \mathcal S : h(p) \le H\} = \#\{w : c(w) \le H\}$.

**Theorem 5.2 (Upper bound).** $N(H) \le 2H$ for every $H$.

*Proof sketch.* If $h(p) = m^2+n^2 \le H$ with $0<n<m$ then $m \le K := \lfloor\sqrt H\rfloor$ and $n \le m$, so the seeds below $H$ inject into $\{1,\ldots,K\}\times\{0,\ldots,K\}$, of cardinality $K(K+1) = K^2+K \le H + H = 2H$ (using $K^2 \le H$ and $K \le H$). $\square$

The lower bound is a sieve on the Euclid triangle.

**Definition 5.3.** $T_M = \{(m,n) : 1 \le n < m \le M\}$, $\;C_M = \{p \in T_M : \gcd(m,n)=1\}$, $\;O_M = \{p \in C_M : m+n \text{ odd}\}$, and for $d \ge 2$, $B_{M,d} = \{p \in T_M : d\mid m,\ d \mid n\}$.

**Lemma 5.4.** $|T_M| = M(M-1)/2$.

**Lemma 5.5 (Divisor sets are small).** For $d \ge 2$, the map $(m,n)\mapsto(m/d,n/d)$ injects $B_{M,d}$ into $T_{\lfloor M/d\rfloor}$, so $|B_{M,d}| \le \frac{1}{2}\lfloor M/d\rfloor^2 \le \frac{M^2}{2d^2}$.

**Lemma 5.6 (Tail estimate).** $\sum_{d=2}^{M} d^{-2} \le 25/36$ for every $M$.

*Proof sketch.* Induction with the telescoping bound $\frac{1}{(d+1)^2} \le \frac1d - \frac1{d+1}$: one shows $\sum_{d=2}^{M} d^{-2} \le \frac{25}{36} - \frac1M$ for $M \ge 3$, the base case $M=3$ being $\frac14+\frac19 = \frac{13}{36} \le \frac{25}{36}-\frac13$. $\square$

**Proposition 5.7 (Coprime count).** $|C_M| \ \ge\ \frac{11}{72}M^2 - \frac M2$.

*Proof sketch.* Every non-coprime pair in $T_M$ lies in $B_{M,d}$ for $d = \gcd(m,n) \ge 2$, so
$$|T_M| \le |C_M| + \sum_{d=2}^{M}|B_{M,d}| \le |C_M| + \frac{M^2}{2}\sum_{d\ge2}\frac1{d^2} \le |C_M| + \frac{25}{72}M^2 ,$$
using Lemmas 5.5 and 5.6. With $|T_M| = \frac{M^2-M}{2}$ this gives $|C_M| \ge \frac{M^2}{2} - \frac M2 - \frac{25}{72}M^2 = \frac{11}{72}M^2 - \frac M2$. $\square$

**Proposition 5.8 (Parity halving).** $|C_M| \le 2|O_M|$.

*Proof sketch.* A coprime pair cannot be even–even, so $C_M$ splits into the opposite-parity pairs $O_M$ and the odd–odd pairs. On the latter, the map
$$(m,n) \;\longmapsto\; \Bigl(\tfrac{m+n}2,\ \tfrac{m-n}2\Bigr)$$
is well defined (both entries are integers), lands in $C_M$ (any common divisor of the images divides their sum $m$ and difference $n$), produces an opposite-parity pair (their sum is $m$, which is odd), and is injective (one recovers $(m,n)$ as sum and difference). Hence $|{\rm odd\text{-}odd}| \le |O_M|$ and $|C_M| \le 2|O_M|$. $\square$

**Theorem 5.9 (Sieve lower bound).** $N(2M^2) \ \ge\ \frac{11}{144}M^2 - \frac M4$.

*Proof.* $O_M$ consists precisely of Euclid seeds with $m \le M$, each of which has $h = m^2+n^2 \le 2M^2$; so $|O_M| \le N(2M^2)$. Combine with Propositions 5.7 and 5.8. $\square$

**Theorem 5.10 (Counting law).** For every $H \ge 512$,
$$\frac{H}{50} \;\le\; N(H) \;\le\; 2H .$$

*Proof sketch.* Put $M = \lfloor\sqrt{H/2}\rfloor$, so that $2M^2 \le H$ and, since $H \ge 512$, $M \ge 16$. Monotonicity of $N$ and Theorem 5.9 give $N(H) \ge N(2M^2) \ge \frac{11}{144}M^2 - \frac M4$. On the other side, maximality of $M$ gives $H/2 < (M+1)^2$, i.e. $H \le 2(M+1)^2$, so it suffices to check
$$\frac{11}{144}M^2 - \frac M4 \;\ge\; \frac{2(M+1)^2}{50} = \frac{(M+1)^2}{25},$$
which rearranges to $\bigl(\frac{11}{144}-\frac1{25}\bigr)M^2 \ge \frac{M}{4} + \frac{2M}{25} + \frac1{25}$ and holds for every $M \ge 16$ (at $M=16$: $15.56 \ge 11.56$). The upper bound is Theorem 5.2. $\square$

This is precisely the counting statement encoded by Theorem 4.9: an abscissa at $1$ corresponds to a counting function of order $H^1$. Had the silver heuristic been right, we would have found $N(H) \asymp H^{0.6232}$, which the sieve flatly contradicts.

---

## 6. A Tauberian bridge

Theorems 4.9 and 5.10 were proved by disjoint methods: primes and Euler on one side, a coprimality sieve on the other. We now show that the counting law by itself implies the analytic divergence, with an explicit rate. Write
$$h_{\text{sum}}(H) = \sum_{c(w) \le H} \frac{1}{c(w)} .$$

**Lemma 6.1 (Block estimate).** For every $H \ge 512$,
$$h_{\text{sum}}(128H) \;\ge\; h_{\text{sum}}(H) + \frac1{300}.$$

*Proof sketch.* The nodes counted by $h_{\text{sum}}(128H)$ but not by $h_{\text{sum}}(H)$ number
$$N(128H) - N(H) \ \ge\ \frac{128H}{50} - 2H \;=\; 0.56\,H,$$
by Theorem 5.10 applied at $128H \ge 512$ and at $H$. Each of them has $c \le 128H$, hence contributes at least $1/(128H)$. The block therefore contributes at least $0.56H/(128H) = 0.004375 > 1/300$. $\square$

**Theorem 6.2 (Explicit divergence rate).** For every $k \ge 0$,
$$h_{\text{sum}}\bigl(512\cdot 128^{k}\bigr) \;\ge\; \frac{k}{300}.$$
In particular $h_{\text{sum}}(H) \to \infty$; indeed $h_{\text{sum}}(H) \gg \log H$.

*Proof.* Induction on $k$, the step being Lemma 6.1 applied at $H = 512\cdot128^k \ge 512$. Since $k \asymp \log H / \log 128$, the logarithmic rate follows. $\square$

**Corollary 6.3 (Independent proof of $\sigma_Z \ge 1$).** $\sum_w c(w)^{-1} = \infty$, and hence $\sigma_Z \ge 1$, without using primes.

*Proof.* Every truncation $h_{\text{sum}}(H)$ is a partial sum of the nonnegative series $Z(1)$, hence bounded by $Z(1)$ if the latter converged; Theorem 6.2 makes the truncations unbounded. Monotonicity (Lemma 4.8) then rules out convergence for every $s \le 1$. $\square$

This is a Tauberian statement in miniature: an order-of-magnitude counting law on the arithmetic side is converted into a divergence statement on the analytic side, with all constants explicit. Its content is that **the abscissa is determined by the counting function alone**, so any correct prediction of the abscissa must correctly predict the growth of $N(H)$ — which the layer heuristic does not.

---

## 7. The leg zeta functions

Each node carries two legs, $a(w) = m^2-n^2$ (odd) and $b(w) = 2mn$ (even), where $(m,n) = \mathrm{nd}(w)$. Define
$$Z_a(s) = \sum_w a(w)^{-s}, \qquad Z_b(s) = \sum_w b(w)^{-s},$$
with abscissae $\sigma_a$, $\sigma_b$.

**Lemma 7.1.** For $p \in \mathcal S$: $1 \le a(p) \le h(p)$ and $1 \le b(p) \le h(p)$.

*Proof sketch.* $m > n \ge 1$ gives $m^2-n^2 \ge 1$ and $2mn \ge 2$. The upper bounds are $m^2-n^2 \le m^2+n^2$ and $2mn \le m^2+n^2$ (AM–GM). $\square$

**Theorem 7.2 (Divergence).** For $s \le 1$, both $Z_a(s)$ and $Z_b(s)$ diverge.

*Proof sketch.* By Lemma 7.1, $a(w)^{-1} \ge c(w)^{-1}$ and $b(w)^{-1} \ge c(w)^{-1}$, so both series dominate $Z(1)$, which diverges by Theorem 4.7. Monotonicity in $s$ extends this to $s \le 1$. $\square$

Convergence for $s>1$ requires a new idea. The naive attempt — deduce it from $Z(s)<\infty$ — fails, because the legs are *not* bounded below by a constant multiple of $c$:

- along the spine $s_2^k$ the seed is $(2k+2,1)$, so $b = 2(2k+2)$ is linear while $c = (2k+2)^2+1$ is quadratic: $b/c \to 0$;
- along the slow spine $s_0^k$ the seed is $(k+2,k+1)$, so $a = 2k+3$ is linear while $c = 2k^2+6k+5$ is quadratic: $a/c \to 0$.

The resolution uses the *multiplicative* structure of the legs.

**Lemma 7.3 (Product lower bounds).** For $p = (m,n) \in \mathcal S$,
$$b(p) = 2mn \ \ge\ m \cdot n, \qquad a(p) = (m-n)(m+n) \ \ge\ (m-n)\cdot m .$$

**Lemma 7.4 (Product majorant).** For $s>1$, $\;\sum_{u,v \ge 1} u^{-s}v^{-s} = \zeta(s)^2 < \infty$. If $u,v \ge 1$ and $uv \le N$ then $N^{-s} \le u^{-s}v^{-s}$.

**Theorem 7.5 (Convergence).** For $s>1$, both $Z_a(s)$ and $Z_b(s)$ converge.

*Proof sketch.* For $Z_b$: the map $\mathcal S \to \mathbb N^2$, $(m,n)\mapsto(m,n)$, is injective, and by Lemmas 7.3–7.4, $b(p)^{-s} \le m^{-s}n^{-s}$; summing over the image inside $\mathbb{N}^2$ gives $Z_b(s) \le \zeta(s)^2$. For $Z_a$: use instead the reindexing $(m,n)\mapsto(m-n,\ m)$, which is injective on $\mathcal S$ (the second coordinate recovers $m$, then the first recovers $n$), and satisfies $a(p)^{-s} \le (m-n)^{-s}m^{-s}$; again the sum is dominated by $\zeta(s)^2$. $\square$

**Theorem 7.6 (All three abscissae agree).** $\sigma_Z = \sigma_a = \sigma_b = 1$.

**Remark 7.7.** The agreement is not a triviality. The counting functions differ: the number of Berggren hypotenuses below $H$ is $\Theta(H)$, whereas the even legs $2mn$ below $B$ number $\asymp B\log B$ when counted with multiplicity across all seeds, reflecting the divisor-function statistics of products. The abscissa is insensitive to this logarithmic discrepancy — a reminder that the abscissa captures only the polynomial order of the counting function, and that finer asymptotics (the pole order, the residue) carry strictly more information.

---

## 8. Algorithms

Everything above is effectively computable, and the computations are what make the phenomena visible.

### 8.1 Layer enumeration

**Purpose.** Generate all $3^k$ seeds at depth $k$ and their hypotenuse statistics.

**Method.** Breadth-first expansion from $(2,1)$ under $s_0,s_1,s_2$. Since the labelling is injective (Theorem 2.9), no deduplication is ever needed — a rare luxury.

**Complexity.** $\Theta(3^k)$ pairs, each produced in $O(1)$ integer operations; the integers at depth $k$ have $O(k)$ digits, so the true cost is $\Theta(k\,3^k)$ bit operations. Memory $\Theta(3^k)$ if the whole layer is retained, $O(1)$ per node if statistics are streamed.

### 8.2 The counting function by sieve

**Purpose.** Compute $N(H)$ exactly.

**Method.** Iterate over $2 \le m \le \lfloor\sqrt H\rfloor$ and $1 \le n < m$; accept $(m,n)$ when $m^2+n^2 \le H$, $\gcd(m,n)=1$, and $m+n$ is odd. By completeness (Theorem 2.10) this counts exactly the tree nodes below $H$, and it does so without touching the tree at all.

**Complexity.** $O(H)$ pairs examined, each at cost $O(\log H)$ for the Euclidean algorithm, hence $O(H\log H)$. This is asymptotically far better than enumerating the tree, which would need depth $\asymp \log H/\log\lambda$ and thus $\asymp H^{\log 3/\log\lambda} = H^{0.623}$ nodes *to find the first $\Theta(H)$ triples* — the discrepancy between these two costs is exactly the content of Theorem 4.13, read algorithmically.

### 8.3 Abscissa detection by ratio bisection

**Purpose.** Estimate the abscissa numerically from truncated sums, to confirm $1$ rather than $0.6232$.

**Method.** For a candidate $s$, compute $Z_T(s) = \sum_{m \le T}\sum_{n<m, \text{seed}} (m^2+n^2)^{-s}$ for a geometric sequence of cut-offs $T$ and inspect the increments. For $s>1$ the increments decay geometrically; for $s\le1$ they stabilise or grow logarithmically. Bisecting on this dichotomy localises $\sigma_Z$.

**Complexity.** $O(T^2)$ per evaluation with $T = \sqrt{H}$; the diagnostic is the log-log slope of the tail, which converges slowly ($O(1/\log T)$) near the abscissa — hence bisection on the qualitative dichotomy, not curve-fitting, is the reliable procedure.

---

## 9. Numerical evidence and the conjectured constant

The counting law of Theorem 5.10 is a factor-of-$100$ two-sided bound. Numerics show the truth is far tighter:

| $H$ | $N(H)$ | $N(H)/H$ |
|---|---|---|
| $10^2$ | 16 | 0.160000 |
| $10^3$ | 158 | 0.158000 |
| $10^4$ | 1{,}593 | 0.159300 |
| $10^5$ | 15{,}919 | 0.159190 |
| $10^6$ | 159{,}139 | 0.159139 |
| $4\times10^6$ | 636{,}617 | 0.1591542 |

and $\dfrac{1}{2\pi} = 0.15915494\ldots$ — agreement to six decimal places at $H = 4\times10^6$.

**Conjecture 9.1.** $\displaystyle \lim_{H\to\infty}\frac{N(H)}{H} = \frac1{2\pi}$, and consequently $Z(s)$ continues meromorphically to a neighbourhood of $s=1$ with a simple pole there of residue $1/(2\pi)$.

**Heuristic derivation.** $N(H)$ counts lattice points $(m,n)$ in the quarter disc $m^2+n^2 \le H$, $m,n>0$, subject to $n<m$, $\gcd(m,n)=1$, $m+n$ odd. Multiply the four densities:

1. **Area.** The quarter disc of radius $\sqrt H$ has area $\pi H/4$; Gauss's circle problem gives this as the lattice count up to $O(\sqrt H)$.
2. **The condition $n<m$** cuts the count in half: $\pi H/8$.
3. **Coprimality** has density $1/\zeta(2) = 6/\pi^2$ among all pairs.
4. **Opposite parity, conditioned on coprimality.** Coprime pairs are never both even, so they are odd–odd or opposite-parity. Among coprime pairs the three residue classes $(\text{odd},\text{odd})$, $(\text{odd},\text{even})$, $(\text{even},\text{odd})$ mod $2$ are equidistributed, so opposite parity has conditional density $2/3$.

Multiplying: $\dfrac{\pi H}{8}\cdot\dfrac{6}{\pi^2}\cdot\dfrac{2}{3} = \dfrac{H}{2\pi}$.

**Corollary (conditional).** If Conjecture 9.1 holds with an error term $N(H) = H/(2\pi) + O(H^{1-\delta})$, then by the standard Mellin correspondence
$$Z(s) \;=\; s\int_1^\infty \frac{N(H)}{H^{s+1}}\,dH$$
extends to $\Re s > 1-\delta$ apart from a simple pole at $s=1$ with residue $1/(2\pi)$.

We emphasise the status: the two-sided bound $H/50 \le N(H) \le 2H$ is established; the constant $1/(2\pi)$ is at present conjectural, supported by the numerics above and by the four-factor heuristic. The three ingredients isolated in the sieve of Section 5 — the circle count, the $\sum_{d\ge2}d^{-2}$ loss, and the parity involution — are exactly the three factors of the heuristic, made rigorous but with lossy constants; sharpening each to its true density is the route to the conjecture.

---

## 10. Discussion

### 10.1 What was refuted, and what survives

The hypothesis under test was that the silver ratio, which governs the tree's metric growth, would also govern its analytic structure through the exponent $\log 3/\log(3+2\sqrt2)$. It does not.

What survives intact is everything metric. The silver speed limit $c \le 2\lambda^{k+1}$ (Theorem 3.3) is true and sharp in exponential order. The spine recurrence $c_{k+2}=6c_{k+1}-c_k$, its closed form in the eigenvalues $3\pm2\sqrt2$, and the growth exponent $\log\lambda = 2\log(1+\sqrt2)$ (Theorem 3.4, Corollary 3.5) are exact. The layer majorant really does converge for $s>\sigma_{\text{silver}}$ (Theorem 4.11). The heuristic's only error is the step where an upper bound on the layer *maximum* is used as a proxy for the layer *sum*.

### 10.2 Why the proxy fails: the entropy of the word statistics

The correct way to think about the layer sum is as an expectation. Write a word $w$ of length $k$ and let $c(w)$ be its hypotenuse. Then
$$\sum_{|w|=k} c(w)^{-s} \;=\; 3^k\ \mathbb E_{w}\bigl[c(w)^{-s}\bigr],$$
the expectation taken over the uniform measure on $\{0,1,2\}^k$. The layer heuristic replaces $\mathbb E[c^{-s}]$ by $(\max c)^{-s}$. But $\log c(w)$ is, to first order, an additive functional of the word — each letter contributes a step to $\log\Phi$ — and additive functionals of i.i.d. letters concentrate around their *mean* per-letter contribution, not their *maximum*. Since $s_1$ multiplies $\Phi$ by $1+\sqrt2$ while $s_0$ and $s_2$ multiply it by less (and can multiply it by a factor tending to $1$), the typical word grows at a strictly slower exponential rate than $\lambda^{k}$. Slower growth means *larger* terms $c^{-s}$, hence a larger sum, hence a larger abscissa. The gap $1 - 0.6232 = 0.3768$ is a quantitative measure of the mismatch between the maximal and typical branch.

This diagnosis suggests a refined, and correct, heuristic: a large-deviations analysis. If the empirical growth rate $\frac1k\log c(w)$ satisfies a large-deviation principle with rate function $I$ on $[\alpha_{\min},\alpha_{\max}] = [0,\log\lambda]$ (with $\alpha_{\min}=0$ because the slow spine is only polynomial), then
$$\frac1k \log \sum_{|w|=k} c(w)^{-s} \;\longrightarrow\; \sup_{\alpha}\ \bigl[\log 3 - I(\alpha) - s\alpha\bigr],$$
and the abscissa is the value of $s$ where the supremum first becomes non-positive. Since $\alpha = 0$ is attainable with $I(0)$ finite, the supremum is bounded below by $\log 3 - I(0)$, independent of $s$ — which is why the abscissa must be located by the arithmetic of the seed lattice rather than by the top eigenvalue. Making this multifractal picture precise for the Berggren tree is an appealing open problem: it would produce the exact free-energy function of the tree, of which the abscissa is a single point.

### 10.3 Relation to graph and dynamical zeta functions

The Ihara zeta function of a finite graph, and the Ruelle zeta functions of hyperbolic dynamical systems, are Euler products over closed geodesics/primitive cycles, and their poles sit at the reciprocal of the topological entropy of the geodesic flow — the analogue of the silver prediction. Our object is genuinely different in kind: it is a sum over *all* nodes weighted by an *arithmetic* size, not over closed orbits weighted by a *dynamical* length. The Berggren tree has no cycles, so no Ihara-type Euler product exists. What the present results show is that when the weight is arithmetic rather than dynamical, the entropy-based prediction can be badly wrong, because the arithmetic weight is not a multiplicative cocycle over the branching: $c(w)$ is not $\prod_i \rho(i)$ for any letter weights $\rho$.

Conversely, our result places $Z(s)$ squarely in classical analytic number theory: since the tree is a bijective reindexing of the Euclid seed lattice, $Z(s)$ is a lattice-sum Dirichlet series
$$Z(s) \;=\; \sum_{\substack{0<n<m,\ \gcd(m,n)=1\\ m+n\ \mathrm{odd}}} \frac{1}{(m^2+n^2)^s},$$
i.e. a sieved Epstein zeta function of the quadratic form $m^2+n^2$. This identification is the real payoff of Theorem 2.10, and it is what makes the conjectured residue $1/(2\pi)$ approachable: the unsieved Epstein zeta function of $m^2+n^2$ is $4\zeta(s)L(s,\chi_4)$, whose simple pole at $s=1$ has residue $\pi$, and the sieve factors $\frac18\cdot\frac{6}{\pi^2}\cdot\frac23$ convert $\pi$ into exactly $\frac{1}{2\pi}$ — the same arithmetic as in Section 9, arrived at analytically.

### 10.4 Robustness

That all three zeta functions — hypotenuse, odd leg, even leg — share the abscissa $1$ (Theorem 7.6) shows the invariant is robust under the choice of size function, provided the size is comparable to a product of two independent seed parameters. It also shows that the abscissa is a coarse invariant: the even-leg counting function differs from the hypotenuse counting function by a factor of $\log$, invisible to the abscissa. Finer invariants — the order and residue of the pole, the width of the zero-free region, the error term in the counting law — are where the differences live.

---

## 11. Future directions

1. **Prove Conjecture 9.1.** The target $N(H) = H/(2\pi) + O(H^{1/2+\varepsilon})$ requires assembling three classical ingredients with uniform error control: the Gauss circle count for $m^2+n^2 \le H$, the Möbius-inversion coprimality sieve with its $\sum_{d}\mu(d)/d^2$ main term, and the parity restriction. All three are in reach; the interaction of the sieve with the circle error term is the delicate point.

2. **The full multifractal spectrum.** Determine the large-deviation rate function $I(\alpha)$ for the growth exponent $\frac1k\log c(w)$ over uniform random words of length $k$, and thereby the exact free-energy function $P(s) = \lim_k \frac1k\log\sum_{|w|=k}c(w)^{-s}$. This would explain the gap $1 - \sigma_{\text{silver}}$ structurally rather than by comparison.

3. **Meromorphic continuation.** Identify $Z(s)$ explicitly as a sieved Epstein zeta function and continue it to the whole plane, locating trivial zeros and a functional equation if one exists. The unsieved form $4\zeta(s)L(s,\chi_4)$ has a functional equation; the sieve is a finite Euler-factor modification at $2$ plus a $1/\zeta(2s)$-type factor, both of which should transport.

4. **Other trees.** The same analysis applies to any Möbius-type tree of arithmetic objects: the Stern–Brocot tree of rationals, the Markov triple tree, the trees of solutions to other Pell-like and Vieta-jumping equations. In each case one may ask whether the branching/growth heuristic gives the right abscissa. The prediction implied by the present work is that it never does when the tree bijects onto a lattice of full dimension.

5. **Effective residues from the block method.** The $128$-adic block argument of Section 6 turns counting bounds into divergence rates. Refining the block ratio and the counting constants would yield explicit two-sided bounds on $\liminf$ and $\limsup$ of $N(H)/H$, narrowing the interval $[1/50, 2]$ towards $1/(2\pi)$ by purely elementary means.

6. **Zeta functions with weights.** Attach to each node a weight reflecting the word, e.g. $q^{|w|}c(w)^{-s}$, producing a two-variable zeta function $Z(q,s)$. Its analytic structure interpolates between the pure counting problem ($q=1$) and the pure branching problem ($s=0$, where $Z(q,0) = \sum_k (3q)^k$), and its singular locus should contain both $s=1$ and the silver curve $3q\lambda^{-s}=1$ — reconciling the two answers as different features of a single object.

---

## 12. Conclusion

We set out to test whether the silver ratio governs the analytic counting of Pythagorean triples over the Berggren tree. It does not. The tree zeta function $Z(s) = \sum_w c(w)^{-s}$ has abscissa of convergence exactly $1$, not the value $\log 3/\log(3+2\sqrt2) = 0.6232\ldots$ predicted by combining the $3^k$ branching with the silver growth of the layer maximum; and there is an explicit window $(0.6233, 1]$ in which the majorant converges and the series does not. The underlying reason is that the tree's layers are internally spread across an exponentially wide range of sizes, from the quadratic slow spine to the exponential fast spine, so that the maximum is an unrepresentative statistic.

The replacement results are sharp: the counting function is $\Theta(H)$, with the explicit bounds $H/50 \le N(H) \le 2H$ for $H \ge 512$; the counting law alone forces the divergence, with the explicit logarithmic rate $\sum_{c \le 512\cdot128^k}c^{-1} \ge k/300$; and the same abscissa $1$ holds for both leg zeta functions, by a two-dimensional argument that cannot be reduced to the hypotenuse case. Together these make the Berggren tree an exactly solved example of the general phenomenon that **growth exponents and arithmetic densities are independent invariants**, and that a self-similar structure can be metrically silver and analytically classical at the same time.
