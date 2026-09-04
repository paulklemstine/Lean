# Rank Correlation as Chordal Distance on the Permutohedron: Quantisation, Metric Equivalence, and a Structural Ceiling for Thresholded Statistics

**Author:** Aristotle
**Date:** 2026-09-04
**Keywords:** permutohedron, Spearman rank correlation, Spearman's footrule, inversions, Diaconis–Graham inequality, point-biserial correlation, quantisation gap, symmetric group

---

## Abstract

We develop the finite geometry of Spearman's rank correlation. On a tie-free population of $n$ items, a ranking is a vertex of the permutohedron $\Pi_{n-1}\subset\mathbb{R}^n$, and Spearman's statistic $\sum d^2$ is the squared Euclidean distance between two such vertices. Because all $n!$ vertices lie on a single sphere inside a single hyperplane, $\sum d^2$ is an affine function of the inner product of the rank vectors; we show that the classical normalisation $\rho = 1 - 6\sum d^2/(n^3-n)$ is exactly the Pearson correlation coefficient of the rank vectors, so that the "rank correlation" is a correlation in the strict sense and not by analogy.

From this vantage point we obtain four families of results.

*Quantisation.* The displacement vector between two vertices sums to zero, which forces $\sum d^2$ to be even. Consequently distinct rankings are separated by $\sum d^2 \ge 2$, and no attainable value of $\rho$ lies in the open interval $\bigl(1 - 12/(n^3-n),\,1\bigr)$: a reading in that window certifies exact agreement. Dually, the reversal permutation is the antipode; it realises the exact diameter $\max\sum d^2 = n(n^2-1)/3$, and $\rho = -1$ holds precisely at that diameter.

*Exact unbiasedness.* Right translation by a transposition is a bijection of $S_n$, so the ensemble is position-blind and the centroid of the permutohedron is barycentric. This yields the exact first moment $\mathbb{E}\!\left[\sum d^2\right] = (n^3-n)/6$ and hence $\sum_{\sigma\in S_n}\rho(\sigma,\mathrm{id}) = 0$ identically, not asymptotically.

*Metric equivalence.* Spearman's footrule $F(\sigma,\tau)=\sum|\sigma(i)-\tau(i)|$ is a right-invariant metric on $S_n$ and a length function, with $F(\text{swap}(a,b)) = 2|a-b|$. We prove the two-sided comparison $F \le \sum d^2 \le (n-1)F$, the Cauchy–Schwarz refinement $F^2 \le n\sum d^2$, and the Diaconis–Graham upper bound $F(\sigma,\mathrm{id}) \le 2\,\mathrm{inv}(\sigma)$ by a two-sided displacement count, with the constant $2$ shown sharp. Chaining gives $\sum d^2 \le 2(n-1)\,\mathrm{inv}(\sigma)$. The $\ell^1$, $\ell^2$, and pairwise-disorder readings therefore agree up to explicit factors.

*A ceiling for thresholded statistics.* If a continuous statistic is coarsened by a threshold into a two-block indicator flagging $m$ of $n$ items, the squared correlation between that indicator and any ranking obeys the sharp bound
$$r^2 \le \frac{3m(n-m)}{n^2-1} \approx 3p(1-p),\qquad p = m/n,$$
independent of the statistic. At $p=0.1$ this caps $|r|$ at $0.520$. This gives a structural, non-statistical explanation for a phenomenon observed in threshold calibration: correlation acceptance bands whose floor exceeds $\sqrt{3p(1-p)}$ are unreachable in principle, so tightening a threshold produces systematic — not stochastic — degradation.

---

## 1. Introduction

### 1.1 Motivation

A recurrent pattern in the monitoring of large systems is the *dial*: a scalar statistic $T$ is computed per item, an outcome rate is observed, and the health of the system is summarised by the rank correlation between the two. An acceptance band is fixed in advance; readings inside the band are "in regime", readings outside trigger investigation. Downstream, however, the statistic is rarely used continuously: an operating threshold $u$ converts it into a binary flag.

Such a dial has two independent axes of validation. Along the **population axis** one asks whether the reading is stable as the population size $N$ varies over orders of magnitude. Along the **threshold axis** one asks whether the reading survives a change in the operating point $u$.

Empirical calibration exhibits a striking asymmetry between the two. Across five independent populations with $N$ spanning $2^{27}$ to $2^{38}$, the reading remained inside a band $[0.71,\,0.76]$ on all five, with mean $0.713$ against an anchor of $0.717$ — the population axis is inert. Moving the operating point from $u=2.5$ to $u=3.5$, in contrast, degraded *every* population (a sign test on $5/5$, $p\approx 0.03$), with the worst reading collapsing to $0.487$ and the mean falling below the band floor. The degradation is systematic, not noisy.

This paper argues that both halves of that asymmetry are consequences of finite geometry, and that the second half in particular is not a statistical phenomenon at all but a hard ceiling imposed by the shape of the space of rankings.

### 1.2 The change of viewpoint

The device is elementary and classical: identify a ranking with a point. A tie-free ranking of $n$ items assigns each item a distinct value in $\{0,1,\dots,n-1\}$, so it is a permutation $\sigma \in S_n$, and its **rank vector** $(\sigma(0),\dots,\sigma(n-1)) \in \mathbb{Z}^n$ is a point in Euclidean space. The convex hull of the $n!$ rank vectors is the **permutohedron** $\Pi_{n-1}$, an $(n-1)$-dimensional polytope whose vertices are exactly those points: a hexagon for $n=3$, a truncated octahedron for $n=4$.

Spearman's raw statistic $\sum_i d_i^2$ is then literally the squared Euclidean distance between two vertices. Every property of the dial becomes a property of a finite point configuration, and the questions "which values are attainable?", "what is the largest possible disagreement?", "what does a threshold do?" become questions about the polytope.

### 1.3 Organisation

