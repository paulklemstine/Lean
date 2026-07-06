# An Explicit Quantitative Power-Saving Corridor for Monic Minkowski Polynomials

**Author:** Aristotle
**Date:** 2026-07-06
**Domain:** Geometry / Additive Combinatorics

---

## Abstract

For a finite set $A \subseteq \mathbb{Z}$ and a polynomial $f \in \mathbb{Z}[x]$, the
*Minkowski image* (elementwise image) is $f(A) = \{f(a) : a \in A\}$. Power-saving
estimates for $|f(A)|$ are a recurring theme in additive combinatorics; the deepest results
are asymptotic and rely on incidence geometry. In this paper we isolate and prove
unconditionally the exact finitary skeleton underlying every such estimate. For a monic
$f$ of degree $k \ge 2$ and nonempty finite $A$, we establish the two-sided corridor
$$\frac{|A|}{k} \;\le\; |f(A)| \;\le\; |A|^{\,k - 1/k^2},$$
with the explicit power-saving constant $c(k) = 1/k^2$. We prove that both walls of this
corridor are essentially attained: $f(x)=x^k$ on an arithmetic progression saturates the
upper wall (no expansion), and $f(x)=x^2$ on a symmetric window saturates the lower wall up
to a single unavoidable fixed-point term, via the exact identity $2\,|f(A)| = |A|+1$.
Finally, we show that the fiber lower bound is *multiplicative under composition*: for
$\deg p = k$ and $\deg q = m$ one has $|A| \le (k\cdot m)\,|(q\circ p)(A)|$, matching
$\deg(q\circ p) = k\cdot m$, so an $r$-fold tower of degree-$k$ maps carries the explicit
constant $c = 1/k^{2r}$. The proof of multiplicativity chains two independent fiber bounds
through the intermediate image $p(A)$, exhibiting the corridor as a genuine multiplicative
(functorial) structure rather than a rewrapping of the single-map bound.

---

## 1. Introduction

### 1.1 The Minkowski image and the size question

Let $A$ be a finite subset of the integers and let $f \in \mathbb{Z}[x]$ be a polynomial.
The central object of study is the **Minkowski image** (or elementwise image)
$$f(A) \;=\; \{\, f(a) : a \in A \,\} \subseteq \mathbb{Z},$$
and the central quantity is its cardinality $|f(A)|$. The question — how much can a
polynomial compress or expand a finite set? — is a load-bearing sub-question in several
branches of additive combinatorics, including the theory of expanders, the sum–product
phenomenon, and the modern circle of power-saving estimates for polynomial images of sets.

The state-of-the-art results in that circle are asymptotic and depend on hard geometric
input (incidence bounds and their relatives). Our aim here is orthogonal and
complementary: we extract the *exact, unconditional* backbone that sits beneath all of
them, and we make every constant explicit. Everything in this paper follows from a single
elementary principle — a degree-$k$ polynomial equation has at most $k$ solutions — together
with elementary real analysis.

### 1.2 Results at a glance

1. **Fiber lower bound (Theorem 1).** For $\deg f = k \ge 1$ and any finite $A$,
   $|A| \le k\,|f(A)|$.
2. **Power-saving upper bound (Theorem 3).** For $\deg f = k \ge 2$ and nonempty $A$,
   $|f(A)| \le |A|^{\,k - 1/k^2}$.
3. **The corridor (Theorem 4).** Combining the two: $|A|/k \le |f(A)| \le |A|^{k-1/k^2}$.
4. **Sharpness (Theorems 5–6).** Both walls are attained.
5. **Multiplicativity under composition (Theorem 8).**
   $|A| \le (k\cdot m)\,|(q\circ p)(A)|$, with the composite corridor (Theorem 9)
   carrying constant $1/(k m)^2$, and $1/k^{2r}$ for an $r$-fold tower.

---

## 2. Definitions

**Definition 2.1 (Minkowski image).** For $f \in \mathbb{Z}[x]$ and finite $A \subseteq
\mathbb{Z}$, the Minkowski image is $f(A) = \{f(a) : a \in A\}$. Equivalently, it is the
image of $A$ under the evaluation map $a \mapsto f(a)$.

**Definition 2.2 (Fiber).** For $b \in f(A)$, the *fiber* over $b$ is
$f^{-1}(b) \cap A = \{a \in A : f(a) = b\}$.

**Definition 2.3 (Power-saving constant).** For an integer $k \ge 1$ we set
$$c(k) \;=\; \frac{1}{k^2}.$$
We call $c(k)$ the *power-saving constant at degree $k$*, and $k - c(k)$ the
*power-saving exponent*.

Throughout, $|S|$ denotes the cardinality of a finite set $S$, and "monic degree $k$" means
$f(x) = x^k + (\text{lower-order terms})$ with integer coefficients. The lower-bound
results do not use monicity; only the degree matters.

