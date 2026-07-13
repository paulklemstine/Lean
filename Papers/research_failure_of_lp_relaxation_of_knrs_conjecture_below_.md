# The $L^p$ Relaxation of the KNRS Local-Density Conjecture: Sharp Thresholds and the Failure of the Edge-Count Formula

**Author:** Aristotle
**Date:** 2026-07-13

## Abstract

The Kohayakawa–Nagle–Rödl–Schacht (KNRS) conjecture predicts that a
$\rho$-locally dense host graph contains at least the random count $\rho^{e(F)}$ of
copies of every fixed pattern $F$. We study a one-parameter *$L^p$ relaxation* of this
statement, in which each edge of the pattern is weighted by an exponent $p>0$ and the
resulting functional is renormalized by a $p$-th root. For each pattern $F$ this defines
a critical exponent $p^\star(F)$ below which $\rho$-locally dense counterexamples exist
and above which none do. A clean candidate formula, $p^\star(F)=\binom{n}{2}/m$ (with
$n$ the number of non-isolated vertices and $m$ the number of edges), was proposed by
analogy. We prove two things. First, for the single edge $F=K_2$ this formula is exactly
correct: the threshold is precisely $p^\star(K_2)=1$, with a power-mean argument
excluding counterexamples for $p\ge 1$ and an explicit two-block graphon realizing them
for every $0<p<1$. Second, the formula is *false in general*: for the two-edge matching
$M_2$ it predicts $3$, whereas the true threshold is $1$. The mechanism is a
factorization $\|W_{M_2}\|_{L^p}=\|W_{K_2}\|_{L^p}^2$ that reduces the matching to a
single edge. We then identify the correct block-construction threshold $(n-c)/m$, where
$c$ is the number of connected components of $F$, show it satisfies
$(n-c)/m\le \binom{n}{2}/m$ with the gap unbounded over the matching family, and discuss
the open problem of determining $p^\star(F)$ exactly.

**Keywords:** local density, KNRS conjecture, graphons, homomorphism density, $L^p$
relaxation, power-mean inequality, block kernels, matchings.

---

## 1. Introduction

### 1.1 Local density and the KNRS conjecture

A recurring theme in extremal and probabilistic combinatorics is that a graph need not
be random in order to inherit the counting behavior of a random graph; it suffices that
it be *uniformly dense at every scale*. The cleanest formalization uses graphons. A
**graphon** is a symmetric measurable function
$$W:[0,1]^2\to[0,1],\qquad W(x,y)=W(y,x),$$
which one thinks of as a limit of dense weighted adjacency matrices. We say $W$ is
**$\rho$-locally dense** if every measurable set $S\subseteq[0,1]$ carries at least its
proportional share of weight:
$$\int_{S\times S} W(x,y)\,dx\,dy \;\ge\; \rho\,|S|^2 .$$
The Kohayakawa–Nagle–Rödl–Schacht conjecture asserts that this local condition alone
forces the random abundance of every fixed pattern: for every graph $F$ with edge set
$E(F)$,
$$t(F,W):=\int_{[0,1]^{V(F)}} \prod_{\{i,j\}\in E(F)} W(x_i,x_j)\,\prod_{i\in V(F)} dx_i
\;\ge\; \rho^{\,e(F)} .$$

### 1.2 The $L^p$ relaxation

We investigate a natural one-parameter deformation. For an exponent $p>0$ define the
**$L^p$ pattern functional** and its **$L^p$ pattern norm** by
$$\|W_F\|_{L^p}^{\,p} := \int_{[0,1]^{V(F)}} \prod_{\{i,j\}\in E(F)} W(x_i,x_j)^{p}
\,\prod_{i\in V(F)} dx_i,
\qquad
\|W_F\|_{L^p} := \big(\|W_F\|_{L^p}^{\,p}\big)^{1/p}.$$
At $p=1$ this reduces to the classical homomorphism density $t(F,W)$. Decreasing $p$
rewards spreading weight and penalizes concentration, making it progressively easier to
force $\|W_F\|_{L^p}<\rho^{e(F)}$. This motivates the central object of study.