Section 2 fixes notation and establishes cosphericity. Section 3 derives the chordal representation, right-invariance, and the identification of $\rho$ with Pearson's coefficient. Section 4 gives the extremes and the exact diameter. Section 5 gives quantisation and the rigidity gap. Section 6 proves exact unbiasedness. Section 7 develops the $\ell^1$ and combinatorial faces and their equivalence with the $\ell^2$ face. Section 8 proves the block ceiling for thresholded statistics and applies it. Section 9 presents algorithms. Section 10 discusses limitations, an open problem, and future directions.

---

## 2. Setup: rank vectors and cosphericity

Throughout, $n \ge 2$ is an integer and $S_n$ denotes the group of permutations of the index set $\{0,1,\dots,n-1\}$.

> **Definition 2.1 (rank vector).** For $\sigma\in S_n$ the *rank vector* is $\mathrm{rk}\,\sigma = (\sigma(0),\sigma(1),\dots,\sigma(n-1))\in\mathbb{Z}^n$. Its $i$-th coordinate is the rank assigned to item $i$.

> **Definition 2.2 (the two structure constants).**
> $$L(n) := \sum_{i=0}^{n-1} i, \qquad R(n) := \sum_{i=0}^{n-1} i^2 .$$

> **Definition 2.3 (the statistics).** For $\sigma,\tau\in S_n$:
> $$D(\sigma,\tau) := \sum_{i}\bigl(\sigma(i)-\tau(i)\bigr)^2, \qquad \langle\sigma,\tau\rangle := \sum_i \sigma(i)\tau(i),$$
> $$\rho(\sigma,\tau) := 1 - \frac{6\,D(\sigma,\tau)}{n^3-n}.$$

The whole theory rests on the following triviality, which we state as a theorem because everything else is a corollary of it.

> **Theorem 2.4 (cosphericity of the permutohedron).** For every $\sigma\in S_n$,
> $$\sum_i \sigma(i) = L(n) = \frac{n(n-1)}{2}, \qquad \sum_i \sigma(i)^2 = R(n) = \frac{n(n-1)(2n-1)}{6}.$$
> Hence all $n!$ vertices of $\Pi_{n-1}$ lie on a common hyperplane and on a common sphere centred at the origin.

*Proof.* Both sums are of the form $\sum_i f(\sigma(i))$ for a fixed $f$; since $\sigma$ is a bijection of the index set, reindexing gives $\sum_i f(\sigma(i)) = \sum_i f(i)$. The closed forms are Gauss's sum and the square-pyramidal sum, each verified by induction on $n$: for the first, $2L(n+1) = 2L(n) + 2n = n(n-1)+2n = n(n+1)$; for the second, $6R(n+1) = 6R(n)+6n^2 = n(n-1)(2n-1)+6n^2 = n(n+1)(2n+1)$. $\square$

The geometric content of Theorem 2.4 is that no vertex of the permutohedron is distinguished by length or by position along the all-ones direction. This is exactly the hypothesis under which a squared distance is equivalent to an inner product.

---

## 3. The chordal representation

> **Theorem 3.1 (chordal form).** For all $\sigma,\tau\in S_n$,
> $$D(\sigma,\tau) = 2\bigl(R(n) - \langle\sigma,\tau\rangle\bigr).$$

*Proof.* Expand $(\sigma(i)-\tau(i))^2 = \sigma(i)^2 + \tau(i)^2 - 2\sigma(i)\tau(i)$ and sum, applying Theorem 2.4 to each of the two square terms. $\square$

Two structural consequences are immediate.

> **Corollary 3.2 (nonnegativity and separation).** $D(\sigma,\tau)\ge 0$, with equality iff $\sigma=\tau$; and $D$ is symmetric.

*Proof.* $D$ is a sum of squares; it vanishes iff every summand does, i.e. iff the rank vectors coincide, i.e. iff the permutations coincide. $\square$

> **Theorem 3.3 (right invariance).** For all $\sigma,\tau,\pi\in S_n$, $D(\sigma\pi,\tau\pi) = D(\sigma,\tau)$, and consequently $D(\sigma,\tau) = D(\sigma\tau^{-1},\mathrm{id})$. The same holds for $\langle\cdot,\cdot\rangle$.

*Proof.* $\mathrm{rk}(\sigma\pi)(i) = \sigma(\pi(i))$, so the summand at $i$ for the pair $(\sigma\pi,\tau\pi)$ equals the summand at $\pi(i)$ for the pair $(\sigma,\tau)$; summing over the bijection $\pi$ gives the claim. Setting $\pi=\tau^{-1}$ gives the reduction to the identity. $\square$

Right invariance says the dial is *relabelling-blind*: it depends only on the relative permutation $\sigma\tau^{-1}$, so without loss of generality one may always compare against the identity ranking. Every subsequent one-argument statement $\Phi(\sigma) := \Phi(\sigma,\mathrm{id})$ is therefore fully general.

The next theorem is what licenses the word "correlation".

> **Theorem 3.4 (Spearman is Pearson).** For $n\ge 2$ and all $\sigma,\tau\in S_n$,
> $$12\Bigl(n\,\langle\sigma,\tau\rangle - L(n)^2\Bigr) = n^2(n^2-1)\,\rho(\sigma,\tau).$$

*Proof.* The left-hand side is $n^2$ times the un-normalised covariance $n\langle\sigma,\tau\rangle/n^2 - (L(n)/n)^2$ of the two rank vectors, scaled by $12$; the right-hand side is $\rho$ scaled by $n^2$ times $12\cdot\mathrm{Var}(\mathrm{rk})= n^2-1$. Concretely, substitute $\langle\sigma,\tau\rangle = R(n) - D/2$ from Theorem 3.1 and $\rho = 1 - 6D/(n^3-n)$, then eliminate $L(n)$ and $R(n)$ using $2L(n) = n(n-1)$ and $6R(n) = n(n-1)(2n-1)$; the identity reduces to a polynomial identity in $n$ and $D$. $\square$

Since the variance of any rank vector is the fixed constant $(n^2-1)/12$, Theorem 3.4 says exactly that $\rho$ is the Pearson correlation coefficient of $\mathrm{rk}\,\sigma$ and $\mathrm{rk}\,\tau$. The mysterious constant $n^3-n$ in the classical formula is $12$ times $n$ times the rank variance; there is nothing to choose.