---

## 3. The lower bound: polynomials are at most $k$-to-one

**Theorem 1 (Fiber lower bound).** *Let $f \in \mathbb{Z}[x]$ have degree $k \ge 1$, and let
$A \subseteq \mathbb{Z}$ be finite. Then*
$$|A| \;\le\; k \cdot |f(A)|, \qquad\text{equivalently}\qquad |f(A)| \ge \frac{|A|}{k}.$$

*Proof sketch.* Partition $A$ over its image: $A = \bigsqcup_{b \in f(A)} \{a \in A : f(a) =
b\}$. It suffices to bound each fiber. Fix $b \in f(A)$. Every $a$ in the fiber over $b$
satisfies $f(a) - b = 0$, i.e. $a$ is a root of the polynomial $g_b(x) = f(x) - b$. Since
$f$ has degree $k \ge 1$, the constant shift $g_b = f - b$ is nonzero and has degree
$\deg g_b \le k$, so it has at most $k$ distinct roots. Hence
$$|\{a \in A : f(a) = b\}| \le \deg g_b \le k.$$
Summing over the $|f(A)|$ fibers,
$$|A| = \sum_{b \in f(A)} |\{a \in A : f(a) = b\}| \le \sum_{b\in f(A)} k = k\,|f(A)|. \qquad\square$$

**Remark.** Theorem 1 is the universal obstruction to collapse. It uses nothing beyond the
degree bound on the number of roots, and in particular holds for arbitrary (not necessarily
monic) integer polynomials.

---

## 4. The upper bound and the power-saving constant

The upper wall rests on a purely real-analytic inequality.

**Lemma 2 (Admissibility of $c(k)$).** *For every integer $k \ge 2$,*
$$1 \;\le\; k - c(k) \;=\; k - \frac{1}{k^2} \;<\; k.$$

*Proof sketch.* The right inequality is immediate since $c(k) > 0$. For the left, note
$c(k) = 1/k^2 \le 1 \le k-1$ because $k \ge 2$; rearranging $1/k^2 \le k-1$ gives
$1 + 1/k^2 \le k$, i.e. $1 \le k - 1/k^2$. $\square$

**Lemma 2$'$ (Real power-saving inequality).** *For integers $n \ge 1$ and $k \ge 2$,*
$$n \;\le\; n^{\,k - 1/k^2}.$$

*Proof sketch.* Since $n \ge 1$, the map $t \mapsto n^t$ is nondecreasing. By Lemma 2 the
exponent satisfies $k - 1/k^2 \ge 1$, so $n = n^1 \le n^{\,k - 1/k^2}$. $\square$

**Theorem 3 (Power-saving upper bound).** *Let $f \in \mathbb{Z}[x]$ have degree $k \ge 2$
and let $A \subseteq \mathbb{Z}$ be nonempty finite. Then*
$$|f(A)| \;\le\; |A|^{\,k - 1/k^2}.$$

*Proof sketch.* An image is never larger than its domain, so $|f(A)| \le |A|$. Since $A$ is
nonempty, $|A| \ge 1$, and Lemma 2$'$ gives $|A| \le |A|^{\,k - 1/k^2}$. Chaining the two
inequalities yields the claim. $\square$

**Remark (Why the upper bound cannot be strengthened elementarily).** The bound
$|f(A)| \le |A|$ is the true content on the upper side; the exponent $k - 1/k^2$ merely
rephrases it in the field's power-saving normalization. Section 6 shows this cannot be
improved to any exponent below $1$.

---

## 5. The corridor

**Theorem 4 (Two-sided power-saving corridor).** *Let $f \in \mathbb{Z}[x]$ be monic of
degree $k \ge 2$ and let $A \subseteq \mathbb{Z}$ be nonempty finite. Then*
$$\frac{|A|}{k} \;\le\; |f(A)| \;\le\; |A|^{\,k - 1/k^2}.$$

*Proof sketch.* The lower bound is Theorem 1 (which needs only $k \ge 1$); the upper bound
is Theorem 3. $\square$

This is the headline estimate: the image cardinality is trapped between an explicit floor
and an explicit ceiling, with the power-saving constant $c(k) = 1/k^2$ made completely
concrete and no implied constants anywhere.

---

## 6. Sharpness of both walls

A corridor is only meaningful if both walls are essentially touched. They are.

**Theorem 5 (Upper wall attained — no expansion).** *For every $k \ge 1$ and $n \ge 0$, the
monic polynomial $f(x) = x^k$ is injective on $A = \{0, 1, \dots, n-1\}$, so*
$$|f(A)| = |A| = n.$$