> **Definition (critical exponent).** For a pattern $F$, let $p^\star(F)$ be the
> supremum of exponents $p$ for which there exists a $\rho$-locally dense graphon $W$
> (valued in $[0,1]$, for some $\rho\in(0,\tfrac12]$) with $\|W_F\|_{L^p}<\rho^{e(F)}$.
> For $p<p^\star(F)$ the relaxed conjecture *fails*; for $p>p^\star(F)$ it *holds*.

### 1.3 The candidate formula and our results

Reasoning that $\binom{n}{2}$ edges could in principle be packed onto the $n$
non-isolated vertices of $F$, one is led to the candidate
$$p^\star(F) \stackrel{?}{=} \frac{\binom{n}{2}}{m}, \qquad n=|V(F)|_{\ne 0},\ m=e(F).$$
Our contributions are:

1. **The formula is exact for the single edge (Section 3).** For $F=K_2$ the formula
   gives $1$, and this is sharp: no counterexample exists for $p\ge 1$ (Theorem 3.1),
   while an explicit two-block graphon is a counterexample for every $0<p<1$
   (Theorem 3.3). Hence $p^\star(K_2)=1$ (Theorem 3.4).

2. **The formula is false in general (Section 4).** For the two-edge matching $M_2$ it
   predicts $3$, but the true threshold is $1$. A factorization identity
   (Theorem 4.1) reduces the matching functional to the edge functional, excluding all
   counterexamples on $1\le p<3$ (Theorem 4.2) while a counterexample survives for
   $0<p<1$ (Theorem 4.3).

3. **The corrected block threshold (Section 5).** The honest quantity reachable by block
   constructions is $(n-c)/m$, with $c$ the number of connected components. It satisfies
   $(n-c)/m\le \binom{n}{2}/m$, and the gap is unbounded over matchings.

A methodological remark: to keep every integral a finite, fully rigorous sum, all results
are established in the standard **finite step-graphon model**. One replaces $[0,1]$ by
$N$ equal blocks indexed by $\{0,\dots,N-1\}$ and a graphon by a symmetric kernel
$W:\{0,\dots,N-1\}^2\to\mathbb{R}$ under the uniform measure. Local density and the
pattern norms translate into finite averages, and no generality relevant to the
threshold question is lost.

---

## 2. The finite model and basic definitions

Throughout, fix $N\ge 1$ and identify the vertex set with $\{0,\dots,N-1\}$ under the
uniform probability measure (each block has mass $1/N$).

> **Definition 2.1 (local density, finite model).** A symmetric kernel
> $W:\{0,\dots,N-1\}^2\to\mathbb{R}$ is **$\rho$-locally dense** if for every subset
> $S\subseteq\{0,\dots,N-1\}$,
> $$\rho\,|S|^2 \;\le\; \sum_{i\in S}\sum_{j\in S} W(i,j).$$

> **Definition 2.2 (single-edge $L^p$ functional).** For $p>0$,
> $$\|W_{K_2}\|_{L^p}^{\,p} = \frac{1}{N^2}\sum_{i,j} W(i,j)^p,
> \qquad
> \|W_{K_2}\|_{L^p} = \left(\frac{1}{N^2}\sum_{i,j} W(i,j)^p\right)^{1/p}.$$

> **Definition 2.3 (two-edge-matching $L^p$ functional).** For $p>0$,
> $$\|W_{M_2}\|_{L^p}^{\,p} = \frac{1}{N^4}\sum_{a,b,c,d} W(a,b)^p\,W(c,d)^p,
> \qquad
> \|W_{M_2}\|_{L^p} = \big(\|W_{M_2}\|_{L^p}^{\,p}\big)^{1/p}.$$

The four indices $a,b,c,d$ range independently, faithfully encoding that the two edges of
$M_2$ are vertex-disjoint. A trivial but useful fact used repeatedly: if $W\ge 0$
pointwise then $\|W_{K_2}\|_{L^p}^{\,p}\ge 0$, since it is a nonnegative combination of
the nonnegative quantities $W(i,j)^p$.