---

## 4. Extremes and the diameter

> **Lemma 4.1 (inner-product ceiling).** $\langle\sigma,\tau\rangle \le R(n)$ for all $\sigma,\tau$, with equality iff $\sigma=\tau$.

*Proof.* Immediate from Theorem 3.1 and $D\ge 0$ (Corollary 3.2). $\square$

This is the easy half of the rearrangement inequality, and cosphericity makes it free.

For the opposite extreme, let $\mathrm{rev}\in S_n$ be the reversal, $\mathrm{rev}(i) = n-1-i$.

> **Lemma 4.2 (reflection identity).** For any $\mu\in S_n$, $\mathrm{rk}(\mathrm{rev}\cdot\mu)(i) = (n-1) - \mathrm{rk}\,\mu(i)$.

*Proof.* $(\mathrm{rev}\cdot\mu)(i) = \mathrm{rev}(\mu(i)) = n-1-\mu(i)$. $\square$

> **Theorem 4.3 (antipodality).** For all $\sigma,\tau\in S_n$,
> $$\langle\sigma,\tau\rangle \ \ge\ (n-1)L(n) - R(n),$$
> and equality holds for $(\mathrm{rev},\mathrm{id})$. Consequently $\mathrm{rev}$ minimises the inner product and maximises the distance.

*Proof.* By right invariance put $\mu = \sigma\tau^{-1}$, so $\langle\sigma,\tau\rangle = \langle\mu,\mathrm{id}\rangle$. Applying Lemma 4.2 and Theorem 2.4,
$$\langle \mathrm{rev}\cdot\mu,\ \mathrm{id}\rangle = \sum_i \bigl((n-1)-\mathrm{rk}\,\mu(i)\bigr)\,i = (n-1)L(n) - \langle\mu,\mathrm{id}\rangle .$$
Now apply Lemma 4.1 to the left-hand side: $(n-1)L(n) - \langle\mu,\mathrm{id}\rangle \le R(n)$, which rearranges to the claim. Taking $\mu=\mathrm{id}$ in the displayed identity and using $\langle\mathrm{id},\mathrm{id}\rangle = R(n)$ shows $\langle\mathrm{rev},\mathrm{id}\rangle = (n-1)L(n) - R(n)$, i.e. the bound is attained. $\square$

> **Theorem 4.4 (exact diameter).** $\displaystyle \max_{\sigma,\tau\in S_n} D(\sigma,\tau) = D(\mathrm{rev},\mathrm{id}) = \frac{n(n^2-1)}{3}.$

*Proof.* Maximality is Theorem 4.3 combined with Theorem 3.1. For the value, Theorem 3.1 gives $D(\mathrm{rev},\mathrm{id}) = 2\bigl(R(n) - (n-1)L(n) + R(n)\bigr) = 4R(n) - 2(n-1)L(n)$. Substituting $6R(n) = n(n-1)(2n-1)$ and $2L(n) = n(n-1)$ yields $3D(\mathrm{rev},\mathrm{id}) = 2n(n-1)(2n-1) - 3n(n-1)^2 = n(n-1)(n+1) = n(n^2-1)$. $\square$

> **Corollary 4.5 (range and characterisation of $\pm 1$).** For $n\ge2$ and all $\sigma,\tau$: $-1 \le \rho(\sigma,\tau) \le 1$; moreover $\rho = 1$ iff $\sigma=\tau$, and $\rho = -1$ iff $D(\sigma,\tau)$ equals the diameter $n(n^2-1)/3$.

*Proof.* The upper bound and its equality case are Corollary 3.2. For the lower bound, Theorem 4.4 gives $6D/(n^3-n)\le 2$, so $\rho\ge -1$, with equality iff $D$ is maximal. $\square$

Thus "perfectly anticorrelated" is not a limit but an exactly characterised geometric event: the two rankings are antipodal vertices of $\Pi_{n-1}$.

---

## 5. Quantisation and the rigidity gap

> **Theorem 5.1 (parity invariant).** $D(\sigma,\tau)$ is even for all $\sigma,\tau\in S_n$.

*Proof.* Let $d_i = \sigma(i)-\tau(i)$. By Theorem 2.4 the displacement vector sums to zero: $\sum_i d_i = L(n)-L(n) = 0$. Hence
$$D(\sigma,\tau) = \sum_i d_i^2 = \sum_i \bigl(d_i^2 - d_i\bigr) = \sum_i d_i(d_i-1),$$
and each term is a product of two consecutive integers, hence even. $\square$

Geometrically: the displacement between two vertices lies in the root lattice $A_{n-1}$, on which the quadratic form is even.

> **Theorem 5.2 (separation).** If $\sigma\ne\tau$ then $D(\sigma,\tau)\ge 2$. In particular no pair of rankings is at squared distance $1$, and more generally $D$ never takes an odd value.

*Proof.* $D \ge 0$, $D \ne 0$ by Corollary 3.2, and $D$ even by Theorem 5.1. $\square$

> **Theorem 5.3 (rigidity gap).** Let $n\ge 2$ and $\sigma\ne\tau$. Then
> $$\rho(\sigma,\tau) \ \le\ 1 - \frac{12}{n^3-n}.$$
> Equivalently: no attainable value of $\rho$ lies in the open interval $\bigl(1-\tfrac{12}{n^3-n},\ 1\bigr)$, and any reading strictly greater than $1-\tfrac{12}{n^3-n}$ certifies $\sigma=\tau$ exactly.

*Proof.* Substitute $D\ge2$ from Theorem 5.2 into $\rho = 1-6D/(n^3-n)$, noting $n^3-n>0$ for $n\ge2$. The contrapositive form follows immediately. $\square$

The gap width $12/(n^3-n)$ is $\tfrac12$ at $n=3$ (so on the hexagon $\rho$ is one of $1, \tfrac12, -\tfrac12, -1$), $0.2$ at $n=4$, $10^{-2}$ at $n\approx 11$, and $1.2\times10^{-11}$ at $n=10^4$. It matters for small-$n$ diagnostics and for the semantics of "$\rho$ close to $1$": on finite data the phrase names a *discrete* condition.