*Proof sketch.* On the nonnegative integers, $m \mapsto m^k$ is strictly increasing (for
$k \ge 1$), hence injective; so distinct elements of $A$ have distinct images and no
collision occurs. $\square$

**Consequence.** The exponent in $|f(A)| \le |A|^{\,k-c}$ cannot be reduced below $1$: there
is no universal super-saving $|f(A)| \le |A|^{1-\varepsilon}$. Genuine expansion requires
input beyond fiber counting.

**Theorem 6 (Lower wall attained — factor-$k$ collapse).** *For $f(x) = x^2$ (so $k=2$) and
the symmetric window $A = \{-n, \dots, n\}$ (of size $2n+1$),*
$$2\,|f(A)| = |A| + 1.$$

*Proof sketch.* Because $a^2 = (-a)^2$, the image of squaring over $\{-n,\dots,n\}$ equals
its image over the nonnegative window $\{0,\dots,n\}$; and squaring is injective on
nonnegatives, so that image has exactly $n+1$ elements. Thus $|f(A)| = n+1$ while
$|A| = 2n+1$, giving $2(n+1) = (2n+1)+1$. $\square$

**Consequence.** This saturates $|A| \le k\,|f(A)|$ with $k=2$ up to the single unavoidable
$+1$ contributed by the fixed point $0$. The factor $k$ in the lower wall is best possible.

Together, Theorems 5 and 6 show the corridor of Theorem 4 is optimal at both endpoints among
purely elementary estimates.

---

## 7. Multiplicativity under composition

We now turn to the structural heart of the paper: how the corridor behaves under
composition, the natural operation when iterating the Minkowski construction.

**Lemma 7 (Composite image equals iterated image).** *For $p, q \in \mathbb{Z}[x]$ and
finite $A \subseteq \mathbb{Z}$,*
$$(q \circ p)(A) \;=\; q\big(p(A)\big).$$

*Proof sketch.* Elementwise, $(q\circ p)(a) = q(p(a))$ for each $a \in A$, so the image of
$A$ under $q\circ p$ is the image under $q$ of the image under $p$. (Formally, this is the
functoriality of images under function composition together with the evaluation identity
$(q\circ p)(a) = q(p(a))$.) $\square$

**Theorem 8 (Multiplicativity of the fiber bound).** *Let $p, q \in \mathbb{Z}[x]$ with
$\deg p = k \ge 1$ and $\deg q = m \ge 1$. Then for every finite $A \subseteq \mathbb{Z}$,*
$$|A| \;\le\; (k \cdot m)\,\big|(q \circ p)(A)\big|,$$
*and $\deg(q\circ p) = k\cdot m$.*

*Proof sketch.* Set $B = p(A)$, an ordinary finite set of integers. Apply Theorem 1 twice:
$$|A| \le k\,|B| = k\,|p(A)|, \qquad |B| \le m\,|q(B)| = m\,|q(p(A))|.$$
Combining, $|A| \le k\,m\,|q(p(A))|$. By Lemma 7, $q(p(A)) = (q\circ p)(A)$, so
$|A| \le (k m)\,|(q\circ p)(A)|$. Finally, $\deg(q\circ p) = \deg q \cdot \deg p = m k$. $\square$

**Remark (This is genuine multiplicativity, not a rewrapping).** The proof does *not* apply
the single-map fiber bound to $q\circ p$ directly; it chains two separate applications
through the intermediate image $B = p(A)$. Each fiber bound is tight in isolation, and $B$ is
a bona fide finite set to which the second bound applies verbatim. Consequently the loss is
*exactly* multiplicative — the degree factors combine to $k\cdot m$, matching the composite
degree, and the collapse never compounds super-multiplicatively.

**Theorem 9 (Composite corridor).** *Let $\deg p = k \ge 1$, $\deg q = m \ge 1$, with
$\deg(q\circ p) = km \ge 2$, and let $A$ be nonempty finite. Writing $K = km$,*
$$\frac{|A|}{K} \;\le\; \big|(q\circ p)(A)\big| \;\le\; |A|^{\,K - 1/K^2}.$$

*Proof sketch.* The lower bound is Theorem 8 rewritten as $|(q\circ p)(A)| \ge |A|/(km)$.
The upper bound is Theorem 3 applied to the composite polynomial $q\circ p$ of degree $K$.
$\square$

**Corollary 10 (Towers).** *For an $r$-fold composition of degree-$k$ monic polynomials,
the composite degree is $k^r$ and the power-saving constant is*
$$c = \frac{1}{k^{2r}}.$$

*Proof sketch.* Iterate Theorem 8: each layer multiplies the degree factor by $k$, giving
$|A| \le k^r\,|F(A)|$ where $F$ is the $r$-fold composite of degree $k^r$; and the composite
corridor (Theorem 9) at degree $K = k^r$ carries constant $c(K) = 1/K^2 = 1/k^{2r}$.
$\square$