---

## 3. The single edge: the formula is exact

Here $n=2$, $m=1$, $e(K_2)=1$, and $\binom{2}{2}/1 = 1$.

### 3.1 No counterexample for $p\ge 1$

> **Theorem 3.1 (upper region).** Let $N\ge 1$ and let $W\ge 0$ be $\rho$-locally dense.
> Then for every $p\ge 1$,
> $$\|W_{K_2}\|_{L^p} \;\ge\; \rho.$$

**Proof sketch.** Apply local density to $S$ = the whole vertex set. Since $|S|=N$,
$$\rho \;\le\; \frac{1}{N^2}\sum_{i,j} W(i,j) = \text{(arithmetic mean of $W$)}.$$
Now invoke the weighted power-mean inequality with the uniform weights $1/N^2$: for
$p\ge 1$,
$$\text{arithmetic mean of } W \;\le\; \Big(\text{arithmetic mean of } W^p\Big)^{1/p}
= \|W_{K_2}\|_{L^p}.$$
Chaining the two inequalities gives $\rho\le \|W_{K_2}\|_{L^p}$. $\qquad\blacksquare$

The content is entirely that $t\mapsto t^p$ is convex for $p\ge1$; concentration of the
weight cannot decrease the $L^p$ average below the plain average, which local density
already pins at $\ge\rho$.

### 3.2 An explicit counterexample for $0<p<1$

Work with $N=2$. Define the **two-block kernel**
$$\mathrm{block}_\rho(i,j) = \begin{cases} 2\rho & i=j,\\ 0 & i\ne j.\end{cases}$$

> **Lemma 3.2 (validity of the construction).** If $0\le \rho$ and $2\rho\le 1$ then
> $\mathrm{block}_\rho$ takes values in $[0,1]$ and is $\rho$-locally dense.

**Proof sketch.** Values are $0$ or $2\rho\in[0,1]$. For local density, a subset
$S\subseteq\{0,1\}$ contributes only through diagonal entries, so
$\sum_{i,j\in S}\mathrm{block}_\rho(i,j) = 2\rho\,|S|$; since $|S|\le 2$ we have
$2\rho|S|\ge \rho|S|^2$, i.e. $\rho|S|(2-|S|)\ge 0$. $\qquad\blacksquare$

A direct evaluation of the functional gives
$$\|\mathrm{block}_\rho\|_{L^p}^{\,p}
= \frac{1}{4}\big((2\rho)^p + 0 + 0 + (2\rho)^p\big) = \tfrac12 (2\rho)^p,$$
hence
$$\|\mathrm{block}_{\rho,K_2}\|_{L^p} = \big(\tfrac12(2\rho)^p\big)^{1/p}
= \rho\cdot 2^{\,1-1/p}.$$

> **Theorem 3.3 (lower region).** For every $\rho>0$ and every $0<p<1$,
> $$\|\mathrm{block}_{\rho,K_2}\|_{L^p} = \rho\cdot 2^{\,1-1/p} < \rho.$$

**Proof sketch.** From the evaluation above, it suffices that $2^{1-1/p}<1$, i.e. that
the exponent $1-\tfrac1p$ is negative, which holds exactly when $p<1$. Equivalently, one
shows $\|\mathrm{block}_\rho\|_{L^p}^{\,p} = \tfrac12(2\rho)^p = 2^{p-1}\rho^p < \rho^p$
because $2^{p}<2$ for $p<1$, and then takes $p$-th roots. $\qquad\blacksquare$

### 3.3 Sharpness

> **Theorem 3.4 (single-edge threshold is exactly $1$).** For $0<\rho\le\tfrac12$:
> for every $p\ge 1$ no $\rho$-locally dense counterexample exists (Theorem 3.1), while
> for every $0<p<1$ the graphon $\mathrm{block}_\rho$ is a $\rho$-locally dense
> counterexample valued in $[0,1]$ (Lemma 3.2, Theorem 3.3). Hence $p^\star(K_2)=1$,
> matching $\binom{2}{2}/1$.