**Exhaustive small-case data.** For $n=3$ the six vertices of the hexagon realise exactly the squared distances $\{0,2,6,8\}$: every value even, the value $1$ absent, the diameter $8 = 3(3^2-1)/3$ attained by opposite corners — all as the theorems require. The value $4$ is also absent, so at $n=3$ the parity obstruction is not the only one; exhaustive enumeration for $4 \le n \le 8$ shows that this is an artefact of the smallest case, every even value in $[0,\,n(n^2-1)/3]$ being realised for $n \ge 4$. Parity is therefore the exact description of the attainable spectrum from $n=4$ onwards, and the rigidity gap of Theorem 5.3 is attained.

---

## 6. Exact unbiasedness: the centroid of the permutohedron

Reading an in-band value as evidence presupposes the dial has no built-in drift. We show the null mean vanishes identically, for every finite $n$.

> **Lemma 6.1 (position blindness).** For all $i,j$, $\ \sum_{\sigma\in S_n}\sigma(i) = \sum_{\sigma\in S_n}\sigma(j)$.

*Proof.* Right multiplication by the transposition $(i\,j)$ is a bijection $S_n\to S_n$. Reindexing the left sum along it, $\sum_\sigma \sigma(i) = \sum_\sigma (\sigma\cdot(i\,j))(i) = \sum_\sigma \sigma(j)$. $\square$

Equivalently: the centroid of the permutohedron is the barycentric point $\bigl(\tfrac{n-1}{2},\dots,\tfrac{n-1}{2}\bigr)$.

> **Lemma 6.2 (pinning the common value).** For every $i$, $\ n\sum_{\sigma\in S_n}\sigma(i) = n!\cdot L(n)$.

*Proof.* Compute $\sum_j\sum_\sigma \sigma(j)$ in two ways. Swapping the order and applying Theorem 2.4 gives $\sum_\sigma \sum_j \sigma(j) = n!\,L(n)$. Applying Lemma 6.1 to each inner sum gives $\sum_j \sum_\sigma\sigma(i) = n\sum_\sigma \sigma(i)$. $\square$

> **Lemma 6.3 (mean inner product).** $\ n\sum_{\sigma\in S_n}\langle\sigma,\mathrm{id}\rangle = n!\,L(n)^2$.

*Proof.* $\sum_\sigma\langle\sigma,\mathrm{id}\rangle = \sum_\sigma\sum_i \sigma(i)\,i = \sum_i i\sum_\sigma\sigma(i)$. Multiply by $n$ and apply Lemma 6.2 termwise: the result is $\sum_i i\cdot n!\,L(n) = n!\,L(n)^2$. $\square$

> **Theorem 6.4 (exact first moment).** $\displaystyle \sum_{\sigma\in S_n} D(\sigma,\mathrm{id}) = \frac{n!\,(n^3-n)}{6}$, i.e. $\mathbb{E}\bigl[\sum d^2\bigr] = (n^3-n)/6$ under the uniform ensemble.

*Proof.* By Theorem 3.1, $\sum_\sigma D(\sigma,\mathrm{id}) = 2\bigl(n!\,R(n) - \sum_\sigma\langle\sigma,\mathrm{id}\rangle\bigr)$. Multiply by $n$ and substitute Lemma 6.3, then eliminate $L(n),R(n)$ via $2L(n)=n(n-1)$ and $6R(n)=n(n-1)(2n-1)$. One obtains $6n\sum_\sigma D = n!\,n\,(n^3-n)$; cancel $n>0$. $\square$

> **Theorem 6.5 (the dial is exactly unbiased).** For $n\ge 2$, $\displaystyle \sum_{\sigma\in S_n}\rho(\sigma,\mathrm{id}) = 0$.

*Proof.* $\sum_\sigma \rho = n! - \frac{6}{n^3-n}\sum_\sigma D$, and Theorem 6.4 makes the second term $n!$ exactly. $\square$

> **Corollary 6.6 (both signs occur).** For $n \ge 2$ there exist $\sigma$ with $\rho(\sigma,\mathrm{id})\le 0$ and $\sigma'$ with $\rho(\sigma',\mathrm{id})\ge 0$.

*Proof.* If all values were strictly positive the sum would be positive, contradicting Theorem 6.5; and $\sigma'=\mathrm{id}$ gives $\rho=1$. $\square$

For $n=3$: $\sum_\sigma D = 24$, mean $4 = (27-3)/6$, mean $\rho = 0$.

Theorem 6.5 is stronger than the usual asymptotic statement and is worth isolating: the normalisation $1-6\sum d^2/(n^3-n)$ is not merely a convenient rescaling to $[-1,1]$, it is the *unique* affine rescaling that centres the statistic exactly at every finite $n$.

---

## 7. The $\ell^1$ and combinatorial faces

A thresholded comparison is not intrinsically an $\ell^2$ object: it counts wrongly-ordered pairs and displacement distances. We therefore develop the $\ell^1$ and pairwise-disorder readings and prove they are equivalent to the $\ell^2$ reading up to explicit factors.

> **Definition 7.1 (footrule).** $\displaystyle F(\sigma,\tau) := \sum_i \bigl|\sigma(i)-\tau(i)\bigr|$. We write $F(\sigma) := F(\sigma,\mathrm{id})$.

> **Definition 7.2 (inversions).** For $\sigma\in S_n$ set
> $$\mathrm{Inv}^{\to}(\sigma,i) := \{\,j : i<j,\ \sigma(j)<\sigma(i)\,\},\qquad \mathrm{Inv}^{\leftarrow}(\sigma,i) := \{\,j : j<i,\ \sigma(i)<\sigma(j)\,\},$$
> the inversions with left, respectively right, endpoint $i$, and $\mathrm{inv}(\sigma) := \sum_i |\mathrm{Inv}^{\to}(\sigma,i)|$.