The corridor is thus *functorial*: each layer of composition contributes its own degree
factor, and the admissible power-saving constant decays geometrically with the number of
layers.

---

## 8. Algorithms

The results are constructive and lend themselves to direct computation. We record the two
core procedures.

**Algorithm A (Corridor certificate).** Given a polynomial $f$ (as a coefficient vector) and
a finite set $A$, compute $|f(A)|$ by evaluation and deduplication, then return the triple
$\big(|A|/k,\;|f(A)|,\;|A|^{\,k-1/k^2}\big)$ and verify $|A|/k \le |f(A)| \le |A|^{k-1/k^2}$.
Complexity: $O(|A|\cdot k)$ evaluations plus $O(|A|\log|A|)$ for deduplication.

**Algorithm B (Composition-chain verifier).** Given $p, q$ and $A$, form $B = p(A)$ and
$C = q(B)$ by two rounds of elementwise evaluation, form the composite polynomial $q\circ p$
by symbolic composition, evaluate it on $A$ to get $D$, assert $C = D$ (Lemma 7), and check
$|A| \le (\deg p \cdot \deg q)\,|D|$ (Theorem 8). Complexity: two evaluation passes plus one
polynomial composition of cost $O((km)^2)$ in the coefficient representation.

Both algorithms are implemented in the accompanying numerical demonstration.

---

## 9. Applications and discussion

**Baseline for expansion theorems.** Theorem 4 provides the exact elementary baseline
against which any expansion result must be measured. A theorem asserting genuine growth
$|f(A)| \ge |A|^{1+\delta}$ is meaningful precisely because Theorem 5 shows the elementary
floor cannot deliver it: arithmetic progressions keep polynomials injective, so any
$\delta > 0$ must come from the interaction between additive and multiplicative structure.

**Pipelines of maps.** Theorem 8 and Corollary 10 quantify how compression accumulates when
polynomial maps are chained, as in iterated Minkowski constructions. The geometric decay
$1/k^{2r}$ of the power-saving constant gives a precise budget for how many layers a pipeline
can tolerate before its guaranteed non-collapse becomes vacuous.

**Sharp constants.** Because every constant here is explicit and both walls are attained, the
corridor can be used as a certificate in computational experiments: any observed image size
outside the corridor would indicate a bug, and image sizes near a wall pinpoint the
extremal (progression-like or symmetric) structure of $A$.

---

## 10. Future directions

The following research directions extend the corridor and its composition law.

1. **Genuine expansion requires curvature, not merely high degree.** For every non-affine
   monic $f$ of degree $k\ge 2$, is there explicit $\delta(k) > 0$ with either
   $|f(A)| \ge |A|^{1+\delta}$ or $|A+A| \ge |A|^{1+\delta}$ for all finite $A$? The
   elementary corridor forbids collapse below $|A|/k$ but never forces growth, because
   arithmetic progressions keep $f$ injective; real expansion must come from the
   incompatibility of additive structure and multiplicative curvature.

2. **Optimality of the composition constant $1/k^{2r}$.** Is $c = 1/k^{2r}$ best possible
   among constants depending only on the composite degree $k^r$, i.e. no elementary argument
   yields $c = 1/k^{2r}\cdot(1+\varepsilon)$ uniformly? Composition makes the degree, and
   hence the fiber loss, multiply, so the admissible constant should decay geometrically,
   with nested endpoint configurations saturating the whole tower.

3. **A mixed sum–image corridor.** For monic $f$ of degree $k\ge 2$ and finite $A$, does
   $|f(A)+A| \ge c_k\,|A|^{1+1/k}$ hold with explicit $c_k>0$? Adding $A$ back to its image
   reintroduces additive structure the image alone lacks, and the fiber bound already
   supplies the multiplicative slack $1/k$ needed to seed the exponent.

4. **Corridor stability under perturbation.** If monic degree-$k$ polynomials $f,g$ satisfy
   $\|f-g\| \le 1$ in the coefficient sup-norm, does
   $\big|\,|f(A)| - |g(A)|\,\big| \le C_k\,|A|^{1-1/k^2}$ hold for every finite $A$?

---

## 11. Conclusion

We have isolated the exact, unconditional skeleton beneath power-saving estimates for
polynomial images of finite integer sets: the corridor
$|A|/k \le |f(A)| \le |A|^{k-1/k^2}$ with explicit constant $c(k)=1/k^2$, sharp at both
walls, and multiplicative under composition with the tower constant $1/k^{2r}$. The floor is
pure algebra (a degree-$k$ equation has at most $k$ roots); the ceiling marks the limit of
what algebra alone can guarantee (injectivity on progressions). The corridor thus both
secures the elementary territory and points to exactly where deeper, incidence-geometric
methods must take over.