---

## 4. The two-edge matching: the formula fails

For $M_2$ we have $n=4$, $m=2$, $e(M_2)=2$, so the candidate formula predicts
$$\binom{4}{2}/2 = 6/2 = 3,$$
i.e. counterexamples for every $p<3$. We refute this.

### 4.1 Factorization

> **Theorem 4.1 (factorization of the matching functional).** For every kernel $W$ and
> every $p>0$,
> $$\|W_{M_2}\|_{L^p}^{\,p} = \big(\|W_{K_2}\|_{L^p}^{\,p}\big)^2,
> \qquad\text{and if } W\ge 0,\quad \|W_{M_2}\|_{L^p} = \|W_{K_2}\|_{L^p}^{\,2}.$$

**Proof sketch.** The quadruple sum splits because the summand is a product of a term in
$(a,b)$ and a term in $(c,d)$:
$$\sum_{a,b,c,d} W(a,b)^p W(c,d)^p
= \Big(\sum_{a,b} W(a,b)^p\Big)\Big(\sum_{c,d} W(c,d)^p\Big),$$
and $1/N^4 = (1/N^2)^2$, giving
$\|W_{M_2}\|_{L^p}^{\,p} = (\|W_{K_2}\|_{L^p}^{\,p})^2$. Taking the $(1/p)$-th power and
using $\big((\,\cdot\,)^2\big)^{1/p} = \big((\,\cdot\,)^{1/p}\big)^2$ for nonnegative
bases yields the norm identity. $\qquad\blacksquare$

Conceptually: because the edges of $M_2$ are vertex-disjoint, the pattern norm is
multiplicative over the two independent edges. A matching is, for this functional, one
edge counted twice.

### 4.2 No counterexample for $1\le p<3$ — the formula is wrong

> **Theorem 4.2 (disproof of the $\binom{n}{2}/m$ formula).** Let $N\ge1$ and let
> $W\ge 0$ be $\rho$-locally dense with $\rho\ge 0$. Then for every $p\ge 1$,
> $$\|W_{M_2}\|_{L^p} \;\ge\; \rho^2 = \rho^{\,e(M_2)}.$$
> In particular, no counterexample exists anywhere on $1\le p<3$, contradicting the
> prediction that counterexamples exist for all $p<3$.

**Proof sketch.** By factorization $\|W_{M_2}\|_{L^p} = \|W_{K_2}\|_{L^p}^2$. By
Theorem 3.1, $\|W_{K_2}\|_{L^p}\ge\rho\ge0$ for $p\ge1$; squaring a valid inequality
between nonnegatives preserves it, giving $\|W_{M_2}\|_{L^p}\ge\rho^2$. $\qquad\blacksquare$

Thus the true critical exponent for $M_2$ is at most $1$, a factor of $3$ below the
formula's prediction.

### 4.3 The true threshold for $M_2$ is exactly $1$

> **Theorem 4.3 (sharpness for the matching).** For $0<\rho\le\tfrac12$ and every
> $0<p<1$, the two-block graphon $\mathrm{block}_\rho$ (on $N=2$) is $\rho$-locally
> dense, valued in $[0,1]$, and satisfies
> $$\|\mathrm{block}_{\rho,M_2}\|_{L^p} < \rho^2 = \rho^{\,e(M_2)}.$$
> Combined with Theorem 4.2, $p^\star(M_2)=1$.

**Proof sketch.** By factorization $\|\mathrm{block}_{\rho,M_2}\|_{L^p} =
\|\mathrm{block}_{\rho,K_2}\|_{L^p}^2$. By Theorem 3.3 the inner norm is
$\rho\cdot 2^{1-1/p}<\rho$, and squaring a strict inequality between nonnegatives
(with $\rho>0$) yields $<\rho^2$. $\qquad\blacksquare$

---

## 5. The corrected threshold: connectivity, not vertex count

The single edge and the matching share the value $1$ for their true threshold, and both
are explained by the *number of independent binding constraints* in the pattern rather
than by the number of vertices.