### 7.1 The footrule is a right-invariant metric and a length function

> **Theorem 7.3.** $F$ is a metric on $S_n$: $F\ge0$; $F(\sigma,\tau)=0$ iff $\sigma=\tau$; $F(\sigma,\tau)=F(\tau,\sigma)$; and $F(\sigma,\pi)\le F(\sigma,\tau)+F(\tau,\pi)$. It is right-invariant: $F(\sigma\pi,\tau\pi)=F(\sigma,\tau)$.

*Proof.* Nonnegativity, symmetry and definiteness are termwise (a sum of nonnegative terms vanishes iff each does). The triangle inequality is the termwise inequality $|a-c|\le|a-b|+|b-c|$ summed. Right invariance is the reindexing argument of Theorem 3.3. $\square$

> **Theorem 7.4 (length function).** $F(\sigma\tau) \le F(\sigma) + F(\tau)$ for all $\sigma,\tau\in S_n$.

*Proof.* By right invariance, $F(\sigma\tau,\tau) = F(\sigma,\mathrm{id}) = F(\sigma)$. Then the triangle inequality with midpoint $\tau$ gives $F(\sigma\tau) \le F(\sigma\tau,\tau)+F(\tau) = F(\sigma)+F(\tau)$. $\square$

Together with $F(\sigma^{-1}) = F(\sigma)$ (from symmetry and right invariance) this makes $F$ a genuine word-length-style length function on $S_n$, comparable to the Coxeter length $\mathrm{inv}$ and the Cayley length.

> **Theorem 7.5 (cost of a transposition).** For $a,b$ indices, $F\bigl((a\,b)\bigr) = 2\,|a-b|$.

*Proof.* The transposition fixes every index outside $\{a,b\}$, so all other summands vanish; the surviving two are $|b-a|$ and $|a-b|$. When $a=b$ both sides are $0$. $\square$

So the footrule of a transposition is exactly twice the distance travelled — the two swapped items each move $|a-b|$ places, in opposite directions.

### 7.2 Equivalence of the $\ell^1$ and $\ell^2$ readings

> **Theorem 7.6 (two-sided comparison).** For all $\sigma,\tau\in S_n$,
> $$F(\sigma,\tau) \ \le\ D(\sigma,\tau) \ \le\ (n-1)\,F(\sigma,\tau).$$

*Proof.* Left: for an integer $x$, $|x| \le x^2$ (trivially at $x=0$; otherwise $|x|\ge1$ so $|x|\le|x|^2 = x^2$), summed termwise. Right: each displacement satisfies $|\sigma(i)-\tau(i)| \le n-1$ since both ranks lie in $\{0,\dots,n-1\}$; hence $(\sigma(i)-\tau(i))^2 = |\cdot|\cdot|\cdot| \le (n-1)|\cdot|$, summed termwise. $\square$

> **Theorem 7.7 (Cauchy–Schwarz refinement).** $F(\sigma,\tau)^2 \le n\, D(\sigma,\tau)$.

*Proof.* Cauchy–Schwarz for the $n$-term sum $\sum_i |d_i|\cdot 1$: $\bigl(\sum |d_i|\bigr)^2 \le n\sum |d_i|^2 = nD$. $\square$

Theorem 7.7 is sharper than the right half of Theorem 7.6 in the regime of many small displacements, and weaker for a single large one; the two together bracket $F$ tightly.

### 7.3 The Diaconis–Graham upper bound

The bridge to pairwise disorder rests on a displacement-counting lemma with a clean geometric reading: *an item cannot move far without creating inversions*.

> **Lemma 7.8 (rightward displacement is charged to inversions).** For all $\sigma$ and all $i$,
> $$\sigma(i) \ \le\ i + \bigl|\mathrm{Inv}^{\to}(\sigma,i)\bigr| .$$

*Proof.* Let $S = \{\,j : \sigma(j) < \sigma(i)\,\}$. Since $\sigma$ is a bijection onto $\{0,\dots,n-1\}$, exactly $\sigma(i)$ indices have smaller image, so $|S| = \sigma(i)$. Split $S$ by position relative to $i$. The part with $j > i$ is precisely $\mathrm{Inv}^{\to}(\sigma,i)$. The part with $j \le i$ excludes $j=i$ (as $\sigma(i)\not<\sigma(i)$), so it is contained in $\{0,\dots,i-1\}$ and has at most $i$ elements. Hence $\sigma(i) = |S| \le i + |\mathrm{Inv}^{\to}(\sigma,i)|$. $\square$

> **Lemma 7.9 (leftward displacement, dually).** For all $\sigma$ and all $i$,
> $$i \ \le\ \sigma(i) + \bigl|\mathrm{Inv}^{\leftarrow}(\sigma,i)\bigr| .$$

*Proof.* Let $T = \{\,j : \sigma(i) < \sigma(j)\,\}$, so $|T| = n-1-\sigma(i)$. The part of $T$ with $j<i$ is $\mathrm{Inv}^{\leftarrow}(\sigma,i)$; the part with $j>i$ has at most $n-1-i$ elements. Hence $n-1-\sigma(i) \le |\mathrm{Inv}^{\leftarrow}(\sigma,i)| + (n-1-i)$, which rearranges to the claim. $\square$

> **Lemma 7.10 (double counting).** $\displaystyle \mathrm{inv}(\sigma) = \sum_i \bigl|\mathrm{Inv}^{\leftarrow}(\sigma,i)\bigr|$.

*Proof.* Both sides count the set of inverted pairs $\{(i,j) : i<j,\ \sigma(j)<\sigma(i)\}$, one grouping by the left endpoint and the other by the right endpoint; exchanging the order of summation converts one grouping into the other. $\square$

> **Theorem 7.11 (Diaconis–Graham upper bound).** For all $\sigma\in S_n$,
> $$F(\sigma) \ \le\ 2\,\mathrm{inv}(\sigma).$$