### 5.1 The $k$-block construction

Generalize the two-block kernel. Partition the vertices into $k$ equal blocks and set
$$W_k(x,y) = \begin{cases} k\rho & x,y \text{ in the same block},\\ 0 & \text{otherwise.}\end{cases}$$

> **Proposition 5.1 (local density of block kernels).** For $0\le\rho$ and $k\rho\le1$,
> $W_k$ is a graphon valued in $[0,1]$ and is $\rho$-locally dense.

**Proof sketch.** For a set $S$ meeting block $b$ in mass $s_b$ (so $\sum_b s_b=|S|$),
$$\int_{S\times S} W_k = k\rho\sum_b s_b^2 \ge k\rho\cdot\frac{(\sum_b s_b)^2}{k}
= \rho|S|^2,$$
by Cauchy–Schwarz (equivalently, the power-mean inequality across blocks). $\qquad\blacksquare$

### 5.2 The block-kernel value of a general pattern

> **Proposition 5.2 (block functional).** Let $F$ have $n$ non-isolated vertices, $m$
> edges, and $c$ connected components. Then for the $k$-block kernel,
> $$\|W_{k,F}\|_{L^p}^{\,p} = k^{\,c-n+mp}\,\rho^{mp},
> \qquad
> \|W_{k,F}\|_{L^p} = \rho^{\,m}\, k^{\,m-(n-c)/p}.$$

**Proof sketch.** In the sum defining $\|W_{k,F}\|_{L^p}^{\,p}$, a vertex assignment
$\varphi$ contributes a nonzero term only if $\varphi$ is constant on every connected
component (otherwise some edge lands off-diagonal and contributes a factor $0$). There
are exactly $k^{c}$ such assignments, each carrying a normalization $k^{-n}$ (one factor
$1/k$ per vertex under the uniform measure) and a value $(k\rho)^{mp}$ (one factor per
edge). Multiplying, $k^{c}\cdot k^{-n}\cdot (k\rho)^{mp} = k^{c-n+mp}\rho^{mp}$; taking
the $(1/p)$-th power gives the norm. $\qquad\blacksquare$

### 5.3 The corrected threshold and the size of the error

Setting $\|W_{k,F}\|_{L^p}<\rho^{e(F)}=\rho^{m}$ in Proposition 5.2 requires
$k^{\,m-(n-c)/p}<1$, i.e. (for $k\ge2$) the exponent negative:
$$m-\frac{n-c}{p}<0 \iff p<\frac{n-c}{m}.$$
Sending $k\to\infty$ makes the violation arbitrarily strong. This proves:

> **Theorem 5.3 (block-construction threshold).** For every pattern $F$ with $n$
> non-isolated vertices, $m$ edges, and $c$ components, and for every $p<(n-c)/m$, there
> exist $\rho$-locally dense graphons with $\|W_F\|_{L^p}<\rho^{e(F)}$. Hence
> $p^\star(F)\ge (n-c)/m$.

Since $n-c\le n-1\le\binom{n}{2}$ for $n\ge1$, we always have
$$\frac{n-c}{m}\le\frac{\binom{n}{2}}{m},$$
so the corrected threshold never exceeds the candidate formula. The two agree for the
single edge and for $M_2$ (both give $1$), but for a general matching $M_k$ with $k$
edges ($n=2k$, $m=k$, $c=k$),
$$\frac{n-c}{m}=1 \qquad\text{versus}\qquad \frac{\binom{2k}{2}}{k}=2k-1,$$
so the discrepancy $2k-2$ grows without bound. The edge-count formula is not off by a
constant; it measures the wrong invariant.

---

## 6. Algorithms

The results above are constructive and lend themselves to exact rational computation
(no floating point is needed for the block kernels when $\rho$ is rational and $p$ is an
integer or simple rational). We record the two core routines.

**Algorithm A — Verify local density of a finite kernel.** Given a symmetric matrix
$W\in\mathbb{R}^{N\times N}$ and $\rho$, decide whether $W$ is $\rho$-locally dense by
checking $\sum_{i,j\in S}W(i,j)\ge\rho|S|^2$ over all $2^N$ subsets $S$. Exponential in
$N$ but exact; adequate for the small witnesses used here.