*Proof.* Lemmas 7.8 and 7.9 combine to give, at each $i$, the two-sided estimate
$$-\bigl|\mathrm{Inv}^{\leftarrow}(\sigma,i)\bigr| \ \le\ \sigma(i)-i \ \le\ \bigl|\mathrm{Inv}^{\to}(\sigma,i)\bigr|,$$
so $|\sigma(i)-i| \le |\mathrm{Inv}^{\to}(\sigma,i)| + |\mathrm{Inv}^{\leftarrow}(\sigma,i)|$ (both terms being nonnegative). Summing over $i$ and applying Lemma 7.10 to the second group,
$$F(\sigma) \le \sum_i\bigl|\mathrm{Inv}^{\to}(\sigma,i)\bigr| + \sum_i\bigl|\mathrm{Inv}^{\leftarrow}(\sigma,i)\bigr| = \mathrm{inv}(\sigma)+\mathrm{inv}(\sigma). \qquad\square$$

> **Proposition 7.12 (sharpness of the constant $2$).** The factor $2$ cannot be reduced: for the adjacent transposition $(0\,1)$ one has $F = 2$ and $\mathrm{inv}=1$, so equality holds. It is not always tight: for $(0\,2)$ in $S_3$, $F = 4 < 6 = 2\,\mathrm{inv}$.

> **Corollary 7.13 (Euclidean bound from combinatorial data).** $D(\sigma,\mathrm{id}) \le 2(n-1)\,\mathrm{inv}(\sigma)$.

*Proof.* Chain Theorem 7.6 (right half) with Theorem 7.11, using $n\ge1$. $\square$

> **Corollary 7.14 (positivity transfer).** For $\sigma\ne\mathrm{id}$: $F(\sigma)>0$ and $\mathrm{inv}(\sigma)>0$.

*Proof.* $F(\sigma)>0$ by definiteness (Theorem 7.3); then Theorem 7.11 forces $\mathrm{inv}(\sigma)>0$. $\square$

**Interpretive consequence.** Theorems 7.6, 7.7 and 7.11 say that the three natural scales of disagreement — total travel ($\ell^1$), squared travel ($\ell^2$), and pairwise disorder — are equivalent up to factors depending only on $n$. Operationally: *a violation of an acceptance band in one of these metrics is a violation in all three.* There is no reparametrisation of the disagreement measure that rescues a failing operating point.

---

## 8. The block ceiling: why thresholding caps the correlation

We now address the threshold axis. The essential observation is that a threshold does not perturb a ranking; it *destroys* one, replacing a permutation-valued object by a two-block indicator.

> **Definition 8.1 (block statistics).** Let $B\subseteq\{0,\dots,n-1\}$ with $|B| = m$, thought of as the flagged set $\{i : T_i > u\}$. For $\sigma\in S_n$ set
> $$\Sigma_B(\sigma) := \sum_{i\in B}\sigma(i), \qquad C_B(\sigma) := n\,\Sigma_B(\sigma) - m\,L(n),$$
> and define the squared point-biserial correlation between $\mathbf 1_B$ and $\mathrm{rk}\,\sigma$,
> $$r^2(\sigma,B) := \frac{12\,C_B(\sigma)^2}{n^2\,m\,(n-m)\,(n^2-1)} .$$

The definition is the standard one: $C_B(\sigma)/n^2 = \mathrm{Cov}(\mathbf 1_B, \mathrm{rk}\,\sigma)$, $\mathrm{Var}(\mathbf 1_B) = m(n-m)/n^2$, and $\mathrm{Var}(\mathrm{rk}\,\sigma) = (n^2-1)/12$, so $r^2 = \mathrm{Cov}^2/(\mathrm{Var}\cdot\mathrm{Var})$ as displayed.

> **Theorem 8.2 (extremal block sums).** For every $\sigma\in S_n$ and every $B$ with $|B|=m$,
> $$\frac{m(m-1)}{2} \ \le\ \Sigma_B(\sigma) \ \le\ \frac{m(2n-m-1)}{2},$$
> and both bounds are attained.

*Proof.* The multiset $\{\sigma(i): i\in B\}$ consists of $m$ *distinct* integers in $\{0,\dots,n-1\}$ (distinct because $\sigma$ is injective). The smallest possible sum of $m$ distinct nonnegative integers is $0+1+\cdots+(m-1) = m(m-1)/2$; the largest sum of $m$ distinct integers each at most $n-1$ is $(n-1)+(n-2)+\cdots+(n-m) = m(2n-m-1)/2$. Attainment: take $B$ to be the bottom, resp. top, $m$ positions under the identity ranking. $\square$

> **Theorem 8.3 (covariance bound).** $\bigl|2\,C_B(\sigma)\bigr| \ \le\ n\,m\,(n-m)$, equivalently $\bigl|\mathrm{Cov}(\mathbf 1_B,\mathrm{rk}\,\sigma)\bigr| \le \tfrac12\,n\,p(1-p)$ with $p=m/n$.

*Proof.* Using $2L(n) = n(n-1)$, the upper half of Theorem 8.2 gives
$$2C_B = 2n\Sigma_B - 2mL(n) \le n\,m(2n-m-1) - m\,n(n-1) = n\,m\,(n-m),$$
and the lower half gives, symmetrically, $2C_B \ge n\,m(m-1) - mn(n-1) = -n\,m\,(n-m)$. $\square$

> **Theorem 8.4 (block ceiling).** Let $0 < m < n$. Then for every $\sigma\in S_n$ and every $B$ with $|B|=m$,
> $$r^2(\sigma,B) \ \le\ \frac{3\,m\,(n-m)}{n^2-1} \ =\ \frac{3\,p(1-p)\,n^2}{n^2-1} \ \approx\ 3p(1-p).$$

*Proof.* Square Theorem 8.3: $4C_B^2 \le n^2m^2(n-m)^2$. Substituting into Definition 8.1,
$$r^2 = \frac{12 C_B^2}{n^2 m(n-m)(n^2-1)} \le \frac{12}{4}\cdot\frac{n^2m^2(n-m)^2}{n^2m(n-m)(n^2-1)} = \frac{3m(n-m)}{n^2-1}. \qquad\square$$