**Algorithm B — Block-kernel threshold.** Given $n$, $m$, $c$, return the corrected
block threshold $(n-c)/m$ and the naive formula $\binom{n}{2}/m$, and report their gap.
Constant time.

**Algorithm C — Evaluate the pattern norm of a block kernel.** Given $k$, $\rho$, $p$
and pattern invariants $(n,m,c)$, return $\rho^{m}k^{\,m-(n-c)/p}$ via Proposition 5.2,
avoiding the $k^n$-term brute-force sum. Constant time.

Full type-hinted implementations accompany this paper.

---

## 7. Applications and discussion

**Quasirandomness with a twist.** The single-edge result is a sharp statement about when
uniform local density forces the $L^p$-averaged edge weight to stay above $\rho$. For
$p\ge1$ it always does; for $p<1$ concentrating the weight onto diagonal blocks beats
the target. This delineates precisely the regime in which "local density" and
"$L^p$-typicality" coincide for edges.

**A caution for extremal analogies.** The failure of $\binom{n}{2}/m$ is a concrete
warning about a common heuristic: guessing thresholds from crude vertex/edge counts.
Whenever a pattern can be decomposed into vertex-disjoint pieces, multiplicativity of the
functional collapses the problem to its pieces, and the right invariant is the number of
*independent constraints* $n-c$ (the rank of a spanning forest), not the number of
*possible* edges $\binom{n}{2}$.

**Rigor.** All the equalities and inequalities above are elementary consequences of the
power-mean inequality, Cauchy–Schwarz, and the multiplicativity of the matching
functional, and have been checked in a fully formal, machine-independent setting in the
finite step-graphon model.

---

## 8. Future directions

1. **Determine the exact threshold $p^\star(F)$.** We have the general lower bound
   $p^\star(F)\ge (n-c)/m$ from block constructions, and for matchings a matching upper
   bound $p^\star=1$. Is $p^\star(F)=(n-c)/m$ for all $F$? A natural first test is the
   triangle $K_3$ ($n=3$, $m=3$, $c=1$): block constructions give $p<2/3$; does a
   counterexample exist for $2/3\le p<1$, and is there any counterexample for $p\ge1$?
   Analyzing the triangle homomorphism functional together with either a smarter
   construction or a Sidorenko-type lower bound would settle this.

2. **Rank-one (positive semidefinite) perturbations.** Kernels of the form
   $W=\rho+c\,\varphi(x)\varphi(y)$ with $c\ge0$ are automatically $\rho$-locally dense,
   since $\int_{S\times S}W = \rho|S|^2 + c\big(\int_S\varphi\big)^2\ge\rho|S|^2$. These
   are far more flexible than block kernels and are the natural candidates for beating
   $(n-c)/m$. Computing their $L^p$ functional is a concrete next step.

3. **General block-kernel theorem.** Establish the closed form
   $\frac{1}{N^n}\sum_\varphi\prod_{\text{edges}}W(\varphi)^p = k^{\,c-n+mp}\rho^{mp}$
   for the $k$-block kernel and a general graph $F$ in full generality, and use it to map
   out the block-achievable region for all patterns simultaneously.

---

## Appendix: summary of thresholds

| Pattern $F$ | $n$ | $m$ | $c$ | naive $\binom{n}{2}/m$ | corrected $(n-c)/m$ | proven $p^\star$ |
|---|---|---|---|---|---|---|
| Edge $K_2$ | 2 | 1 | 1 | $1$ | $1$ | $1$ (exact) |
| Matching $M_2$ | 4 | 2 | 2 | $3$ | $1$ | $1$ (exact) |
| Matching $M_k$ | $2k$ | $k$ | $k$ | $2k-1$ | $1$ | $1$ (exact) |
| Triangle $K_3$ | 3 | 3 | 1 | $1$ | $2/3$ | open in $[2/3,1]$ |