The bound is sharp in the sense that the input inequality is attained: at $n=4$, $m=2$, the top block $\{2,3\}$ under the identity ranking realises $2\Sigma_B = 10 = m(2n-m-1)$, and the ceiling reads $3\cdot 2\cdot 2/15 = 4/5$.

> **Corollary 8.5 (deployment criterion).** Let $0<m<n$ and let $c>0$ be a target correlation. If
> $$3\,m\,(n-m) \ <\ c^2\,(n^2-1),$$
> then $r^2(\sigma,B) < c^2$ for every statistic and every ranking: the target is unreachable in principle.

*Proof.* Immediate from Theorem 8.4. $\square$

### 8.1 The empirical regime

Take $n=100$ strata with a $10\%$ flag rate, $m=10$. Theorem 8.4 gives the exact bound
$$r^2 \le \frac{3\cdot 10\cdot 90}{100^2-1} = \frac{2700}{9999} \approx 0.27003,\qquad |r| \le 0.5196 .$$
The pre-registered band floor $0.71$ requires $r^2 \ge 0.5041$, i.e. $c^2(n^2-1) = 5040.5 > 2700$; Corollary 8.5 applies, and the band is structurally unreachable. The following table gives the ceiling as a function of the flagged fraction (asymptotic form $\sqrt{3p(1-p)}$):

| $p$ | $0.50$ | $0.40$ | $0.30$ | $0.20$ | $0.15$ | $0.10$ | $0.05$ | $0.02$ |
|---|---|---|---|---|---|---|---|---|
| ceiling on $\lvert r\rvert$ | $0.866$ | $0.849$ | $0.794$ | $0.693$ | $0.618$ | $0.520$ | $0.377$ | $0.243$ |

The band floor $0.71$ is crossed at $p \approx 0.21$: for any flagged fraction below roughly one fifth, the acceptance test cannot be passed.

This is the structural content of the observed asymmetry. Along the population axis nothing in the geometry depends on $N$: $\rho$ is scale-free (Theorem 3.4 normalises by $n$), which is consistent with in-band readings across $2^{27}$–$2^{38}$. Along the threshold axis, raising $u$ shrinks $p$, which lowers the ceiling, which at some point passes below the band floor. The degradation is therefore *monotone and systematic* rather than stochastic — exactly the signature observed (every seed degrades; a sign test across seeds is significant; the worst reading, $0.487$, lies just below the $p\approx0.1$ ceiling of $0.520$). No amount of seed averaging or population enlargement can recover the band.

**Practical rule.** Before tightening a threshold, compute $\sqrt{3p(1-p)}$ for the resulting flag rate. If it lies below the acceptance floor, the experiment is uninformative: recalibrate the band, or keep the looser operating point.

---

## 9. Algorithms

Three computations recur; we give them with complexities.

**(A) Exact Spearman reading from two rankings.** Compute $d_i = \sigma(i)-\tau(i)$, accumulate $D = \sum d_i^2$ and $F = \sum|d_i|$, then $\rho = 1 - 6D/(n^3-n)$. Time $O(n)$, space $O(1)$. Because $D$ is an integer, the reading is exact in rational arithmetic; and by Theorem 5.1 an odd $D$ signals an implementation bug (ties, or a non-bijective rank assignment).

**(B) Inversion count by merge sort.** Counting inversions naively is $\Theta(n^2)$. Merge sort counts them in $O(n\log n)$: when merging two sorted halves, taking an element from the right half while $k$ elements remain in the left half contributes exactly $k$ inversions. The output feeds the certificate $F \le 2\,\mathrm{inv} $ and the derived bound $D \le 2(n-1)\mathrm{inv}$.

**(C) Ceiling audit for a proposed threshold.** Given the flag rate $p$ (or the counts $m,n$) and an acceptance floor $c$, evaluate the ceiling $\sqrt{3m(n-m)/(n^2-1)}$ and compare with $c$; if the ceiling is smaller, report the operating point as structurally infeasible and, by bisection on $p$, report the largest flag rate at which the floor is attainable. Time $O(1)$ per evaluation, $O(\log(1/\varepsilon))$ for the bisection.

A fourth, used for validation, is exhaustive enumeration of $S_n$ for small $n$ to confirm the quantisation set, the diameter, the null mean, and the metric inequalities; this is $O(n!\cdot n)$ and practical to $n=8$.

---

## 10. Discussion

### 10.1 What the geometry buys

The results split cleanly into what follows from cosphericity and what requires genuine combinatorics.

Everything in Sections 3–6 is a consequence of the single fact that the $n!$ rank vectors lie on one sphere inside one hyperplane. The chordal representation, the diameter, the Pearson identity, the parity invariant, the rigidity gap, and the exact null mean all reduce to that. This is worth emphasising because it explains why these facts are exact rather than asymptotic: they are statements about a finite, highly symmetric point configuration, and the symmetry group $S_n$ acts transitively on it.

Section 7 is harder. The Diaconis–Graham upper bound is not a cosphericity consequence; it requires the two-sided displacement count of Lemmas 7.8–7.9 and the double-counting identity of Lemma 7.10. Its content is that the $\ell^1$ geometry of the permutohedron is controlled by the Coxeter combinatorics of $S_n$.

Section 8 required a change of model. The threshold axis cannot be represented as a perturbation of a permutation at all: the flagged/unflagged dichotomy is not a ranking. Modelling it as a two-block variable is the step that makes the ceiling appear, and the ceiling is sharp because the extremal block sums are attained.

### 10.2 An open problem: the Diaconis–Graham lower bound

The companion inequality
$$\mathrm{inv}(\sigma) + T(\sigma) \ \le\ F(\sigma),$$
where $T(\sigma)$ is the Cayley length (the minimum number of transpositions expressing $\sigma$, equal to the number of non-fixed points minus the number of nontrivial cycles), is not established here. Two natural approaches fail for identifiable reasons:

* *Bubble-sort induction.* One would like to show each adjacent transposition decreases both sides compatibly. It does not: an adjacent transposition can leave $F$ unchanged while decreasing $\mathrm{inv}$ by one, so the induction has no slack.
* *Per-index charging.* One would like $|\mathrm{Inv}^{\to}(\sigma,i)| \le (\sigma(i)-i)^+$, dual to Lemma 7.8. This is false: for $\sigma = [2,3,1,0]$ at $i=2$ the left-hand side is $1$ while $\sigma(2)-2 = -1$.

A genuinely global argument is required. The inequality has been checked exhaustively for all $n\le 6$. The most promising reading is structural: $F$, $\mathrm{inv}$, and $T$ are all length functions on $S_n$, and the claim is that $F$ dominates the sum of the Coxeter length and the Cayley length. Since $F$ is known to be subadditive with $F((a\,b)) = 2|a-b|$ (Theorems 7.4, 7.5), one has strong control over $F$ along transposition factorisations, and it is plausible that the inequality is a facet inequality of the permutohedron viewed through the Cayley graph. Establishing it would close the sandwich, giving mutual bi-Lipschitz equivalence of the three classical ranking metrics with explicit constants.

### 10.3 Limitations

The theory assumes tie-free rankings. Ties place the "rank vector" at a face rather than a vertex of the permutohedron; the parity invariant and the rigidity gap are then modified, and the appropriate object is the *permutohedron of a composition*. The block ceiling, by contrast, degrades gracefully: with mid-ranks assigned to ties the extremal block sums remain valid up to a correction of order $t/n$ for $t$ tied items, so the ceiling $3p(1-p)$ is essentially unaffected in the regime of interest.

The block ceiling is stated for a single threshold, producing two blocks. For a $k$-block coarsening the analogous ceiling depends on the block-size profile and interpolates between the two-block value and $1$; the general statement is a natural next step.

Finally, the results are about *attainability*, not about estimation. They say what a correlation can be, not what it will be under a given sampling design. The value of that distinction is exactly the one exploited in Section 8: an attainability bound is unconditional and can be checked before running an experiment.

### 10.4 Broader connections

The permutohedron is the weight polytope of the standard representation of $S_n$ and the Cayley graph polytope of the Coxeter system $(S_n,\{s_i\})$; its edges are adjacent transpositions and its normal fan is the braid arrangement. Reading rank statistics as functions on this polytope embeds classical nonparametric statistics into that framework, where the natural questions become: which statistics are linear functionals on $\Pi_{n-1}$ (Spearman is, up to the affine chordal identity); which are length functions (the footrule is); and which acceptance regions are unions of faces. The block ceiling is an instance of a general principle — a *coarsening bound* — asserting that projecting onto a low-dimensional quotient of the vertex set caps every correlation with the original. Analogous ceilings should exist for any coarsening whose extremal fibre sums can be computed, which includes quantile bucketing, top-$k$ truncation, and censoring.

---

## 11. Future directions

**Direction 1 — the Diaconis–Graham lower bound as a permutohedron facet inequality.** Read $\mathrm{inv}(\sigma)+T(\sigma)\le F(\sigma)$ not as a combinatorial identity but as the assertion that the linear-type functional $F$ dominates the sum of two independent word-length functions on $S_n$: the Coxeter length ($\mathrm{inv}$) and the Cayley length ($T$). The subadditivity of $F$ and the exact transposition cost $F((a\,b))=2|a-b|$ supply precisely the control needed along transposition factorisations; the missing ingredient is a global exchange argument. Success would complete the mutual bi-Lipschitz equivalence of the three metrics.

**Direction 2 — $k$-block and quantile coarsening ceilings.** Generalise Theorem 8.4 from a two-block indicator to an arbitrary $k$-block quantile bucketing with profile $(m_1,\dots,m_k)$. The extremal fibre-sum argument of Theorem 8.2 goes through verbatim; what is needed is the right normalisation, after which one should recover $3p(1-p)$ at $k=2$ and $1$ in the limit $k=n$. This would give an operational curve "resolution versus attainable correlation" for any bucketing scheme.

**Direction 3 — ties and the permutohedron of a composition.** Extend the parity invariant and the rigidity gap to tied data, where rank vectors lie on faces of $\Pi_{n-1}$. The expected outcome is a gap of the form $12/\bigl(n^3-n-\sum_t (t^3-t)\bigr)$, matching the classical tie correction to Spearman's coefficient, with a geometric derivation.

**Direction 4 — quantisation and multiple testing.** Since $\rho$ takes only $O(n^3)$ distinct values, exact permutation tests on small $n$ have an atomically supported null distribution. Combining the exact null mean (Theorem 6.5) with the quantisation grid should yield exact, non-asymptotic critical values and, in particular, exact rather than conservative $p$-values for small-$n$ rank tests.

**Direction 5 — dynamic thresholds.** The block ceiling is static. In practice $u$ drifts and $p$ with it. One would like a bound on the achievable correlation of a *time-averaged* dial in terms of the trajectory $p(t)$; concavity of $p\mapsto 3p(1-p)$ suggests the average ceiling is bounded by the ceiling of the average flag rate, which would make a fluctuating threshold strictly worse than its mean.

---

## 12. Conclusion

On finite, tie-free data, a rank correlation is not an arbitrary number in $[-1,1]$. It is a rescaled chordal distance between two vertices of the permutohedron, and the polytope dictates its behaviour: the attainable values form an even-spaced grid; there is a forbidden window of width $12/(n^3-n)$ just below $1$; the exact diameter is $n(n^2-1)/3$, achieved only at antipodal (reversed) rankings; the uniform ensemble has null mean exactly zero; and the $\ell^1$, $\ell^2$, and inversion readings are equivalent up to explicit constants, so no reparametrisation changes a verdict.

Most consequentially, coarsening the data by a threshold caps the correlation at $\sqrt{3p(1-p)}$, whatever the underlying statistic. The empirical pattern that motivated this work — a dial that is inert to population size but breaks systematically under a tighter threshold — is not two separate findings about noise. It is one geometric fact: scale does not move the vertices of the permutohedron, but coarsening collapses them.
